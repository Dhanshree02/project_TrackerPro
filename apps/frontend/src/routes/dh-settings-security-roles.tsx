import { createFileRoute, Link, Navigate } from "@tanstack/react-router";
import { useMemo, useState } from "react";
import { Search, ChevronRight, ChevronDown, Save, RotateCcw } from "lucide-react";
import { toast } from "sonner";
import { AppShell } from "@/components/app-shell";
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

import { usePermissions } from "@/lib/permissions";

function SecurityRolesPage() {
  const { can, isDhanshree } = useRoleContext();
  const { hasAny } = usePermissions();
  const [activeTab, setActiveTab] = useState<"users" | "modules">("modules");

  const allowed = isDhanshree || (can ? can("settings.manage_roles") : false) || hasAny("settings.manage_roles", "roles:manage", "settings.view");
  if (!allowed) return <Navigate to="/" />;

  return (
    <AppShell title="Roles & Permissions" subtitle="Who can see and do what — across every module">
      <nav className="mb-5 flex items-center gap-1.5 text-xs text-muted-foreground" aria-label="Breadcrumb">
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
  const [q, setQ] = useState("");
  const [roleFilter, setRoleFilter] = useState<string>("all");
  const [users, setUsers] = useState<UserRow[]>(() => [...initialUsers]);

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
          onClick={() => toast.success("Roles updated", { description: `${users.length} user role assignments saved.` })}
          className="ml-auto inline-flex items-center gap-1.5 rounded-md bg-primary px-4 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90 transition-colors"
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
                      {u.name.split(" ").map((w) => w[0]).join("").slice(0, 2)}
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

function ModuleAccessTab() {
  const ctx = useRoleContext();
  const getPermissionsFor = ctx.getPermissionsFor ?? ((r: Role) => DEFAULT_ROLE_PERMISSIONS[r] ?? []);
  const setRolePermissions = ctx.setRolePermissions ?? (() => {});
  const resetRolePermissions = ctx.resetRolePermissions ?? (() => {});
  const [selectedRole, setSelectedRole] = useState<Role>("employee");
  const [openModules, setOpenModules] = useState<Record<string, boolean>>({ Projects: true });
  const [draft, setDraft] = useState<PermissionKey[]>(() => getPermissionsFor("employee"));

  const switchRole = (role: Role) => {
    setSelectedRole(role);
    setDraft(getPermissionsFor(role));
  };

  const granted = useMemo(() => new Set(draft), [draft]);

  const toggle = (key: PermissionKey) => {
    setDraft((prev) => (prev.includes(key) ? prev.filter((k) => k !== key) : [...prev, key]));
  };

  const grouped = useMemo(() => {
    return MODULE_ORDER.map((module) => {
      const items = PERMISSION_CATALOG.filter((p) => p.module === module);
      const groups = [...new Set(items.map((i) => i.group))];
      return { module, groups, items };
    }).filter((g) => g.items.length > 0);
  }, []);

  const enabledCount = draft.length;

  return (
    <>
      <p className="mb-4 text-xs text-muted-foreground">
        Defaults match the agreed access for each role. Saving applies immediately in this workspace (until the backend is live).
        Use the role switcher in the top bar to preview.
      </p>

      <div className="mb-4 flex flex-wrap items-center gap-3">
        <select
          value={selectedRole}
          onChange={(e) => switchRole(e.target.value as Role)}
          className="h-9 rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
        >
          {APP_ROLES.map((r) => (
            <option key={r} value={r}>
              {ROLE_LABELS[r]}
            </option>
          ))}
        </select>
        <span className="rounded-full border border-border bg-muted/40 px-2.5 py-1 text-[11px] text-muted-foreground">
          Data scope: {SCOPE_LABEL[ROLE_PROJECT_SCOPE[selectedRole]]}
        </span>
        <span className="text-[11px] text-muted-foreground">{enabledCount} permissions on</span>
        <button
          onClick={() => {
            resetRolePermissions(selectedRole);
            setDraft(DEFAULT_ROLE_PERMISSIONS[selectedRole]);
            toast.message("Reset to defaults", { description: ROLE_LABELS[selectedRole] });
          }}
          className="inline-flex items-center gap-1.5 rounded-md border border-border bg-card px-3 py-2 text-xs font-medium hover:bg-accent"
        >
          <RotateCcw className="h-3.5 w-3.5" />
          Reset
        </button>
        <button
          onClick={() => {
            setRolePermissions(selectedRole, draft);
            toast.success("Permissions saved", {
              description: `Access for ${ROLE_LABELS[selectedRole]} updated.`,
            });
          }}
          className="ml-auto inline-flex items-center gap-1.5 rounded-md bg-primary px-4 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90"
        >
          <Save className="h-3.5 w-3.5" />
          Save Permissions
        </button>
      </div>

      <div className="space-y-2">
        {grouped.map(({ module, groups, items }) => {
          const open = openModules[module] ?? false;
          const onCount = items.filter((i) => granted.has(i.key)).length;
          return (
            <div key={module} className="overflow-hidden rounded-xl border border-border bg-card shadow-sm">
              <button
                onClick={() => setOpenModules((p) => ({ ...p, [module]: !open }))}
                className="flex w-full items-center gap-3 px-4 py-3 text-left hover:bg-accent/30"
              >
                <ChevronDown className={cn("h-4 w-4 text-muted-foreground transition-transform", open && "rotate-180")} />
                <span className="text-sm font-semibold">{module}</span>
                <span className="ml-auto text-[11px] tabular-nums text-muted-foreground">
                  {onCount}/{items.length} enabled
                </span>
              </button>
              {open && (
                <div className="border-t border-border px-4 py-3 space-y-4">
                  {groups.map((group) => (
                    <div key={group}>
                      <div className="mb-2 text-[10px] font-semibold uppercase tracking-wide text-muted-foreground">
                        {group}
                      </div>
                      <div className="grid gap-1.5 sm:grid-cols-2">
                        {items
                          .filter((i) => i.group === group)
                          .map((item) => (
                            <label
                              key={item.key}
                              className="flex items-center gap-2 rounded-md px-2 py-1.5 text-sm hover:bg-accent/40 cursor-pointer"
                            >
                              <input
                                type="checkbox"
                                checked={granted.has(item.key)}
                                onChange={() => toggle(item.key)}
                                disabled={selectedRole === "dhanshree"}
                                className="h-4 w-4 rounded border-2 border-input accent-primary cursor-pointer"
                              />
                              <span>{item.label}</span>
                            </label>
                          ))}
                      </div>
                    </div>
                  ))}
                  {selectedRole === "dhanshree" && (
                    <p className="text-[11px] text-muted-foreground">Admin always has full access.</p>
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
