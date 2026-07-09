import { createFileRoute } from "@tanstack/react-router";
import { useMemo, useRef, useState, useEffect } from "react";
import { Plus, Filter, Send, History, MessageSquare, Users, X, Search } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext, roleLabels } from "@/lib/role-context";
import {
  issueTypeLabels,
  getPerson,
  people,
  type Issue,
  type IssueType,
  type IssuePriority,
  type IssueStatus,
  type IssueRoleTarget,
  type IssueComment,
} from "@/lib/mock-data";
import { PriorityPill, IssueStatusPill, Avatar } from "@/components/pills";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/health")({
  head: () => ({
    meta: [
      { title: "Health & Governance — Pulse PMO" },
      { name: "description", content: "Issue escalation, threaded discussion, status tracking and audit history." },
    ],
  }),
  component: HealthPage,
});

const issueTypes: IssueType[] = ["scope_change", "resource_shortage", "delay", "escalation", "client_issue", "internal_blocker"];
const priorities: IssuePriority[] = ["low", "medium", "high", "critical"];
const targets: IssueRoleTarget[] = ["PM", "Senior PM", "EM", "PMO", "HOD"];
const statuses: IssueStatus[] = ["open", "in_progress", "resolved", "closed"];

function HealthPage() {
  const { user, role, assignedClients, assignedProjects, assignedIssues } = useRoleContext();

  const [issuesState, setIssuesState] = useState<Issue[]>(assignedIssues);
  const [statusFilter, setStatusFilter] = useState<IssueStatus | "all">("all");
  const [selectedId, setSelectedId] = useState<string | null>(assignedIssues[0]?.id ?? null);
  const [showForm, setShowForm] = useState(false);
  const [reply, setReply] = useState("");

  const filtered = useMemo(
    () => issuesState.filter((i) => statusFilter === "all" || i.status === statusFilter),
    [issuesState, statusFilter],
  );
  const selected = issuesState.find((i) => i.id === selectedId) ?? null;

  function postReply() {
    if (!selected || !reply.trim()) return;
    const c: IssueComment = {
      id: `c${Date.now()}`,
      authorId: user.id,
      text: reply.trim(),
      createdAt: new Date().toISOString(),
    };
    setIssuesState((prev) => prev.map((i) => i.id === selected.id ? {
      ...i,
      comments: [...i.comments, c],
      audit: [...i.audit, { id: `a${Date.now()}`, actorId: user.id, action: "Commented", at: c.createdAt }],
      updatedAt: c.createdAt,
    } : i));
    setReply("");
  }

  function changeStatus(s: IssueStatus) {
    if (!selected) return;
    setIssuesState((prev) => prev.map((i) => i.id === selected.id ? {
      ...i,
      status: s,
      audit: [...i.audit, { id: `a${Date.now()}`, actorId: user.id, action: `Status → ${s} · Notified ${i.taggedUserIds.length} tagged user(s)`, at: new Date().toISOString() }],
      updatedAt: new Date().toISOString(),
    } : i));
  }

  function updateTags(nextIds: string[]) {
    if (!selected) return;
    const prevIds = selected.taggedUserIds;
    const added = nextIds.filter((id) => !prevIds.includes(id));
    const removed = prevIds.filter((id) => !nextIds.includes(id));
    if (added.length === 0 && removed.length === 0) return;
    const parts: string[] = [];
    if (added.length) parts.push(`Tagged ${added.map((id) => getPerson(id).name).join(", ")}`);
    if (removed.length) parts.push(`Removed ${removed.map((id) => getPerson(id).name).join(", ")}`);
    setIssuesState((prev) => prev.map((i) => i.id === selected.id ? {
      ...i,
      taggedUserIds: nextIds,
      audit: [...i.audit, { id: `a${Date.now()}`, actorId: user.id, action: parts.join(" · "), at: new Date().toISOString() }],
      updatedAt: new Date().toISOString(),
    } : i));
  }

  return (
    <AppShell title="Health & Governance" subtitle="Issue escalation, governance and audit trail">
      <div className="mb-4 flex flex-wrap items-center gap-2">
        <div className="flex items-center gap-1 rounded-lg border border-border bg-card p-1 text-xs">
          <Filter className="ml-1 h-3.5 w-3.5 text-muted-foreground" />
          {(["all", ...statuses] as const).map((s) => (
            <button
              key={s}
              onClick={() => setStatusFilter(s)}
              className={cn(
                "rounded-md px-2.5 py-1 capitalize",
                statusFilter === s ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground",
              )}
            >
              {s === "all" ? "All" : s.replace("_", " ")}
            </button>
          ))}
        </div>
        <button
          onClick={() => setShowForm(true)}
          className="ml-auto inline-flex items-center gap-1.5 rounded-md bg-primary px-3 py-1.5 text-sm font-medium text-primary-foreground hover:bg-primary/90"
        >
          <Plus className="h-4 w-4" /> Raise issue
        </button>
      </div>

      <div className="grid gap-4 lg:grid-cols-[360px,1fr]">
        <aside className="rounded-xl border border-border bg-card shadow-sm">
          <ul className="max-h-[70vh] divide-y divide-border overflow-y-auto">
            {filtered.map((i) => {
              const proj = assignedProjects.find((p) => p.id === i.projectId);
              return (
                <li key={i.id}>
                  <button
                    onClick={() => setSelectedId(i.id)}
                    className={cn(
                      "w-full px-4 py-3 text-left transition-colors",
                      selectedId === i.id ? "bg-accent/60" : "hover:bg-accent/40",
                    )}
                  >
                    <div className="flex items-center justify-between gap-2">
                      <span className="text-xs font-medium text-muted-foreground">{issueTypeLabels[i.type]}</span>
                      <PriorityPill priority={i.priority} />
                    </div>
                    <p className="mt-1 line-clamp-2 text-sm">{i.description}</p>
                    <div className="mt-2 flex items-center justify-between">
                      <span className="text-[11px] text-muted-foreground">{proj?.name ?? "—"}</span>
                      <IssueStatusPill status={i.status} />
                    </div>
                  </button>
                </li>
              );
            })}
            {filtered.length === 0 && (
              <li className="px-4 py-10 text-center text-sm text-muted-foreground">No issues match this filter</li>
            )}
          </ul>
        </aside>

        <section className="rounded-xl border border-border bg-card shadow-sm">
          {selected ? (
            <IssueDetail
              issue={selected}
              projectName={assignedProjects.find((p) => p.id === selected.projectId)?.name ?? "—"}
              clientName={assignedClients.find((c) => c.id === selected.clientId)?.name ?? "—"}
              reply={reply}
              setReply={setReply}
              onPost={postReply}
              onStatusChange={changeStatus}
              onTagsChange={updateTags}
            />
          ) : (
            <div className="flex h-64 items-center justify-center text-sm text-muted-foreground">
              Select an issue to view discussion
            </div>
          )}
        </section>
      </div>

      {showForm && (
        <NewIssueDialog
          onClose={() => setShowForm(false)}
          onCreate={(draft) => {
            const id = `i${Date.now()}`;
            const now = new Date().toISOString();
            const newIssue: Issue = {
              id, ...draft,
              raisedById: user.id,
              raisedByRole: role === "senior_pm" ? "Senior PM" : "EM",
              status: "open",
              createdAt: now, updatedAt: now,
              comments: [],
              audit: [
                { id: `a${id}`, actorId: user.id, action: "Raised issue", at: now },
                ...(draft.taggedUserIds.length
                  ? [{ id: `a${id}t`, actorId: user.id, action: `Tagged ${draft.taggedUserIds.map((tid) => getPerson(tid).name).join(", ")} (notified)`, at: now }]
                  : []),
              ],
            };
            setIssuesState((p) => [newIssue, ...p]);
            setSelectedId(id);
            setShowForm(false);
          }}
        />
      )}

      <p className="mt-4 text-center text-xs text-muted-foreground">
        Logged in as <span className="font-medium text-foreground">{roleLabels[role]}</span> · Escalation flow: TL → PM → Senior PM / EM → PMO / HOD
      </p>
    </AppShell>
  );
}

function IssueDetail({
  issue, projectName, clientName, reply, setReply, onPost, onStatusChange, onTagsChange,
}: {
  issue: Issue; projectName: string; clientName: string;
  reply: string; setReply: (s: string) => void;
  onPost: () => void; onStatusChange: (s: IssueStatus) => void;
  onTagsChange: (ids: string[]) => void;
}) {
  const raiser = getPerson(issue.raisedById);
  const assignee = getPerson(issue.assignedToId);

  return (
    <div className="flex h-full flex-col">
      <header className="border-b border-border p-5">
        <div className="flex flex-wrap items-center gap-2">
          <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">{issueTypeLabels[issue.type]}</span>
          <PriorityPill priority={issue.priority} />
          <IssueStatusPill status={issue.status} />
          <div className="ml-auto flex items-center gap-1">
            {statuses.map((s) => (
              <button
                key={s}
                onClick={() => onStatusChange(s)}
                disabled={issue.status === s}
                className="rounded-md border border-input bg-card px-2 py-1 text-[11px] hover:bg-accent disabled:opacity-50 capitalize"
              >
                {s.replace("_", " ")}
              </button>
            ))}
          </div>
        </div>
        <h2 className="mt-2 text-lg font-semibold">{issue.description}</h2>
        <div className="mt-3 grid gap-3 text-xs sm:grid-cols-4">
          <Field label="Client" value={clientName} />
          <Field label="Project" value={projectName} />
          <Field label="Raised by" value={`${raiser.name} · ${issue.raisedByRole}`} />
          <Field label="Assigned to" value={`${assignee.name} · ${issue.assignedToRole}`} />
        </div>
        <div className="mt-3">
          <div className="mb-1.5 flex items-center gap-1.5 text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
            <Users className="h-3.5 w-3.5" /> Tagged people (CC) — receive updates on status & comments
          </div>
          <UserTagPicker
            value={issue.taggedUserIds}
            onChange={onTagsChange}
            excludeIds={[issue.raisedById, issue.assignedToId]}
          />
        </div>
      </header>

      <div className="flex flex-1 flex-col gap-4 p-5">
        <div>
          <h3 className="mb-2 flex items-center gap-1.5 text-sm font-semibold">
            <MessageSquare className="h-4 w-4" /> Discussion
          </h3>
          <ul className="space-y-3">
            {issue.comments.map((c) => {
              const a = getPerson(c.authorId);
              return (
                <li key={c.id} className="flex gap-3">
                  <Avatar name={a.name} />
                  <div className="flex-1 rounded-lg border border-border bg-accent/30 p-3">
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-semibold">{a.name} <span className="font-normal text-muted-foreground">· {a.role}</span></span>
                      <span className="text-[11px] text-muted-foreground">{new Date(c.createdAt).toLocaleString()}</span>
                    </div>
                    <p className="mt-1 text-sm">{c.text}</p>
                  </div>
                </li>
              );
            })}
            {issue.comments.length === 0 && (
              <li className="rounded-lg border border-dashed border-border p-4 text-center text-sm text-muted-foreground">
                No comments yet
              </li>
            )}
          </ul>
        </div>

        <div className="flex gap-2">
          <textarea
            value={reply}
            onChange={(e) => setReply(e.target.value)}
            rows={2}
            placeholder="Add a comment or update…"
            className="flex-1 resize-none rounded-md border border-input bg-card p-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
          <button
            onClick={onPost}
            disabled={!reply.trim()}
            className="inline-flex items-center gap-1 self-end rounded-md bg-primary px-3 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
          >
            <Send className="h-4 w-4" /> Post
          </button>
        </div>

        {issue.resolution && (
          <div className="rounded-lg border border-success/30 bg-success/10 p-3 text-sm text-success">
            <strong className="font-semibold">Resolution:</strong> {issue.resolution}
          </div>
        )}

        <div>
          <h3 className="mb-2 flex items-center gap-1.5 text-sm font-semibold">
            <History className="h-4 w-4" /> Audit history
          </h3>
          <ol className="relative ml-2 space-y-2 border-l border-border pl-4">
            {issue.audit.map((a) => {
              const p = getPerson(a.actorId);
              return (
                <li key={a.id} className="text-xs">
                  <span className="absolute -left-[5px] mt-1.5 h-2 w-2 rounded-full bg-primary" />
                  <span className="font-medium">{p.name}</span> · {a.action}
                  <span className="ml-2 text-muted-foreground">{new Date(a.at).toLocaleString()}</span>
                </li>
              );
            })}
          </ol>
        </div>
      </div>
    </div>
  );
}

function Field({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-md border border-border bg-muted/30 px-3 py-2">
      <div className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">{label}</div>
      <div className="mt-0.5 truncate text-sm">{value}</div>
    </div>
  );
}

function NewIssueDialog({
  onClose, onCreate,
}: {
  onClose: () => void;
  onCreate: (draft: Omit<Issue, "id" | "raisedById" | "raisedByRole" | "status" | "createdAt" | "updatedAt" | "comments" | "audit">) => void;
}) {
  const { assignedClients, assignedProjects } = useRoleContext();
  const [clientId, setClientId] = useState(assignedClients[0]?.id ?? "");
  const projsForClient = assignedProjects.filter((p) => p.clientId === clientId);
  const [projectId, setProjectId] = useState(projsForClient[0]?.id ?? "");
  const [type, setType] = useState<IssueType>("delay");
  const [priority, setPriority] = useState<IssuePriority>("medium");
  const [description, setDescription] = useState("");
  const [assignedToRole, setAssignedToRole] = useState<IssueRoleTarget>("PMO");
  const [taggedUserIds, setTaggedUserIds] = useState<string[]>([]);
  const assignedToId = "u11"; // PMO

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-foreground/40 p-4">
      <div className="w-full max-w-lg rounded-xl border border-border bg-card shadow-lg">
        <header className="flex items-center justify-between border-b border-border px-5 py-3">
          <h3 className="text-base font-semibold">Raise an issue</h3>
          <button onClick={onClose} className="text-sm text-muted-foreground hover:text-foreground">×</button>
        </header>
        <div className="grid gap-3 p-5 text-sm">
          <FormRow label="Client">
            <select value={clientId} onChange={(e) => { setClientId(e.target.value); const np = assignedProjects.find((p) => p.clientId === e.target.value); setProjectId(np?.id ?? ""); }} className="form-input">
              {assignedClients.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
            </select>
          </FormRow>
          <FormRow label="Project">
            <select value={projectId} onChange={(e) => setProjectId(e.target.value)} className="form-input">
              {projsForClient.map((p) => <option key={p.id} value={p.id}>{p.name}</option>)}
            </select>
          </FormRow>
          <div className="grid grid-cols-2 gap-3">
            <FormRow label="Issue type">
              <select value={type} onChange={(e) => setType(e.target.value as IssueType)} className="form-input">
                {issueTypes.map((t) => <option key={t} value={t}>{issueTypeLabels[t]}</option>)}
              </select>
            </FormRow>
            <FormRow label="Priority">
              <select value={priority} onChange={(e) => setPriority(e.target.value as IssuePriority)} className="form-input">
                {priorities.map((p) => <option key={p} value={p} className="capitalize">{p}</option>)}
              </select>
            </FormRow>
          </div>
          <FormRow label="Assign to">
            <select value={assignedToRole} onChange={(e) => setAssignedToRole(e.target.value as IssueRoleTarget)} className="form-input">
              {targets.map((t) => <option key={t} value={t}>{t}</option>)}
            </select>
          </FormRow>
          <FormRow label="Tag people (CC)">
            <UserTagPicker value={taggedUserIds} onChange={setTaggedUserIds} />
            <span className="mt-1 block text-[11px] text-muted-foreground">
              Tagged users will be notified, can open the issue and reply in the same thread.
            </span>
          </FormRow>
          <FormRow label="Description">
            <textarea value={description} onChange={(e) => setDescription(e.target.value)} rows={3} className="form-input resize-none" placeholder="Describe the issue, impact and request…" />
          </FormRow>
        </div>
        <footer className="flex items-center justify-end gap-2 border-t border-border bg-muted/30 px-5 py-3">
          <button onClick={onClose} className="rounded-md border border-input bg-card px-3 py-1.5 text-sm hover:bg-accent">Cancel</button>
          <button
            disabled={!description.trim() || !projectId}
            onClick={() => onCreate({ clientId, projectId, type, priority, description, assignedToId, assignedToRole, taggedUserIds })}
            className="rounded-md bg-primary px-3 py-1.5 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
          >
            Raise issue
          </button>
        </footer>
      </div>
    </div>
  );
}

function FormRow({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <label className="block">
      <span className="mb-1 block text-xs font-medium text-muted-foreground">{label}</span>
      {children}
    </label>
  );
}

function UserTagPicker({
  value, onChange, excludeIds = [],
}: {
  value: string[];
  onChange: (ids: string[]) => void;
  excludeIds?: string[];
}) {
  const [query, setQuery] = useState("");
  const [open, setOpen] = useState(false);
  const wrapRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function onDoc(e: MouseEvent) {
      if (!wrapRef.current?.contains(e.target as Node)) setOpen(false);
    }
    document.addEventListener("mousedown", onDoc);
    return () => document.removeEventListener("mousedown", onDoc);
  }, []);

  const candidates = people.filter(
    (p) =>
      !value.includes(p.id) &&
      !excludeIds.includes(p.id) &&
      (query.trim() === "" ||
        p.name.toLowerCase().includes(query.toLowerCase()) ||
        p.role.toLowerCase().includes(query.toLowerCase()) ||
        p.email.toLowerCase().includes(query.toLowerCase())),
  );

  return (
    <div ref={wrapRef} className="relative">
      <div
        className="flex flex-wrap items-center gap-1.5 rounded-md border border-input bg-card p-1.5 text-sm focus-within:ring-2 focus-within:ring-ring"
        onClick={() => setOpen(true)}
      >
        {value.map((id) => {
          const p = getPerson(id);
          return (
            <span
              key={id}
              className="inline-flex items-center gap-1 rounded-full bg-primary/10 px-2 py-0.5 text-xs font-medium text-primary"
            >
              <Avatar name={p.name} />
              {p.name}
              <span className="text-[10px] text-muted-foreground">· {p.role}</span>
              <button
                type="button"
                onClick={(e) => { e.stopPropagation(); onChange(value.filter((v) => v !== id)); }}
                className="rounded-full p-0.5 hover:bg-primary/20"
                aria-label={`Remove ${p.name}`}
              >
                <X className="h-3 w-3" />
              </button>
            </span>
          );
        })}
        <div className="flex flex-1 items-center gap-1 px-1">
          <Search className="h-3.5 w-3.5 text-muted-foreground" />
          <input
            value={query}
            onChange={(e) => { setQuery(e.target.value); setOpen(true); }}
            onFocus={() => setOpen(true)}
            placeholder={value.length === 0 ? "Search people by name, role or email…" : ""}
            className="min-w-[140px] flex-1 bg-transparent text-sm outline-none"
          />
        </div>
      </div>
      {open && candidates.length > 0 && (
        <div className="absolute z-20 mt-1 max-h-56 w-full overflow-y-auto rounded-md border border-border bg-popover p-1 shadow-lg">
          {candidates.map((p) => (
            <button
              key={p.id}
              type="button"
              onClick={() => { onChange([...value, p.id]); setQuery(""); }}
              className="flex w-full items-center gap-2 rounded-md px-2 py-1.5 text-left text-sm hover:bg-accent"
            >
              <Avatar name={p.name} />
              <span className="flex-1">
                <span className="font-medium">{p.name}</span>{" "}
                <span className="text-xs text-muted-foreground">· {p.role}</span>
              </span>
              <span className="text-[11px] text-muted-foreground">{p.email}</span>
            </button>
          ))}
        </div>
      )}
      {open && candidates.length === 0 && (
        <div className="absolute z-20 mt-1 w-full rounded-md border border-border bg-popover p-3 text-center text-xs text-muted-foreground shadow-lg">
          No matching people
        </div>
      )}
    </div>
  );
}
