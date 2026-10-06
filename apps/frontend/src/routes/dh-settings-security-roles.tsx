import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useEffect, useMemo, useState } from "react";
import { Search, ChevronDown, ChevronLeft, ChevronRight, ChevronUp, Save, RotateCcw, Loader2, X, ShieldAlert } from "lucide-react";
import { toast } from "sonner";
import { AppShell } from "@/components/app-shell";
import { usePermissions } from "@/lib/permissions";
import { Avatar } from "@/components/pills";
import { RowsPerPageSelect } from "@/components/rows-per-page-select";
import { apiFetch } from "@/lib/api-client";
import { useRoleContext } from "@/lib/role-context";
import { useAuth } from "@/lib/auth-context";
import { cn } from "@/lib/utils";
import { SearchableSelect } from "@/components/creatable-catalog-select";
import { paginateSlice, paginationRange, totalPageCount } from "@/lib/pagination";

export const Route = createFileRoute("/dh-settings-security-roles")({
  head: () => ({
    meta: [
      { title: "Roles & Permissions — Settings — Pulse PMO" },
      { name: "description", content: "Assign user roles and fine-grained module permissions." },
    ],
  }),
  component: SecurityRolesPage,
});

interface UserAccessApiRow {
  id: string;
  employeeCode: string;
  name: string;
  email: string;
  department: string;
  designation: string;
  profileRole: string;
  accessRole: string;
}

interface UserRow {
  id: string;
  employeeCode: string;
  name: string;
  email: string;
  department: string;
  designation: string;
  profileRole: string;
  accessRole: string;
  initialAccessRole: string;
}

function SecurityRolesPage() {
  const { can, isDhanshree, isAdmin } = useRoleContext();
  const { hasAny } = usePermissions();
  const { permissionsReady } = useAuth();
  const [activeTab, setActiveTab] = useState<"users" | "modules">("modules");

  if (!permissionsReady) return null;

  const allowed =
    isAdmin ||
    isDhanshree ||
    (can ? can("settings.manage_roles") : false) ||
    hasAny(
      "settings.manage_roles",
      "roles:manage",
      "settings.roles.view",
      "roles.view",
      "Settings|Roles & Permission:view",
      "settings.view"
    );
  if (!allowed) return <Navigate to="/" />;

  const canManageRoles =
    isAdmin ||
    isDhanshree ||
    hasAny(
      "settings.manage_roles",
      "roles:manage",
      "Settings|Roles & Permission:manage",
      "Settings|Roles & Permission|Moduleswise Access:manage",
      "Settings|Roles & Permission|User Role Access:manage"
    ) ||
    (can ? can("settings.manage_roles") || can("roles:manage") : false);

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

      {activeTab === "users" ? (
        <UserRoleAccessTab canManageRoles={canManageRoles} />
      ) : (
        <ModuleAccessTab canManageRoles={canManageRoles} />
      )}
    </AppShell>
  );
}

type AccessSortKey = "code" | "name" | "email" | "designation" | "profile";
type SortDir = "asc" | "desc";

function UserRoleAccessTab({ canManageRoles = true }: { canManageRoles?: boolean }) {
  const [q, setQ] = useState("");
  const [roleFilter, setRoleFilter] = useState("");
  const [users, setUsers] = useState<UserRow[]>([]);
  const [roles, setRoles] = useState<RbacRoleOption[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [loadError, setLoadError] = useState("");
  const [isSaving, setIsSaving] = useState(false);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(15);
  const [sortKey, setSortKey] = useState<AccessSortKey>("name");
  const [sortDir, setSortDir] = useState<SortDir>("asc");

  useEffect(() => {
    let cancelled = false;
    setIsLoading(true);
    setLoadError("");
    Promise.all([
      apiFetch<UserAccessApiRow[]>("/api/v1/rbac/user-access"),
      apiFetch<RbacRoleOption[]>("/api/v1/rbac/roles"),
    ])
      .then(([accounts, roleList]) => {
        if (cancelled) return;
        setRoles(roleList ?? []);
        setUsers(
          (accounts ?? []).map((account) => ({
            id: account.id ?? "",
            employeeCode: account.employeeCode,
            name: account.name,
            email: account.email,
            department: account.department,
            designation: account.designation,
            profileRole: account.profileRole,
            accessRole: account.accessRole,
            initialAccessRole: account.accessRole,
          })),
        );
      })
      .catch((error: Error) => {
        if (!cancelled) setLoadError(error.message || "Could not load users.");
      })
      .finally(() => {
        if (!cancelled) setIsLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  const roleOptions = useMemo(() => {
    const options = roles.map((role) => ({
      value: role.name,
      label: role.displayName || role.name,
    }));
    return options.sort((a, b) => a.label.localeCompare(b.label));
  }, [roles]);

  const filtered = useMemo(() => {
    const term = q.trim().toLowerCase();
    const list = users.filter((user) => {
      const matchesRole = !roleFilter || user.accessRole === roleFilter;
      const matchesQuery =
        !term ||
        user.name.toLowerCase().includes(term) ||
        user.email.toLowerCase().includes(term) ||
        user.employeeCode.toLowerCase().includes(term) ||
        user.designation.toLowerCase().includes(term) ||
        user.profileRole.toLowerCase().includes(term);
      return matchesRole && matchesQuery;
    });
    const valueOf = (user: UserRow) => {
      if (sortKey === "code") return user.employeeCode;
      if (sortKey === "email") return user.email;
      if (sortKey === "designation") return user.designation;
      if (sortKey === "profile") return user.profileRole;
      return user.name;
    };
    return [...list].sort((a, b) => {
      const cmp = valueOf(a).localeCompare(valueOf(b), undefined, { sensitivity: "base" });
      return sortDir === "asc" ? cmp : -cmp;
    });
  }, [users, q, roleFilter, sortKey, sortDir]);

  useEffect(() => {
    setPage(1);
  }, [q, roleFilter, pageSize, sortKey, sortDir]);

  const totalPages = totalPageCount(filtered.length, pageSize);
  const currentPage = Math.min(page, totalPages);
  const pageRows = paginateSlice(filtered, currentPage, pageSize);
  const pageRange = paginationRange(currentPage, pageSize, filtered.length);
  const pending = users.filter((user) => user.id && user.accessRole !== user.initialAccessRole).length;

  const changeRole = (id: string, accessRole: string) => {
    setUsers((prev) => prev.map((user) => (user.id === id ? { ...user, accessRole } : user)));
  };

  const handleSave = async () => {
    const changed = users.filter((user) => user.id && user.accessRole !== user.initialAccessRole);
    if (changed.length === 0) {
      toast.info("No access changes to save.");
      return;
    }
    setIsSaving(true);
    try {
      await Promise.all(
        changed.map((user) =>
          apiFetch("/api/v1/rbac/user-access", {
            method: "PUT",
            body: JSON.stringify({ userId: user.id, roleName: user.accessRole }),
          }),
        ),
      );
      setUsers((prev) => prev.map((user) => ({ ...user, initialAccessRole: user.accessRole })));
      toast.success("Access updated", {
        description: `${changed.length} ${changed.length === 1 ? "person can" : "people can"} open that role. Resource profiles were not changed.`,
      });
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Could not update access.");
    } finally {
      setIsSaving(false);
    }
  };

  const sortBy = (column: AccessSortKey) => {
    if (sortKey === column) setSortDir((dir) => (dir === "asc" ? "desc" : "asc"));
    else {
      setSortKey(column);
      setSortDir("asc");
    }
  };

  return (
    <>
      {!canManageRoles && (
        <div className="mb-4 rounded-xl border border-blue-500/20 bg-blue-500/10 p-3 text-xs text-blue-600 dark:text-blue-400 flex items-center gap-2.5">
          <ShieldAlert className="h-4 w-4 shrink-0" />
          <span>You have View Only access to User Role assignments. Modifying user access roles requires manage permission.</span>
        </div>
      )}

      <div className="mb-4 rounded-xl border border-border bg-card p-3.5 shadow-xs">
        <p className="mb-2.5 text-xs text-muted-foreground">
          Access role decides what this person can open. Designation and On Floor Role stay on the resource profile.
        </p>
        <div className="flex flex-col md:flex-row items-stretch md:items-center gap-2.5">
          <div className="relative flex-1 min-w-[220px]">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <input
              type="text"
              value={q}
              onChange={(e) => setQ(e.target.value)}
              placeholder="Search by name, work email, or ID..."
              className="h-9 w-full rounded-md border border-input bg-background pl-9 pr-8 text-xs font-normal text-foreground placeholder:text-muted-foreground outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:border-primary transition-all"
            />
            {q && (
              <button
                type="button"
                onClick={() => setQ("")}
                className="absolute right-2.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground p-0.5"
                title="Clear search"
              >
                <X className="h-3.5 w-3.5" />
              </button>
            )}
          </div>
          <div className="w-full md:w-56 shrink-0">
            <SearchableSelect
              placeholder="All Roles"
              searchPlaceholder="Search roles..."
              options={roleOptions}
              value={roleFilter}
              onChange={setRoleFilter}
              className="w-full text-xs"
              buttonClassName={cn(
                "h-9 text-xs transition-all",
                roleFilter
                  ? "border-blue-500/50 font-medium text-foreground bg-blue-500/5"
                  : "border-input text-muted-foreground",
              )}
            />
          </div>
          {canManageRoles && (
            <button
              type="button"
              onClick={handleSave}
              disabled={isSaving || pending === 0}
              className="md:ml-auto inline-flex h-9 items-center justify-center gap-2 rounded-md bg-primary px-4 text-sm font-medium text-primary-foreground hover:bg-primary/90 shadow-sm transition-all cursor-pointer disabled:opacity-50"
            >
              {isSaving ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
              Save Access{pending > 0 ? ` (${pending})` : ""}
            </button>
          )}
        </div>
      </div>

      <div className="rounded-xl border border-border bg-card shadow-sm overflow-hidden flex flex-col">
        <div className="overflow-auto max-h-[calc(100vh-280px)] min-h-[420px]">
          <table className="w-full min-w-[1100px] table-fixed text-sm">
            <thead className="sticky top-0 z-10 bg-blue-50/80 dark:bg-blue-950/45 backdrop-blur-md text-left text-xs text-blue-950/85 dark:text-blue-100/85 border-b border-slate-300 dark:border-slate-700 shadow-2xs">
              <tr>
                <AccessSortHeader label="Employee ID" column="code" sortKey={sortKey} sortDir={sortDir} onSort={sortBy} className="w-32" />
                <AccessSortHeader label="Name" column="name" sortKey={sortKey} sortDir={sortDir} onSort={sortBy} className="w-56" />
                <AccessSortHeader label="Work Email" column="email" sortKey={sortKey} sortDir={sortDir} onSort={sortBy} className="w-64" />
                <AccessSortHeader label="Designation" column="designation" sortKey={sortKey} sortDir={sortDir} onSort={sortBy} className="w-52" />
                <AccessSortHeader label="On Floor Role" column="profile" sortKey={sortKey} sortDir={sortDir} onSort={sortBy} className="w-52" />
                <th className="relative w-64 whitespace-nowrap px-4 py-3 font-semibold text-xs text-blue-950/85 dark:text-blue-100/85">
                  Access role
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {isLoading ? (
                <tr>
                  <td colSpan={6} className="px-4 py-16 text-center text-sm text-muted-foreground">
                    <Loader2 className="mx-auto mb-2 h-5 w-5 animate-spin" />
                    Loading users...
                  </td>
                </tr>
              ) : pageRows.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-4 py-10 text-center text-sm text-muted-foreground">
                    {loadError ? `Could not load users: ${loadError}` : "No users match your filters"}
                  </td>
                </tr>
              ) : (
                pageRows.map((user) => {
                  const changed = user.accessRole !== user.initialAccessRole;
                  const options =
                    user.accessRole && !roleOptions.some((option) => option.value === user.accessRole)
                      ? [{ value: user.accessRole, label: user.accessRole }, ...roleOptions]
                      : roleOptions;
                  return (
                    <tr key={user.employeeCode || user.id} className="transition-colors hover:bg-accent/30">
                      <td className="whitespace-nowrap px-4 py-3.5 font-mono text-xs text-muted-foreground truncate" title={user.employeeCode}>
                        {user.employeeCode || "—"}
                      </td>
                      <td className="whitespace-nowrap px-4 py-3.5">
                        <div className="flex items-center gap-2.5 min-w-0">
                          <Avatar name={user.name} size={28} />
                          <span className="font-semibold truncate" title={user.name}>{user.name}</span>
                        </div>
                      </td>
                      <td className="whitespace-nowrap px-4 py-3.5 text-muted-foreground truncate" title={user.email}>
                        {user.email}
                      </td>
                      <td className="whitespace-nowrap px-4 py-3.5 text-muted-foreground truncate" title={user.designation}>
                        {user.designation || "—"}
                      </td>
                      <td className="whitespace-nowrap px-4 py-3.5 text-muted-foreground truncate" title={user.profileRole}>
                        {user.profileRole || "—"}
                      </td>
                      <td className="px-4 py-2.5">
                        <SearchableSelect
                          placeholder={user.id ? "Select access role" : "No login account"}
                          searchPlaceholder="Search roles..."
                          options={options}
                          value={user.accessRole}
                          onChange={(value) => changeRole(user.id, value)}
                          disabled={!user.id || !canManageRoles}
                          clearable={false}
                          className="w-full text-xs"
                          buttonClassName={cn(
                            "h-8 text-xs transition-all",
                            changed
                              ? "border-blue-500 font-medium text-foreground bg-blue-500/5"
                              : "border-input text-foreground",
                          )}
                        />
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>

        <div className="sticky bottom-0 z-20 flex flex-col sm:flex-row items-center justify-between gap-3 border-t border-slate-300 dark:border-slate-700 bg-blue-50/80 dark:bg-blue-950/45 backdrop-blur-md px-4 py-3 text-xs text-blue-950/80 dark:text-blue-100/80 shadow-xs">
          <div className="flex items-center gap-3">
            <span>
              Showing <strong className="font-semibold text-blue-950 dark:text-blue-100">{pageRange.from}</strong> - <strong className="font-semibold text-blue-950 dark:text-blue-100">{pageRange.to}</strong>{" "}
              of <strong className="font-semibold text-blue-950 dark:text-blue-100">{filtered.length}</strong> users
            </span>
            <span className="text-slate-300 dark:text-slate-600">|</span>
            <div className="flex items-center gap-1.5">
              <span>Per page:</span>
              <RowsPerPageSelect
                value={pageSize}
                onChange={setPageSize}
                className="h-7 min-w-[3.25rem] rounded-md border border-slate-300 dark:border-slate-600 bg-white/90 dark:bg-blue-950/60 pl-2 pr-5 text-xs font-medium text-blue-950 dark:text-blue-100 outline-none cursor-pointer hover:bg-blue-100/50 dark:hover:bg-blue-900/40 transition-colors focus-visible:ring-1 focus-visible:ring-blue-500"
              />
            </div>
          </div>
          <div className="flex items-center gap-1.5">
            <button
              type="button"
              onClick={() => setPage((current) => Math.max(1, current - 1))}
              disabled={currentPage <= 1}
              className="inline-flex items-center gap-1 rounded-md border border-slate-300 dark:border-slate-600 bg-white/90 dark:bg-blue-900/50 px-2.5 py-1 text-xs font-medium text-blue-950 dark:text-blue-100 hover:bg-blue-100/60 dark:hover:bg-blue-800/60 disabled:opacity-40 disabled:pointer-events-none shadow-2xs transition-colors"
            >
              <ChevronLeft className="h-3.5 w-3.5" /> Previous
            </button>
            <span className="px-2 tabular-nums font-semibold text-blue-950 dark:text-blue-100">
              {currentPage} / {totalPages}
            </span>
            <button
              type="button"
              onClick={() => setPage((current) => Math.min(totalPages, current + 1))}
              disabled={currentPage >= totalPages}
              className="inline-flex items-center gap-1 rounded-md border border-slate-300 dark:border-slate-600 bg-white/90 dark:bg-blue-900/50 px-2.5 py-1 text-xs font-medium text-blue-950 dark:text-blue-100 hover:bg-blue-100/60 dark:hover:bg-blue-800/60 disabled:opacity-40 disabled:pointer-events-none shadow-2xs transition-colors"
            >
              Next <ChevronRight className="h-3.5 w-3.5" />
            </button>
          </div>
        </div>
      </div>
    </>
  );
}

function AccessSortHeader({
  label,
  column,
  sortKey,
  sortDir,
  onSort,
  className,
}: {
  label: string;
  column: AccessSortKey;
  sortKey: AccessSortKey;
  sortDir: SortDir;
  onSort: (column: AccessSortKey) => void;
  className?: string;
}) {
  const active = sortKey === column;
  return (
    <th className={cn("relative whitespace-nowrap px-4 py-3 font-semibold", className)}>
      <button
        type="button"
        onClick={() => onSort(column)}
        className={cn(
          "group inline-flex items-center gap-1.5 text-left text-xs font-semibold transition-colors select-none",
          active
            ? "text-blue-600 dark:text-blue-400 font-bold"
            : "text-blue-950/85 hover:text-blue-600 dark:text-blue-100/85 dark:hover:text-blue-300",
        )}
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
          {active && sortDir === "desc" ? <ChevronDown className="h-3.5 w-3.5" /> : <ChevronUp className="h-3.5 w-3.5" />}
        </span>
      </button>
      <span className="absolute right-0 top-2.5 bottom-2.5 w-[1.5px] bg-slate-400/80 dark:bg-slate-500 pointer-events-none" aria-hidden="true" />
    </th>
  );
}

interface RbacNode {
  level: string;
  name: string;
  permissionId?: string | null;
  canView?: number | null;
  canManage?: number | null;
  children: RbacNode[];
}

interface RbacMatrix {
  roleId: string;
  roleName: string;
  nodes: RbacNode[];
}

function cloneNodes(nodes: RbacNode[]): RbacNode[] {
  return nodes.map((node) => ({ ...node, children: cloneNodes(node.children ?? []) }));
}

function updateNode(nodes: RbacNode[], permissionId: string, patch: Partial<RbacNode>): RbacNode[] {
  return nodes.map((node) => {
    if (node.permissionId === permissionId) return { ...node, ...patch, children: node.children };
    return { ...node, children: updateNode(node.children ?? [], permissionId, patch) };
  });
}

function collectGrants(nodes: RbacNode[], into: { id: string; canView: number; canManage: number }[]) {
  for (const node of nodes) {
    if (node.permissionId) {
      into.push({
        id: node.permissionId,
        canView: node.canView === 1 ? 1 : 0,
        canManage: node.canView === 1 && node.canManage === 1 ? 1 : 0,
      });
    }
    collectGrants(node.children ?? [], into);
  }
}

interface RbacRoleOption {
  id: string;
  name: string;
  displayName: string;
}

function ModuleAccessTab({ canManageRoles = true }: { canManageRoles?: boolean }) {
  const [roles, setRoles] = useState<RbacRoleOption[]>([]);
  const [selectedRole, setSelectedRole] = useState("");
  const [openModules, setOpenModules] = useState<Record<string, boolean>>({});
  const [nodes, setNodes] = useState<RbacNode[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [isResetting, setIsResetting] = useState(false);

  const load = (roleName: string) => {
    if (!roleName) return;
    setIsLoading(true);
    apiFetch<RbacMatrix>(`/api/v1/rbac/matrix?roleName=${encodeURIComponent(roleName)}`)
      .then((matrix) => setNodes(cloneNodes(matrix.nodes ?? [])))
      .catch((error: Error) => toast.error(error.message || "Could not load the access matrix."))
      .finally(() => setIsLoading(false));
  };

  useEffect(() => {
    apiFetch<RbacRoleOption[]>("/api/v1/rbac/roles")
      .then((list) => {
        const next = list ?? [];
        setRoles(next);
        setSelectedRole((current) => current || next[0]?.name || "");
      })
      .catch((error: Error) => toast.error(error.message || "Could not load roles."));
  }, []);

  useEffect(() => {
    if (selectedRole) load(selectedRole);
  }, [selectedRole]);

  const setFlag = (permissionId: string, field: "canView" | "canManage", on: boolean) => {
    if (!canManageRoles) return;
    setNodes((current) => {
      const node = findNode(current, permissionId);
      if (!node) return current;
      const canView = field === "canView" ? (on ? 1 : 0) : node.canView === 1 || on ? 1 : 0;
      const canManage = field === "canManage" ? (on ? 1 : 0) : on ? node.canManage ?? 0 : 0;
      return updateNode(current, permissionId, {
        canView: field === "canView" && !on ? 0 : canView,
        canManage: field === "canView" && !on ? 0 : canManage,
      });
    });
  };

  const selectedLabel = roles.find((role) => role.name === selectedRole)?.displayName || selectedRole;
  const rows = visibleAccessRows(nodes, openModules);

  return (
    <>
      {!canManageRoles && (
        <div className="mb-4 rounded-xl border border-blue-500/20 bg-blue-500/10 p-3 text-xs text-blue-600 dark:text-blue-400 flex items-center gap-2.5">
          <ShieldAlert className="h-4 w-4 shrink-0" />
          <span>You have View Only access to Roles & Permissions. Editing access requires manage permission.</span>
        </div>
      )}

      <div className="mb-4 rounded-xl border border-border bg-card p-3.5 shadow-xs">
        <div className="flex flex-col gap-2.5 md:flex-row md:items-center">
          <div className="w-full md:w-72 shrink-0">
            <SearchableSelect
              placeholder="Select role"
              searchPlaceholder="Search roles..."
              options={roles.map((role) => ({
                value: role.name,
                label: role.displayName || role.name,
              }))}
              value={selectedRole}
              onChange={setSelectedRole}
              clearable={false}
              className="w-full text-xs"
              buttonClassName={cn(
                "h-9 text-xs transition-all",
                selectedRole
                  ? "border-blue-500/50 font-medium text-foreground bg-blue-500/5"
                  : "border-input text-muted-foreground",
              )}
            />
          </div>
          {canManageRoles && (
            <button
              type="button"
              onClick={async () => {
                if (!selectedRole) return;
                setIsResetting(true);
                try {
                  await apiFetch("/api/v1/rbac/matrix/reset", {
                    method: "POST",
                    body: JSON.stringify({ roleName: selectedRole }),
                  });
                  load(selectedRole);
                  toast.success("Reset to baseline", { description: selectedLabel });
                } catch (error) {
                  toast.error(error instanceof Error ? error.message : "Could not reset this role.");
                } finally {
                  setIsResetting(false);
                }
              }}
              disabled={!selectedRole || isResetting || isLoading}
              className="inline-flex h-9 items-center justify-center gap-1.5 rounded-md border border-border bg-card px-3 text-xs font-medium text-muted-foreground hover:bg-muted hover:text-foreground transition-colors disabled:opacity-50 cursor-pointer"
            >
              {isResetting ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : <RotateCcw className="h-3.5 w-3.5" />}
              Reset to Baseline
            </button>
          )}
          {canManageRoles && (
            <button
              type="button"
              onClick={async () => {
                setIsSaving(true);
                const items: { id: string; canView: number; canManage: number }[] = [];
                collectGrants(nodes, items);
                try {
                  await apiFetch("/api/v1/rbac/matrix", {
                    method: "PUT",
                    body: JSON.stringify({ roleName: selectedRole, items }),
                  });
                  toast.success("Permissions saved", { description: selectedLabel });
                } catch (error) {
                  toast.error(error instanceof Error ? error.message : "Could not save permissions.");
                } finally {
                  setIsSaving(false);
                }
              }}
              disabled={isSaving || isLoading || !selectedRole}
              className="md:ml-auto inline-flex h-9 items-center justify-center gap-2 rounded-md bg-primary px-4 text-sm font-medium text-primary-foreground hover:bg-primary/90 shadow-sm transition-all cursor-pointer disabled:opacity-50"
            >
              {isSaving ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
              Save Permissions
            </button>
          )}
        </div>
      </div>

      <div className="overflow-hidden rounded-xl border border-border bg-card shadow-sm">
        <div className="max-h-[calc(100vh-250px)] min-h-[420px] overflow-auto">
          <table className="w-full min-w-[720px] text-sm">
            <thead className="sticky top-0 z-10 border-b border-slate-300 bg-blue-50/80 text-left text-xs text-blue-950/85 shadow-2xs backdrop-blur-md dark:border-slate-700 dark:bg-blue-950/45 dark:text-blue-100/85">
              <tr>
                <th className="px-4 py-3 font-semibold">Access</th>
                <th className="w-36 px-4 py-3 font-semibold">Level</th>
                <th className="w-28 px-4 py-3 text-center font-semibold">View</th>
                <th className="w-28 px-4 py-3 text-center font-semibold">Manage</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {isLoading ? (
                <tr>
                  <td colSpan={4} className="px-4 py-16 text-center text-sm text-muted-foreground">
                    <Loader2 className="mx-auto mb-2 h-5 w-5 animate-spin" />
                    Loading access…
                  </td>
                </tr>
              ) : rows.length === 0 ? (
                <tr>
                  <td colSpan={4} className="px-4 py-16 text-center text-sm text-muted-foreground">
                    No access rows for this role.
                  </td>
                </tr>
              ) : (
                rows.map((row) => {
                  const expanded = openModules[row.key] === true;
                  return (
                    <AccessRow
                      key={row.key}
                      row={row}
                      canManageRoles={canManageRoles}
                      open={Boolean(row.node.children?.length) && expanded}
                      onToggle={() =>
                        setOpenModules((current) => ({
                          ...current,
                          [row.key]: !current[row.key],
                        }))
                      }
                      onFlag={setFlag}
                    />
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>
    </>
  );
}

function visibleAccessRows(nodes: RbacNode[], open: Record<string, boolean>, depth = 0, parentKey = ""): AccessRowModel[] {
  const rows: AccessRowModel[] = [];
  for (const node of nodes) {
    const key = `${parentKey}/${node.level}:${node.name}`;
    rows.push({ node, depth, key });
    const expanded = open[key] === true;
    if (expanded && node.children?.length) rows.push(...visibleAccessRows(node.children, open, depth + 1, key));
  }
  return rows;
}

interface AccessRowModel {
  node: RbacNode;
  depth: number;
  key: string;
}

const LEVEL_LABEL: Record<string, string> = {
  module: "Module",
  submodule: "Submodule",
  "sub-submodule": "Sub-submodule",
  widget: "Widget",
  tab: "Tab",
};

function findNode(nodes: RbacNode[], permissionId: string): RbacNode | null {
  for (const node of nodes) {
    if (node.permissionId === permissionId) return node;
    const child = findNode(node.children ?? [], permissionId);
    if (child) return child;
  }
  return null;
}

function AccessRow({
  row,
  canManageRoles = true,
  open,
  onToggle,
  onFlag,
}: {
  row: AccessRowModel;
  canManageRoles?: boolean;
  open: boolean;
  onToggle: () => void;
  onFlag: (permissionId: string, field: "canView" | "canManage", on: boolean) => void;
}) {
  const { node, depth } = row;
  const hasChildren = (node.children?.length ?? 0) > 0;
  const viewOn = node.canView === 1;
  const manageOn = viewOn && node.canManage === 1;
  return (
    <tr className={cn("transition-colors hover:bg-accent/30", depth === 0 && "bg-muted/30")}>
      <td className="px-4 py-3">
        <div className="flex items-center gap-2" style={{ paddingLeft: depth * 20 }}>
          {hasChildren ? (
            <button type="button" onClick={onToggle} className="rounded-md p-0.5 text-muted-foreground hover:bg-accent hover:text-foreground" aria-label={open ? "Collapse" : "Expand"}>
              <ChevronDown className={cn("h-4 w-4 transition-transform", !open && "-rotate-90")} />
            </button>
          ) : (
            <span className="inline-block w-5" />
          )}
          <span className={cn("truncate", depth === 0 ? "font-semibold" : "font-medium")}>{node.name}</span>
        </div>
      </td>
      <td className="px-4 py-3">
        <span className="inline-flex items-center rounded-full border border-border bg-muted px-2 py-0.5 text-[11px] font-medium text-muted-foreground">
          {LEVEL_LABEL[node.level] ?? node.level}
        </span>
      </td>
      <td className="px-4 py-3 text-center">
        <AccessCheck
          checked={viewOn}
          disabled={!canManageRoles || !node.permissionId}
          onChange={(on) => node.permissionId && onFlag(node.permissionId, "canView", on)}
          label={`View ${node.name}`}
        />
      </td>
      <td className="px-4 py-3 text-center">
        <AccessCheck
          checked={manageOn}
          disabled={!canManageRoles || !node.permissionId}
          onChange={(on) => node.permissionId && onFlag(node.permissionId, "canManage", on)}
          label={`Manage ${node.name}`}
        />
      </td>
    </tr>
  );
}

function AccessCheck({
  checked,
  disabled,
  onChange,
  label,
}: {
  checked: boolean;
  disabled?: boolean;
  onChange: (on: boolean) => void;
  label: string;
}) {
  return (
    <input
      type="checkbox"
      aria-label={label}
      checked={checked}
      disabled={disabled}
      onChange={(event) => onChange(event.target.checked)}
      className="h-4 w-4 cursor-pointer rounded border-2 border-input accent-primary disabled:cursor-not-allowed"
    />
  );
}
