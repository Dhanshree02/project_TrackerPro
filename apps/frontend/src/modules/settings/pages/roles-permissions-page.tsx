import { Fragment, useEffect, useMemo, useState } from "react";
import { ChevronRight } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { SearchableSelect } from "@/components/creatable-catalog-select";
import { fetchSidebarModules, type SidebarModule, type SidebarSubModule, type SidebarTab, type SidebarWidget } from "@/lib/api/catalogs";
import { fetchRoles, type ApiRole } from "@/lib/api/users";
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

export function RolesPermissionsPage() {
  const [roles, setRoles] = useState<ApiRole[]>([]);
  const [modules, setModules] = useState<SidebarModule[]>([]);
  const [roleId, setRoleId] = useState("");
  const [accessByRole, setAccessByRole] = useState<Record<string, Record<string, ModuleAccess>>>({});
  const [openIds, setOpenIds] = useState<Record<string, boolean>>({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    let cancelled = false;
    Promise.all([fetchRoles(), fetchSidebarModules()])
      .then(([roleRows, moduleRows]) => {
        if (cancelled) return;
        setRoles(roleRows.filter((role) => role.isActive));
        setModules(moduleRows);
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
      roles.map((role) => ({
        value: role.id,
        label: role.displayName || role.name,
      })),
    [roles],
  );

  const selectedAccess = accessByRole[roleId] ?? {};

  const toggleOpen = (id: string) => {
    setOpenIds((prev) => ({ ...prev, [id]: !prev[id] }));
  };

  const setAccess = (moduleId: string, access: ModuleAccess | null) => {
    if (!roleId) return;
    setAccessByRole((prev) => {
      const current = { ...(prev[roleId] ?? {}) };
      const located = locateRow(rows, moduleId);
      const parentAccess = located?.parent ? current[located.parent.id] : undefined;
      if (located?.parent) {
        if (!parentAccess) return prev;
        if (access === "view-manage" && parentAccess !== "view-manage") return prev;
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
            if (current[id] === "view-manage") current[id] = "view";
          }
        }
      }
      return { ...prev, [roleId]: current };
    });
  };

  return (
    <AppShell title="Roles & Permissions" subtitle="Settings">
      <div className="mx-auto max-w-4xl space-y-6">
        <div className="max-w-sm">
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
              {loading && (
                <tr>
                  <td colSpan={4} className="px-4 py-8 text-center text-muted-foreground">
                    Loading modules…
                  </td>
                </tr>
              )}
              {!loading && modules.length === 0 && (
                <tr>
                  <td colSpan={4} className="px-4 py-8 text-center text-muted-foreground">
                    No modules are in the catalog.
                  </td>
                </tr>
              )}
              <AccessRows
                rows={rows}
                depth={0}
                roleId={roleId}
                parentAccess={null}
                parentName=""
                openIds={openIds}
                selectedAccess={selectedAccess}
                onToggle={toggleOpen}
                onSetAccess={setAccess}
              />
            </tbody>
          </table>
        </div>
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
  onToggle: (id: string) => void;
  onSetAccess: (id: string, access: ModuleAccess | null) => void;
}) {
  return rows.map((row) => {
    const access = selectedAccess[row.id];
    const isChild = depth > 0;
    const viewDisabled = !roleId || (isChild && !parentAccess);
    const manageDisabled = !roleId || (isChild && parentAccess !== "view-manage");
    const hasChildren = row.children.length > 0;
    const open = hasChildren && !!openIds[row.id];
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
          <td className="px-4 py-3 text-center">
            <AccessRadio
              name={`access-${roleId || "none"}-${row.id}`}
              checked={access === "view"}
              disabled={viewDisabled}
              label={`Only view for ${row.name}`}
              title={viewDisabled && parentName ? `Give ${parentName} access first` : undefined}
              onChange={() => onSetAccess(row.id, "view")}
              onClear={() => onSetAccess(row.id, null)}
            />
          </td>
          <td className="px-4 py-3 text-center">
            <AccessRadio
              name={`access-${roleId || "none"}-${row.id}`}
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
            onToggle={onToggle}
            onSetAccess={onSetAccess}
          />
        )}
      </Fragment>
    );
  });
}

function AccessRadio({
  name,
  checked,
  disabled,
  label,
  title,
  onChange,
  onClear,
}: {
  name: string;
  checked: boolean;
  disabled: boolean;
  label: string;
  title?: string;
  onChange: () => void;
  onClear: () => void;
}) {
  return (
    <label
      className={cn("inline-flex items-center justify-center", disabled && "cursor-not-allowed opacity-50")}
      title={title}
    >
      <input
        type="radio"
        name={name}
        checked={checked}
        disabled={disabled}
        aria-label={label}
        title={title}
        onClick={() => {
          if (checked) onClear();
        }}
        onChange={onChange}
        className="size-4 accent-primary"
      />
    </label>
  );
}
