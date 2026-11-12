import { Fragment, useEffect, useMemo, useState, useCallback } from "react";
import { ChevronRight, ChevronLeft, ChevronUp, ChevronDown, RotateCcw, Save, Check, Loader2, Info, Search, X } from "lucide-react";
import { toast } from "sonner";
import { AppShell } from "@/components/app-shell";
import { SearchableSelect } from "@/components/creatable-catalog-select";
import { RowsPerPageSelect } from "@/components/rows-per-page-select";
import { Avatar } from "@/components/pills";
import { paginationRange } from "@/lib/pagination";
import { loadEmployeePersonas } from "@/lib/employee-personas";
import { fetchSidebarModules, type SidebarModule, type SidebarSubModule, type SidebarTab, type SidebarWidget } from "@/lib/api/catalogs";
import {
  fetchRoles,
  fetchRolePermissions,
  saveRolePermissions,
  resetRolePermissionsToDefault,
  fetchUserRoleAccessList,
  updateUserRoleAccess,
  resetUserRoleAccess,
  type ApiRole,
  type ApiRolePermission,
  type ApiUserRoleAccess,
} from "@/lib/api/users";
import { cn } from "@/lib/utils";

type ModuleAccess = "view" | "view-manage";
type AccessKind = "module" | "submodule" | "widget" | "tab";

const kindLabel: Record<AccessKind, string> = {
  module: "Module",
  submodule: "Sub module",
  widget: "Widget",
  tab: "Tab",
};

const kindBubble: Record<AccessKind, string> = {
  module: "border-blue-200 bg-blue-50 text-blue-700 dark:border-blue-800 dark:bg-blue-950 dark:text-blue-200",
  submodule: "border-violet-200 bg-violet-50 text-violet-700 dark:border-violet-800 dark:bg-violet-950 dark:text-violet-200",
  widget: "border-amber-200 bg-amber-50 text-amber-800 dark:border-amber-800 dark:bg-amber-950 dark:text-amber-200",
  tab: "border-emerald-200 bg-emerald-50 text-emerald-700 dark:border-emerald-800 dark:bg-emerald-950 dark:text-emerald-200",
};

type AccessRow = {
  id: string;
  name: string;
  sortOrder: number;
  kind: AccessKind;
  children: AccessRow[];
};

function byCatalogOrder<T extends { sortOrder: number; name: string }>(rows: T[]) {
  return [...rows].sort((a, b) => a.sortOrder - b.sortOrder || a.name.localeCompare(b.name));
}

function tabRows(rows: SidebarTab[]): AccessRow[] {
  return byCatalogOrder(rows).map((row) => ({
    id: row.id,
    name: row.name,
    sortOrder: row.sortOrder,
    kind: "tab",
    children: tabRows(row.children ?? []),
  }));
}

function submoduleRows(rows: SidebarSubModule[]): AccessRow[] {
  return byCatalogOrder(rows).map((row) => ({
    id: row.id,
    name: row.name,
    sortOrder: row.sortOrder,
    kind: "submodule",
    children: [...submoduleRows(row.children ?? []), ...tabRows(row.tabs ?? [])],
  }));
}

function widgetRows(rows: SidebarWidget[]): AccessRow[] {
  return byCatalogOrder(rows).map((row) => ({
    id: row.id,
    name: row.name,
    sortOrder: row.sortOrder,
    kind: "widget",
    children: [],
  }));
}

function moduleRows(modules: SidebarModule[]): AccessRow[] {
  return byCatalogOrder(modules).map((module) => ({
    id: module.id,
    name: module.name,
    sortOrder: module.sortOrder,
    kind: "module",
    children: [
      ...submoduleRows(module.subModules ?? []),
      ...widgetRows(module.widgets ?? []),
      ...tabRows(module.tabs ?? []),
    ],
  }));
}

function locateRow(
  rows: AccessRow[],
  id: string,
  parent: AccessRow | null = null,
): { row: AccessRow; parent: AccessRow | null } | null {
  for (const row of rows) {
    if (row.id === id) return { row, parent };
    const nested = locateRow(row.children, id, row);
    if (nested) return nested;
  }
  return null;
}

function descendantIds(row: AccessRow): string[] {
  return row.children.flatMap((child) => [child.id, ...descendantIds(child)]);
}

function isViewOnlyRow(row?: AccessRow | null, parent?: AccessRow | null | string): boolean {
  if (!row) return false;
  const pName = typeof parent === "string" ? parent : parent?.name ?? "";
  const isEmployeeDetailTab = row.kind === "tab" && pName.toLowerCase() === "employee detail";
  const isExitSummary = row.kind === "submodule" && row.name.toLowerCase() === "exit summary";
  const isHealthAlerts = pName.toLowerCase() === "health" && row.name.toLowerCase() === "alerts";
  const isHealthEscalations = pName.toLowerCase() === "health" && (row.name.toLowerCase() === "escalations" || row.name.toLowerCase() === "escalation");
  const isMyTeamTab = row.kind === "tab" && pName.toLowerCase() === "team dashboard" && row.name.toLowerCase() === "my team";
  return isEmployeeDetailTab || isExitSummary || isHealthAlerts || isHealthEscalations || isMyTeamTab;
}

function isViewManageOnlyRow(row?: AccessRow | null, parent?: AccessRow | null | string): boolean {
  if (!row) return false;
  const pName = typeof parent === "string" ? parent : parent?.name ?? "";
  const isTimesheetTab = row.kind === "tab" && pName.toLowerCase() === "timesheets";
  const isTimesheetsSubmodule = row.kind === "submodule" && row.name.toLowerCase() === "timesheets";
  return isTimesheetTab || isTimesheetsSubmodule;
}

export function RolesPermissionsPage() {
  const [activeTab, setActiveTab] = useState<"rolewise" | "userwise">("rolewise");
  const [roles, setRoles] = useState<ApiRole[]>([]);
  const [modules, setModules] = useState<SidebarModule[]>([]);
  const [roleId, setRoleId] = useState("");
  const [accessByRole, setAccessByRole] = useState<Record<string, Record<string, ModuleAccess>>>({});
  const [savedAccessByRole, setSavedAccessByRole] = useState<Record<string, Record<string, ModuleAccess>>>({});
  const [defaultAccessByRole, setDefaultAccessByRole] = useState<Record<string, Record<string, ModuleAccess>>>({});
  const [openIds, setOpenIds] = useState<Record<string, boolean>>({});
  const [loading, setLoading] = useState(true);
  const [permissionsLoading, setPermissionsLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [saveSuccess, setSaveSuccess] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    let cancelled = false;
    Promise.all([fetchRoles(), fetchSidebarModules()])
      .then(([roleRows, moduleRows]) => {
        if (cancelled) return;
        // Exclude Admin role from RBAC configuration dropdown (Admin always has full access)
        setRoles(
          roleRows.filter(
            (role) =>
              role.isActive &&
              role.name.toLowerCase() !== "admin" &&
              role.displayName?.toLowerCase() !== "admin" &&
              role.id !== "a0000000-0000-0000-0000-000000000001",
          ),
        );
        // Exclude Settings module from the Roles & Permissions matrix table to prevent access looping
        setModules(
          moduleRows.filter(
            (m) =>
              m.code?.toLowerCase() !== "settings" &&
              m.name?.toLowerCase() !== "settings" &&
              m.id !== "fcb69b3e-e5aa-49bb-921f-7793f0a8c90d",
          ),
        );
      })
      .catch(() => {
        if (!cancelled) setError("Could not load roles and modules.");
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  const rows = useMemo(() => moduleRows(modules), [modules]);

  const roleOptions = useMemo(
    () =>
      roles
        .filter(
          (role) =>
            role.name.toLowerCase() !== "admin" &&
            role.displayName?.toLowerCase() !== "admin" &&
            role.id !== "a0000000-0000-0000-0000-000000000001",
        )
        .map((role) => ({
          value: role.id,
          label: role.displayName || role.name,
        })),
    [roles],
  );

  // Load role permissions from backend whenever a role is chosen
  useEffect(() => {
    if (!roleId) return;
    let cancelled = false;
    setPermissionsLoading(true);
    setSaveSuccess(false);

    fetchRolePermissions(roleId)
      .then((perms) => {
        if (cancelled) return;
        const map: Record<string, ModuleAccess> = {};
        const defaultMap: Record<string, ModuleAccess> = {};
        for (const p of perms) {
          const located = locateRow(rows, p.itemId);
          const viewOnly = isViewOnlyRow(located?.row, located?.parent);
          const manageOnly = isViewManageOnlyRow(located?.row, located?.parent);
          // Live access map
          if (manageOnly) {
            if (p.canManage === 1 || p.canView === 1) map[p.itemId] = "view-manage";
          } else if (p.canManage === 1 && !viewOnly) {
            map[p.itemId] = "view-manage";
          } else if (p.canView === 1 || p.canManage === 1) {
            map[p.itemId] = "view";
          }
          // Default (baseline) access map — same logic but reads defaultCanView/defaultCanManage
          const dv = p.defaultCanView ?? 0;
          const dm = p.defaultCanManage ?? 0;
          if (manageOnly) {
            if (dm === 1 || dv === 1) defaultMap[p.itemId] = "view-manage";
          } else if (dm === 1 && !viewOnly) {
            defaultMap[p.itemId] = "view-manage";
          } else if (dv === 1 || dm === 1) {
            defaultMap[p.itemId] = "view";
          }
        }
        setAccessByRole((prev) => ({ ...prev, [roleId]: map }));
        setSavedAccessByRole((prev) => ({ ...prev, [roleId]: map }));
        setDefaultAccessByRole((prev) => ({ ...prev, [roleId]: defaultMap }));
      })
      .catch(() => {
        if (!cancelled) setError("Failed to load permissions for selected role.");
      })
      .finally(() => {
        if (!cancelled) setPermissionsLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [roleId]);

  const selectedAccess = accessByRole[roleId] ?? {};
  const selectedDefault = defaultAccessByRole[roleId] ?? {};

  const hasUnsavedChanges = useMemo(() => {
    if (!roleId) return false;
    const current = accessByRole[roleId] ?? {};
    const saved = savedAccessByRole[roleId] ?? {};
    const currentKeys = Object.keys(current);
    const savedKeys = Object.keys(saved);
    if (currentKeys.length !== savedKeys.length) return true;
    for (const key of currentKeys) {
      if (current[key] !== saved[key]) return true;
    }
    return false;
  }, [roleId, accessByRole, savedAccessByRole]);

  const toggleOpen = (id: string) => {
    setOpenIds((prev) => ({ ...prev, [id]: !prev[id] }));
  };

  const setAccess = (moduleId: string, access: ModuleAccess | null) => {
    if (!roleId) return;
    setAccessByRole((prev) => {
      const current = { ...(prev[roleId] ?? {}) };
      const located = locateRow(rows, moduleId);
      const viewOnly = isViewOnlyRow(located?.row, located?.parent);
      const manageOnly = isViewManageOnlyRow(located?.row, located?.parent);
      if (viewOnly && access === "view-manage") {
        access = "view";
      }
      if (manageOnly && access === "view") {
        access = "view-manage";
      }
      const parentAccess = located?.parent ? current[located.parent.id] : undefined;
      const isTimesheetsUnderMyTeam =
        located?.row.kind === "submodule" &&
        located.row.name.toLowerCase() === "timesheets" &&
        located.parent?.name.toLowerCase() === "my team";

      if (access !== null && located?.parent) {
        if (!parentAccess) return prev;
        if (access === "view-manage" && parentAccess !== "view-manage" && !isTimesheetsUnderMyTeam) {
          return prev;
        }
      }
      if (access === null) {
        delete current[moduleId];
        if (located) {
          for (const id of descendantIds(located.row)) delete current[id];
        }
      } else {
        current[moduleId] = access;
        if (access === "view" && located) {
          for (const id of descendantIds(located.row)) {
            if (current[id] === "view-manage") {
              const childLoc = locateRow(rows, id);
              if (isViewManageOnlyRow(childLoc?.row, childLoc?.parent)) {
                delete current[id];
              } else {
                current[id] = "view";
              }
            }
          }
        }
      }
      return { ...prev, [roleId]: current };
    });
  };

  const handleReset = () => {
    if (!roleId) return;
    const saved = savedAccessByRole[roleId] ?? {};
    setAccessByRole((prev) => ({ ...prev, [roleId]: { ...saved } }));
    setSaveSuccess(false);
  };

  const handleResetToBaseline = async () => {
    if (!roleId || saving) return;
    setSaving(true);
    setSaveSuccess(false);
    setError("");

    try {
      await resetRolePermissionsToDefault(roleId);
      const perms = await fetchRolePermissions(roleId);
      const map: Record<string, ModuleAccess> = {};
      const defaultMap: Record<string, ModuleAccess> = {};
      for (const p of perms) {
        const located = locateRow(rows, p.itemId);
        const viewOnly = isViewOnlyRow(located?.row, located?.parent);
        const manageOnly = isViewManageOnlyRow(located?.row, located?.parent);
        if (manageOnly) {
          if (p.canManage === 1 || p.canView === 1) map[p.itemId] = "view-manage";
        } else if (p.canManage === 1 && !viewOnly) {
          map[p.itemId] = "view-manage";
        } else if (p.canView === 1 || p.canManage === 1) {
          map[p.itemId] = "view";
        }
        const dv = p.defaultCanView ?? 0;
        const dm = p.defaultCanManage ?? 0;
        if (manageOnly) {
          if (dm === 1 || dv === 1) defaultMap[p.itemId] = "view-manage";
        } else if (dm === 1 && !viewOnly) {
          defaultMap[p.itemId] = "view-manage";
        } else if (dv === 1 || dm === 1) {
          defaultMap[p.itemId] = "view";
        }
      }
      setAccessByRole((prev) => ({ ...prev, [roleId]: map }));
      setSavedAccessByRole((prev) => ({ ...prev, [roleId]: map }));
      setDefaultAccessByRole((prev) => ({ ...prev, [roleId]: defaultMap }));
      setSaveSuccess(true);
      if (typeof window !== "undefined") {
        window.dispatchEvent(new CustomEvent("permissions-updated", { detail: { roleId } }));
      }
      setTimeout(() => setSaveSuccess(false), 3000);
    } catch {
      setError("Failed to reset role permissions to baseline defaults.");
    } finally {
      setSaving(false);
    }
  };

  const handleSave = async () => {
    if (!roleId || saving) return;
    setSaving(true);
    setSaveSuccess(false);
    setError("");

    try {
      const current = accessByRole[roleId] ?? {};
      const payload: ApiRolePermission[] = Object.entries(current).map(([itemId, access]) => {
        const located = locateRow(rows, itemId);
        const viewOnly = isViewOnlyRow(located?.row, located?.parent);
        const manageOnly = isViewManageOnlyRow(located?.row, located?.parent);
        const effectiveAccess = viewOnly && access === "view-manage" ? "view" : manageOnly ? "view-manage" : access;
        return {
          itemId,
          itemType: located?.row.kind ?? "module",
          canView: effectiveAccess === "view" || effectiveAccess === "view-manage" ? 1 : 0,
          canManage: effectiveAccess === "view-manage" ? 1 : 0,
        };
      });

      await saveRolePermissions(roleId, payload);
      setSavedAccessByRole((prev) => ({ ...prev, [roleId]: { ...current } }));
      setSaveSuccess(true);
      if (typeof window !== "undefined") {
        window.dispatchEvent(new CustomEvent("permissions-updated", { detail: { roleId } }));
      }
      setTimeout(() => setSaveSuccess(false), 3000);
    } catch {
      setError("Failed to save role permissions.");
    } finally {
      setSaving(false);
    }
  };

  return (
    <AppShell title="Roles & Permissions" subtitle="Settings">
      <div className="space-y-6">
        {/* Internal Tabs Switcher: Rolewise Access vs Userwise Access */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 border-b border-border pb-4">
          <div>
            <h1 className="text-xl font-bold tracking-tight text-foreground">Roles & Permissions</h1>
            <p className="text-xs text-muted-foreground mt-0.5">
              Configure system-wide RBAC access matrices or manage user-specific assigned roles.
            </p>
          </div>

          <div className="inline-flex rounded-lg border border-border bg-muted/60 p-1 self-start sm:self-auto">
            <button
              type="button"
              onClick={() => setActiveTab("rolewise")}
              className={cn(
                "rounded-md px-4 py-1.5 text-xs font-medium transition-colors cursor-pointer",
                activeTab === "rolewise"
                  ? "bg-background text-foreground shadow-xs font-semibold"
                  : "text-muted-foreground hover:text-foreground",
              )}
            >
              Rolewise Access
            </button>
            <button
              type="button"
              onClick={() => setActiveTab("userwise")}
              className={cn(
                "rounded-md px-4 py-1.5 text-xs font-medium transition-colors cursor-pointer",
                activeTab === "userwise"
                  ? "bg-background text-foreground shadow-xs font-semibold"
                  : "text-muted-foreground hover:text-foreground",
              )}
            >
              Userwise Access
            </button>
          </div>
        </div>

        {activeTab === "rolewise" ? (
          <div className="mx-auto max-w-4xl space-y-6">
        <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
          <div className="w-full max-w-sm">
            <SearchableSelect
              id="rbac-role"
              label="RBAC Role"
              options={roleOptions}
              value={roleId}
              onChange={setRoleId}
              placeholder={loading ? "Loading roles…" : "Select an RBAC role"}
              disabled={loading || roleOptions.length === 0}
              clearable
            />
          </div>

          <div className="flex items-center gap-2.5">
            {saveSuccess && (
              <span className="inline-flex items-center gap-1.5 text-xs font-semibold text-emerald-600 dark:text-emerald-400 bg-emerald-50 dark:bg-emerald-950/60 border border-emerald-200 dark:border-emerald-800 rounded-md px-2.5 py-1.5">
                <Check className="size-3.5" />
                Saved
              </span>
            )}
            <button
              type="button"
              onClick={handleResetToBaseline}
              disabled={!roleId || saving || permissionsLoading}
              title="Reset all permissions for this role back to the default baseline"
              className="inline-flex items-center gap-1.5 rounded-lg border border-border bg-card px-3.5 py-2 text-xs font-semibold text-muted-foreground hover:text-foreground hover:bg-muted disabled:cursor-not-allowed disabled:opacity-40 transition-colors shadow-2xs"
            >
              <RotateCcw className="size-3.5 text-muted-foreground" />
              Reset to Baseline
            </button>
            <button
              type="button"
              onClick={handleReset}
              disabled={!roleId || !hasUnsavedChanges || saving || permissionsLoading}
              className="inline-flex items-center gap-1.5 rounded-lg border border-border bg-card px-3.5 py-2 text-xs font-semibold text-foreground hover:bg-muted disabled:cursor-not-allowed disabled:opacity-40 transition-colors shadow-2xs"
            >
              <RotateCcw className="size-3.5" />
              Reset
            </button>
            <button
              type="button"
              onClick={handleSave}
              disabled={!roleId || !hasUnsavedChanges || saving || permissionsLoading}
              className="inline-flex items-center gap-1.5 rounded-lg bg-primary px-4 py-2 text-xs font-semibold text-primary-foreground hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-40 transition-colors shadow-2xs"
            >
              {saving ? <Loader2 className="size-3.5 animate-spin" /> : <Save className="size-3.5" />}
              {saving ? "Saving…" : "Save Changes"}
            </button>
          </div>
        </div>

        {error && <p className="text-sm text-destructive">{error}</p>}

        <div className="overflow-hidden rounded-lg border border-border bg-card">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border bg-muted/50 text-left">
                <th className="px-4 py-3 font-medium text-foreground">Module</th>
                <th className="w-32 px-4 py-3 font-medium text-foreground">Type</th>
                <th className="w-36 px-4 py-3 text-center font-medium text-foreground">Only view</th>
                <th className="w-40 px-4 py-3 text-center font-medium text-foreground">View + Manage</th>
              </tr>
            </thead>
            <tbody>
              {(loading || permissionsLoading) && (
                <tr>
                  <td colSpan={4} className="px-4 py-8 text-center text-muted-foreground">
                    <span className="inline-flex items-center gap-2">
                      <Loader2 className="size-4 animate-spin text-primary" />
                      {loading ? "Loading modules…" : "Loading permissions…"}
                    </span>
                  </td>
                </tr>
              )}
              {!loading && !permissionsLoading && modules.length === 0 && (
                <tr>
                  <td colSpan={4} className="px-4 py-8 text-center text-muted-foreground">
                    No modules are in the catalog.
                  </td>
                </tr>
              )}
              {!permissionsLoading && (
                <AccessRows
                  rows={rows}
                  depth={0}
                  roleId={roleId}
                  parentAccess={null}
                  parentName=""
                  openIds={openIds}
                  selectedAccess={selectedAccess}
                  defaultAccess={selectedDefault}
                  saving={saving}
                  onToggle={toggleOpen}
                  onSetAccess={setAccess}
                />
              )}
            </tbody>
          </table>
        </div>
      </div>
    ) : (
      <UserwiseAccessView />
    )}
  </div>
</AppShell>
  );
}

function AccessRows({
  rows,
  depth,
  roleId,
  parentAccess,
  parentName,
  openIds,
  selectedAccess,
  defaultAccess,
  saving,
  onToggle,
  onSetAccess,
}: {
  rows: AccessRow[];
  depth: number;
  roleId: string;
  parentAccess: ModuleAccess | null;
  parentName: string;
  openIds: Record<string, boolean>;
  selectedAccess: Record<string, ModuleAccess>;
  defaultAccess: Record<string, ModuleAccess>;
  saving?: boolean;
  onToggle: (id: string) => void;
  onSetAccess: (id: string, access: ModuleAccess | null) => void;
}) {
  return rows.map((row) => {
    const isChild = depth > 0;
    const isDashboardModule = row.kind === "module" && row.name.toLowerCase() === "dashboard";
    const isWidget = row.kind === "widget";
    const viewOnly = isViewOnlyRow(row, parentName);
    const manageOnly = isViewManageOnlyRow(row, parentName);
    const access = viewOnly && selectedAccess[row.id] === "view-manage" ? "view" : selectedAccess[row.id];
    const hasChildren = row.children.length > 0;
    const open = hasChildren && !!openIds[row.id];

    // Baseline default for this row
    const baseline = defaultAccess[row.id] ?? null;
    const baselineLabel =
      baseline === "view-manage"
        ? "Default: View + Manage"
        : baseline === "view"
          ? "Default: Only View"
          : "Default: No Access";

    // Core rule: Dashboard, widgets, Employee Detail tabs, and Exit Summary do not support View + Manage
    const viewManageSupported = !isDashboardModule && !isWidget && !viewOnly;

    // View radio button supported: false if manageOnly (Timesheets tabs & Timesheets submodule)
    const viewSupported = !manageOnly;

    // View radio button disabled rules
    const viewDisabled = !roleId || !!saving || (isChild && !parentAccess) || !viewSupported;

    const isTimesheetsUnderMyTeam =
      row.kind === "submodule" &&
      row.name.toLowerCase() === "timesheets" &&
      parentName.toLowerCase() === "my team";

    // Manage radio button disabled rules
    const manageDisabled =
      !roleId ||
      !!saving ||
      !viewManageSupported ||
      (isChild && parentAccess !== "view-manage" && !isTimesheetsUnderMyTeam);

    return (
      <Fragment key={row.id}>
        <tr className="border-b border-border last:border-b-0">
          <td
            className={cn("py-2.5 pr-4 text-foreground", depth === 0 ? "font-medium" : "font-normal")}
            style={{ paddingLeft: 12 + depth * 28 }}
          >
            <span className="flex items-center gap-1.5">
              {hasChildren ? (
                <button
                  type="button"
                  aria-expanded={open}
                  aria-label={open ? `Hide rows under ${row.name}` : `Show rows under ${row.name}`}
                  onClick={() => onToggle(row.id)}
                  className="inline-flex size-6 shrink-0 items-center justify-center rounded text-muted-foreground hover:bg-muted hover:text-foreground"
                >
                  <ChevronRight className={cn("size-4 transition-transform duration-200", open && "rotate-90")} />
                </button>
              ) : (
                <span className="size-6 shrink-0" aria-hidden />
              )}
              <span>{row.name}</span>
              {roleId && (
                <span
                  title={baselineLabel}
                  aria-label={baselineLabel}
                  className="inline-flex items-center justify-center text-muted-foreground/50 hover:text-muted-foreground transition-colors cursor-default"
                >
                  <Info className="size-3" />
                </span>
              )}
            </span>
          </td>
          <td className="px-4 py-3">
            <span
              className={cn(
                "inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-medium leading-none",
                kindBubble[row.kind],
              )}
            >
              {kindLabel[row.kind]}
            </span>
          </td>
          <td
            className={cn(
              "px-4 py-3 text-center",
              !viewSupported || viewDisabled ? "cursor-not-allowed" : "cursor-pointer",
            )}
            onClick={() => {
              if (!viewSupported || viewDisabled) return;
              if (access === "view") onSetAccess(row.id, null);
              else onSetAccess(row.id, "view");
            }}
          >
            {viewSupported ? (
              <AccessRadio
                checked={access === "view"}
                disabled={viewDisabled}
                label={`Only view for ${row.name}`}
                title={viewDisabled && parentName ? `Give ${parentName} access first` : undefined}
                onChange={() => onSetAccess(row.id, "view")}
                onClear={() => onSetAccess(row.id, null)}
              />
            ) : (
              <span className="text-xs text-muted-foreground/60 select-none">—</span>
            )}
          </td>
          <td
            className={cn(
              "px-4 py-3 text-center",
              !viewManageSupported || manageDisabled ? "cursor-not-allowed" : "cursor-pointer",
            )}
            onClick={() => {
              if (!viewManageSupported || manageDisabled) return;
              if (access === "view-manage") onSetAccess(row.id, null);
              else onSetAccess(row.id, "view-manage");
            }}
          >
            {viewManageSupported ? (
              <AccessRadio
                checked={access === "view-manage"}
                disabled={manageDisabled}
                label={`View and manage for ${row.name}`}
                title={
                  manageDisabled && parentName
                    ? parentAccess
                      ? `View + Manage on ${parentName} is required`
                      : `Give ${parentName} access first`
                    : undefined
                }
                onChange={() => onSetAccess(row.id, "view-manage")}
                onClear={() => onSetAccess(row.id, null)}
              />
            ) : (
              <span className="text-xs text-muted-foreground/60 select-none">—</span>
            )}
          </td>
        </tr>
        {open && (
          <AccessRows
            rows={row.children}
            depth={depth + 1}
            roleId={roleId}
            parentAccess={access ?? null}
            parentName={row.name}
            openIds={openIds}
            selectedAccess={selectedAccess}
            defaultAccess={defaultAccess}
            saving={saving}
            onToggle={onToggle}
            onSetAccess={onSetAccess}
          />
        )}
      </Fragment>
    );
  });
}

function AccessRadio({
  checked,
  disabled,
  label,
  title,
  onChange,
  onClear,
}: {
  checked: boolean;
  disabled: boolean;
  label: string;
  title?: string;
  onChange: () => void;
  onClear: () => void;
}) {
  const handleClick = (e: React.MouseEvent<HTMLButtonElement>) => {
    e.stopPropagation();
    if (disabled) return;
    if (checked) {
      onClear();
    } else {
      onChange();
    }
  };

  const resolvedTitle = disabled
    ? title
    : checked
      ? "Click to unselect"
      : title || label;

  return (
    <button
      type="button"
      role="radio"
      aria-checked={checked}
      aria-label={label}
      disabled={disabled}
      title={resolvedTitle}
      onClick={handleClick}
      className={cn(
        "inline-flex size-7 items-center justify-center rounded-full transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        disabled ? "cursor-not-allowed opacity-40" : "cursor-pointer hover:bg-muted/70",
      )}
    >
      <span
        className={cn(
          "size-4 rounded-full border transition-all flex items-center justify-center",
          checked
            ? "border-primary text-primary"
            : "border-muted-foreground/40 hover:border-primary/70",
          disabled && "border-muted-foreground/30 opacity-40",
        )}
      >
        {checked && <span className="size-2 rounded-full bg-primary" />}
      </span>
    </button>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Userwise Access Subview
// ─────────────────────────────────────────────────────────────────────────────

const USERWISE_DEPARTMENT_OPTIONS = [
  "All",
  "Core",
  "Functional - Accounts",
  "Functional - HR",
  "Functional - IT Administration",
  "Functional - Project Management",
  "Functional - Sales",
  "R&D (Research & Development)",
  "Services - Consulting",
  "Services - Operations",
  "Services - Testing",
];

type UserwiseSortKey = "name" | "department" | "originalRole" | "currentRole";
type UserwiseSortDir = "asc" | "desc";

function UserwiseAccessView() {
  const [data, setData] = useState<ApiUserRoleAccess[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(15);
  const [total, setTotal] = useState(0);
  const [totalPages, setTotalPages] = useState(1);
  const [search, setSearch] = useState("");
  const [debouncedSearch, setDebouncedSearch] = useState("");
  const [department, setDepartment] = useState("All");
  const [rowUpdating, setRowUpdating] = useState<Record<string, boolean>>({});
  const [sortKey, setSortKey] = useState<UserwiseSortKey>("name");
  const [sortDir, setSortDir] = useState<UserwiseSortDir>("asc");

  // Debounce search input
  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedSearch(search);
      setPage(1);
    }, 300);
    return () => clearTimeout(timer);
  }, [search]);

  // Load data from backend
  const loadData = useCallback(async () => {
    setLoading(true);
    try {
      const res = await fetchUserRoleAccessList({
        page,
        perPage: pageSize,
        search: debouncedSearch.trim() || undefined,
        department: department !== "All" ? department : undefined,
      });
      setData(res.items);
      setTotal(res.total);
      setTotalPages(res.totalPages);
    } catch {
      toast.error("Failed to load user access list.");
    } finally {
      setLoading(false);
    }
  }, [page, pageSize, debouncedSearch, department]);

  useEffect(() => {
    void loadData();
  }, [loadData]);

  // Sort rows client-side for active page
  const sortedRows = useMemo(() => {
    const sorted = [...data];
    sorted.sort((a, b) => {
      let diff = 0;
      if (sortKey === "name") {
        diff = a.fullName.localeCompare(b.fullName);
      } else if (sortKey === "department") {
        diff = a.departmentName.localeCompare(b.departmentName);
      } else if (sortKey === "originalRole") {
        const aRole = a.originalRoleDisplayName || a.originalRoleName;
        const bRole = b.originalRoleDisplayName || b.originalRoleName;
        diff = aRole.localeCompare(bRole);
      } else if (sortKey === "currentRole") {
        const aRole = a.currentRoleDisplayName || a.currentRoleName;
        const bRole = b.currentRoleDisplayName || b.currentRoleName;
        diff = aRole.localeCompare(bRole);
      }
      return sortDir === "asc" ? diff : -diff;
    });
    return sorted;
  }, [data, sortKey, sortDir]);

  const handleRoleChange = async (employeeId: string, newRoleId: string) => {
    if (!newRoleId) return;
    setRowUpdating((prev) => ({ ...prev, [employeeId]: true }));
    try {
      const updated = await updateUserRoleAccess(employeeId, newRoleId);
      setData((prev) => prev.map((item) => (item.id === employeeId ? updated : item)));
      toast.success(`Role switched to ${updated.currentRoleDisplayName} for ${updated.fullName}`);
      void loadEmployeePersonas(true);
      if (typeof window !== "undefined") {
        window.dispatchEvent(new CustomEvent("permissions-updated", { detail: { roleId: newRoleId } }));
      }
    } catch (err: any) {
      toast.error(err?.message || "Failed to update employee role.");
    } finally {
      setRowUpdating((prev) => ({ ...prev, [employeeId]: false }));
    }
  };

  const handleReset = async (employeeId: string) => {
    setRowUpdating((prev) => ({ ...prev, [employeeId]: true }));
    try {
      const updated = await resetUserRoleAccess(employeeId);
      setData((prev) => prev.map((item) => (item.id === employeeId ? updated : item)));
      toast.success(`Reset role to ${updated.originalRoleDisplayName} for ${updated.fullName}`);
      void loadEmployeePersonas(true);
      if (typeof window !== "undefined") {
        window.dispatchEvent(new CustomEvent("permissions-updated", { detail: { roleId: updated.currentRoleId } }));
      }
    } catch (err: any) {
      toast.error(err?.message || "Failed to reset employee role.");
    } finally {
      setRowUpdating((prev) => ({ ...prev, [employeeId]: false }));
    }
  };

  const hasActiveFilters = search.trim().length > 0 || department !== "All";

  const clearAllFilters = () => {
    setSearch("");
    setDebouncedSearch("");
    setDepartment("All");
    setPage(1);
  };

  const pageRange = paginationRange(page, pageSize, total);

  return (
    <div className="w-full space-y-4">
      {/* Filter and Search Bar (matching Employee Directory card design) */}
      <div className="rounded-xl border border-border bg-card p-3.5 shadow-xs">
        <div className="flex flex-col md:flex-row items-stretch md:items-center gap-2.5">
          {/* Search input */}
          <div className="relative flex-1 min-w-[240px]">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search by employee name, code, email, role..."
              className="h-9 w-full rounded-md border border-input bg-background pl-9 pr-8 text-xs font-normal text-foreground placeholder:text-muted-foreground outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:border-primary transition-all"
            />
            {search && (
              <button
                type="button"
                onClick={() => setSearch("")}
                className="absolute right-2.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground p-0.5 cursor-pointer"
                title="Clear search"
              >
                <X className="h-3.5 w-3.5" />
              </button>
            )}
          </div>

          {/* Department Filter */}
          <div className="w-full md:w-56 shrink-0">
            <select
              value={department}
              onChange={(e) => {
                setDepartment(e.target.value);
                setPage(1);
              }}
              className="h-9 w-full rounded-md border border-input bg-background px-3 text-xs font-medium text-foreground outline-none cursor-pointer hover:bg-muted/50 focus:border-primary transition-colors"
            >
              {USERWISE_DEPARTMENT_OPTIONS.map((dept) => (
                <option key={dept} value={dept}>
                  {dept === "All" ? "All Departments" : dept}
                </option>
              ))}
            </select>
          </div>

          {/* Reset Filters Button */}
          {hasActiveFilters && (
            <div className="shrink-0 flex items-center">
              <button
                type="button"
                onClick={clearAllFilters}
                className="h-9 inline-flex items-center justify-center gap-1.5 rounded-md border border-dashed border-border px-3 text-xs font-medium text-muted-foreground hover:bg-muted hover:text-foreground transition-colors cursor-pointer"
              >
                <RotateCcw className="h-3.5 w-3.5" />
                <span>Reset Filters</span>
              </button>
            </div>
          )}
        </div>
      </div>

      {/* Userwise Access Table */}
      <div className="rounded-xl border border-border bg-card shadow-sm overflow-hidden flex flex-col">
        <div className="overflow-auto max-h-[calc(100vh-270px)] min-h-[460px]">
          <table className="w-full text-sm table-fixed min-w-[960px]">
            <thead className="sticky top-0 z-10 bg-blue-50/80 dark:bg-blue-950/45 backdrop-blur-md text-left text-xs text-blue-950/85 dark:text-blue-100/85 border-b border-slate-300 dark:border-slate-700 shadow-2xs">
              <tr>
                <SortableUserTh
                  label="Employee Name"
                  column="name"
                  sortKey={sortKey}
                  sortDir={sortDir}
                  onSort={(col) => {
                    if (sortKey === col) setSortDir((d) => (d === "asc" ? "desc" : "asc"));
                    else {
                      setSortKey(col);
                      setSortDir("asc");
                    }
                  }}
                  className="w-72 min-w-[240px]"
                />
                <SortableUserTh
                  label="Department"
                  column="department"
                  sortKey={sortKey}
                  sortDir={sortDir}
                  onSort={(col) => {
                    if (sortKey === col) setSortDir((d) => (d === "asc" ? "desc" : "asc"));
                    else {
                      setSortKey(col);
                      setSortDir("asc");
                    }
                  }}
                  className="w-56 min-w-[190px]"
                />
                <SortableUserTh
                  label="Original RBAC Role"
                  column="originalRole"
                  sortKey={sortKey}
                  sortDir={sortDir}
                  onSort={(col) => {
                    if (sortKey === col) setSortDir((d) => (d === "asc" ? "desc" : "asc"));
                    else {
                      setSortKey(col);
                      setSortDir("asc");
                    }
                  }}
                  className="w-56 min-w-[190px]"
                />
                <SortableUserTh
                  label="Assigned RBAC Role"
                  column="currentRole"
                  sortKey={sortKey}
                  sortDir={sortDir}
                  onSort={(col) => {
                    if (sortKey === col) setSortDir((d) => (d === "asc" ? "desc" : "asc"));
                    else {
                      setSortKey(col);
                      setSortDir("asc");
                    }
                  }}
                  className="w-64 min-w-[220px]"
                />
                <th className="relative w-32 min-w-[110px] whitespace-nowrap px-4 py-3 font-semibold text-right text-xs text-blue-950/85 dark:text-blue-100/85">
                  Action
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {loading ? (
                <tr>
                  <td colSpan={5} className="px-4 py-16 text-center text-sm text-muted-foreground">
                    <div className="flex flex-col items-center justify-center gap-2">
                      <Loader2 className="h-6 w-6 animate-spin text-primary" />
                      <span>Loading user access list…</span>
                    </div>
                  </td>
                </tr>
              ) : sortedRows.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-4 py-16 text-center text-sm text-muted-foreground">
                    No employees match your search or filter criteria.
                  </td>
                </tr>
              ) : (
                sortedRows.map((row) => {
                  const isUpdating = !!rowUpdating[row.id];
                  return (
                    <tr
                      key={row.id}
                      className={cn(
                        "transition-colors hover:bg-accent/30",
                        row.isSwitched && "bg-primary/[0.02]"
                      )}
                    >
                      {/* Employee Name */}
                      <td className="w-72 min-w-[240px] whitespace-nowrap px-4 py-3.5">
                        <div className="flex items-center gap-2.5 min-w-0">
                          <Avatar name={row.fullName} size={30} />
                          <div className="min-w-0 flex flex-col">
                            <span className="font-semibold text-foreground truncate" title={row.fullName}>
                              {row.fullName}
                            </span>
                            <span className="text-[11px] text-muted-foreground font-mono truncate" title={row.workEmail}>
                              {row.employeeCode} · {row.workEmail}
                            </span>
                          </div>
                        </div>
                      </td>

                      {/* Department */}
                      <td className="w-56 min-w-[190px] whitespace-nowrap px-4 py-3.5 text-foreground/90 font-medium truncate" title={row.departmentName}>
                        {row.departmentName}
                      </td>

                      {/* Original RBAC Role */}
                      <td className="w-56 min-w-[190px] whitespace-nowrap px-4 py-3.5">
                        <span
                          className="inline-flex items-center rounded-md border border-slate-200 dark:border-slate-700 bg-slate-100/80 dark:bg-slate-900/60 px-2.5 py-1 text-xs font-medium text-slate-700 dark:text-slate-300 truncate max-w-full"
                          title={row.originalRoleDisplayName || row.originalRoleName}
                        >
                          {row.originalRoleDisplayName || row.originalRoleName}
                        </span>
                      </td>

                      {/* Assigned RBAC Role (department-restricted dropdown) */}
                      <td className="w-64 min-w-[220px] whitespace-nowrap px-4 py-3.5">
                        <div className="flex flex-col gap-1 max-w-[230px]">
                          <select
                            value={row.currentRoleId ?? ""}
                            onChange={(e) => handleRoleChange(row.id, e.target.value)}
                            disabled={row.isSuperAdmin || isUpdating}
                            title={row.isSuperAdmin ? "Super Admin role is locked" : `Choose role from ${row.departmentName}`}
                            className={cn(
                              "h-8 w-full rounded-md border px-2.5 text-xs font-medium transition-colors outline-none cursor-pointer",
                              row.isSwitched
                                ? "border-primary bg-primary/5 text-primary font-semibold focus:ring-1 focus:ring-primary"
                                : "border-input bg-background text-foreground hover:bg-muted/50 focus:border-primary",
                              (row.isSuperAdmin || isUpdating) && "opacity-60 cursor-not-allowed bg-muted/30"
                            )}
                          >
                            {row.departmentRoles.map((role) => (
                              <option key={role.id} value={role.id}>
                                {role.displayName || role.name}
                              </option>
                            ))}
                          </select>
                          {row.isSwitched && (
                            <span className="inline-flex items-center gap-1 text-[10px] font-semibold text-primary">
                              <span className="size-1.5 rounded-full bg-primary animate-pulse" />
                              Switched from original
                            </span>
                          )}
                        </div>
                      </td>

                      {/* Action: Reset Button */}
                      <td className="w-32 min-w-[110px] whitespace-nowrap px-4 py-3.5 text-right">
                        <button
                          type="button"
                          onClick={() => handleReset(row.id)}
                          disabled={!row.isSwitched || isUpdating}
                          title={
                            row.isSwitched
                              ? `Reset back to ${row.originalRoleDisplayName || row.originalRoleName}`
                              : "Role is already original"
                          }
                          className={cn(
                            "inline-flex items-center gap-1.5 rounded-md px-2.5 py-1.5 text-xs font-medium transition-colors shadow-2xs",
                            row.isSwitched
                              ? "border border-border bg-card text-foreground hover:bg-muted cursor-pointer hover:border-slate-300 dark:hover:border-slate-700"
                              : "border border-border/40 bg-muted/20 text-muted-foreground/40 cursor-not-allowed"
                          )}
                        >
                          {isUpdating ? (
                            <Loader2 className="size-3.5 animate-spin text-muted-foreground" />
                          ) : (
                            <RotateCcw className="size-3.5 text-muted-foreground" />
                          )}
                          <span>Reset</span>
                        </button>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>

        {/* Frozen / Sticky Pagination Footer (identical styling to Employee Directory) */}
        <div className="sticky bottom-0 z-20 flex flex-col sm:flex-row items-center justify-between gap-3 border-t border-slate-300 dark:border-slate-700 bg-blue-50/80 dark:bg-blue-950/45 backdrop-blur-md px-4 py-3 text-xs text-blue-950/80 dark:text-blue-100/80 shadow-xs">
          <div className="flex items-center gap-3">
            <span>
              Showing <strong className="font-semibold text-blue-950 dark:text-blue-100">{pageRange.from}</strong> - <strong className="font-semibold text-blue-950 dark:text-blue-100">{pageRange.to}</strong> of <strong className="font-semibold text-blue-950 dark:text-blue-100">{total}</strong> employees
            </span>
            <span className="text-slate-300 dark:text-slate-600">|</span>
            <div className="flex items-center gap-1.5">
              <span>Per page:</span>
              <RowsPerPageSelect
                value={pageSize}
                onChange={(size) => {
                  setPageSize(size);
                  setPage(1);
                }}
                className="h-7 min-w-[3.25rem] rounded-md border border-slate-300 dark:border-slate-600 bg-white/90 dark:bg-blue-950/60 pl-2 pr-5 text-xs font-medium text-blue-950 dark:text-blue-100 outline-none cursor-pointer hover:bg-blue-100/50 dark:hover:bg-blue-900/40 transition-colors focus-visible:ring-1 focus-visible:ring-blue-500"
              />
            </div>
          </div>

          <div className="flex items-center gap-1.5">
            <button
              type="button"
              onClick={() => setPage((p) => Math.max(1, p - 1))}
              disabled={page <= 1}
              className="inline-flex items-center gap-1 rounded-md border border-slate-300 dark:border-slate-600 bg-white/90 dark:bg-blue-900/50 px-2.5 py-1 text-xs font-medium text-blue-950 dark:text-blue-100 hover:bg-blue-100/60 dark:hover:bg-blue-800/60 disabled:opacity-40 disabled:pointer-events-none shadow-2xs transition-colors cursor-pointer"
            >
              <ChevronLeft className="h-3.5 w-3.5" /> Previous
            </button>
            <span className="px-2 tabular-nums font-semibold text-blue-950 dark:text-blue-100">
              {page} / {totalPages}
            </span>
            <button
              type="button"
              onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
              disabled={page >= totalPages}
              className="inline-flex items-center gap-1 rounded-md border border-slate-300 dark:border-slate-600 bg-white/90 dark:bg-blue-900/50 px-2.5 py-1 text-xs font-medium text-blue-950 dark:text-blue-100 hover:bg-blue-100/60 dark:hover:bg-blue-800/60 disabled:opacity-40 disabled:pointer-events-none shadow-2xs transition-colors cursor-pointer"
            >
              Next <ChevronRight className="h-3.5 w-3.5" />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

function SortableUserTh<T extends string>({
  label,
  column,
  sortKey,
  sortDir,
  onSort,
  className,
  isLast,
}: {
  label: string;
  column: T;
  sortKey: T;
  sortDir: UserwiseSortDir;
  onSort: (column: T) => void;
  className?: string;
  isLast?: boolean;
}) {
  const active = sortKey === column;
  return (
    <th className={cn("relative whitespace-nowrap px-4 py-3 font-semibold", className)}>
      <button
        type="button"
        onClick={() => onSort(column)}
        className={cn(
          "group inline-flex items-center gap-1.5 text-left text-xs font-semibold transition-colors select-none cursor-pointer",
          active
            ? "text-blue-600 dark:text-blue-400 font-bold"
            : "text-blue-950/85 hover:text-blue-600 dark:text-blue-100/85 dark:hover:text-blue-300",
        )}
        aria-sort={active ? (sortDir === "asc" ? "ascending" : "descending") : "none"}
      >
        <span>{label}</span>
        <span
          className={cn(
            "inline-flex h-4 w-4 shrink-0 items-center justify-center rounded transition-all duration-150",
            active
              ? "bg-blue-100 text-blue-600 dark:bg-blue-900/60 dark:text-blue-400"
              : "text-blue-400/40 opacity-0 group-hover:opacity-100 group-hover:text-blue-500",
          )}
        >
          {active && sortDir === "desc" ? (
            <ChevronDown className="h-3.5 w-3.5" />
          ) : (
            <ChevronUp className="h-3.5 w-3.5" />
          )}
        </span>
      </button>
      {!isLast && (
        <span
          className="absolute right-0 top-2.5 bottom-2.5 w-[1.5px] bg-slate-400/80 dark:bg-slate-500 pointer-events-none"
          aria-hidden="true"
        />
      )}
    </th>
  );
}
