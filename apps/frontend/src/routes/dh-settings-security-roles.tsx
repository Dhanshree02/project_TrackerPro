import { createFileRoute, Link, Navigate } from "@tanstack/react-router";
import { useEffect, useMemo, useState } from "react";
import {
  Search,
  ChevronRight,
  Save,
  Pencil,
  Copy,
  RotateCcw,
  Plus,
  Shield,
  ChevronDown,
  CheckSquare,
  Square,
  X,
  Users,
  History,
} from "lucide-react";
import { toast } from "sonner";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { usePermissions } from "@/lib/permissions";
import {
  fetchRoles,
  fetchUsers,
  updateRolePermissions,
  updateUser,
  updateRole,
  createRole,
  cloneRole,
  resetRolePermissions,
  fetchPermissionCatalog,
  fetchPermissionAudits,
  type ApiRole,
  type ApiUser,
  type ApiPermissionModule,
  type ApiPermissionSubmodule,
  type ApiPermissionAction,
  type ApiPermissionAudit,
} from "@/lib/api/users";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/dh-settings-security-roles")({
  head: () => ({
    meta: [
      { title: "Role & Access Management — Settings — Pulse PMO" },
      {
        name: "description",
        content: "Manage roles, module permissions and user role assignments.",
      },
    ],
  }),
  component: SecurityRolesPage,
});

// ─── Page ────────────────────────────────────────────────────────────────────

type Tab = "roles" | "users" | "audit";

function SecurityRolesPage() {
  const { isDhanshree } = useRoleContext();
  const { hasPermission, hasAny } = usePermissions();
  const [activeTab, setActiveTab] = useState<Tab>("roles");

  // Only administrators (or roles granted the settings permission) may enter.
  const canManage = isDhanshree || hasAny("settings.view", "users:manage", "roles:manage");
  if (!canManage) return <Navigate to="/" />;

  const tabs: { key: Tab; label: string; icon: typeof Shield }[] = [
    { key: "roles", label: "Role & Access Management", icon: Shield },
    { key: "users", label: "User Role Assignment", icon: Users },
    { key: "audit", label: "Audit Log", icon: History },
  ];

  return (
    <AppShell
      title="Role & Access Management"
      subtitle="Roles, module permissions and user assignments"
    >
      {/* Breadcrumb */}
      <nav
        className="mb-5 flex items-center gap-1.5 text-xs text-muted-foreground"
        aria-label="Breadcrumb"
      >
        <Link to="/dh-settings" className="hover:text-foreground transition-colors">
          Settings
        </Link>
        <ChevronRight className="h-3 w-3" />
        <span className="font-medium text-foreground">Role &amp; Access Management</span>
      </nav>

      {/* Tabs */}
      <div className="mb-5 flex items-center gap-1 border-b border-border overflow-x-auto">
        {tabs.map((t) => (
          <button
            key={t.key}
            id={`tab-${t.key}`}
            onClick={() => setActiveTab(t.key)}
            className={cn(
              "relative inline-flex items-center gap-1.5 whitespace-nowrap px-4 py-2.5 text-sm font-medium transition-colors",
              activeTab === t.key ? "text-primary" : "text-muted-foreground hover:text-foreground",
            )}
          >
            <t.icon className="h-3.5 w-3.5" />
            {t.label}
            {activeTab === t.key && (
              <span className="absolute inset-x-0 -bottom-px h-0.5 rounded-full bg-primary" />
            )}
          </button>
        ))}
      </div>

      {activeTab === "roles" && <RoleAccessTab />}
      {activeTab === "users" && <UserRoleAssignmentTab />}
      {activeTab === "audit" && <AuditLogTab />}
    </AppShell>
  );
}

// ─── Permission matrix helpers ───────────────────────────────────────────────

type MatrixState = Record<string, boolean>; // keyed by full dot key, e.g. "projects.team.assign"

const leafKey = (m: ApiPermissionModule, s: ApiPermissionSubmodule, a: ApiPermissionAction) =>
  s.key ? `${m.key}.${s.key}.${a.key}` : `${m.key}.${a.key}`;

function buildMatrix(role: ApiRole | undefined, catalog: ApiPermissionModule[]): MatrixState {
  const out: MatrixState = {};
  if (!role || catalog.length === 0) return out;
  const perms = new Set(role.permissions);
  for (const m of catalog) {
    for (const s of m.submodules) {
      for (const a of s.actions) {
        const full = leafKey(m, s, a);
        out[full] = perms.has(full) || a.legacyKeys.some((k) => perms.has(k));
      }
    }
  }
  return out;
}

/** Rebuilds the role's permission set from the matrix, preserving unknown keys. */
function computePermissionKeys(
  matrix: MatrixState,
  catalog: ApiPermissionModule[],
  current: string[],
): string[] {
  const catalogueKeys = new Set<string>();
  for (const m of catalog) {
    for (const s of m.submodules) {
      for (const a of s.actions) {
        const full = leafKey(m, s, a);
        if (matrix[full]) {
          catalogueKeys.add(full);
          a.legacyKeys.forEach((k) => catalogueKeys.add(k));
        }
      }
    }
  }
  // Preserve keys outside the catalogue (custom/unknown permissions).
  const preserved = current.filter((k) => !catalogueKeys.has(k));
  return [...preserved, ...[...catalogueKeys].sort()];
}

// ─── Tab 1: Role & Access Management ─────────────────────────────────────────

function RoleAccessTab() {
  const [roles, setRoles] = useState<ApiRole[]>([]);
  const [catalog, setCatalog] = useState<ApiPermissionModule[]>([]);
  const [selectedId, setSelectedId] = useState<string>("");
  const [matrix, setMatrix] = useState<MatrixState>({});
  const [expanded, setExpanded] = useState<Record<string, boolean>>({});
  const [saving, setSaving] = useState(false);
  const [loading, setLoading] = useState(true);
  const [editOpen, setEditOpen] = useState(false);
  const [cloneOpen, setCloneOpen] = useState(false);
  const [createOpen, setCreateOpen] = useState(false);

  const load = async (keepSelection?: string) => {
    setLoading(true);
    try {
      const [r, c] = await Promise.all([fetchRoles(), fetchPermissionCatalog()]);
      setRoles(r);
      setCatalog(c);
      setSelectedId((prev) => {
        const id = keepSelection ?? prev;
        return r.some((x) => x.id === id) ? id : (r[0]?.id ?? "");
      });
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to load roles");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, []);

  const selected = roles.find((r) => r.id === selectedId) ?? null;

  // Rebuild the matrix whenever the selected role changes.
  useEffect(() => {
    setMatrix(buildMatrix(selected ?? undefined, catalog));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selected?.id, selected?.permissions]);

  const toggleLeaf = (key: string) => setMatrix((prev) => ({ ...prev, [key]: !prev[key] }));

  const toggleModule = (m: ApiPermissionModule) => {
    setMatrix((prev) => {
      const keys = m.submodules.flatMap((s) => s.actions.map((a) => leafKey(m, s, a)));
      const anyOn = keys.some((k) => prev[k]);
      const next = { ...prev };
      keys.forEach((k) => (next[k] = !anyOn));
      return next;
    });
  };

  const selectAllModule = (m: ApiPermissionModule) => {
    setMatrix((prev) => {
      const next = { ...prev };
      m.submodules.forEach((s) => s.actions.forEach((a) => (next[leafKey(m, s, a)] = true)));
      return next;
    });
  };

  const clearAllModule = (m: ApiPermissionModule) => {
    setMatrix((prev) => {
      const next = { ...prev };
      m.submodules.forEach((s) => s.actions.forEach((a) => (next[leafKey(m, s, a)] = false)));
      return next;
    });
  };

  const moduleAllChecked = (m: ApiPermissionModule) => {
    const keys = m.submodules.flatMap((s) => s.actions.map((a) => leafKey(m, s, a)));
    return keys.length > 0 && keys.every((k) => matrix[k]);
  };

  const savePermissions = async () => {
    if (!selected) return;
    setSaving(true);
    try {
      const next = computePermissionKeys(matrix, catalog, selected.permissions);
      await updateRolePermissions(selected.id, next);
      toast.success("Permissions saved", {
        description: `Access for "${selected.displayName}" updated. Users re-login (or refresh) to pick up changes.`,
      });
      void load(selected.id);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to save permissions");
    } finally {
      setSaving(false);
    }
  };

  const resetBaseline = async () => {
    if (!selected) return;
    if (!window.confirm(`Reset "${selected.displayName}" to its baseline permission matrix?`))
      return;
    try {
      await resetRolePermissions(selected.id);
      toast.success("Baseline restored", {
        description: `"${selected.displayName}" reset to the baseline matrix.`,
      });
      void load(selected.id);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to reset role");
    }
  };

  const moduleCount = (m: ApiPermissionModule) => {
    const keys = m.submodules.flatMap((s) => s.actions.map((a) => leafKey(m, s, a)));
    return `${keys.filter((k) => matrix[k]).length}/${keys.length}`;
  };

  return (
    <div className="grid gap-5 lg:grid-cols-[260px_1fr]">
      {/* Left panel: roles */}
      <aside className="rounded-xl border border-border bg-card shadow-sm">
        <div className="flex items-center justify-between border-b border-border px-4 py-3">
          <h2 className="text-sm font-semibold">Roles</h2>
          <button
            id="btn-create-role"
            onClick={() => setCreateOpen(true)}
            title="Create role"
            className="inline-flex h-7 w-7 items-center justify-center rounded-md border border-border text-muted-foreground hover:bg-accent hover:text-foreground"
          >
            <Plus className="h-3.5 w-3.5" />
          </button>
        </div>
        <div className="max-h-[70vh] overflow-y-auto p-2">
          {roles.map((r) => (
            <button
              key={r.id}
              onClick={() => setSelectedId(r.id)}
              className={cn(
                "flex w-full items-center justify-between gap-2 rounded-md px-3 py-2 text-left text-sm transition-colors",
                selectedId === r.id
                  ? "bg-primary/10 font-medium text-primary"
                  : "text-foreground/80 hover:bg-accent",
              )}
            >
              <span className="min-w-0 truncate">{r.displayName}</span>
              {!r.isActive && (
                <span className="rounded-full bg-muted px-1.5 py-0.5 text-[9px] font-semibold text-muted-foreground">
                  off
                </span>
              )}
            </button>
          ))}
          {loading && (
            <p className="px-3 py-6 text-center text-xs text-muted-foreground">Loading roles…</p>
          )}
        </div>
      </aside>

      {/* Right panel: permission matrix */}
      <section className="min-w-0 rounded-xl border border-border bg-card shadow-sm">
        {selected ? (
          <>
            <header className="flex flex-wrap items-center gap-3 border-b border-border px-4 py-3">
              <div className="min-w-0">
                <h2 className="text-sm font-semibold">
                  Role: <span className="text-primary">{selected.displayName}</span>
                </h2>
                <p className="mt-0.5 text-xs text-muted-foreground">
                  {selected.userCount} user{selected.userCount === 1 ? "" : "s"} ·{" "}
                  {selected.permissions.length} permission
                  {selected.permissions.length === 1 ? "" : "s"}
                  {selected.isSystemRole && (
                    <span className="ml-2 rounded-full bg-muted px-2 py-0.5 text-[10px] font-medium text-muted-foreground">
                      system role
                    </span>
                  )}
                </p>
              </div>
              <div className="ml-auto flex flex-wrap items-center gap-2">
                <button
                  id="btn-edit-role"
                  onClick={() => setEditOpen(true)}
                  className="inline-flex items-center gap-1.5 rounded-md border border-input bg-card px-3 py-1.5 text-xs font-medium hover:bg-accent"
                >
                  <Pencil className="h-3.5 w-3.5" /> Edit Role
                </button>
                <button
                  id="btn-clone-role"
                  onClick={() => setCloneOpen(true)}
                  className="inline-flex items-center gap-1.5 rounded-md border border-input bg-card px-3 py-1.5 text-xs font-medium hover:bg-accent"
                >
                  <Copy className="h-3.5 w-3.5" /> Clone Permissions
                </button>
                <button
                  id="btn-reset-role"
                  onClick={() => void resetBaseline()}
                  className="inline-flex items-center gap-1.5 rounded-md border border-input bg-card px-3 py-1.5 text-xs font-medium hover:bg-accent"
                >
                  <RotateCcw className="h-3.5 w-3.5" /> Reset
                </button>
                <button
                  id="btn-save-permissions"
                  onClick={() => void savePermissions()}
                  disabled={saving}
                  className="inline-flex items-center gap-1.5 rounded-md bg-primary px-4 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
                >
                  <Save className="h-3.5 w-3.5" />
                  {saving ? "Saving…" : "Save Changes"}
                </button>
              </div>
            </header>

            <div className="divide-y divide-border">
              {catalog.map((m) => {
                const isOpen = expanded[m.key] ?? m.key === "dashboard";
                const anyOn = m.submodules.some((s) =>
                  s.actions.some((a) => matrix[leafKey(m, s, a)]),
                );
                const allOn = moduleAllChecked(m);
                return (
                  <div key={m.key}>
                    {/* Module row */}
                    <div className="flex items-center gap-3 px-4 py-2.5 hover:bg-accent/30">
                      <button
                        onClick={() => setExpanded((prev) => ({ ...prev, [m.key]: !prev[m.key] }))}
                        className="inline-flex items-center gap-1.5 text-sm font-medium"
                      >
                        <ChevronDown
                          className={cn(
                            "h-4 w-4 text-muted-foreground transition-transform",
                            isOpen && "rotate-180",
                          )}
                        />
                        {m.label}
                      </button>
                      <span
                        className={cn("text-xs", anyOn ? "text-success" : "text-muted-foreground")}
                      >
                        {anyOn ? "✓ Access" : "No access"} · {moduleCount(m)}
                      </span>
                      <div className="ml-auto flex items-center gap-1.5">
                        <button
                          onClick={() => selectAllModule(m)}
                          className="inline-flex items-center gap-1 rounded-md px-2 py-1 text-[11px] font-medium text-muted-foreground hover:bg-accent hover:text-foreground"
                        >
                          {allOn ? (
                            <CheckSquare className="h-3.5 w-3.5" />
                          ) : (
                            <Square className="h-3.5 w-3.5" />
                          )}
                          Select All
                        </button>
                        <button
                          onClick={() => clearAllModule(m)}
                          className="rounded-md px-2 py-1 text-[11px] font-medium text-muted-foreground hover:bg-accent hover:text-foreground"
                        >
                          Clear All
                        </button>
                      </div>
                    </div>

                    {/* Expanded submodules */}
                    {isOpen && (
                      <div className="space-y-1 bg-muted/20 px-4 py-3 pl-10">
                        {m.submodules.map((s) => (
                          <div
                            key={s.key ?? `${m.key}-root`}
                            className="rounded-lg border border-border/60 bg-card p-2.5"
                          >
                            <div className="mb-1.5 text-xs font-semibold text-muted-foreground">
                              {s.label}
                              <span className="ml-2 font-normal text-muted-foreground/60">
                                {s.actions.filter((a) => matrix[leafKey(m, s, a)]).length}/
                                {s.actions.length} enabled
                              </span>
                            </div>
                            <div className="flex flex-wrap gap-x-4 gap-y-1.5">
                              {s.actions.map((a) => {
                                const key = leafKey(m, s, a);
                                const on = !!matrix[key];
                                return (
                                  <label
                                    key={key}
                                    className="inline-flex cursor-pointer items-center gap-1.5 text-xs"
                                  >
                                    <input
                                      type="checkbox"
                                      checked={on}
                                      onChange={() => toggleLeaf(key)}
                                      className="h-3.5 w-3.5 rounded border-2 border-input bg-card text-primary accent-primary focus:ring-2 focus:ring-ring cursor-pointer"
                                    />
                                    <span
                                      className={
                                        on ? "font-medium text-foreground" : "text-muted-foreground"
                                      }
                                    >
                                      {a.label}
                                    </span>
                                  </label>
                                );
                              })}
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          </>
        ) : (
          <p className="p-10 text-center text-sm text-muted-foreground">
            Select a role to view its permissions.
          </p>
        )}
      </section>

      {editOpen && selected && (
        <EditRoleModal
          role={selected}
          onClose={() => setEditOpen(false)}
          onSaved={() => void load(selected.id)}
        />
      )}
      {cloneOpen && selected && (
        <CloneRoleModal
          role={selected}
          onClose={() => setCloneOpen(false)}
          onSaved={() => void load()}
        />
      )}
      {createOpen && (
        <CreateRoleModal
          roles={roles}
          onClose={() => setCreateOpen(false)}
          onSaved={() => void load()}
        />
      )}
    </div>
  );
}

// ─── Edit Role modal ─────────────────────────────────────────────────────────

function EditRoleModal({
  role,
  onClose,
  onSaved,
}: {
  role: ApiRole;
  onClose: () => void;
  onSaved: () => void;
}) {
  const [displayName, setDisplayName] = useState(role.displayName);
  const [description, setDescription] = useState(role.description ?? "");
  const [isActive, setIsActive] = useState(role.isActive);
  const [saving, setSaving] = useState(false);

  const save = async () => {
    if (!displayName.trim()) {
      toast.error("Display name is required");
      return;
    }
    setSaving(true);
    try {
      await updateRole(role.id, {
        displayName: displayName.trim(),
        description: description.trim() || undefined,
        isActive,
      });
      toast.success("Role updated");
      onSaved();
      onClose();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to update role");
    } finally {
      setSaving(false);
    }
  };

  return (
    <Modal title={`Edit Role — ${role.displayName}`} onClose={onClose}>
      <div className="space-y-4">
        <div>
          <label className="mb-1.5 block text-xs font-medium text-muted-foreground">
            Display Name
          </label>
          <input
            value={displayName}
            onChange={(e) => setDisplayName(e.target.value)}
            className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
        </div>
        <div>
          <label className="mb-1.5 block text-xs font-medium text-muted-foreground">
            Description
          </label>
          <textarea
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            rows={3}
            className="w-full rounded-md border border-input bg-card px-3 py-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
        </div>
        <label className="flex items-center gap-2 text-sm">
          <input
            type="checkbox"
            checked={isActive}
            disabled={role.isSystemRole}
            onChange={(e) => setIsActive(e.target.checked)}
            className="h-4 w-4 rounded border-2 border-input accent-primary cursor-pointer disabled:opacity-50"
          />
          Active — assignable to users
          {role.isSystemRole && (
            <span className="text-[11px] text-muted-foreground">
              (system roles cannot be deactivated)
            </span>
          )}
        </label>
        <div className="flex justify-end gap-2 border-t border-border pt-4">
          <button
            onClick={onClose}
            className="rounded-md border border-input bg-card px-4 py-2 text-xs font-medium hover:bg-accent"
          >
            Cancel
          </button>
          <button
            onClick={() => void save()}
            disabled={saving}
            className="rounded-md bg-primary px-4 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
          >
            {saving ? "Saving…" : "Save"}
          </button>
        </div>
      </div>
    </Modal>
  );
}

// ─── Clone / Create role modal ───────────────────────────────────────────────

function CloneRoleModal({
  role,
  onClose,
  onSaved,
}: {
  role: ApiRole;
  onClose: () => void;
  onSaved: () => void;
}) {
  const [name, setName] = useState("");
  const [displayName, setDisplayName] = useState("");
  const [saving, setSaving] = useState(false);

  const save = async () => {
    if (!name.trim() || !displayName.trim()) {
      toast.error("Name and display name are required");
      return;
    }
    setSaving(true);
    try {
      await cloneRole(role.id, {
        name: name.trim(),
        displayName: displayName.trim(),
        description: `Cloned from ${role.displayName}`,
      });
      toast.success("Role cloned", {
        description: `"${displayName.trim()}" created with ${role.permissions.length} permissions.`,
      });
      onSaved();
      onClose();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to clone role");
    } finally {
      setSaving(false);
    }
  };

  return (
    <Modal title={`Clone Permissions — from ${role.displayName}`} onClose={onClose}>
      <p className="mb-4 text-xs text-muted-foreground">
        Creates a new custom role with an exact copy of "{role.displayName}"'s{" "}
        {role.permissions.length} permissions.
      </p>
      <div className="space-y-4">
        <div>
          <label className="mb-1.5 block text-xs font-medium text-muted-foreground">
            Role Key <span className="text-destructive">*</span>
          </label>
          <input
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="e.g. DeliveryLead"
            className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
        </div>
        <div>
          <label className="mb-1.5 block text-xs font-medium text-muted-foreground">
            Display Name <span className="text-destructive">*</span>
          </label>
          <input
            value={displayName}
            onChange={(e) => setDisplayName(e.target.value)}
            placeholder="e.g. Delivery Lead"
            className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
        </div>
        <div className="flex justify-end gap-2 border-t border-border pt-4">
          <button
            onClick={onClose}
            className="rounded-md border border-input bg-card px-4 py-2 text-xs font-medium hover:bg-accent"
          >
            Cancel
          </button>
          <button
            onClick={() => void save()}
            disabled={saving}
            className="rounded-md bg-primary px-4 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
          >
            {saving ? "Cloning…" : "Clone Role"}
          </button>
        </div>
      </div>
    </Modal>
  );
}

function CreateRoleModal({
  roles,
  onClose,
  onSaved,
}: {
  roles: ApiRole[];
  onClose: () => void;
  onSaved: () => void;
}) {
  const [name, setName] = useState("");
  const [displayName, setDisplayName] = useState("");
  const [description, setDescription] = useState("");
  const [cloneFrom, setCloneFrom] = useState("");
  const [saving, setSaving] = useState(false);

  const save = async () => {
    if (!name.trim() || !displayName.trim()) {
      toast.error("Name and display name are required");
      return;
    }
    setSaving(true);
    try {
      await createRole({
        name: name.trim(),
        displayName: displayName.trim(),
        description: description.trim() || undefined,
        cloneFromRoleId: cloneFrom || undefined,
      });
      toast.success("Role created");
      onSaved();
      onClose();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to create role");
    } finally {
      setSaving(false);
    }
  };

  return (
    <Modal title="Create Role" onClose={onClose}>
      <div className="space-y-4">
        <div>
          <label className="mb-1.5 block text-xs font-medium text-muted-foreground">
            Role Key <span className="text-destructive">*</span>
          </label>
          <input
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="e.g. DeliveryLead"
            className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
        </div>
        <div>
          <label className="mb-1.5 block text-xs font-medium text-muted-foreground">
            Display Name <span className="text-destructive">*</span>
          </label>
          <input
            value={displayName}
            onChange={(e) => setDisplayName(e.target.value)}
            placeholder="e.g. Delivery Lead"
            className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
        </div>
        <div>
          <label className="mb-1.5 block text-xs font-medium text-muted-foreground">
            Description
          </label>
          <input
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
        </div>
        <div>
          <label className="mb-1.5 block text-xs font-medium text-muted-foreground">
            Start from another role's permissions
          </label>
          <select
            value={cloneFrom}
            onChange={(e) => setCloneFrom(e.target.value)}
            className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          >
            <option value="">Start empty</option>
            {roles.map((r) => (
              <option key={r.id} value={r.id}>
                {r.displayName} ({r.permissions.length} permissions)
              </option>
            ))}
          </select>
        </div>
        <div className="flex justify-end gap-2 border-t border-border pt-4">
          <button
            onClick={onClose}
            className="rounded-md border border-input bg-card px-4 py-2 text-xs font-medium hover:bg-accent"
          >
            Cancel
          </button>
          <button
            onClick={() => void save()}
            disabled={saving}
            className="rounded-md bg-primary px-4 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
          >
            {saving ? "Creating…" : "Create Role"}
          </button>
        </div>
      </div>
    </Modal>
  );
}

// ─── Tab 2: User Role Assignment ─────────────────────────────────────────────

function UserRoleAssignmentTab() {
  const [q, setQ] = useState("");
  const [roleFilter, setRoleFilter] = useState<string>("all");
  const [users, setUsers] = useState<ApiUser[]>([]);
  const [roles, setRoles] = useState<ApiRole[]>([]);
  const [loading, setLoading] = useState(true);

  const load = async () => {
    setLoading(true);
    try {
      const [u, r] = await Promise.all([fetchUsers({ perPage: 100 }), fetchRoles()]);
      setUsers(u.items);
      setRoles(r.filter((x) => x.isActive));
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to load users");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, []);

  const roleLabel = (key: string | null | undefined) =>
    roles.find((r) => r.name === key)?.displayName ?? (key ? key : "—");

  const filtered = useMemo(() => {
    let list = users;
    if (roleFilter !== "all") list = list.filter((u) => u.role === roleFilter);
    if (q.trim()) {
      const term = q.toLowerCase();
      list = list.filter(
        (u) =>
          u.name.toLowerCase().includes(term) ||
          u.email.toLowerCase().includes(term) ||
          (u.employeeId ?? "").toLowerCase().includes(term),
      );
    }
    return list;
  }, [users, q, roleFilter]);

  const changeRole = async (id: string, newRole: string) => {
    const previous = users;
    setUsers((prev) => prev.map((u) => (u.id === id ? { ...u, role: newRole } : u)));
    try {
      await updateUser(id, { role: newRole });
      toast.success("Role updated", {
        description:
          "The user's sessions were revoked — they must sign in again to pick up the new permissions.",
      });
      void load();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to update role");
      setUsers(previous);
    }
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
            placeholder="Search user name, email or employee id…"
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
          {roles.map((r) => (
            <option key={r.id} value={r.name}>
              {r.displayName}
            </option>
          ))}
        </select>
        <span className="ml-auto text-xs text-muted-foreground">
          Changing a role revokes the user's sessions; they sign in again with the new permissions.
        </span>
      </div>

      {/* Table */}
      <div className="overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
        <table className="w-full text-sm">
          <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr>
              <th className="px-4 py-3 font-medium">Name</th>
              <th className="px-4 py-3 font-medium">Employee ID</th>
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
                        .split(/\s+/)
                        .filter(Boolean)
                        .slice(0, 2)
                        .map((w) => w[0]?.toUpperCase())
                        .join("") || "?"}
                    </span>
                    <div className="min-w-0">
                      <div className="font-medium">{u.name}</div>
                      <div className="truncate text-xs text-muted-foreground">{u.email}</div>
                    </div>
                  </div>
                </td>
                <td className="px-4 py-3 tabular-nums text-muted-foreground">{u.employeeId}</td>
                <td className="px-4 py-3">
                  <span className="inline-flex items-center rounded-full bg-muted px-2.5 py-0.5 text-[11px] font-medium text-muted-foreground">
                    {roleLabel(u.role)}
                  </span>
                </td>
                <td className="px-4 py-3">
                  <select
                    value={u.role ?? ""}
                    onChange={(e) => changeRole(u.id, e.target.value)}
                    className="h-8 rounded-md border border-input bg-card px-2 text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring"
                  >
                    {roles.map((r) => (
                      <option key={r.id} value={r.name}>
                        {r.displayName}
                      </option>
                    ))}
                  </select>
                </td>
              </tr>
            ))}
            {loading && (
              <tr>
                <td colSpan={4} className="px-4 py-10 text-center text-sm text-muted-foreground">
                  Loading users…
                </td>
              </tr>
            )}
            {!loading && filtered.length === 0 && (
              <tr>
                <td colSpan={4} className="px-4 py-10 text-center text-sm text-muted-foreground">
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

// ─── Tab 3: Audit Log ────────────────────────────────────────────────────────

function AuditLogTab() {
  const [entries, setEntries] = useState<ApiPermissionAudit[]>([]);
  const [roles, setRoles] = useState<ApiRole[]>([]);
  const [roleFilter, setRoleFilter] = useState<string>("all");
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);

  const load = async () => {
    setLoading(true);
    try {
      const [a, r] = await Promise.all([
        fetchPermissionAudits({
          perPage: 100,
          roleId: roleFilter !== "all" ? roleFilter : undefined,
        }),
        roles.length ? Promise.resolve(roles) : fetchRoles(),
      ]);
      setEntries(a.items);
      setTotal(a.total);
      if (r.length && roles.length === 0) setRoles(r);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to load audit log");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [roleFilter]);

  const roleName = (id: string) => roles.find((r) => r.id === id)?.displayName ?? id;

  return (
    <>
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <select
          value={roleFilter}
          onChange={(e) => setRoleFilter(e.target.value)}
          className="h-9 rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
        >
          <option value="all">All Roles</option>
          {roles.map((r) => (
            <option key={r.id} value={r.id}>
              {r.displayName}
            </option>
          ))}
        </select>
        <span className="ml-auto text-xs text-muted-foreground">
          {total} permission change{total === 1 ? "" : "s"} recorded
        </span>
      </div>

      <div className="overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
        <table className="w-full text-sm">
          <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr>
              <th className="px-4 py-3 font-medium">When</th>
              <th className="px-4 py-3 font-medium">Role</th>
              <th className="px-4 py-3 font-medium">Module / Submodule</th>
              <th className="px-4 py-3 font-medium">Permission</th>
              <th className="px-4 py-3 font-medium">Change</th>
              <th className="px-4 py-3 font-medium">Changed By</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {entries.map((a) => (
              <tr key={a.id} className="hover:bg-accent/30 transition-colors">
                <td className="px-4 py-3 whitespace-nowrap text-xs text-muted-foreground">
                  {new Date(a.createdAtUtc).toLocaleString()}
                </td>
                <td className="px-4 py-3 font-medium">{a.roleName}</td>
                <td className="px-4 py-3 text-xs">
                  {a.moduleLabel}
                  {a.submoduleLabel ? ` → ${a.submoduleLabel}` : ""}
                </td>
                <td className="px-4 py-3">
                  <code className="rounded bg-muted px-1.5 py-0.5 text-[11px]">
                    {a.permissionKey}
                  </code>
                  <span className="ml-1.5 text-xs text-muted-foreground">{a.actionLabel}</span>
                </td>
                <td className="px-4 py-3">
                  <span
                    className={cn(
                      "inline-flex items-center rounded-full px-2 py-0.5 text-[11px] font-semibold",
                      a.changeType === "granted"
                        ? "bg-success/10 text-success"
                        : "bg-destructive/10 text-destructive",
                    )}
                  >
                    {a.changeType === "granted" ? "Allowed" : "Denied"}
                  </span>
                  <span className="ml-1.5 text-[11px] text-muted-foreground">
                    {a.previousValue} → {a.newValue}
                  </span>
                </td>
                <td className="px-4 py-3 text-xs">{a.changedByName ?? roleName(a.roleId)}</td>
              </tr>
            ))}
            {loading && (
              <tr>
                <td colSpan={6} className="px-4 py-10 text-center text-sm text-muted-foreground">
                  Loading audit log…
                </td>
              </tr>
            )}
            {!loading && entries.length === 0 && (
              <tr>
                <td colSpan={6} className="px-4 py-10 text-center text-sm text-muted-foreground">
                  No permission changes recorded yet.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </>
  );
}

// ─── Shared modal shell ──────────────────────────────────────────────────────

function Modal({
  title,
  children,
  onClose,
}: {
  title: string;
  children: React.ReactNode;
  onClose: () => void;
}) {
  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4"
      onClick={onClose}
    >
      <div
        className="max-h-[90vh] w-full max-w-lg overflow-y-auto rounded-xl bg-card shadow-xl"
        onClick={(e) => e.stopPropagation()}
      >
        <header className="sticky top-0 z-10 flex items-center gap-3 border-b border-border bg-card px-5 py-4">
          <h2 className="flex-1 text-lg font-semibold">{title}</h2>
          <button onClick={onClose} className="rounded-md p-1.5 hover:bg-accent" aria-label="Close">
            <X className="h-5 w-5" />
          </button>
        </header>
        <div className="p-5">{children}</div>
      </div>
    </div>
  );
}
