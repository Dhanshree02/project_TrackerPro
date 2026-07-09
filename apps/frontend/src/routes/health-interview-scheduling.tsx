import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useMemo, useState } from "react";
import { Plus, Search, Filter, Send, Trash2, MessageSquare, CheckCircle2, X } from "lucide-react";
import { toast } from "sonner";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { getPerson, people } from "@/lib/mock-data";
import { Avatar, PriorityPill } from "@/components/pills";
import { cn } from "@/lib/utils";
import { useDhStore, dhStore, type InterviewStatus, type DhInterview } from "@/lib/dh-store";

export const Route = createFileRoute("/health-interview-scheduling")({
  head: () => ({
    meta: [
      { title: "Interview Scheduling — Pulse PMO" },
      { name: "description", content: "Manage client interview scheduling and resource feedback." },
    ],
  }),
  component: InterviewSchedulingPage,
});

const interviewStatuses: InterviewStatus[] = ["Pending", "Selected", "Rejected", "Postponed"];

function InterviewSchedulingPage() {
  const { isDhanshree } = useRoleContext();
  const snapshot = useDhStore((s) => s);
  const interviews = snapshot.interviews;
  
  const [q, setQ] = useState("");
  const [statusFilter, setStatusFilter] = useState<InterviewStatus | "all">("all");
  const [selectedId, setSelectedId] = useState<string | null>(interviews[0]?.id ?? null);
  const [showForm, setShowForm] = useState(false);
  const [selectedInterview, setSelectedInterview] = useState<typeof interviews[0] | null>(null);

  if (!isDhanshree) return <Navigate to="/" />;

  const filtered = useMemo(() => {
    return interviews.filter((iv) => {
      if (statusFilter !== "all" && iv.status !== statusFilter) return false;
      if (!q.trim()) return true;
      return [iv.resourceName, iv.clientName, iv.projectName].some((v) => 
        v?.toLowerCase().includes(q.toLowerCase())
      );
    });
  }, [interviews, statusFilter, q]);

  const selected = interviews.find((iv) => iv.id === selectedId) ?? filtered[0] ?? null;

  return (
    <AppShell title="Client Engagement" subtitle="Interview Scheduling">
      <div className="mb-4 flex flex-wrap items-center gap-2">
        <div className="relative max-w-xs flex-1">
          <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Search interviews…"
            className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
        </div>
        <div className="flex items-center gap-1 rounded-lg border border-border bg-card p-1 text-xs">
          <Filter className="ml-1 h-3.5 w-3.5 text-muted-foreground" />
          {(["all", ...interviewStatuses] as const).map((s) => (
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
          <Plus className="h-4 w-4" /> Schedule Interview
        </button>
      </div>

      <div className="grid gap-4 lg:grid-cols-[360px,1fr]">
        <aside className="rounded-xl border border-border bg-card shadow-sm">
          <ul className="max-h-[70vh] divide-y divide-border overflow-y-auto">
            {filtered.map((iv) => (
              <li key={iv.id}>
                <button
                  onClick={() => setSelectedId(iv.id)}
                  className={cn(
                    "w-full px-4 py-3 text-left transition-colors",
                    selectedId === iv.id ? "bg-accent/60" : "hover:bg-accent/40",
                  )}
                >
                  <div className="flex items-center justify-between gap-2">
                    <span className="text-xs font-medium text-muted-foreground">{iv.resourceName}</span>
                    <InterviewStatusBadge status={iv.status} />
                  </div>
                  <p className="mt-1 line-clamp-2 text-sm">{iv.clientName}</p>
                  <div className="mt-2 flex items-center justify-between">
                    <span className="text-[11px] text-muted-foreground">{iv.projectName}</span>
                    <span className="text-[11px] text-muted-foreground">{new Date(iv.interviewDate).toLocaleDateString()}</span>
                  </div>
                </button>
              </li>
            ))}
            {filtered.length === 0 && (
              <li className="px-4 py-10 text-center text-sm text-muted-foreground">No interviews match this filter</li>
            )}
          </ul>
        </aside>

        <section className="rounded-xl border border-border bg-card shadow-sm">
          {selected ? (
            <InterviewDetail
              interview={selected}
              onStatusChange={(status) => {
                dhStore.updateInterviewStatus(selected.id, status, getPerson(selected.resourceId).name);
                toast.success(`Status updated to ${status}`);
              }}
            />
          ) : (
            <div className="flex h-64 items-center justify-center text-sm text-muted-foreground">
              Select an interview to view details
            </div>
          )}
        </section>
      </div>

      {showForm && (
        <NewInterviewDialog
          onClose={() => setShowForm(false)}
          onCreate={(input) => {
            dhStore.addInterview(input);
            toast.success("Interview scheduled", { description: `${input.resourceName} for ${input.clientName}` });
            setShowForm(false);
          }}
        />
      )}
    </AppShell>
  );
}

function InterviewStatusBadge({ status }: { status: InterviewStatus }) {
  const colors = {
    "Pending": "bg-warning/10 text-warning-foreground border-warning/30",
    "Selected": "bg-success/10 text-success border-success/30",
    "Rejected": "bg-destructive/10 text-destructive border-destructive/30",
    "Postponed": "bg-muted/10 text-muted-foreground border-muted/30",
  };
  return (
    <span className={cn("rounded-full border px-2 py-0.5 text-[10px] font-medium capitalize", colors[status])}>
      {status}
    </span>
  );
}

function InterviewDetail({
  interview,
  onStatusChange,
}: {
  interview: DhInterview;
  onStatusChange: (status: InterviewStatus) => void;
}) {
  const resource = getPerson(interview.resourceId);
  const [comment, setComment] = useState("");
  const [response, setResponse] = useState(interview.resourceResponse?.text ?? "");

  return (
    <div className="flex h-full flex-col">
      <header className="border-b border-border p-5">
        <div className="flex flex-wrap items-center gap-2">
          <InterviewStatusBadge status={interview.status} />
          <div className="ml-auto flex items-center gap-1">
            {interviewStatuses.map((s) => (
              <button
                key={s}
                onClick={() => onStatusChange(s)}
                disabled={interview.status === s}
                className="rounded-md border border-input bg-card px-2 py-1 text-[11px] hover:bg-accent disabled:opacity-50 capitalize"
              >
                {s}
              </button>
            ))}
          </div>
        </div>
        <h2 className="mt-2 text-lg font-semibold">{interview.interviewRound}</h2>
        <div className="mt-3 grid gap-3 text-xs sm:grid-cols-3">
          <Field label="Resource" value={resource.name} />
          <Field label="Employee ID" value={interview.employeeId} />
          <Field label="Client" value={interview.clientName} />
          <Field label="Project" value={interview.projectName} />
          <Field label="Interview Date" value={new Date(interview.interviewDate).toLocaleDateString()} />
          <Field label="Time" value={interview.interviewTime} />
          <Field label="Interviewer" value={interview.interviewer} />
        </div>
        {interview.notes && (
          <div className="mt-3 rounded-md border border-border bg-muted/30 p-3">
            <div className="text-xs font-medium text-muted-foreground">Notes</div>
            <p className="mt-1 text-sm">{interview.notes}</p>
          </div>
        )}
      </header>

      <div className="flex flex-1 flex-col gap-4 p-5 overflow-y-auto">
        <div>
          <h3 className="mb-2 flex items-center gap-1.5 text-sm font-semibold">
            <MessageSquare className="h-4 w-4" /> Interview History
          </h3>
          <ol className="relative ml-2 space-y-2 border-l border-border pl-4">
            {interview.history.map((h: { status: InterviewStatus; at: string; updatedBy: string }, idx: number) => (
              <li key={idx} className="text-xs">
                <span className="absolute -left-[5px] mt-1.5 h-2 w-2 rounded-full bg-primary" />
                <span className="font-medium">{h.status}</span>
                <span className="ml-2 text-muted-foreground">{new Date(h.at).toLocaleString()}</span>
              </li>
            ))}
          </ol>
        </div>

        {interview.status === "Pending" && (
          <div className="rounded-md border border-info/30 bg-info/10 p-3 text-sm text-info-foreground">
            Awaiting resource response and acknowledgement
          </div>
        )}

        {interview.status === "Selected" && (
          <div>
            <h3 className="mb-2 text-sm font-semibold">Resource Confirmation</h3>
            <textarea
              value={response}
              onChange={(e) => setResponse(e.target.value)}
              rows={3}
              placeholder="Resource response (availability confirmation, questions, etc.)…"
              className="w-full rounded-md border border-input bg-card p-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
            />
            <button
              onClick={() => {
                dhStore.submitInterviewResponse(interview.id, response);
                toast.success("Response submitted");
              }}
              className="mt-2 rounded-md bg-primary px-3 py-1.5 text-sm font-medium text-primary-foreground hover:bg-primary/90"
            >
              Submit Response
            </button>
          </div>
        )}

        {interview.resourceResponse && (
          <div className="rounded-lg border border-border bg-card p-3">
            <div className="text-xs font-semibold">Resource Response</div>
            <p className="mt-1 text-sm">{interview.resourceResponse.text}</p>
            <div className="mt-2 text-xs text-muted-foreground">{new Date(interview.resourceResponse.at).toLocaleString()}</div>
          </div>
        )}
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

function NewInterviewDialog({
  onClose,
  onCreate,
}: {
  onClose: () => void;
  onCreate: (input: Parameters<typeof dhStore.addInterview>[0]) => void;
}) {
  const [resourceId, setResourceId] = useState("");
  const [clientName, setClientName] = useState("");
  const [projectName, setProjectName] = useState("");
  const [interviewDate, setInterviewDate] = useState("");
  const [interviewTime, setInterviewTime] = useState("");
  const [interviewRound, setInterviewRound] = useState("");
  const [interviewer, setInterviewer] = useState("");
  const [notes, setNotes] = useState("");

  const resource = resourceId ? getPerson(resourceId) : null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-foreground/40 p-4">
      <div className="w-full max-w-lg rounded-xl border border-border bg-card shadow-lg">
        <header className="flex items-center justify-between border-b border-border px-5 py-3">
          <h3 className="text-base font-semibold">Schedule Interview</h3>
          <button onClick={onClose} className="text-sm text-muted-foreground hover:text-foreground">×</button>
        </header>
        <div className="grid gap-3 p-5 text-sm">
          <FormRow label="Resource">
            <select value={resourceId} onChange={(e) => setResourceId(e.target.value)} className="form-input">
              <option value="">Select a resource…</option>
              {people.map((p) => <option key={p.id} value={p.id}>{p.name} • {p.role}</option>)}
            </select>
          </FormRow>
          {resource && (
            <FormRow label="Employee ID">
              <input type="text" value={resourceId} readOnly className="form-input bg-muted/50" placeholder="Auto-filled" />
            </FormRow>
          )}
          <FormRow label="Client Name">
            <input type="text" value={clientName} onChange={(e) => setClientName(e.target.value)} className="form-input" />
          </FormRow>
          <FormRow label="Project Name">
            <input type="text" value={projectName} onChange={(e) => setProjectName(e.target.value)} className="form-input" />
          </FormRow>
          <div className="grid grid-cols-2 gap-3">
            <FormRow label="Interview Date">
              <input type="date" value={interviewDate} onChange={(e) => setInterviewDate(e.target.value)} className="form-input" />
            </FormRow>
            <FormRow label="Interview Time">
              <input type="time" value={interviewTime} onChange={(e) => setInterviewTime(e.target.value)} className="form-input" />
            </FormRow>
          </div>
          <FormRow label="Interview Round">
            <input type="text" value={interviewRound} onChange={(e) => setInterviewRound(e.target.value)} placeholder="e.g., Technical Round 1" className="form-input" />
          </FormRow>
          <FormRow label="Interviewer">
            <input type="text" value={interviewer} onChange={(e) => setInterviewer(e.target.value)} className="form-input" />
          </FormRow>
          <FormRow label="Notes">
            <textarea value={notes} onChange={(e) => setNotes(e.target.value)} rows={2} className="form-input resize-none" />
          </FormRow>
        </div>
        <footer className="flex items-center justify-end gap-2 border-t border-border bg-muted/30 px-5 py-3">
          <button onClick={onClose} className="rounded-md border border-input bg-card px-3 py-1.5 text-sm hover:bg-accent">Cancel</button>
          <button
            disabled={!resourceId || !clientName || !projectName || !interviewDate || !interviewTime}
            onClick={() => {
              const resource = getPerson(resourceId);
              onCreate({
                projectId: "p1",
                resourceId,
                resourceName: resource.name,
                employeeId: resourceId.toUpperCase(),
                clientName,
                projectName,
                interviewDate,
                interviewTime,
                interviewRound,
                interviewer,
                notes,
                status: "Pending",
              });
            }}
            className="rounded-md bg-primary px-3 py-1.5 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
          >
            Schedule Interview
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
