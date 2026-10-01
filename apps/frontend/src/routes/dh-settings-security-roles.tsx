import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useEffect, useMemo, useState } from "react";
import {
  Search,
  ChevronDown,
  ChevronRight,
  Save,
  RotateCcw,
  Loader2,
  Check,
  ShieldCheck,
  Eye,
  SlidersHorizontal,
  Info,
  Layers,
  Sparkles,
  CheckSquare,
  Square,
  Lock,
} from "lucide-react";
import { toast } from "sonner";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { cn } from "@/lib/utils";
import type { Role } from "@/lib/mock-data";
import {
  APP_ROLES,
  CANONICAL_ROLE_ALIASES,
  DEFAULT_ROLE_PERMISSIONS,
  MODULE_ORDER,
  PERMISSION_CATALOG,
  ROLE_LABELS,
  ROLE_PROJECT_SCOPE,
  useWidgetPermissions,
  type PermissionKey,
} from "@/lib/rbac";
import {
  fetchUsers,
  fetchRoles,
  updateUser,
  updateRolePermissions,
  resetRoleToBaseline,
  type ApiRole,
} from "@/lib/api/users";
import {
  fetchRbacCatalogTree,
  updateRoleWidgetPermissions,
  resetRoleWidgetBaseline,
  type ModuleNode,
  type SubmoduleNode,
  type WidgetNode,
} from "@/lib/api/rbac";

export const Route = createFileRoute("/dh-settings-security-roles")({
  head: () => ({
    meta: [
      { title: "Roles & Permissions — Settings — Pulse PMO" },
      { name: "description", content: "Assign user roles and fine-grained module permissions." },
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

import { usePermissions } from "@/lib/permissions";

function SecurityRolesPage() {
  const { can, isDhanshree, isExecutive } = useRoleContext();
  const { hasAny } = usePermissions();
  const [activeTab, setActiveTab] = useState<"users" | "modules">("modules");

  const allowed = isDhanshree || isExecutive || (can ? can("settings.manage_roles") : false) || hasAny("settings.manage_roles", "roles:manage", "settings.view");
  if (!allowed) return <Navigate to="/" />;

  return (
    <AppShell title="Roles & Permissions" subtitle="Who can see and do what — across every module">
      <div className="mb-5 flex items-center border-b border-border">
        <button
          onClick={() => setActiveTab("modules")}
          className={cn(
            "relative px-4 py-2.5 text-sm font-medium transition-colors",
            activeTab === "modules" ? "text-primary" : "text-muted-foreground hover:text-foreground",
          )}
        >
          Module Access
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
  const { isExecutive, isDhanshree, can } = useRoleContext();
  const [q, setQ] = useState("");
  const [roleFilter, setRoleFilter] = useState<string>("all");
  const [users, setUsers] = useState<UserRow[]>(() => [...initialUsers]);
  const [isLoading, setIsLoading] = useState(false);
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => {
    let cancelled = false;
    setIsLoading(true);
    fetchUsers({ perPage: 100 })
      .then((res) => {
        if (cancelled) return;
        if (res?.items && res.items.length > 0) {
          const rows: UserRow[] = res.items.map((u) => {
            const rawRole = u.role || "";
            const matchedRole = (APP_ROLES.find(
              (r) => r.toLowerCase() === rawRole.toLowerCase() || r === rawRole,
            ) || "employee") as Role;
            return {
              id: u.id,
              name: u.name,
              email: u.email,
              currentRole: matchedRole,
              initialRole: matchedRole,
            };
          });
          setUsers(rows);
        }
      })
      .catch(() => { })
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
              {ROLE_LABELS[r]}
            </option>
          ))}
        </select>
        {!isExecutive && (
          <button
            onClick={handleSave}
            disabled={isSaving}
            className="ml-auto inline-flex items-center gap-1.5 rounded-md bg-primary px-4 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90 transition-colors disabled:opacity-50"
          >
            {isSaving ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : <Save className="h-3.5 w-3.5" />}
            Save Changes
          </button>
        )}
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
                      disabled={isExecutive || (!isDhanshree && !can?.("settings.manage_roles"))}
                      onChange={(e) => changeRole(u.id, e.target.value as Role)}
                      className={cn(
                        "h-8 rounded-md border border-input bg-card px-2 text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring",
                        isExecutive && "cursor-not-allowed opacity-75 bg-muted/30"
                      )}
                    >
                      {APP_ROLES.map((r) => (
                        <option key={r} value={r}>
                          {ROLE_LABELS[r]}
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

function ModuleAccessTab() {
  const ctx = useRoleContext();
  const { isExecutive, isDhanshree, can } = ctx;
  const { refreshPermissions } = useWidgetPermissions();

  const [selectedRoleKey, setSelectedRoleKey] = useState<string>("Testing-Team Member");
  const [backendRoles, setBackendRoles] = useState<ApiRole[]>([]);
  const [selectedRole, setSelectedRole] = useState<ApiRole | null>(null);
  const [catalogTree, setCatalogTree] = useState<ModuleNode[]>([]);
  const [perms, setPerms] = useState<Record<string, { canView: number; canManage: number }>>({});
  const [initialPerms, setInitialPerms] = useState<Record<string, { canView: number; canManage: number }>>({});

  const [isLoadingRoles, setIsLoadingRoles] = useState(true);
  const [isLoadingTree, setIsLoadingTree] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [isResetting, setIsResetting] = useState(false);

  const [searchQuery, setSearchQuery] = useState("");
  const [expandedModules, setExpandedModules] = useState<Record<string, boolean>>({});
  const [expandedSubmodules, setExpandedSubmodules] = useState<Record<string, boolean>>({});

  // Helper to find matching backend role
  const findBackendRole = (roleKey: string, rolesList: ApiRole[]): ApiRole | undefined => {
    if (!rolesList || rolesList.length === 0) return undefined;
    // 1. Direct name match
    let matched = rolesList.find((b) => b.name.toLowerCase() === roleKey.toLowerCase());
    if (matched) return matched;
    // 2. Display name match
    const label = ROLE_LABELS[roleKey as Role] || roleKey;
    matched = rolesList.find((b) => (b.displayName || "").toLowerCase() === label.toLowerCase());
    if (matched) return matched;
    // 3. Canonical alias match (e.g. employee -> Testing-Team Member, pm -> Testing-Manager, etc.)
    const alias = CANONICAL_ROLE_ALIASES[roleKey.toLowerCase()];
    if (alias) {
      matched = rolesList.find((b) => b.name.toLowerCase() === alias.toLowerCase());
      if (matched) return matched;
    }
    return undefined;
  };

  // Full role options matching the established catalog order without "(System Role)" suffix
  const roleOptions = useMemo(() => {
    const list: { key: string; label: string; backendRole?: ApiRole }[] = [];
    const seenNames = new Set<string>();

    // 1. All APP_ROLES in their established catalog order
    for (const r of APP_ROLES) {
      const label = ROLE_LABELS[r] || r;
      const bRole = findBackendRole(r, backendRoles);
      list.push({
        key: r,
        label,
        backendRole: bRole,
      });
      seenNames.add(r.toLowerCase());
      if (bRole) {
        seenNames.add(bRole.name.toLowerCase());
        if (bRole.displayName) seenNames.add(bRole.displayName.toLowerCase());
      }
    }

    // 2. Any additional custom roles present in the database
    for (const b of backendRoles) {
      if (!seenNames.has(b.name.toLowerCase()) && !seenNames.has((b.displayName || "").toLowerCase())) {
        list.push({
          key: b.name,
          label: b.displayName || b.name,
          backendRole: b,
        });
        seenNames.add(b.name.toLowerCase());
      }
    }

    return list;
  }, [backendRoles]);

  // 1. Fetch available database roles
  useEffect(() => {
    let cancelled = false;
    setIsLoadingRoles(true);
    fetchRoles()
      .then((roles) => {
        if (cancelled) return;
        setBackendRoles(roles ?? []);
        if (roles && roles.length > 0) {
          const matched = findBackendRole(selectedRoleKey, roles) || roles[0];
          setSelectedRole(matched);
        }
      })
      .catch((err) => {
        console.error("Failed to fetch roles:", err);
        toast.error("Failed to load roles from database.");
      })
      .finally(() => {
        if (!cancelled) setIsLoadingRoles(false);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  // 2. Fetch catalog tree whenever selectedRole changes
  const loadTreeForRole = async (roleId: string) => {
    setIsLoadingTree(true);
    try {
      const tree = await fetchRbacCatalogTree(roleId);
      setCatalogTree(tree);

      // Extract all widgets into perms map
      const newPerms: Record<string, { canView: number; canManage: number }> = {};
      const extractWidgets = (wList: WidgetNode[]) => {
        for (const w of wList) {
          newPerms[w.id] = {
            canView: w.canView === 1 ? 1 : 0,
            canManage: w.canManage === 1 ? 1 : 0,
          };
        }
      };

      const traverseSub = (s: SubmoduleNode) => {
        extractWidgets(s.widgets);
        if (s.childSubmodules) {
          s.childSubmodules.forEach(traverseSub);
        }
      };

      for (const mod of tree) {
        extractWidgets(mod.directWidgets);
        for (const sub of mod.submodules) {
          traverseSub(sub);
        }
      }

      setPerms(newPerms);
      setInitialPerms({ ...newPerms });

      // Default expand all modules
      const initialExp: Record<string, boolean> = {};
      tree.forEach((m) => {
        initialExp[m.id] = true;
      });
      setExpandedModules(initialExp);
    } catch (err: any) {
      console.error("Failed to load catalog tree:", err);
      toast.error("Failed to load RBAC permissions catalog.");
    } finally {
      setIsLoadingTree(false);
    }
  };

  useEffect(() => {
    if (selectedRole?.id) {
      loadTreeForRole(selectedRole.id);
    }
  }, [selectedRole?.id]);

  // 3. Permission toggling with strict database invariant:
  // - View unchecked (0) -> Manage forced to 0
  // - Manage checked (1) -> View forced to 1
  const toggleView = (widgetId: string) => {
    setPerms((prev) => {
      const cur = prev[widgetId] ?? { canView: 0, canManage: 0 };
      const nextView = cur.canView === 1 ? 0 : 1;
      const nextManage = nextView === 0 ? 0 : cur.canManage;
      return {
        ...prev,
        [widgetId]: { canView: nextView, canManage: nextManage },
      };
    });
  };

  const toggleManage = (widgetId: string) => {
    setPerms((prev) => {
      const cur = prev[widgetId] ?? { canView: 0, canManage: 0 };
      const nextManage = cur.canManage === 1 ? 0 : 1;
      const nextView = nextManage === 1 ? 1 : cur.canView;
      return {
        ...prev,
        [widgetId]: { canView: nextView, canManage: nextManage },
      };
    });
  };

  // Bulk actions for a set of widgets
  const applyBulkToWidgets = (
    widgetList: WidgetNode[],
    action: "all-view" | "revoke-all" | "full-manage",
  ) => {
    setPerms((prev) => {
      const next = { ...prev };
      for (const w of widgetList) {
        if (action === "all-view") {
          const cur = next[w.id] ?? { canView: 0, canManage: 0 };
          next[w.id] = { canView: 1, canManage: cur.canManage };
        } else if (action === "revoke-all") {
          next[w.id] = { canView: 0, canManage: 0 };
        } else if (action === "full-manage") {
          next[w.id] = {
            canView: 1,
            canManage: w.hasManageAction ? 1 : 0,
          };
        }
      }
      return next;
    });
  };

  // Count dirty changes
  const dirtyCount = useMemo(() => {
    let count = 0;
    for (const [wId, val] of Object.entries(perms)) {
      const init = initialPerms[wId];
      if (!init || init.canView !== val.canView || init.canManage !== val.canManage) {
        count++;
      }
    }
    return count;
  }, [perms, initialPerms]);

  // Overall metric counts
  const totalStats = useMemo(() => {
    let totalWidgets = 0;
    let viewGranted = 0;
    let manageGranted = 0;

    for (const [, val] of Object.entries(perms)) {
      totalWidgets++;
      if (val.canView === 1) viewGranted++;
      if (val.canManage === 1) manageGranted++;
    }

    return { totalWidgets, viewGranted, manageGranted };
  }, [perms]);

  // Save handler
  const handleSave = async () => {
    if (!selectedRole) return;
    setIsSaving(true);
    try {
      const items = Object.entries(perms).map(([widgetId, p]) => ({
        widgetId,
        canView: p.canView,
        canManage: p.canManage,
      }));
      await updateRoleWidgetPermissions(selectedRole.id, items);
      setInitialPerms({ ...perms });
      await refreshPermissions(selectedRole.name);
      if (typeof window !== "undefined") {
        window.dispatchEvent(new CustomEvent("rbac-permissions-updated", { detail: { role: selectedRole.name } }));
      }
      toast.success("Permissions updated successfully", {
        description: `Saved ${items.length} widget permissions (1/0 flags) to PostgreSQL for "${selectedRole.displayName || selectedRole.name}".`,
      });
    } catch (err: any) {
      console.error("Save failed:", err);
      toast.error("Failed to save permissions", {
        description: err?.message || "An error occurred while saving.",
      });
    } finally {
      setIsSaving(false);
    }
  };

  // Reset baseline handler
  const handleResetBaseline = async () => {
    if (!selectedRole) return;
    const ok = window.confirm(
      `Reset all permissions for "${selectedRole.displayName || selectedRole.name}" back to the canonical Modules RBAC.xlsx baseline?`,
    );
    if (!ok) return;

    setIsResetting(true);
    try {
      await resetRoleWidgetBaseline(selectedRole.id);
      await loadTreeForRole(selectedRole.id);
      await refreshPermissions(selectedRole.name);
      if (typeof window !== "undefined") {
        window.dispatchEvent(new CustomEvent("rbac-permissions-updated", { detail: { role: selectedRole.name } }));
      }
      toast.success("Role reset to baseline", {
        description: `Default 1/0 permissions restored for "${selectedRole.displayName || selectedRole.name}".`,
      });
    } catch (err: any) {
      console.error("Reset failed:", err);
      toast.error("Failed to reset baseline", {
        description: err?.message || "An error occurred.",
      });
    } finally {
      setIsResetting(false);
    }
  };

  const toggleModule = (modId: string) => {
    setExpandedModules((prev) => ({ ...prev, [modId]: !prev[modId] }));
  };

  const toggleSubmodule = (subId: string) => {
    setExpandedSubmodules((prev) => ({ ...prev, [subId]: !prev[subId] }));
  };

  const expandAll = () => {
    const allMods: Record<string, boolean> = {};
    const allSubs: Record<string, boolean> = {};
    const traverse = (s: SubmoduleNode) => {
      allSubs[s.id] = true;
      s.childSubmodules?.forEach(traverse);
    };
    catalogTree.forEach((m) => {
      allMods[m.id] = true;
      m.submodules.forEach(traverse);
    });
    setExpandedModules(allMods);
    setExpandedSubmodules(allSubs);
  };

  const collapseAll = () => {
    setExpandedModules({});
    setExpandedSubmodules({});
  };

  // Filtering
  const q = searchQuery.trim().toLowerCase();

  const filterWidget = (w: WidgetNode) => {
    if (!q) return true;
    return (
      w.name.toLowerCase().includes(q) ||
      w.code.toLowerCase().includes(q) ||
      w.widgetKey.toLowerCase().includes(q) ||
      w.widgetType.toLowerCase().includes(q)
    );
  };

  const collectSubWidgets = (sub: SubmoduleNode): WidgetNode[] => {
    let list = [...sub.widgets];
    if (sub.childSubmodules) {
      sub.childSubmodules.forEach((cs) => {
        list = list.concat(collectSubWidgets(cs));
      });
    }
    return list;
  };

  const collectModuleWidgets = (mod: ModuleNode): WidgetNode[] => {
    let list = [...mod.directWidgets];
    mod.submodules.forEach((sub) => {
      list = list.concat(collectSubWidgets(sub));
    });
    return list;
  };

  // Type color badges
  const getTypeBadgeClass = (type: string) => {
    switch (type.toLowerCase()) {
      case "kpi":
        return "bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-500/20";
      case "tab":
        return "bg-purple-500/10 text-purple-600 dark:text-purple-400 border-purple-500/20";
      case "form":
        return "bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 border-indigo-500/20";
      case "view":
        return "bg-amber-500/10 text-amber-600 dark:text-amber-400 border-amber-500/20";
      default:
        return "bg-sky-500/10 text-sky-600 dark:text-sky-400 border-sky-500/20";
    }
  };

  return (
    <div className="space-y-5">
      {/* Top Header Controls */}
      <div className="rounded-xl border border-border bg-card p-4 shadow-sm">
        <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
          {/* Role selector & metrics */}
          <div className="flex flex-wrap items-center gap-3">
            <div className="flex flex-col">
              <label className="text-[11px] font-medium text-muted-foreground uppercase tracking-wider">
                Select Target Role
              </label>
              <select
                value={selectedRoleKey}
                disabled={isLoadingRoles || isLoadingTree}
                onChange={(e) => {
                  const key = e.target.value;
                  setSelectedRoleKey(key);
                  const matched = findBackendRole(key, backendRoles);
                  if (matched) setSelectedRole(matched);
                }}
                className="mt-1 h-9 rounded-md border border-input bg-card px-3 text-sm font-medium outline-none focus-visible:ring-2 focus-visible:ring-ring"
              >
                {roleOptions.map((opt) => (
                  <option key={opt.key} value={opt.key}>
                    {opt.label}
                  </option>
                ))}
              </select>
            </div>

            {selectedRole && (
              <div className="mt-5 flex flex-wrap items-center gap-2">
                <span className="inline-flex items-center gap-1.5 rounded-full border border-border bg-muted/40 px-3 py-1 text-xs font-medium">
                  <Layers className="h-3.5 w-3.5 text-primary" />
                  <span>9 Modules &bull; 49 Widgets</span>
                </span>
                <span className="inline-flex items-center gap-1.5 rounded-full border border-emerald-500/20 bg-emerald-500/10 px-3 py-1 text-xs font-medium text-emerald-600 dark:text-emerald-400">
                  <Eye className="h-3.5 w-3.5" />
                  <span>
                    View: {totalStats.viewGranted}/{totalStats.totalWidgets}
                  </span>
                </span>
                <span className="inline-flex items-center gap-1.5 rounded-full border border-purple-500/20 bg-purple-500/10 px-3 py-1 text-xs font-medium text-purple-600 dark:text-purple-400">
                  <ShieldCheck className="h-3.5 w-3.5" />
                  <span>
                    Manage: {totalStats.manageGranted}/{totalStats.totalWidgets}
                  </span>
                </span>
              </div>
            )}
          </div>

          {/* Action buttons */}
          <div className="flex flex-wrap items-center gap-2">
            <button
              onClick={handleResetBaseline}
              disabled={isResetting || isLoadingTree || !selectedRole}
              title="Reset this role to default baseline from modules RBAC.xlsx"
              className="inline-flex items-center gap-1.5 rounded-md border border-border bg-card px-3 py-2 text-xs font-medium text-muted-foreground hover:bg-accent hover:text-foreground transition-colors disabled:opacity-50"
            >
              {isResetting ? (
                <Loader2 className="h-3.5 w-3.5 animate-spin" />
              ) : (
                <RotateCcw className="h-3.5 w-3.5" />
              )}
              Reset Baseline
            </button>

            <button
              onClick={handleSave}
              disabled={isSaving || isLoadingTree || dirtyCount === 0 || !selectedRole}
              className={cn(
                "inline-flex items-center gap-1.5 rounded-md px-4 py-2 text-xs font-medium transition-colors shadow-sm",
                dirtyCount > 0
                  ? "bg-primary text-primary-foreground hover:bg-primary/90 ring-2 ring-primary/30"
                  : "bg-muted text-muted-foreground cursor-not-allowed opacity-60",
              )}
            >
              {isSaving ? (
                <Loader2 className="h-3.5 w-3.5 animate-spin" />
              ) : (
                <Save className="h-3.5 w-3.5" />
              )}
              {dirtyCount > 0 ? `Save Changes (${dirtyCount})` : "All Saved"}
            </button>
          </div>
        </div>

        {/* Database Invariant Explainer Banner */}
        <div className="mt-4 flex items-start gap-2.5 rounded-lg border border-primary/20 bg-primary/5 p-2.5 text-xs text-muted-foreground">
          <Info className="h-4 w-4 shrink-0 text-primary mt-0.5" />
          <div className="space-y-0.5">
            <span className="font-semibold text-foreground">
              4-Tier RBAC Architecture (Role &rarr; Module &rarr; Submodule &rarr; Widget/Tab)
            </span>
            <p>
              Permissions are stored as binary <code className="font-mono text-primary font-bold">1</code> and <code className="font-mono text-primary font-bold">0</code> in PostgreSQL.
              <strong> Core Invariant:</strong> Manage requires View. Unchecking View automatically sets Manage to <code className="font-mono">0</code>; checking Manage automatically enables View (<code className="font-mono">1</code>).
            </p>
          </div>
        </div>

        {/* Search bar & quick expand buttons */}
        <div className="mt-4 flex flex-wrap items-center justify-between gap-3 border-t border-border pt-3">
          <div className="relative max-w-sm flex-1">
            <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <input
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search widget name, code or key (e.g. issues, budget)..."
              className="h-8 w-full rounded-md border border-input bg-card pl-8 pr-3 text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring"
            />
          </div>

          <div className="flex items-center gap-1.5 text-xs">
            <button
              onClick={expandAll}
              className="rounded px-2.5 py-1 text-muted-foreground hover:bg-accent hover:text-foreground"
            >
              Expand All
            </button>
            <span className="text-muted-foreground/40">&bull;</span>
            <button
              onClick={collapseAll}
              className="rounded px-2.5 py-1 text-muted-foreground hover:bg-accent hover:text-foreground"
            >
              Collapse All
            </button>
          </div>
        </div>
      </div>

      {/* Main Hierarchy Tree Display */}
      {isLoadingTree ? (
        <div className="flex flex-col items-center justify-center rounded-xl border border-border bg-card py-16 text-center shadow-sm">
          <Loader2 className="h-8 w-8 animate-spin text-primary" />
          <p className="mt-3 text-sm font-medium text-foreground">Loading Module Permissions...</p>
          <p className="text-xs text-muted-foreground">Reading master catalog and role 1/0 flags from database.</p>
        </div>
      ) : (
        <div className="space-y-4">
          {catalogTree.map((mod) => {
            const modWidgets = collectModuleWidgets(mod);
            const matchesFilter = q
              ? mod.name.toLowerCase().includes(q) ||
                modWidgets.some((w) => filterWidget(w))
              : true;

            if (!matchesFilter) return null;

            const isOpen = q ? true : expandedModules[mod.id] ?? true;

            const modViewCount = modWidgets.filter((w) => perms[w.id]?.canView === 1).length;
            const modManageCount = modWidgets.filter((w) => perms[w.id]?.canManage === 1).length;

            return (
              <div
                key={mod.id}
                className="overflow-hidden rounded-xl border border-border bg-card shadow-sm transition-all"
              >
                {/* Module Header Bar */}
                <div
                  onClick={() => toggleModule(mod.id)}
                  className="flex cursor-pointer items-center justify-between border-b border-border bg-muted/30 px-4 py-3 hover:bg-muted/50 transition-colors"
                >
                  <div className="flex items-center gap-3">
                    <button
                      type="button"
                      className="text-muted-foreground hover:text-foreground p-0.5"
                    >
                      <ChevronDown
                        className={cn(
                          "h-4 w-4 transition-transform duration-200",
                          !isOpen && "-rotate-90",
                        )}
                      />
                    </button>
                    <div className="flex items-center gap-2">
                      <span className="font-semibold text-foreground text-sm">{mod.name}</span>
                      <span className="rounded bg-muted px-2 py-0.5 font-mono text-[10px] text-muted-foreground uppercase">
                        {mod.code}
                      </span>
                    </div>
                  </div>

                  <div className="flex items-center gap-2">
                    {/* Module stats badges */}
                    <span className="hidden sm:inline-flex items-center rounded-full bg-emerald-500/10 px-2 py-0.5 text-[11px] font-medium text-emerald-600 dark:text-emerald-400">
                      View: {modViewCount}/{modWidgets.length}
                    </span>
                    <span className="hidden sm:inline-flex items-center rounded-full bg-purple-500/10 px-2 py-0.5 text-[11px] font-medium text-purple-600 dark:text-purple-400">
                      Manage: {modManageCount}/{modWidgets.length}
                    </span>

                    {/* Quick Module bulk toggle buttons */}
                    <div
                      onClick={(e) => e.stopPropagation()}
                      className="flex items-center gap-1 border-l border-border pl-2 ml-1"
                    >
                      <button
                        type="button"
                        onClick={() => applyBulkToWidgets(modWidgets, "all-view")}
                        className="rounded px-2 py-0.5 text-[10px] font-medium text-muted-foreground hover:bg-accent hover:text-foreground"
                        title="Grant View to all widgets in this module"
                      >
                        All View
                      </button>
                      <button
                        type="button"
                        onClick={() => applyBulkToWidgets(modWidgets, "full-manage")}
                        className="rounded px-2 py-0.5 text-[10px] font-medium text-muted-foreground hover:bg-accent hover:text-foreground"
                        title="Grant full View & Manage to all widgets in this module"
                      >
                        Full
                      </button>
                      <button
                        type="button"
                        onClick={() => applyBulkToWidgets(modWidgets, "revoke-all")}
                        className="rounded px-2 py-0.5 text-[10px] font-medium text-rose-500 hover:bg-rose-500/10"
                        title="Revoke all access in this module"
                      >
                        None
                      </button>
                    </div>
                  </div>
                </div>

                {/* Module Body */}
                {isOpen && (
                  <div className="p-4 space-y-4">
                    {/* Direct widgets if any (e.g. Dashboard, Repository) */}
                    {mod.directWidgets.length > 0 && (
                      <div className="overflow-x-auto rounded-lg border border-border">
                        <table className="w-full text-xs">
                          <thead className="bg-muted/40 text-left font-medium text-muted-foreground border-b border-border">
                            <tr>
                              <th className="px-3 py-2 w-2/5">Widget / Feature Name</th>
                              <th className="px-3 py-2 w-1/5">Type</th>
                              <th className="px-3 py-2 w-1/5 text-center">View (0 / 1)</th>
                              <th className="px-3 py-2 w-1/5 text-center">Manage (0 / 1)</th>
                            </tr>
                          </thead>
                          <tbody className="divide-y divide-border">
                            {mod.directWidgets.filter(filterWidget).map((w) => {
                              const p = perms[w.id] ?? { canView: 0, canManage: 0 };
                              return (
                                <WidgetTableRow
                                  key={w.id}
                                  widget={w}
                                  canView={p.canView}
                                  canManage={p.canManage}
                                  onToggleView={() => toggleView(w.id)}
                                  onToggleManage={() => toggleManage(w.id)}
                                  typeBadgeClass={getTypeBadgeClass(w.widgetType)}
                                />
                              );
                            })}
                          </tbody>
                        </table>
                      </div>
                    )}

                    {/* Submodules */}
                    {mod.submodules.map((sub) => {
                      const subWidgets = collectSubWidgets(sub);
                      const subMatches = q
                        ? sub.name.toLowerCase().includes(q) ||
                          subWidgets.some((w) => filterWidget(w))
                        : true;
                      if (!subMatches) return null;

                      const isSubOpen = q ? true : expandedSubmodules[sub.id] ?? true;

                      return (
                        <div
                          key={sub.id}
                          className="rounded-lg border border-border/80 bg-background/50 overflow-hidden"
                        >
                          {/* Submodule Header */}
                          <div
                            onClick={() => toggleSubmodule(sub.id)}
                            className="flex cursor-pointer items-center justify-between bg-muted/20 px-3.5 py-2.5 hover:bg-muted/40 transition-colors"
                          >
                            <div className="flex items-center gap-2">
                              <ChevronRight
                                className={cn(
                                  "h-3.5 w-3.5 text-muted-foreground transition-transform duration-200",
                                  isSubOpen && "rotate-90",
                                )}
                              />
                              <span className="font-semibold text-foreground text-xs">
                                {sub.name}
                              </span>
                              {sub.routePrefix && (
                                <span className="font-mono text-[10px] text-muted-foreground bg-muted px-1.5 py-0.2 rounded">
                                  {sub.routePrefix}
                                </span>
                              )}
                            </div>

                            <div
                              onClick={(e) => e.stopPropagation()}
                              className="flex items-center gap-1.5"
                            >
                              <span className="text-[10px] text-muted-foreground mr-1">
                                {subWidgets.filter((w) => perms[w.id]?.canView === 1).length}/
                                {subWidgets.length} view
                              </span>
                              <button
                                type="button"
                                onClick={() => applyBulkToWidgets(subWidgets, "all-view")}
                                className="rounded px-1.5 py-0.5 text-[9px] text-muted-foreground hover:bg-accent hover:text-foreground"
                              >
                                View All
                              </button>
                              <button
                                type="button"
                                onClick={() => applyBulkToWidgets(subWidgets, "revoke-all")}
                                className="rounded px-1.5 py-0.5 text-[9px] text-rose-500 hover:bg-rose-500/10"
                              >
                                Clear
                              </button>
                            </div>
                          </div>

                          {/* Submodule Content */}
                          {isSubOpen && (
                            <div className="p-3 space-y-3">
                              {/* Submodule widgets */}
                              {sub.widgets.length > 0 && (
                                <div className="overflow-x-auto rounded border border-border">
                                  <table className="w-full text-xs">
                                    <thead className="bg-muted/30 text-left font-medium text-muted-foreground border-b border-border">
                                      <tr>
                                        <th className="px-3 py-1.5 w-2/5">Widget / Tab</th>
                                        <th className="px-3 py-1.5 w-1/5">Type</th>
                                        <th className="px-3 py-1.5 w-1/5 text-center">View (0 / 1)</th>
                                        <th className="px-3 py-1.5 w-1/5 text-center">Manage (0 / 1)</th>
                                      </tr>
                                    </thead>
                                    <tbody className="divide-y divide-border">
                                      {sub.widgets.filter(filterWidget).map((w) => {
                                        const p = perms[w.id] ?? { canView: 0, canManage: 0 };
                                        return (
                                          <WidgetTableRow
                                            key={w.id}
                                            widget={w}
                                            canView={p.canView}
                                            canManage={p.canManage}
                                            onToggleView={() => toggleView(w.id)}
                                            onToggleManage={() => toggleManage(w.id)}
                                            typeBadgeClass={getTypeBadgeClass(w.widgetType)}
                                          />
                                        );
                                      })}
                                    </tbody>
                                  </table>
                                </div>
                              )}

                              {/* Nested child submodules (e.g. Project Health -> Escalations/Issues) */}
                              {sub.childSubmodules?.map((childSub) => {
                                const childWidgets = childSub.widgets.filter(filterWidget);
                                if (q && childWidgets.length === 0 && !childSub.name.toLowerCase().includes(q)) {
                                  return null;
                                }

                                return (
                                  <div
                                    key={childSub.id}
                                    className="ml-3 rounded border border-dashed border-border/80 bg-muted/10 p-2.5 space-y-2"
                                  >
                                    <div className="flex items-center justify-between">
                                      <div className="flex items-center gap-1.5">
                                        <span className="h-1.5 w-1.5 rounded-full bg-primary" />
                                        <span className="font-semibold text-foreground text-xs">
                                          {childSub.name}
                                        </span>
                                      </div>
                                      <div className="flex items-center gap-1">
                                        <button
                                          type="button"
                                          onClick={() => applyBulkToWidgets(childSub.widgets, "all-view")}
                                          className="text-[9px] text-muted-foreground hover:text-foreground"
                                        >
                                          View All
                                        </button>
                                        <span className="text-muted-foreground/30">&bull;</span>
                                        <button
                                          type="button"
                                          onClick={() => applyBulkToWidgets(childSub.widgets, "revoke-all")}
                                          className="text-[9px] text-rose-500 hover:underline"
                                        >
                                          Clear
                                        </button>
                                      </div>
                                    </div>

                                    <div className="overflow-x-auto rounded border border-border bg-card">
                                      <table className="w-full text-xs">
                                        <tbody className="divide-y divide-border">
                                          {childWidgets.map((w) => {
                                            const p = perms[w.id] ?? { canView: 0, canManage: 0 };
                                            return (
                                              <WidgetTableRow
                                                key={w.id}
                                                widget={w}
                                                canView={p.canView}
                                                canManage={p.canManage}
                                                onToggleView={() => toggleView(w.id)}
                                                onToggleManage={() => toggleManage(w.id)}
                                                typeBadgeClass={getTypeBadgeClass(w.widgetType)}
                                              />
                                            );
                                          })}
                                        </tbody>
                                      </table>
                                    </div>
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
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

interface WidgetTableRowProps {
  widget: WidgetNode;
  canView: number;
  canManage: number;
  onToggleView: () => void;
  onToggleManage: () => void;
  typeBadgeClass: string;
}

function WidgetTableRow({
  widget,
  canView,
  canManage,
  onToggleView,
  onToggleManage,
  typeBadgeClass,
}: WidgetTableRowProps) {
  const isViewGranted = canView === 1;
  const isManageGranted = canManage === 1;

  return (
    <tr className="hover:bg-accent/30 transition-colors">
      {/* Widget Name and Monospace Key */}
      <td className="px-3 py-2">
        <div className="flex flex-col gap-0.5">
          <span className="font-medium text-foreground text-xs">{widget.name}</span>
          <span className="font-mono text-[10px] text-muted-foreground">
            {widget.widgetKey}
          </span>
        </div>
      </td>

      {/* Type badge */}
      <td className="px-3 py-2">
        <span
          className={cn(
            "inline-flex items-center rounded border px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wider",
            typeBadgeClass,
          )}
        >
          {widget.widgetType}
        </span>
      </td>

      {/* View Checkbox (1/0) */}
      <td className="px-3 py-2 text-center">
        <label className="inline-flex items-center gap-1.5 cursor-pointer select-none">
          <input
            type="checkbox"
            checked={isViewGranted}
            onChange={onToggleView}
            className="h-4 w-4 rounded border-input text-primary accent-primary cursor-pointer focus:ring-primary"
          />
          <span
            className={cn(
              "font-mono text-[11px] font-semibold px-1.5 py-0.5 rounded",
              isViewGranted
                ? "bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 font-bold"
                : "bg-muted text-muted-foreground",
            )}
          >
            {isViewGranted ? "1" : "0"}
          </span>
        </label>
      </td>

      {/* Manage Checkbox (1/0) */}
      <td className="px-3 py-2 text-center">
        {widget.hasManageAction ? (
          <label
            className={cn(
              "inline-flex items-center gap-1.5 select-none",
              !isViewGranted ? "cursor-not-allowed opacity-40" : "cursor-pointer",
            )}
            title={
              !isViewGranted
                ? "Manage requires View access (Invariant)"
                : isManageGranted
                  ? "Manage enabled (1)"
                  : "Manage disabled (0)"
            }
          >
            <input
              type="checkbox"
              checked={isManageGranted}
              disabled={!isViewGranted}
              onChange={onToggleManage}
              className="h-4 w-4 rounded border-input text-purple-600 accent-purple-600 cursor-pointer focus:ring-purple-600"
            />
            <span
              className={cn(
                "font-mono text-[11px] font-semibold px-1.5 py-0.5 rounded",
                isManageGranted
                  ? "bg-purple-500/10 text-purple-600 dark:text-purple-400 font-bold"
                  : "bg-muted text-muted-foreground",
              )}
            >
              {isManageGranted ? "1" : "0"}
            </span>
          </label>
        ) : (
          <span
            className="inline-flex items-center gap-1 font-mono text-[10px] text-muted-foreground/60 italic"
            title="This widget is read-only (KPI/View) and does not have manage operations"
          >
            &mdash; (N/A)
          </span>
        )}
      </td>
    </tr>
  );
}
