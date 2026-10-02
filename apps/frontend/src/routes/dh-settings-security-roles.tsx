import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useEffect, useMemo, useState } from "react";
import { Search, ChevronDown, Save, RotateCcw, Loader2, Shield, Eye, Edit3 } from "lucide-react";
import { toast } from "sonner";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { cn } from "@/lib/utils";
import type { Role } from "@/lib/mock-data";
import {
  APP_ROLES,
  ROLE_LABELS,
  ROLE_PROJECT_SCOPE,
} from "@/lib/rbac";
import {
  RBAC_WIDGET_CATALOG,
  getBaselinePermissionsForRole,
  useWidgetPermissions,
  saveCustomRolePermissions,
  clearCustomRolePermissions,
} from "@/lib/rbac";
import {
  fetchRbacCatalogTree,
  updateRoleWidgetPermissions,
  resetRoleWidgetBaseline,
  type ModuleCatalogItemDto,
  type WidgetCatalogItemDto,
} from "@/lib/api/rbac";
import {
  fetchUsers,
  fetchRoles,
  updateUser,
  type ApiRole,
} from "@/lib/api/users";
import { usePermissions } from "@/lib/permissions";

export const Route = createFileRoute("/dh-settings-security-roles")({
  head: () => ({
    meta: [
      { title: "Roles & Permissions — Settings — Pulse PMO" },
      { name: "description", content: "Assign user roles and fine-grained 4-tier module/widget permissions." },
    ],
  }),
  component: SecurityRolesPage,
});

interface UserRow {
  id: string;
  name: string;
  email: string;
  currentRole: Role;
  initialRole: Role;
}

const initialUsers: UserRow[] = [
  { id: "r1", name: "Aarav Mehta", email: "aarav.mehta@talakunchi.com", currentRole: "senior_pm", initialRole: "senior_pm" },
  { id: "r2", name: "Riya Kapoor", email: "riya.kapoor@talakunchi.com", currentRole: "engagement_manager", initialRole: "engagement_manager" },
  { id: "r3", name: "Vikram Shah", email: "vikram.shah@talakunchi.com", currentRole: "pm", initialRole: "pm" },
  { id: "r4", name: "Sana Iyer", email: "sana.iyer@talakunchi.com", currentRole: "pm", initialRole: "pm" },
  { id: "r7", name: "Arjun Singh", email: "arjun.singh@talakunchi.com", currentRole: "employee", initialRole: "employee" },
  { id: "r8", name: "Meera Joshi", email: "meera.joshi@talakunchi.com", currentRole: "employee", initialRole: "employee" },
  { id: "r9", name: "Dev Patel", email: "dev.patel@talakunchi.com", currentRole: "employee", initialRole: "employee" },
  { id: "r10", name: "Kavya Nair", email: "kavya.nair@talakunchi.com", currentRole: "hr", initialRole: "hr" },
  { id: "r11", name: "Rahul Gupta", email: "rahul.gupta@talakunchi.com", currentRole: "pmo", initialRole: "pmo" },
  { id: "r12", name: "Neha Sharma", email: "neha.sharma@talakunchi.com", currentRole: "sales", initialRole: "sales" },
  { id: "r13", name: "Ananya Desai", email: "ananya.desai@talakunchi.com", currentRole: "accounts", initialRole: "accounts" },
  { id: "r14", name: "Karan Verma", email: "karan.verma@talakunchi.com", currentRole: "employee", initialRole: "employee" },
  { id: "r15", name: "Pooja Hegde", email: "pooja.hegde@talakunchi.com", currentRole: "employee", initialRole: "employee" },
  { id: "r16", name: "Aditya Roy", email: "aditya.roy@talakunchi.com", currentRole: "management", initialRole: "management" },
  { id: "r17", name: "Dhanshree", email: "dhanshree@talakunchi.com", currentRole: "dhanshree", initialRole: "dhanshree" },
];

const SCOPE_LABEL: Record<string, string> = {
  involved: "Only projects the person is on",
  pm: "Only projects they manage",
  assigned: "Assigned customers / projects",
  department: "Own department only",
  all: "All company projects",
};

function SecurityRolesPage() {
  const { can, isDhanshree } = useRoleContext();
  const { hasAny } = usePermissions();
  const [activeTab, setActiveTab] = useState<"modules" | "users">("modules");

  const allowed = isDhanshree || (can ? can("settings.manage_roles") : false) || hasAny("settings.manage_roles", "roles:manage", "settings.view");
  if (!allowed) return <Navigate to="/" />;

  return (
    <AppShell title="Roles & Permissions" subtitle="Fine-grained Role → Module → Submodule → Widget Access Control">
      <div className="mb-5 flex items-center border-b border-border">
        <button
          onClick={() => setActiveTab("modules")}
          className={cn(
            "relative px-4 py-2.5 text-sm font-medium transition-colors",
            activeTab === "modules" ? "text-primary" : "text-muted-foreground hover:text-foreground",
          )}
        >
          Module & Widget Access
          {activeTab === "modules" && (
            <span className="absolute inset-x-0 -bottom-px h-0.5 rounded-full bg-primary" />
          )}
        </button>
        <button
          onClick={() => setActiveTab("users")}
          className={cn(
            "relative px-4 py-2.5 text-sm font-medium transition-colors",
            activeTab === "users" ? "text-primary" : "text-muted-foreground hover:text-foreground",
          )}
        >
          User Role Assignment
          {activeTab === "users" && (
            <span className="absolute inset-x-0 -bottom-px h-0.5 rounded-full bg-primary" />
          )}
        </button>
      </div>

      {activeTab === "modules" ? <ModuleAccessTab /> : <UsersTab />}
    </AppShell>
  );
}

function UsersTab() {
  const [users, setUsers] = useState<UserRow[]>(initialUsers);
  const [q, setQ] = useState("");
  const [roleFilter, setRoleFilter] = useState("all");
  const [isSaving, setIsSaving] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    fetchUsers()
      .then((apiUsers) => {
        if (cancelled) return;
        if (apiUsers && apiUsers.length > 0) {
          const rows: UserRow[] = apiUsers.map((u) => {
            const r = (u.role as Role) || "employee";
            return {
              id: u.id,
              name: u.name,
              email: u.email,
              currentRole: r,
              initialRole: r,
            };
          });
          setUsers(rows);
        }
      })
      .catch(() => {})
      .finally(() => {
        if (!cancelled) setIsLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  const filtered = useMemo(() => {
    let list = users;
    if (roleFilter !== "all") list = list.filter((u) => u.currentRole === roleFilter);
    if (q.trim()) {
      const term = q.toLowerCase();
      list = list.filter((u) => u.name.toLowerCase().includes(term) || u.email.toLowerCase().includes(term));
    }
    return list;
  }, [users, q, roleFilter]);

  const changeRole = (id: string, newRole: Role) => {
    setUsers((prev) => prev.map((u) => (u.id === id ? { ...u, currentRole: newRole } : u)));
  };

  const handleSave = async () => {
    const changed = users.filter((u) => u.currentRole !== u.initialRole);
    if (changed.length === 0) {
      toast.info("No changes to save.");
      return;
    }
    setIsSaving(true);
    try {
      await Promise.all(
        changed.map((u) => updateUser(u.id, { role: u.currentRole })),
      );
      setUsers((prev) => prev.map((u) => ({ ...u, initialRole: u.currentRole })));
      toast.success("Roles updated", { description: `${changed.length} user role assignment(s) saved to database.` });
    } catch {
      toast.error("Failed to update user roles.");
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <>
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <div className="relative max-w-xs flex-1">
          <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Search user name or email…"
            className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
        </div>
        <select
          value={roleFilter}
          onChange={(e) => setRoleFilter(e.target.value)}
          className="h-9 rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
        >
          <option value="all">All Roles</option>
          {APP_ROLES.map((r) => (
            <option key={r} value={r}>
              {ROLE_LABELS[r] || r}
            </option>
          ))}
        </select>
        <button
          onClick={handleSave}
          disabled={isSaving}
          className="ml-auto inline-flex items-center gap-1.5 rounded-md bg-primary px-4 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90 transition-colors disabled:opacity-50"
        >
          {isSaving ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : <Save className="h-3.5 w-3.5" />}
          Save Changes
        </button>
      </div>

      <div className="overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
        <table className="w-full text-sm">
          <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr>
              <th className="px-4 py-3 font-medium">Name</th>
              <th className="px-4 py-3 font-medium">Email</th>
              <th className="px-4 py-3 font-medium">Current Role</th>
              <th className="px-4 py-3 font-medium">Change Role</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {isLoading ? (
              <tr>
                <td colSpan={4} className="py-8 text-center text-muted-foreground text-xs">
                  Loading users...
                </td>
              </tr>
            ) : filtered.length === 0 ? (
              <tr>
                <td colSpan={4} className="py-8 text-center text-muted-foreground text-xs">
                  No users found.
                </td>
              </tr>
            ) : (
              filtered.map((u) => (
                <tr key={u.id} className="hover:bg-accent/30 transition-colors">
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-2.5">
                      <span className="flex h-8 w-8 items-center justify-center rounded-full bg-primary/10 text-xs font-semibold text-primary">
                        {u.name.split(" ").map((w) => w[0]).join("").slice(0, 2)}
                      </span>
                      <span className="font-medium">{u.name}</span>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-muted-foreground">{u.email}</td>
                  <td className="px-4 py-3">
                    <span className="inline-flex items-center rounded-full bg-muted px-2.5 py-0.5 text-[11px] font-medium text-muted-foreground">
                      {ROLE_LABELS[u.currentRole] || u.currentRole}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <select
                      value={u.currentRole}
                      onChange={(e) => changeRole(u.id, e.target.value as Role)}
                      className="h-8 rounded-md border border-input bg-card px-2 text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring"
                    >
                      {APP_ROLES.map((r) => (
                        <option key={r} value={r}>
                          {ROLE_LABELS[r] || r}
                        </option>
                      ))}
                    </select>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </>
  );
}

interface EditablePermission {
  widgetId: string;
  widgetKey: string;
  canView: number;
  canManage: number;
  hasManageAction: boolean;
}

function ModuleAccessTab() {
  const { refresh: refreshContextPerms } = useWidgetPermissions();
  const [backendRoles, setBackendRoles] = useState<ApiRole[]>([]);
  const [selectedRole, setSelectedRole] = useState<string>("Testing-Manager");
  const [catalogTree, setCatalogTree] = useState<ModuleCatalogItemDto[]>([]);
  const [permissionsState, setPermissionsState] = useState<Record<string, EditablePermission>>({});
  const [searchQuery, setSearchQuery] = useState("");
  const [openModules, setOpenModules] = useState<Record<string, boolean>>({
    dashboard: true,
    action_center: true,
    projects: true,
    reports: false,
    resources: false,
    customers: false,
    repository: false,
    my_team: false,
    settings: false,
  });
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);

  // Load all available backend roles
  useEffect(() => {
    fetchRoles()
      .then((roles) => {
        if (roles && roles.length > 0) {
          setBackendRoles(roles);
        }
      })
      .catch(() => {});
  }, []);

  const selectedRoleId = useMemo(() => {
    const matched = backendRoles.find(
      (r) => r.name.toLowerCase() === selectedRole.toLowerCase()
    );
    return matched?.id;
  }, [backendRoles, selectedRole]);

  // Load catalog tree from API (with fallback)
  useEffect(() => {
    let cancelled = false;
    setIsLoading(true);

    fetchRbacCatalogTree(selectedRoleId)
      .then((tree) => {
        if (cancelled) return;
        const safeTree = Array.isArray(tree) ? tree : [];
        setCatalogTree(safeTree);

        // Build flat permission map
        const map: Record<string, EditablePermission> = {};
        const collectWidgets = (widgets?: WidgetCatalogItemDto[]) => {
          if (!widgets) return;
          for (const w of widgets) {
            map[w.widgetKey] = {
              widgetId: w.id,
              widgetKey: w.widgetKey,
              canView: w.canView,
              canManage: w.canManage,
              hasManageAction: w.hasManageAction,
            };
          }
        };

        for (const mod of safeTree) {
          collectWidgets(mod.directWidgets);
          for (const sub of mod.submodules || []) {
            collectWidgets(sub.widgets);
            for (const child of sub.childSubmodules || []) {
              collectWidgets(child.widgets);
            }
          }
        }

        setPermissionsState(map);
      })
      .catch(() => {
        // Fallback using excel-baseline
        const baseline = getBaselinePermissionsForRole(selectedRole);
        const map: Record<string, EditablePermission> = {};
        for (const w of RBAC_WIDGET_CATALOG) {
          const b = baseline[w.key] ?? { canView: 0, canManage: 0 };
          map[w.key] = {
            widgetId: w.key,
            widgetKey: w.key,
            canView: b.canView,
            canManage: b.canManage,
            hasManageAction: w.hasManageAction,
          };
        }
        setPermissionsState(map);
      })
      .finally(() => {
        if (!cancelled) setIsLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [selectedRoleId, selectedRole]);

  const handleToggleView = (key: string) => {
    setPermissionsState((prev) => {
      const cur = prev[key];
      if (!cur) return prev;
      const nextView = cur.canView === 1 ? 0 : 1;
      // If turning off View, automatically turn off Manage
      const nextManage = nextView === 0 ? 0 : cur.canManage;
      return {
        ...prev,
        [key]: {
          ...cur,
          canView: nextView,
          canManage: nextManage,
        },
      };
    });
  };

  const handleToggleManage = (key: string) => {
    setPermissionsState((prev) => {
      const cur = prev[key];
      if (!cur || !cur.hasManageAction) return prev;
      const nextManage = cur.canManage === 1 ? 0 : 1;
      // If turning on Manage, automatically turn on View
      const nextView = nextManage === 1 ? 1 : cur.canView;
      return {
        ...prev,
        [key]: {
          ...cur,
          canView: nextView,
          canManage: nextManage,
        },
      };
    });
  };

  const handleResetBaseline = async () => {
    clearCustomRolePermissions(selectedRole);

    if (!selectedRoleId) {
      // Offline fallback
      const baseline = getBaselinePermissionsForRole(selectedRole);
      setPermissionsState((prev) => {
        const next = { ...prev };
        for (const [key, val] of Object.entries(baseline)) {
          if (next[key]) {
            next[key].canView = val.canView;
            next[key].canManage = val.canManage;
          }
        }
        return next;
      });
      toast.success("Restored to Excel baseline (offline)");
      return;
    }

    try {
      await resetRoleWidgetBaseline(selectedRoleId);
      const tree = await fetchRbacCatalogTree(selectedRoleId);
      const safeTree = Array.isArray(tree) ? tree : [];
      setCatalogTree(safeTree);
      const map: Record<string, EditablePermission> = {};
      const collectWidgets = (widgets?: WidgetCatalogItemDto[]) => {
        if (!widgets) return;
        for (const w of widgets) {
          map[w.widgetKey] = {
            widgetId: w.id,
            widgetKey: w.widgetKey,
            canView: w.canView,
            canManage: w.canManage,
            hasManageAction: w.hasManageAction,
          };
        }
      };
      for (const mod of safeTree) {
        collectWidgets(mod.directWidgets);
        for (const sub of mod.submodules || []) {
          collectWidgets(sub.widgets);
          for (const child of sub.childSubmodules || []) {
            collectWidgets(child.widgets);
          }
        }
      }
      setPermissionsState(map);
      await refreshContextPerms();
      toast.success("Reset to factory baseline successfully.");
    } catch {
      toast.error("Failed to reset baseline.");
    }
  };

  const handleSaveChanges = async () => {
    // 1. Save locally to instant custom cache so switched persona reflects changes immediately
    const permsMapToSave: Record<string, { canView: number; canManage: number }> = {};
    for (const [key, val] of Object.entries(permissionsState)) {
      permsMapToSave[key] = { canView: val.canView, canManage: val.canManage };
    }
    saveCustomRolePermissions(selectedRole, permsMapToSave);

    if (!selectedRoleId) {
      toast.success("Permissions updated locally for role: " + selectedRole);
      return;
    }

    setIsSaving(true);
    try {
      const payload = Object.values(permissionsState).map((p) => ({
        widgetId: p.widgetId,
        canView: p.canView,
        canManage: p.canManage,
      }));
      await updateRoleWidgetPermissions(selectedRoleId, payload);
      await refreshContextPerms();
      toast.success("Permissions updated successfully.", {
        description: `Changes for ${selectedRole} saved to database.`,
      });
    } catch {
      toast.error("Failed to save permissions to server.");
    } finally {
      setIsSaving(false);
    }
  };

  // Grouped fallback catalog if catalogTree is empty
  const displayModules = useMemo(() => {
    if (Array.isArray(catalogTree) && catalogTree.length > 0) return catalogTree;

    // Convert RBAC_WIDGET_CATALOG to ModuleCatalogItemDto structure
    const modMap = new Map<string, ModuleCatalogItemDto>();
    for (const w of RBAC_WIDGET_CATALOG) {
      if (!modMap.has(w.moduleCode)) {
        modMap.set(w.moduleCode, {
          id: w.moduleCode,
          code: w.moduleCode,
          name: w.moduleName,
          icon: null,
          sortOrder: 1,
          submodules: [],
          directWidgets: [],
        });
      }
      const mod = modMap.get(w.moduleCode)!;
      const widgetDto: WidgetCatalogItemDto = {
        id: w.key,
        code: w.code,
        name: w.name,
        widgetKey: w.key,
        widgetType: w.widgetType,
        hasManageAction: w.hasManageAction,
        sortOrder: w.sortOrder,
        canView: permissionsState[w.key]?.canView ?? 0,
        canManage: permissionsState[w.key]?.canManage ?? 0,
      };

      if (!w.submoduleCode) {
        mod.directWidgets.push(widgetDto);
      } else {
        let sub = mod.submodules.find((s) => s.code === w.submoduleCode);
        if (!sub) {
          sub = {
            id: w.submoduleCode,
            code: w.submoduleCode,
            name: w.submoduleName || w.submoduleCode,
            routePrefix: null,
            sortOrder: 1,
            widgets: [],
            childSubmodules: [],
          };
          mod.submodules.push(sub);
        }
        sub.widgets.push(widgetDto);
      }
    }
    return Array.from(modMap.values());
  }, [catalogTree, permissionsState]);

  const viewCount = Object.values(permissionsState).filter((p) => p.canView === 1).length;
  const manageCount = Object.values(permissionsState).filter((p) => p.canManage === 1).length;

  return (
    <>
      <div className="mb-4 flex flex-wrap items-center justify-between gap-3 bg-muted/20 p-3 rounded-xl border border-border">
        <div className="flex flex-wrap items-center gap-3">
          <div className="flex items-center gap-2">
            <Shield className="h-4 w-4 text-primary" />
            <span className="text-xs font-bold text-foreground">Select Role:</span>
          </div>
          <select
            value={selectedRole}
            onChange={(e) => setSelectedRole(e.target.value)}
            className="h-9 rounded-md border border-input bg-card px-3 text-sm font-semibold outline-none focus-visible:ring-2 focus-visible:ring-ring shadow-2xs"
          >
            {backendRoles.length > 0
              ? backendRoles.map((r) => (
                  <option key={r.id} value={r.name}>
                    {r.name}
                  </option>
                ))
              : APP_ROLES.map((r) => (
                  <option key={r} value={r}>
                    {ROLE_LABELS[r] || r}
                  </option>
                ))}
          </select>

          <span className="rounded-full border border-border bg-muted/60 px-2.5 py-1 text-[11px] text-muted-foreground font-mono">
            Data scope: {SCOPE_LABEL[ROLE_PROJECT_SCOPE[selectedRole as Role]] || "Involved"}
          </span>

          <div className="flex items-center gap-2 text-xs">
            <span className="inline-flex items-center gap-1 text-emerald-600 font-medium">
              <Eye className="h-3.5 w-3.5" /> {viewCount} View
            </span>
            <span className="text-muted-foreground">•</span>
            <span className="inline-flex items-center gap-1 text-primary font-medium">
              <Edit3 className="h-3.5 w-3.5" /> {manageCount} Manage
            </span>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <div className="relative w-48 sm:w-64">
            <Search className="pointer-events-none absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
            <input
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search widget..."
              className="h-8 w-full rounded-md border border-input bg-card pl-8 pr-3 text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring"
            />
          </div>

          <button
            onClick={handleResetBaseline}
            className="inline-flex items-center gap-1.5 rounded-md border border-border bg-card px-3 py-1.5 text-xs font-medium hover:bg-accent transition-colors"
            title="Reset role to baseline from Excel"
          >
            <RotateCcw className="h-3.5 w-3.5 text-muted-foreground" />
            Reset Baseline
          </button>

          <button
            onClick={handleSaveChanges}
            disabled={isSaving || isLoading}
            className="inline-flex items-center gap-1.5 rounded-md bg-primary px-3.5 py-1.5 text-xs font-semibold text-primary-foreground hover:bg-primary/90 transition-colors shadow-2xs disabled:opacity-50"
          >
            {isSaving ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : <Save className="h-3.5 w-3.5" />}
            Save Permissions
          </button>
        </div>
      </div>

      {isLoading ? (
        <div className="flex h-64 items-center justify-center rounded-xl border border-border bg-card text-xs text-muted-foreground">
          <Loader2 className="mr-2 h-4 w-4 animate-spin text-primary" />
          Loading 4-tier RBAC matrix...
        </div>
      ) : (
        <div className="space-y-3">
          {displayModules.map((mod) => {
            const open = openModules[mod.code] ?? true;

            // Collect all widgets in this module for count
            const allModWidgets: WidgetCatalogItemDto[] = [
              ...(mod.directWidgets || []),
              ...(mod.submodules || []).flatMap((s) => [
                ...(s.widgets || []),
                ...(s.childSubmodules || []).flatMap((cs) => cs.widgets || []),
              ]),
            ];

            const filteredWidgets = searchQuery.trim()
              ? allModWidgets.filter((w) =>
                  w.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                  w.widgetKey.toLowerCase().includes(searchQuery.toLowerCase())
                )
              : allModWidgets;

            if (searchQuery.trim() && filteredWidgets.length === 0) {
              return null;
            }

            const modViewCount = allModWidgets.filter(
              (w) => permissionsState[w.widgetKey]?.canView === 1
            ).length;
            const modManageCount = allModWidgets.filter(
              (w) => permissionsState[w.widgetKey]?.canManage === 1
            ).length;

            return (
              <div
                key={mod.code}
                className="overflow-hidden rounded-xl border border-border bg-card shadow-xs"
              >
                <button
                  onClick={() =>
                    setOpenModules((prev) => ({ ...prev, [mod.code]: !open }))
                  }
                  className="flex w-full items-center justify-between px-4 py-3 bg-muted/30 hover:bg-muted/50 transition-colors text-left"
                >
                  <div className="flex items-center gap-2.5">
                    <ChevronDown
                      className={cn(
                        "h-4 w-4 text-muted-foreground transition-transform",
                        open && "rotate-180"
                      )}
                    />
                    <span className="text-sm font-bold text-foreground">
                      {mod.name}
                    </span>
                    <span className="text-[10px] text-muted-foreground font-mono">
                      ({mod.code})
                    </span>
                  </div>

                  <div className="flex items-center gap-3 text-xs">
                    <span className="text-muted-foreground">
                      <span className="font-semibold text-emerald-600">{modViewCount}</span>/{allModWidgets.length} View
                    </span>
                    <span className="text-muted-foreground">
                      <span className="font-semibold text-primary">{modManageCount}</span>/{allModWidgets.length} Manage
                    </span>
                  </div>
                </button>

                {open && (
                  <div className="divide-y divide-border/60">
                    {/* Header Columns */}
                    <div className="grid grid-cols-12 gap-2 px-4 py-2 bg-muted/20 text-[10px] font-bold uppercase tracking-wider text-muted-foreground">
                      <div className="col-span-7">Widget / Submodule / Action</div>
                      <div className="col-span-2 text-center">Type</div>
                      <div className="col-span-3 text-center grid grid-cols-2">
                        <span>Can View</span>
                        <span>Can Manage</span>
                      </div>
                    </div>

                    {/* Direct widgets */}
                    {(mod.directWidgets || []).map((w) => (
                      <WidgetPermissionRow
                        key={w.widgetKey}
                        widget={w}
                        permission={permissionsState[w.widgetKey]}
                        onToggleView={() => handleToggleView(w.widgetKey)}
                        onToggleManage={() => handleToggleManage(w.widgetKey)}
                      />
                    ))}

                    {/* Submodules */}
                    {(mod.submodules || []).map((sub) => (
                      <div key={sub.code} className="bg-background/50">
                        <div className="px-4 py-1.5 bg-muted/15 text-[11px] font-semibold text-muted-foreground flex items-center justify-between">
                          <span>📂 {sub.name}</span>
                          <span className="text-[10px] font-mono text-muted-foreground/70">
                            {sub.code}
                          </span>
                        </div>

                        {(sub.widgets || []).map((w) => (
                          <WidgetPermissionRow
                            key={w.widgetKey}
                            widget={w}
                            permission={permissionsState[w.widgetKey]}
                            onToggleView={() => handleToggleView(w.widgetKey)}
                            onToggleManage={() => handleToggleManage(w.widgetKey)}
                            indent
                          />
                        ))}

                        {/* Child submodules */}
                        {(sub.childSubmodules || []).map((child) => (
                          <div key={child.code}>
                            <div className="pl-8 pr-4 py-1 bg-muted/10 text-[10px] font-semibold text-muted-foreground flex items-center justify-between">
                              <span>↳ {child.name}</span>
                              <span className="text-[9px] font-mono text-muted-foreground/60">
                                {child.code}
                              </span>
                            </div>
                            {(child.widgets || []).map((w) => (
                              <WidgetPermissionRow
                                key={w.widgetKey}
                                widget={w}
                                permission={permissionsState[w.widgetKey]}
                                onToggleView={() => handleToggleView(w.widgetKey)}
                                onToggleManage={() => handleToggleManage(w.widgetKey)}
                                doubleIndent
                              />
                            ))}
                          </div>
                        ))}
                      </div>
                    ))}
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
    </>
  );
}

function WidgetPermissionRow({
  widget,
  permission,
  onToggleView,
  onToggleManage,
  indent = false,
  doubleIndent = false,
}: {
  widget: WidgetCatalogItemDto;
  permission?: EditablePermission;
  onToggleView: () => void;
  onToggleManage: () => void;
  indent?: boolean;
  doubleIndent?: boolean;
}) {
  const canView = permission?.canView === 1;
  const canManage = permission?.canManage === 1;

  const typeBadgeColors: Record<string, string> = {
    widget: "bg-blue-500/10 text-blue-600 border-blue-500/20",
    action: "bg-purple-500/10 text-purple-600 border-purple-500/20",
    tab: "bg-amber-500/10 text-amber-600 border-amber-500/20",
    kpi_card: "bg-emerald-500/10 text-emerald-600 border-emerald-500/20",
  };

  return (
    <div
      className={cn(
        "grid grid-cols-12 gap-2 px-4 py-2.5 items-center hover:bg-accent/30 transition-colors text-xs border-b border-border/40",
        indent && "pl-8",
        doubleIndent && "pl-12",
      )}
    >
      <div className="col-span-7 flex flex-col min-w-0">
        <span className="font-medium text-foreground truncate">{widget.name}</span>
        <span className="text-[10px] text-muted-foreground font-mono truncate">
          {widget.widgetKey}
        </span>
      </div>

      <div className="col-span-2 text-center">
        <span
          className={cn(
            "inline-flex items-center px-2 py-0.5 rounded-full text-[9px] font-semibold uppercase tracking-wider border",
            typeBadgeColors[widget.widgetType] || "bg-muted text-muted-foreground",
          )}
        >
          {widget.widgetType}
        </span>
      </div>

      <div className="col-span-3 grid grid-cols-2 text-center items-center">
        <label className="flex items-center justify-center cursor-pointer">
          <input
            type="checkbox"
            checked={canView}
            onChange={onToggleView}
            className="h-4 w-4 rounded border-border accent-emerald-600 cursor-pointer"
          />
        </label>

        <label className="flex items-center justify-center cursor-pointer">
          {widget.hasManageAction ? (
            <input
              type="checkbox"
              checked={canManage}
              onChange={onToggleManage}
              disabled={!canView}
              className={cn(
                "h-4 w-4 rounded border-border accent-primary cursor-pointer",
                !canView && "opacity-30 cursor-not-allowed"
              )}
            />
          ) : (
            <span className="text-[10px] text-muted-foreground italic">—</span>
          )}
        </label>
      </div>
    </div>
  );
}
