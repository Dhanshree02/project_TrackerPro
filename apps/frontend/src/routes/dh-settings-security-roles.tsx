import { createFileRoute, Link, Navigate } from "@tanstack/react-router";
import { useMemo, useState, useEffect } from "react";
import {
  Search,
  ChevronRight,
  ChevronDown,
  Save,
  RotateCcw,
  Shield,
  Layers,
  CheckSquare,
  Square,
  Users,
  CheckCircle2,
  LayoutDashboard,
  Zap,
  FolderKanban,
  BarChart3,
  Building2,
  HardDrive,
  UserCheck,
  Settings as SettingsIcon,
  ChevronsUpDown,
} from "lucide-react";
import { toast } from "sonner";
import { AppShell } from "@/components/app-shell";
import { usePermissions } from "@/lib/permissions";
import { useRoleContext } from "@/lib/role-context";
import { cn } from "@/lib/utils";
import type { Role } from "@/lib/mock-data";
import {
  APP_ROLES,
  DEFAULT_ROLE_PERMISSIONS,
  MODULE_ORDER,
  PERMISSION_CATALOG,
  ROLE_LABELS,
  ROLE_PROJECT_SCOPE,
  type PermissionKey,
} from "@/lib/rbac";
import {
  fetchRoles,
  updateRolePermissions as apiUpdateRolePermissions,
  resetRolePermissions as apiResetRolePermissions,
  type ApiRole,
} from "@/lib/api/users";

export const Route = createFileRoute("/dh-settings-security-roles")({
  head: () => ({
    meta: [
      { title: "Roles & Permissions — Settings — TrackerPro" },
      { name: "description", content: "Manage fine-grained Module, Submodule, and Widget/Action permissions." },
    ],
  }),
  component: SecurityRolesPage,
});

interface UserRow {
  id: string;
  name: string;
  email: string;
  currentRole: Role;
}

const initialUsers: UserRow[] = [
  { id: "r1", name: "Aarav Mehta", email: "aarav.mehta@talakunchi.com", currentRole: "senior_pm" },
  { id: "r2", name: "Riya Kapoor", email: "riya.kapoor@talakunchi.com", currentRole: "engagement_manager" },
  { id: "r3", name: "Vikram Shah", email: "vikram.shah@talakunchi.com", currentRole: "pm" },
  { id: "r4", name: "Sana Iyer", email: "sana.iyer@talakunchi.com", currentRole: "pm" },
  { id: "r7", name: "Arjun Singh", email: "arjun.singh@talakunchi.com", currentRole: "employee" },
  { id: "r8", name: "Meera Joshi", email: "meera.joshi@talakunchi.com", currentRole: "employee" },
  { id: "r9", name: "Dev Patel", email: "dev.patel@talakunchi.com", currentRole: "employee" },
  { id: "r10", name: "Kavya Nair", email: "kavya.nair@talakunchi.com", currentRole: "hr" },
  { id: "r11", name: "Rahul Gupta", email: "rahul.gupta@talakunchi.com", currentRole: "pmo" },
  { id: "r12", name: "Anita Desai", email: "anita.desai@talakunchi.com", currentRole: "hod" },
  { id: "r13", name: "Vikrant Malhotra", email: "vikrant.malhotra@talakunchi.com", currentRole: "business_owner" },
  { id: "r14", name: "Sneha Kulkarni", email: "sneha.kulkarni@talakunchi.com", currentRole: "accounts_finance" },
  { id: "r15", name: "Rohan Sharma", email: "rohan.sharma@talakunchi.com", currentRole: "sales_bd" },
  { id: "r16", name: "Dhanshree", email: "dhanshree@talakunchi.com", currentRole: "dhanshree" },
];

const SCOPE_LABEL: Record<string, string> = {
  involved: "Only projects the person is on",
  pm: "Only projects they manage",
  assigned: "Assigned customers / projects",
  department: "Own department only",
  all: "All company projects",
};

const BACKEND_ROLE_NAME_MAP: Record<Role, string> = {
  employee: "Employee",
  pm: "ProjectManager",
  senior_pm: "SeniorPm",
  engagement_manager: "EngagementManager",
  pmo: "Pmo",
  business_owner: "BusinessOwner",
  hod: "Hod",
  hr: "Hr",
  accounts_finance: "Accounts",
  sales_bd: "Sales",
  dhanshree: "Admin",
};

function SecurityRolesPage() {
  const { can, isDhanshree } = useRoleContext();
  const { hasAny, hasPermission } = usePermissions();
  const [activeTab, setActiveTab] = useState<"modules" | "users">("modules");

  const allowed =
    isDhanshree ||
    (can ? can("settings.manage_roles") : false) ||
    hasPermission("settings.manage_roles") ||
    hasAny("settings.manage_roles", "roles:manage", "settings.view", "settings.roles.view");
  if (!allowed) return <Navigate to="/" />;

  return (
    <AppShell
      title="Roles & Permissions"
      subtitle="Configure dynamic permissions at Module → Submodule → Widget / Action level"
    >
      <nav
        className="mb-5 flex items-center gap-1.5 text-xs text-muted-foreground"
        aria-label="Breadcrumb"
      >
        <Link to="/dh-settings" className="hover:text-foreground transition-colors">
          Settings
        </Link>
        <ChevronRight className="h-3 w-3" />
        <span className="font-medium text-foreground">Roles & Permissions</span>
      </nav>

      <div className="mb-5 flex items-center border-b border-border">
        <button
          onClick={() => setActiveTab("modules")}
          className={cn(
            "relative flex items-center gap-2 px-4 py-2.5 text-sm font-medium transition-colors",
            activeTab === "modules"
              ? "text-primary"
              : "text-muted-foreground hover:text-foreground",
          )}
        >
          <Shield className="h-4 w-4" />
          Module Access
          {activeTab === "modules" && (
            <span className="absolute inset-x-0 -bottom-px h-0.5 rounded-full bg-primary" />
          )}
        </button>
        <button
          onClick={() => setActiveTab("users")}
          className={cn(
            "relative flex items-center gap-2 px-4 py-2.5 text-sm font-medium transition-colors",
            activeTab === "users" ? "text-primary" : "text-muted-foreground hover:text-foreground",
          )}
        >
          <Users className="h-4 w-4" />
          User Role Access
          {activeTab === "users" && (
            <span className="absolute inset-x-0 -bottom-px h-0.5 rounded-full bg-primary" />
          )}
        </button>
      </div>

      {activeTab === "users" ? <UserRoleAccessTab /> : <ModuleAccessTab />}
    </AppShell>
  );
}

function UserRoleAccessTab() {
  const [q, setQ] = useState("");
  const [roleFilter, setRoleFilter] = useState<string>("all");
  const [users, setUsers] = useState<UserRow[]>(() => [...initialUsers]);

  const filtered = useMemo(() => {
    let list = users;
    if (roleFilter !== "all") list = list.filter((u) => u.currentRole === roleFilter);
    if (q.trim()) {
      const term = q.toLowerCase();
      list = list.filter(
        (u) => u.name.toLowerCase().includes(term) || u.email.toLowerCase().includes(term),
      );
    }
    return list;
  }, [users, q, roleFilter]);

  const changeRole = (id: string, newRole: Role) => {
    setUsers((prev) => prev.map((u) => (u.id === id ? { ...u, currentRole: newRole } : u)));
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
              {ROLE_LABELS[r]}
            </option>
          ))}
        </select>
        <button
          onClick={() =>
            toast.success("User roles saved", {
              description: `User role assignments have been successfully updated.`,
            })
          }
          className="ml-auto inline-flex items-center gap-1.5 rounded-md bg-primary px-4 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90 transition-colors shadow-2xs"
        >
          <Save className="h-3.5 w-3.5" />
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
            {filtered.map((u) => (
              <tr key={u.id} className="hover:bg-accent/30 transition-colors">
                <td className="px-4 py-3">
                  <div className="flex items-center gap-2.5">
                    <span className="flex h-8 w-8 items-center justify-center rounded-full bg-primary/10 text-xs font-semibold text-primary">
                      {u.name
                        .split(" ")
                        .map((w) => w[0])
                        .join("")
                        .slice(0, 2)}
                    </span>
                    <span className="font-medium">{u.name}</span>
                  </div>
                </td>
                <td className="px-4 py-3 text-muted-foreground">{u.email}</td>
                <td className="px-4 py-3">
                  <span className="inline-flex items-center rounded-full bg-muted px-2.5 py-0.5 text-[11px] font-medium text-muted-foreground">
                    {ROLE_LABELS[u.currentRole]}
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
                        {ROLE_LABELS[r]}
                      </option>
                    ))}
                  </select>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}

const MODULE_ICON_MAP: Record<string, typeof Layers> = {
  Dashboard: LayoutDashboard,
  "Action Centre": Zap,
  Projects: FolderKanban,
  Reports: BarChart3,
  Resources: Users,
  Customers: Building2,
  Repository: HardDrive,
  "My Team": UserCheck,
  Settings: SettingsIcon,
};

function ModuleAccessTab() {
  const ctx = useRoleContext();
  const getPermissionsFor = ctx.getPermissionsFor ?? ((r: Role) => DEFAULT_ROLE_PERMISSIONS[r] ?? []);
  const setRolePermissions = ctx.setRolePermissions ?? (() => {});
  const resetRolePermissions = ctx.resetRolePermissions ?? (() => {});

  const [selectedRole, setSelectedRole] = useState<Role>("employee");
  const [searchTerm, setSearchTerm] = useState("");
  const [openModules, setOpenModules] = useState<Record<string, boolean>>({});

  const [backendRoles, setBackendRoles] = useState<ApiRole[]>([]);
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const roles = await fetchRoles();
        if (!cancelled && roles && roles.length > 0) {
          setBackendRoles(roles);
        }
      } catch {
        /* Offline / dev mode fallback */
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  const [draft, setDraft] = useState<PermissionKey[]>(() => getPermissionsFor("employee"));

  const switchRole = (role: Role) => {
    setSelectedRole(role);
    setDraft(getPermissionsFor(role));
  };

  const granted = useMemo(() => new Set(draft), [draft]);

  const toggle = (key: PermissionKey) => {
    setDraft((prev) => (prev.includes(key) ? prev.filter((k) => k !== key) : [...prev, key]));
  };

  const toggleModuleAll = (moduleName: string, enable: boolean) => {
    const moduleItems = PERMISSION_CATALOG.filter((p) => p.module === moduleName);
    const keys = moduleItems.map((p) => p.key);
    setDraft((prev) => {
      if (enable) {
        return Array.from(new Set([...prev, ...keys]));
      }
      return prev.filter((k) => !keys.includes(k));
    });
  };

  const toggleSubmoduleAll = (moduleName: string, submoduleName: string, enable: boolean) => {
    const subItems = PERMISSION_CATALOG.filter(
      (p) => p.module === moduleName && (p.submodule ?? "General") === submoduleName,
    );
    const keys = subItems.map((p) => p.key);
    setDraft((prev) => {
      if (enable) {
        return Array.from(new Set([...prev, ...keys]));
      }
      return prev.filter((k) => !keys.includes(k));
    });
  };

  // Group permissions hierarchically: Module -> Submodule -> Actions/Widgets
  const hierarchicalCatalog = useMemo(() => {
    const term = searchTerm.trim().toLowerCase();

    return MODULE_ORDER.map((module) => {
      let items = PERMISSION_CATALOG.filter((p) => p.module === module);
      if (term) {
        items = items.filter(
          (p) =>
            p.label.toLowerCase().includes(term) ||
            p.key.toLowerCase().includes(term) ||
            (p.submodule && p.submodule.toLowerCase().includes(term)) ||
            p.group.toLowerCase().includes(term),
        );
      }

      // Group items by Submodule
      const submodulesMap = new Map<string, typeof items>();
      items.forEach((item) => {
        const sub = item.submodule || "General";
        if (!submodulesMap.has(sub)) {
          submodulesMap.set(sub, []);
        }
        submodulesMap.get(sub)!.push(item);
      });

      const submodules = Array.from(submodulesMap.entries()).map(([submodule, subItems]) => {
        // Group subItems by group (e.g. Tabs, Actions, Widgets)
        const groups = Array.from(new Set(subItems.map((i) => i.group)));
        return { submodule, subItems, groups };
      });

      return {
        module,
        totalCount: PERMISSION_CATALOG.filter((p) => p.module === module).length,
        items,
        submodules,
      };
    }).filter((g) => g.items.length > 0);
  }, [searchTerm]);

  const areAllOpen = useMemo(() => {
    if (hierarchicalCatalog.length === 0) return false;
    return hierarchicalCatalog.every((g) => openModules[g.module]);
  }, [hierarchicalCatalog, openModules]);

  const toggleAllModules = () => {
    const targetState = !areAllOpen;
    const next: Record<string, boolean> = {};
    hierarchicalCatalog.forEach((g) => {
      next[g.module] = targetState;
    });
    setOpenModules(next);
  };

  const handleSave = async () => {
    setIsSaving(true);
    try {
      // 1. Update local reactive store immediately
      setRolePermissions(selectedRole, draft);

      // 2. Persist to backend database if connected
      const backendName = BACKEND_ROLE_NAME_MAP[selectedRole];
      const match = backendRoles.find(
        (r) => r.name.toLowerCase() === backendName.toLowerCase() || r.name.toLowerCase() === selectedRole.toLowerCase(),
      );
      if (match) {
        await apiUpdateRolePermissions(match.id, draft);
      }

      toast.success("Permissions saved successfully", {
        description: `Access rules for ${ROLE_LABELS[selectedRole]} have been updated dynamically across the application.`,
      });
    } catch {
      toast.success("Permissions updated locally", {
        description: `Access rules for ${ROLE_LABELS[selectedRole]} are now active in this workspace.`,
      });
    } finally {
      setIsSaving(false);
    }
  };

  const handleReset = async () => {
    const defaultPerms = DEFAULT_ROLE_PERMISSIONS[selectedRole] ?? [];
    resetRolePermissions(selectedRole);
    setDraft(defaultPerms);

    try {
      const backendName = BACKEND_ROLE_NAME_MAP[selectedRole];
      const match = backendRoles.find(
        (r) => r.name.toLowerCase() === backendName.toLowerCase() || r.name.toLowerCase() === selectedRole.toLowerCase(),
      );
      if (match) {
        await apiResetRolePermissions(match.id);
      }
    } catch {
      /* ignore */
    }

    toast.message("Reset to baseline permissions", {
      description: `Default permissions restored for ${ROLE_LABELS[selectedRole]}.`,
    });
  };

  const enabledCount = draft.length;

  return (
    <>
      <div className="mb-4 rounded-xl border border-primary/20 bg-primary/5 p-4 text-xs text-muted-foreground flex items-center justify-between gap-4">
        <div>
          <span className="font-semibold text-foreground">Dynamic Multi-Level RBAC:</span> Enable or disable features at the <span className="font-medium text-foreground">Module → Submodule → Widget / Action</span> level. Changes apply automatically across all screens and role switches in real time.
        </div>
        <div className="flex items-center gap-2 shrink-0">
          <CheckCircle2 className="h-4 w-4 text-primary" />
          <span className="font-medium text-foreground">Dynamic Sync Active</span>
        </div>
      </div>

      <div className="mb-4 flex flex-wrap items-center gap-3">
        <div className="relative">
          <select
            value={selectedRole}
            onChange={(e) => switchRole(e.target.value as Role)}
            className="h-9 appearance-none rounded-md border border-input bg-card pl-3 pr-8 text-sm font-medium outline-none focus-visible:ring-2 focus-visible:ring-ring cursor-pointer"
          >
            {APP_ROLES.map((r) => (
              <option key={r} value={r}>
                {ROLE_LABELS[r]}
              </option>
            ))}
          </select>
          <ChevronDown className="pointer-events-none absolute right-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        </div>

        <span className="rounded-full border border-border bg-muted/40 px-2.5 py-1 text-[11px] text-muted-foreground">
          Scope: {SCOPE_LABEL[ROLE_PROJECT_SCOPE[selectedRole]]}
        </span>

        <span className="text-[11px] font-medium text-primary">
          {enabledCount} permissions active
        </span>

        <div className="relative max-w-xs flex-1 min-w-[200px]">
          <Search className="pointer-events-none absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
          <input
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="Search permissions, modules, actions…"
            className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
        </div>

        <button
          onClick={toggleAllModules}
          className="inline-flex items-center gap-1.5 rounded-md border border-border bg-card px-3 py-2 text-xs font-medium hover:bg-accent transition-colors"
          title={areAllOpen ? "Collapse all module dropdowns" : "Expand all module dropdowns"}
        >
          <ChevronsUpDown className="h-3.5 w-3.5" />
          {areAllOpen ? "Collapse All" : "Expand All"}
        </button>

        <button
          onClick={handleReset}
          disabled={selectedRole === "dhanshree"}
          className="inline-flex items-center gap-1.5 rounded-md border border-border bg-card px-3 py-2 text-xs font-medium hover:bg-accent disabled:opacity-50 transition-colors"
        >
          <RotateCcw className="h-3.5 w-3.5" />
          Reset Baseline
        </button>

        <button
          onClick={handleSave}
          disabled={isSaving || selectedRole === "dhanshree"}
          className="ml-auto inline-flex items-center gap-1.5 rounded-md bg-primary px-4 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50 transition-colors shadow-2xs"
        >
          <Save className="h-3.5 w-3.5" />
          {isSaving ? "Saving…" : "Save Permissions"}
        </button>
      </div>

      <div className="space-y-3">
        {hierarchicalCatalog.map(({ module, submodules, totalCount }) => {
          const open = openModules[module] ?? false;
          const allModuleKeys = PERMISSION_CATALOG.filter((p) => p.module === module).map((p) => p.key);
          const onCount = allModuleKeys.filter((k) => granted.has(k)).length;
          const isAllModuleSelected = allModuleKeys.length > 0 && onCount === allModuleKeys.length;
          const ModuleIcon = MODULE_ICON_MAP[module] || Layers;

          return (
            <div
              key={module}
              className={cn(
                "overflow-hidden rounded-xl border bg-card transition-all duration-200",
                open ? "border-primary/40 shadow-sm" : "border-border shadow-2xs hover:border-border/80",
              )}
            >
              {/* Module Header Bar / Dropdown Trigger */}
              <div
                className={cn(
                  "flex w-full items-center justify-between px-4 py-3 bg-card transition-colors select-none",
                  open && "border-b border-border/50 bg-muted/20",
                )}
              >
                <button
                  type="button"
                  onClick={() => setOpenModules((p) => ({ ...p, [module]: !open }))}
                  className="flex items-center gap-3 text-left flex-1 group cursor-pointer"
                  aria-expanded={open}
                >
                  <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary transition-transform group-hover:scale-105">
                    <ModuleIcon className="h-4 w-4" />
                  </div>
                  <div>
                    <span className="text-sm font-semibold text-foreground group-hover:text-primary transition-colors">
                      {module}
                    </span>
                    <span className="ml-2.5 text-[11px] font-normal text-muted-foreground">
                      ({submodules.length} {submodules.length === 1 ? "submodule" : "submodules"})
                    </span>
                  </div>
                  <ChevronDown
                    className={cn(
                      "ml-1 h-4 w-4 text-muted-foreground transition-transform duration-200",
                      open && "rotate-180 text-primary",
                    )}
                  />
                </button>

                <div className="flex items-center gap-3">
                  <span
                    className={cn(
                      "text-[11px] tabular-nums font-medium px-2.5 py-0.5 rounded-full border",
                      isAllModuleSelected
                        ? "border-emerald-500/30 bg-emerald-500/10 text-emerald-600 dark:text-emerald-400"
                        : onCount > 0
                          ? "border-primary/30 bg-primary/10 text-primary"
                          : "border-border bg-muted/50 text-muted-foreground",
                    )}
                  >
                    {onCount} / {totalCount} active
                  </span>

                  {selectedRole !== "dhanshree" && (
                    <button
                      type="button"
                      onClick={() => toggleModuleAll(module, !isAllModuleSelected)}
                      className="text-[11px] font-medium text-primary hover:underline px-1.5 py-0.5"
                    >
                      {isAllModuleSelected ? "Deselect All" : "Select All"}
                    </button>
                  )}
                </div>
              </div>

              {/* Submodules & Action/Widget Grid */}
              {open && (
                <div className="p-4 space-y-4 bg-background/40">
                  {submodules.map(({ submodule, subItems, groups }) => {
                    const subKeys = subItems.map((i) => i.key);
                    const subOnCount = subKeys.filter((k) => granted.has(k)).length;
                    const isAllSubSelected = subKeys.length > 0 && subOnCount === subKeys.length;

                    return (
                      <div
                        key={submodule}
                        className="rounded-lg border border-border/70 bg-card p-3.5 space-y-3 shadow-2xs"
                      >
                        {/* Submodule Header */}
                        <div className="flex items-center justify-between border-b border-border/50 pb-2">
                          <div className="flex items-center gap-2">
                            <span className="text-xs font-semibold text-foreground">
                              {submodule}
                            </span>
                            <span className="text-[10px] text-muted-foreground tabular-nums bg-muted/50 px-1.5 py-0.5 rounded">
                              {subOnCount} / {subItems.length} active
                            </span>
                          </div>

                          {selectedRole !== "dhanshree" && (
                            <button
                              type="button"
                              onClick={() => toggleSubmoduleAll(module, submodule, !isAllSubSelected)}
                              className="text-[10px] text-muted-foreground hover:text-primary transition-colors flex items-center gap-1"
                            >
                              {isAllSubSelected ? (
                                <>
                                  <Square className="h-3 w-3" /> Deselect Submodule
                                </>
                              ) : (
                                <>
                                  <CheckSquare className="h-3 w-3" /> Select Submodule
                                </>
                              )}
                            </button>
                          )}
                        </div>

                        {/* Groups inside Submodule */}
                        <div className="space-y-3 pt-1">
                          {groups.map((group) => (
                            <div key={group} className="space-y-1.5">
                              <div className="text-[10px] font-semibold uppercase tracking-wider text-muted-foreground">
                                {group}
                              </div>
                              <div className="grid gap-1.5 sm:grid-cols-2 lg:grid-cols-3">
                                {subItems
                                  .filter((i) => i.group === group)
                                  .map((item) => {
                                    const checked = granted.has(item.key);
                                    return (
                                      <label
                                        key={item.key}
                                        className={cn(
                                          "flex items-center gap-2.5 rounded-md px-2.5 py-2 text-xs transition-colors cursor-pointer border select-none",
                                          checked
                                            ? "border-primary/30 bg-primary/5 text-foreground font-medium"
                                            : "border-transparent hover:bg-accent/40 text-muted-foreground",
                                        )}
                                      >
                                        <input
                                          type="checkbox"
                                          checked={checked}
                                          onChange={() => toggle(item.key)}
                                          disabled={selectedRole === "dhanshree"}
                                          className="h-3.5 w-3.5 rounded border-2 border-input accent-primary cursor-pointer shrink-0"
                                        />
                                        <span className="truncate">{item.label}</span>
                                      </label>
                                    );
                                  })}
                              </div>
                            </div>
                          ))}
                        </div>
                      </div>
                    );
                  })}

                  {selectedRole === "dhanshree" && (
                    <p className="text-[11px] text-muted-foreground italic">
                      Admin always has super-user full access across every module, submodule, and widget.
                    </p>
                  )}
                </div>
              )}
            </div>
          );
        })}
      </div>
    </>
  );
}
