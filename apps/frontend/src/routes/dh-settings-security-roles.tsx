import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useEffect, useMemo, useState, useRef } from "react";
import {
  Search,
  ChevronDown,
  Save,
  RotateCcw,
  Loader2,
  Shield,
  ShieldCheck,
  Eye,
  Edit3,
  X,
  SlidersHorizontal,
  Folder,
  LayoutDashboard,
  ListChecks,
  FolderKanban,
  BarChart3,
  Users,
  Building2,
  Building,
  UserCheck,
  Settings,
  Globe,
  ChevronsUpDown,
  Layers,
  XCircle,
  Lock,
  type LucideIcon,
} from "lucide-react";
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
  getCustomRolePermissions,
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
  { id: "r12", name: "Neha Sharma", email: "neha.sharma@talakunchi.com", currentRole: "sales_bd", initialRole: "sales_bd" },
  { id: "r13", name: "Ananya Desai", email: "ananya.desai@talakunchi.com", currentRole: "Accounts", initialRole: "Accounts" },
  { id: "r14", name: "Karan Verma", email: "karan.verma@talakunchi.com", currentRole: "employee", initialRole: "employee" },
  { id: "r15", name: "Pooja Hegde", email: "pooja.hegde@talakunchi.com", currentRole: "employee", initialRole: "employee" },
  { id: "r16", name: "Aditya Roy", email: "aditya.roy@talakunchi.com", currentRole: "Admin" as Role, initialRole: "Admin" as Role },
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
  const { can, isDhanshree, isAdmin } = useRoleContext();
  const { hasAny, hasPermission } = usePermissions();
  const { canManage, canView } = useWidgetPermissions();
  const [activeTab, setActiveTab] = useState<"modules" | "users">("modules");

  // Only roles with explicit MANAGE access to settings.roles (Admin, PMO) can edit.
  // View-only roles (CEO, COO, CTO, EM, HODs, Senior Managers) can only view.
  const canManageRoles = useMemo(() => {
    if (isAdmin) return true;
    return canManage("settings.roles.modules_access") || canManage("settings.roles.user_access");
  }, [isAdmin, canManage]);

  const allowed =
    canManageRoles ||
    canView("settings.roles.modules_access") ||
    canView("settings.roles.user_access") ||
    (can ? can("settings.roles.view") : false) ||
    hasAny(
      "settings.roles.view",
      "settings.roles.modules_access",
      "settings.roles.user_access"
    );
  if (!allowed) return <Navigate to="/dh-settings-masters" replace />;

  return (
    <AppShell title="Roles & Permissions" subtitle="Fine-grained Role → Module → Submodule → Widget Access Control">
      {!canManageRoles && (
        <div className="mb-5 flex items-center justify-between gap-3 rounded-xl border border-amber-500/30 bg-amber-500/10 px-4 py-3 text-xs text-amber-800 dark:text-amber-300 shadow-2xs">
          <div className="flex items-center gap-2.5">
            <Shield className="h-4 w-4 shrink-0 text-amber-600 dark:text-amber-400" />
            <div>
              <span className="font-bold">Read-Only Mode:</span>{" "}
              <span>Your role has view-only access to Roles & Permissions. All modifications and saving are disabled.</span>
            </div>
          </div>
          <span className="inline-flex items-center gap-1 rounded-md bg-amber-500/20 px-2.5 py-1 text-[11px] font-semibold text-amber-700 dark:text-amber-300 border border-amber-500/30 shrink-0">
            <Lock className="h-3 w-3" /> View Only
          </span>
        </div>
      )}

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

      {activeTab === "modules" ? (
        <ModuleAccessTab canManageRoles={canManageRoles} />
      ) : (
        <UsersTab canManageRoles={canManageRoles} />
      )}
    </AppShell>
  );
}

function UsersTab({ canManageRoles }: { canManageRoles: boolean }) {
  const [users, setUsers] = useState<UserRow[]>(initialUsers);
  const [q, setQ] = useState("");
  const [roleFilter, setRoleFilter] = useState("all");
  const [isSaving, setIsSaving] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    fetchUsers()
      .then((res) => {
        if (cancelled) return;
        const usersList = Array.isArray(res) ? res : res?.items || [];
        if (usersList.length > 0) {
          const rows: UserRow[] = usersList.map((u: any) => {
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
    if (!canManageRoles) return;
    setUsers((prev) => prev.map((u) => (u.id === id ? { ...u, currentRole: newRole } : u)));
  };

  const handleSave = async () => {
    if (!canManageRoles) {
      toast.error("Read-only access: you do not have permission to modify user roles.");
      return;
    }
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
          disabled={!canManageRoles || isSaving}
          title={!canManageRoles ? "Read-only access: changes cannot be saved" : undefined}
          className="ml-auto inline-flex items-center gap-1.5 rounded-md bg-primary px-4 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90 transition-colors disabled:opacity-40 disabled:cursor-not-allowed"
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
                      disabled={!canManageRoles}
                      onChange={(e) => changeRole(u.id, e.target.value as Role)}
                      className={cn(
                        "h-8 rounded-md border border-input bg-card px-2 text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring",
                        !canManageRoles && "cursor-not-allowed opacity-50 bg-muted pointer-events-none"
                      )}
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

const MODULE_ICONS: Record<string, LucideIcon> = {
  dashboard: LayoutDashboard,
  action_center: ListChecks,
  projects: FolderKanban,
  reports: BarChart3,
  resources: Users,
  customers: Building2,
  repository: Building,
  my_team: UserCheck,
  settings: Settings,
};

function PermissionCheckbox({
  checked,
  indeterminate = false,
  onChange,
  disabled = false,
  color = "emerald",
  label,
  subLabel,
  className,
}: {
  checked: boolean;
  indeterminate?: boolean;
  onChange: () => void;
  disabled?: boolean;
  color?: "emerald" | "primary";
  label?: string;
  subLabel?: string;
  className?: string;
}) {
  const ref = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (ref.current) {
      ref.current.indeterminate = Boolean(indeterminate);
    }
  }, [indeterminate]);

  return (
    <label
      onClick={(e) => e.stopPropagation()}
      className={cn(
        "inline-flex items-center gap-2 select-none px-2.5 py-1.5 rounded-lg border transition-all text-xs",
        checked || indeterminate
          ? color === "emerald"
            ? "bg-emerald-500/10 border-emerald-500/30 text-emerald-700 dark:text-emerald-300 font-medium"
            : "bg-primary/10 border-primary/30 text-primary font-medium"
          : "bg-background border-border/60 text-muted-foreground hover:bg-muted/40",
        disabled ? "opacity-35 cursor-not-allowed pointer-events-none" : "cursor-pointer",
        className
      )}
    >
      <input
        ref={ref}
        type="checkbox"
        checked={checked}
        disabled={disabled}
        onChange={(e) => {
          e.stopPropagation();
          if (!disabled) onChange();
        }}
        className={cn(
          "h-4 w-4 rounded border-input cursor-pointer transition-colors",
          color === "emerald"
            ? "accent-emerald-600 text-emerald-600 focus:ring-emerald-500"
            : "accent-primary text-primary focus:ring-primary",
          disabled && "cursor-not-allowed"
        )}
      />
      {label && <span className="text-xs font-semibold">{label}</span>}
      {subLabel && (
        <span className="text-[10px] opacity-75 font-mono ml-0.5">{subLabel}</span>
      )}
    </label>
  );
}

function ModuleAccessTab({ canManageRoles }: { canManageRoles: boolean }) {
  const { refresh: refreshContextPerms } = useWidgetPermissions();
  const [backendRoles, setBackendRoles] = useState<ApiRole[]>([]);
  const [selectedRole, setSelectedRole] = useState<string>("Testing-Manager");
  const [catalogTree, setCatalogTree] = useState<ModuleCatalogItemDto[]>([]);
  const [permissionsState, setPermissionsState] = useState<Record<string, EditablePermission>>({});
  const [searchQuery, setSearchQuery] = useState("");
  const [filterStatus, setFilterStatus] = useState<"all" | "visible" | "hidden">("all");
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

        // Overlay custom permissions from localStorage if present
        const custom = getCustomRolePermissions(selectedRole);

        // Build flat permission map
        const map: Record<string, EditablePermission> = {};
        const collectWidgets = (widgets?: WidgetCatalogItemDto[]) => {
          if (!widgets) return;
          for (const w of widgets) {
            const cv = custom && custom[w.widgetKey] !== undefined ? custom[w.widgetKey].canView : w.canView;
            const cm = custom && custom[w.widgetKey] !== undefined ? custom[w.widgetKey].canManage : w.canManage;
            map[w.widgetKey] = {
              widgetId: w.id,
              widgetKey: w.widgetKey,
              canView: cv,
              canManage: cm,
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
        // Fallback using excel-baseline or custom overrides
        const custom = getCustomRolePermissions(selectedRole);
        const baseline = custom || getBaselinePermissionsForRole(selectedRole);
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
    if (!canManageRoles) return;
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
    if (!canManageRoles) return;
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

  const handleToggleModuleView = (modWidgets: WidgetCatalogItemDto[], currentHasView: boolean) => {
    if (!canManageRoles) return;
    const nextView = currentHasView ? 0 : 1;
    setPermissionsState((prev) => {
      const next = { ...prev };
      for (const w of modWidgets) {
        const cur = next[w.widgetKey];
        if (cur) {
          next[w.widgetKey] = {
            ...cur,
            canView: nextView,
            canManage: nextView === 0 ? 0 : cur.canManage,
          };
        }
      }
      return next;
    });
  };

  const handleToggleModuleManage = (modWidgets: WidgetCatalogItemDto[], currentHasManage: boolean) => {
    if (!canManageRoles) return;
    const nextManage = currentHasManage ? 0 : 1;
    setPermissionsState((prev) => {
      const next = { ...prev };
      for (const w of modWidgets) {
        const cur = next[w.widgetKey];
        if (cur && cur.hasManageAction) {
          next[w.widgetKey] = {
            ...cur,
            canManage: nextManage,
            canView: nextManage === 1 ? 1 : cur.canView,
          };
        }
      }
      return next;
    });
  };

  const handleResetBaseline = async () => {
    if (!canManageRoles) {
      toast.error("Read-only access: you do not have permission to reset baselines.");
      return;
    }
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
    if (!canManageRoles) {
      toast.error("Read-only access: you do not have permission to save permissions.");
      return;
    }
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

  const allWidgetsList = Object.values(permissionsState);
  const totalWidgetsCount = allWidgetsList.length;
  const viewCount = allWidgetsList.filter((p) => p.canView === 1).length;
  const manageableWidgetsTotal = allWidgetsList.filter((p) => p.hasManageAction).length;
  const manageCount = allWidgetsList.filter((p) => p.canManage === 1).length;

  const activeModulesCount = displayModules.filter((mod) => {
    const allModWidgets: WidgetCatalogItemDto[] = [
      ...(mod.directWidgets || []),
      ...(mod.submodules || []).flatMap((s) => [
        ...(s.widgets || []),
        ...(s.childSubmodules || []).flatMap((cs) => cs.widgets || []),
      ]),
    ];
    return allModWidgets.some((w) => permissionsState[w.widgetKey]?.canView === 1);
  }).length;
  const hiddenModulesCount = displayModules.length - activeModulesCount;

  const handleToggleExpandAll = () => {
    const allAreOpen = displayModules.every((m) => openModules[m.code] !== false);
    const next: Record<string, boolean> = {};
    for (const m of displayModules) {
      next[m.code] = !allAreOpen;
    }
    setOpenModules(next);
  };

  return (
    <>
      {/* Top Control Center */}
      <div className="mb-5 rounded-2xl border border-border/80 bg-card p-4 sm:p-5 shadow-xs space-y-4">
        {/* Row 1: Role Selector, Scope, and Action Buttons */}
        <div className="flex flex-wrap items-center justify-between gap-4">
          <div className="flex flex-wrap items-center gap-3">
            <div className="flex items-center gap-2">
              <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-primary/10 text-primary border border-primary/20 shrink-0">
                <ShieldCheck className="h-4 w-4" />
              </div>
              <span className="text-xs font-bold text-foreground uppercase tracking-wider">
                Select Role:
              </span>
            </div>

            <div className="relative min-w-[210px]">
              <select
                value={selectedRole}
                onChange={(e) => setSelectedRole(e.target.value)}
                className="h-10 w-full appearance-none rounded-xl border border-input bg-background px-3.5 pr-8 text-sm font-bold text-foreground outline-none focus-visible:ring-2 focus-visible:ring-ring shadow-2xs hover:border-muted-foreground/40 transition-colors cursor-pointer"
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
              <ChevronsUpDown className="pointer-events-none absolute right-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            </div>

            <span className="inline-flex items-center gap-1.5 rounded-full border border-border/80 bg-muted/50 px-3 py-1 text-xs font-medium text-muted-foreground">
              <Globe className="h-3 w-3 text-muted-foreground/70" />
              <span>Scope:</span>
              <strong className="font-semibold text-foreground">
                {SCOPE_LABEL[ROLE_PROJECT_SCOPE[selectedRole as Role]] || "Involved"}
              </strong>
            </span>
          </div>

          <div className="flex items-center gap-2.5">
            <button
              onClick={handleResetBaseline}
              disabled={!canManageRoles}
              title={!canManageRoles ? "Read-only access: cannot reset baseline" : "Reset role permissions to baseline from Excel"}
              className={cn(
                "inline-flex items-center gap-1.5 rounded-xl border border-border/80 bg-background px-3.5 py-2 text-xs font-semibold hover:bg-muted/50 transition-all text-muted-foreground hover:text-foreground shadow-2xs",
                !canManageRoles ? "opacity-40 cursor-not-allowed" : "cursor-pointer"
              )}
            >
              <RotateCcw className="h-3.5 w-3.5" />
              <span>Reset Baseline</span>
            </button>

            <button
              onClick={handleSaveChanges}
              disabled={!canManageRoles || isSaving || isLoading}
              title={!canManageRoles ? "Read-only access: changes cannot be saved" : undefined}
              className={cn(
                "inline-flex items-center gap-2 rounded-xl bg-primary px-4 py-2 text-xs font-bold text-primary-foreground hover:bg-primary/90 transition-all shadow-xs active:scale-[0.98]",
                !canManageRoles || isSaving || isLoading ? "opacity-40 cursor-not-allowed" : "cursor-pointer"
              )}
            >
              {isSaving ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : <Save className="h-3.5 w-3.5" />}
              <span>Save Permissions</span>
            </button>
          </div>
        </div>

        {/* Row 2: Metrics Summary Chips */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5 pt-1 border-t border-border/40">
          <div className="rounded-xl border border-border/60 bg-muted/20 px-3.5 py-2 flex items-center justify-between">
            <div className="flex items-center gap-2 text-xs text-muted-foreground">
              <Layers className="h-3.5 w-3.5 text-primary" />
              <span className="font-medium">Active Modules</span>
            </div>
            <span className="text-xs font-bold text-foreground">
              {activeModulesCount} / {displayModules.length}
            </span>
          </div>

          <div className="rounded-xl border border-border/60 bg-muted/20 px-3.5 py-2 flex items-center justify-between">
            <div className="flex items-center gap-2 text-xs text-muted-foreground">
              <Eye className="h-3.5 w-3.5 text-emerald-600" />
              <span className="font-medium">Widgets Visible</span>
            </div>
            <span className="text-xs font-bold text-emerald-600 dark:text-emerald-400">
              {viewCount} / {totalWidgetsCount}
            </span>
          </div>

          <div className="rounded-xl border border-border/60 bg-muted/20 px-3.5 py-2 flex items-center justify-between">
            <div className="flex items-center gap-2 text-xs text-muted-foreground">
              <Edit3 className="h-3.5 w-3.5 text-primary" />
              <span className="font-medium">Manage Actions</span>
            </div>
            <span className="text-xs font-bold text-primary">
              {manageCount} / {manageableWidgetsTotal}
            </span>
          </div>

          <div className="rounded-xl border border-border/60 bg-muted/20 px-3.5 py-2 flex items-center justify-between">
            <div className="flex items-center gap-2 text-xs text-muted-foreground">
              <XCircle className="h-3.5 w-3.5 text-rose-500" />
              <span className="font-medium">Hidden Modules</span>
            </div>
            <span className="text-xs font-bold text-rose-600 dark:text-rose-400">
              {hiddenModulesCount}
            </span>
          </div>
        </div>

        {/* Row 3: Search, Filters & Expand All */}
        <div className="flex flex-wrap items-center justify-between gap-3 pt-1 border-t border-border/40">
          <div className="flex flex-wrap items-center gap-2">
            <span className="text-xs text-muted-foreground font-semibold flex items-center gap-1.5 mr-1">
              <SlidersHorizontal className="h-3.5 w-3.5" />
              Filter:
            </span>
            <button
              type="button"
              onClick={() => setFilterStatus("all")}
              className={cn(
                "px-3 py-1 rounded-lg text-xs font-semibold transition-all border cursor-pointer",
                filterStatus === "all"
                  ? "bg-foreground text-background border-foreground shadow-2xs"
                  : "bg-background text-muted-foreground border-border hover:bg-muted/50"
              )}
            >
              All Modules ({displayModules.length})
            </button>
            <button
              type="button"
              onClick={() => setFilterStatus("visible")}
              className={cn(
                "px-3 py-1 rounded-lg text-xs font-semibold transition-all border cursor-pointer",
                filterStatus === "visible"
                  ? "bg-emerald-600 text-white border-emerald-600 shadow-2xs"
                  : "bg-background text-muted-foreground border-border hover:bg-muted/50"
              )}
            >
              Visible Only ({activeModulesCount})
            </button>
            <button
              type="button"
              onClick={() => setFilterStatus("hidden")}
              className={cn(
                "px-3 py-1 rounded-lg text-xs font-semibold transition-all border cursor-pointer",
                filterStatus === "hidden"
                  ? "bg-rose-600 text-white border-rose-600 shadow-2xs"
                  : "bg-background text-muted-foreground border-border hover:bg-muted/50"
              )}
            >
              Hidden Only ({hiddenModulesCount})
            </button>
          </div>

          <div className="flex items-center gap-2">
            <div className="relative w-48 sm:w-60">
              <Search className="pointer-events-none absolute left-3 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
              <input
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Search widgets or keys..."
                className="h-9 w-full rounded-xl border border-input bg-background pl-8 pr-8 text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring transition-colors shadow-2xs"
              />
              {searchQuery && (
                <button
                  type="button"
                  onClick={() => setSearchQuery("")}
                  className="absolute right-2.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground cursor-pointer"
                >
                  <X className="h-3.5 w-3.5" />
                </button>
              )}
            </div>

            <button
              type="button"
              onClick={handleToggleExpandAll}
              className="inline-flex items-center gap-1.5 rounded-xl border border-border/80 bg-background px-3 py-2 text-xs font-semibold hover:bg-muted/50 text-muted-foreground hover:text-foreground transition-all shadow-2xs cursor-pointer"
              title="Expand or collapse all module cards"
            >
              <ChevronsUpDown className="h-3.5 w-3.5" />
              <span>Expand/Collapse All</span>
            </button>
          </div>
        </div>
      </div>

      {isLoading ? (
        <div className="flex h-64 items-center justify-center rounded-xl border border-border bg-card text-xs text-muted-foreground">
          <Loader2 className="mr-2 h-4 w-4 animate-spin text-primary" />
          Loading 4-tier RBAC matrix...
        </div>
      ) : (
        <div className="space-y-3.5">
          {displayModules.map((mod) => {
            const ModIcon = MODULE_ICONS[mod.code] || Layers;
            const open = openModules[mod.code] ?? true;

            // Collect all widgets in this module for count
            const allModWidgets: WidgetCatalogItemDto[] = [
              ...(mod.directWidgets || []),
              ...(mod.submodules || []).flatMap((s) => [
                ...(s.widgets || []),
                ...(s.childSubmodules || []).flatMap((cs) => cs.widgets || []),
              ]),
            ];

            const modViewCount = allModWidgets.filter(
              (w) => permissionsState[w.widgetKey]?.canView === 1
            ).length;
            const modManageCount = allModWidgets.filter(
              (w) => permissionsState[w.widgetKey]?.canManage === 1
            ).length;
            const manageableWidgets = allModWidgets.filter((w) => w.hasManageAction);

            // Filter check
            if (filterStatus === "visible" && modViewCount === 0) return null;
            if (filterStatus === "hidden" && modViewCount > 0) return null;

            // Search filter check
            const filteredWidgets = searchQuery.trim()
              ? allModWidgets.filter((w) =>
                  w.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                  w.widgetKey.toLowerCase().includes(searchQuery.toLowerCase())
                )
              : allModWidgets;

            if (searchQuery.trim() && filteredWidgets.length === 0) {
              return null;
            }

            return (
              <div
                key={mod.code}
                className={cn(
                  "overflow-hidden rounded-2xl border transition-all duration-200 bg-card",
                  modViewCount === 0
                    ? "border-border/60 opacity-90"
                    : "border-border shadow-xs hover:border-border/90"
                )}
              >
                {/* Module Header Bar */}
                <div
                  onClick={() =>
                    setOpenModules((prev) => ({ ...prev, [mod.code]: !open }))
                  }
                  className="flex w-full flex-wrap items-center justify-between gap-3 px-5 py-3.5 bg-muted/20 hover:bg-muted/40 transition-colors cursor-pointer select-none text-left border-b border-border/40"
                >
                  {/* Left: Icon, Name, Code, and Status Badge */}
                  <div className="flex flex-wrap items-center gap-3">
                    <div className="flex items-center justify-center h-8 w-8 rounded-xl bg-primary/10 text-primary border border-primary/20 shrink-0">
                      <ModIcon className="h-4 w-4" />
                    </div>

                    <div>
                      <div className="flex items-center gap-2">
                        <span className="text-base font-extrabold text-foreground tracking-tight">
                          {mod.name}
                        </span>
                        <span className="text-[10px] text-muted-foreground font-mono bg-muted px-1.5 py-0.5 rounded border border-border/40">
                          {mod.code}
                        </span>
                      </div>
                    </div>

                    {/* Modern Status Badge */}
                    {modViewCount === 0 ? (
                      <span className="inline-flex items-center gap-1.5 rounded-full bg-rose-500/10 px-2.5 py-0.5 text-[10px] font-bold text-rose-600 dark:text-rose-400 border border-rose-300/60 dark:border-rose-900/50">
                        <span className="h-1.5 w-1.5 rounded-full bg-rose-500" />
                        No Access (Hidden)
                      </span>
                    ) : modViewCount === allModWidgets.length ? (
                      <span className="inline-flex items-center gap-1.5 rounded-full bg-emerald-500/10 px-2.5 py-0.5 text-[10px] font-bold text-emerald-600 dark:text-emerald-400 border border-emerald-300/60 dark:border-emerald-900/50">
                        <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
                        Full Access ({modViewCount} widgets)
                      </span>
                    ) : (
                      <span className="inline-flex items-center gap-1.5 rounded-full bg-amber-500/10 px-2.5 py-0.5 text-[10px] font-bold text-amber-600 dark:text-amber-400 border border-amber-300/60 dark:border-amber-900/50">
                        <span className="h-1.5 w-1.5 rounded-full bg-amber-500" />
                        Partial Access ({modViewCount}/{allModWidgets.length})
                      </span>
                    )}
                  </div>

                  {/* Right: Quick Module Checkboxes + Accordion Chevron */}
                  <div className="flex items-center gap-2.5" onClick={(e) => e.stopPropagation()}>
                    {/* Module View Checkbox */}
                    <PermissionCheckbox
                      checked={modViewCount === allModWidgets.length}
                      indeterminate={modViewCount > 0 && modViewCount < allModWidgets.length}
                      onChange={() => handleToggleModuleView(allModWidgets, modViewCount > 0)}
                      disabled={!canManageRoles}
                      color="emerald"
                      label="View"
                      subLabel={`(${modViewCount}/${allModWidgets.length})`}
                    />

                    {/* Module Manage Checkbox */}
                    {manageableWidgets.length > 0 ? (
                      <PermissionCheckbox
                        checked={modManageCount === manageableWidgets.length}
                        indeterminate={modManageCount > 0 && modManageCount < manageableWidgets.length}
                        onChange={() => handleToggleModuleManage(allModWidgets, modManageCount > 0)}
                        disabled={!canManageRoles}
                        color="primary"
                        label="Manage"
                        subLabel={`(${modManageCount}/${manageableWidgets.length})`}
                      />
                    ) : (
                      <span className="text-[10px] text-muted-foreground/60 italic px-1 hidden sm:inline">
                        View-only
                      </span>
                    )}

                    {/* Chevron button */}
                    <button
                      type="button"
                      onClick={() => setOpenModules((prev) => ({ ...prev, [mod.code]: !open }))}
                      className="p-1.5 rounded-lg bg-muted/40 hover:bg-muted text-muted-foreground hover:text-foreground transition-all ml-1 cursor-pointer"
                      title={open ? "Collapse" : "Expand"}
                    >
                      <ChevronDown
                        className={cn(
                          "h-4 w-4 transition-transform duration-200",
                          open && "rotate-180"
                        )}
                      />
                    </button>
                  </div>
                </div>

                {/* Inner Content (Widgets Table) */}
                {open && (
                  <div className="border-t border-border/50">
                    {/* Header Columns */}
                    <div className="grid grid-cols-12 gap-3 px-5 py-2.5 bg-muted/30 text-[10px] font-bold uppercase tracking-wider text-muted-foreground border-b border-border/40">
                      <div className="col-span-6">Folder / Submodule / Widget</div>
                      <div className="col-span-2 text-center">Type</div>
                      <div className="col-span-2 text-center">View Access</div>
                      <div className="col-span-2 text-center">Manage Access</div>
                    </div>

                    {/* Direct widgets (Level 3 - under Module) */}
                    {(mod.directWidgets || []).map((w) => (
                      <WidgetPermissionRow
                        key={w.widgetKey}
                        widget={w}
                        permission={permissionsState[w.widgetKey]}
                        onToggleView={() => handleToggleView(w.widgetKey)}
                        onToggleManage={() => handleToggleManage(w.widgetKey)}
                        canManageRoles={canManageRoles}
                      />
                    ))}

                    {/* Submodules (Level 2 - Light Bold) */}
                    {(mod.submodules || []).map((sub) => {
                      const allSubWidgets: WidgetCatalogItemDto[] = [
                        ...(sub.widgets || []),
                        ...(sub.childSubmodules || []).flatMap((cs) => cs.widgets || []),
                      ];
                      const subViewCount = allSubWidgets.filter((w) => permissionsState[w.widgetKey]?.canView === 1).length;
                      const subManageCount = allSubWidgets.filter((w) => permissionsState[w.widgetKey]?.canManage === 1).length;
                      const subManageable = allSubWidgets.filter((w) => w.hasManageAction);

                      return (
                        <div key={sub.code} className="border-b border-border/30 last:border-0 bg-background/50">
                          {/* Submodule Bar - Light Bold Header */}
                          <div className="pl-6 sm:pl-8 pr-5 py-2.5 bg-muted/20 text-xs font-semibold text-foreground/90 flex flex-wrap items-center justify-between gap-2 border-b border-border/30 border-l-4 border-l-primary/40">
                            <div className="flex items-center gap-2">
                              <Folder className="h-4 w-4 text-primary/70 shrink-0" />
                              <span className="font-semibold text-xs sm:text-sm text-foreground/90">{sub.name}</span>
                              <span className="text-[10px] font-mono text-muted-foreground font-normal bg-muted px-1.5 py-0.5 rounded border border-border/30">
                                {sub.code}
                              </span>
                            </div>

                            <div className="flex items-center gap-2" onClick={(e) => e.stopPropagation()}>
                              <PermissionCheckbox
                                checked={subViewCount === allSubWidgets.length}
                                indeterminate={subViewCount > 0 && subViewCount < allSubWidgets.length}
                                onChange={() => handleToggleModuleView(allSubWidgets, subViewCount > 0)}
                                disabled={!canManageRoles}
                                color="emerald"
                                label="View"
                                subLabel={`(${subViewCount}/${allSubWidgets.length})`}
                                className="py-1 px-2.5 bg-background/80"
                              />

                              {subManageable.length > 0 && (
                                <PermissionCheckbox
                                  checked={subManageCount === subManageable.length}
                                  indeterminate={subManageCount > 0 && subManageCount < subManageable.length}
                                  onChange={() => handleToggleModuleManage(allSubWidgets, subManageCount > 0)}
                                  disabled={!canManageRoles}
                                  color="primary"
                                  label="Manage"
                                  subLabel={`(${subManageCount}/${subManageable.length})`}
                                  className="py-1 px-2.5 bg-background/80"
                                />
                              )}
                            </div>
                          </div>

                          {/* Submodule Widgets (Level 3 - More Light) */}
                          {(sub.widgets || []).map((w) => (
                            <WidgetPermissionRow
                              key={w.widgetKey}
                              widget={w}
                              permission={permissionsState[w.widgetKey]}
                              onToggleView={() => handleToggleView(w.widgetKey)}
                              onToggleManage={() => handleToggleManage(w.widgetKey)}
                              indent
                              canManageRoles={canManageRoles}
                            />
                          ))}

                          {/* Child Submodules (Level 2.5) */}
                          {(sub.childSubmodules || []).map((child) => {
                            const childWidgets = child.widgets || [];
                            const childViewCount = childWidgets.filter((w) => permissionsState[w.widgetKey]?.canView === 1).length;
                            const childManageCount = childWidgets.filter((w) => permissionsState[w.widgetKey]?.canManage === 1).length;
                            const childManageable = childWidgets.filter((w) => w.hasManageAction);

                            return (
                              <div key={child.code} className="border-b border-border/20 last:border-0">
                                <div className="pl-10 sm:pl-12 pr-5 py-2 bg-muted/15 text-xs font-medium text-foreground/85 flex flex-wrap items-center justify-between gap-2 border-b border-border/20 border-l-4 border-l-primary/20">
                                  <div className="flex items-center gap-2">
                                    <Folder className="h-3.5 w-3.5 text-primary/60 shrink-0" />
                                    <span className="font-semibold text-xs text-foreground/85">{child.name}</span>
                                    <span className="text-[9px] font-mono text-muted-foreground/60 bg-muted px-1.5 py-0.5 rounded border border-border/20">
                                      {child.code}
                                    </span>
                                  </div>

                                  {childWidgets.length > 0 && (
                                    <div className="flex items-center gap-2" onClick={(e) => e.stopPropagation()}>
                                      <PermissionCheckbox
                                        checked={childViewCount === childWidgets.length}
                                        indeterminate={childViewCount > 0 && childViewCount < childWidgets.length}
                                        onChange={() => handleToggleModuleView(childWidgets, childViewCount > 0)}
                                        disabled={!canManageRoles}
                                        color="emerald"
                                        label="View"
                                        subLabel={`(${childViewCount}/${childWidgets.length})`}
                                        className="py-0.5 px-2 text-[11px] bg-background/80"
                                      />

                                      {childManageable.length > 0 && (
                                        <PermissionCheckbox
                                          checked={childManageCount === childManageable.length}
                                          indeterminate={childManageCount > 0 && childManageCount < childManageable.length}
                                          onChange={() => handleToggleModuleManage(childWidgets, childManageCount > 0)}
                                          disabled={!canManageRoles}
                                          color="primary"
                                          label="Manage"
                                          subLabel={`(${childManageCount}/${childManageable.length})`}
                                          className="py-0.5 px-2 text-[11px] bg-background/80"
                                        />
                                      )}
                                    </div>
                                  )}
                                </div>

                                {childWidgets.map((w) => (
                                  <WidgetPermissionRow
                                    key={w.widgetKey}
                                    widget={w}
                                    permission={permissionsState[w.widgetKey]}
                                    onToggleView={() => handleToggleView(w.widgetKey)}
                                    onToggleManage={() => handleToggleManage(w.widgetKey)}
                                    doubleIndent
                                    canManageRoles={canManageRoles}
                                  />
                                ))}
                              </div>
                            );
                          })}
                        </div>
                      );
                    })}
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
  canManageRoles = true,
}: {
  widget: WidgetCatalogItemDto;
  permission?: EditablePermission;
  onToggleView: () => void;
  onToggleManage: () => void;
  indent?: boolean;
  doubleIndent?: boolean;
  canManageRoles?: boolean;
}) {
  const canView = permission?.canView === 1;
  const canManage = permission?.canManage === 1;

  const typeBadgeStyles: Record<string, { bg: string; text: string; border: string }> = {
    widget: { bg: "bg-blue-500/10", text: "text-blue-600 dark:text-blue-400", border: "border-blue-500/20" },
    action: { bg: "bg-purple-500/10", text: "text-purple-600 dark:text-purple-400", border: "border-purple-500/20" },
    tab: { bg: "bg-amber-500/10", text: "text-amber-600 dark:text-amber-400", border: "border-amber-500/20" },
    kpi_card: { bg: "bg-emerald-500/10", text: "text-emerald-600 dark:text-emerald-400", border: "border-emerald-500/20" },
  };

  const badgeStyle = typeBadgeStyles[widget.widgetType] || {
    bg: "bg-muted",
    text: "text-muted-foreground",
    border: "border-border",
  };

  return (
    <div
      className={cn(
        "grid grid-cols-12 gap-3 px-5 py-2.5 items-center hover:bg-muted/30 transition-colors text-xs border-b border-border/25 last:border-0",
        doubleIndent ? "pl-16 sm:pl-20 bg-muted/10" : indent ? "pl-12 sm:pl-16 bg-muted/5" : "pl-8 sm:pl-10"
      )}
    >
      {/* Level 3: More Light Widget */}
      <div className="col-span-6 flex items-start gap-2 min-w-0 pr-2">
        <span className="text-muted-foreground/45 font-mono text-sm leading-none mt-0.5 select-none shrink-0">↳</span>
        <div className="flex flex-col min-w-0">
          <span className="font-normal text-xs text-foreground/80 leading-snug truncate">
            {widget.name}
          </span>
          <span className="text-[10px] text-muted-foreground/60 font-mono truncate mt-0.5">
            {widget.widgetKey}
          </span>
        </div>
      </div>

      <div className="col-span-2 text-center">
        <span
          className={cn(
            "inline-flex items-center px-2 py-0.5 rounded-md text-[9px] font-bold uppercase tracking-wider border",
            badgeStyle.bg,
            badgeStyle.text,
            badgeStyle.border
          )}
        >
          {widget.widgetType.replace("_", " ")}
        </span>
      </div>

      {/* Checkbox only for View */}
      <div className="col-span-2 flex items-center justify-center">
        <label
          onClick={(e) => {
            e.stopPropagation();
            if (canManageRoles) onToggleView();
          }}
          className={cn(
            "inline-flex items-center gap-1.5 select-none px-2 py-1 rounded transition-colors",
            canManageRoles ? "cursor-pointer hover:bg-muted/50" : "cursor-not-allowed opacity-40 pointer-events-none"
          )}
        >
          <input
            type="checkbox"
            checked={canView}
            disabled={!canManageRoles}
            onChange={() => {
              if (canManageRoles) onToggleView();
            }}
            className={cn(
              "h-4 w-4 rounded border-input text-emerald-600 focus:ring-emerald-500 accent-emerald-600",
              canManageRoles ? "cursor-pointer" : "cursor-not-allowed opacity-50"
            )}
          />
          <span
            className={cn(
              "text-[11px]",
              canView
                ? "text-emerald-700 dark:text-emerald-300 font-medium"
                : "text-muted-foreground/60 font-normal"
            )}
          >
            {canView ? "View" : "No"}
          </span>
        </label>
      </div>

      {/* Checkbox only for Manage */}
      <div className="col-span-2 flex items-center justify-center">
        {widget.hasManageAction ? (
          <label
            onClick={(e) => {
              e.stopPropagation();
              if (canManageRoles && canView) onToggleManage();
            }}
            className={cn(
              "inline-flex items-center gap-1.5 px-2 py-1 rounded transition-colors select-none",
              !canManageRoles
                ? "cursor-not-allowed opacity-40 pointer-events-none"
                : canView
                ? "cursor-pointer hover:bg-muted/50"
                : "cursor-not-allowed opacity-35"
            )}
          >
            <input
              type="checkbox"
              checked={canManage}
              onChange={() => {
                if (canManageRoles && canView) onToggleManage();
              }}
              disabled={!canManageRoles || !canView}
              className={cn(
                "h-4 w-4 rounded border-input text-primary focus:ring-primary accent-primary",
                canManageRoles && canView ? "cursor-pointer" : "cursor-not-allowed opacity-50"
              )}
            />
            <span
              className={cn(
                "text-[11px]",
                !canView
                  ? "text-muted-foreground/40 font-normal"
                  : canManage
                  ? "text-primary font-medium"
                  : "text-muted-foreground/60 font-normal"
              )}
            >
              {canManage ? "Manage" : "No"}
            </span>
          </label>
        ) : (
          <span className="text-[11px] text-muted-foreground/30 italic select-none">
            —
          </span>
        )}
      </div>
    </div>
  );
}
