import { createFileRoute, Link, Navigate } from "@tanstack/react-router";
import { useMemo, useState } from "react";
import { Search, Filter, Plus, Send, Trash2, Clock, MessageSquare, Copy, X, CheckCircle2, XCircle, RotateCcw, AlertTriangle, AlertCircle, Calendar, DollarSign, Check, ExternalLink, ShieldAlert, ListFilter, User, Paperclip, Bell, Archive } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { getPerson, people, type TaskStatus, type CellCommentData, type CellCommentMessage } from "@/lib/mock-data";
import { TaskStatusPill, TimesheetStatusPill, PriorityPill, Avatar } from "@/components/pills";
import { useDhStore, dhStore, allProjects, allClients, type DhAlert, type DhInterview, type DhTimesheet, type DhCentralApproval, type AlertStatus, type DhNotification } from "@/lib/dh-store";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import { Modal } from "./projects.index";

export const Route = createFileRoute("/action-centre")({
  head: () => ({
    meta: [
      { title: "Action Centre — Pulse PMO" },
      { name: "description", content: "Bucket list, timesheets, approvals and alerts in one place." },
    ],
  }),
  component: ActionCentrePage,
});

const tabs = ["Bucket List", "Approvals", "Alerts", "Notifications"] as const;
type Tab = (typeof tabs)[number];

function ActionCentrePage() {
  const { isDhanshree, user } = useRoleContext();
  const [tab, setTab] = useState<Tab>("Bucket List");
  const store = useDhStore((s) => s);
  const pendingCount = (store.notifications || []).filter(n => n.status === "Pending").length;

  if (!isDhanshree) return <Navigate to="/" />;

  return (
    <AppShell title="Action Centre" subtitle={`${user.name} · tasks, timesheets, approvals and alerts`}>
      <div className="mb-4 flex gap-1 overflow-x-auto rounded-lg border border-border bg-card p-1 text-sm shadow-sm">
        {tabs.map((t) => {
          const isNotif = t === "Notifications";
          return (
            <button
              key={t}
              onClick={() => setTab(t)}
              className={cn(
                "rounded-md px-3 py-1.5 font-medium transition-colors whitespace-nowrap flex items-center gap-1.5",
                tab === t ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground",
              )}
            >
              <span>{t}</span>
              {isNotif && pendingCount > 0 && (
                <span className="rounded-full bg-destructive text-destructive-foreground px-2 py-0.5 text-xs font-semibold leading-none">
                  {pendingCount}
                </span>
              )}
            </button>
          );
        })}
      </div>

      {tab === "Bucket List" && <BucketList />}
      {tab === "Approvals" && <ApprovalsTab />}
      {tab === "Alerts" && <AlertsTab />}
      {tab === "Notifications" && <NotificationsTab />}
    </AppShell>
  );
}

// ---------- Bucket List ----------
type BucketRow = {
  taskId: string;
  taskTitle: string;
  projectId: string;
  projectName: string;
  priority: "low" | "medium" | "high" | "critical";
  dueDate: string;
  status: TaskStatus;
  assignedById: string;
};

function BucketList() {
  const { user } = useRoleContext();
  const [q, setQ] = useState("");
  const [statusFilter, setStatusFilter] = useState<"all" | TaskStatus>("all");
  const [priorityFilter, setPriorityFilter] = useState<"all" | BucketRow["priority"]>("all");
  const store = useDhStore((s) => s);
  const projectsList = allProjects();

  const rows: BucketRow[] = useMemo(() => {
    const out: BucketRow[] = [];
    const prios: BucketRow["priority"][] = ["high", "medium", "critical", "low", "medium", "high"];

    // Existing base bucket tasks logic:
    projectsList.slice(0, 5).forEach((p, pi) => {
      p.tasks.slice(0, 3).forEach((t, ti) => {
        out.push({
          taskId: t.id,
          taskTitle: t.title,
          projectId: p.id,
          projectName: p.name,
          priority: prios[(pi + ti) % prios.length],
          dueDate: t.dueDate,
          status: t.status,
          assignedById: p.pmId,
        });
      });
    });

    // Dynamic tasks for Ready To Start projects assigned to the current PM/SPM:
    projectsList.forEach((p) => {
      const prereq = store.prereqs[p.id];
      if (prereq && prereq.isProjectReadyToStart) {
        const isAssignedPm = prereq.assignedPmIds?.includes(user.id);
        const isAssignedSpm = prereq.assignedSpmIds?.includes(user.id);
        if (isAssignedPm || isAssignedSpm) {
          p.tasks.forEach((t) => {
            // Avoid duplicates
            if (!out.some(x => x.taskId === t.id)) {
              out.push({
                taskId: t.id,
                taskTitle: t.title,
                projectId: p.id,
                projectName: p.name,
                priority: "medium", // default
                dueDate: t.dueDate,
                status: t.status,
                assignedById: p.pmId || "u14", // Dhanshree / System
              });
            }
          });
        }
      }
    });

    return out;
  }, [projectsList, store.prereqs, user.id]);

  const filtered = rows.filter((r) => {
    if (statusFilter !== "all" && r.status !== statusFilter) return false;
    if (priorityFilter !== "all" && r.priority !== priorityFilter) return false;
    if (!q.trim()) return true;
    return [r.taskTitle, r.projectName].some((v) => v.toLowerCase().includes(q.toLowerCase()));
  });

  return (
    <section className="rounded-xl border border-border bg-card shadow-sm">
      <header className="flex flex-wrap items-center gap-2 border-b border-border p-3">
        <div className="relative max-w-xs flex-1">
          <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            value={q} onChange={(e) => setQ(e.target.value)}
            placeholder="Search task or project…"
            className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
        </div>
        <div className="flex items-center gap-1 rounded-lg border border-border bg-card p-1 text-xs">
          <Filter className="ml-1 h-3.5 w-3.5 text-muted-foreground" />
          {(["all", "todo", "in_progress", "review", "done"] as const).map((s) => (
            <button key={s} onClick={() => setStatusFilter(s)}
              className={cn("rounded-md px-2.5 py-1 capitalize",
                statusFilter === s ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground")}>
              {s === "all" ? "All status" : s.replace("_", " ")}
            </button>
          ))}
        </div>
        <div className="flex items-center gap-1 rounded-lg border border-border bg-card p-1 text-xs">
          {(["all", "low", "medium", "high", "critical"] as const).map((p) => (
            <button key={p} onClick={() => setPriorityFilter(p)}
              className={cn("rounded-md px-2.5 py-1 capitalize",
                priorityFilter === p ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground")}>
              {p === "all" ? "All priority" : p}
            </button>
          ))}
        </div>
        <span className="ml-auto text-xs text-muted-foreground">
          Assigned to {user.name} · {filtered.length} tasks
        </span>
      </header>

      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr>
              <th className="px-3 py-2 font-medium">Task</th>
              <th className="px-3 py-2 font-medium">Project</th>
              <th className="px-3 py-2 font-medium">Priority</th>
              <th className="px-3 py-2 font-medium">Due Date</th>
              <th className="px-3 py-2 font-medium">Status</th>
              <th className="px-3 py-2 font-medium">Assigned By</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {filtered.map((r) => {
              const by = getPerson(r.assignedById);
              return (
                <tr key={r.taskId} className="hover:bg-accent/30">
                  <td className="px-3 py-2.5">
                    <Link to="/projects/$projectId" params={{ projectId: r.projectId }} hash={r.taskId}
                      className="font-medium hover:text-primary">{r.taskTitle}</Link>
                  </td>
                  <td className="px-3 py-2.5 text-muted-foreground">{r.projectName}</td>
                  <td className="px-3 py-2.5"><PriorityPill priority={r.priority} /></td>
                  <td className="px-3 py-2.5 text-xs tabular-nums text-muted-foreground">{new Date(r.dueDate).toLocaleDateString()}</td>
                  <td className="px-3 py-2.5"><TaskStatusPill status={r.status} /></td>
                  <td className="px-3 py-2.5">
                    <div className="flex items-center gap-2"><Avatar name={by.name} size={24} /><span className="text-xs">{by.name}</span></div>
                  </td>
                </tr>
              );
            })}
            {filtered.length === 0 && (
              <tr><td colSpan={6} className="px-3 py-10 text-center text-sm text-muted-foreground">No tasks match your filters</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </section>
  );
}

// ---------- Approvals ----------
function ApprovalsTab() {
  const store = useDhStore((s) => s);
  const [selectedAppId, setSelectedAppId] = useState<string | null>(null);
  const [appComment, setAppComment] = useState("");
  const [projectFilter, setProjectFilter] = useState("all");
  const [typeFilter, setTypeFilter] = useState("all");
  const [statusFilter, setStatusFilter] = useState("all");
  const { user } = useRoleContext();

  const selectedApproval = useMemo(() => {
    return store.approvals.find(a => a.id === selectedAppId);
  }, [store.approvals, selectedAppId]);

  const approvalTypes = [
    "WBS Approval",
    "Budget Approval",
    "PM Assignment Approval",
    "SPM Assignment Approval",
    "Project Ready To Start Approval",
    "Resource Allocation Approval",
    "Client Requirement Approval",
    "Timeline Extension Approval"
  ];

  const filteredApprovals = useMemo(() => {
    return store.approvals.filter((a) => {
      if (projectFilter !== "all" && a.projectId !== projectFilter) return false;
      if (typeFilter !== "all" && a.requestType !== typeFilter) return false;
      if (statusFilter !== "all" && a.status !== statusFilter) return false;
      return true;
    });
  }, [store.approvals, projectFilter, typeFilter, statusFilter]);

  const handleAction = (status: DhCentralApproval["status"]) => {
    if (!selectedAppId) return;
    if (!appComment.trim()) {
      toast.error("Comments are mandatory for every central approval action!");
      return;
    }
    dhStore.updateCentralApprovalStatus(selectedAppId, status, appComment, user.name, user.id);
    toast.success(`Success: Approval Request marked as ${status}!`);
    setAppComment("");
    setSelectedAppId(null);
  };

  const handleAcknowledge = (appId: string) => {
    dhStore.acknowledgeCentralApproval(appId);
    toast.success("Decision Acknowledged Persistently!");
  };

  return (
    <section className="rounded-xl border border-border bg-card shadow-sm">
      <header className="border-b border-border p-4 space-y-3">
        <div className="flex items-center gap-2">
          <ShieldAlert className="h-4.5 w-4.5 text-primary" />
          <h3 className="text-sm font-semibold">Central Approval Center</h3>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-2 text-xs">
          <div className="flex flex-col gap-1">
            <span className="text-[10px] font-semibold text-muted-foreground uppercase">Project</span>
            <select value={projectFilter} onChange={(e) => setProjectFilter(e.target.value)} className="form-input rounded-md border border-border p-1.5 bg-card">
              <option value="all">All Projects</option>
              {allProjects().map((p) => <option key={p.id} value={p.id}>{p.name}</option>)}
            </select>
          </div>
          <div className="flex flex-col gap-1">
            <span className="text-[10px] font-semibold text-muted-foreground uppercase">Request Type</span>
            <select value={typeFilter} onChange={(e) => setTypeFilter(e.target.value)} className="form-input rounded-md border border-border p-1.5 bg-card">
              <option value="all">All Request Types</option>
              {approvalTypes.map((t) => <option key={t} value={t}>{t}</option>)}
            </select>
          </div>
          <div className="flex flex-col gap-1">
            <span className="text-[10px] font-semibold text-muted-foreground uppercase">Status</span>
            <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} className="form-input rounded-md border border-border p-1.5 bg-card">
              <option value="all">All Statuses</option>
              {(["Pending", "Approved", "Rejected", "Hold", "Request Changes"] as const).map((s) => (
                <option key={s} value={s}>{s}</option>
              ))}
            </select>
          </div>
        </div>
      </header>

      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr>
              <th className="px-3 py-2 font-medium">Approval ID</th>
              <th className="px-3 py-2 font-medium">Project</th>
              <th className="px-3 py-2 font-medium">Request Type</th>
              <th className="px-3 py-2 font-medium">Requested By</th>
              <th className="px-3 py-2 font-medium">Date</th>
              <th className="px-3 py-2 font-medium">Status</th>
              <th className="px-3 py-2 font-medium text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {filteredApprovals.map((app) => (
              <tr key={app.id} className="hover:bg-accent/30">
                <td className="px-3 py-2.5 font-mono text-xs font-bold text-gray-800">{app.id}</td>
                <td className="px-3 py-2.5 font-medium text-gray-700">{app.projectName}</td>
                <td className="px-3 py-2.5 text-xs text-primary font-semibold">{app.requestType}</td>
                <td className="px-3 py-2.5">
                  <div className="flex items-center gap-2">
                    <Avatar name={app.requestedBy} size={20} />
                    <span className="text-xs">{app.requestedBy}</span>
                  </div>
                </td>
                <td className="px-3 py-2.5 text-xs tabular-nums text-muted-foreground">{new Date(app.requestedDate).toLocaleDateString()}</td>
                <td className="px-3 py-2.5">
                  <span className={cn("inline-flex rounded-full border px-2 py-0.5 text-[10px] font-medium capitalize",
                    app.status === "Approved" ? "bg-success/10 text-success border-success/30" :
                      app.status === "Rejected" ? "bg-destructive/10 text-destructive border-destructive/30" :
                        app.status === "Hold" ? "bg-warning/15 text-warning-foreground border-warning/30" :
                          app.status === "Request Changes" ? "bg-info/10 text-info border-info/30" :
                            "bg-muted text-muted-foreground border-border"
                  )}>
                    {app.status}
                  </span>
                </td>
                <td className="px-3 py-2.5 text-right space-x-1 whitespace-nowrap">
                  <button onClick={() => setSelectedAppId(app.id)} className="rounded-md border border-input bg-card px-2.5 py-1 text-xs hover:bg-accent font-medium text-primary">
                    View
                  </button>
                  {app.status !== "Pending" && !app.acknowledgedAt && (
                    <button onClick={() => handleAcknowledge(app.id)} className="inline-flex items-center gap-1 rounded-md border border-success/30 bg-success/10 px-2.5 py-1 text-xs font-semibold text-success hover:bg-success/20">
                      <Check className="h-3 w-3" /> Acknowledge
                    </button>
                  )}
                  {app.acknowledgedAt && (
                    <span className="text-[10px] font-medium text-success pl-1 inline-flex items-center gap-0.5">
                      <CheckCircle2 className="h-3 w-3 inline" /> Acked
                    </span>
                  )}
                </td>
              </tr>
            ))}
            {filteredApprovals.length === 0 && (
              <tr><td colSpan={7} className="px-3 py-10 text-center text-sm text-muted-foreground">No approvals found</td></tr>
            )}
          </tbody>
        </table>
      </div>

      {selectedApproval && (
        <Modal title={`Review Request — ${selectedApproval.id}`} onClose={() => setSelectedAppId(null)} wide>
          <div className="space-y-4">
            <div className="bg-muted/30 border border-border rounded-lg p-3 text-xs leading-relaxed grid grid-cols-2 md:grid-cols-4 gap-3">
              <div><span className="text-muted-foreground">Project Link</span><p className="font-medium text-primary hover:underline"><Link to="/projects/$projectId" params={{ projectId: selectedApproval.projectId }}>{selectedApproval.projectName}</Link></p></div>
              <div><span className="text-muted-foreground">Requested By</span><p className="font-semibold">{selectedApproval.requestedBy}</p></div>
              <div><span className="text-muted-foreground">Submitted On</span><p className="font-medium">{selectedApproval.requestedDate}</p></div>
              <div><span className="text-muted-foreground">Request Type</span><p className="font-bold text-xs text-primary">{selectedApproval.requestType}</p></div>
            </div>

            <div className="rounded-lg border border-border p-3 bg-card space-y-1.5">
              <span className="text-xs font-bold text-muted-foreground uppercase">Description & Justification</span>
              <p className="text-sm text-gray-800 leading-relaxed font-medium">{selectedApproval.description}</p>
            </div>

            {selectedApproval.comments.length > 0 && (
              <div className="rounded-lg border border-border bg-card p-3 space-y-2">
                <span className="text-xs font-semibold text-muted-foreground uppercase tracking-wide">Discussion & Audit Log History</span>
                <div className="space-y-2 max-h-40 overflow-y-auto pl-1">
                  {selectedApproval.history.map((h, idx) => (
                    <div key={idx} className="text-xs border-l-2 border-primary pl-2 py-0.5 bg-muted/10 rounded-sm">
                      <div className="flex justify-between text-muted-foreground text-[10px]">
                        <span>Status: <strong className="text-gray-700 font-semibold">{h.status}</strong> by {h.updatedBy}</span>
                        <span>{new Date(h.at).toLocaleString()}</span>
                      </div>
                      {h.comment && <p className="text-gray-800 mt-0.5">"{h.comment}"</p>}
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Requester Acknowledge State */}
            {selectedApproval.acknowledgedAt && (
              <div className="rounded-lg border border-success/30 bg-success/10 p-3 text-xs text-success flex items-center gap-2">
                <CheckCircle2 className="h-4 w-4" />
                <span>
                  This decision was acknowledged by the requester on <strong>{new Date(selectedApproval.acknowledgedAt).toLocaleString()}</strong>.
                </span>
              </div>
            )}

            {/* Mandatory Comment box */}
            {selectedApproval.status === "Pending" && (
              <div className="space-y-2 border-t border-border pt-3">
                <label className="text-xs font-semibold text-gray-700 block">
                  Action Comments / Clarifications / Instructions <span className="text-destructive font-bold">*Mandatory</span>
                </label>
                <textarea
                  value={appComment}
                  onChange={(e) => setAppComment(e.target.value)}
                  placeholder="Provide detailed instructions, clarification request, or reasons..."
                  rows={3}
                  className="w-full rounded-md border border-input bg-card p-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring border-border"
                />
              </div>
            )}

            <div className="flex justify-end gap-2 border-t border-border pt-3">
              <button onClick={() => setSelectedAppId(null)} className="rounded-md border border-input bg-card px-4 py-2 text-xs font-medium hover:bg-accent">
                Close
              </button>
              {selectedApproval.status === "Pending" && (
                <>
                  <button
                    onClick={() => handleAction("Hold")}
                    disabled={!appComment.trim()}
                    className="inline-flex items-center gap-1 rounded-md border border-warning/30 bg-warning/10 px-4 py-2 text-xs font-medium text-warning-foreground hover:bg-warning/20 disabled:opacity-50"
                  >
                    Hold
                  </button>
                  <button
                    onClick={() => handleAction("Request Changes")}
                    disabled={!appComment.trim()}
                    className="inline-flex items-center gap-1 rounded-md border border-info/30 bg-info/10 px-4 py-2 text-xs font-medium text-info hover:bg-info/20 disabled:opacity-50"
                  >
                    Request Changes
                  </button>
                  <button
                    onClick={() => handleAction("Rejected")}
                    disabled={!appComment.trim()}
                    className="inline-flex items-center gap-1 rounded-md border border-destructive/30 bg-destructive/10 px-4 py-2 text-xs font-medium text-destructive hover:bg-destructive/20 disabled:opacity-50"
                  >
                    Reject
                  </button>
                  <button
                    onClick={() => handleAction("Approved")}
                    disabled={!appComment.trim()}
                    className="inline-flex items-center gap-1 rounded-md bg-primary px-4 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
                  >
                    Approve
                  </button>
                </>
              )}
            </div>
          </div>
        </Modal>
      )}
    </section>
  );
}

// ---------- Alerts ----------
function MetricCard({ label, value, color }: { label: string; value: number; color: string }) {
  return (
    <div className={cn("rounded-lg border p-3 flex flex-col justify-between shadow-xs bg-card", color)}>
      <span className="text-[10px] font-bold uppercase tracking-wider opacity-85">{label}</span>
      <span className="text-xl font-extrabold tracking-tight mt-1">{value}</span>
    </div>
  );
}

function AlertsTab() {
  const store = useDhStore((s) => s);
  const [selectedAlertId, setSelectedAlertId] = useState<string | null>(null);
  const [projFilter, setProjFilter] = useState("all");
  const [clientFilter, setClientFilter] = useState("all");
  const [prioFilter, setPrioFilter] = useState("all");
  const [typeFilter, setTypeFilter] = useState("all");
  const [statusFilter, setStatusFilter] = useState("all");

  // Modal states
  const [newChatMsg, setNewChatMsg] = useState("");
  const [selectedOwner, setSelectedOwner] = useState("");
  const [selectedResOwner, setSelectedResOwner] = useState("");
  const [selectedEscOwner, setSelectedEscOwner] = useState("");
  const [resDetails, setResDetails] = useState("");
  const [selectedStatus, setSelectedStatus] = useState<AlertStatus>("Open");
  const [approved, setApproved] = useState(false);
  const { user } = useRoleContext();

  const allAlerts = store.alerts;
  const projectsList = allProjects();
  const clientsList = allClients();

  const filtered = useMemo(() => {
    return allAlerts.filter((a) => {
      const proj = projectsList.find(p => p.id === a.projectId);
      if (projFilter !== "all" && a.projectId !== projFilter) return false;
      if (clientFilter !== "all" && proj?.clientId !== clientFilter) return false;
      if (prioFilter !== "all" && a.priority !== prioFilter) return false;
      if (typeFilter !== "all" && a.alertType !== typeFilter) return false;
      if (statusFilter !== "all" && a.status !== statusFilter) return false;
      return true;
    });
  }, [allAlerts, projFilter, clientFilter, prioFilter, typeFilter, statusFilter, projectsList]);

  const metrics = useMemo(() => {
    const total = allAlerts.length;
    const open = allAlerts.filter(a => a.status === "Open").length;
    const critical = allAlerts.filter(a => a.priority === "Critical").length;
    const resolved = allAlerts.filter(a => a.status === "Resolved").length;
    const escalated = allAlerts.filter(a => a.priority === "Critical" || a.status === "Closed").length;
    return { total, open, critical, resolved, escalated };
  }, [allAlerts]);

  const selectedAlert = useMemo(() => {
    return allAlerts.find(a => a.id === selectedAlertId);
  }, [allAlerts, selectedAlertId]);

  // Alerts raised by the Log Requirement flow (add service / scope cancellation)
  const isRequirementAlert = !!selectedAlert?.alertId?.startsWith("REQ-AL-");

  const openDetails = (id: string) => {
    const alert = allAlerts.find(a => a.id === id);
    if (alert) {
      setSelectedAlertId(id);
      setSelectedOwner(alert.owner || "");
      setSelectedResOwner(alert.resolutionOwner || "");
      setSelectedEscOwner(alert.escalationOwner || "");
      setResDetails(alert.resolutionDetails || "");
      setSelectedStatus(alert.status);
      setApproved(false);
    }
  };

  const handleUpdateAlert = () => {
    if (!selectedAlertId) return;
    const alert = selectedAlert;
    // For Escalation alerts — never update status from here (creator-only via Health tab)
    dhStore.updateGovernanceAlert(
      selectedAlertId,
      {
        ...(alert?.kind !== "Escalation" ? { status: selectedStatus } : {}),
        owner: selectedOwner,
        resolutionOwner: selectedResOwner,
        escalationOwner: selectedEscOwner,
        resolutionDetails: resDetails
      },
      newChatMsg,
      user.id,
      user.name
    );
    toast.success("Alert Governance updated persistently!");
    setNewChatMsg("");
    setSelectedAlertId(null);
  };

  const alertTypes = [
    "Project Risk",
    "Resource Risk",
    "Technical Issue",
    "Dependency Blocker",
    "Escalation",
    "Client Concern",
    "Budget Concern",
    "Schedule Delay",
    "Quality Concern",
    "Governance Alert"
  ];

  return (
    <>
      {/* Metrics Dashboard Grid */}
      <div className="grid grid-cols-2 md:grid-cols-5 gap-3 mb-4">
        <MetricCard label="Total Alerts" value={metrics.total} color="bg-blue-50 text-blue-700 border-blue-200" />
        <MetricCard label="Open Alerts" value={metrics.open} color="bg-orange-50 text-orange-700 border-orange-200" />
        <MetricCard label="Critical Alerts" value={metrics.critical} color="bg-red-50 text-red-700 border-red-200" />
        <MetricCard label="Resolved Alerts" value={metrics.resolved} color="bg-green-50 text-green-700 border-green-200" />
        <MetricCard label="Escalated Alerts" value={metrics.escalated} color="bg-purple-50 text-purple-700 border-purple-200" />
      </div>

      <section className="rounded-xl border border-border bg-card shadow-sm">
        {/* Filters Panel */}
        <header className="border-b border-border p-4 space-y-3">
          <div className="flex items-center gap-2">
            <ShieldAlert className="h-4.5 w-4.5 text-yellow-500" />
            <h3 className="text-sm font-semibold">PMO Health & Governance Governance Panel</h3>
          </div>
          <div className="grid grid-cols-2 md:grid-cols-5 gap-2.5 text-xs">
            <div className="flex flex-col gap-1">
              <span className="text-[10px] font-bold text-muted-foreground uppercase">Project</span>
              <select value={projFilter} onChange={(e) => setProjFilter(e.target.value)} className="form-input rounded-md border border-border p-1.5 bg-card">
                <option value="all">All Projects</option>
                {projectsList.map((p) => <option key={p.id} value={p.id}>{p.name}</option>)}
              </select>
            </div>
            <div className="flex flex-col gap-1">
              <span className="text-[10px] font-bold text-muted-foreground uppercase">Client</span>
              <select value={clientFilter} onChange={(e) => setClientFilter(e.target.value)} className="form-input rounded-md border border-border p-1.5 bg-card">
                <option value="all">All Clients</option>
                {clientsList.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
              </select>
            </div>
            <div className="flex flex-col gap-1">
              <span className="text-[10px] font-bold text-muted-foreground uppercase">Priority</span>
              <select value={prioFilter} onChange={(e) => setPrioFilter(e.target.value)} className="form-input rounded-md border border-border p-1.5 bg-card">
                <option value="all">All Priorities</option>
                {(["Low", "Medium", "High", "Critical"] as const).map((pr) => (
                  <option key={pr} value={pr}>{pr}</option>
                ))}
              </select>
            </div>
            <div className="flex flex-col gap-1">
              <span className="text-[10px] font-bold text-muted-foreground uppercase">Alert Type</span>
              <select value={typeFilter} onChange={(e) => setTypeFilter(e.target.value)} className="form-input rounded-md border border-border p-1.5 bg-card">
                <option value="all">All Types</option>
                {alertTypes.map((t) => <option key={t} value={t}>{t}</option>)}
              </select>
            </div>
            <div className="flex flex-col gap-1">
              <span className="text-[10px] font-bold text-muted-foreground uppercase">Status</span>
              <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} className="form-input rounded-md border border-border p-1.5 bg-card">
                <option value="all">All Statuses</option>
                {(["Open", "Acknowledged", "In Progress", "Waiting for Client", "Resolved", "Closed"] as const).map((s) => (
                  <option key={s} value={s}>{s}</option>
                ))}
              </select>
            </div>
          </div>
        </header>

        {filtered.length === 0 ? (
          <div className="p-8 text-center">
            <p className="text-sm text-muted-foreground">No governance alerts found matching the active filters.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
                <tr>
                  <th className="px-3 py-2 font-medium">Alert ID</th>
                  <th className="px-3 py-2 font-medium">Alert Title</th>
                  <th className="px-3 py-2 font-medium">Project Name</th>
                  <th className="px-3 py-2 font-medium">Client Name</th>
                  <th className="px-3 py-2 font-medium">Alert Type</th>
                  <th className="px-3 py-2 font-medium">Priority</th>
                  <th className="px-3 py-2 font-medium">Raised By</th>
                  <th className="px-3 py-2 font-medium">Raised Date</th>
                  <th className="px-3 py-2 font-medium">Status</th>
                  <th className="px-3 py-2 font-medium text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {filtered.map((alert) => {
                  const project = projectsList.find((p) => p.id === alert.projectId);
                  const client = clientsList.find((c) => c.id === project?.clientId);
                  return (
                    <tr key={alert.id} className="hover:bg-accent/30">
                      <td className="px-3 py-2.5 font-mono text-xs font-bold text-gray-800">{alert.alertId || "ALT-GEN"}</td>
                      <td className="px-3 py-2.5 font-medium text-gray-700">{alert.title}</td>
                      <td className="px-3 py-2.5 text-xs text-muted-foreground font-semibold">{project?.name || "—"}</td>
                      <td className="px-3 py-2.5 text-xs text-muted-foreground">{client?.name || "—"}</td>
                      <td className="px-3 py-2.5">
                        <span className="inline-flex rounded-full border border-border bg-muted px-2 py-0.5 text-[9px] font-bold text-gray-700">
                          {alert.alertType || alert.kind}
                        </span>
                      </td>
                      <td className="px-3 py-2.5"><PriorityPill priority={alert.priority.toLowerCase() as any} /></td>
                      <td className="px-3 py-2.5 text-xs font-medium">{alert.raisedByName}</td>
                      <td className="px-3 py-2.5 text-xs tabular-nums text-muted-foreground">{new Date(alert.createdAt).toLocaleDateString()}</td>
                      <td className="px-3 py-2.5">
                        <span className={cn("inline-flex rounded-full border px-2 py-0.5 text-[10px] font-medium capitalize",
                          alert.status === "Open" ? "bg-orange-50 text-orange-700 border-orange-200" :
                            alert.status === "In Progress" ? "bg-blue-50 text-blue-700 border-blue-200" :
                              alert.status === "Resolved" || alert.status === "Closed" ? "bg-green-50 text-green-700 border-green-200" :
                                alert.status === "Waiting for Client" ? "bg-purple-50 text-purple-700 border-purple-200" :
                                  "bg-muted text-muted-foreground border-border"
                        )}>
                          {alert.status}
                        </span>
                      </td>
                      <td className="px-3 py-2.5 text-right">
                        <button onClick={() => openDetails(alert.id)} className="rounded-md border border-input bg-card px-2.5 py-1 text-xs hover:bg-accent font-medium text-primary">
                          Review details
                        </button>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </section>

      {/* Alert Details Modal */}
      {selectedAlert && (
        <Modal title={selectedAlert.kind === "Escalation" ? `Escalation Review Details — ${selectedAlert.alertId || "ALT-GEN"}` : `Governance Alert Details — ${selectedAlert.alertId || "ALT-GEN"}`} onClose={() => setSelectedAlertId(null)} wide>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">
            {/* Left side details */}
            <div className="md:col-span-2 space-y-4">
              <div className="rounded-lg border border-border p-3 bg-muted/10 space-y-1">
                <span className="font-semibold text-[10px] text-muted-foreground uppercase">{selectedAlert.kind === "Escalation" ? "Escalation Subject" : "Alert Title"}</span>
                <p className="text-sm font-bold text-gray-800">{selectedAlert.title}</p>
              </div>

              {selectedAlert.kind === "Escalation" && (
                <div className="bg-muted/30 border border-border rounded-lg p-3 grid grid-cols-2 gap-3">
                  <div>
                    <span className="text-[9px] uppercase font-bold text-muted-foreground block">Service Name</span>
                    <span className="font-semibold text-primary">{selectedAlert.serviceName || "—"}</span>
                  </div>
                  <div>
                    <span className="text-[9px] uppercase font-bold text-muted-foreground block">Escalation Type</span>
                    <span className="font-semibold text-gray-800">{selectedAlert.escalationType || "—"}</span>
                  </div>
                  <div>
                    <span className="text-[9px] uppercase font-bold text-muted-foreground block">Raised By</span>
                    <span className="font-semibold text-gray-800">{selectedAlert.raisedByName || "—"}</span>
                  </div>
                  {selectedAlert.expectedResolutionDate && (
                    <div>
                      <span className="text-[9px] uppercase font-bold text-muted-foreground block">Expected Resolution Date</span>
                      <span className="font-semibold text-gray-800">{selectedAlert.expectedResolutionDate}</span>
                    </div>
                  )}
                </div>
              )}

              <div className="rounded-lg border border-border p-3 bg-card space-y-2">
                <span className="font-semibold text-[10px] text-muted-foreground uppercase block border-b border-border pb-1">Full Description</span>
                <p className="text-xs text-gray-700 leading-relaxed font-medium">{selectedAlert.description || "No full description provided."}</p>
              </div>

              <div className="rounded-lg border border-border p-3 bg-card space-y-3">
                <span className="font-semibold text-[10px] text-muted-foreground uppercase block border-b border-border pb-1">Governance Allocation & Ownership</span>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-2">
                  <div className="flex flex-col gap-1">
                    <span className="text-[10px] font-bold text-muted-foreground">Alert Owner</span>
                    <select value={selectedOwner} onChange={(e) => setSelectedOwner(e.target.value)} className="form-input rounded-md border border-border p-1 bg-card">
                      <option value="">Unassigned</option>
                      {people.map((p) => <option key={p.id} value={p.name}>{p.name}</option>)}
                    </select>
                  </div>
                  <div className="flex flex-col gap-1">
                    <span className="text-[10px] font-bold text-muted-foreground">Resolution Owner</span>
                    <select value={selectedResOwner} onChange={(e) => setSelectedResOwner(e.target.value)} className="form-input rounded-md border border-border p-1 bg-card">
                      <option value="">Unassigned</option>
                      {people.map((p) => <option key={p.id} value={p.name}>{p.name}</option>)}
                    </select>
                  </div>
                  <div className="flex flex-col gap-1">
                    <span className="text-[10px] font-bold text-muted-foreground">Escalation Owner</span>
                    <select value={selectedEscOwner} onChange={(e) => setSelectedEscOwner(e.target.value)} className="form-input rounded-md border border-border p-1 bg-card">
                      <option value="">Unassigned</option>
                      {people.map((p) => <option key={p.id} value={p.name}>{p.name}</option>)}
                    </select>
                  </div>
                </div>
              </div>

              {/* Resolution Progress */}
              <div className="rounded-lg border border-border p-3 bg-card space-y-2">
                <span className="font-semibold text-[10px] text-muted-foreground uppercase block border-b border-border pb-1">Resolution Timeline Details</span>
                <textarea
                  value={resDetails}
                  onChange={(e) => setResDetails(e.target.value)}
                  placeholder="Document resolution steps, technical outcomes, or internal timeline here..."
                  rows={2}
                  className="w-full rounded-md border border-border bg-card p-2 text-xs outline-none focus-visible:ring-1 focus-visible:ring-ring"
                />
              </div>

              {/* History Timeline Logs */}
              {selectedAlert.history && selectedAlert.history.length > 0 && (
                <div className="rounded-lg border border-border p-3 bg-card space-y-2">
                  <span className="font-semibold text-[10px] text-muted-foreground uppercase block border-b border-border pb-1">Status Transitions Timeline</span>
                  <div className="space-y-1.5 pl-1 max-h-32 overflow-y-auto">
                    {selectedAlert.history.map((h, idx) => (
                      <div key={idx} className="flex gap-2 text-[10px]">
                        <span className="text-muted-foreground tabular-nums">{new Date(h.at).toLocaleDateString()} {new Date(h.at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}:</span>
                        <span>Status transitioned to <strong className="text-gray-800">{h.status}</strong> by {h.updatedBy} {h.details ? `— "${h.details}"` : ""}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>

            {/* Right side communications thread */}
            <div className="space-y-4 flex flex-col justify-between">
              <div className="space-y-3">
                <div className="rounded-lg border border-border p-3 bg-card space-y-2">
                  <span className="font-semibold text-[10px] text-muted-foreground uppercase block border-b border-border pb-1">Project Link</span>
                  {selectedAlert.projectId ? (
                    <Link
                      to="/projects/$projectId"
                      params={{ projectId: selectedAlert.projectId }}
                      hash="health-alerts"
                      className="inline-flex items-center gap-1 bg-primary/10 text-primary border border-primary/20 rounded-md px-2.5 py-1.5 font-bold hover:bg-primary/20 text-xs w-full justify-between"
                    >
                      <span>
                        {projectsList.find(p => p.id === selectedAlert.projectId)?.name || "Go to project"}
                      </span>
                      <ExternalLink className="h-3 w-3" />
                    </Link>
                  ) : (
                    <span className="text-muted-foreground italic">No linked project.</span>
                  )}
                </div>

                <div className="rounded-lg border border-border p-3 bg-card space-y-1.5">
                  <span className="font-semibold text-[10px] text-muted-foreground uppercase block">Attachments</span>
                  {selectedAlert.attachments && selectedAlert.attachments.length > 0 ? (
                    <div className="space-y-1">
                      {selectedAlert.attachments.map((file, idx) => (
                        <div key={idx} className="flex items-center gap-1.5 text-[10px] text-primary hover:underline cursor-pointer">
                          <Paperclip className="h-3 w-3 text-muted-foreground" />
                          <span>{file}</span>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <span className="text-muted-foreground italic text-[10px]">No attachments.</span>
                  )}
                </div>

                {/* Escalated To */}
                {selectedAlert.kind === "Escalation" && selectedAlert.escalatedTo && (
                  <div className="rounded-lg border border-border p-3 bg-muted/10 space-y-1">
                    <span className="font-semibold text-[10px] text-muted-foreground uppercase block">Escalated To</span>
                    <p className="text-xs font-semibold text-primary truncate" title={selectedAlert.escalatedTo.join(", ")}>
                      {selectedAlert.escalatedTo.join(", ")}
                    </p>
                  </div>
                )}

                {/* Status Switcher — hidden for Escalation kind (only creator can change status via project Health tab) */}
                {selectedAlert.kind !== "Escalation" && (
                <div className="rounded-lg border border-border p-3 bg-card space-y-2">
                  <span className="font-semibold text-[10px] text-muted-foreground uppercase block">{isRequirementAlert ? "Status" : "Set Status"}</span>
                  {isRequirementAlert ? (
                    // Requirement alerts start as Open; status is updated later by the
                    // assigned manager / higher authority, not from this window.
                    <div className={cn(
                      "w-full rounded-md border p-2 text-xs font-bold shadow-xs",
                      selectedAlert.status === "Resolved" || selectedAlert.status === "Closed" ? "bg-emerald-50 border-emerald-200 text-emerald-700" :
                        selectedAlert.status === "Open" ? "bg-orange-50 border-orange-200 text-orange-700" :
                          "bg-gray-50 border-gray-200 text-gray-600"
                    )}>
                      {selectedAlert.status}
                    </div>
                  ) : (
                  <select
                    value={selectedStatus}
                    onChange={(e) => setSelectedStatus(e.target.value as any)}
                    className={cn(
                      "w-full rounded-md border p-2 text-xs font-bold shadow-xs transition-colors cursor-pointer outline-none focus-visible:ring-1 focus-visible:ring-ring",
                      selectedStatus === "Resolved" || selectedStatus === "Closed" ? "bg-emerald-50 border-emerald-200 text-emerald-700 hover:bg-emerald-100" :
                        selectedStatus === "Open" ? "bg-orange-50 border-orange-200 text-orange-700 hover:bg-orange-100" :
                          selectedStatus === "In Progress" ? "bg-blue-50 border-blue-200 text-blue-700 hover:bg-blue-100" :
                            selectedStatus === "Waiting for Client" ? "bg-purple-50 border-purple-200 text-purple-700 hover:bg-purple-100" :
                              "bg-gray-50 border-gray-200 text-gray-600 hover:bg-gray-100"
                    )}
                  >
                    {(["Open", "In Progress", "Resolved", "Closed"] as const).map((s) => (
                        <option key={s} value={s}>{s}</option>
                      ))
                    }
                  </select>
                  )}
                </div>
                )}
                {selectedAlert.kind === "Escalation" && (
                <div className="rounded-lg border border-border p-3 bg-muted/20 space-y-2">
                  <span className="font-semibold text-[10px] text-muted-foreground uppercase block">Status</span>
                  <div className="flex items-center gap-2">
                    <span className={cn(
                      "inline-flex items-center gap-1.5 rounded-full border px-2.5 py-1 text-xs font-bold",
                      selectedAlert.status === "Closed"
                        ? "bg-emerald-50 border-emerald-200 text-emerald-700"
                        : "bg-orange-50 border-orange-200 text-orange-700"
                    )}>
                      {selectedAlert.status === "Closed" ? "⚫" : "🟢"} {selectedAlert.status}
                    </span>
                    <span className="text-[9px] text-muted-foreground italic">Only the escalation creator can change this status</span>
                  </div>
                </div>
                )}

                {/* Discussion Area Comment box */}
                <div className="rounded-lg border border-border p-3 bg-card space-y-2">
                  <span className="font-semibold text-[10px] text-muted-foreground uppercase block border-b border-border pb-1">Discussion Chat Thread</span>
                  <div className="space-y-2 max-h-36 overflow-y-auto pl-1 pr-0.5 text-[10px] leading-relaxed">
                    {selectedAlert.comments.map((cm) => (
                      <div key={cm.id} className="bg-muted/30 border border-border p-2 rounded-md space-y-0.5">
                        <div className="flex justify-between font-semibold text-gray-800 text-[9px]">
                          <span>{cm.authorName}</span>
                          <span className="text-muted-foreground">{new Date(cm.at).toLocaleDateString()}</span>
                        </div>
                        <p className="text-gray-700">{cm.text}</p>
                      </div>
                    ))}
                    {selectedAlert.comments.length === 0 && (
                      <span className="text-muted-foreground italic text-[10px]">No chat messages yet.</span>
                    )}
                  </div>
                  <textarea
                    value={newChatMsg}
                    onChange={(e) => setNewChatMsg(e.target.value)}
                    placeholder="Type an internal governance comment or reply..."
                    rows={2}
                    className="w-full rounded-md border border-border p-1.5 text-xs bg-card outline-none focus-visible:ring-1 focus-visible:ring-ring mt-2"
                  />
                </div>
              </div>

              <div className="flex justify-end gap-2 border-t border-border pt-3">
                {isRequirementAlert ? (
                  <>
                    <button
                      onClick={() => {
                        setApproved(true);
                        toast.success("Requirement approved — click Update to save");
                      }}
                      className={cn(
                        "rounded-md border px-3.5 py-1.5 text-xs font-medium transition-colors",
                        approved
                          ? "border-emerald-600 bg-emerald-600 text-white"
                          : "border-emerald-300 bg-emerald-50 text-emerald-700 hover:bg-emerald-100"
                      )}
                    >
                      {approved ? "Approved ✓" : "Approve"}
                    </button>
                    <button
                      onClick={() => {
                        // TODO: notify the manager assigned to this project on reject (to be wired later)
                        toast("Requirement rejected — manager notification will be enabled later");
                        setSelectedAlertId(null);
                      }}
                      className="rounded-md border border-red-300 bg-red-50 px-3.5 py-1.5 text-xs font-medium text-red-700 hover:bg-red-100"
                    >
                      Reject
                    </button>
                    <button
                      onClick={handleUpdateAlert}
                      disabled={!approved}
                      className={cn(
                        "rounded-md px-3.5 py-1.5 text-xs font-medium transition-colors",
                        approved
                          ? "bg-primary text-primary-foreground hover:bg-primary/90"
                          : "border border-border bg-muted text-muted-foreground cursor-not-allowed"
                      )}
                    >
                      Update
                    </button>
                  </>
                ) : (
                  <>
                    <button onClick={() => setSelectedAlertId(null)} className="rounded-md border border-input bg-card px-3.5 py-1.5 text-xs font-medium hover:bg-accent">
                      Cancel
                    </button>
                    <button
                      onClick={handleUpdateAlert}
                      className="rounded-md bg-primary px-3.5 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90"
                    >
                      Save Governance Changes
                    </button>
                  </>
                )}
              </div>
            </div>
          </div>
        </Modal>
      )}
    </>
  );
}

function NotificationsTab() {
  const store = useDhStore((s) => s);
  const { user } = useRoleContext();
  const [subTab, setSubTab] = useState<"Current" | "Archived">("Current");

  // Search state
  const [searchQuery, setSearchQuery] = useState("");

  // Filters state
  const [typeFilter, setTypeFilter] = useState("all");
  const [priorityFilter, setPriorityFilter] = useState("all");
  const [dateFilter, setDateFilter] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");

  // Modal details state
  const [selectedNotifId, setSelectedNotifId] = useState<string | null>(null);
  const [commentText, setCommentText] = useState("");
  const [showCommentError, setShowCommentError] = useState(false);

  const notifications = store.notifications || [];

  // Metrics
  const totalCount = notifications.length;
  const pendingCount = notifications.filter(n => n.status === "Pending").length;
  const criticalPendingCount = notifications.filter(n => n.status === "Pending" && (n.priority === "Critical" || n.priority === "High")).length;
  const archivedCount = notifications.filter(n => n.status === "Acknowledged").length;

  // Formatting helpers matching images
  const formatNotifDate = (dateStr: string): string => {
    try {
      const d = new Date(dateStr);
      if (isNaN(d.getTime())) return dateStr;
      const day = d.getDate();
      const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      const month = months[d.getMonth()];
      const year = d.getFullYear();
      return `${day} ${month} ${year}`;
    } catch (e) {
      return dateStr;
    }
  };

  const formatNotifTime = (dateStr: string): string => {
    try {
      const d = new Date(dateStr);
      if (isNaN(d.getTime())) return "12:00";
      const hours = String(d.getHours()).padStart(2, '0');
      const minutes = String(d.getMinutes()).padStart(2, '0');
      return `${hours}:${minutes}`;
    } catch (e) {
      return "12:00";
    }
  };

  // Type styles helper
  const getTypeStyles = (type: string) => {
    const t = type.toLowerCase();
    if (t.includes("wbs")) {
      return "bg-orange-50 text-orange-700 border border-orange-200";
    } else if (t.includes("ready") || t.includes("completed") || t.includes("resolved") || t.includes("approved")) {
      return "bg-emerald-50 text-emerald-700 border border-emerald-200";
    } else if (t.includes("rejected") || t.includes("cancelled") || t.includes("removal")) {
      return "bg-red-50 text-red-700 border border-red-200";
    } else if (t.includes("changes") || t.includes("requirement") || t.includes("approval")) {
      return "bg-amber-50 text-amber-700 border border-amber-200";
    } else if (t.includes("interview") || t.includes("shuffle") || t.includes("allocation") || t.includes("assignment")) {
      return "bg-sky-50 text-sky-700 border border-sky-200";
    }
    return "bg-gray-50 text-gray-700 border border-gray-200";
  };

  // Filter & Search Logic
  const filteredNotifications = useMemo(() => {
    return notifications.filter((n) => {
      // 1. Sub-tab filter
      if (subTab === "Current") {
        const isCurrent = n.status === "Pending" || n.unread;
        if (!isCurrent) return false;
      } else {
        const isArchived = n.status === "Acknowledged";
        if (!isArchived) return false;
      }

      // 2. Search query filter (Project, Task, Notification Type, Employee, Title)
      if (searchQuery.trim()) {
        const query = searchQuery.toLowerCase();
        const matchesProject = n.relatedProject.toLowerCase().includes(query);
        const matchesTask = n.relatedTask ? n.relatedTask.toLowerCase().includes(query) : false;
        const matchesType = n.type.toLowerCase().includes(query);
        const matchesEmployee = n.raisedBy.toLowerCase().includes(query);
        const matchesTitle = n.title.toLowerCase().includes(query);

        if (!matchesProject && !matchesTask && !matchesType && !matchesEmployee && !matchesTitle) {
          return false;
        }
      }

      // 3. Dropdown/Inputs filters
      if (typeFilter !== "all" && n.type !== typeFilter) return false;
      if (priorityFilter !== "all" && n.priority.toLowerCase() !== priorityFilter.toLowerCase()) return false;
      if (statusFilter !== "all" && n.status.toLowerCase() !== statusFilter.toLowerCase()) return false;
      if (dateFilter) {
        const notifDate = n.createdAt.slice(0, 10);
        if (notifDate !== dateFilter) return false;
      }

      return true;
    });
  }, [notifications, subTab, searchQuery, typeFilter, priorityFilter, dateFilter, statusFilter]);

  const selectedNotification = useMemo(() => {
    return notifications.find(n => n.id === selectedNotifId);
  }, [notifications, selectedNotifId]);

  const handleOpenDetails = (id: string) => {
    dhStore.markNotificationAsRead(id);
    setSelectedNotifId(id);
    setCommentText("");
    setShowCommentError(false);
  };

  const handleConfirmAcknowledge = () => {
    if (!selectedNotification) return;
    if (!commentText.trim()) {
      setShowCommentError(true);
      return;
    }
    dhStore.acknowledgeNotification(selectedNotification.id, user.name, commentText);
    toast.success("Notification Acknowledged Persistently!");
    setSelectedNotifId(null);
    setCommentText("");
    setShowCommentError(false);
  };

  const totalSubtabCount = subTab === "Current" ? pendingCount : archivedCount;

  return (
    <>
      {/* Metrics Dashboard Cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4">
        {/* TOTAL NOTIFICATIONS */}
        <div className="rounded-xl border border-blue-200 bg-blue-50/15 p-4 flex flex-col justify-between shadow-xs">
          <span className="text-[10px] font-bold text-blue-600 uppercase tracking-wider">Total Notifications</span>
          <span className="text-2xl font-bold text-blue-900 mt-1">{totalCount}</span>
        </div>

        {/* PENDING */}
        <div className="rounded-xl border border-amber-250 bg-amber-50/15 p-4 flex flex-col justify-between shadow-xs">
          <span className="text-[10px] font-bold text-amber-600 uppercase tracking-wider">Pending</span>
          <span className="text-2xl font-bold text-amber-900 mt-1">{pendingCount}</span>
        </div>

        {/* CRITICAL PENDING */}
        <div className="rounded-xl border border-red-200 bg-red-50/15 p-4 flex flex-col justify-between shadow-xs">
          <span className="text-[10px] font-bold text-red-600 uppercase tracking-wider">Critical Pending</span>
          <span className="text-2xl font-bold text-red-900 mt-1">{criticalPendingCount}</span>
        </div>

        {/* ARCHIVED */}
        <div className="rounded-xl border border-emerald-250 bg-emerald-50/15 p-4 flex flex-col justify-between shadow-xs">
          <span className="text-[10px] font-bold text-emerald-600 uppercase tracking-wider">Archived</span>
          <span className="text-2xl font-bold text-emerald-900 mt-1">{archivedCount}</span>
        </div>
      </div>

      {/* Notification Inbox Container */}
      <div className="border border-border rounded-xl bg-card shadow-sm p-4 space-y-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Bell className="h-5 w-5 text-primary" />
            <span className="font-bold text-gray-800 text-sm">Notification Inbox</span>
          </div>
          <span className="text-xs text-muted-foreground">
            {filteredNotifications.length} of {totalSubtabCount} shown
          </span>
        </div>

        {/* Search */}
        <div className="relative">
          <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search by project, task, type, employee..."
            className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring border-border"
          />
        </div>

        {/* Filters */}
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-3 text-[11px] leading-relaxed">
          <div className="flex flex-col gap-1">
            <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider">Notification Type</span>
            <select
              value={typeFilter}
              onChange={(e) => setTypeFilter(e.target.value)}
              className="form-input rounded-md border border-border p-1.5 bg-card outline-none focus-visible:ring-1 focus-visible:ring-primary"
            >
              <option value="all">All Types</option>
              {NOTIFICATION_TYPES.map((t) => (
                <option key={t} value={t}>{t}</option>
              ))}
            </select>
          </div>

          <div className="flex flex-col gap-1">
            <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider">Priority</span>
            <select
              value={priorityFilter}
              onChange={(e) => setPriorityFilter(e.target.value)}
              className="form-input rounded-md border border-border p-1.5 bg-card outline-none focus-visible:ring-1 focus-visible:ring-primary"
            >
              <option value="all">All Priorities</option>
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
              <option value="critical">Critical</option>
            </select>
          </div>

          <div className="flex flex-col gap-1">
            <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider">Date</span>
            <input
              type="date"
              value={dateFilter}
              onChange={(e) => setDateFilter(e.target.value)}
              placeholder="dd-mm-yyyy"
              className="form-input rounded-md border border-border p-1.5 bg-card outline-none focus-visible:ring-1 focus-visible:ring-primary text-xs"
            />
          </div>

          <div className="flex flex-col gap-1">
            <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider">Status</span>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="form-input rounded-md border border-border p-1.5 bg-card outline-none focus-visible:ring-1 focus-visible:ring-primary"
            >
              <option value="all">All Statuses</option>
              <option value="pending">Pending</option>
              <option value="acknowledged">Acknowledged</option>
            </select>
          </div>
        </div>

        {/* Sub-tabs line selector */}
        <div className="flex gap-4 border-b border-border pb-1 mt-2">
          {(["Current", "Archived"] as const).map((st) => {
            const count = notifications.filter(n => {
              if (st === "Current") {
                return n.status === "Pending" || n.unread;
              } else {
                return n.status === "Acknowledged";
              }
            }).length;

            return (
              <button
                key={st}
                onClick={() => setSubTab(st)}
                className={cn(
                  "border-b-2 px-4 py-2 text-sm font-medium transition-all -mb-[6px] flex items-center gap-1.5 cursor-pointer",
                  subTab === st ? "border-primary text-foreground" : "border-transparent text-muted-foreground hover:text-foreground"
                )}
              >
                {st === "Current" ? <Bell className="h-3.5 w-3.5" /> : <Archive className="h-3.5 w-3.5" />}
                <span>{st}</span>
                <span className="rounded-full bg-muted px-1.5 py-0.5 text-[10px] font-semibold text-muted-foreground">
                  {count}
                </span>
              </button>
            );
          })}
        </div>

        {/* Notifications Table */}
        <div className="overflow-x-auto border border-border rounded-xl">
          <table className="min-w-full divide-y divide-border text-sm leading-relaxed text-left">
            <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
              <tr>
                <th className="px-3 py-2 font-medium min-w-[340px] w-[35%]">Notification Title</th>
                <th className="px-3 py-2 font-medium">Type</th>
                <th className="px-3 py-2 font-medium max-w-[180px]">Related Project</th>
                <th className="px-3 py-2 font-medium max-w-[150px]">Related Task</th>
                <th className="px-3 py-2 font-medium">Raised By</th>
                <th className="px-3 py-2 font-medium">Date</th>
                <th className="px-3 py-2 font-medium">Time</th>
                <th className="px-3 py-2 font-medium">Status</th>
                <th className="px-3 py-2 font-medium">Priority</th>
                {subTab === "Current" && <th className="px-3 py-2 font-medium text-right">Actions</th>}
              </tr>
            </thead>
            <tbody className="divide-y divide-border/60 align-middle">
              {filteredNotifications.length === 0 ? (
                <tr>
                  <td colSpan={10} className="p-8 text-center text-muted-foreground">
                    No notifications matching search and filters.
                  </td>
                </tr>
              ) : (
                filteredNotifications.map((n) => (
                  <tr key={n.id} className="hover:bg-muted/10 transition-colors">
                    {/* Title */}
                    <td className="px-3 py-2.5 min-w-[340px] w-[35%]">
                      <div className="flex items-start gap-1.5">
                        {n.unread && (
                          <span className="text-primary mt-1 text-[10px] select-none">●</span>
                        )}
                        <button
                          onClick={() => handleOpenDetails(n.id)}
                          className="text-left font-medium text-gray-800 hover:text-primary transition-colors cursor-pointer hover:underline block w-full"
                        >
                          {n.title}
                        </button>
                      </div>
                    </td>

                    {/* Type Badge */}
                    <td className="px-3 py-2.5 whitespace-nowrap">
                      <span className={cn(
                        "inline-flex rounded-full px-2.5 py-0.5 text-[9px] font-bold uppercase tracking-wider",
                        getTypeStyles(n.type)
                      )}>
                        {n.type}
                      </span>
                    </td>

                    {/* Related Project */}
                    <td className="px-3 py-2.5 text-xs text-muted-foreground max-w-[180px] break-words">
                      {n.relatedProject}
                    </td>

                    {/* Related Task */}
                    <td className="px-3 py-2.5 text-xs text-muted-foreground max-w-[150px] break-words">
                      {n.relatedTask || "—"}
                    </td>

                    {/* Raised By */}
                    <td className="px-3 py-2.5 whitespace-nowrap">
                      <div className="flex items-center gap-2">
                        <Avatar name={n.raisedBy} size={24} />
                        <span className="text-xs">{n.raisedBy}</span>
                      </div>
                    </td>

                    {/* Date */}
                    <td className="px-3 py-2.5 text-xs tabular-nums text-muted-foreground whitespace-nowrap">
                      {formatNotifDate(n.createdAt)}
                    </td>

                    {/* Time */}
                    <td className="px-3 py-2.5 text-xs tabular-nums text-muted-foreground whitespace-nowrap font-mono">
                      {formatNotifTime(n.createdAt)}
                    </td>

                    {/* Status Badge */}
                    <td className="px-3 py-2.5 whitespace-nowrap">
                      <span className={cn(
                        "inline-flex rounded-full border px-2 py-0.5 text-[9px] font-bold capitalize items-center gap-1",
                        n.status === "Acknowledged" ? "bg-emerald-50 text-emerald-700 border-emerald-200" : "bg-orange-50 text-orange-700 border-orange-200"
                      )}>
                        {n.status === "Acknowledged" ? (
                          <>
                            <Check className="h-2.5 w-2.5" />
                            <span>Acknowledged</span>
                          </>
                        ) : (
                          <>
                            <Clock className="h-2.5 w-2.5" />
                            <span>Pending</span>
                          </>
                        )}
                      </span>
                    </td>

                    {/* Priority */}
                    <td className="px-3 py-2.5 whitespace-nowrap">
                      <PriorityPill priority={n.priority.toLowerCase() as any} />
                    </td>

                    {/* Actions */}
                    {subTab === "Current" && (
                      <td className="px-3 py-2.5 pr-4 text-right whitespace-nowrap">
                        {n.status === "Pending" ? (
                          <button
                            onClick={() => handleOpenDetails(n.id)}
                            className="inline-flex items-center gap-1 rounded-md border border-success text-success bg-transparent hover:bg-success/10 px-2.5 py-1 text-xs font-semibold cursor-pointer transition-colors"
                          >
                            <Check className="h-3.5 w-3.5" /> Acknowledge
                          </button>
                        ) : (
                          <span className="text-muted-foreground">—</span>
                        )}
                      </td>
                    )}
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Details & Interactive Comment Modal */}
      {selectedNotification && (
        <Modal
          title={`Notification Details — ${selectedNotification.id}`}
          onClose={() => setSelectedNotifId(null)}
          wide
        >
          <div className="space-y-4 text-xs">
            {/* Top pill badges and Large Title */}
            <div className="space-y-2">
              <div className="flex flex-wrap gap-2">
                <span className={cn(
                  "inline-flex rounded-full px-2.5 py-0.5 text-[9px] font-bold uppercase tracking-wider",
                  getTypeStyles(selectedNotification.type)
                )}>
                  {selectedNotification.type}
                </span>
                <PriorityPill priority={selectedNotification.priority.toLowerCase() as any} />
                <span className={cn(
                  "inline-flex rounded-full border px-2.5 py-0.5 text-[9px] font-bold capitalize items-center gap-1",
                  selectedNotification.status === "Acknowledged" ? "bg-emerald-50 text-emerald-700 border-emerald-200" : "bg-orange-50 text-orange-700 border-orange-200"
                )}>
                  {selectedNotification.status === "Acknowledged" ? <Check className="h-2.5 w-2.5" /> : <Clock className="h-2.5 w-2.5" />}
                  {selectedNotification.status}
                </span>
              </div>
              <h3 className="text-base font-bold text-gray-800 leading-snug">
                {selectedNotification.title}
              </h3>
            </div>

            {/* Metadata Grid */}
            <div className="grid grid-cols-2 md:grid-cols-3 gap-y-3.5 gap-x-6 border border-border rounded-xl p-4 bg-muted/5">
              <div>
                <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">Related Project</span>
                <span className="font-semibold text-gray-800">{selectedNotification.relatedProject}</span>
              </div>
              <div>
                <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">Related Task</span>
                <span className="font-semibold text-gray-800">{selectedNotification.relatedTask || "—"}</span>
              </div>
              <div>
                <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">Raised By</span>
                <div className="flex items-center gap-1.5 mt-0.5">
                  <Avatar name={selectedNotification.raisedBy} size={18} />
                  <span className="font-semibold text-gray-700">{selectedNotification.raisedBy}</span>
                </div>
              </div>
              <div>
                <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">Date</span>
                <span className="font-medium text-gray-800">{formatNotifDate(selectedNotification.createdAt)}</span>
              </div>
              <div>
                <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">Time</span>
                <span className="font-medium text-gray-800 font-mono">{formatNotifTime(selectedNotification.createdAt)}</span>
              </div>
              <div>
                <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">Notification ID</span>
                <span className="font-bold text-gray-800">{selectedNotification.id}</span>
              </div>
            </div>

            {/* Awaiting acknowledgement warning box */}
            {selectedNotification.status === "Pending" && (
              <div className="bg-orange-50 border border-orange-200 rounded-xl p-3.5 text-xs text-orange-800 space-y-0.5">
                <div className="font-semibold">This notification is awaiting acknowledgement.</div>
                <div className="text-orange-700">Add your comment and click Acknowledge to confirm you have reviewed this notification.</div>
              </div>
            )}

            {/* Mandatory Comment Area */}
            {selectedNotification.status === "Pending" ? (
              <div className="space-y-1">
                <label className="block text-xs font-bold text-gray-700">
                  Acknowledgement Comment <span className="text-red-500">* Mandatory</span>
                </label>
                <textarea
                  value={commentText}
                  onChange={(e) => {
                    setCommentText(e.target.value);
                    if (e.target.value.trim()) setShowCommentError(false);
                  }}
                  placeholder="Enter your acknowledgement remarks before confirming..."
                  rows={3}
                  className={cn(
                    "w-full rounded-lg border p-3 text-xs outline-none focus-visible:ring-1 focus-visible:ring-primary focus:border-primary/55 bg-card",
                    showCommentError ? "border-red-500" : "border-border"
                  )}
                />
                {showCommentError && (
                  <p className="text-[11px] text-red-500 mt-1 flex items-center gap-1 font-semibold select-none">
                    ⚠ Comment is required to acknowledge this notification.
                  </p>
                )}
              </div>
            ) : (
              // Read-only comment box for Acknowledged
              <div className="bg-emerald-50 border border-emerald-100 rounded-xl p-3.5 text-xs text-emerald-800 space-y-1">
                <div className="font-semibold">This notification has been acknowledged.</div>
                <div className="text-emerald-700">
                  Acknowledged by <strong>{selectedNotification.acknowledgedBy}</strong> on {formatNotifDate(selectedNotification.acknowledgedDate || "")} at {selectedNotification.acknowledgedTime}.
                </div>
              </div>
            )}

            {/* Audit History Card */}
            <div className="border border-border rounded-xl p-4 bg-card space-y-3 shadow-xs">
              <span className="font-bold text-muted-foreground uppercase text-[10px] tracking-wider block border-b border-border/50 pb-1">
                Audit History
              </span>
              <div className="grid grid-cols-3 gap-4 text-[11px] leading-relaxed">
                <div>
                  <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider">Created By</span>
                  <span className="font-semibold text-gray-700">{selectedNotification.createdBy}</span>
                </div>
                <div>
                  <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider">Created Date</span>
                  <span className="font-medium text-gray-755">{formatNotifDate(selectedNotification.createdAt)}</span>
                </div>
                <div>
                  <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider">Created Time</span>
                  <span className="font-medium text-gray-755 font-mono">{formatNotifTime(selectedNotification.createdAt)}</span>
                </div>

                {selectedNotification.status === "Acknowledged" && (
                  <>
                    <div>
                      <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider">Acknowledged By</span>
                      <span className="font-bold text-emerald-700">{selectedNotification.acknowledgedBy}</span>
                    </div>
                    <div>
                      <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider">Acknowledged Date</span>
                      <span className="font-semibold text-emerald-700">{formatNotifDate(selectedNotification.acknowledgedDate || "")}</span>
                    </div>
                    <div>
                      <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider">Acknowledged Time</span>
                      <span className="font-semibold text-emerald-700 font-mono">{selectedNotification.acknowledgedTime}</span>
                    </div>
                  </>
                )}
              </div>

              {/* Chronological Timeline History Log */}
              <div className="relative pl-4 border-l border-border/60 space-y-3 mt-4">
                {selectedNotification.history.map((h, idx) => (
                  <div key={idx} className="relative flex items-start gap-2">
                    <span className="absolute -left-[20.5px] top-1.5 h-2 w-2 rounded-full border border-primary bg-card" />
                    <div className="flex flex-col gap-0.5 text-xs leading-relaxed">
                      <div className="flex items-center gap-2">
                        <span className="text-muted-foreground font-mono text-[10px]">
                          {formatNotifDate(h.date)} {h.time}
                        </span>
                        <span className="font-semibold text-gray-700">
                          {h.action.includes("Remarks:") ? (
                            <>
                              Notification acknowledged by <strong>{h.by}</strong>
                              <span className="block text-muted-foreground font-normal mt-0.5 italic">
                                Remarks: {h.action.split("Remarks:")[1]?.replace(/"/g, "")}
                              </span>
                            </>
                          ) : (
                            `${h.action} by ${h.by}`
                          )}
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Modal Footer Controls */}
            <div className="flex justify-end gap-2 border-t border-border pt-3">
              <button
                onClick={() => setSelectedNotifId(null)}
                className="rounded-md border border-input bg-card px-4 py-2 font-medium hover:bg-accent text-xs cursor-pointer"
              >
                Close
              </button>
              {selectedNotification.status === "Pending" && (
                <button
                  onClick={handleConfirmAcknowledge}
                  className="rounded-md bg-success text-success-foreground px-4 py-2 font-semibold hover:bg-success/90 text-xs flex items-center gap-1 cursor-pointer"
                >
                  <Check className="h-3.5 w-3.5" /> Acknowledge
                </button>
              )}
            </div>
          </div>
        </Modal>
      )}
    </>
  );
}

const NOTIFICATION_TYPES = [
  "New Project Assignment",
  "New Task Assignment",
  "WBS Assignment",
  "Project Ready To Start",
  "Team Assignment",
  "Shadow Team Assignment",
  "Appreciation Received",
  "Issue Raised",
  "Issue Resolved",
  "Client Interview Selected",
  "Client Interview Rejected",
  "Change Management",
  "Approval Request",
  "Timesheet Approved",
  "Timesheet Rejected",
  "Timesheet Request Changes",
  "Resource Allocation",
  "Resource Removal",
  "Project Status Change",
  "Project Completed",
  "Project Cancelled",
  "Scope Change",
  "Resource Shuffle"
] as const;
