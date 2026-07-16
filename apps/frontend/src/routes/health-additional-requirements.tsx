import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useMemo, useState } from "react";
import { Plus, Search, Filter, Send, MessageSquare, X, Paperclip } from "lucide-react";
import { toast } from "sonner";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { getPerson } from "@/lib/mock-data";
import { Avatar } from "@/components/pills";
import { cn } from "@/lib/utils";
import { useDhStore, dhStore, type RequirementStatus, type DhPriority, type DhComment, type DhAdditionalRequirement } from "@/lib/dh-store";

export const Route = createFileRoute("/health-additional-requirements")({
  head: () => ({
    meta: [
      { title: "Change Management — Pulse PMO" },
      { name: "description", content: "Manage additional requirements raised by clients post-onboarding." },
    ],
  }),
  component: AdditionalRequirementsPage,
});

const requirementStatuses: RequirementStatus[] = ["Open", "Under Review", "Approved", "Rejected", "Implemented"];
const priorities: DhPriority[] = ["Low", "Medium", "High", "Critical"];

function DhPriorityPill({ priority }: { priority: DhPriority }) {
  const colors = {
    "Low": "bg-muted text-muted-foreground border-border",
    "Medium": "bg-info/10 text-info border-info/30",
    "High": "bg-warning/15 text-warning-foreground border-warning/40",
    "Critical": "bg-destructive/10 text-destructive border-destructive/30",
  };
  return (
    <span className={cn("inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[11px] font-medium border", colors[priority])}>
      {priority}
    </span>
  );
}

function AdditionalRequirementsPage() {
  const { isDhanshree } = useRoleContext();
  const snapshot = useDhStore((s) => s);
  const requirements = snapshot.requirements;
  
  const [q, setQ] = useState("");
  const [statusFilter, setStatusFilter] = useState<RequirementStatus | "all">("all");
  const [selectedId, setSelectedId] = useState<string | null>(requirements[0]?.id ?? null);
  const [showForm, setShowForm] = useState(false);

  if (!isDhanshree) return <Navigate to="/" />;

  const filtered = useMemo(() => {
    return requirements.filter((req) => {
      if (statusFilter !== "all" && req.status !== statusFilter) return false;
      if (!q.trim()) return true;
      return [req.title, req.description, req.clientName, req.projectName].some((v) => 
        v?.toLowerCase().includes(q.toLowerCase())
      );
    });
  }, [requirements, statusFilter, q]);

  const selected = requirements.find((req) => req.id === selectedId) ?? filtered[0] ?? null;

  return (
    <AppShell title="Client Engagement" subtitle="Change Management">
      <div className="mb-4 flex flex-wrap items-center gap-2">
        <div className="relative max-w-xs flex-1">
          <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Search requirements…"
            className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
        </div>
        <div className="flex items-center gap-1 rounded-lg border border-border bg-card p-1 text-xs">
          <Filter className="ml-1 h-3.5 w-3.5 text-muted-foreground" />
          {(["all", ...requirementStatuses] as const).map((s) => (
            <button
              key={s}
              onClick={() => setStatusFilter(s)}
              className={cn(
                "rounded-md px-2.5 py-1 capitalize",
                statusFilter === s ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground",
              )}
            >
              {s === "all" ? "All" : s}
            </button>
          ))}
        </div>
        <button
          onClick={() => setShowForm(true)}
          className="ml-auto inline-flex items-center gap-1.5 rounded-md bg-primary px-3 py-1.5 text-sm font-medium text-primary-foreground hover:bg-primary/90"
        >
          <Plus className="h-4 w-4" /> Log Requirement
        </button>
      </div>

      <div className="grid gap-4 lg:grid-cols-[360px,1fr]">
        <aside className="rounded-xl border border-border bg-card shadow-sm">
          <ul className="max-h-[70vh] divide-y divide-border overflow-y-auto">
            {filtered.map((req) => (
              <li key={req.id}>
                <button
                  onClick={() => setSelectedId(req.id)}
                  className={cn(
                    "w-full px-4 py-3 text-left transition-colors",
                    selectedId === req.id ? "bg-accent/60" : "hover:bg-accent/40",
                  )}
                >
                  <div className="flex items-center justify-between gap-2">
                    <span className="text-xs font-medium text-muted-foreground">{req.requirementId}</span>
                    <RequirementStatusBadge status={req.status} />
                  </div>
                  <p className="mt-1 line-clamp-2 text-sm font-medium">{req.title}</p>
                  <div className="mt-2 flex items-center justify-between">
                    <span className="text-[11px] text-muted-foreground">{req.clientName}</span>
                    <DhPriorityPill priority={req.priority} />
                  </div>
                </button>
              </li>
            ))}
            {filtered.length === 0 && (
              <li className="px-4 py-10 text-center text-sm text-muted-foreground">No requirements match this filter</li>
            )}
          </ul>
        </aside>

        <section className="rounded-xl border border-border bg-card shadow-sm">
          {selected ? (
            <RequirementDetail
              requirement={selected}
              onStatusChange={(status) => {
                dhStore.updateRequirementStatus(selected.id, status, "dhanshree", "Dhanshree");
                toast.success(`Status updated to ${status}`);
              }}
              onAddComment={(comment) => {
                dhStore.addRequirementComment(selected.id, comment);
                toast.success("Comment added");
              }}
            />
          ) : (
            <div className="flex h-64 items-center justify-center text-sm text-muted-foreground">
              Select a requirement to view details
            </div>
          )}
        </section>
      </div>

      {showForm && (
        <NewRequirementDialog
          onClose={() => setShowForm(false)}
          onCreate={(input) => {
            dhStore.addRequirement(input);
            toast.success("Requirement logged", { description: `${input.title}` });
            setShowForm(false);
          }}
        />
      )}
    </AppShell>
  );
}

function RequirementStatusBadge({ status }: { status: RequirementStatus }) {
  const colors = {
    "Open": "bg-warning/10 text-warning-foreground border-warning/30",
    "Under Review": "bg-info/10 text-info-foreground border-info/30",
    "Approved": "bg-success/10 text-success border-success/30",
    "Rejected": "bg-destructive/10 text-destructive border-destructive/30",
    "Implemented": "bg-success/10 text-success border-success/30",
  };
  return (
    <span className={cn("rounded-full border px-2 py-0.5 text-[10px] font-medium capitalize", colors[status])}>
      {status}
    </span>
  );
}

function RequirementDetail({
  requirement,
  onStatusChange,
  onAddComment,
}: {
  requirement: DhAdditionalRequirement;
  onStatusChange: (status: RequirementStatus) => void;
  onAddComment: (comment: Omit<DhComment, "id" | "at">) => void;
}) {
  const [newComment, setNewComment] = useState("");

  return (
    <div className="flex h-full flex-col">
      <header className="border-b border-border p-5">
        <div className="flex flex-wrap items-center gap-2">
          <RequirementStatusBadge status={requirement.status} />
          <DhPriorityPill priority={requirement.priority} />
          <div className="ml-auto flex items-center gap-1">
            {requirementStatuses.map((s) => (
              <button
                key={s}
                onClick={() => onStatusChange(s)}
                disabled={requirement.status === s}
                className="rounded-md border border-input bg-card px-2 py-1 text-[11px] hover:bg-accent disabled:opacity-50 capitalize"
              >
                {s.replace(" ", "")}
              </button>
            ))}
          </div>
        </div>
        <h2 className="mt-2 text-lg font-semibold">{requirement.title}</h2>
        <p className="mt-1 text-sm text-muted-foreground">{requirement.description}</p>
        <div className="mt-3 grid gap-3 text-xs sm:grid-cols-3">
          <Field label="Requirement ID" value={requirement.requirementId} />
          <Field label="Client" value={requirement.clientName} />
          <Field label="Project" value={requirement.projectName} />
          <Field label="Requested By" value={requirement.requestedBy} />
          <Field label="Requested Date" value={new Date(requirement.requestedDate).toLocaleDateString()} />
          <Field label="Priority" value={requirement.priority} />
        </div>
        {requirement.attachmentName && (
          <div className="mt-3 flex items-center gap-2 rounded-md border border-border bg-muted/30 p-2">
            <Paperclip className="h-3.5 w-3.5 text-muted-foreground" />
            <span className="text-xs font-medium">{requirement.attachmentName}</span>
          </div>
        )}
      </header>

      <div className="flex flex-1 flex-col gap-4 p-5 overflow-y-auto">
        <div>
          <h3 className="mb-2 flex items-center gap-1.5 text-sm font-semibold">
            <MessageSquare className="h-4 w-4" /> Discussion
          </h3>
          <ul className="space-y-3">
            {requirement.comments.map((c: DhComment) => {
              const author = getPerson(c.authorId);
              return (
                <li key={c.id} className="flex gap-3">
                  <Avatar name={author.name} />
                  <div className="flex-1 rounded-lg border border-border bg-accent/30 p-3">
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-semibold">{c.authorName}</span>
                      <span className="text-[11px] text-muted-foreground">{new Date(c.at).toLocaleString()}</span>
                    </div>
                    <p className="mt-1 text-sm">{c.text}</p>
                  </div>
                </li>
              );
            })}
            {requirement.comments.length === 0 && (
              <li className="rounded-lg border border-dashed border-border p-4 text-center text-sm text-muted-foreground">
                No comments yet
              </li>
            )}
          </ul>
        </div>

        <div className="flex gap-2">
          <textarea
            value={newComment}
            onChange={(e) => setNewComment(e.target.value)}
            rows={2}
            placeholder="Add a comment or update…"
            className="flex-1 resize-none rounded-md border border-input bg-card p-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
          <button
            onClick={() => {
              if (!newComment.trim()) return;
              onAddComment({
                authorId: "u14",
                authorName: "Dhanshree",
                text: newComment.trim(),
              });
              setNewComment("");
            }}
            disabled={!newComment.trim()}
            className="inline-flex items-center gap-1 self-end rounded-md bg-primary px-3 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
          >
            <Send className="h-4 w-4" /> Post
          </button>
        </div>

        <div>
          <h3 className="mb-2 text-sm font-semibold">Status History</h3>
          <ol className="relative ml-2 space-y-2 border-l border-border pl-4">
            {requirement.history.map((h: { status: RequirementStatus; at: string; updatedByName: string }) => (
              <li key={h.at} className="text-xs">
                <span className="absolute -left-[5px] mt-1.5 h-2 w-2 rounded-full bg-primary" />
                <span className="font-medium">{h.status}</span> · {h.updatedByName}
                <span className="ml-2 text-muted-foreground">{new Date(h.at).toLocaleString()}</span>
              </li>
            ))}
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
      <div className="mt-0.5 truncate text-sm font-medium">{value}</div>
    </div>
  );
}

function NewRequirementDialog({
  onClose,
  onCreate,
}: {
  onClose: () => void;
  onCreate: (input: Parameters<typeof dhStore.addRequirement>[0]) => void;
}) {
  const [clientName, setClientName] = useState("");
  const [projectName, setProjectName] = useState("");
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [priority, setPriority] = useState<DhPriority>("Medium");
  const [requestedBy, setRequestedBy] = useState("");
  const [requestedDate, setRequestedDate] = useState(new Date().toISOString().split("T")[0]);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-foreground/40 p-4">
      <div className="w-full max-w-lg rounded-xl border border-border bg-card shadow-lg">
        <header className="flex items-center justify-between border-b border-border px-5 py-3">
          <h3 className="text-base font-semibold">Log Additional Requirement</h3>
          <button onClick={onClose} className="text-sm text-muted-foreground hover:text-foreground">×</button>
        </header>
        <div className="grid gap-3 p-5 text-sm">
          <FormRow label="Client Name">
            <input type="text" value={clientName} onChange={(e) => setClientName(e.target.value)} className="form-input" />
          </FormRow>
          <FormRow label="Project Name">
            <input type="text" value={projectName} onChange={(e) => setProjectName(e.target.value)} className="form-input" />
          </FormRow>
          <FormRow label="Requirement Title">
            <input type="text" value={title} onChange={(e) => setTitle(e.target.value)} className="form-input" />
          </FormRow>
          <FormRow label="Description">
            <textarea value={description} onChange={(e) => setDescription(e.target.value)} rows={2} className="form-input resize-none" />
          </FormRow>
          <div className="grid grid-cols-2 gap-3">
            <FormRow label="Priority">
              <select value={priority} onChange={(e) => setPriority(e.target.value as DhPriority)} className="form-input">
                {priorities.map((p) => <option key={p} value={p}>{p}</option>)}
              </select>
            </FormRow>
            <FormRow label="Requested Date">
              <input type="date" value={requestedDate} onChange={(e) => setRequestedDate(e.target.value)} className="form-input" />
            </FormRow>
          </div>
          <FormRow label="Requested By">
            <input type="text" value={requestedBy} onChange={(e) => setRequestedBy(e.target.value)} placeholder="Client/PM name" className="form-input" />
          </FormRow>
        </div>
        <footer className="flex items-center justify-end gap-2 border-t border-border bg-muted/30 px-5 py-3">
          <button onClick={onClose} className="rounded-md border border-input bg-card px-3 py-1.5 text-sm hover:bg-accent">Cancel</button>
          <button
            disabled={!clientName || !projectName || !title || !description}
            onClick={() => {
              onCreate({
                projectId: "p1",
                title,
                description,
                clientName,
                projectName,
                priority,
                requestedBy,
                requestedDate,
                status: "Open",
                comments: [],
              });
            }}
            className="rounded-md bg-primary px-3 py-1.5 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
          >
            Log Requirement
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
