import { createFileRoute, Link, Navigate } from "@tanstack/react-router";
import { useState, useMemo } from "react";
import { Search, ChevronRight, Save } from "lucide-react";
import { toast } from "sonner";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/dh-settings-security-roles")({
  head: () => ({
    meta: [
      { title: "Security Roles — Settings — Pulse PMO" },
      { name: "description", content: "Manage user roles and module access permissions." },
    ],
  }),
  component: SecurityRolesPage,
});

// ─── Static data ───────────────────────────────────────────────

const roleOptions = [
  "Sales",
  "Accounts",
  "HR",
  "HOD",
  "Business Owner",
  "PM",
  "Senior PM",
  "TL",
  "Employee",
  "Engagement Manager",
  "PMO",
] as const;

type RoleName = (typeof roleOptions)[number];

interface UserRow {
  id: string;
  name: string;
  email: string;
  currentRole: RoleName;
}

const initialUsers: UserRow[] = [
  { id: "r1", name: "Aarav Mehta", email: "aarav.mehta@talakunchi.com", currentRole: "Senior PM" },
  { id: "r2", name: "Riya Kapoor", email: "riya.kapoor@talakunchi.com", currentRole: "Engagement Manager" },
  { id: "r3", name: "Vikram Shah", email: "vikram.shah@talakunchi.com", currentRole: "PM" },
  { id: "r4", name: "Sana Iyer", email: "sana.iyer@talakunchi.com", currentRole: "PM" },
  { id: "r5", name: "Nikhil Rao", email: "nikhil.rao@talakunchi.com", currentRole: "TL" },
  { id: "r6", name: "Priya Verma", email: "priya.verma@talakunchi.com", currentRole: "TL" },
  { id: "r7", name: "Arjun Singh", email: "arjun.singh@talakunchi.com", currentRole: "Employee" },
  { id: "r8", name: "Meera Joshi", email: "meera.joshi@talakunchi.com", currentRole: "Employee" },
  { id: "r9", name: "Dev Patel", email: "dev.patel@talakunchi.com", currentRole: "Employee" },
  { id: "r10", name: "Kavya Nair", email: "kavya.nair@talakunchi.com", currentRole: "HR" },
  { id: "r11", name: "Rahul Gupta", email: "rahul.gupta@talakunchi.com", currentRole: "PMO" },
  { id: "r12", name: "Anita Desai", email: "anita.desai@talakunchi.com", currentRole: "HOD" },
  { id: "r13", name: "Vikrant Malhotra", email: "vikrant.malhotra@talakunchi.com", currentRole: "Business Owner" },
  { id: "r14", name: "Sneha Kulkarni", email: "sneha.kulkarni@talakunchi.com", currentRole: "Accounts" },
  { id: "r15", name: "Rohan Sharma", email: "rohan.sharma@talakunchi.com", currentRole: "Sales" },
  { id: "r16", name: "Tanvi Reddy", email: "tanvi.reddy@talakunchi.com", currentRole: "Employee" },
];

const modules = [
  "Dashboard",
  "Action Centre",
  "Projects",
  "Reports",
  "Resources",
  "Customers",
  "Settings",
] as const;

type ModuleName = (typeof modules)[number];

interface ModulePerm {
  module: ModuleName;
  view: boolean;
  manage: boolean;
}

const defaultPerms: Record<string, ModulePerm[]> = {
  PM: [
    { module: "Dashboard", view: true, manage: false },
    { module: "Action Centre", view: true, manage: true },
    { module: "Projects", view: true, manage: true },
    { module: "Reports", view: true, manage: false },
    { module: "Resources", view: true, manage: false },
    { module: "Customers", view: true, manage: false },
    { module: "Settings", view: false, manage: false },
  ],
  "Senior PM": [
    { module: "Dashboard", view: true, manage: true },
    { module: "Action Centre", view: true, manage: true },
    { module: "Projects", view: true, manage: true },
    { module: "Reports", view: true, manage: true },
    { module: "Resources", view: true, manage: true },
    { module: "Customers", view: true, manage: false },
    { module: "Settings", view: false, manage: false },
  ],
  TL: [
    { module: "Dashboard", view: true, manage: false },
    { module: "Action Centre", view: true, manage: false },
    { module: "Projects", view: true, manage: false },
    { module: "Reports", view: true, manage: false },
    { module: "Resources", view: false, manage: false },
    { module: "Customers", view: false, manage: false },
    { module: "Settings", view: false, manage: false },
  ],
  Employee: [
    { module: "Dashboard", view: true, manage: false },
    { module: "Action Centre", view: true, manage: false },
    { module: "Projects", view: true, manage: false },
    { module: "Reports", view: false, manage: false },
    { module: "Resources", view: false, manage: false },
    { module: "Customers", view: false, manage: false },
    { module: "Settings", view: false, manage: false },
  ],
  HOD: [
    { module: "Dashboard", view: true, manage: true },
    { module: "Action Centre", view: true, manage: true },
    { module: "Projects", view: true, manage: true },
    { module: "Reports", view: true, manage: true },
    { module: "Resources", view: true, manage: true },
    { module: "Customers", view: true, manage: true },
    { module: "Settings", view: true, manage: false },
  ],
  "Business Owner": [
    { module: "Dashboard", view: true, manage: true },
    { module: "Action Centre", view: true, manage: true },
    { module: "Projects", view: true, manage: true },
    { module: "Reports", view: true, manage: true },
    { module: "Resources", view: true, manage: true },
    { module: "Customers", view: true, manage: true },
    { module: "Settings", view: true, manage: true },
  ],
  PMO: [
    { module: "Dashboard", view: true, manage: true },
    { module: "Action Centre", view: true, manage: true },
    { module: "Projects", view: true, manage: true },
    { module: "Reports", view: true, manage: true },
    { module: "Resources", view: true, manage: true },
    { module: "Customers", view: true, manage: true },
    { module: "Settings", view: true, manage: true },
  ],
  "Engagement Manager": [
    { module: "Dashboard", view: true, manage: false },
    { module: "Action Centre", view: true, manage: true },
    { module: "Projects", view: true, manage: true },
    { module: "Reports", view: true, manage: true },
    { module: "Resources", view: true, manage: false },
    { module: "Customers", view: true, manage: true },
    { module: "Settings", view: false, manage: false },
  ],
  Sales: [
    { module: "Dashboard", view: true, manage: false },
    { module: "Action Centre", view: false, manage: false },
    { module: "Projects", view: true, manage: false },
    { module: "Reports", view: true, manage: false },
    { module: "Resources", view: false, manage: false },
    { module: "Customers", view: true, manage: false },
    { module: "Settings", view: false, manage: false },
  ],
  Accounts: [
    { module: "Dashboard", view: true, manage: false },
    { module: "Action Centre", view: false, manage: false },
    { module: "Projects", view: true, manage: false },
    { module: "Reports", view: true, manage: true },
    { module: "Resources", view: false, manage: false },
    { module: "Customers", view: true, manage: true },
    { module: "Settings", view: false, manage: false },
  ],
  HR: [
    { module: "Dashboard", view: true, manage: false },
    { module: "Action Centre", view: false, manage: false },
    { module: "Projects", view: false, manage: false },
    { module: "Reports", view: true, manage: false },
    { module: "Resources", view: true, manage: true },
    { module: "Customers", view: false, manage: false },
    { module: "Settings", view: false, manage: false },
  ],
};

// ─── Page ──────────────────────────────────────────────────────

function SecurityRolesPage() {
  const { isDhanshree } = useRoleContext();
  const [activeTab, setActiveTab] = useState<"users" | "modules">("users");

  if (!isDhanshree) return <Navigate to="/" />;

  return (
    <AppShell title="Security Roles" subtitle="Manage user roles and module access">
      {/* Breadcrumb */}
      <nav className="mb-5 flex items-center gap-1.5 text-xs text-muted-foreground" aria-label="Breadcrumb">
        <Link to="/dh-settings" className="hover:text-foreground transition-colors">
          Settings
        </Link>
        <ChevronRight className="h-3 w-3" />
        <span className="font-medium text-foreground">Security Roles</span>
      </nav>

      {/* Tabs */}
      <div className="mb-5 flex items-center border-b border-border">
        <button
          id="tab-user-role-access"
          onClick={() => setActiveTab("users")}
          className={cn(
            "relative px-4 py-2.5 text-sm font-medium transition-colors",
            activeTab === "users"
              ? "text-primary"
              : "text-muted-foreground hover:text-foreground"
          )}
        >
          User Role Access
          {activeTab === "users" && (
            <span className="absolute inset-x-0 -bottom-px h-0.5 rounded-full bg-primary" />
          )}
        </button>
        <button
          id="tab-module-access"
          onClick={() => setActiveTab("modules")}
          className={cn(
            "relative px-4 py-2.5 text-sm font-medium transition-colors",
            activeTab === "modules"
              ? "text-primary"
              : "text-muted-foreground hover:text-foreground"
          )}
        >
          Module Access
          {activeTab === "modules" && (
            <span className="absolute inset-x-0 -bottom-px h-0.5 rounded-full bg-primary" />
          )}
        </button>
      </div>

      {activeTab === "users" ? <UserRoleAccessTab /> : <ModuleAccessTab />}
    </AppShell>
  );
}

// ─── Tab 1: User Role Access ───────────────────────────────────

function UserRoleAccessTab() {
  const [q, setQ] = useState("");
  const [roleFilter, setRoleFilter] = useState<string>("all");
  const [users, setUsers] = useState<UserRow[]>(() => [...initialUsers]);

  const filtered = useMemo(() => {
    let list = users;
    if (roleFilter !== "all") {
      list = list.filter((u) => u.currentRole === roleFilter);
    }
    if (q.trim()) {
      const term = q.toLowerCase();
      list = list.filter(
        (u) =>
          u.name.toLowerCase().includes(term) ||
          u.email.toLowerCase().includes(term)
      );
    }
    return list;
  }, [users, q, roleFilter]);

  const changeRole = (id: string, newRole: RoleName) => {
    setUsers((prev) =>
      prev.map((u) => (u.id === id ? { ...u, currentRole: newRole } : u))
    );
  };

  const saveChanges = () => {
    toast.success("Roles updated", {
      description: `${users.length} user role assignments saved.`,
    });
  };

  return (
    <>
      {/* Toolbar */}
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <div className="relative max-w-xs flex-1">
          <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            id="search-users"
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Search user name or email…"
            className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
        </div>
        <select
          id="filter-role"
          value={roleFilter}
          onChange={(e) => setRoleFilter(e.target.value)}
          className="h-9 rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
        >
          <option value="all">All Roles</option>
          {roleOptions.map((r) => (
            <option key={r} value={r}>
              {r}
            </option>
          ))}
        </select>
        <button
          id="btn-save-roles"
          onClick={saveChanges}
          className="ml-auto inline-flex items-center gap-1.5 rounded-md bg-primary px-4 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90 transition-colors"
        >
          <Save className="h-3.5 w-3.5" />
          Save Changes
        </button>
      </div>

      {/* Table */}
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
                    {u.currentRole}
                  </span>
                </td>
                <td className="px-4 py-3">
                  <select
                    value={u.currentRole}
                    onChange={(e) =>
                      changeRole(u.id, e.target.value as RoleName)
                    }
                    className="h-8 rounded-md border border-input bg-card px-2 text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring"
                  >
                    {roleOptions.map((r) => (
                      <option key={r} value={r}>
                        {r}
                      </option>
                    ))}
                  </select>
                </td>
              </tr>
            ))}
            {filtered.length === 0 && (
              <tr>
                <td
                  colSpan={4}
                  className="px-4 py-10 text-center text-sm text-muted-foreground"
                >
                  No users found matching your search.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </>
  );
}

// ─── Tab 2: Module Access ──────────────────────────────────────

function ModuleAccessTab() {
  const [selectedRole, setSelectedRole] = useState<string>("PM");
  const [perms, setPerms] = useState<ModulePerm[]>(
    () => defaultPerms["PM"] ?? []
  );

  const switchRole = (role: string) => {
    setSelectedRole(role);
    setPerms(defaultPerms[role] ?? modules.map((m) => ({ module: m, view: false, manage: false })));
  };

  const toggle = (module: ModuleName, field: "view" | "manage") => {
    setPerms((prev) =>
      prev.map((p) => {
        if (p.module !== module) return p;
        if (field === "manage" && !p.manage) {
          // enabling manage → also enable view
          return { ...p, view: true, manage: true };
        }
        if (field === "view" && p.view && p.manage) {
          // disabling view → also disable manage
          return { ...p, view: false, manage: false };
        }
        return { ...p, [field]: !p[field] };
      })
    );
  };

  const savePermissions = () => {
    toast.success("Permissions saved", {
      description: `Module access for "${selectedRole}" updated successfully.`,
    });
  };

  return (
    <>
      {/* Toolbar */}
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <select
          id="filter-module-role"
          value={selectedRole}
          onChange={(e) => switchRole(e.target.value)}
          className="h-9 rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
        >
          {roleOptions.map((r) => (
            <option key={r} value={r}>
              {r}
            </option>
          ))}
        </select>
        <button
          id="btn-save-permissions"
          onClick={savePermissions}
          className="ml-auto inline-flex items-center gap-1.5 rounded-md bg-primary px-4 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90 transition-colors"
        >
          <Save className="h-3.5 w-3.5" />
          Save Permissions
        </button>
      </div>

      {/* Table */}
      <div className="overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
        <table className="w-full text-sm">
          <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr>
              <th className="px-4 py-3 font-medium">Module</th>
              <th className="px-4 py-3 font-medium text-center">View</th>
              <th className="px-4 py-3 font-medium text-center">Manage</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {perms.map((p) => (
              <tr
                key={p.module}
                className="hover:bg-accent/30 transition-colors"
              >
                <td className="px-4 py-3 font-medium">{p.module}</td>
                <td className="px-4 py-3 text-center">
                  <label className="inline-flex items-center justify-center">
                    <input
                      type="checkbox"
                      checked={p.view}
                      onChange={() => toggle(p.module, "view")}
                      className="h-4 w-4 rounded border-2 border-input bg-card text-primary accent-primary focus:ring-2 focus:ring-ring focus:ring-offset-1 cursor-pointer"
                    />
                  </label>
                </td>
                <td className="px-4 py-3 text-center">
                  <label className="inline-flex items-center justify-center">
                    <input
                      type="checkbox"
                      checked={p.manage}
                      onChange={() => toggle(p.module, "manage")}
                      className="h-4 w-4 rounded border-2 border-input bg-card text-primary accent-primary focus:ring-2 focus:ring-ring focus:ring-offset-1 cursor-pointer"
                    />
                  </label>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}
