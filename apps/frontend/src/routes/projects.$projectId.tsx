import { createFileRoute, Link, notFound } from "@tanstack/react-router";
import React, { useMemo, useState } from "react";
import { ChevronRight, Calendar, Wallet, Lock, UserPlus, Eye, Pencil, Trash2, MoreHorizontal, X, Star, MessageSquare, Send, Check, Search, AlertTriangle, Award, Plus, ShieldCheck, Paperclip, Briefcase, Users, Clock, CalendarDays, ChevronDown, Building2, FolderOpen, Folder, FileText, Play, ChevronsDown, ChevronsUp } from "lucide-react";
import { toast } from "sonner";
import { AppShell } from "@/components/app-shell";
import { StageTracker, type SubStageItem } from "@/components/stage-tracker";
import { useRoleContext } from "@/lib/role-context";
import { projects, clients, getPerson, people, invoices, type WBSNode, type Project, type Client, type Task, type Person } from "@/lib/mock-data";
import { HealthPill, StatusPill, ProgressBar, TaskStatusPill, PriorityPill, Avatar } from "@/components/pills";
import { getProjectEMs, getProjectPMs, getProjectTLs, getProjectTeam, getTaskMeta, getDept, getSubDept, DH_TASK_STATUSES, mapTaskStatus, type DhTaskStatus, type Billability, type ResourceType, people as dhPeople } from "@/lib/dh-helpers";
import { dhStore, useDhStore, getPrereq, canAssignPMs, getStagesList, allClients, allProjects, type DhIssueStatus, type IssueCategory, type DhPriority, type InterviewStatus, type PrereqStatus, type PrereqCollectionStatus, type DhProjectPrereq, type DhInterview, type DhAdditionalRequirement, type RequirementStatus, type DhComment, type DhIssue, type DhAlert, type DhEscalation, type DhAppreciation, type LeadershipRole } from "@/lib/dh-store";
import { Modal, Field } from "@/routes/projects.index";
import { cn } from "@/lib/utils";
import { Calendar as CalendarUI } from "@/components/ui/calendar";
import type { DateRange } from "react-day-picker";

// Helper function for consistent date formatting (prevents hydration mismatch)
function formatDate(date: Date): string {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  return `${m}/${d}/${y}`;
}

function formatDateString(dateStr: string | undefined | null): string {
  if (!dateStr) return "—";
  const d = new Date(dateStr);
  if (isNaN(d.getTime())) return "—";
  return d.toLocaleDateString("en-IN", { day: "2-digit", month: "short", year: "numeric" });
}

const DEPT_GROUPS: Record<string, "Resource" | "Scope"> = {
  "Penetration Testing": "Scope",
  "Vulnerability Assessment": "Scope",
  "Red Team & Adversary Simulation": "Resource",
  "Cloud Security": "Resource",
  "Code & Application Security": "Scope",
  "Compliance & Audit": "Resource",
  "Social Engineering & Awareness": "Scope",
  "Forensics & Incident Response": "Resource",
  "Network & Infrastructure": "Scope",
  "Threat Intelligence & Modeling": "Resource",
};

// ---------- Date Range Picker — two small inline calendars ----------
function DateRangePicker({
  value,
  onChange,
}: {
  value: string;
  onChange: (val: string) => void;
}) {
  // Parse "M/D/YYYY → M/D/YYYY" → DateRange
  const parsedRange = useMemo<DateRange>(() => {
    if (!value) return { from: undefined, to: undefined };
    const parts = value.split(" → ");
    const from = parts[0] ? new Date(parts[0]) : undefined;
    const to = parts[1] ? new Date(parts[1]) : undefined;
    return {
      from: from && !isNaN(from.getTime()) ? from : undefined,
      to: to && !isNaN(to.getTime()) ? to : undefined,
    };
  }, [value]);

  // Single shared month — both calendars always show the same month
  const [currentMonth, setCurrentMonth] = useState<Date>(parsedRange.from ?? new Date());

  // Format date as dd-mm-yyyy for the text inputs
  const toInputFmt = (d: Date | undefined) => {
    if (!d) return "";
    return `${String(d.getDate()).padStart(2, "0")}-${String(d.getMonth() + 1).padStart(2, "0")}-${d.getFullYear()}`;
  };

  const parseInputFmt = (s: string): Date | undefined => {
    const [dd, mm, yyyy] = s.split("-");
    if (!dd || !mm || !yyyy) return undefined;
    const d = new Date(Number(yyyy), Number(mm) - 1, Number(dd));
    return isNaN(d.getTime()) ? undefined : d;
  };

  const [fromInput, setFromInput] = useState(toInputFmt(parsedRange.from));
  const [toInput, setToInput] = useState(toInputFmt(parsedRange.to));

  const commit = (from: Date | undefined, to: Date | undefined) => {
    if (from && to) onChange(`${formatDate(from)} → ${formatDate(to)}`);
    else if (from) onChange(`${formatDate(from)} → `);
    else onChange("");
  };

  // Click on start calendar
  const handleFromDay = (day: Date) => {
    setFromInput(toInputFmt(day));
    // If picked start > current end, clear end
    const newTo = parsedRange.to && day > parsedRange.to ? undefined : parsedRange.to;
    if (!newTo) setToInput("");
    commit(day, newTo);
  };

  // Click on end calendar
  const handleToDay = (day: Date) => {
    // end must not be before start
    if (parsedRange.from && day < parsedRange.from) {
      toast.error("End date must be after start date");
      return;
    }
    setToInput(toInputFmt(day));
    commit(parsedRange.from, day);
  };

  const handleFromInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFromInput(e.target.value);
    const d = parseInputFmt(e.target.value);
    if (d) { setCurrentMonth(d); commit(d, parsedRange.to); }
  };

  const handleToInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setToInput(e.target.value);
    const d = parseInputFmt(e.target.value);
    if (d) { setCurrentMonth(d); commit(parsedRange.from, d); }
  };

  const handleClear = () => {
    setFromInput(""); setToInput("");
    onChange("");
  };

  return (
    <div className="rounded-lg border border-border bg-card overflow-hidden">
      {/* Two side-by-side small calendars */}
      <div className="flex gap-0 divide-x divide-border">
        {/* Start date calendar */}
        <div className="flex-1 min-w-0">
          <p className="px-3 pt-2 pb-0 text-[10px] font-semibold uppercase tracking-wide text-muted-foreground">Start Date</p>
          <CalendarUI
            mode="single"
            selected={parsedRange.from}
            onSelect={(day) => day && handleFromDay(day)}
            month={currentMonth}
            onMonthChange={setCurrentMonth}
            showOutsideDays
            captionLayout="label"
            className="w-full [--cell-size:1.45rem] text-[10px]"
          />
        </div>
        {/* End date calendar */}
        <div className="flex-1 min-w-0">
          <p className="px-3 pt-2 pb-0 text-[10px] font-semibold uppercase tracking-wide text-muted-foreground">End Date</p>
          <CalendarUI
            mode="single"
            selected={parsedRange.to}
            onSelect={(day) => day && handleToDay(day)}
            month={currentMonth}
            onMonthChange={setCurrentMonth}
            showOutsideDays
            captionLayout="label"
            disabled={parsedRange.from ? { before: parsedRange.from } : undefined}
            className="w-full [--cell-size:1.45rem] text-[10px]"
          />
        </div>
      </div>

      {/* Clear link */}
      <div className="border-t border-border px-3 py-1.5 flex justify-between items-center">
        <button
          type="button"
          onClick={handleClear}
          className="text-xs font-medium text-primary hover:underline"
        >
          Clear
        </button>
      </div>

      {/* Two text inputs */}
      <div className="flex items-center gap-2 border-t border-border px-3 py-2.5">
        <div className="relative flex-1">
          <input
            type="text"
            placeholder="dd-mm-yyyy"
            value={fromInput}
            maxLength={10}
            onChange={handleFromInputChange}
            className="h-8 w-full rounded-md border border-input bg-card px-2 pr-8 text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
          <CalendarDays className="pointer-events-none absolute right-2 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
        </div>
        <span className="text-xs text-muted-foreground font-medium shrink-0">—</span>
        <div className="relative flex-1">
          <input
            type="text"
            placeholder="dd-mm-yyyy"
            value={toInput}
            maxLength={10}
            onChange={handleToInputChange}
            className="h-8 w-full rounded-md border border-input bg-card px-2 pr-8 text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
          <CalendarDays className="pointer-events-none absolute right-2 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
        </div>
      </div>
    </div>
  );
}

export const Route = createFileRoute("/projects/$projectId")({
  loader: ({ params }): { project: Project; client: Client } => {
    const project = allProjects().find((p) => p.id === params.projectId);
    if (!project) throw notFound();
    const client = allClients().find((c) => c.id === project.clientId)!;
    return { project, client };
  },
  head: ({ loaderData }) => ({
    meta: [
      { title: `${loaderData?.project.name ?? "Project"} — Pulse PMO` },
      { name: "description", content: loaderData?.project.description ?? "Project details." },
    ],
  }),
  component: ProjectDetail,
});

const tabs = ["Overview", "WBS", "Tasks", "Team", "Health", "Invoices"] as const;
type Tab = (typeof tabs)[number];

function WbsItem({ node, depth = 0 }: { node: WBSNode; depth?: number }) {
  return (
    <div>
      <div className="flex items-center gap-3 py-2" style={{ paddingLeft: depth * 20 }}>
        <span className="min-w-0 flex-1 text-sm">{node.name}</span>
        <ProgressBar value={node.progress} className="w-32" />
        <span className="w-10 text-right text-xs tabular-nums text-muted-foreground">{node.progress}%</span>
      </div>
      {node.children?.map((c) => <WbsItem key={c.id} node={c} depth={depth + 1} />)}
    </div>
  );
}

function ProjectDetail() {
  const { project: loaderProject, client: loaderClient } = Route.useLoaderData() as { project: Project; client: Client };
  const { user, isDhanshree } = useRoleContext();

  // Subscribe to store so runtime-created projects stay live/reactive
  const extraCount = useDhStore((s) => s.extraClients.length + s.extraProjects.length);
  const project: Project = useMemo(
    () => allProjects().find((p) => p.id === loaderProject.id) ?? loaderProject,
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [loaderProject.id, extraCount]
  );
  const client: Client = useMemo(
    () => allClients().find((c) => c.id === project.clientId) ?? loaderClient,
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [project.clientId, extraCount]
  );
  const snapshotInvoices = useDhStore((s) => s.invoices);
  const [raiseModalOpen, setRaiseModalOpen] = useState(false);
  const [raiseInvoiceId, setRaiseInvoiceId] = useState<string | null>(null);
  const [invoiceNumberInput, setInvoiceNumberInput] = useState("");
  const [tab, setTab] = useState<Tab>(() => {
    if (typeof window !== "undefined") {
      const h = window.location.hash;
      if (h === "#health" || h.startsWith("#health-")) {
        return "Health";
      }
    }
    return "Overview";
  });

  const pm = getPerson(project.pmId);
  const tl = getPerson(project.tlId);
  const team = project.teamIds.map(getPerson);

  const poFileName = useMemo(() => {
    return project.wbsDetails?.accounts?.poFileName ||
      (project.wbsDetails?.accounts?.poStatus === "PO Received" ||
        project.wbsDetails?.accounts?.poStatus === "PO Validated" ||
        project.wbsDetails?.accounts?.poStatus === "PO Raised" ||
        (project.id === "p1")
        ? "PO_Northwind_p1.pdf"
        : "");
  }, [project]);

  const handleDownloadPO = () => {
    if (!poFileName) return;
    const element = document.createElement("a");
    const file = new Blob(["Mock PO File Content for project: " + project.name], { type: 'application/pdf' });
    element.href = URL.createObjectURL(file);
    element.download = poFileName;
    document.body.appendChild(element);
    element.click();
    document.body.removeChild(element);
    toast.success("Download started", { description: poFileName });
  };

  // Get project stages - call unconditionally to avoid Rules of Hooks violation
  const stages = useMemo(() => getStagesList(project.id), [project.id]);

  // Subscribe to store for sub-status derivation (Dhanshree only)
  const storePrereqs = useDhStore((s) => s.prereqs[project.id]);
  const storeProjectStages = useDhStore((s) => s.projectStages[project.id]);

  // ── subStatusMap: one-line badge sub-text per stage (preserved unchanged) ──
  const subStatusMap = useMemo<Record<string, string>>(() => {
    if (!isDhanshree) return {} as Record<string, string>;
    const prereq = storePrereqs;
    const tracker = storeProjectStages;

    // --- Sales ---
    const salesStatus = tracker?.stages?.sales?.currentStatus;
    let salesSub = "Pending";
    if (salesStatus === "Assigned") salesSub = "WBS Created & Assigned";
    else if (salesStatus === "Approval") salesSub = "WBS Approval In Progress";

    // --- PMO ---
    const allCollected = (prereq?.services?.length ?? 0) > 0 && (prereq?.services?.every(s => {
      const wbsSvc = project.wbsDetails?.services?.find((x: any) => x.id === s.serviceId);
      const isResourceDept = wbsSvc ? (DEPT_GROUPS[wbsSvc.department] === "Resource") : false;
      return isResourceDept || s.collectionStatus === "Collected";
    }) ?? false);

    const allValidated = (prereq?.services?.length ?? 0) > 0 && (prereq?.services?.every(s => {
      const wbsSvc = project.wbsDetails?.services?.find((x: any) => x.id === s.serviceId);
      const isResourceDept = wbsSvc ? (DEPT_GROUPS[wbsSvc.department] === "Resource") : false;
      return isResourceDept || s.validationStatus === "Validated";
    }) ?? false);

    const allBillingOk = (prereq?.services?.length ?? 0) > 0 && (prereq?.services?.every(s => s.billingStatus === "Advance Received" || s.billingStatus === "Advance Not Required") ?? false);
    const hasPM = (prereq?.assignedPmIds?.length ?? 0) > 0;
    const hasSPM = (prereq?.assignedSpmIds?.length ?? 0) > 0;
    let pmoSub = "Prerequisite Collection Pending";
    if (allCollected && allValidated && allBillingOk && hasPM && hasSPM) pmoSub = "Project Allocation Completed";
    else if (allCollected && allValidated && allBillingOk) pmoSub = "Billing Validated";
    else if (allCollected && allValidated) pmoSub = "Validation Completed";
    else if (allCollected) pmoSub = "Collection Completed";
    else if (allCollected === false && (prereq?.services?.some(s => s.collectionStatus === "Collected") ?? false)) pmoSub = "Collection In Progress";

    // --- Delivery ---
    const deliveryStatus = tracker?.stages?.delivery?.currentStatus ?? project.status;
    let deliverySub = String(deliveryStatus);
    if (deliveryStatus === "Ongoing") {
      const pct = project.progress;
      deliverySub = pct >= 80 ? `${pct}% — Near Completion` : pct >= 50 ? `${pct}% — In Progress` : `${pct}% — Early Stage`;
    } else if (deliveryStatus === "Completed") deliverySub = "Project Delivered";
    else if (deliveryStatus === "After Release") deliverySub = "Post-Release Monitoring";

    // --- Accounts ---
    const acctDetail = tracker?.accountsDetail;
    let acctSub = "PO Pending";
    if (acctDetail) {
      if (acctDetail.paymentStatus === "Payment Received") acctSub = "Payment Received";
      else if (acctDetail.poStatus === "PO Validated") acctSub = "PO Validated — Awaiting Payment";
      else if (acctDetail.poStatus === "PO Received") acctSub = "PO Received — Under Validation";
      else acctSub = "PO Pending";
    }

    return { Sales: salesSub, PMO: pmoSub, Delivery: deliverySub, Accounts: acctSub };
  }, [isDhanshree, storePrereqs, storeProjectStages, project.progress, project.status, project.contractType]);

  // ── subStagesMap: expandable sub-stage checklist (Dhanshree only) ──────────
  const subStagesMap = useMemo<Record<string, SubStageItem[]>>(() => {
    if (!isDhanshree) return {} as Record<string, SubStageItem[]>;
    const prereq = storePrereqs;
    const tracker = storeProjectStages;

    // ---- Sales sub-stages: WBS lifecycle ----
    // currentStatus in dh-store: "Pending" | "Assigned" | "Approval"
    const salesStatus = tracker?.stages?.sales?.currentStatus ?? "Pending";
    const wbsStatus = (project as any).wbsStatus ?? "draft";
    // WBS Created = project exists (always true once we reach this page)
    // WBS Stabilized = wbsStatus is "approved" / "started" / "approval_pending" (sent for approval means stabilized)
    // WBS Modified = salesStatus === "Approval" and wbsStatus includes modification signals
    const wbsCreated = true;
    const wbsStabilized =
      salesStatus === "Approval" ||
      wbsStatus === "approved" ||
      wbsStatus === "started" ||
      wbsStatus === "assigned";
    const wbsModified =
      salesStatus === "Approval" && (wbsStatus === "assigned" || wbsStatus === "started");

    const salesSubStages: SubStageItem[] = [
      {
        label: "WBS Created",
        status: wbsCreated ? "completed" : "active",
      },
      {
        label: "WBS Stabilized",
        status: wbsStabilized ? "completed" : wbsCreated ? "active" : "pending",
      },
      {
        label: "WBS Modified",
        status: wbsModified ? "completed" : wbsStabilized ? "active" : "pending",
      },
    ];

    // ---- PMO sub-stages: assignment + prerequisite workflow ----
    const hasSPM = (prereq?.assignedSpmIds?.length ?? 0) > 0;
    const hasPM = (prereq?.assignedPmIds?.length ?? 0) > 0;
    const allCollected = (prereq?.services?.length ?? 0) > 0 && (prereq?.services?.every(s => {
      const wbsSvc = project.wbsDetails?.services?.find((x: any) => x.id === s.serviceId);
      const isResourceDept = wbsSvc ? (DEPT_GROUPS[wbsSvc.department] === "Resource") : false;
      return isResourceDept || s.collectionStatus === "Collected";
    }) ?? false);
    const allValidated = (prereq?.services?.length ?? 0) > 0 && (prereq?.services?.every(s => {
      const wbsSvc = project.wbsDetails?.services?.find((x: any) => x.id === s.serviceId);
      const isResourceDept = wbsSvc ? (DEPT_GROUPS[wbsSvc.department] === "Resource") : false;
      return isResourceDept || s.validationStatus === "Validated";
    }) ?? false);
    const allBillingOk = (prereq?.services?.length ?? 0) > 0 && (prereq?.services?.every(s => s.billingStatus === "Advance Received" || s.billingStatus === "Advance Not Required") ?? false);
    const isReadyToStart = prereq?.isProjectReadyToStart ?? false;

    // Each step unlocks the next in sequence.
    const pmoSteps = [
      { label: "Senior Project Manager Assigned", done: hasSPM },
      { label: "Project Manager Assigned", done: hasPM && hasSPM },
      { label: "Prerequisite Collected", done: allCollected && hasPM },
      { label: "Prerequisite Validated", done: allValidated && allCollected && hasPM },
      { label: "Billing Validation", done: allBillingOk && allValidated && allCollected && hasPM },
      { label: "Ready To Start", done: isReadyToStart },
    ];

    // Find first step not done → it is "active"
    let foundActive = false;
    const pmoSubStages: SubStageItem[] = pmoSteps.map(step => {
      if (step.done) return { label: step.label, status: "completed" as const };
      if (!foundActive) {
        foundActive = true;
        return { label: step.label, status: "active" as const };
      }
      return { label: step.label, status: "pending" as const };
    });

    // ---- Delivery sub-stages: sequential execution states ----
    const deliveryStatus = tracker?.stages?.delivery?.currentStatus ?? "Ongoing";
    // Map the five sequential delivery sub-stages to current position.
    const deliveryOrder = [
      "Initial Testing Completed",
      "Re-testing Completed",
      "Meta Data Completed",
      "Certification Released",
      "After Released",
    ] as const;
    // Derive which step is active from deliveryStatus + project progress.
    // The store tracks high-level status. We map progress % → delivery position.
    let deliveryActiveIdx: number;
    if (deliveryStatus === "Completed" || deliveryStatus === "After Release") {
      deliveryActiveIdx = deliveryOrder.length; // all done
    } else {
      const pct = project.progress;
      if (pct >= 80) deliveryActiveIdx = 3;       // Certification Released active
      else if (pct >= 60) deliveryActiveIdx = 2;  // Meta Data Completed active
      else if (pct >= 40) deliveryActiveIdx = 1;  // Re-testing Completed active
      else if (pct >= 20) deliveryActiveIdx = 0;  // Initial Testing Completed active
      else deliveryActiveIdx = 0;
    }
    const deliverySubStages: SubStageItem[] = deliveryOrder.map((label, idx) => {
      if (idx < deliveryActiveIdx) return { label, status: "completed" as const };
      if (idx === deliveryActiveIdx && deliveryActiveIdx < deliveryOrder.length)
        return { label, status: "active" as const };
      return { label, status: "pending" as const };
    });

    // ---- Accounts sub-stages: PO + Invoice workflow ----
    const acctStatus = tracker?.stages?.accounts?.currentStatus ?? "PO Not Raised";
    const acctDetail = tracker?.accountsDetail;

    const poReceived =
      acctStatus === "PO Received" ||
      acctStatus === "PO Raised" ||
      acctStatus === "Invoice Raised" ||
      acctStatus === "Invoice Not Raised" ||
      acctDetail?.poStatus === "PO Received" ||
      acctDetail?.poStatus === "PO Validated";
    const poNotRequired = acctStatus === "PO Not Raised" && !poReceived;
    const invoiceRaised =
      acctStatus === "Invoice Raised" ||
      acctDetail?.paymentStatus === "Payment Received";

    // PO Pending is the default starting state.
    // PO Received / PO Not Required are mutually exclusive alternatives.
    // Invoice Raised follows either of them.
    const poPending = !poReceived && !poNotRequired && !invoiceRaised;
    let accountsSubStages: SubStageItem[];
    if (poNotRequired) {
      accountsSubStages = [
        { label: "PO Pending", status: "completed" as const },
        { label: "PO Not Required", status: "active" as const },
        { label: "PO Received", status: "pending" as const },
        { label: "Invoice Raised", status: invoiceRaised ? "completed" as const : "pending" as const },
      ];
    } else {
      accountsSubStages = [
        { label: "PO Pending", status: poPending ? "active" as const : "completed" as const },
        { label: "PO Received", status: poReceived ? "completed" as const : "pending" as const },
        { label: "PO Not Required", status: "pending" as const },
        { label: "Invoice Raised", status: invoiceRaised ? "completed" as const : poReceived ? "active" as const : "pending" as const },
      ];
    }

    return {
      Sales: salesSubStages,
      PMO: pmoSubStages,
      Delivery: deliverySubStages,
      Accounts: accountsSubStages,
    };
  }, [isDhanshree, storePrereqs, storeProjectStages, project.progress, project.status]);

  return (
    <AppShell title={project.name} subtitle={
      <span>
        <Link
          to="/customer-detail/$clientId"
          params={{ clientId: client.id }}
          className="font-medium text-primary hover:underline"
        >
          {client.name}
        </Link>
        {project.subVenture ? ` (${project.subVenture})` : ""}
        {` · ${project.description}`}
      </span>
    }>

      {/* Breadcrumb path */}
      <nav className="mb-3 flex items-center gap-1 text-xs text-muted-foreground">
        <Link to="/projects" className="hover:text-foreground transition-colors">Projects</Link>
        <ChevronRight className="h-3 w-3 shrink-0" />
        <span className="text-foreground font-medium truncate">{project.name}</span>
      </nav>

      {/* Project Stages Tracker - Dhanshree Role Only */}
      {isDhanshree && (
        <div className="mb-3 rounded-lg border border-border bg-card shadow-sm">
          <div className="border-b border-border px-4 py-3">
            <h2 className="text-xs font-semibold text-gray-900">Project Stages Tracker</h2>
            <p className="text-[11px] text-gray-600 mt-0.5">Track project progression through Sales → PMO → Delivery → Accounts</p>
          </div>
          <StageTracker stages={stages} subStatusMap={subStatusMap} subStagesMap={subStagesMap} />
        </div>
      )}

      <div className="rounded-xl border border-border bg-card shadow-sm">
        <div className="flex flex-wrap items-center gap-3 border-b border-border p-4">
          <HealthPill status={project.health} />
          <StatusPill status={project.status} />
          {!isDhanshree && (
            <span className="inline-flex items-center gap-1 rounded-full border border-border bg-muted px-2 py-0.5 text-[11px] text-muted-foreground">
              <Lock className="h-3 w-3" /> View only · {user.role}
            </span>
          )}
          <div className="ml-auto flex items-center gap-3">
            <ProgressBar value={project.progress} className="w-40" />
            <span className="text-xs font-medium tabular-nums">{project.progress}%</span>
          </div>
        </div>

        <div className="flex gap-1 overflow-x-auto border-b border-border px-2">
          {tabs.map((t) => (
            <button key={t} onClick={() => setTab(t)}
              className={cn("border-b-2 px-3 py-2.5 text-sm font-medium transition-colors",
                tab === t ? "border-primary text-foreground" : "border-transparent text-muted-foreground hover:text-foreground")}>
              {t}
            </button>
          ))}
        </div>

        <div className="p-5">
          {tab === "Overview" && (
            <OverviewTab project={project} pm={pm} tl={tl} team={team} isDhanshree={isDhanshree} />
          )}

          {tab === "WBS" && (
            <WbsTab
              project={project}
              onRaiseInvoice={(invoiceId) => {
                setRaiseInvoiceId(invoiceId);
                setInvoiceNumberInput("");
                setRaiseModalOpen(true);
              }}
            />
          )}

          {tab === "Health" && <HealthTab project={project} />}

          {tab === "Tasks" && (isDhanshree ? <DhTasksTab project={project} /> : <DefaultTasksTab project={project} />)}

          {tab === "Team" && (isDhanshree ? <DhTeamTab project={project} /> : <DefaultTeamTab project={project} pm={pm} tl={tl} team={team} />)}

          {tab === "Invoices" && (
            <div className="space-y-4">
              {poFileName && (
                <div className="flex justify-end">
                  <div className="flex items-center gap-2 border border-border rounded-lg p-2 px-3 bg-muted/20">
                    <span className="text-xs font-semibold text-muted-foreground">Attached PO Document:</span>
                    <button
                      onClick={handleDownloadPO}
                      className="inline-flex items-center gap-1.5 text-xs font-bold text-primary hover:underline hover:text-primary/80"
                    >
                      <Paperclip className="h-3.5 w-3.5 shrink-0" />
                      <span>{poFileName}</span>
                    </button>
                  </div>
                </div>
              )}

              {isDhanshree ? (
                <div className="overflow-x-auto rounded-lg border border-border">
                  <table className="w-full text-sm">
                    <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
                      <tr>
                        <th className="px-3 py-2 font-medium">Milestone / Period</th>
                        <th className="px-3 py-2 font-medium">Resource Level</th>
                        <th className="px-3 py-2 font-medium">Invoice Target Date</th>
                        <th className="px-3 py-2 font-medium">Unit Price</th>
                        <th className="px-3 py-2 font-medium">Qty</th>
                        <th className="px-3 py-2 font-medium">Currency</th>
                        <th className="px-3 py-2 font-medium">Invoice Amount</th>
                        <th className="px-3 py-2 font-medium">Invoice Status</th>
                        <th className="px-3 py-2 font-medium">Invoice Number</th>
                        <th className="px-3 py-2 font-medium">Payment Status</th>
                        <th className="px-3 py-2 font-medium">Date Of Payment Received</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-border">
                      {snapshotInvoices.filter((i) => i.projectId === project.id).map((inv) => {
                        const statusTone = inv.invoiceStatus === "Raised" ? "bg-emerald-100 text-emerald-800" : "bg-gray-100 text-gray-800";
                        const paymentTone = inv.paymentStatus === "Received" ? "bg-success/10 text-success border-success/30" : "bg-warning/15 text-warning-foreground border-warning/30";

                        return (
                          <tr key={inv.id} className="hover:bg-accent/30">
                            <td className="px-3 py-2.5 font-medium">{inv.milestone}</td>
                            <td className="px-3 py-2.5 text-center font-medium">{inv.resourceLevel || "—"}</td>
                            <td className="px-3 py-2.5 text-xs text-muted-foreground">{inv.invoiceTargetDate}</td>
                            <td className="px-3 py-2.5 font-semibold tabular-nums">${inv.unitPrice.toLocaleString()}</td>
                            <td className="px-3 py-2.5 text-center font-medium">{inv.qty}</td>
                            <td className="px-3 py-2.5 font-medium">{inv.currency}</td>
                            <td className="px-3 py-2.5 font-semibold tabular-nums">${inv.invoiceAmount.toLocaleString()}</td>
                            <td className="px-3 py-2.5">
                              <select
                                value={inv.invoiceStatus}
                                onChange={(e) => {
                                  const val = e.target.value as "Not Raised" | "Raised";
                                  if (val === "Raised") {
                                    setRaiseInvoiceId(inv.id);
                                    setInvoiceNumberInput("");
                                    setRaiseModalOpen(true);
                                  } else {
                                    dhStore.cancelInvoice(project.id, inv.id, user.id, user.name);
                                    toast.success("Invoice status reset to Not Raised");
                                  }
                                }}
                                className={cn(
                                  "h-7 rounded-full border px-2 text-[11px] font-medium outline-none focus-visible:ring-2 focus-visible:ring-ring bg-white cursor-pointer",
                                  statusTone
                                )}
                              >
                                <option value="Not Raised" className="bg-white text-gray-800">Not Raised</option>
                                <option value="Raised" className="bg-white text-gray-800">Raised</option>
                              </select>
                            </td>
                            <td className="px-3 py-2.5 font-mono text-xs">
                              {inv.invoiceNumber || "-"}
                            </td>
                            <td className="px-3 py-2.5">
                              <select
                                value={inv.paymentStatus}
                                disabled={inv.invoiceStatus === "Not Raised"}
                                onChange={(e) => {
                                  const val = e.target.value as "Not Received" | "Received";
                                  dhStore.updatePaymentStatus(project.id, inv.id, val, user.id, user.name);
                                  toast.success(`Payment Status updated to ${val}`);
                                }}
                                className={cn(
                                  "h-7 rounded-full border px-2 text-[11px] font-medium outline-none focus-visible:ring-2 focus-visible:ring-ring bg-white cursor-pointer",
                                  paymentTone
                                )}
                              >
                                <option value="Not Received" className="bg-white text-gray-800">Not Received</option>
                                <option value="Received" className="bg-white text-gray-800">Received</option>
                              </select>
                            </td>
                            <td className="px-3 py-2.5 text-xs text-muted-foreground">
                              {inv.paymentReceivedDate || "-"}
                            </td>
                          </tr>
                        );
                      })}
                      {snapshotInvoices.filter((i) => i.projectId === project.id).length === 0 && (
                        <tr><td colSpan={10} className="px-3 py-8 text-center text-sm text-muted-foreground">No invoices raised yet</td></tr>
                      )}
                    </tbody>
                  </table>
                </div>
              ) : (
                <div className="overflow-x-auto rounded-lg border border-border">
                  <table className="w-full text-sm">
                    <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
                      <tr>
                        <th className="px-3 py-2 font-medium">Unit Price</th>
                        <th className="px-3 py-2 font-medium">Qty</th>
                        <th className="px-3 py-2 font-medium">Currency</th>
                        <th className="px-3 py-2 font-medium">Invoice Amount</th>
                        <th className="px-3 py-2 font-medium">Actions</th>
                        <th className="px-3 py-2 font-medium">Payment Status</th>
                        <th className="px-3 py-2 font-medium">Payment Received</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-border">
                      {invoices.filter((i) => i.projectId === project.id).map((inv, idx) => {
                        const paymentTone = inv.paymentStatus === "completed" ? "bg-success/10 text-success border-success/30"
                          : inv.paymentStatus === "overdue" ? "bg-destructive/10 text-destructive border-destructive/30"
                            : inv.paymentStatus === "pending" ? "bg-warning/15 text-warning-foreground border-warning/30"
                              : "bg-muted text-muted-foreground border-border";
                        return (
                          <tr key={idx} className="hover:bg-accent/30">
                            <td className="px-3 py-2.5 font-semibold tabular-nums">${inv.unitPrice.toLocaleString()}</td>
                            <td className="px-3 py-2.5 text-center font-medium">{inv.qty}</td>
                            <td className="px-3 py-2.5 font-medium">{inv.currency}</td>
                            <td className="px-3 py-2.5 font-semibold tabular-nums">${inv.invoiceAmount.toLocaleString()}</td>
                            <td className="px-3 py-2.5 text-center">
                              {inv.status === "raised" && (
                                <button className="inline-flex items-center gap-1 rounded-md text-xs font-medium text-primary hover:bg-primary/10 px-2 py-1">
                                  <Plus className="h-3 w-3" /> Raise
                                </button>
                              )}
                            </td>
                            <td className="px-3 py-2.5">
                              <span className={`inline-flex rounded-full border px-2 py-0.5 text-[11px] font-medium capitalize ${paymentTone}`}>{inv.paymentStatus.replace("_", " ")}</span>
                            </td>
                            <td className="px-3 py-2.5 text-xs text-muted-foreground">
                              {inv.paymentReceivedDate ? new Date(inv.paymentReceivedDate).toLocaleDateString() : "-"}
                            </td>
                          </tr>
                        );
                      })}
                      {invoices.filter((i) => i.projectId === project.id).length === 0 && (
                        <tr><td colSpan={7} className="px-3 py-8 text-center text-sm text-muted-foreground">No invoices raised yet</td></tr>
                      )}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          )}
        </div>
      </div>

      {raiseModalOpen && (
        <Modal
          title="Raise Invoice"
          onClose={() => setRaiseModalOpen(false)}
        >
          <div className="space-y-4">
            <Field label="Invoice Number" required>
              <input
                type="text"
                value={invoiceNumberInput}
                onChange={(e) => setInvoiceNumberInput(e.target.value)}
                placeholder="E.g., INV-2026-001"
                className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
              />
            </Field>

            <div className="flex justify-end gap-2 border-t border-border pt-4">
              <button
                onClick={() => setRaiseModalOpen(false)}
                className="rounded-md border border-input bg-card px-4 py-2 text-xs font-medium hover:bg-accent cursor-pointer"
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  if (!invoiceNumberInput.trim()) {
                    toast.error("Invoice Number is mandatory");
                    return;
                  }
                  if (raiseInvoiceId) {
                    dhStore.raiseInvoice(project.id, raiseInvoiceId, invoiceNumberInput.trim(), user.id, user.name);
                    toast.success("Invoice raised successfully!");
                  }
                  setRaiseModalOpen(false);
                }}
                className="rounded-md bg-primary px-4 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90 cursor-pointer"
              >
                Save
              </button>
            </div>
          </div>
        </Modal>
      )}
    </AppShell>
  );
}

// ---------- WBS Tab ----------
// Legacy demo service list shown in the WBS tab for seeded projects that
// have no wbsDetails (also feeds the Scope Cancellation dropdown).
const LEGACY_WBS_SERVICES = [
  { id: 1, taskId: 'WBS-01', dept: 'Penetration Testing', name: 'External Network Penetration Testing', qty: 1, desc: 'External network penetration test for internet-facing assets', freq: 'Once', delivery: 'Onsite', loc: 'Andheri', svc: 'Initial Test', format: 'PDF Report', billing: 'Ad-Hoc', tools: 'Nmap, Metasploit', start: '01 Feb 2026', end: '05 Feb 2026', durDays: 5, durHrs: 40, totalDays: 5, totalHrs: 40 },
  { id: 2, taskId: 'WBS-02', dept: 'Vulnerability Assessment', name: 'Web Application Vulnerability Assessment', qty: 2, desc: 'Security review for web apps and APIs', freq: 'Once', delivery: 'Offsite', loc: '', svc: 'Initial + 1 Re-test', format: 'Excel + PDF', billing: 'Ad-Hoc', tools: 'OWASP ZAP, Burp Suite', start: '06 Feb 2026', end: '10 Feb 2026', durDays: 4, durHrs: 32, totalDays: 8, totalHrs: 64 },
  { id: 3, taskId: 'WBS-03', dept: 'Cloud Security', name: 'AWS Cloud Security Assessment', qty: 1, desc: 'Cloud misconfiguration and control review', freq: 'Once', delivery: 'Hybrid', loc: '', svc: 'Initial Test', format: 'PDF Report', billing: 'Ad-Hoc', tools: 'AWS Config, Security Hub', start: '11 Feb 2026', end: '16 Feb 2026', durDays: 6, durHrs: 48, totalDays: 6, totalHrs: 48 },
  { id: 4, taskId: 'WBS-04', dept: 'Code & Application Security', name: 'Static Application Security Testing (SAST)', qty: 1, desc: 'Source code review and vulnerability analysis', freq: 'Once', delivery: 'Onsite', loc: 'Malad', svc: 'Initial + 2 Re-test', format: 'PDF + XLSX', billing: 'Ad-Hoc', tools: 'SonarQube, Semgrep', start: '17 Feb 2026', end: '21 Feb 2026', durDays: 5, durHrs: 40, totalDays: 5, totalHrs: 40 },
  { id: 5, taskId: 'WBS-05', dept: 'Compliance & Audit', name: 'ISO 27001 Assessment', qty: 1, desc: 'Compliance gap assessment and audit checklist', freq: 'Once', delivery: 'Onsite', loc: 'Bandra', svc: 'Initial + 1 Re-test', format: 'PDF Report', billing: 'Ad-Hoc', tools: 'Checklist, Audit Toolkit', start: '22 Feb 2026', end: '01 Mar 2026', durDays: 8, durHrs: 64, totalDays: 8, totalHrs: 64 },
  { id: 6, taskId: 'WBS-06', dept: 'Network & Infrastructure', name: 'Network Security Assessment', qty: 1, desc: 'Infrastructure review and segmentation validation', freq: 'Once', delivery: 'Offsite', loc: '', svc: 'Initial + 3 Re-test', format: 'PDF Report', billing: 'Ad-Hoc', tools: 'Nmap, Wireshark', start: '02 Mar 2026', end: '07 Mar 2026', durDays: 6, durHrs: 48, totalDays: 6, totalHrs: 48 },
];

function WbsTab({ project, onRaiseInvoice, onNavigateToHealthAlerts }: { project: Project; onRaiseInvoice: (invoiceId: string) => void; onNavigateToHealthAlerts?: () => void }) {
  const snapshotInvoices = useDhStore((s) => s.invoices);
  const { user, isDhanshree } = useRoleContext();

  if (project.wbsDetails) {
    const wbsDetails = project.wbsDetails;
    const totalServices = wbsDetails.services.reduce((acc: number, curr: any) => acc + curr.total, 0);
    const tax = totalServices * 0.18;
    const grandTotal = totalServices + tax;

    return (
      <div className="space-y-5">
        <div className="grid gap-4 md:grid-cols-2">
          <div className="rounded-lg border border-border bg-card p-4">
            <h3 className="mb-3 text-sm font-semibold">WBS Details</h3>
            <div className="space-y-2">
              <InfoRow label="Contract Type" value={wbsDetails.contractType} />
              <InfoRow label="Project Type" value={wbsDetails.projectType} />
              <InfoRow label="Sales Person" value={wbsDetails.salesPerson} />
            </div>
          </div>
          <div className="rounded-lg border border-border bg-card p-4">
            <h3 className="mb-3 text-sm font-semibold">Billing Information</h3>
            <div className="space-y-2">
              <InfoRow label="Billing Model" value={wbsDetails.accounts.billingModel} />
              <InfoRow label="Payment Terms" value={wbsDetails.accounts.paymentTerms} />
              <InfoRow label="Total Services Value" value={`${wbsDetails.currency} ${totalServices.toLocaleString()}`} />
              <InfoRow label="Currency" value={wbsDetails.currency} />
            </div>
          </div>
        </div>

        <WbsPrerequisiteSection project={project} />

        <div>
          <h3 className="mb-3 text-sm font-semibold">Services & Deliverables from WBS</h3>
          <div className="overflow-x-auto rounded-lg border border-border">
            <table className="w-full text-xs">
              <thead className="bg-muted/40 text-left uppercase tracking-wide text-muted-foreground">
                <tr>
                  <th className="px-3 py-2 font-medium">Department</th>
                  <th className="px-3 py-2 font-medium">Service ID</th>
                  <th className="px-3 py-2 font-medium">Service Name</th>
                  <th className="px-3 py-2 font-medium">Description</th>
                  <th className="px-3 py-2 font-medium">Resource Level</th>
                  <th className="px-3 py-2 font-medium">Qty</th>
                  <th className="px-3 py-2 font-medium">Frequency</th>
                  <th className="px-3 py-2 font-medium">Service Model</th>
                  <th className="px-3 py-2 font-medium">Delivery Model</th>
                  <th className="px-3 py-2 font-medium">Delivery Site</th>
                  <th className="px-3 py-2 font-medium">Delivery Format</th>
                  <th className="px-3 py-2 font-medium">Tools</th>
                  <th className="px-3 py-2 font-medium">Billing Model</th>
                  <th className="px-3 py-2 font-medium">WBS Start Date</th>
                  <th className="px-3 py-2 font-medium">WBS End Date</th>
                  <th className="px-3 py-2 font-medium">Duration Days</th>
                  <th className="px-3 py-2 font-medium">Duration Hours</th>
                  <th className="px-3 py-2 font-medium">Total Days</th>
                  <th className="px-3 py-2 font-medium">Total Hours</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {wbsDetails.services.map((svc: any) => (
                  <tr key={svc.id} className="hover:bg-accent/30">
                    <td className="px-3 py-2">{svc.department}</td>
                    <td className="px-3 py-2 font-mono text-muted-foreground">{svc.id}</td>
                    <td className="px-3 py-2 font-medium">{svc.serviceName}</td>
                    <td className="px-3 py-2 max-w-[140px] truncate cursor-default" title={svc.description}>{svc.description}</td>
                    <td className="px-3 py-2 text-center font-medium">{svc.resourceLevel || "—"}</td>
                    <td className="px-3 py-2 text-center">{svc.qty}</td>
                    <td className="px-3 py-2">{svc.frequency ?? "—"}</td>
                    <td className="px-3 py-2">{svc.serviceModel ?? "—"}</td>
                    <td className="px-3 py-2">{svc.location || "—"}</td>
                    <td className="px-3 py-2">{svc.locationText || "—"}</td>
                    <td className="px-3 py-2">{(svc as any).finalDelivery ?? (svc as any).deliveryFormat ?? svc.finalDeliveryFormat ?? "—"}</td>
                    <td className="px-3 py-2">{svc.tools ?? "—"}</td>
                    <td className="px-3 py-2">{svc.billingModel || wbsDetails.accounts.billingModel || "—"}</td>
                    <td className="px-3 py-2">{svc.startDate}</td>
                    <td className="px-3 py-2">{svc.endDate}</td>
                    <td className="px-3 py-2 text-center">{(svc as any).durationDays ?? svc.duration ?? "—"}</td>
                    <td className="px-3 py-2 text-center">{(svc as any).durationHours ?? (svc.duration ? svc.duration * 8 : "—")}</td>
                    <td className="px-3 py-2 text-center">{svc.totalDays ?? "—"}</td>
                    <td className="px-3 py-2 text-center">{svc.totalHrs ?? (svc.totalDays ? svc.totalDays * 8 : "—")}</td>
                  </tr>
                ))}
                {wbsDetails.services.length === 0 && (
                  <tr><td colSpan={18} className="px-3 py-6 text-center text-sm text-muted-foreground">No services defined.</td></tr>
                )}
              </tbody>
            </table>
          </div>
        </div>

        <div className="grid gap-4 md:grid-cols-3 rounded-lg border border-border bg-muted/20 p-4">
          <div>
            <div className="text-xs font-medium text-muted-foreground mb-1">Total Services</div>
            <div className="text-lg font-semibold">{wbsDetails.currency} {totalServices.toLocaleString()}</div>
          </div>
          <div>
            <div className="text-xs font-medium text-muted-foreground mb-1">Tax (18%)</div>
            <div className="text-lg font-semibold">{wbsDetails.currency} {tax.toLocaleString()}</div>
          </div>
          <div>
            <div className="text-xs font-medium text-muted-foreground mb-1">Grand Total</div>
            <div className="text-lg font-semibold">{wbsDetails.currency} {grandTotal.toLocaleString()}</div>
          </div>
        </div>

        <div>
          <h3 className="mb-3 text-sm font-semibold">Invoice Schedule</h3>
          <div className="overflow-x-auto rounded-lg border border-border">
            <table className="w-full text-sm">
              <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
                <tr>
                  <th className="px-3 py-2 font-medium">Milestone/Period</th>
                  <th className="px-3 py-2 font-medium">Invoice Date</th>
                  <th className="px-3 py-2 font-medium">Remarks</th>
                  <th className="px-3 py-2 font-medium">Amount</th>
                  <th className="px-3 py-2 font-medium text-right">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {wbsDetails.accounts.invoices.map((inv: any) => {
                  const liveInv = snapshotInvoices.find(
                    (li) => li.projectId === project.id && (li.id === inv.id || li.milestone === inv.milestone)
                  );
                  const isPaid = liveInv?.paymentStatus === "Received";
                  const isRaised = liveInv?.invoiceStatus === "Raised";
                  const displayInvoiceNo = liveInv?.invoiceNumber || inv.remarks || "-";
                  const displayDate = liveInv?.invoiceTargetDate || inv.invoiceDate;

                  return (
                    <tr key={inv.id} className="hover:bg-accent/30">
                      <td className="px-3 py-2 font-medium">{inv.milestone}</td>
                      <td className="px-3 py-2">{displayDate}</td>
                      <td className="px-3 py-2 font-mono text-xs">{displayInvoiceNo}</td>
                      <td className="px-3 py-2 font-medium">{wbsDetails.currency} {inv.amount.toLocaleString()}</td>
                      <td className="px-3 py-2 text-right">
                        {isPaid ? (
                          <span className="inline-flex rounded-full bg-success/10 border border-success/30 px-2 py-0.5 text-[11px] font-medium text-success">
                            Paid
                          </span>
                        ) : isRaised ? (
                          <div className="flex items-center justify-end gap-2">
                            <span className="inline-flex rounded-full bg-blue-100 border border-blue-200 px-2 py-0.5 text-[11px] font-medium text-blue-800">
                              Raised
                            </span>
                            {isDhanshree && liveInv && (
                              <button
                                onClick={() => {
                                  dhStore.updatePaymentStatus(project.id, liveInv.id, "Received", user.id, user.name);
                                  toast.success("Payment marked as Received");
                                }}
                                className="inline-flex items-center gap-1 rounded bg-success px-2 py-0.5 text-[10px] font-semibold text-success-foreground hover:bg-success/90 cursor-pointer"
                              >
                                Mark Paid
                              </button>
                            )}
                          </div>
                        ) : (
                          isDhanshree && liveInv ? (
                            <button
                              onClick={() => onRaiseInvoice(liveInv.id)}
                              className="inline-flex items-center gap-1 rounded-md bg-primary px-2 py-1 text-xs font-medium text-primary-foreground hover:bg-primary/90 cursor-pointer"
                            >
                              Raise Invoice
                            </button>
                          ) : (
                            <span className="inline-flex rounded-full bg-gray-100 border border-gray-200 px-2 py-0.5 text-[11px] font-medium text-gray-600">
                              Not Raised
                            </span>
                          )
                        )}
                      </td>
                    </tr>
                  );
                })}
                {wbsDetails.accounts.invoices.length === 0 && (
                  <tr><td colSpan={5} className="px-3 py-6 text-center text-sm text-muted-foreground">No invoices scheduled.</td></tr>
                )}
              </tbody>
            </table>
          </div>
        </div>

        <WbsPrerequisiteSection project={project} onNavigateToHealthAlerts={onNavigateToHealthAlerts} />
      </div>
    );
  }

  const wbsId = `WBS-2024-${project.id.padStart(3, '0')}`;
  const subtotal = 50000;
  const tax = subtotal * 0.18;
  const grandTotal = subtotal + tax;

  const wbsServices = LEGACY_WBS_SERVICES;

  return (
    <div className="space-y-5">
      {/* WBS Info Cards */}
      <div className="grid gap-4 md:grid-cols-2">
        <div className="rounded-lg border border-border bg-card p-4">
          <h3 className="mb-3 text-sm font-semibold">WBS Details</h3>
          <div className="space-y-2">
            <InfoRow label="WBS ID" value={wbsId} />
            <InfoRow label="Contract Type" value="Fixed Price" />
            <InfoRow label="Engagement Manager" value="Priya Sharma" />
            <InfoRow label="Sales Person" value="Amit Verma" />
          </div>
        </div>
        <div className="rounded-lg border border-border bg-card p-4">
          <h3 className="mb-3 text-sm font-semibold">Billing Information</h3>
          <div className="space-y-2">
            <InfoRow label="Project Type" value="Ad-Hoc" />
            <InfoRow label="Billing Model" value="70% Advance + 30% on Delivery" />
            <InfoRow label="Total Amount" value="---------" muted />
            <InfoRow label="Currency" value="---------" muted />
          </div>
        </div>
      </div>

      {/* PMO Intake & Prerequisite Workflow */}
      <WbsPrerequisiteSection project={project} />

      {/* Services Table */}
      <div>
        <h3 className="mb-3 text-sm font-semibold">Services & Deliverables from WBS</h3>
        <div className="overflow-x-auto rounded-lg border border-border">
          <table className="w-full text-xs">
            <thead className="bg-muted/40 text-left uppercase tracking-wide text-muted-foreground">
              <tr>
                <th className="px-3 py-2 font-medium">#</th>
                <th className="px-3 py-2 font-medium">Department</th>
                <th className="px-3 py-2 font-medium">Service ID</th>
                <th className="px-3 py-2 font-medium">Service Name</th>
                <th className="px-3 py-2 font-medium">Description</th>
                <th className="px-3 py-2 font-medium">Qty</th>
                <th className="px-3 py-2 font-medium">Frequency</th>
                <th className="px-3 py-2 font-medium">Service Model</th>
                <th className="px-3 py-2 font-medium">Delivery Model</th>
                <th className="px-3 py-2 font-medium">Delivery Site</th>
                <th className="px-3 py-2 font-medium">Delivery Format</th>
                <th className="px-3 py-2 font-medium">Tools</th>
                <th className="px-3 py-2 font-medium">Billing Model</th>
                <th className="px-3 py-2 font-medium">WBS Start Date</th>
                <th className="px-3 py-2 font-medium">WBS End Date</th>
                <th className="px-3 py-2 font-medium">Duration Days</th>
                <th className="px-3 py-2 font-medium">Duration Hours</th>
                <th className="px-3 py-2 font-medium">Total Days</th>
                <th className="px-3 py-2 font-medium">Total Hours</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {wbsServices.map((svc) => (
                <tr key={svc.id} className="hover:bg-accent/30">
                  <td className="px-3 py-2">{svc.id}</td>
                  <td className="px-3 py-2">{svc.dept}</td>
                  <td className="px-3 py-2 font-mono text-muted-foreground">{svc.taskId}</td>
                  <td className="px-3 py-2 font-medium">{svc.name}</td>
                  <td className="px-3 py-2 max-w-[140px] truncate cursor-default" title={svc.desc}>{svc.desc}</td>
                  <td className="px-3 py-2 text-center">{svc.qty}</td>
                  <td className="px-3 py-2">{svc.freq}</td>
                  <td className="px-3 py-2">{svc.svc}</td>
                  <td className="px-3 py-2">{svc.delivery}</td>
                  <td className="px-3 py-2">{svc.loc || "—"}</td>
                  <td className="px-3 py-2">{svc.format}</td>
                  <td className="px-3 py-2">{svc.tools}</td>
                  <td className="px-3 py-2">{svc.billing}</td>
                  <td className="px-3 py-2">{svc.start}</td>
                  <td className="px-3 py-2">{svc.end}</td>
                  <td className="px-3 py-2 text-center">{svc.durDays}</td>
                  <td className="px-3 py-2 text-center">{svc.durHrs}</td>
                  <td className="px-3 py-2 text-center">{svc.totalDays}</td>
                  <td className="px-3 py-2 text-center">{svc.totalHrs}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Totals */}
      <div className="grid gap-4 md:grid-cols-4 rounded-lg border border-border bg-muted/20 p-4">
        <div>
          <div className="text-xs font-medium text-muted-foreground mb-1">Subtotal</div>
          <div className="text-lg font-semibold text-muted-foreground">---------</div>
        </div>
        <div>
          <div className="text-xs font-medium text-muted-foreground mb-1">Tax (18%)</div>
          <div className="text-lg font-semibold text-muted-foreground">---------</div>
        </div>
        <div>
          <div className="text-xs font-medium text-muted-foreground mb-1">Total Days</div>
          <div className="text-lg font-semibold">35 days</div>
        </div>
        <div>
          <div className="text-xs font-medium text-muted-foreground mb-1">Grand Total</div>
          <div className="text-lg font-semibold text-muted-foreground">---------</div>
        </div>
      </div>

      {/* Invoice Schedule */}
      <div>
        <h3 className="mb-3 text-sm font-semibold">Invoice Schedule</h3>
        <div className="overflow-x-auto rounded-lg border border-border">
          <table className="w-full text-sm">
            <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
              <tr>
                <th className="px-3 py-2 font-medium">#</th>
                <th className="px-3 py-2 font-medium">Milestone/Period</th>
                <th className="px-3 py-2 font-medium">Invoice Target Date</th>
                <th className="px-3 py-2 font-medium">Duration/Days</th>
                <th className="px-3 py-2 font-medium">Billing Model</th>
                <th className="px-3 py-2 font-medium">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              <tr className="hover:bg-accent/30">
                <td className="px-3 py-2">1</td>
                <td className="px-3 py-2 font-medium">Advance 70%</td>
                <td className="px-3 py-2">02 Feb 2026</td>
                <td className="px-3 py-2">20 days</td>
                <td className="px-3 py-2">70% Advance</td>
                <td className="px-3 py-2">
                  <button className="inline-flex items-center gap-1 rounded-md bg-primary px-2 py-1 text-xs font-medium text-primary-foreground hover:bg-primary/90">
                    Invoice should be raised
                  </button>
                </td>
              </tr>
              <tr className="hover:bg-accent/30">
                <td className="px-3 py-2">2</td>
                <td className="px-3 py-2 font-medium">Final Delivery 30%</td>
                <td className="px-3 py-2">01 Sep 2026</td>
                <td className="px-3 py-2">15 days</td>
                <td className="px-3 py-2">30% on Delivery</td>
                <td className="px-3 py-2">
                  <button className="inline-flex items-center gap-1 rounded-md bg-primary px-2 py-1 text-xs font-medium text-primary-foreground hover:bg-primary/90">
                    Invoice should be raised
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      {/* Prerequisite Collection Status Section */}
      <WbsPrerequisiteSection project={project} onNavigateToHealthAlerts={onNavigateToHealthAlerts} />
    </div>
  );
}

function InfoRow({ label, value, muted }: { label: string; value: string; muted?: boolean }) {
  return (
    <div className="flex justify-between text-xs">
      <span className="text-muted-foreground font-medium">{label}</span>
      <span className={cn("font-semibold", muted && "text-muted-foreground")}>{value}</span>
    </div>
  );
}

// ---------- Overview ----------
function OverviewTab({ project, pm, tl, team, isDhanshree }: { project: Project; pm: Person; tl: Person; team: Person[]; isDhanshree: boolean }) {
  // Reactive leadership assignments from store (Dhanshree overrides)
  const leadershipAssignment = useDhStore((s) => s.leadershipAssignments[project.id] ?? null);

  const client = useMemo(() => {
    return allClients().find((c) => c.id === project.clientId);
  }, [project.clientId]);

  const ems: Person[] = useMemo(() => {
    if (leadershipAssignment?.emIds?.length) return leadershipAssignment.emIds.map(getPerson).filter(Boolean) as Person[];
    return getProjectEMs(project);
  }, [leadershipAssignment, project]);

  const spms: Person[] = useMemo(() => {
    if (leadershipAssignment?.spmIds?.length) return leadershipAssignment.spmIds.map(getPerson).filter(Boolean) as Person[];
    // fallback: prereq assigned SPMs, else default pool
    return [getPerson("u1")];
  }, [leadershipAssignment]);

  const pms: Person[] = useMemo(() => {
    if (leadershipAssignment?.pmIds?.length) return leadershipAssignment.pmIds.map(getPerson).filter(Boolean) as Person[];
    return getProjectPMs(project);
  }, [leadershipAssignment, project]);

  const tls: Person[] = useMemo(() => {
    if (leadershipAssignment?.tlIds?.length) return leadershipAssignment.tlIds.map(getPerson).filter(Boolean) as Person[];
    return getProjectTLs(project);
  }, [leadershipAssignment, project]);

  const wbs = project.wbsDetails;
  const hasWbsData = !!(project.wbsId || wbs);
  // A WBS-created project with no team assigned yet — PM/TL/team are placeholders
  const isNewWbsProject = hasWbsData && project.teamIds.length === 0;
  const totalServices = wbs ? wbs.services.reduce((a, b) => a + b.total, 0) : 0;
  const currency = wbs?.currency ?? project.currency ?? "INR";
  const taxPct = wbs ? (project.taxPercent ?? 18) : 18;
  const grandTotal = totalServices + totalServices * (taxPct / 100);

  return (
    <div className="grid gap-4 md:grid-cols-3">
      <div className={cn("space-y-4", isDhanshree ? "md:col-span-2" : "md:col-span-3")}>
        <div>
          <h3 className="text-sm font-semibold">Description</h3>
          <p className="mt-1 text-sm text-muted-foreground">{project.description || project.sectionAComments || "—"}</p>
        </div>
        <div className="grid gap-3 sm:grid-cols-3">
          <Info icon={Calendar} label="Start" value={formatDate(new Date(project.startDate))} />
          <Info icon={Calendar} label="End" value={formatDate(new Date(project.endDate))} />
          <Info icon={Wallet} label="Budget" value={`${currency} ${(project.budget / 1000).toFixed(0)}k`} sub={`Spent ${currency} ${(project.spent / 1000).toFixed(0)}k`} />
        </div>
        {project.budget > 0 && (
          <div>
            <h3 className="mb-2 text-sm font-semibold">Budget burn</h3>
            <ProgressBar value={(project.spent / project.budget) * 100} />
            <p className="mt-1 text-xs text-muted-foreground">{((project.spent / project.budget) * 100).toFixed(0)}% utilized</p>
          </div>
        )}

        {/* WBS Project Info — shown for projects created via the WBS form */}
        {hasWbsData && (
          <div className="rounded-lg border border-border bg-card p-4 space-y-3">
            <h3 className="text-sm font-semibold border-b border-border pb-2">Project Details</h3>
            <div className="grid gap-2 sm:grid-cols-2">
              {project.wbsId && <InfoRow label="WBS ID" value={project.wbsId} />}
              {project.projectSeqId && <InfoRow label="Project ID" value={project.projectSeqId} />}
              {project.subVenture && <InfoRow label="End Customer / Sub-venture" value={project.subVenture} />}
              {(project.contractType || wbs?.contractType) && (
                <InfoRow label="Contract Type" value={project.contractType ?? wbs!.contractType} />
              )}
              {(project.projectType || wbs?.projectType) && (
                <InfoRow label="Project Type" value={project.projectType ?? wbs!.projectType} />
              )}
              {(project.engagementManager || (wbs as any)?.engagementManager) && (
                <InfoRow label="Engagement Manager" value={project.engagementManager ?? (wbs as any).engagementManager ?? "—"} />
              )}
              {(project.salesPerson || wbs?.salesPerson) && (
                <InfoRow label="Sales Person" value={project.salesPerson ?? wbs!.salesPerson} />
              )}
              {project.projectIssuedDate && (
                <InfoRow label="Project Onboarding Date" value={formatDate(new Date(project.projectIssuedDate))} />
              )}
              {currency && <InfoRow label="Currency" value={currency} />}
              {wbs?.accounts?.billingModel && (
                <InfoRow label="Billing Model" value={wbs.accounts.billingModel} />
              )}
              {wbs?.accounts?.paymentTerms && (
                <InfoRow label="Payment Terms" value={wbs.accounts.paymentTerms} />
              )}
              {wbs?.accounts?.poStatus && (
                <InfoRow label="PO Status" value={wbs.accounts.poStatus} />
              )}
              {project.wbsStatus && (
                <InfoRow label="WBS Status" value={project.wbsSubStatus ?? project.wbsStatus} />
              )}
            </div>
            {totalServices > 0 && (
              <div className="grid grid-cols-3 gap-3 pt-2 border-t border-border">
                <div>
                  <div className="text-[11px] text-muted-foreground font-medium mb-0.5">Services Subtotal</div>
                  <div className="text-sm font-semibold">{currency} {totalServices.toLocaleString()}</div>
                </div>
                <div>
                  <div className="text-[11px] text-muted-foreground font-medium mb-0.5">Tax ({taxPct}%)</div>
                  <div className="text-sm font-semibold">{currency} {(totalServices * taxPct / 100).toLocaleString()}</div>
                </div>
                <div>
                  <div className="text-[11px] text-muted-foreground font-medium mb-0.5">Grand Total</div>
                  <div className="text-sm font-semibold text-primary">{currency} {grandTotal.toLocaleString()}</div>
                </div>
              </div>
            )}
            {(project.totalDays || project.totalHours) ? (
              <div className="grid grid-cols-2 gap-3 pt-2 border-t border-border">
                {project.totalDays ? (
                  <div>
                    <div className="text-[11px] text-muted-foreground font-medium mb-0.5">Total Days</div>
                    <div className="text-sm font-semibold">{project.totalDays} days</div>
                  </div>
                ) : null}
                {project.totalHours ? (
                  <div>
                    <div className="text-[11px] text-muted-foreground font-medium mb-0.5">Total Hours</div>
                    <div className="text-sm font-semibold">{project.totalHours} hrs</div>
                  </div>
                ) : null}
              </div>
            ) : null}
          </div>
        )}

        {isDhanshree && (
          <div className="grid gap-3 sm:grid-cols-3 items-stretch">
            <LeadershipBlock title="Senior Project Managers" role="Senior Project Manager" people={spms} project={project} />
            <LeadershipBlock title="Project Managers" role="Project Manager" people={pms} unassigned={isNewWbsProject} project={project} />
            <LeadershipBlock title="Team Leads" role="Team Lead" people={tls} unassigned={isNewWbsProject} project={project} />
          </div>
        )}
      </div>
      {isDhanshree && (
        <aside className="space-y-3">
          {client && (
            <div className="rounded-lg border border-border bg-card p-4 shadow-sm space-y-3">
              <h3 className="text-xs font-semibold uppercase tracking-wider text-muted-foreground flex items-center gap-1.5 border-b border-border pb-2">
                <Building2 className="h-3.5 w-3.5 text-muted-foreground" /> Client Information
              </h3>
              <div className="space-y-2 text-xs">
                <div>
                  <span className="text-muted-foreground font-medium block mb-0.5">Client Name</span>
                  <Link to="/clients/$clientId" params={{ clientId: client.id }} className="font-semibold text-primary hover:underline block truncate">
                    {client.name}
                  </Link>
                </div>
                <div>
                  <span className="text-muted-foreground font-medium block mb-0.5">Contact Person</span>
                  <span className="font-medium text-foreground block truncate">{client.contactName ?? client.contact.split("@")[0]}</span>
                </div>
                <div>
                  <span className="text-muted-foreground font-medium block mb-0.5">Email</span>
                  <span className="font-medium text-foreground block truncate">{client.contact}</span>
                </div>
                <div>
                  <span className="text-muted-foreground font-medium block mb-0.5">Phone</span>
                  <span className="font-medium text-foreground block">{client.contactPhone ?? "—"}</span>
                </div>
                <div>
                  <span className="text-muted-foreground font-medium block mb-0.5">Designation</span>
                  <span className="font-medium text-foreground block truncate">{client.contactDesignation ?? "—"}</span>
                </div>
                <div>
                  <span className="text-muted-foreground font-medium block mb-0.5">Contact Type</span>
                  <span className="font-semibold text-primary block">{client.contactType ?? "—"}</span>
                </div>
              </div>
            </div>
          )}
          <div className="rounded-lg border border-border bg-accent/30 p-4">
            <ExtensionRequestCard project={project} />
          </div>
        </aside>
      )}
    </div>
  );
}

function ExtensionRequestCard({ project }: { project: Project }) {
  const { user } = useRoleContext();
  const [newEndDate, setNewEndDate] = useState(project.endDate);
  const [reason, setReason] = useState("");
  const [taggedIds, setTaggedIds] = useState<string[]>([]);
  const [showSearch, setShowSearch] = useState(false);
  const [query, setQuery] = useState("");

  const approversPool = useMemo(() => {
    return people.filter(p => ["Senior PM", "Engagement Manager", "PM", "PMO", "HOD"].includes(p.role));
  }, []);

  const extDays = useMemo(() => {
    if (!newEndDate) return 0;
    const d1 = new Date(project.endDate);
    const d2 = new Date(newEndDate);
    const diff = d2.getTime() - d1.getTime();
    return Math.max(0, Math.ceil(diff / (1000 * 60 * 60 * 24)));
  }, [newEndDate, project.endDate]);

  const visibleApprovers = useMemo(() => {
    return approversPool.filter(p => !query.trim() || p.name.toLowerCase().includes(query.toLowerCase()));
  }, [approversPool, query]);

  const toggle = (id: string) => {
    setTaggedIds(prev => prev.includes(id) ? prev.filter(x => x !== id) : [...prev, id]);
  };

  const handleSubmit = () => {
    if (!reason.trim()) {
      toast.error("Reason For Extension is mandatory");
      return;
    }
    if (taggedIds.length === 0) {
      toast.error("Please tag at least one approver");
      return;
    }
    dhStore.submitExtensionRequest(project.id, newEndDate, extDays, reason, taggedIds, user.name, user.id);
    toast.success("Timeline Extension Approval request submitted successfully!");
    setReason("");
    setTaggedIds([]);
  };

  return (
    <div className="rounded-lg border border-border bg-card p-3 space-y-3 mt-4 text-xs text-left">
      <div className="flex items-center gap-1.5 border-b border-border pb-1.5 text-xs font-semibold uppercase tracking-wider text-primary">
        <Clock className="h-4 w-4" />
        <span>Extension Request</span>
      </div>

      <div className="space-y-2">
        <div>
          <span className="text-muted-foreground block mb-0.5 font-medium">Current End Date</span>
          <p className="font-semibold text-gray-800">{formatDate(new Date(project.endDate))}</p>
        </div>

        <div>
          <label className="text-muted-foreground block mb-1 font-medium">Requested New End Date</label>
          <input
            type="date"
            value={newEndDate}
            onChange={(e) => setNewEndDate(e.target.value)}
            className="w-full h-8 rounded-md border border-border bg-card px-2 text-xs font-medium focus-visible:ring-1 focus-visible:ring-ring"
          />
        </div>

        <div>
          <span className="text-muted-foreground block mb-0.5 font-medium">Extension Duration</span>
          <p className="font-semibold text-primary">{extDays} Days</p>
        </div>

        <div>
          <label className="text-muted-foreground block mb-1 font-medium">
            Reason For Extension <span className="text-destructive font-bold">*</span>
          </label>
          <textarea
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            placeholder="Provide a valid corporate reason..."
            rows={2}
            className="w-full rounded-md border border-border bg-card p-1.5 text-xs outline-none focus-visible:ring-1 focus-visible:ring-ring"
          />
        </div>

        <div>
          <label className="text-muted-foreground block mb-1 font-medium">Tag Stakeholder Approvers</label>
          <div className="relative">
            <button
              onClick={() => setShowSearch(!showSearch)}
              className="w-full h-8 rounded-md border border-border bg-card px-2 text-left text-xs text-muted-foreground flex justify-between items-center"
            >
              <span>{taggedIds.length > 0 ? `${taggedIds.length} approvers tagged` : "Select Approvers"}</span>
              <span className="text-[10px]">▼</span>
            </button>

            {showSearch && (
              <div className="absolute top-9 left-0 right-0 z-50 rounded-md border border-border bg-card shadow-lg p-2 space-y-2">
                <input
                  value={query}
                  onChange={(e) => setQuery(e.target.value)}
                  placeholder="Search name..."
                  className="w-full h-7 rounded-md border border-border bg-card px-2 text-xs"
                />
                <ul className="max-h-28 overflow-y-auto divide-y divide-border text-[10px] space-y-1">
                  {visibleApprovers.map((p) => {
                    const isSel = taggedIds.includes(p.id);
                    return (
                      <li key={p.id} className="py-1">
                        <button
                          onClick={() => toggle(p.id)}
                          className="flex items-center justify-between w-full text-left"
                        >
                          <span>{p.name} ({p.role})</span>
                          {isSel && <Check className="h-3 w-3 text-primary" />}
                        </button>
                      </li>
                    );
                  })}
                </ul>
              </div>
            )}
          </div>
          {taggedIds.length > 0 && (
            <div className="flex flex-wrap gap-1 mt-1.5">
              {taggedIds.map((id) => {
                const p = getPerson(id);
                return (
                  <span key={id} className="inline-flex items-center gap-1 rounded bg-muted border border-border px-1 py-0.5 text-[9px] font-medium text-gray-700">
                    {p.name.split(" ")[0]}
                    <button onClick={() => toggle(id)} className="text-muted-foreground hover:text-foreground">×</button>
                  </span>
                );
              })}
            </div>
          )}
        </div>

        <button
          onClick={handleSubmit}
          disabled={!reason.trim() || taggedIds.length === 0}
          className="w-full h-8 bg-primary text-primary-foreground font-semibold rounded-md hover:bg-primary/90 text-xs transition-colors disabled:opacity-50 mt-1"
        >
          Submit Request
        </button>
      </div>
    </div>
  );
}

function PeopleBlock({ title, people, unassigned }: { title: string; people: Person[]; unassigned?: boolean }) {
  return (
    <div className="rounded-lg border border-border bg-card p-3">
      <div className="mb-2 text-[11px] font-medium uppercase tracking-wide text-muted-foreground">{title}</div>
      {unassigned || people.length === 0 ? (
        <span className="text-[11px] italic text-muted-foreground">Not yet assigned</span>
      ) : (
        <div className="flex flex-wrap gap-1.5">
          {people.map((p) => (
            <div key={p.id} className="flex items-center gap-1.5 rounded-full border border-border bg-accent/30 px-2 py-0.5 text-xs">
              <Avatar name={p.name} size={18} />
              <span>{p.name}</span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

// ---------- Leadership Block (Dhanshree only) — chips + Change Leader button ----------
function LeadershipBlock({
  title, role, people, unassigned, project,
}: {
  title: string;
  role: LeadershipRole;
  people: Person[];
  unassigned?: boolean;
  project: Project;
}) {
  const [showPanel, setShowPanel] = useState(false);
  return (
    <div className="flex flex-col rounded-lg border border-border bg-card p-3 gap-2 min-h-[120px]">
      {/* Fixed-height title — always 2 lines so all cards align */}
      <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground leading-tight min-h-[28px]">
        {title}
      </div>
      {/* People chips — grow to fill available space */}
      <div className="flex-1 flex flex-wrap gap-1.5 content-start">
        {unassigned || people.length === 0 ? (
          <span className="text-[11px] italic text-muted-foreground">Not yet assigned</span>
        ) : (
          people.map((p) => (
            <div key={p.id} className="flex items-center gap-1.5 rounded-full border border-border bg-accent/30 px-2 py-0.5 text-xs">
              <Avatar name={p.name} size={18} />
              <span>{p.name}</span>
            </div>
          ))
        )}
      </div>
      {/* Button always at the bottom */}
      <button
        onClick={() => setShowPanel(true)}
        className="mt-auto w-full h-7 rounded-md border border-primary/40 bg-primary/5 text-primary text-[11px] font-semibold hover:bg-primary/10 transition-colors"
      >
        Change Leader
      </button>
      {showPanel && (
        <ChangeLeaderPanel
          project={project}
          role={role}
          assignedPeople={people}
          onClose={() => setShowPanel(false)}
        />
      )}
    </div>
  );
}

// ---------- Change Leader Panel — direct assign / deassign ----------
function ChangeLeaderPanel({
  project, role, assignedPeople, onClose,
}: {
  project: Project;
  role: LeadershipRole;
  assignedPeople: Person[];
  onClose: () => void;
}) {
  const [search, setSearch] = useState("");
  // Working copy of assigned IDs — saved on "Done"
  const [assignedIds, setAssignedIds] = useState<string[]>(assignedPeople.map((p) => p.id));

  const allPeople = dhPeople;

  const visible = useMemo(() =>
    allPeople.filter((p) =>
      !search.trim() || p.name.toLowerCase().includes(search.toLowerCase()) || p.role.toLowerCase().includes(search.toLowerCase())
    ),
    [search, allPeople]
  );

  const toggle = (id: string) => {
    setAssignedIds((prev) =>
      prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]
    );
  };

  const handleDone = () => {
    dhStore.updateLeadershipAssignment(project.id, role, assignedIds);
    const names = assignedIds.map((id) => getPerson(id).name).join(", ") || "None";
    toast.success(`${role} updated`, { description: names });
    onClose();
  };

  return (
    <Modal title={`Change Leader — ${role}`} onClose={onClose}>
      <div className="space-y-3">

        {/* Currently assigned chips */}
        <div>
          <p className="text-[11px] font-medium text-muted-foreground uppercase tracking-wide mb-1.5">
            Currently Assigned
          </p>
          <div className="flex flex-wrap gap-1.5 min-h-[28px]">
            {assignedIds.length === 0
              ? <span className="text-xs italic text-muted-foreground">No one assigned</span>
              : assignedIds.map((id) => {
                const p = getPerson(id);
                return (
                  <span key={id} className="inline-flex items-center gap-1 rounded-full border border-primary/30 bg-primary/10 px-2 py-0.5 text-xs text-primary">
                    <Avatar name={p.name} size={14} />
                    {p.name}
                    <button
                      onClick={() => toggle(id)}
                      className="ml-0.5 rounded-full hover:bg-destructive/20 hover:text-destructive"
                      title="Remove"
                    >
                      <X className="h-3 w-3" />
                    </button>
                  </span>
                );
              })
            }
          </div>
        </div>

        {/* Search + full list */}
        <div>
          <p className="text-[11px] font-medium text-muted-foreground uppercase tracking-wide mb-1.5">
            All Leaders
          </p>
          <div className="relative mb-2">
            <Search className="pointer-events-none absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
            <input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search by name or role…"
              className="h-8 w-full rounded-md border border-input bg-card pl-8 pr-3 text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring"
              autoFocus
            />
          </div>

          <ul className="max-h-64 overflow-y-auto divide-y divide-border rounded-md border border-border">
            {visible.map((p) => {
              const isAssigned = assignedIds.includes(p.id);
              return (
                <li key={p.id}>
                  <button
                    onClick={() => toggle(p.id)}
                    className={cn(
                      "flex w-full items-center gap-2.5 px-3 py-2 text-left text-xs transition-colors hover:bg-accent/40",
                      isAssigned && "bg-primary/5"
                    )}
                  >
                    <Avatar name={p.name} size={24} />
                    <div className="flex-1 min-w-0">
                      <div className="font-medium truncate">{p.name}</div>
                      <div className="text-[10px] text-muted-foreground">{p.role}</div>
                    </div>
                    <div className={cn(
                      "shrink-0 h-4 w-4 rounded border flex items-center justify-center transition-colors",
                      isAssigned
                        ? "bg-primary border-primary text-primary-foreground"
                        : "border-input bg-card"
                    )}>
                      {isAssigned && <Check className="h-2.5 w-2.5" />}
                    </div>
                  </button>
                </li>
              );
            })}
            {visible.length === 0 && (
              <li className="px-3 py-6 text-center text-xs text-muted-foreground">No match</li>
            )}
          </ul>
        </div>

        {/* Actions */}
        <div className="flex justify-end gap-2 border-t border-border pt-3">
          <button
            onClick={onClose}
            className="rounded-md border border-input bg-card px-4 py-2 text-xs font-medium hover:bg-accent"
          >
            Cancel
          </button>
          <button
            onClick={handleDone}
            className="rounded-md bg-primary px-4 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90"
          >
            Save Changes
          </button>
        </div>
      </div>
    </Modal>
  );
}

// ---------- Default Tasks (other roles) ----------
function DefaultTasksTab({ project }: { project: Project }) {
  const snapshot = useDhStore((s) => s);
  const prereq = snapshot.prereqs[project.id];

  const visibleTasks = useMemo(() => {
    if (!prereq) return project.tasks;
    return project.tasks.filter((t) => {
      const svc = prereq.services?.find((s) => s.serviceId === t.serviceId);
      if (!svc) return true;
      return svc.isReady;
    });
  }, [project.tasks, prereq]);

  return (
    <div className="overflow-x-auto rounded-lg border border-border">
      <table className="w-full text-sm">
        <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
          <tr>
            <th className="px-3 py-2 font-medium">Task</th>
            <th className="px-3 py-2 font-medium">Assignee</th>
            <th className="px-3 py-2 font-medium">Status</th>
            <th className="px-3 py-2 font-medium">Due</th>
            <th className="px-3 py-2 font-medium">Progress</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-border">
          {project.tasks.length === 0 ? (
            <tr>
              <td colSpan={5} className="px-3 py-10 text-center text-sm text-muted-foreground">
                No services — create this project via Assign WBS to populate tasks.
              </td>
            </tr>
          ) : visibleTasks.length === 0 ? (
            <tr>
              <td colSpan={5} className="px-3 py-10 text-center text-sm text-muted-foreground">
                No active tasks. Mark services as Ready in the Prerequisites tab to start tracking tasks.
              </td>
            </tr>
          ) : (
            visibleTasks.map((t) => {
              const a = getPerson(t.assigneeId);
              return (
                <tr key={t.id} className="hover:bg-accent/30">
                  <td className="px-3 py-2.5 font-medium">{t.title}</td>
                  <td className="px-3 py-2.5"><div className="flex items-center gap-2"><Avatar name={a.name} size={22} /><span className="text-xs">{a.name}</span></div></td>
                  <td className="px-3 py-2.5"><TaskStatusPill status={t.status} /></td>
                  <td className="px-3 py-2.5 text-xs text-muted-foreground">{new Date(t.dueDate).toLocaleDateString()}</td>
                  <td className="px-3 py-2.5">
                    <div className="flex items-center gap-2"><ProgressBar value={t.progress} className="w-24" /><span className="w-8 text-right text-xs tabular-nums text-muted-foreground">{t.progress}%</span></div>
                  </td>
                </tr>
              );
            })
          )}
        </tbody>
      </table>
    </div>
  );
}

// ---------- Dhanshree Tasks ----------
function getActivityName(t: Task): string {
  const title = t.title.toLowerCase();
  if (title.includes("requirement") || title.includes("gathering") || title.includes("discovery")) {
    return "1. Discovery";
  }
  if (title.includes("architecture") || title.includes("design") || title.includes("mockup")) {
    return "2. Design";
  }
  if (title.includes("api") || title.includes("implementation") || title.includes("frontend") || title.includes("build") || title.includes("integration")) {
    return "3. Build";
  }
  if (title.includes("qa") || title.includes("uat") || title.includes("test")) {
    return "4. Launch";
  }
  if (title.includes("deployment") || title.includes("launch")) {
    return "4. Launch";
  }
  return "Execution";
}

// ── Working-day helper (skip Sat/Sun) ──────────────────────────────────────
function addWorkingDaysFromDate(startIso: string, days: number): string {
  const d = new Date(startIso);
  let rem = days;
  while (rem > 0) {
    d.setDate(d.getDate() + 1);
    const dow = d.getDay();
    if (dow !== 0 && dow !== 6) rem--;
  }
  return d.toISOString().slice(0, 10);
}

interface AvatarStackAssignee {
  id: string;
  name: string;
  started: boolean;
}

// ── AvatarStack with hover tooltip ────────────────────────────────────────
function AvatarStack({ assignees }: { assignees: AvatarStackAssignee[] }) {
  const [tooltipPos, setTooltipPos] = useState<{ x: number; y: number } | null>(null);
  const ref = React.useRef<HTMLDivElement>(null);
  const validAssignees = assignees.filter(a => a && a.name);
  const initials = (n: string) => n.split(" ").map((p) => p[0]).slice(0, 2).join("").toUpperCase();
  const colors = ["bg-primary", "bg-info", "bg-success", "bg-warning"];
  const first = validAssignees[0];
  const extra = validAssignees.length - 1;

  const showTooltip = () => {
    if (!ref.current) return;
    const rect = ref.current.getBoundingClientRect();
    setTooltipPos({ x: rect.left, y: rect.bottom + 6 });
  };
  const hideTooltip = () => setTooltipPos(null);

  if (validAssignees.length === 0) {
    return <span className="text-xs text-muted-foreground">—</span>;
  }

  return (
    <>
      <div
        ref={ref}
        className="inline-flex items-center cursor-default"
        onMouseEnter={showTooltip}
        onMouseLeave={hideTooltip}
      >
        {/* First circle */}
        <span className={cn(
          "inline-flex h-7 w-7 items-center justify-center rounded-full border-2 border-card text-[10px] font-bold text-white z-10 select-none",
          colors[0]
        )}>
          {initials(first.name)}
        </span>
        {/* +N badge — only when more than 1 person */}
        {extra >= 1 && (
          <span className="-ml-2 inline-flex h-6 min-w-6 items-center justify-center rounded-full border-2 border-card bg-white px-1 text-[10px] font-bold text-foreground shadow-sm z-20 select-none">
            +{extra}
          </span>
        )}
      </div>

      {/* Tooltip rendered via portal-like fixed positioning — never clipped by overflow */}
      {tooltipPos && (
        <div
          className="fixed z-[9999] min-w-[210px] rounded-lg border border-border bg-popover p-2.5 shadow-xl"
          style={{ top: tooltipPos.y, left: tooltipPos.x }}
          onMouseEnter={showTooltip}
          onMouseLeave={hideTooltip}
        >
          <p className="mb-1.5 text-[10px] font-semibold uppercase tracking-wide text-muted-foreground">
            {validAssignees.length} Assigned
          </p>
          <div className="space-y-1.5">
            {validAssignees.map((a, i) => (
              <div key={i} className="flex items-center justify-between gap-3 text-xs font-medium text-foreground">
                <div className="flex items-center gap-2">
                  <span className={cn(
                    "inline-flex h-5 w-5 shrink-0 items-center justify-center rounded-full text-[9px] font-bold text-white",
                    colors[i % colors.length]
                  )}>
                    {initials(a.name)}
                  </span>
                  <span>{a.name}</span>
                </div>
                <span className={cn(
                  "text-[9px] font-bold px-1.5 py-0.5 rounded-full border shrink-0",
                  a.started
                    ? "bg-green-500/10 border-green-500/20 text-green-600"
                    : "bg-muted border-border text-muted-foreground"
                )}>
                  {a.started ? "Started" : "Not Started"}
                </span>
              </div>
            ))}
          </div>
        </div>
      )}
    </>
  );
}

const TREE_TASK_STAGES = ["Not Started", "Assigned", "Ongoing", "Completed", "On Hold", "Cancelled"] as const;
type TreeTaskStage = typeof TREE_TASK_STAGES[number];

function treeStageCls(s: TreeTaskStage) {
  return ({
    "Not Started": "border-primary/30 bg-primary/10 text-primary",
    "Assigned": "border-indigo-300 bg-indigo-50 text-indigo-700",
    "Ongoing": "border-blue-300 bg-blue-50 text-blue-700",
    "Completed": "border-success/30 bg-success/10 text-success",
    "On Hold": "border-warning/40 bg-warning/15 text-warning-foreground",
    "Cancelled": "border-destructive/30 bg-destructive/10 text-destructive",
  } as Record<TreeTaskStage, string>)[s] ?? "border-border bg-muted text-muted-foreground";
}

function getTasksFromServiceModel(serviceModel: string): { suffix: string; label: string }[] {
  const norm = (serviceModel || "").trim().toUpperCase();
  if (norm === "NA" || norm === "N/A") {
    return [{ suffix: "01", label: "NA" }];
  }
  if (norm.includes("INITIAL + 1")) {
    return [
      { suffix: "01", label: "Initial Test" },
      { suffix: "02", label: "Retest 1" },
    ];
  }
  if (norm.includes("INITIAL + 2")) {
    return [
      { suffix: "01", label: "Initial Test" },
      { suffix: "02", label: "Retest 1" },
      { suffix: "03", label: "Retest 2" },
    ];
  }
  if (norm.includes("INITIAL + 3")) {
    return [
      { suffix: "01", label: "Initial Test" },
      { suffix: "02", label: "Retest 1" },
      { suffix: "03", label: "Retest 2" },
      { suffix: "04", label: "Retest 3" },
    ];
  }
  return [{ suffix: "01", label: "Initial Test" }];
}

function computeAggregateStage(stages: TreeTaskStage[]): TreeTaskStage {
  if (stages.length === 0) return "Not Started";
  if (stages.every(s => s === "Completed")) return "Completed";
  if (stages.every(s => s === "Not Started")) return "Not Started";
  if (stages.every(s => s === "On Hold")) return "On Hold";
  if (stages.every(s => s === "Cancelled")) return "Cancelled";

  if (stages.includes("Ongoing")) return "Ongoing";
  if (stages.includes("On Hold")) return "On Hold";
  if (stages.includes("Not Started")) return "Not Started";
  if (stages.includes("Cancelled")) return "Cancelled";
  return "Completed";
}

interface TreeTask {
  id: string;
  taskId: string;
  serviceModel: string;
  actualStartDate: string;
  actualEndDate: string;
  stage: TreeTaskStage;
  assigneeIds: string[];
  estHoursPerTask: number;
}

interface APFolder {
  id: string;
  label: string;
  tasks: TreeTask[];
}

interface QuarterFolder {
  id: string;
  label: string;
  aps: APFolder[];
}

interface ServiceFolder {
  serviceId: string;
  serviceName: string;
  wbsStartDate: string;
  wbsEndDate: string;
  estimatedHours: number;
  quarters: QuarterFolder[] | null;
  aps: APFolder[] | null;
}

function buildServiceTree(project: Project, store: any): ServiceFolder[] {
  if (!project.wbsDetails?.services) return [];

  return project.wbsDetails.services.map((svc) => {
    const qty = svc.qty || 1;
    const freq = (svc.frequency || "Once").toLowerCase();
    const serviceModel = svc.serviceModel || "Initial Test";
    const estHours = svc.totalHrs ?? (svc.totalDays ? svc.totalDays * 8 : svc.duration * 8);

    const taskSpecs = getTasksFromServiceModel(serviceModel);

    const apList: string[] = [];
    for (let i = 1; i <= qty; i++) {
      apList.push(`AP${i}`);
    }

    let numQuarters = 0;
    if (freq.includes("half")) {
      numQuarters = 2;
    } else if (freq.includes("year")) {
      numQuarters = 4;
    }

    const totalTasksCount = (numQuarters || 1) * qty * taskSpecs.length;
    const estHoursPerTask = totalTasksCount > 0 ? estHours / totalTasksCount : 0;

    const buildTasks = (quarterNum: number | null, apName: string): TreeTask[] => {
      return taskSpecs.map((spec) => {
        const qPart = quarterNum !== null ? `q${quarterNum}-` : "";
        const taskId = `${project.id}-${svc.id}-${qPart}${apName.toLowerCase()}-t${spec.suffix}`;

        const liveState = store.getTreeTaskState(project.id, taskId);

        return {
          id: taskId,
          taskId: `Task ${spec.suffix}`,
          serviceModel: spec.label,
          actualStartDate: liveState.actualStartDate,
          actualEndDate: liveState.actualEndDate,
          stage: liveState.stage as TreeTaskStage,
          assigneeIds: liveState.assigneeIds,
          estHoursPerTask,
        };
      });
    };

    if (numQuarters > 0) {
      const quarters: QuarterFolder[] = [];
      for (let q = 1; q <= numQuarters; q++) {
        const aps: APFolder[] = apList.map((apName) => {
          const apId = `${project.id}-${svc.id}-q${q}-${apName.toLowerCase()}`;
          return {
            id: apId,
            label: apName,
            tasks: buildTasks(q, apName),
          };
        });
        quarters.push({
          id: `${project.id}-${svc.id}-q${q}`,
          label: `Quarter ${q}`,
          aps,
        });
      }
      return {
        serviceId: svc.id,
        serviceName: svc.serviceName || svc.department,
        wbsStartDate: svc.startDate,
        wbsEndDate: svc.endDate,
        estimatedHours: estHours,
        quarters,
        aps: null,
      };
    } else {
      const aps: APFolder[] = apList.map((apName) => {
        const apId = `${project.id}-${svc.id}-${apName.toLowerCase()}`;
        return {
          id: apId,
          label: apName,
          tasks: buildTasks(null, apName),
        };
      });
      return {
        serviceId: svc.id,
        serviceName: svc.serviceName || svc.department,
        wbsStartDate: svc.startDate,
        wbsEndDate: svc.endDate,
        estimatedHours: estHours,
        quarters: null,
        aps,
      };
    }
  });
}

const expandedNodesMap = new Map<string, Set<string>>();

function DhTasksTab({ project }: { project: Project }) {
  const snapshot = useDhStore((s) => s);
  const prereq = snapshot.prereqs[project.id];
  const shadowTeamIds = snapshot.shadowTeams[project.id] ?? [];

  const tree = useMemo(() => {
    return buildServiceTree(project, dhStore);
  }, [project, snapshot.treeTaskStates]);

  const visibleTree = useMemo(() => {
    if (!prereq) return [];
    return tree.filter((svcFolder) => {
      const pSvc = prereq.services?.find((s) => s.serviceId === svcFolder.serviceId);
      return pSvc ? pSvc.isReady : false;
    });
  }, [tree, prereq]);

  const [expandedNodes, setExpandedNodes] = useState<Set<string>>(() => {
    const existing = expandedNodesMap.get(project.id);
    if (existing) return existing;
    return new Set<string>();
  });

  const updateExpanded = (newSet: Set<string>) => {
    setExpandedNodes(newSet);
    expandedNodesMap.set(project.id, newSet);
  };

  const toggleNode = (nodeId: string) => {
    const newSet = new Set(expandedNodes);
    if (newSet.has(nodeId)) {
      newSet.delete(nodeId);
    } else {
      newSet.add(nodeId);
    }
    updateExpanded(newSet);
  };

  const handleExpandAll = () => {
    const newSet = new Set<string>();
    visibleTree.forEach(svc => {
      newSet.add(`svc-${svc.serviceId}`);
      if (svc.quarters) {
        svc.quarters.forEach(q => {
          newSet.add(q.id);
          q.aps.forEach(ap => {
            newSet.add(ap.id);
          });
        });
      } else if (svc.aps) {
        svc.aps.forEach(ap => {
          newSet.add(ap.id);
        });
      }
    });
    updateExpanded(newSet);
  };

  const handleCollapseAll = () => {
    updateExpanded(new Set<string>());
  };

  type TreeRow =
    | { type: "service"; id: string; service: ServiceFolder; depth: number }
    | { type: "quarter"; id: string; quarter: QuarterFolder; service: ServiceFolder; depth: number }
    | { type: "ap"; id: string; ap: APFolder; service: ServiceFolder; depth: number };

  const flattenedRows = useMemo(() => {
    const rows: TreeRow[] = [];
    visibleTree.forEach((svc) => {
      const svcId = `svc-${svc.serviceId}`;
      rows.push({ type: "service", id: svcId, service: svc, depth: 0 });

      if (expandedNodes.has(svcId)) {
        if (svc.quarters) {
          svc.quarters.forEach((q) => {
            rows.push({ type: "quarter", id: q.id, quarter: q, service: svc, depth: 1 });

            if (expandedNodes.has(q.id)) {
              q.aps.forEach((ap) => {
                rows.push({ type: "ap", id: ap.id, ap, service: svc, depth: 2 });
              });
            }
          });
        } else if (svc.aps) {
          svc.aps.forEach((ap) => {
            rows.push({ type: "ap", id: ap.id, ap, service: svc, depth: 1 });
          });
        }
      }
    });
    return rows;
  }, [visibleTree, expandedNodes]);

  const [assignFor, setAssignFor] = useState<TreeTask | null>(null);
  const liveAssignments = useDhStore((s) => s.taskAssignments);

  const teamPool = useMemo(() => {
    const projectTeamAdditionIds = snapshot.projectTeamAdditions[project.id] ?? [];
    const removedIds = snapshot.projectTeamRemovals[project.id] ?? [];
    const ids = Array.from(new Set([project.pmId, project.tlId, ...project.teamIds, ...projectTeamAdditionIds, ...shadowTeamIds]))
      .filter(id => !removedIds.includes(id));
    return ids.map((id) => {
      const person = getPerson(id);
      return { person, isProjectTeam: project.pmId === id || project.tlId === id || project.teamIds.includes(id) || projectTeamAdditionIds.includes(id), isShadowTeam: shadowTeamIds.includes(id) };
    });
  }, [project, shadowTeamIds, snapshot.projectTeamAdditions, snapshot.projectTeamRemovals]);

  const getDescendantTasks = (row: TreeRow): TreeTask[] => {
    if (row.type === "ap") return row.ap.tasks;
    if (row.type === "quarter") return row.quarter.aps.flatMap(ap => ap.tasks);
    const svc = row.service;
    return svc.quarters
      ? svc.quarters.flatMap(q => q.aps.flatMap(ap => ap.tasks))
      : (svc.aps ? svc.aps.flatMap(ap => ap.tasks) : []);
  };

  return (
    <>
      <div className="mb-4 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <button
            onClick={handleExpandAll}
            className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-2.5 py-1.5 text-xs font-medium hover:bg-accent text-muted-foreground hover:text-foreground transition-colors"
          >
            <ChevronsDown className="h-3.5 w-3.5" /> Expand All
          </button>
          <button
            onClick={handleCollapseAll}
            className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-2.5 py-1.5 text-xs font-medium hover:bg-accent text-muted-foreground hover:text-foreground transition-colors"
          >
            <ChevronsUp className="h-3.5 w-3.5" /> Collapse All
          </button>
        </div>
        <div className="text-xs text-muted-foreground">
          Showing {visibleTree.length} active service tree(s)
        </div>
      </div>

      <div className="overflow-x-auto rounded-lg border border-border">
        <table className="w-full text-sm">
          <thead className="sticky top-0 bg-muted/90 backdrop-blur-sm text-center text-xs uppercase tracking-wide text-muted-foreground z-10 border-b border-border">
            <tr>
              <th className="px-4 py-3 text-left font-medium whitespace-nowrap min-w-[280px]">Name &amp; Hierarchy</th>
              <th className="px-3 py-3 font-medium whitespace-nowrap">Service ID</th>
              <th className="px-3 py-3 font-medium whitespace-nowrap">Start Date</th>
              <th className="px-3 py-3 font-medium whitespace-nowrap">End Date</th>
              <th className="px-3 py-3 font-medium whitespace-nowrap">Hours (Utilized / Est.)</th>
              <th className="px-3 py-3 font-medium whitespace-nowrap">Progress</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border/40">
            {project.wbsDetails?.services?.length === 0 ? (
              <tr>
                <td colSpan={6} className="px-3 py-10 text-center text-sm text-muted-foreground">
                  No services onboarding details found — create WBS first.
                </td>
              </tr>
            ) : visibleTree.length === 0 ? (
              <tr>
                <td colSpan={6} className="px-3 py-10 text-center text-sm text-muted-foreground">
                  No active services. Start services from the Prerequisites tab to populate tasks.
                </td>
              </tr>
            ) : (
              flattenedRows.map((row) => {
                const descendantTasks = getDescendantTasks(row);

                const totalEstimatedHours = row.type === "service" ? row.service.estimatedHours : 0;
                const totalUtilizedHours = descendantTasks.reduce((sum, t) => {
                  return sum + (t.stage === "Completed" ? t.estHoursPerTask : 0);
                }, 0);

                const isExpanded = expandedNodes.has(row.id);
                const depthPadding = row.depth * 28;

                if (row.type === "service") {
                  const svc = row.service;

                  const nonCancelledTasks = descendantTasks.filter(t => t.stage !== "Cancelled");
                  const totalTasksCount = nonCancelledTasks.length;
                  let progress = 0;
                  if (totalTasksCount > 0) {
                    const sumWeights = nonCancelledTasks.reduce((sum, t) => {
                      if (t.stage === "Completed") return sum + 1;
                      if (t.stage === "Ongoing") return sum + 0.5;
                      return sum;
                    }, 0);
                    progress = Math.round((sumWeights / totalTasksCount) * 100);
                  }

                  return (
                    <tr key={row.id} className="hover:bg-accent/5 font-semibold bg-muted/20 border-b border-border/40">
                      <td className="px-4 py-3 align-middle text-left whitespace-nowrap" style={{ paddingLeft: `${depthPadding + 16}px` }}>
                        <div className="flex items-center gap-2">
                          <button
                            onClick={() => toggleNode(row.id)}
                            className="p-1 hover:bg-muted rounded text-muted-foreground hover:text-foreground transition-colors"
                          >
                            <ChevronRight className={cn("h-3.5 w-3.5 transform transition-transform", isExpanded && "rotate-90")} />
                          </button>
                          {isExpanded ? (
                            <FolderOpen className="h-4 w-4 text-blue-500 fill-blue-50/20" />
                          ) : (
                            <Folder className="h-4 w-4 text-blue-500 fill-blue-50/20" />
                          )}
                          <span className="text-foreground">{svc.serviceName}</span>
                        </div>
                      </td>
                      <td className="px-3 py-3 text-center align-middle font-mono text-[11px] text-muted-foreground whitespace-nowrap">
                        {svc.serviceId}
                      </td>
                      <td className="px-3 py-3 text-center align-middle text-xs text-muted-foreground whitespace-nowrap">
                        {formatDateString(svc.wbsStartDate)}
                      </td>
                      <td className="px-3 py-3 text-center align-middle text-xs text-muted-foreground whitespace-nowrap">
                        {formatDateString(svc.wbsEndDate)}
                      </td>
                      <td className="px-3 py-3 text-center align-middle tabular-nums text-muted-foreground">
                        {totalUtilizedHours.toFixed(1)} / {totalEstimatedHours.toFixed(1)} hrs
                      </td>
                      <td className="px-3 py-3 text-center align-middle">
                        <div className="flex items-center justify-center gap-2">
                          <div className="w-16 bg-muted-foreground/20 rounded-full h-1.5 overflow-hidden">
                            <div className="bg-primary h-full rounded-full" style={{ width: `${progress}%` }}></div>
                          </div>
                          <span className="font-mono text-xs font-semibold text-foreground/80">{progress}%</span>
                        </div>
                      </td>
                    </tr>
                  );
                }

                if (row.type === "quarter") {
                  const q = row.quarter;
                  return (
                    <tr key={row.id} className="hover:bg-accent/5 text-foreground/80 font-medium border-b border-border/20 py-1">
                      <td className="px-4 py-1.5 align-middle text-left whitespace-nowrap" style={{ paddingLeft: `${depthPadding + 16}px` }}>
                        <div className="flex items-center gap-2">
                          <button
                            onClick={() => toggleNode(row.id)}
                            className="p-1 hover:bg-muted rounded text-muted-foreground hover:text-foreground transition-colors"
                          >
                            <ChevronRight className={cn("h-3.5 w-3.5 transform transition-transform", isExpanded && "rotate-90")} />
                          </button>
                          {isExpanded ? (
                            <FolderOpen className="h-4 w-4 text-orange-500 fill-orange-50/20" />
                          ) : (
                            <Folder className="h-4 w-4 text-orange-500 fill-orange-50/20" />
                          )}
                          <span className="text-foreground/90">{q.label}</span>
                        </div>
                      </td>
                      <td></td>
                      <td></td>
                      <td></td>
                      <td></td>
                      <td></td>
                    </tr>
                  );
                }

                if (row.type === "ap") {
                  const ap = row.ap;
                  const svc = row.service;
                  const apEstimatedHours = descendantTasks.reduce((sum, t) => sum + (t.estHoursPerTask || 0), 0);
                  const apUtilizedHours = descendantTasks.reduce((sum, t) => {
                    return sum + (t.stage === "Completed" ? (t.estHoursPerTask || 0) : 0);
                  }, 0);

                  const nonCancelledTasks = descendantTasks.filter(t => t.stage !== "Cancelled");
                  const totalTasksCount = nonCancelledTasks.length;
                  let progress = 0;
                  if (totalTasksCount > 0) {
                    const sumWeights = nonCancelledTasks.reduce((sum, t) => {
                      if (t.stage === "Completed") return sum + 1;
                      if (t.stage === "Ongoing") return sum + 0.5;
                      return sum;
                    }, 0);
                    progress = Math.round((sumWeights / totalTasksCount) * 100);
                  }

                  const apStartDates = descendantTasks.map(t => t.actualStartDate).filter(Boolean);
                  const apEndDates = descendantTasks.map(t => t.actualEndDate).filter(Boolean);

                  const apStartDate = apStartDates.length > 0
                    ? apStartDates.reduce((earliest, curr) => curr < earliest ? curr : earliest)
                    : svc.wbsStartDate;

                  const apEndDate = apEndDates.length > 0
                    ? apEndDates.reduce((latest, curr) => curr > latest ? curr : latest)
                    : svc.wbsEndDate;

                  return (
                    <React.Fragment key={row.id}>
                      <tr className="hover:bg-accent/5 text-foreground/80 font-medium border-b border-border/20 py-1 bg-muted/5">
                        <td className="px-4 py-2 align-middle text-left whitespace-nowrap" style={{ paddingLeft: `${depthPadding + 16}px` }}>
                          <div className="flex items-center gap-2">
                            <button
                              onClick={() => toggleNode(row.id)}
                              className="p-1 hover:bg-muted rounded text-muted-foreground hover:text-foreground transition-colors"
                            >
                              <ChevronRight className={cn("h-3.5 w-3.5 transform transition-transform", isExpanded && "rotate-90")} />
                            </button>
                            {isExpanded ? (
                              <FolderOpen className="h-4 w-4 text-emerald-600 fill-emerald-50/20" />
                            ) : (
                              <Folder className="h-4 w-4 text-emerald-600 fill-emerald-50/20" />
                            )}
                            <span className="text-foreground/90">{ap.label}</span>
                          </div>
                        </td>
                        <td className="px-3 py-2 text-center align-middle font-mono text-[11px] text-muted-foreground whitespace-nowrap">
                          {svc.serviceId}
                        </td>
                        <td className="px-3 py-2 text-center align-middle text-xs text-muted-foreground whitespace-nowrap">
                          {formatDateString(apStartDate)}
                        </td>
                        <td className="px-3 py-2 text-center align-middle text-xs text-muted-foreground whitespace-nowrap">
                          {formatDateString(apEndDate)}
                        </td>
                        <td className="px-3 py-2 text-center align-middle tabular-nums text-muted-foreground">
                          {apUtilizedHours.toFixed(1)} / {apEstimatedHours.toFixed(1)} hrs
                        </td>
                        <td className="px-3 py-2 text-center align-middle">
                          <div className="flex items-center justify-center gap-2">
                            <div className="w-16 bg-muted-foreground/20 rounded-full h-1.5 overflow-hidden">
                              <div className="bg-emerald-600 h-full rounded-full" style={{ width: `${progress}%` }}></div>
                            </div>
                            <span className="font-mono text-xs font-semibold text-foreground/80">{progress}%</span>
                          </div>
                        </td>
                      </tr>

                      {isExpanded && (
                        <tr key={`${row.id}-tasks-container`}>
                          <td colSpan={6} className="bg-transparent pb-4 pt-1.5 pr-4" style={{ paddingLeft: `${depthPadding + 44}px` }}>
                            <div className="w-full overflow-hidden">
                              <table className="w-full text-sm text-left border-none bg-transparent">
                                <thead className="bg-transparent text-[10px] uppercase tracking-wider text-muted-foreground border-b border-border/40 z-10">
                                  <tr>
                                    <th className="px-3 py-2 font-semibold">Task ID</th>
                                    <th className="px-3 py-2 font-semibold">Service Model</th>
                                    <th className="px-3 py-2 font-semibold">Actual Start</th>
                                    <th className="px-3 py-2 font-semibold">Actual End</th>
                                    <th className="px-3 py-2 font-semibold">Assigned Resources</th>
                                    <th className="px-3 py-2 font-semibold">Actions</th>
                                    <th className="px-3 py-2 font-semibold">Stage</th>
                                  </tr>
                                </thead>
                                <tbody className="divide-y divide-border/20">
                                  {ap.tasks.map((t) => {
                                    const liveIds = (liveAssignments[t.id]?.assigneeIds ?? dhStore.getTreeTaskAssignees(project.id, t.id))
                                      .filter(Boolean);
                                    const assignees = liveIds.map((id) => {
                                      const p = getPerson(id);
                                      const btId = `${t.id}-${id}`;
                                      const bt = snapshot.bucketTasks?.find((x) => x.id === btId);
                                      const started = bt ? bt.status !== "Not Started" : false;
                                      return {
                                        id,
                                        name: p ? p.name : id,
                                        started,
                                      };
                                    });
                                    const isStarted = t.stage !== "Not Started" && t.stage !== "Assigned";

                                    return (
                                      <tr key={t.id} className="hover:bg-accent/10 transition-colors">
                                        <td className="px-3 py-1.5 align-middle font-medium text-xs whitespace-nowrap text-foreground/90">
                                          <div className="flex items-center gap-1.5 h-8">
                                            <FileText className="h-3.5 w-3.5 text-slate-400" />
                                            <span>{t.taskId}</span>
                                          </div>
                                        </td>
                                        <td className="px-3 py-1.5 align-middle text-xs text-muted-foreground max-w-[160px] truncate">
                                          <div className="flex items-center h-8" title={t.serviceModel}>
                                            {t.serviceModel}
                                          </div>
                                        </td>
                                        <td className="px-3 py-1.5 align-middle">
                                          <div className="flex items-center h-8">
                                            <input
                                              type="date"
                                              value={t.actualStartDate}
                                              onChange={(e) => {
                                                const newStart = e.target.value;
                                                const estHrs = t.estHoursPerTask || 0;
                                                const autoEndDate = newStart && estHrs > 0 ? addWorkingDaysFromDate(newStart, Math.ceil(estHrs / 8)) : "";
                                                dhStore.updateTreeTaskState(project.id, t.id, {
                                                  actualStartDate: newStart,
                                                  actualEndDate: autoEndDate,
                                                  ...(t.stage === "Not Started" && newStart ? { stage: "Ongoing" } : {})
                                                });
                                              }}
                                              className="h-7 w-28 rounded-md border border-input bg-card px-2 text-[11px] outline-none focus-visible:ring-1 focus-visible:ring-ring"
                                            />
                                          </div>
                                        </td>
                                        <td className="px-3 py-1.5 align-middle">
                                          <div className="flex items-center h-8">
                                            <input
                                              type="date"
                                              value={t.actualEndDate}
                                              onChange={(e) => {
                                                dhStore.updateTreeTaskState(project.id, t.id, {
                                                  actualEndDate: e.target.value,
                                                });
                                              }}
                                              className="h-7 w-28 rounded-md border border-input bg-card px-2 text-[11px] outline-none focus-visible:ring-1 focus-visible:ring-ring"
                                            />
                                          </div>
                                        </td>
                                        <td className="px-3 py-1.5 align-middle">
                                          <div className="flex items-center h-8">
                                            <AvatarStack assignees={assignees} />
                                          </div>
                                        </td>
                                        <td className="px-3 py-1.5 align-middle">
                                          <div className="flex items-center h-8">
                                            <button
                                              onClick={() => setAssignFor(t)}
                                              className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-2 py-1 text-[10px] hover:bg-accent text-muted-foreground hover:text-foreground transition-colors"
                                            >
                                              <UserPlus className="h-3.5 w-3.5" /> Assign
                                            </button>
                                          </div>
                                        </td>
                                        <td className="px-3 py-1.5 align-middle">
                                          <div className="flex items-center h-8">
                                            {!isStarted ? (
                                              <span className={cn("inline-flex items-center rounded-full border px-2.5 py-0.5 text-[10px] font-medium shadow-sm", treeStageCls(t.stage as any))}>
                                                {t.stage || "Not Started"}
                                              </span>
                                            ) : (
                                              <select
                                                value={t.stage}
                                                onChange={(e) => {
                                                  const v = e.target.value as TreeTaskStage;
                                                  dhStore.updateTreeTaskState(project.id, t.id, { stage: v });
                                                  toast.success("Stage updated", { description: `${t.taskId} → ${v}` });
                                                }}
                                                className={cn("h-7 rounded-full border px-2 text-[10px] font-medium outline-none focus-visible:ring-1 focus-visible:ring-ring", treeStageCls(t.stage))}
                                              >
                                                {TREE_TASK_STAGES.filter(s => s !== "Not Started").map((s) => (
                                                  <option key={s} value={s}>{s}</option>
                                                ))}
                                              </select>
                                            )}
                                          </div>
                                        </td>
                                      </tr>
                                    );
                                  })}
                                </tbody>
                              </table>
                            </div>
                          </td>
                        </tr>
                      )}
                    </React.Fragment>
                  );
                }

                return null;
              })
            )}
          </tbody>
        </table>
      </div>

      {assignFor && (
        <AssignTaskModal
          task={{ id: assignFor.id, title: `${assignFor.taskId} - ${assignFor.serviceModel}` }}
          pool={teamPool}
          project={project}
          selected={liveAssignments[assignFor.id]?.assigneeIds ?? dhStore.getTreeTaskAssignees(project.id, assignFor.id)}
          onClose={() => setAssignFor(null)}
          onSave={(ids) => {
            const parentSvc = visibleTree.find(s => {
              if (s.quarters) {
                return s.quarters.some(q => q.aps.some(a => a.tasks.some(task => task.id === assignFor.id)));
              } else if (s.aps) {
                return s.aps.some(a => a.tasks.some(task => task.id === assignFor.id));
              }
              return false;
            });
            const svcName = parentSvc?.serviceName || "";
            const taskTitle = parentSvc ? `${svcName} - ${assignFor.serviceModel}` : `${assignFor.taskId} - ${assignFor.serviceModel}`;
            const dueDate = parentSvc?.wbsEndDate || "";

            dhStore.assignResourcesToTreeTask(project.id, assignFor.id, ids, taskTitle, dueDate, "medium");
            toast.success("Assignments updated", { description: `${ids.length} member(s) assigned` });
            setAssignFor(null);
          }}
        />
      )}
    </>
  );
}

function AssignTaskModal({ project, task, pool, selected, onClose, onSave }: { project: Project; task: Task | { id: string; title: string }; pool: { person: Person; isProjectTeam: boolean; isShadowTeam: boolean }[]; selected: string[]; onClose: () => void; onSave: (ids: string[]) => void }) {
  const [sel, setSel] = useState<string[]>(selected);
  const [q, setQ] = useState("");

  const isTreeTask = !project.tasks.some((t) => t.id === task.id);
  // Load assignment history persistently
  const assignment = isTreeTask
    ? dhStore.getTreeTaskAssignment(project.id, task.id)
    : dhStore.getTaskAssignment(project.id, task.id);
  const history = assignment.history;

  const toggle = (id: string) => setSel((s) => s.includes(id) ? s.filter((x) => x !== id) : [...s, id]);
  const visible = pool.filter(({ person: p }) => !q.trim() || p.name.toLowerCase().includes(q.toLowerCase()));

  return (
    <Modal title={`Assign — ${task.title}`} onClose={onClose}>
      <div className="space-y-4">
        <p className="text-xs text-muted-foreground">Resources from Project Team and Shadow Team can be assigned. Select one or more.</p>
        <div className="relative">
          <Search className="pointer-events-none absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
          <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search team member…"
            className="h-9 w-full rounded-md border border-input bg-background pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring" />
        </div>
        {sel.length > 0 && (
          <div className="flex flex-wrap gap-1.5 border-b border-border pb-3">
            {sel.map((id) => {
              const p = getPerson(id);
              const teamInfo = pool.find(item => item.person.id === id);
              const teamLabel = teamInfo?.isShadowTeam ? "(Shadow Team)" : "(Project Team)";
              return (
                <span key={id} className={cn("inline-flex items-center gap-1.5 rounded-full border py-0.5 pl-1 pr-2 text-xs font-medium shadow-sm",
                  teamInfo?.isShadowTeam ? "bg-purple-50 text-purple-700 border-purple-200" : "bg-blue-50 text-blue-700 border-blue-200")}>
                  <Avatar name={p.name} size={18} /> {p.name} <span className="text-[10px] text-muted-foreground">{teamLabel}</span>
                  <button onClick={() => toggle(id)} className="ml-1 text-muted-foreground hover:text-foreground"><X className="h-3 w-3" /></button>
                </span>
              );
            })}
          </div>
        )}
        <ul className="max-h-48 divide-y divide-border overflow-y-auto rounded-md border border-border">
          {visible.map(({ person: p, isProjectTeam, isShadowTeam }) => {
            const isSel = sel.includes(p.id);
            const teamLabel = isShadowTeam ? "Shadow Team" : "Project Team";
            return (
              <li key={p.id}>
                <button onClick={() => toggle(p.id)}
                  className={cn("flex w-full items-center gap-3 px-3 py-2 text-left hover:bg-accent/40", isSel && "bg-primary/5")}>
                  <Avatar name={p.name} size={26} />
                  <div className="flex-1 min-w-0">
                    <div className="text-sm font-medium">{p.name}</div>
                    <div className="text-[11px] text-muted-foreground flex items-center gap-1.5">
                      <span>{p.role}</span>
                      <span>·</span>
                      <span className={cn("inline-flex px-1.5 py-0.2 rounded text-[9px] font-semibold border",
                        isShadowTeam ? "bg-purple-50 text-purple-700 border-purple-200" : "bg-blue-50 text-blue-700 border-blue-200")}>
                        {teamLabel}
                      </span>
                    </div>
                  </div>
                  {isSel && <Check className="h-4 w-4 text-primary" />}
                </button>
              </li>
            );
          })}
          {visible.length === 0 && <li className="px-3 py-6 text-center text-xs text-muted-foreground">No match</li>}
        </ul>

        {/* Assignment History Log */}
        <div className="border-t border-border pt-3">
          <label className="text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">Assignment History Log</label>
          <ul className="mt-2 max-h-28 overflow-y-auto space-y-1 text-xs text-muted-foreground divide-y divide-border pr-1">
            {history.map((h, i) => (
              <li key={i} className="flex justify-between items-center py-1.5">
                <span>
                  <strong>{h.resourceName}</strong> was{" "}
                  <span className={cn("font-semibold", h.action === "Assign" ? "text-success" : "text-destructive")}>{h.action.toLowerCase()}ed</span>{" "}
                  as <strong>{h.teamType}</strong>
                </span>
                <span className="text-[10px] text-muted-foreground">
                  {new Date(h.timestamp).toLocaleDateString()} {new Date(h.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                </span>
              </li>
            ))}
            {history.length === 0 && (
              <li className="text-center py-3 text-xs text-muted-foreground">No assignment history yet</li>
            )}
          </ul>
        </div>

        <div className="flex justify-end gap-2 border-t border-border pt-3">
          <button onClick={onClose} className="rounded-md border border-input bg-card px-3 py-1.5 text-xs hover:bg-accent">Cancel</button>
          <button onClick={() => onSave(sel)} className="rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90">Save Assignments</button>
        </div>
      </div>
    </Modal>
  );
}

// ---------- Default Team (other roles) ----------
function DefaultTeamTab({ project, pm, tl, team }: { project: Project; pm: Person; tl: Person; team: Person[] }) {
  return (
    <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
      {[pm, tl, ...team].map((m) => {
        const tasks = project.tasks.filter((t) => t.assigneeId === m.id);
        return (
          <div key={m.id} className="rounded-lg border border-border bg-card p-4">
            <div className="flex items-center gap-3">
              <Avatar name={m.name} size={36} />
              <div>
                <div className="text-sm font-semibold">{m.name}</div>
                <div className="text-xs text-muted-foreground">{m.role}</div>
              </div>
            </div>
            <div className="mt-3 text-xs text-muted-foreground">{tasks.length} active {tasks.length === 1 ? "task" : "tasks"}</div>
            <ul className="mt-2 space-y-1">
              {tasks.slice(0, 3).map((t) => (
                <li key={t.id} className="flex items-center justify-between gap-2 text-xs">
                  <span className="truncate">{t.title}</span>
                  <TaskStatusPill status={t.status} />
                </li>
              ))}
              {tasks.length === 0 && <li className="text-xs text-muted-foreground">No assigned tasks</li>}
            </ul>
          </div>
        );
      })}
    </div>
  );
}

// ---------- Dhanshree Team ----------
type ActionType = null | "view" | "edit" | "remove" | "praise" | "feedback" | "request" | "add";
type TeamTabType = "project" | "shadow";

function DhTeamTab({ project }: { project: Project }) {
  const snapshot = useDhStore((s) => s);
  const prereq = snapshot.prereqs[project.id];

  const [teamTab, setTeamTab] = useState<TeamTabType>("project");
  const [menuOpen, setMenuOpen] = useState<string | null>(null);
  const [action, setAction] = useState<{ type: ActionType; person: Person | null }>({ type: null, person: null });
  const [showAddModal, setShowAddModal] = useState(false);
  const removedIds = useMemo(() => new Set(snapshot.projectTeamRemovals[project.id] ?? []), [snapshot.projectTeamRemovals, project.id]);

  // Reactive access to DhStore shadow team records
  const shadowTeamIds = snapshot.shadowTeams[project.id] ?? [];
  const shadowDetails = snapshot.shadowTeamDetails[project.id] ?? {};

  // Project team: base rows from helper, overridden by persisted store details
  const projectTeamOverrides = snapshot.projectTeamDetails[project.id] ?? {};
  const projectTeamAdditionIds = snapshot.projectTeamAdditions[project.id] ?? [];

  const rows = useMemo(() => {
    // Base members from project (PM, TL, team)
    const base = getProjectTeam(project)
      .filter((r) => !removedIds.has(r.person.id))
      .map((r) => {
        const override = projectTeamOverrides[r.person.id];
        return override ? { ...r, ...override } : r;
      });

    // Members added at runtime via Add Team Member modal
    const additions = projectTeamAdditionIds
      .filter((id) => !removedIds.has(id))
      .map((id) => {
        const person = getPerson(id);
        const detail = projectTeamOverrides[id] ?? {
          duration: "",
          billability: "Billable" as Billability,
          resourceType: "Dedicated" as ResourceType,
        };
        return { person, ...detail };
      });

    return [...base, ...additions];
  }, [project, projectTeamOverrides, projectTeamAdditionIds, removedIds]);

  const shadowRows = useMemo(() => {
    return shadowTeamIds.map(id => {
      const person = getPerson(id);
      const detail = shadowDetails[id] || { duration: `${new Date(project.startDate).toLocaleDateString()} → ${new Date(project.endDate).toLocaleDateString()}`, billability: "Non-Billable" as Billability, resourceType: "Shared Resource" as ResourceType };
      return {
        person,
        duration: detail.duration,
        billability: detail.billability,
        resourceType: detail.resourceType
      };
    });
  }, [shadowTeamIds, shadowDetails, project]);

  const updateRow = (id: string, patch: Partial<typeof rows[number]>) => {
    dhStore.updateProjectTeamMember(project.id, id, patch);
  };
  const removeRow = (id: string) => {
    dhStore.removeProjectTeamMember(project.id, id);
    toast.success("Resource removed from team");
  };

  // Access-blocked guard AFTER all hooks
  const hasSPM = (prereq?.assignedSpmIds?.length ?? 0) > 0;
  const hasPM = (prereq?.assignedPmIds?.length ?? 0) > 0;
  const isAssigned = hasPM && hasSPM;

  if (prereq && !isAssigned) {
    return (
      <div className="rounded-lg border border-warning/30 bg-warning/10 p-8 text-center">
        <AlertTriangle className="mx-auto h-8 w-8 text-amber-500 mb-2" />
        <h4 className="font-semibold text-sm mb-1 text-warning-foreground">Access Blocked — PM/SPM Not Assigned</h4>
        <p className="max-w-md mx-auto text-xs text-muted-foreground leading-relaxed">
          Team building, resource assignment, shadow team allocation, task assignment, and activity assignment are disabled until both PM and SPM are assigned.
        </p>
      </div>
    );
  }

  return (
    <>
      <div className="mb-4 flex items-center justify-between gap-4">
        <div className="flex gap-1 rounded-lg border border-border bg-muted/30 p-1">
          {(["project", "shadow"] as TeamTabType[]).map((t) => (
            <button
              key={t}
              onClick={() => setTeamTab(t)}
              className={cn("rounded-md px-3 py-1.5 text-xs font-medium transition-colors",
                teamTab === t ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground")}
            >
              {t === "project" ? "Project Team" : "Shadow Team"}
            </button>
          ))}
        </div>
        <button
          onClick={() => setShowAddModal(true)}
          className="inline-flex items-center gap-2 rounded-md bg-primary px-3 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90"
        >
          <Plus className="h-3.5 w-3.5" /> Add Team Member
        </button>
      </div>
      <div className="overflow-x-auto rounded-lg border border-border">
        <table className="w-full text-sm">
          <thead className="bg-muted/40 text-xs uppercase tracking-wide text-muted-foreground">
            <tr>
              <th className="px-4 py-2.5 text-left font-medium">Resource</th>
              <th className="px-3 py-2.5 text-center font-medium">Department</th>
              <th className="px-3 py-2.5 text-center font-medium">Sub Department</th>
              <th className="px-3 py-2.5 text-center font-medium">Allocation Duration</th>
              <th className="px-3 py-2.5 text-center font-medium">Billability</th>
              <th className="px-3 py-2.5 text-center font-medium">Resource Type</th>
              <th className="px-3 py-2.5 text-center font-medium">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {(teamTab === "project" ? rows : shadowRows).map((r) => (
              <tr key={r.person.id} className="hover:bg-accent/30">
                {/* Resource — left aligned with avatar */}
                <td className="px-4 py-3">
                  <div className="flex items-center gap-2.5">
                    <Avatar name={r.person.name} size={28} />
                    <div>
                      <div className="text-sm font-semibold leading-tight">{r.person.name}</div>
                      <div className="text-[11px] text-muted-foreground leading-tight">{r.person.role}</div>
                    </div>
                  </div>
                </td>
                {/* Department — center */}
                <td className="px-3 py-3 text-center text-sm align-middle">{getDept(r.person)}</td>
                {/* Sub Department — center */}
                <td className="px-3 py-3 text-center text-sm text-muted-foreground align-middle">{getSubDept(r.person)}</td>
                {/* Allocation Duration — center, monospaced */}
                <td className="px-3 py-3 text-center text-xs text-muted-foreground align-middle whitespace-nowrap">{r.duration || "—"}</td>
                {/* Billability — center pill */}
                <td className="px-3 py-3 text-center align-middle">
                  <span className={cn(
                    "inline-flex items-center rounded-full border px-2.5 py-0.5 text-[11px] font-medium",
                    r.billability === "Billable"
                      ? "bg-success/10 border-success/30 text-success"
                      : "bg-muted border-border text-muted-foreground"
                  )}>
                    {r.billability}
                  </span>
                </td>
                {/* Resource Type — center pill */}
                <td className="px-3 py-3 text-center align-middle">
                  <span className={cn(
                    "inline-flex items-center rounded-full border px-2.5 py-0.5 text-[11px] font-medium",
                    r.resourceType === "Dedicated"
                      ? "bg-primary/10 border-primary/30 text-primary"
                      : "bg-info/10 border-info/30 text-info"
                  )}>
                    {r.resourceType}
                  </span>
                </td>
                {/* Actions — center */}
                <td className="px-3 py-3 text-center align-middle">
                  <div className="relative inline-flex items-center gap-1">
                    <button title="View" onClick={() => setAction({ type: "view", person: r.person })}
                      className="rounded-md border border-input bg-card p-1.5 hover:bg-accent"><Eye className="h-3.5 w-3.5" /></button>
                    <button title="Edit" onClick={() => setAction({ type: "edit", person: r.person })}
                      className="rounded-md border border-input bg-card p-1.5 hover:bg-accent"><Pencil className="h-3.5 w-3.5" /></button>
                    <button title="Remove" onClick={() => setAction({ type: "remove", person: r.person })}
                      className="rounded-md border border-input bg-card p-1.5 text-destructive hover:bg-destructive/10"><Trash2 className="h-3.5 w-3.5" /></button>
                    <button title="More" onClick={() => setMenuOpen(menuOpen === r.person.id ? null : r.person.id)}
                      className="rounded-md border border-input bg-card p-1.5 hover:bg-accent"><MoreHorizontal className="h-3.5 w-3.5" /></button>
                    {menuOpen === r.person.id && (
                      <div className="absolute right-0 top-9 z-10 w-44 overflow-hidden rounded-md border border-border bg-card shadow-lg" onMouseLeave={() => setMenuOpen(null)}>
                        {[
                          { k: "praise", label: "Give Praise", icon: Star },
                          { k: "feedback", label: "Give Feedback", icon: MessageSquare },
                          { k: "request", label: "Request Feedback", icon: Send },
                        ].map((o) => (
                          <button key={o.k} onClick={() => { setMenuOpen(null); setAction({ type: o.k as ActionType, person: r.person }); }}
                            className="flex w-full items-center gap-2 px-3 py-2 text-left text-xs hover:bg-accent">
                            <o.icon className="h-3.5 w-3.5 text-muted-foreground" /> {o.label}
                          </button>
                        ))}
                      </div>
                    )}
                  </div>
                </td>
              </tr>
            ))}
            {(teamTab === "project" ? rows : shadowRows).length === 0 && (
              <tr><td colSpan={7} className="px-3 py-10 text-center text-sm text-muted-foreground">No {teamTab} team members allocated</td></tr>
            )}
          </tbody>
        </table>
      </div>

      {action.type && action.person && (
        <TeamActionModal
          action={action.type}
          person={action.person}
          project={project}
          teamType={teamTab}
          row={teamTab === "project" ? rows.find((r) => r.person.id === action.person!.id) : shadowRows.find((r) => r.person.id === action.person!.id)}
          onClose={() => setAction({ type: null, person: null })}
          onSaveEdit={(patch) => {
            if (teamTab === "project") {
              updateRow(action.person!.id, patch);
            } else {
              dhStore.updateShadowMember(project.id, action.person!.id, patch);
            }
            toast.success("Resource updated");
            setAction({ type: null, person: null });
          }}
          onConfirmRemove={() => {
            if (teamTab === "project") {
              removeRow(action.person!.id);
            } else {
              dhStore.removeShadowMember(project.id, action.person!.id);
              toast.success("Shadow team member removed");
            }
            setAction({ type: null, person: null });
          }}
        />
      )}

      {showAddModal && (
        <AddTeamMemberModal
          project={project}
          teamType={teamTab}
          existingPersonIds={(teamTab === "project" ? rows : shadowRows).map((r) => r.person.id)}
          onClose={() => setShowAddModal(false)}
          onAdd={(newRow) => {
            if (teamTab === "project") {
              dhStore.addProjectTeamMember(
                project.id,
                newRow.person.id,
                newRow.duration,
                newRow.billability,
                newRow.resourceType,
              );
            } else {
              dhStore.addShadowMember(project.id, newRow.person.id, newRow.duration, "Non-Billable", "Shared Resource");
            }
            toast.success("Team member added");
            setShowAddModal(false);
          }}
        />
      )}
    </>
  );
}

function TeamActionModal({ action, person, project, row, teamType = "project", onClose, onSaveEdit, onConfirmRemove }: {
  action: Exclude<ActionType, null>; person: Person; project: Project;
  row?: { person: Person; duration: string; billability: Billability; resourceType: ResourceType };
  teamType?: TeamTabType;
  onClose: () => void;
  onSaveEdit: (patch: { billability?: Billability; resourceType?: ResourceType; duration?: string }) => void;
  onConfirmRemove: () => void;
}) {
  const [editState, setEditState] = useState({
    billability: row?.billability ?? ("Billable" as Billability),
    resourceType: row?.resourceType ?? ("Dedicated" as ResourceType),
    duration: row?.duration ?? "",
  });
  const [praise, setPraise] = useState({ message: "", tag: "Team Player" });
  const [feedback, setFeedback] = useState({ strengths: "", improvements: "", comments: "", rating: 4 });
  const [requestNote, setRequestNote] = useState("");

  if (action === "view") {
    const tasks = project.tasks.filter((t) => t.assigneeId === person.id);
    return (
      <Modal title={`${person.name} — Workload`} onClose={onClose} wide>
        <div className="grid gap-4 md:grid-cols-3">
          <div className="md:col-span-1 space-y-3">
            <div className="flex items-center gap-3 rounded-lg border border-border bg-accent/30 p-3">
              <Avatar name={person.name} size={42} />
              <div>
                <div className="text-sm font-semibold">{person.name}</div>
                <div className="text-[11px] text-muted-foreground">{person.role}</div>
                <div className="text-[11px] text-muted-foreground">{person.email}</div>
              </div>
            </div>
            <Info icon={Calendar} label="Allocation" value={row?.duration ?? "—"} />
            <Info icon={Wallet} label="Billability" value={row?.billability ?? "—"} />
            <Info icon={Calendar} label="Resource Type" value={row?.resourceType ?? "—"} />
          </div>
          <div className="md:col-span-2 space-y-3">
            <div>
              <h4 className="mb-2 text-xs font-semibold uppercase tracking-wide text-muted-foreground">Assigned Tasks · {tasks.length}</h4>
              <ul className="space-y-1.5">
                {tasks.length === 0 && <li className="text-sm text-muted-foreground">No tasks assigned on this project</li>}
                {tasks.map((t) => (
                  <li key={t.id} className="flex items-center gap-2 rounded-md border border-border bg-card p-2 text-xs">
                    <span className="flex-1 truncate font-medium">{t.title}</span>
                    <TaskStatusPill status={t.status} />
                    <ProgressBar value={t.progress} className="w-20" />
                    <span className="w-8 text-right tabular-nums text-muted-foreground">{t.progress}%</span>
                  </li>
                ))}
              </ul>
            </div>
            <div>
              <h4 className="mb-2 text-xs font-semibold uppercase tracking-wide text-muted-foreground">Other Projects</h4>
              <ul className="space-y-1">
                {projects.filter((p) => p.id !== project.id && (p.pmId === person.id || p.tlId === person.id || p.teamIds.includes(person.id))).slice(0, 4).map((p) => (
                  <li key={p.id} className="flex items-center gap-2 text-xs">
                    <span className="flex-1 truncate">{p.name}</span>
                    <StatusPill status={p.status} />
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </div>
      </Modal>
    );
  }

  if (action === "edit") {
    return (
      <Modal title={`Edit Allocation — ${person.name}`} onClose={onClose}>
        <div className="space-y-3">
          <Field label="Allocation Duration">
            <DateRangePicker value={editState.duration} onChange={(val) => setEditState((s) => ({ ...s, duration: val }))} />
          </Field>

          <Field label="Billability">
            {teamType === "shadow" ? (
              <div className="flex items-center gap-2 h-9 px-3 rounded-md border border-border bg-muted/30">
                <span className="inline-flex items-center rounded-full border border-border bg-muted px-2.5 py-0.5 text-[11px] font-medium text-muted-foreground">Non-Billable</span>
                <span className="text-xs text-muted-foreground/60 italic">(fixed for shadow team)</span>
              </div>
            ) : (
              <select className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm" value={editState.billability} onChange={(e) => setEditState((s) => ({ ...s, billability: e.target.value as Billability }))}>
                {(["Billable", "Non-Billable"] as Billability[]).map((o) => <option key={o}>{o}</option>)}
              </select>
            )}
          </Field>

          <Field label="Resource Type">
            {teamType === "shadow" ? (
              <div className="flex items-center gap-2 h-9 px-3 rounded-md border border-border bg-muted/30">
                <span className="inline-flex items-center rounded-full border border-info/30 bg-info/10 px-2.5 py-0.5 text-[11px] font-medium text-info">Shared Resource</span>
                <span className="text-xs text-muted-foreground/60 italic">(fixed for shadow team)</span>
              </div>
            ) : (
              <select className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm" value={editState.resourceType} onChange={(e) => setEditState((s) => ({ ...s, resourceType: e.target.value as ResourceType }))}>
                {(["Dedicated", "Shared Resource"] as ResourceType[]).map((o) => <option key={o}>{o}</option>)}
              </select>
            )}
          </Field>

          <div className="flex justify-end gap-2 border-t border-border pt-3">
            <button onClick={onClose} className="rounded-md border border-input bg-card px-3 py-1.5 text-xs hover:bg-accent">Cancel</button>
            <button
              onClick={() => onSaveEdit(teamType === "shadow"
                ? { duration: editState.duration, billability: "Non-Billable", resourceType: "Shared Resource" }
                : editState
              )}
              className="rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90"
            >
              Save
            </button>
          </div>
        </div>
      </Modal>
    );
  }

  if (action === "remove") {
    return (
      <Modal title="Remove resource" onClose={onClose}>
        <p className="text-sm">Are you sure you want to remove <strong>{person.name}</strong> from this project's team? This action cannot be undone.</p>
        <div className="mt-5 flex justify-end gap-2">
          <button onClick={onClose} className="rounded-md border border-input bg-card px-3 py-1.5 text-xs hover:bg-accent">Cancel</button>
          <button onClick={onConfirmRemove} className="rounded-md bg-destructive px-3 py-1.5 text-xs font-medium text-destructive-foreground hover:bg-destructive/90">Remove</button>
        </div>
      </Modal>
    );
  }

  if (action === "praise") {
    return (
      <Modal title={`Give Praise — ${person.name}`} onClose={onClose}>
        <div className="space-y-3">
          <Field label="Badge">
            <select className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm" value={praise.tag} onChange={(e) => setPraise((s) => ({ ...s, tag: e.target.value }))}>
              {["Team Player", "Innovator", "Customer Hero", "Above & Beyond", "Mentor"].map((o) => <option key={o}>{o}</option>)}
            </select>
          </Field>
          <Field label="Appreciation Message">
            <textarea rows={3} className="w-full rounded-md border border-input bg-card px-3 py-2 text-sm" value={praise.message} onChange={(e) => setPraise((s) => ({ ...s, message: e.target.value }))} placeholder="Share what made this great…" />
          </Field>
          <div className="flex justify-end gap-2 border-t border-border pt-3">
            <button onClick={onClose} className="rounded-md border border-input bg-card px-3 py-1.5 text-xs hover:bg-accent">Cancel</button>
            <button onClick={() => { if (!praise.message.trim()) return toast.error("Add a message"); toast.success("Praise sent", { description: `${praise.tag} → ${person.name}` }); onClose(); }} className="rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90">Send Praise</button>
          </div>
        </div>
      </Modal>
    );
  }

  if (action === "feedback") {
    return (
      <Modal title={`Give Feedback — ${person.name}`} onClose={onClose}>
        <div className="space-y-3">
          <Field label="Strengths"><textarea rows={2} className="w-full rounded-md border border-input bg-card px-3 py-2 text-sm" value={feedback.strengths} onChange={(e) => setFeedback((s) => ({ ...s, strengths: e.target.value }))} /></Field>
          <Field label="Areas of Improvement"><textarea rows={2} className="w-full rounded-md border border-input bg-card px-3 py-2 text-sm" value={feedback.improvements} onChange={(e) => setFeedback((s) => ({ ...s, improvements: e.target.value }))} /></Field>
          <Field label="Comments"><textarea rows={2} className="w-full rounded-md border border-input bg-card px-3 py-2 text-sm" value={feedback.comments} onChange={(e) => setFeedback((s) => ({ ...s, comments: e.target.value }))} /></Field>
          <Field label={`Rating: ${feedback.rating}/5`}>
            <input type="range" min={1} max={5} value={feedback.rating} onChange={(e) => setFeedback((s) => ({ ...s, rating: Number(e.target.value) }))} className="w-full" />
          </Field>
          <div className="flex justify-end gap-2 border-t border-border pt-3">
            <button onClick={onClose} className="rounded-md border border-input bg-card px-3 py-1.5 text-xs hover:bg-accent">Cancel</button>
            <button onClick={() => { if (!feedback.strengths.trim() && !feedback.improvements.trim()) return toast.error("Add at least one section"); toast.success("Feedback submitted"); onClose(); }} className="rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90">Submit Feedback</button>
          </div>
        </div>
      </Modal>
    );
  }

  if (action === "request") {
    return (
      <Modal title={`Request Feedback for ${person.name}`} onClose={onClose}>
        <div className="space-y-3">
          <p className="text-xs text-muted-foreground">A request will be sent to the reporting manager. You'll be notified when feedback is submitted.</p>
          <Field label="Note (optional)"><textarea rows={3} className="w-full rounded-md border border-input bg-card px-3 py-2 text-sm" value={requestNote} onChange={(e) => setRequestNote(e.target.value)} placeholder="Add context for the manager…" /></Field>
          <div className="flex justify-end gap-2 border-t border-border pt-3">
            <button onClick={onClose} className="rounded-md border border-input bg-card px-3 py-1.5 text-xs hover:bg-accent">Cancel</button>
            <button onClick={() => { toast.success("Feedback request sent", { description: "Status: Pending" }); onClose(); }} className="rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90">Send Request</button>
          </div>
        </div>
      </Modal>
    );
  }

  return null;
}

function AddTeamMemberModal({
  project,
  teamType = "project",
  existingPersonIds,
  onClose,
  onAdd,
}: {
  project: Project;
  teamType?: TeamTabType;
  existingPersonIds: string[];
  onClose: () => void;
  onAdd: (row: ReturnType<typeof getProjectTeam>[number]) => void;
}) {
  const [selectedPersonId, setSelectedPersonId] = useState<string>("");
  const [duration, setDuration] = useState<string>("");
  const [billability, setBillability] = useState<Billability>("Billable");
  const [resourceType, setResourceType] = useState<ResourceType>("Dedicated");

  // Filter out already assigned people
  const availablePeople = people.filter((p) => !existingPersonIds.includes(p.id));

  const handleAdd = () => {
    if (!selectedPersonId) {
      toast.error("Please select a team member");
      return;
    }
    if (!duration || !duration.includes(" → ") || duration.startsWith(" → ") || duration.endsWith(" → ")) {
      toast.error("Please select both start and end dates for allocation duration");
      return;
    }

    const selectedPerson = getPerson(selectedPersonId);
    const newRow: ReturnType<typeof getProjectTeam>[number] = {
      person: selectedPerson,
      duration,
      billability,
      resourceType,
    };

    onAdd(newRow);
  };

  return (
    <Modal title="Add Team Member" onClose={onClose} wide={false}>
      <div className="space-y-4">
        <Field label="Resource" required>
          <select
            value={selectedPersonId}
            onChange={(e) => setSelectedPersonId(e.target.value)}
            className="w-full rounded-md border border-input bg-card px-3 py-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          >
            <option value="">Select a team member...</option>
            {availablePeople.map((p) => (
              <option key={p.id} value={p.id}>
                {p.name} — {p.role}
              </option>
            ))}
          </select>
        </Field>

        <Field label="Department" required>
          {selectedPersonId ? (
            <div className="px-3 py-2 text-sm text-muted-foreground">{getDept(getPerson(selectedPersonId))}</div>
          ) : (
            <div className="px-3 py-2 text-sm text-muted-foreground">—</div>
          )}
        </Field>

        <Field label="Sub Department" required>
          {selectedPersonId ? (
            <div className="px-3 py-2 text-sm text-muted-foreground">{getSubDept(getPerson(selectedPersonId))}</div>
          ) : (
            <div className="px-3 py-2 text-sm text-muted-foreground">—</div>
          )}
        </Field>

        <Field label="Allocation Duration" required>
          <DateRangePicker
            value={duration}
            onChange={setDuration}
          />
        </Field>

        <Field label="Billability" required>
          {teamType === "shadow" ? (
            <div className="flex items-center gap-2 px-3 py-2 rounded-md border border-border bg-muted/30 text-sm text-muted-foreground">
              <span className="inline-flex items-center rounded-full border border-border bg-muted px-2.5 py-0.5 text-[11px] font-medium text-muted-foreground">Non-Billable</span>
              <span className="text-xs text-muted-foreground/60 italic">(fixed for shadow team)</span>
            </div>
          ) : (
            <div className="inline-flex rounded-full border border-border bg-card p-0.5 text-sm">
              {(["Billable", "Non-Billable"] as Billability[]).map((b) => (
                <button
                  key={b}
                  onClick={() => setBillability(b)}
                  className={cn(
                    "rounded-full px-3 py-1.5 font-medium",
                    billability === b
                      ? b === "Billable"
                        ? "bg-success/15 text-success"
                        : "bg-muted text-muted-foreground"
                      : "text-muted-foreground hover:text-foreground"
                  )}
                >
                  {b}
                </button>
              ))}
            </div>
          )}
        </Field>

        <Field label="Resource Type" required>
          {teamType === "shadow" ? (
            <div className="flex items-center gap-2 px-3 py-2 rounded-md border border-border bg-muted/30 text-sm text-muted-foreground">
              <span className="inline-flex items-center rounded-full border border-info/30 bg-info/10 px-2.5 py-0.5 text-[11px] font-medium text-info">Shared Resource</span>
              <span className="text-xs text-muted-foreground/60 italic">(fixed for shadow team)</span>
            </div>
          ) : (
            <select
              value={resourceType}
              onChange={(e) => setResourceType(e.target.value as ResourceType)}
              className="w-full rounded-md border border-input bg-card px-3 py-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
            >
              {(["Dedicated", "Shared Resource"] as ResourceType[]).map((t) => (
                <option key={t} value={t}>{t}</option>
              ))}
            </select>
          )}
        </Field>

        <div className="flex justify-end gap-2 pt-4">
          <button
            onClick={onClose}
            className="rounded-md border border-input bg-card px-4 py-2 text-sm font-medium hover:bg-accent"
          >
            Cancel
          </button>
          <button
            onClick={handleAdd}
            className="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
          >
            Add Team Member
          </button>
        </div>
      </div>
    </Modal>
  );
}

function Info({ icon: Icon, label, value, sub }: {
  icon: React.ComponentType<{ className?: string }>; label: string; value: string; sub?: string;
}) {
  return (
    <div className="rounded-lg border border-border bg-card p-3">
      <div className="flex items-center gap-2 text-xs text-muted-foreground"><Icon className="h-3.5 w-3.5" /> {label}</div>
      <div className="mt-1 text-sm font-semibold">{value}</div>
      {sub && <div className="text-[11px] text-muted-foreground">{sub}</div>}
    </div>
  );
}

function PersonRow({ label, person, unassigned }: { label: string; person: Person; unassigned?: boolean }) {
  return (
    <div>
      <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">{label}</div>
      {unassigned ? (
        <div className="mt-1 text-xs italic text-muted-foreground">Not yet assigned</div>
      ) : (
        <div className="mt-1 flex items-center gap-2">
          <Avatar name={person.name} size={28} />
          <div>
            <div className="text-sm font-medium">{person.name}</div>
            <div className="text-[11px] text-muted-foreground">{person.email}</div>
          </div>
        </div>
      )}
    </div>
  );
}

// ---------- Health Tab ----------
function HealthTab({ project }: { project: Project }) {
  const store = useDhStore((s) => s);
  const { user, isDhanshree } = useRoleContext();
  const [healthTab, setHealthTab] = useState<string>(() => {
    if (typeof window !== "undefined") {
      const h = window.location.hash;
      if (h === "#health-alerts") return "Alerts";
      if (h === "#health-issues") return "Issues";
      // Escalations tab removed for Dhanshree — fall back to Issues
      if (h === "#health-escalations") return isDhanshree ? "Issues" : "Escalations";
      if (h === "#health-appreciations") return "Appreciation";
    }
    return "Issues";
  });

  const projectIssues = store.issues.filter((i) => i.projectId === project.id);
  const projectAlerts = store.alerts.filter((a) => a.projectId === project.id);
  const projectEscalations = useMemo(() => {
    const legacy = store.escalations.filter((e) => e.projectId === project.id);
    const newEscs = store.alerts
      .filter((a) => a.projectId === project.id && a.kind === "Escalation")
      .map((a) => ({
        id: a.id,
        projectId: a.projectId ?? "",
        title: a.title,
        severity: a.priority,
        ownerId: a.id,
        ownerName: a.owner || a.raisedByName,
        deadline: a.expectedResolutionDate || a.createdAt.slice(0, 10),
        status: a.status as any,
        comments: a.comments,
        createdAt: a.createdAt,
        serviceName: a.serviceName,
        escalationType: a.escalationType,
        escalatedTo: a.escalatedTo,
        attachments: a.attachments,
        description: a.description
      }));
    return [...newEscs, ...legacy];
  }, [store.escalations, store.alerts, project.id]);
  const projectAppreciations = store.appreciations.filter((a) => a.projectId === project.id);

  const canRaiseIssue = user.role === "Team Member" || user.role === "Team Lead" || user.role === "Dhanshree";

  // Check if user has access to Client Communication
  const canAccessClientComm = ["Dhanshree", "PMO", "Project Manager", "Engagement Manager", "Senior Project Manager", "Head of Delivery", "Business Operations"].includes(user.role);
  const client = clients.find((c) => c.id === project.clientId)!;

  // Dhanshree: Escalations tab restored for WBS Escalation workflow
  const tabsList = isDhanshree
    ? (["Issues", "Alerts", "Escalations", "Appreciation", "Client Engagement"] as const)
    : (["Issues", "Alerts", "Escalations", "Appreciation", "Client Communication"] as const);

  return (
    <div className="space-y-4">
      <div className="flex gap-1 overflow-x-auto rounded-lg border border-border bg-muted/30 p-1 text-sm">
        {tabsList.map((t) => (
          <button
            key={t}
            onClick={() => setHealthTab(t)}
            className={cn(
              "rounded-md px-3 py-1.5 font-medium transition-colors whitespace-nowrap",
              healthTab === t ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground"
            )}
          >
            {t}
          </button>
        ))}
      </div>

      {healthTab === "Issues" && <HealthIssuesPanel issues={projectIssues} project={project} canRaise={canRaiseIssue} />}
      {healthTab === "Alerts" && <HealthAlertsPanel alerts={projectAlerts} />}
      {healthTab === "Escalations" && <HealthEscalationsPanel escalations={projectEscalations} project={project} />}
      {healthTab === "Appreciation" && <HealthAppreciationPanel appreciations={projectAppreciations} project={project} />}

      {isDhanshree && healthTab === "Client Engagement" && (
        <DhClientEngagementTab project={project} clientName={client.name} />
      )}

      {!isDhanshree && healthTab === "Client Communication" && canAccessClientComm && (
        <ClientCommTab project={project} />
      )}

      {!isDhanshree && healthTab === "Client Communication" && !canAccessClientComm && (
        <div className="rounded-lg border border-border bg-muted/20 p-8 text-center">
          <p className="text-sm text-muted-foreground">You don't have access to Client Communication</p>
        </div>
      )}
    </div>
  );
}

function HealthIssuesPanel({ issues, project, canRaise }: { issues: DhIssue[]; project: Project; canRaise: boolean }) {
  const store = useDhStore((s) => s);
  const { user } = useRoleContext();
  const [showRaiseModal, setShowRaiseModal] = useState(false);
  const [formData, setFormData] = useState({
    title: "",
    description: "",
    category: "Technical Related Issues" as IssueCategory,
    priority: "Medium" as DhPriority,
  });

  const handleSubmit = () => {
    if (!formData.title.trim() || !formData.description.trim()) {
      toast.error("Fill all fields");
      return;
    }
    dhStore.raiseIssue({
      title: formData.title,
      description: formData.description,
      projectId: project.id,
      raisedById: user.id,
      raisedByName: user.name,
      raisedByRole: user.role,
      category: formData.category,
      priority: formData.priority,
    });
    toast.success("Issue raised", { description: "PMs and SPMs notified" });
    setShowRaiseModal(false);
    setFormData({ title: "", description: "", category: "Technical Related Issues", priority: "Medium" });
  };

  const hasNoIssues = issues.length === 0;

  return (
    <div className="space-y-3">
      {hasNoIssues && canRaise ? (
        <div className="rounded-lg border-2 border-dashed border-border bg-muted/20 py-12 text-center">
          <p className="text-sm text-muted-foreground mb-4">No issues raised yet</p>
          <button
            onClick={() => setShowRaiseModal(true)}
            className="inline-flex items-center gap-2 rounded-md bg-primary px-4 py-2.5 text-sm font-medium text-primary-foreground hover:bg-primary/90"
          >
            <Plus className="h-4 w-4" /> Raise Issues Alerts
          </button>
        </div>
      ) : (
        canRaise && (
          <div className="flex justify-end">
            <button
              onClick={() => setShowRaiseModal(true)}
              className="inline-flex items-center gap-2 rounded-md bg-primary px-3 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90"
            >
              <Plus className="h-3.5 w-3.5" /> Raise Issues Alerts
            </button>
          </div>
        )
      )}

      {showRaiseModal && (
        <Modal title="Raise Issue" onClose={() => setShowRaiseModal(false)}>
          <div className="space-y-3">
            <Field label="Issue Title">
              <input value={formData.title} onChange={(e) => setFormData((s) => ({ ...s, title: e.target.value }))} placeholder="Brief summary..." className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring" />
            </Field>
            <Field label="Description">
              <textarea value={formData.description} onChange={(e) => setFormData((s) => ({ ...s, description: e.target.value }))} placeholder="Detailed description..." rows={3} className="w-full rounded-md border border-input bg-card px-3 py-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring" />
            </Field>
            <Field label="Issue Type">
              <select value={formData.category} onChange={(e) => setFormData((s) => ({ ...s, category: e.target.value as IssueCategory }))} className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring">
                {(["Technical Related Issues", "Behavioral Related Issues", "Process Related Issues"] as IssueCategory[]).map((cat) => <option key={cat} value={cat}>{cat}</option>)}
              </select>
            </Field>
            <Field label="Priority">
              <select value={formData.priority} onChange={(e) => setFormData((s) => ({ ...s, priority: e.target.value as DhPriority }))} className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring">
                {(["Low", "Medium", "High", "Critical"] as DhPriority[]).map((pri) => <option key={pri} value={pri}>{pri}</option>)}
              </select>
            </Field>
            <div className="flex justify-end gap-2 border-t border-border pt-3">
              <button onClick={() => setShowRaiseModal(false)} className="rounded-md border border-input bg-card px-3 py-1.5 text-xs hover:bg-accent">Cancel</button>
              <button onClick={handleSubmit} className="rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90">Raise Issue</button>
            </div>
          </div>
        </Modal>
      )}

      {issues.length === 0 ? (
        <div className="rounded-lg border border-border bg-card p-8 text-center">
          <p className="text-sm text-muted-foreground">No issues raised yet</p>
        </div>
      ) : (
        <div className="space-y-2">
          {issues.map((issue: DhIssue) => {
            const priorityColors: Record<DhPriority, string> = { Low: "border-info/30 bg-info/10 text-info", Medium: "border-warning/30 bg-warning/15 text-warning-foreground", High: "border-destructive/30 bg-destructive/10 text-destructive", Critical: "border-destructive/30 bg-destructive/10 text-destructive" };
            return (
              <div key={issue.id} className="rounded-lg border border-border bg-card p-3 hover:bg-accent/30">
                <div className="flex items-start justify-between gap-3">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 flex-wrap">
                      <h4 className="text-sm font-medium">{issue.title}</h4>
                      <span className={cn("inline-flex rounded-full border px-2 py-0.5 text-[10px] font-medium", priorityColors[issue.priority])}>{issue.priority}</span>
                      <span className="inline-flex rounded-full border border-border bg-muted px-2 py-0.5 text-[10px] font-medium text-muted-foreground">{issue.status}</span>
                    </div>
                    <p className="mt-1 text-xs text-muted-foreground">{issue.description}</p>
                    <div className="mt-2 flex items-center gap-3 text-xs text-muted-foreground">
                      <span>{issue.raisedByName} · {issue.raisedByRole}</span>
                      <span>·</span>
                      <span>{new Date(issue.createdAt).toLocaleDateString()}</span>
                      {issue.comments.length > 0 && <><span>·</span><span className="flex items-center gap-1"><MessageSquare className="h-3 w-3" /> {issue.comments.length}</span></>}
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

function HealthAlertsPanel({ alerts }: { alerts: DhAlert[] }) {
  if (alerts.length === 0) {
    return <div className="rounded-lg border border-border bg-card p-8 text-center"><p className="text-sm text-muted-foreground">No active alerts</p></div>;
  }
  return (
    <div className="space-y-2">
      {alerts.map((alert) => (
        <div key={alert.id} className="rounded-lg border border-border bg-card p-3 hover:bg-accent/30">
          <div className="flex items-start justify-between">
            <div>
              <h4 className="text-sm font-medium">{alert.title}</h4>
              <p className="mt-1 text-xs text-muted-foreground">Raised by {alert.raisedByName} · {new Date(alert.createdAt).toLocaleDateString()}</p>
            </div>
            <span className="inline-flex rounded-full border border-info/30 bg-info/10 px-2 py-0.5 text-[10px] font-medium text-info">{alert.status}</span>
          </div>
        </div>
      ))}
    </div>
  );
}

function HealthEscalationsPanel({ escalations, project }: { escalations: any[]; project: Project }) {
  const store = useDhStore((s) => s);
  const { user } = useRoleContext();
  const [selectedEscId, setSelectedEscId] = useState<string | null>(null);

  // Modal State
  const [selectedStatus, setSelectedStatus] = useState<any>("Open");
  const [resDetails, setResDetails] = useState("");
  const [newChatMsg, setNewChatMsg] = useState("");

  const selectedEsc = useMemo(() => {
    return store.alerts.find(a => a.id === selectedEscId);
  }, [store.alerts, selectedEscId]);

  const openDetails = (id: string) => {
    const alert = store.alerts.find(a => a.id === id);
    if (alert) {
      setSelectedEscId(id);
      setSelectedStatus(alert.status);
      setResDetails(alert.resolutionDetails || "");
    }
  };

  const handleUpdateEscalation = () => {
    if (!selectedEscId) return;
    dhStore.updateGovernanceAlert(
      selectedEscId,
      {
        status: selectedStatus,
        resolutionDetails: resDetails
      },
      newChatMsg,
      user.id,
      user.name
    );
    toast.success("Escalation updated successfully!");
    setNewChatMsg("");
    setSelectedEscId(null);
  };

  const summary = useMemo(() => {
    const total = escalations.length;
    const open = escalations.filter(e => e.status === "Open").length;
    const inProgress = escalations.filter(e => e.status === "In Progress").length;
    const waitingForClient = escalations.filter(e => e.status === "Waiting for Client").length;
    const resolved = escalations.filter(e => e.status === "Resolved" || e.status === "Closed").length;
    const critical = escalations.filter(e => e.severity === "Critical").length;
    return { total, open, inProgress, waitingForClient, resolved, critical };
  }, [escalations]);

  const clientInfo = getClientInfo(project.clientId);

  return (
    <div className="space-y-4 text-xs">
      {/* Summary Grid */}
      <div className="grid grid-cols-2 md:grid-cols-6 gap-3">
        <div className="rounded-lg border border-border p-3 flex flex-col justify-between bg-card">
          <span className="text-[10px] font-bold uppercase tracking-wider text-muted-foreground">Total</span>
          <span className="text-lg font-extrabold text-blue-700 mt-1">{summary.total}</span>
        </div>
        <div className="rounded-lg border border-border p-3 flex flex-col justify-between bg-card">
          <span className="text-[10px] font-bold uppercase tracking-wider text-muted-foreground">Open</span>
          <span className="text-lg font-extrabold text-orange-700 mt-1">{summary.open}</span>
        </div>
        <div className="rounded-lg border border-border p-3 flex flex-col justify-between bg-card">
          <span className="text-[10px] font-bold uppercase tracking-wider text-muted-foreground">In Progress</span>
          <span className="text-lg font-extrabold text-blue-600 mt-1">{summary.inProgress}</span>
        </div>
        <div className="rounded-lg border border-border p-3 flex flex-col justify-between bg-card">
          <span className="text-[10px] font-bold uppercase tracking-wider text-muted-foreground">Waiting Client</span>
          <span className="text-lg font-extrabold text-purple-700 mt-1">{summary.waitingForClient}</span>
        </div>
        <div className="rounded-lg border border-border p-3 flex flex-col justify-between bg-card">
          <span className="text-[10px] font-bold uppercase tracking-wider text-muted-foreground">Resolved</span>
          <span className="text-lg font-extrabold text-emerald-700 mt-1">{summary.resolved}</span>
        </div>
        <div className="rounded-lg border border-border p-3 flex flex-col justify-between bg-card">
          <span className="text-[10px] font-bold uppercase tracking-wider text-muted-foreground">Critical</span>
          <span className="text-lg font-extrabold text-red-700 mt-1">{summary.critical}</span>
        </div>
      </div>

      {/* Escalations Table */}
      <div className="overflow-x-auto rounded-lg border border-border bg-card">
        <table className="w-full text-sm">
          <thead className="bg-muted/40 text-left uppercase tracking-wide text-muted-foreground">
            <tr>
              <th className="px-3 py-2 font-bold">Escalation ID</th>
              <th className="px-3 py-2 font-bold">Service</th>
              <th className="px-3 py-2 font-bold">Subject</th>
              <th className="px-3 py-2 font-bold">Type</th>
              <th className="px-3 py-2 font-bold">Priority</th>
              <th className="px-3 py-2 font-bold">Raised By</th>
              <th className="px-3 py-2 font-bold">Expected Date</th>
              <th className="px-3 py-2 font-bold">Status</th>
              <th className="px-3 py-2 font-bold text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {escalations.map((esc) => {
              const severityTone = esc.severity === "Critical" ? "bg-red-50 text-red-700 border-red-200" : esc.severity === "High" ? "bg-amber-50 text-amber-700 border-amber-200" : "bg-blue-50 text-blue-700 border-blue-200";
              const statusTone = esc.status === "Resolved" || esc.status === "Closed" ? "bg-emerald-50 text-emerald-700 border-emerald-200" : esc.status === "Waiting for Client" ? "bg-purple-50 text-purple-700 border-purple-200" : "bg-orange-50 text-orange-700 border-orange-200";
              return (
                <tr key={esc.id} className="hover:bg-accent/30">
                  <td className="px-3 py-2.5 font-mono font-bold text-gray-800">{esc.alertId || "ALT-GEN"}</td>
                  <td className="px-3 py-2.5 font-semibold text-gray-700">{esc.serviceName || "Core Project"}</td>
                  <td className="px-3 py-2.5 text-gray-800 font-medium">{esc.title}</td>
                  <td className="px-3 py-2.5">
                    <span className="inline-flex rounded-full border border-border bg-muted px-2 py-0.5 text-[9px] font-bold text-gray-700">
                      {esc.escalationType || "General"}
                    </span>
                  </td>
                  <td className="px-3 py-2.5">
                    <span className={cn("inline-flex rounded-full border px-2 py-0.5 text-[9px] font-bold", severityTone)}>{esc.severity}</span>
                  </td>
                  <td className="px-3 py-2.5 font-medium">{esc.ownerName}</td>
                  <td className="px-3 py-2.5 text-muted-foreground">{esc.deadline || "—"}</td>
                  <td className="px-3 py-2.5">
                    <span className={cn("inline-flex rounded-full border px-2 py-0.5 text-[9px] font-bold", statusTone)}>{esc.status}</span>
                  </td>
                  <td className="px-3 py-2.5 text-right">
                    <button
                      onClick={() => openDetails(esc.id)}
                      className="rounded-md border border-input bg-card px-2.5 py-1 text-[10px] hover:bg-accent font-bold text-primary"
                    >
                      Review details
                    </button>
                  </td>
                </tr>
              );
            })}
            {escalations.length === 0 && (
              <tr>
                <td colSpan={9} className="px-3 py-8 text-center text-sm text-muted-foreground">No escalations active for this project</td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Escalation Review Details Modal */}
      {selectedEsc && (
        <Modal title={`Escalation Review Details — ${selectedEsc.alertId || "ALT-GEN"}`} onClose={() => setSelectedEscId(null)} wide>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">
            {/* Left side details */}
            <div className="md:col-span-2 space-y-4">
              <div className="bg-muted/30 border border-border rounded-lg p-3 grid grid-cols-2 gap-3">
                <div>
                  <span className="text-[9px] uppercase font-bold text-muted-foreground block">Project</span>
                  <span className="font-semibold text-gray-800">{project.name}</span>
                </div>
                <div>
                  <span className="text-[9px] uppercase font-bold text-muted-foreground block">Client</span>
                  <span className="font-semibold text-gray-800">{clientInfo?.name || "—"}</span>
                </div>
                <div>
                  <span className="text-[9px] uppercase font-bold text-muted-foreground block">Service Name</span>
                  <span className="font-semibold text-primary">{selectedEsc.serviceName || "—"}</span>
                </div>
                <div>
                  <span className="text-[9px] uppercase font-bold text-muted-foreground block">Escalation Type</span>
                  <span className="font-semibold text-gray-800">{selectedEsc.escalationType || "—"}</span>
                </div>
              </div>

              <div className="rounded-lg border border-border p-3 bg-card space-y-1.5">
                <span className="font-semibold text-[9px] text-muted-foreground uppercase block border-b border-border pb-1">Description</span>
                <p className="text-xs text-gray-700 leading-relaxed font-medium">{selectedEsc.description || "No full description provided."}</p>
              </div>

              {/* Resolution Progress */}
              <div className="rounded-lg border border-border p-3 bg-card space-y-2">
                <span className="font-semibold text-[9px] text-muted-foreground uppercase block border-b border-border pb-1">Resolution & Outcome Notes</span>
                <textarea
                  value={resDetails}
                  onChange={(e) => setResDetails(e.target.value)}
                  placeholder="Document resolution steps, technical outcomes, or action plan here..."
                  rows={3}
                  className="w-full rounded-md border border-border bg-card p-2 text-xs outline-none focus-visible:ring-1 focus-visible:ring-ring"
                />
              </div>

              {/* History Timeline Logs */}
              {selectedEsc.history && selectedEsc.history.length > 0 && (
                <div className="rounded-lg border border-border p-3 bg-card space-y-2">
                  <span className="font-semibold text-[9px] text-muted-foreground uppercase block border-b border-border pb-1">Status Transitions Timeline</span>
                  <div className="space-y-1.5 pl-1 max-h-32 overflow-y-auto">
                    {selectedEsc.history.map((h, idx) => (
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
                <div className="bg-muted/10 rounded-lg border border-border p-3 space-y-1.5">
                  <div className="flex justify-between">
                    <span className="text-[9px] uppercase font-bold text-muted-foreground">Raised By</span>
                    <span className="font-semibold text-gray-800">{selectedEsc.raisedByName}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-[9px] uppercase font-bold text-muted-foreground">Escalated To</span>
                    <span className="font-semibold text-primary truncate max-w-[120px]" title={selectedEsc.escalatedTo?.join(", ")}>
                      {selectedEsc.escalatedTo?.join(", ") || "—"}
                    </span>
                  </div>
                </div>

                {/* Attachments */}
                <div className="rounded-lg border border-border p-3 bg-card space-y-1.5">
                  <span className="font-semibold text-[9px] text-muted-foreground uppercase block">Attachments</span>
                  {selectedEsc.attachments && selectedEsc.attachments.length > 0 ? (
                    <div className="space-y-1">
                      {selectedEsc.attachments.map((file, idx) => (
                        <div key={idx} className="flex items-center gap-1.5 text-[10px] text-primary hover:underline cursor-pointer">
                          <Paperclip className="h-3 w-3 text-muted-foreground" />
                          <span>{file}</span>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <span className="text-muted-foreground italic text-[9px]">No attachments.</span>
                  )}
                </div>

                {/* Status Switcher */}
                <div className="rounded-lg border border-border p-3 bg-card space-y-2">
                  <span className="font-semibold text-[9px] text-muted-foreground uppercase block">Set Status</span>
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
                    {(["Open", "Acknowledged", "In Progress", "Waiting for Client", "Resolved", "Closed"] as const).map((s) => (
                      <option key={s} value={s}>{s}</option>
                    ))}
                  </select>
                </div>

                {/* Discussion Area Comment box */}
                <div className="rounded-lg border border-border p-3 bg-card space-y-2">
                  <span className="font-semibold text-[9px] text-muted-foreground uppercase block border-b border-border pb-1">Discussion Thread Chat</span>
                  <div className="space-y-2 max-h-36 overflow-y-auto pl-1 pr-0.5 text-[9px] leading-relaxed">
                    {selectedEsc.comments.map((cm) => (
                      <div key={cm.id} className="bg-muted/30 border border-border p-2 rounded-md space-y-0.5">
                        <div className="flex justify-between font-semibold text-gray-800 text-[8px]">
                          <span>{cm.authorName}</span>
                          <span className="text-muted-foreground">{new Date(cm.at).toLocaleDateString()}</span>
                        </div>
                        <p className="text-gray-700">{cm.text}</p>
                      </div>
                    ))}
                    {selectedEsc.comments.length === 0 && (
                      <span className="text-muted-foreground italic text-[9px]">No chat messages yet.</span>
                    )}
                  </div>
                  <textarea
                    value={newChatMsg}
                    onChange={(e) => setNewChatMsg(e.target.value)}
                    placeholder="Type a message or reply to conversation thread..."
                    rows={2}
                    className="w-full rounded-md border border-border p-1.5 text-xs bg-card outline-none focus-visible:ring-1 focus-visible:ring-ring mt-2"
                  />
                </div>
              </div>

              <div className="flex justify-end gap-2 border-t border-border pt-3">
                <button onClick={() => setSelectedEscId(null)} className="rounded-md border border-input bg-card px-3.5 py-1.5 text-xs font-semibold hover:bg-accent">
                  Cancel
                </button>
                <button
                  onClick={handleUpdateEscalation}
                  className="rounded-md bg-primary px-3.5 py-1.5 text-xs font-semibold text-primary-foreground hover:bg-primary/90"
                >
                  Save Changes
                </button>
              </div>
            </div>
          </div>
        </Modal>
      )}
    </div>
  );
}

function HealthAppreciationPanel({ appreciations, project }: { appreciations: DhAppreciation[]; project: Project }) {
  const store = useDhStore((s) => s);
  const { user } = useRoleContext();
  const [showAppreciateModal, setShowAppreciateModal] = useState(false);
  const [formData, setFormData] = useState({ toUserId: project.teamIds[0] || "u5", badge: "Star Performer" as const, note: "" });
  const canAppreciate = user.role === "Project Manager" || user.role === "Senior Project Manager" || user.role === "Team Lead" || user.role === "Engagement Manager" || user.role === "Dhanshree";

  const teamPool = useMemo(() => {
    const ids = [project.pmId, project.tlId, ...project.teamIds];
    return Array.from(new Set(ids)).map(getPerson);
  }, [project]);

  const handleSubmit = () => {
    if (!formData.note.trim()) { toast.error("Add message"); return; }
    dhStore.addAppreciation({
      projectId: project.id,
      toUserId: formData.toUserId,
      toName: getPerson(formData.toUserId).name,
      fromName: user.name,
      badge: formData.badge,
      note: formData.note,
    });
    toast.success("Appreciation sent!");
    setShowAppreciateModal(false);
  };

  return (
    <div className="space-y-3">
      {canAppreciate && (
        <button onClick={() => setShowAppreciateModal(true)} className="inline-flex items-center gap-2 rounded-md bg-primary px-3 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90">
          <Star className="h-3.5 w-3.5" /> Appreciate
        </button>
      )}

      {showAppreciateModal && (
        <Modal title="Give Appreciation" onClose={() => setShowAppreciateModal(false)}>
          <div className="space-y-3">
            <Field label="Resource">
              <select value={formData.toUserId} onChange={(e) => setFormData((s) => ({ ...s, toUserId: e.target.value }))} className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring">
                {teamPool.map((p) => <option key={p.id} value={p.id}>{p.name}</option>)}
              </select>
            </Field>
            <Field label="Badge">
              <select value={formData.badge} onChange={(e) => setFormData((s) => ({ ...s, badge: e.target.value as any }))} className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring">
                {(["Star Performer", "Team Player", "Innovator", "Client Champion"] as const).map((b) => <option key={b} value={b}>{b}</option>)}
              </select>
            </Field>
            <Field label="Message">
              <textarea value={formData.note} onChange={(e) => setFormData((s) => ({ ...s, note: e.target.value }))} placeholder="Why appreciate..." rows={3} className="w-full rounded-md border border-input bg-card px-3 py-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring" />
            </Field>
            <div className="flex justify-end gap-2 border-t border-border pt-3">
              <button onClick={() => setShowAppreciateModal(false)} className="rounded-md border border-input bg-card px-3 py-1.5 text-xs hover:bg-accent">Cancel</button>
              <button onClick={handleSubmit} className="rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90">Send</button>
            </div>
          </div>
        </Modal>
      )}

      {appreciations.length === 0 ? (
        <div className="rounded-lg border border-border bg-card p-8 text-center"><p className="text-sm text-muted-foreground">No appreciations yet</p></div>
      ) : (
        <div className="space-y-2">
          {appreciations.map((app) => (
            <div key={app.id} className="rounded-lg border border-border bg-card p-3">
              <div className="flex items-start gap-3">
                <Award className="h-4 w-4 flex-shrink-0 text-yellow-500 mt-0.5" />
                <div className="flex-1">
                  <p className="text-sm font-medium">{app.toName} <span className="text-muted-foreground font-normal">received</span> {app.badge}</p>
                  <p className="mt-1 text-xs text-muted-foreground">{app.note}</p>
                  <p className="mt-1 text-[11px] text-muted-foreground">From {app.fromName} · {new Date(app.at).toLocaleDateString()}</p>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

// ---------- Dhanshree Client Engagement Tab ----------
function DhClientEngagementTab({ project, clientName }: { project: Project; clientName: string }) {
  const store = useDhStore((s) => s);
  const { user } = useRoleContext();
  const [commTab, setCommTab] = useState<"Interview Scheduling" | "Additional Client Requirement">("Interview Scheduling");

  const projectInterviews = store.interviews.filter((i) => i.projectId === project.id);
  const projectRequirements = store.requirements.filter((r) => r.projectId === project.id);
  const isEM = user.role === "Engagement Manager" || user.role === "Dhanshree";

  return (
    <div className="space-y-4">
      <div className="flex gap-1 overflow-x-auto rounded-lg border border-border bg-muted/30 p-1 text-sm shadow-sm">
        {(["Interview Scheduling", "Additional Client Requirement"] as const).map((t) => (
          <button
            key={t}
            onClick={() => setCommTab(t)}
            className={cn(
              "rounded-md px-3 py-1.5 font-medium transition-colors whitespace-nowrap",
              commTab === t ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground"
            )}
          >
            {t}
          </button>
        ))}
      </div>

      {commTab === "Interview Scheduling" && (
        <InterviewSchedulingPanel interviews={projectInterviews} project={project} isEM={isEM} />
      )}
      {commTab === "Additional Client Requirement" && (
        <AdditionalRequirementsPanel requirements={projectRequirements} project={project} clientName={clientName} />
      )}
    </div>
  );
}

function AdditionalRequirementsPanel({ requirements, project, clientName }: { requirements: DhAdditionalRequirement[]; project: Project; clientName: string }) {
  const [showModal, setShowModal] = useState(false);
  const [selectedReq, setSelectedReq] = useState<DhAdditionalRequirement | null>(null);

  const [client, setClient] = useState(clientName);
  const [projName, setProjName] = useState(project.name);
  const [title, setTitle] = useState("");
  const [customTitle, setCustomTitle] = useState("");
  const [description, setDescription] = useState("");
  const [priority, setPriority] = useState<DhPriority>("Medium");
  const [requestedBy, setRequestedBy] = useState("");
  const [requestedDate, setRequestedDate] = useState(new Date().toISOString().split("T")[0]);
  const [attachmentName, setAttachmentName] = useState("");
  const [scopeCancellation, setScopeCancellation] = useState("");
  const [reqTab, setReqTab] = useState<"Add Service" | "Scope Cancellation">("Add Service");

  // Services come from wbsDetails (projects created via the WBS form) or, for
  // seeded demo projects without wbsDetails, the legacy WBS-tab service list.
  const projectServices = useMemo(() => {
    const wbsServices = (project.wbsDetails?.services ?? []).map((s) => ({ id: String(s.id), name: s.serviceName }));
    if (wbsServices.length > 0) return wbsServices;
    return LEGACY_WBS_SERVICES.map((s) => ({ id: String(s.id), name: s.name }));
  }, [project]);

  const handleLog = () => {
    const isCancellation = reqTab === "Scope Cancellation";
    if (isCancellation && !scopeCancellation) {
      toast.error("Please select the service to cancel");
      return;
    }
    const finalTitle = isCancellation
      ? `Scope Cancellation: ${scopeCancellation}`
      : (title === "Other" ? customTitle.trim() : title);
    if (!finalTitle || !description.trim() || !requestedBy.trim()) {
      toast.error("Please fill in all required fields");
      return;
    }
    dhStore.addRequirement({
      projectId: project.id,
      clientName: client,
      projectName: projName,
      title: finalTitle,
      description,
      priority,
      requestedBy,
      requestedDate,
      attachmentName: attachmentName || undefined,
      scopeCancellationService: isCancellation ? scopeCancellation : undefined,
      status: "Open",
      comments: []
    });
    toast.success(isCancellation ? "Scope cancellation request logged!" : "Requirement logged persistently!");
    setShowModal(false);
    // Reset
    setReqTab("Add Service");
    setTitle("");
    setCustomTitle("");
    setDescription("");
    setRequestedBy("");
    setAttachmentName("");
    setScopeCancellation("");
  };

  const priorityColors = {
    Low: "bg-muted text-muted-foreground border-border",
    Medium: "bg-info/10 text-info border-info/30",
    High: "bg-warning/15 text-warning-foreground border-warning/40",
    Critical: "bg-destructive/10 text-destructive border-destructive/30",
  };

  const statusColors = {
    "Open": "bg-warning/10 text-warning-foreground border-warning/30",
    "Under Review": "bg-info/10 text-info-foreground border-info/30",
    "Approved": "bg-success/10 text-success border-success/30",
    "Rejected": "bg-destructive/10 text-destructive border-destructive/30",
    "Implemented": "bg-success/10 text-success border-success/30",
  };

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between">
        <h4 className="text-xs font-semibold text-gray-500 uppercase tracking-wider">Additional Requirements ({requirements.length})</h4>
        <button
          onClick={() => setShowModal(true)}
          className="inline-flex items-center gap-1.5 rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90"
        >
          <Plus className="h-3.5 w-3.5" /> Log Requirement
        </button>
      </div>

      <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
        {requirements.map((req) => (
          <div key={req.id} className="rounded-lg border border-border bg-card p-4 hover:shadow-md transition-shadow relative">
            <div className="flex items-start justify-between gap-2 mb-2">
              <span className="text-[10px] font-mono text-muted-foreground">{req.requirementId}</span>
              <div className="flex gap-1.5">
                <span className={cn("inline-flex rounded-full border px-2 py-0.5 text-[9px] font-medium capitalize", priorityColors[req.priority])}>
                  {req.priority}
                </span>
                <span className={cn("inline-flex rounded-full border px-2 py-0.5 text-[9px] font-medium capitalize", statusColors[req.status])}>
                  {req.status}
                </span>
              </div>
            </div>
            <h5 className="font-semibold text-sm line-clamp-1">{req.title}</h5>
            <p className="text-xs text-muted-foreground mt-1 line-clamp-2">{req.description}</p>

            <div className="mt-3 flex items-center justify-between border-t border-border pt-3 text-[11px] text-muted-foreground">
              <span>By: {req.requestedBy}</span>
              <span>{new Date(req.requestedDate).toLocaleDateString()}</span>
            </div>

            <button
              onClick={() => setSelectedReq(req)}
              className="mt-3 flex w-full items-center justify-center rounded-md border border-input bg-card px-2.5 py-1 text-xs hover:bg-accent"
            >
              View & Comment ({req.comments.length})
            </button>
          </div>
        ))}
        {requirements.length === 0 && (
          <div className="col-span-full rounded-lg border-2 border-dashed border-border py-12 text-center text-xs text-muted-foreground">
            No additional client requirements logged for this project yet.
          </div>
        )}
      </div>

      {/* Log Requirement Modal */}
      {showModal && (
        <Modal title="Log Additional Client Requirement" onClose={() => setShowModal(false)}>
          <div className="space-y-3">
            <div className="grid grid-cols-2 gap-3">
              <Field label="Client Name"><input value={client} onChange={(e) => setClient(e.target.value)} readOnly className="h-9 w-full rounded-md border border-input bg-muted/40 px-3 text-sm outline-none" /></Field>
              <Field label="Project Name"><input value={projName} onChange={(e) => setProjName(e.target.value)} readOnly className="h-9 w-full rounded-md border border-input bg-muted/40 px-3 text-sm outline-none" /></Field>
            </div>

            <div className="flex gap-1 rounded-lg border border-border bg-muted/30 p-1 text-xs">
              {(["Add Service", "Scope Cancellation"] as const).map((t) => (
                <button
                  key={t}
                  type="button"
                  onClick={() => setReqTab(t)}
                  className={cn(
                    "flex-1 rounded-md px-3 py-1.5 font-medium transition-colors",
                    reqTab === t ? "bg-primary text-primary-foreground shadow-sm" : "text-muted-foreground hover:text-foreground"
                  )}
                >
                  {t}
                </button>
              ))}
            </div>

            {reqTab === "Add Service" && (
              <>
                <Field label="Requirement Title" required>
                  <select value={title} onChange={(e) => { setTitle(e.target.value); if (e.target.value !== "Other") setCustomTitle(""); }} className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring">
                    <option value="" disabled>Select requirement type...</option>
                    <option value="Resource Requirement">Resource Requirement</option>
                    <option value="Scope Requirement">Scope Requirement</option>
                    <option value="Other">Other</option>
                  </select>
                </Field>
                {title === "Other" && (
                  <Field label="Specify Requirement Title" required><input value={customTitle} onChange={(e) => setCustomTitle(e.target.value)} placeholder="Enter requirement title..." className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring" /></Field>
                )}
              </>
            )}

            {reqTab === "Scope Cancellation" && (
              <Field label="Service to Cancel" required>
                <select value={scopeCancellation} onChange={(e) => setScopeCancellation(e.target.value)} className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring">
                  <option value="" disabled>Select service...</option>
                  {projectServices.map((svc) => (
                    <option key={svc.id} value={svc.name}>{svc.name}</option>
                  ))}
                </select>
              </Field>
            )}

            <Field label={reqTab === "Scope Cancellation" ? "Reason for Cancellation" : "Description"} required><textarea value={description} onChange={(e) => setDescription(e.target.value)} placeholder={reqTab === "Scope Cancellation" ? "Reason for cancelling this service..." : "Detailed requirement..."} rows={3} className="w-full rounded-md border border-input bg-card px-3 py-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring" /></Field>

            <div className="grid grid-cols-2 gap-3">
              <Field label="Priority">
                <select value={priority} onChange={(e) => setPriority(e.target.value as DhPriority)} className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm">
                  {["Low", "Medium", "High", "Critical"].map((p) => <option key={p} value={p}>{p}</option>)}
                </select>
              </Field>
              <Field label="Requested Date">
                <input type="date" value={requestedDate} onChange={(e) => setRequestedDate(e.target.value)} className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm" />
              </Field>
            </div>

            <Field label="Requested By"><input value={requestedBy} onChange={(e) => setRequestedBy(e.target.value)} placeholder="Client contact..." className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring" /></Field>

            <Field label="Attachment File Name (optional)">
              <div className="flex gap-2">
                <input value={attachmentName} onChange={(e) => setAttachmentName(e.target.value)} placeholder="e.g. SOW_Addendum.pdf" className="h-9 flex-1 rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring" />
                <input type="file" id="file-upload" className="hidden" onChange={(e) => {
                  const file = e.target.files?.[0];
                  if (file) setAttachmentName(file.name);
                }} />
                <label htmlFor="file-upload" className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-3 py-2 text-xs hover:bg-accent cursor-pointer">
                  <Paperclip className="h-3.5 w-3.5" /> Browse
                </label>
              </div>
            </Field>

            <div className="flex justify-end gap-2 border-t border-border pt-3">
              <button onClick={() => setShowModal(false)} className="rounded-md border border-input bg-card px-3 py-1.5 text-xs hover:bg-accent">Cancel</button>
              <button onClick={handleLog} className="rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90">{reqTab === "Scope Cancellation" ? "Log Scope Cancellation" : "Log Requirement"}</button>
            </div>
          </div>
        </Modal>
      )}

      {/* Details & Comments Modal */}
      {selectedReq && (
        <RequirementDetailsModal
          requirement={selectedReq}
          onClose={() => setSelectedReq(null)}
        />
      )}
    </div>
  );
}

function RequirementDetailsModal({ requirement, onClose }: { requirement: DhAdditionalRequirement; onClose: () => void }) {
  const [commentText, setCommentText] = useState("");
  const store = useDhStore(s => s);

  const req = store.requirements.find(r => r.id === requirement.id) || requirement;

  const handleComment = () => {
    if (!commentText.trim()) return;
    dhStore.addRequirementComment(req.id, {
      authorId: "u14",
      authorName: "Dhanshree",
      text: commentText.trim()
    });
    setCommentText("");
    toast.success("Comment added persistently!");
  };

  const statusColors = {
    "Open": "bg-warning/10 text-warning-foreground border-warning/30",
    "Under Review": "bg-info/10 text-info-foreground border-info/30",
    "Approved": "bg-success/10 text-success border-success/30",
    "Rejected": "bg-destructive/10 text-destructive border-destructive/30",
    "Implemented": "bg-success/10 text-success border-success/30",
  };

  return (
    <Modal title={`Requirement Details — ${req.requirementId}`} onClose={onClose} wide>
      <div className="grid gap-4 md:grid-cols-3 text-sm">
        {/* Info side column */}
        <div className="md:col-span-1 space-y-3">
          <div className="rounded-lg border border-border bg-muted/20 p-3">
            <h5 className="font-semibold text-xs text-muted-foreground uppercase tracking-wide mb-2">Requirement Status</h5>
            <div className="flex items-center gap-2">
              <span className={cn("inline-flex rounded-full border px-2 py-0.5 text-xs font-semibold", statusColors[req.status])}>
                {req.status}
              </span>
              <select
                value={req.status}
                onChange={(e) => {
                  const s = e.target.value as RequirementStatus;
                  dhStore.updateRequirementStatus(req.id, s, "dhanshree", "Dhanshree");
                  toast.success(`Status updated to ${s}`);
                }}
                className={cn(
                  "h-8 rounded-md border px-2.5 text-xs font-bold shadow-xs transition-colors cursor-pointer outline-none focus-visible:ring-1 focus-visible:ring-ring",
                  req.status === "Approved" || req.status === "Implemented" ? "bg-emerald-50 border-emerald-200 text-emerald-700 hover:bg-emerald-100" :
                    req.status === "Open" ? "bg-amber-50 border-amber-200 text-amber-700 hover:bg-amber-100" :
                      req.status === "Under Review" ? "bg-blue-50 border-blue-200 text-blue-700 hover:bg-blue-100" :
                        req.status === "Rejected" ? "bg-red-50 border-red-200 text-red-700 hover:bg-red-100" :
                          "bg-gray-50 border-gray-200 text-gray-600 hover:bg-gray-100"
                )}
              >
                {["Open", "Under Review", "Approved", "Rejected", "Implemented"].map((s) => (
                  <option key={s} value={s}>{s}</option>
                ))}
              </select>
            </div>
          </div>

          <Info icon={Calendar} label="Client" value={req.clientName} />
          <Info icon={Briefcase} label="Project" value={req.projectName} />
          <Info icon={Users} label="Requested By" value={req.requestedBy} />
          <Info icon={Calendar} label="Date" value={new Date(req.requestedDate).toLocaleDateString()} />
          <Info icon={AlertTriangle} label="Priority" value={req.priority} />

          {req.attachmentName && (
            <div className="rounded-lg border border-border bg-card p-3">
              <div className="text-[11px] text-muted-foreground uppercase tracking-wide font-medium">Attachment</div>
              <div className="flex items-center gap-1.5 mt-1.5 text-xs text-primary font-medium">
                <Paperclip className="h-3.5 w-3.5 shrink-0" />
                <span className="truncate hover:underline cursor-pointer">{req.attachmentName}</span>
              </div>
            </div>
          )}
        </div>

        {/* Thread and Comments */}
        <div className="md:col-span-2 flex flex-col h-[65vh]">
          <div className="border-b border-border pb-3 mb-3">
            <h4 className="font-semibold text-base text-gray-800">{req.title}</h4>
            <p className="text-sm text-gray-600 mt-1.5 leading-relaxed">{req.description}</p>
          </div>

          <div className="flex-1 overflow-y-auto space-y-3 pr-1">
            <h5 className="font-semibold text-xs text-muted-foreground uppercase tracking-wide flex items-center gap-1">
              <MessageSquare className="h-3.5 w-3.5" /> Discussion Thread ({req.comments.length})
            </h5>

            {req.comments.map((c: DhComment) => (
              <div key={c.id} className="flex gap-3 text-xs">
                <Avatar name={c.authorName} size={28} />
                <div className="flex-1 rounded-lg border border-border bg-accent/30 p-3">
                  <div className="flex items-center justify-between mb-1">
                    <span className="font-semibold text-gray-800">{c.authorName}</span>
                    <span className="text-[10px] text-muted-foreground">{new Date(c.at).toLocaleString()}</span>
                  </div>
                  <p className="text-gray-700 leading-normal">{c.text}</p>
                </div>
              </div>
            ))}
            {req.comments.length === 0 && (
              <div className="rounded-lg border border-dashed border-border p-6 text-center text-xs text-muted-foreground">
                No comments in discussion yet. Add a remark or feedback below.
              </div>
            )}

            {/* History log in the thread */}
            <div className="border-t border-border pt-3 mt-4">
              <h5 className="font-semibold text-xs text-muted-foreground uppercase tracking-wide mb-2">Requirement History</h5>
              <ol className="relative ml-2 space-y-2 border-l border-border pl-4 text-xs text-muted-foreground">
                {req.history.map((h: { status: RequirementStatus; at: string; updatedBy: string; updatedByName: string }, idx: number) => (
                  <li key={idx} className="relative">
                    <span className="absolute -left-[21px] mt-1 h-2 w-2 rounded-full bg-primary" />
                    <span>
                      Status set to <strong>{h.status}</strong> by <strong>{h.updatedByName}</strong>
                    </span>
                    <span className="ml-2 text-[10px] text-muted-foreground">
                      {new Date(h.at).toLocaleDateString()} {new Date(h.at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                    </span>
                  </li>
                ))}
              </ol>
            </div>
          </div>

          <div className="border-t border-border pt-3 flex gap-2">
            <textarea
              value={commentText}
              onChange={(e) => setCommentText(e.target.value)}
              placeholder="Add a remark, feedback, or update to the thread..."
              rows={2}
              className="flex-1 resize-none rounded-md border border-input bg-card p-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
            />
            <button
              onClick={handleComment}
              disabled={!commentText.trim()}
              className="inline-flex items-center gap-1.5 self-end rounded-md bg-primary px-3 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
            >
              <Send className="h-3.5 w-3.5" /> Post
            </button>
          </div>
        </div>
      </div>
    </Modal>
  );
}

// ---------- Client Communication Tab ----------
function ClientCommTab({ project }: { project: Project }) {
  const store = useDhStore((s) => s);
  const { user } = useRoleContext();
  const [commTab, setCommTab] = useState<"Interview Scheduling" | "Prerequisite Validation">("Interview Scheduling");

  const projectInterviews = store.interviews.filter((i) => i.projectId === project.id);
  const projectPrereq = store.prereqs[project.id];
  const isEM = user.role === "Engagement Manager" || user.role === "Dhanshree";

  return (
    <div className="space-y-4">
      <div className="flex gap-1 overflow-x-auto rounded-lg border border-border bg-muted/30 p-1 text-sm">
        {(["Interview Scheduling", "Prerequisite Validation"] as const).map((t) => (
          <button key={t} onClick={() => setCommTab(t)} className={cn("rounded-md px-3 py-1.5 font-medium transition-colors whitespace-nowrap", commTab === t ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground")}>{t}</button>
        ))}
      </div>

      {commTab === "Interview Scheduling" && <InterviewSchedulingPanel interviews={projectInterviews} project={project} isEM={isEM} />}
      {commTab === "Prerequisite Validation" && projectPrereq && <PrerequisiteValidationPanel prereq={projectPrereq} project={project} isEM={isEM} />}
    </div>
  );
}

function InterviewSchedulingPanel({ interviews, project, isEM }: { interviews: DhInterview[]; project: Project; isEM: boolean }) {
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({ resourceId: project.teamIds[0] || "u5", client: "Client", date: new Date().toISOString().slice(0, 10), round: "Technical Round 1", interviewer: "Architect" });

  const teamPool = useMemo(() => project.teamIds.map(getPerson), [project]);

  const handleSchedule = () => {
    dhStore.addInterview({
      projectId: project.id,
      resourceId: formData.resourceId,
      resourceName: getPerson(formData.resourceId).name,
      employeeId: "ENG-001",
      clientName: formData.client,
      projectName: project.name,
      interviewDate: formData.date,
      interviewTime: "10:00 AM",
      interviewRound: formData.round,
      interviewer: formData.interviewer,
      notes: "",
      status: "Pending",
    });
    toast.success("Interview scheduled persistently");
    setShowModal(false);
  };

  const updateStatus = (interviewId: string, newStatus: InterviewStatus) => {
    dhStore.updateInterviewStatus(interviewId, newStatus, "engagement_manager");
    toast.success(`Interview status updated to ${newStatus}`);
  };

  return (
    <div className="space-y-3">
      {isEM && (
        <button onClick={() => setShowModal(true)} className="inline-flex items-center gap-2 rounded-md bg-primary px-3 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90">
          <Plus className="h-3.5 w-3.5" /> Schedule Interview
        </button>
      )}

      {showModal && (
        <Modal title="Schedule Interview" onClose={() => setShowModal(false)}>
          <div className="space-y-3">
            <Field label="Resource">
              <select value={formData.resourceId} onChange={(e) => setFormData((s) => ({ ...s, resourceId: e.target.value }))} className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring">
                {teamPool.map((p) => <option key={p.id} value={p.id}>{p.name}</option>)}
              </select>
            </Field>
            <Field label="Client"><input value={formData.client} onChange={(e) => setFormData((s) => ({ ...s, client: e.target.value }))} className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring" /></Field>
            <Field label="Date"><input type="date" value={formData.date} onChange={(e) => setFormData((s) => ({ ...s, date: e.target.value }))} className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring" /></Field>
            <Field label="Round"><input value={formData.round} onChange={(e) => setFormData((s) => ({ ...s, round: e.target.value }))} className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring" /></Field>
            <Field label="Interviewer"><input value={formData.interviewer} onChange={(e) => setFormData((s) => ({ ...s, interviewer: e.target.value }))} className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring" /></Field>
            <div className="flex justify-end gap-2 border-t border-border pt-3">
              <button onClick={() => setShowModal(false)} className="rounded-md border border-input bg-card px-3 py-1.5 text-xs hover:bg-accent">Cancel</button>
              <button onClick={handleSchedule} className="rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90">Schedule</button>
            </div>
          </div>
        </Modal>
      )}

      {interviews.length === 0 ? (
        <div className="rounded-lg border border-border bg-card p-8 text-center"><p className="text-sm text-muted-foreground">No interviews scheduled</p></div>
      ) : (
        <div className="space-y-2">
          {interviews.map((iv) => {
            const statusColor = iv.status === "Selected" ? "border-success/30 bg-success/10 text-success" : iv.status === "Rejected" ? "border-destructive/30 bg-destructive/10 text-destructive" : iv.status === "Pending" ? "border-info/30 bg-info/10 text-info" : "border-warning/30 bg-warning/15 text-warning-foreground";
            return (
              <div key={iv.id} className="rounded-lg border border-border bg-card p-3">
                <div className="flex items-start justify-between gap-3">
                  <div className="flex-1">
                    <h4 className="text-sm font-medium">{iv.resourceName}</h4>
                    <p className="mt-1 text-xs text-muted-foreground">{iv.clientName} · {iv.interviewRound}</p>
                    <p className="text-xs text-muted-foreground">{new Date(iv.interviewDate).toLocaleDateString()} · {iv.interviewer}</p>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className={cn("inline-flex rounded-full border px-2 py-0.5 text-[10px] font-medium", statusColor)}>{iv.status}</span>
                    {isEM && (
                      <select
                        value={iv.status}
                        onChange={(e) => updateStatus(iv.id, e.target.value as InterviewStatus)}
                        className={cn(
                          "h-7 rounded-md border px-2 text-[10px] font-bold shadow-xs transition-colors cursor-pointer outline-none focus-visible:ring-1 focus-visible:ring-ring",
                          iv.status === "Selected" ? "bg-emerald-50 border-emerald-200 text-emerald-700 hover:bg-emerald-100" :
                            iv.status === "Rejected" ? "bg-red-50 border-red-200 text-red-700 hover:bg-red-100" :
                              iv.status === "Pending" ? "bg-blue-50 border-blue-200 text-blue-700 hover:bg-blue-100" :
                                "bg-amber-50 border-amber-200 text-amber-700 hover:bg-amber-100"
                        )}
                      >
                        {(["Pending", "Selected", "Rejected", "Postponed"] as InterviewStatus[]).map((s) => <option key={s} value={s}>{s}</option>)}
                      </select>
                    )}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

function PrerequisiteValidationPanel({ prereq, project, isEM }: { prereq: DhProjectPrereq; project: Project; isEM: boolean }) {
  const [editingStatus, setEditingStatus] = useState<PrereqStatus>(prereq.validation);

  const handleStatusChange = (newStatus: PrereqStatus) => {
    dhStore.setPrereqValidation(project.id, newStatus);
    setEditingStatus(newStatus);
    toast.success("Status updated persistently");
  };

  const statusColor = (status: PrereqStatus) => {
    if (status === "Validated") return "border-success/30 bg-success/10 text-success";
    return "border-amber-200/30 bg-amber-50/30 text-amber-900";
  };

  return (
    <div className="space-y-4">
      <div className="rounded-lg border border-border bg-card p-4">
        <h4 className="mb-3 text-sm font-semibold">Validation Status</h4>
        <div className="space-y-3">
          <div className="flex items-center justify-between">
            <span className="text-xs text-muted-foreground">Validation by EM</span>
            {isEM ? (
              <select
                value={editingStatus}
                onChange={(e) => handleStatusChange(e.target.value as PrereqStatus)}
                className={cn(
                  "h-8 rounded-md border px-2.5 text-[10px] font-bold shadow-xs transition-colors cursor-pointer outline-none focus-visible:ring-1 focus-visible:ring-ring",
                  editingStatus === "Validated"
                    ? "bg-emerald-50 border-emerald-200 text-emerald-700 hover:bg-emerald-100"
                    : "bg-amber-50 border-amber-200 text-amber-700 hover:bg-amber-100"
                )}
              >
                {(["Validation Pending", "Validated"] as PrereqStatus[]).map((s) => <option key={s} value={s}>{s}</option>)}
              </select>
            ) : (
              <span className={cn("inline-flex rounded-full border px-2 py-0.5 text-[10px] font-medium", statusColor(editingStatus))}>{editingStatus}</span>
            )}
          </div>
          <p className="text-[11px] text-muted-foreground">Only Engagement Manager can update this status</p>
        </div>
      </div>
    </div>
  );
}

// ---------- WBS Prerequisite Section Helpers ----------
function getPMStats(pmId: string): { total: number; ongoing: number; completed: number; freePct: number } {
  const all = projects.filter(p => p.pmId === pmId || p.teamIds?.includes(pmId));
  const total = all.length;
  const ongoing = all.filter(p => p.status === "ongoing").length;
  const completed = all.filter(p => p.status === "completed").length;
  // Free % = completed / total × 100 (more completed = more capacity freed up)
  const freePct = total > 0 ? Math.round((completed / total) * 100) : 100;
  return { total, ongoing, completed, freePct };
}

function getOngoingProjectCountForPM(pmId: string): number {
  return projects.filter(p => p.pmId === pmId && p.status === "ongoing").length;
}

function getClientInfo(clientId: string) {
  const client = allClients().find((c: any) => c.id === clientId);
  if (!client) return null;
  return {
    name: client.name,
    type: client.clientType || "NEW",
    previousPmIds: client.previousPmIds || []
  };
}

function WbsPrerequisiteSection({ project, onNavigateToHealthAlerts }: { project: Project; onNavigateToHealthAlerts?: () => void }) {
  const snapshot = useDhStore((s) => s);
  const prereqs = snapshot.prereqs;
  const { user } = useRoleContext();
  const [assignModalMode, setAssignModalMode] = useState<null | "pm" | "spm">(null);

  // Escalation Modal States
  const [escalationModalOpen, setEscalationModalOpen] = useState(false);
  const [escalationModalSvc, setEscalationModalSvc] = useState<any>(null);
  const [escType, setEscType] = useState("Prerequisite Pending");
  const [escPriority, setEscPriority] = useState<DhPriority>("High");
  const [escSubject, setEscSubject] = useState("");
  const [escDescription, setEscDescription] = useState("");
  const [escTo, setEscTo] = useState<string[]>([]);
  const [escResolutionDate, setEscResolutionDate] = useState("");
  const [escAttachmentName, setEscAttachmentName] = useState("");

  const prereq = prereqs[project.id] ?? {
    projectId: project.id,
    validation: "Validation Pending",
    collection: "NA",
    assignedPmIds: [],
    assignedSpmIds: [],
    isProjectReadyToStart: false,
    services: [],
    auditTrail: []
  };

  const servicesList = prereq.services || [];

  // Auto-calculated Project Level statuses
  const allCollected = servicesList.length > 0 && servicesList.every(s => {
    const wbsSvc = project.wbsDetails?.services?.find((x: any) => x.id === s.serviceId);
    const isResourceDept = wbsSvc ? (DEPT_GROUPS[wbsSvc.department] === "Resource") : false;
    return isResourceDept || s.collectionStatus === "Collected";
  });

  const allValidated = servicesList.length > 0 && servicesList.every(s => {
    const wbsSvc = project.wbsDetails?.services?.find((x: any) => x.id === s.serviceId);
    const isResourceDept = wbsSvc ? (DEPT_GROUPS[wbsSvc.department] === "Resource") : false;
    return isResourceDept || s.validationStatus === "Validated";
  });

  const projectCollectionStatus = allCollected ? "Completed" : "Pending";
  const projectValidationStatus = allValidated ? "Validated" : "Pending";

  // Get client info
  const clientInfo = getClientInfo(project.clientId);

  // Tagged previous managers based on roles
  const clientPrevPMs = useMemo(() => {
    if (!clientInfo || clientInfo.type !== "OLD" || !clientInfo.previousPmIds) return [];
    return clientInfo.previousPmIds.map(getPerson).filter((p: any) => p && p.role === "PM");
  }, [clientInfo]);

  const clientPrevSPMs = useMemo(() => {
    if (!clientInfo || clientInfo.type !== "OLD" || !clientInfo.previousPmIds) return [];
    return clientInfo.previousPmIds.map(getPerson).filter((p: any) => p && p.role === "Senior PM");
  }, [clientInfo]);

  // Determine Ready to Start conditions
  const canShowAssignment = true;
  const canProjectStart = allCollected && allValidated && prereq.assignedPmIds.length > 0 && prereq.assignedSpmIds.length > 0;

  // Get team pool
  const teamPool = useMemo(() => {
    const ids = Array.from(new Set([project.pmId, project.tlId, ...project.teamIds]));
    return ids.map(getPerson);
  }, [project]);

  const stakeholders = useMemo(() => {
    const list: Person[] = [];

    // Add PM
    if (project.pmId) {
      const pmObj = getPerson(project.pmId);
      if (pmObj) list.push(pmObj);
    }
    // Add TL
    if (project.tlId) {
      const tlObj = getPerson(project.tlId);
      if (tlObj) list.push(tlObj);
    }
    // Add EM
    const client = allClients().find((c) => c.id === project.clientId);
    const emName = project.engagementManager || client?.engagementManager || "Riya Kapoor";
    const emObj = people.find((p) => p.name === emName || p.role === "Engagement Manager");
    if (emObj && !list.some(p => p.id === emObj.id)) list.push(emObj);

    // Add HOD (Anita Desai)
    const hodObj = people.find(p => p.role === "HOD" || p.name === "Anita Desai");
    if (hodObj && !list.some(p => p.id === hodObj.id)) list.push(hodObj);

    // Add PMO (Rahul Gupta)
    const pmoObj = people.find(p => p.role === "PMO" || p.name === "Rahul Gupta");
    if (pmoObj && !list.some(p => p.id === pmoObj.id)) list.push(pmoObj);

    // Add Business Owner (Vikrant Malhotra)
    const boObj = people.find(p => p.role === "Business Owner" || p.name === "Vikrant Malhotra");
    if (boObj && !list.some(p => p.id === boObj.id)) list.push(boObj);

    // Add any assigned SPMs
    if (prereq.assignedSpmIds) {
      prereq.assignedSpmIds.forEach(id => {
        const pObj = getPerson(id);
        if (pObj && !list.some(p => p.id === pObj.id)) list.push(pObj);
      });
    }

    // Add other team members assigned to project
    project.teamIds.forEach(id => {
      const pObj = getPerson(id);
      if (pObj && !list.some(p => p.id === pObj.id) && ["PM", "Senior PM", "TL", "EM", "HOD", "PMO", "Business Owner"].includes(pObj.role)) {
        list.push(pObj);
      }
    });

    return list;
  }, [project, clientInfo, prereq.assignedSpmIds]);

  const pmPeople = teamPool.filter(p => prereq.assignedPmIds.includes(p.id));
  const spmPeople = teamPool.filter(p => prereq.assignedSpmIds.includes(p.id));

  const statusColor = (status: string) => {
    if (status === "Completed" || status === "Validated" || status === "Collected" || status === "Ready To Start") return "border-success/30 bg-success/10 text-success";
    if (status === "Pending" || status === "Pending To Collect" || status === "Pending To Validate") return "border-muted-foreground/30 bg-muted text-muted-foreground";
    return "border-muted-foreground/30 bg-muted text-muted-foreground";
  };

  const handleServiceChange = (serviceId: string, field: "collectionStatus" | "validationStatus" | "billingStatus", value: string) => {
    dhStore.setServicePrereqStatus(project.id, serviceId, field, value, user.id, user.name);
    toast.success("Service status updated successfully");
  };

  return (
    <>
      <div className="border-t border-border pt-5">
        <h3 className="text-sm font-semibold mb-4 text-gray-900">PMO Intake & Prerequisite Workflow</h3>

        {/* STEP 1: CLIENT PROFILE & STEP 2: PM/SPM ASSIGNMENT */}
        <div className="grid gap-4 md:grid-cols-3 mb-4">

          {/* CLIENT PROFILE INFORMATION */}
          <div className="md:col-span-2 rounded-lg border border-border bg-card p-4 space-y-4 shadow-sm">
            <div className="flex items-center gap-2 border-b border-border pb-2">
              <span className="inline-flex h-6 w-6 items-center justify-center rounded-full bg-blue-500/20 text-xs font-semibold text-blue-600">1</span>
              <h4 className="text-sm font-bold text-gray-800">Client Profile Information</h4>
            </div>

            <div className="space-y-2 text-xs">
              <div className="flex items-center justify-between">
                <span className="text-muted-foreground">Client ID</span>
                <span className="font-semibold text-gray-800">{project.clientId}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-muted-foreground">Client Name</span>
                <span className="font-semibold text-gray-800">{clientInfo?.name}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-muted-foreground">Client Type</span>
                <span className={cn("inline-flex rounded-full border px-2 py-0.5 text-[10px] font-bold uppercase",
                  clientInfo?.type === "NEW" ? "border-green-200/50 bg-green-50/50 text-green-700" : "border-blue-200/50 bg-blue-50/50 text-blue-700"
                )}>
                  {clientInfo?.type === "NEW" ? "🆕 NEW" : "🔄 OLD"}
                </span>
              </div>
            </div>

            {/* Previously Assigned Project Managers display */}
            {clientInfo?.type === "OLD" && (
              <div className="space-y-3 pt-3 border-t border-border">
                <div>
                  <p className="text-[10px] font-bold text-muted-foreground uppercase tracking-wide mb-1.5">Previously Assigned Project Managers</p>
                  {clientPrevPMs.length > 0 ? (
                    <div className="space-y-1.5">
                      {clientPrevPMs.map((pm: any) => {
                        const stats = getPMStats(pm.id);
                        const freeColor = stats.freePct >= 70 ? "text-success" : stats.freePct >= 40 ? "text-warning-foreground" : "text-destructive";
                        return (
                          <div key={pm.id} className="rounded-md border border-border p-2.5 bg-muted/20 text-[10px] space-y-1.5">
                            <div className="flex items-center justify-between">
                              <div className="flex items-center gap-1.5">
                                <Avatar name={pm.name} size={18} />
                                <span className="font-bold text-gray-800 text-xs">{pm.name}</span>
                              </div>
                              <span className={`font-bold text-sm tabular-nums ${freeColor}`}>{stats.freePct}% free</span>
                            </div>
                            <div className="flex items-center gap-2 text-muted-foreground">
                              <span className="rounded px-1.5 py-0.5 bg-muted font-semibold">Total: {stats.total}</span>
                              <span className="rounded px-1.5 py-0.5 bg-info/10 text-info font-semibold">Ongoing: {stats.ongoing}</span>
                              <span className="rounded px-1.5 py-0.5 bg-success/10 text-success font-semibold">Completed: {stats.completed}</span>
                            </div>
                            <div className="h-1.5 w-full rounded-full bg-muted overflow-hidden">
                              <div className={`h-full rounded-full transition-all ${stats.freePct >= 70 ? "bg-success" : stats.freePct >= 40 ? "bg-warning" : "bg-destructive"}`}
                                style={{ width: `${stats.freePct}%` }} />
                            </div>
                          </div>
                        );
                      })}
                    </div>
                  ) : (
                    <p className="text-[10px] text-muted-foreground italic">No PM historical assignments available.</p>
                  )}
                </div>

                <div>
                  <p className="text-[10px] font-bold text-muted-foreground uppercase tracking-wide mb-1.5">Previously Assigned Senior PMs</p>
                  {clientPrevSPMs.length > 0 ? (
                    <div className="space-y-1.5">
                      {clientPrevSPMs.map((pm: any) => {
                        const stats = getPMStats(pm.id);
                        const freeColor = stats.freePct >= 70 ? "text-success" : stats.freePct >= 40 ? "text-warning-foreground" : "text-destructive";
                        return (
                          <div key={pm.id} className="rounded-md border border-border p-2.5 bg-muted/20 text-[10px] space-y-1.5">
                            <div className="flex items-center justify-between">
                              <div className="flex items-center gap-1.5">
                                <Avatar name={pm.name} size={18} />
                                <span className="font-bold text-gray-800 text-xs">{pm.name}</span>
                              </div>
                              <span className={`font-bold text-sm tabular-nums ${freeColor}`}>{stats.freePct}% free</span>
                            </div>
                            <div className="flex items-center gap-2 text-muted-foreground">
                              <span className="rounded px-1.5 py-0.5 bg-muted font-semibold">Total: {stats.total}</span>
                              <span className="rounded px-1.5 py-0.5 bg-info/10 text-info font-semibold">Ongoing: {stats.ongoing}</span>
                              <span className="rounded px-1.5 py-0.5 bg-success/10 text-success font-semibold">Completed: {stats.completed}</span>
                            </div>
                            <div className="h-1.5 w-full rounded-full bg-muted overflow-hidden">
                              <div className={`h-full rounded-full transition-all ${stats.freePct >= 70 ? "bg-success" : stats.freePct >= 40 ? "bg-warning" : "bg-destructive"}`}
                                style={{ width: `${stats.freePct}%` }} />
                            </div>
                          </div>
                        );
                      })}
                    </div>
                  ) : (
                    <p className="text-[10px] text-muted-foreground italic">No Senior PM historical assignments available.</p>
                  )}
                </div>
              </div>
            )}

            {clientInfo?.type === "NEW" && (
              <div className="pt-3 border-t border-border rounded-md p-3 bg-muted/30 text-center text-xs text-muted-foreground font-medium">
                No historical PM/SPM assignments available.
              </div>
            )}
          </div>

          {/* PM/SPM ASSIGNMENT FLOW */}
          <div className="rounded-lg border border-border bg-card p-4 space-y-4 shadow-sm">
            <div className="flex items-center gap-2 border-b border-border pb-2">
              <span className="inline-flex h-6 w-6 items-center justify-center rounded-full bg-purple-500/20 text-xs font-semibold text-purple-600">2</span>
              <h4 className="text-sm font-bold text-gray-800">Project Allocation</h4>
            </div>

            <div className="space-y-3 text-xs leading-relaxed">
              <div>
                <p className="font-bold text-muted-foreground uppercase text-[10px] mb-1">Assigned Project Managers</p>
                <div className="flex flex-wrap gap-1.5">
                  {pmPeople.map(p => (
                    <span key={p.id} className="inline-flex items-center gap-1 rounded-full border border-border bg-primary/10 px-2 py-0.5 font-medium">
                      <Avatar name={p.name} size={14} /> {p.name}
                    </span>
                  ))}
                  {pmPeople.length === 0 && <span className="text-muted-foreground italic text-[11px]">No PM assigned yet</span>}
                </div>
              </div>

              <div>
                <p className="font-bold text-muted-foreground uppercase text-[10px] mb-1">Assigned Senior PMs</p>
                <div className="flex flex-wrap gap-1.5">
                  {spmPeople.map(p => (
                    <span key={p.id} className="inline-flex items-center gap-1 rounded-full border border-border bg-primary/10 px-2 py-0.5 font-medium">
                      <Avatar name={p.name} size={14} /> {p.name}
                    </span>
                  ))}
                  {spmPeople.length === 0 && <span className="text-muted-foreground italic text-[11px]">No Senior PM assigned yet</span>}
                </div>
              </div>
            </div>

            <div className="flex gap-2">
              <button
                onClick={() => setAssignModalMode("pm")}
                disabled={!canShowAssignment}
                className={cn(
                  "flex-1 inline-flex items-center justify-center gap-1.5 rounded-md px-3 py-2 text-xs font-semibold transition-colors",
                  canShowAssignment
                    ? "bg-primary text-primary-foreground hover:bg-primary/90"
                    : "bg-muted text-muted-foreground cursor-not-allowed border border-border"
                )}
              >
                <UserPlus className="h-3.5 w-3.5" /> Assign PM
              </button>
              <button
                onClick={() => setAssignModalMode("spm")}
                disabled={!canShowAssignment}
                className={cn(
                  "flex-1 inline-flex items-center justify-center gap-1.5 rounded-md px-3 py-2 text-xs font-semibold transition-colors",
                  canShowAssignment
                    ? "bg-primary text-primary-foreground hover:bg-primary/90"
                    : "bg-muted text-muted-foreground cursor-not-allowed border border-border"
                )}
              >
                <UserPlus className="h-3.5 w-3.5" /> Assign SPM
              </button>
            </div>
            {!canShowAssignment && (
              <p className="text-[9px] text-muted-foreground italic text-center">Locked until all service collect &amp; validate prerequisites are validated.</p>
            )}
          </div>
        </div>

        {/* STEP 3 & 4: SERVICE WISE TRACKING TABLE */}
        <div className="grid gap-4 md:grid-cols-3 mb-4">
          <div className="md:col-span-4 rounded-lg border border-border bg-card p-4 shadow-sm space-y-3">
            <div className="flex items-center gap-2 border-b border-border pb-2">
              <span className="inline-flex h-6 w-6 items-center justify-center rounded-full bg-orange-500/20 text-xs font-semibold text-orange-600">3</span>
              <h4 className="text-sm font-bold text-gray-800">Service wise Prerequisite Tracking</h4>
            </div>

            <div className="overflow-x-auto rounded-md border border-border bg-card">
              <table className="w-full text-xs">
                <thead className="bg-muted/40 uppercase tracking-wide text-muted-foreground">
                  <tr>
                    <th className="px-3 py-2 font-bold text-center">Service Name</th>
                    <th className="px-3 py-2 font-bold text-center">Collection Status</th>
                    <th className="px-3 py-2 font-bold text-center">Validation Status</th>
                    <th className="px-3 py-2 font-bold text-center">Billing Status</th>
                    <th className="px-3 py-2 font-bold text-center">Ready to Start</th>
                    <th className="px-3 py-2 font-bold text-center">Escalation</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-border">
                  {servicesList.map((svc) => {
                    const wbsSvc = project.wbsDetails?.services?.find((x: any) => x.id === svc.serviceId);
                    const isResourceDept = wbsSvc ? (DEPT_GROUPS[wbsSvc.department] === "Resource") : false;

                    const isCollected = isResourceDept ? true : svc.collectionStatus === "Collected";
                    const isValidated = isResourceDept ? true : svc.validationStatus === "Validated";
                    const isBillingOk = svc.billingStatus === "Advance Received" || svc.billingStatus === "Advance Not Required";
                    const canStart = isCollected && isValidated && isBillingOk;
                    const isReady = svc.isReady ?? false;

                    const svcEscalations = snapshot.alerts.filter((a) => a.projectId === project.id && a.kind === "Escalation" && a.serviceName === svc.serviceName);
                    const activeEsc = svcEscalations.find((e) => e.status !== "Resolved" && e.status !== "Closed");

                    return (
                      <tr key={svc.serviceId} className="hover:bg-accent/20">
                        <td className="px-3 py-2.5 text-center align-middle font-semibold text-gray-800">{svc.serviceName}</td>
                        <td className="px-3 py-2.5 text-center align-middle">
                          <select
                            value={isResourceDept ? "NA" : svc.collectionStatus}
                            disabled={isResourceDept}
                            onChange={(e) => handleServiceChange(svc.serviceId, "collectionStatus", e.target.value)}
                            className={cn(
                              "h-7 rounded-md border px-2 text-[10px] font-bold outline-none shadow-xs transition-colors cursor-pointer",
                              isResourceDept
                                ? "bg-gray-100 border-gray-200 text-gray-400 cursor-not-allowed"
                                : svc.collectionStatus === "Collected"
                                  ? "bg-emerald-50 border-emerald-200 text-emerald-700 hover:bg-emerald-100"
                                  : "bg-gray-50 border-gray-200 text-gray-600 hover:bg-gray-100"
                            )}
                          >
                            {isResourceDept ? (
                              <option value="NA">NA</option>
                            ) : (
                              <>
                                <option value="Pending To Collect">Pending To Collect</option>
                                <option value="Collected">Collected</option>
                              </>
                            )}
                          </select>
                        </td>
                        <td className="px-3 py-2.5 text-center align-middle">
                          <select
                            value={isResourceDept ? "NA" : svc.validationStatus}
                            disabled={isResourceDept || !isCollected}
                            onChange={(e) => handleServiceChange(svc.serviceId, "validationStatus", e.target.value)}
                            className={cn(
                              "h-7 rounded-md border px-2 text-[10px] font-bold outline-none shadow-xs transition-colors cursor-pointer",
                              (isResourceDept || !isCollected)
                                ? "bg-gray-100 border-gray-200 text-gray-400 cursor-not-allowed"
                                : svc.validationStatus === "Validated"
                                  ? "bg-emerald-50 border-emerald-200 text-emerald-700 hover:bg-emerald-100"
                                  : "bg-gray-50 border-gray-200 text-gray-600 hover:bg-gray-100"
                            )}
                          >
                            {isResourceDept ? (
                              <option value="NA">NA</option>
                            ) : (
                              <>
                                <option value="Pending To Validate">Pending To Validate</option>
                                <option value="Validated">Validated</option>
                              </>
                            )}
                          </select>
                        </td>
                        <td className="px-3 py-2.5 text-center align-middle">
                          <select
                            value={svc.billingStatus ?? "Advance Pending"}
                            onChange={(e) => handleServiceChange(svc.serviceId, "billingStatus", e.target.value)}
                            className={cn(
                              "h-7 rounded-md border px-2 text-[10px] font-bold outline-none shadow-xs transition-colors cursor-pointer",
                              svc.billingStatus === "Advance Received"
                                ? "bg-emerald-50 border-emerald-200 text-emerald-700 hover:bg-emerald-100"
                                : svc.billingStatus === "Advance Not Required"
                                  ? "bg-gray-50 border-gray-200 text-gray-600 hover:bg-gray-100"
                                  : "bg-amber-50 border-amber-200 text-amber-700 hover:bg-amber-100"
                            )}
                          >
                            <option value="Advance Pending">Advance Pending</option>
                            <option value="Advance Received">Advance Received</option>
                            <option value="Advance Not Required">Advance Not Required</option>
                          </select>
                        </td>
                        <td className="px-3 py-2.5 text-center align-middle">
                          <div className="flex items-center justify-center">
                            {isReady ? (
                              <span className="inline-flex items-center gap-1 rounded-md border border-success/30 bg-success/10 px-2.5 py-1 text-[10px] font-bold text-success">
                                ✓ Started
                              </span>
                            ) : (
                              <button
                                disabled={!canStart}
                                onClick={() => {
                                  dhStore.setServicePrereqReady(project.id, svc.serviceId, true);
                                  toast.success("Service marked as Ready to Start", { description: svc.serviceName });
                                }}
                                className={cn(
                                  "inline-flex items-center gap-1 rounded-md px-2.5 py-1 text-[10px] font-bold transition-colors",
                                  canStart
                                    ? "bg-success text-white hover:bg-success/90 shadow-sm cursor-pointer"
                                    : "bg-muted text-muted-foreground border border-border cursor-not-allowed opacity-60"
                                )}
                                title={!canStart ? (isResourceDept ? "Set Billing to Received/Not Required first" : "Set Collection to Collected, Validation to Validated, and Billing to Received/Not Required first") : "Mark this service as Ready to Start"}
                              >
                                Ready
                              </button>
                            )}
                          </div>
                        </td>
                        <td className="px-3 py-2.5 text-center align-middle">
                          {activeEsc ? (
                            <button
                              onClick={() => {
                                onNavigateToHealthAlerts?.();
                                window.location.hash = "#health-alerts";
                                toast.info("Active escalation details are available in Health → Alerts");
                              }}
                              className={cn(
                                "inline-flex items-center gap-1 rounded-md border px-2 py-0.5 text-[9px] font-bold text-white hover:opacity-90 transition-opacity",
                                activeEsc.priority === "Critical" ? "bg-red-600 border-red-700" :
                                  activeEsc.priority === "High" ? "bg-amber-600 border-amber-700" : "bg-blue-600 border-blue-700"
                              )}
                              title="Click to view details in Health tab"
                            >
                              ⚠️ {activeEsc.status} ({activeEsc.priority})
                            </button>
                          ) : (
                            <button
                              onClick={() => {
                                setEscalationModalSvc(svc);
                                setEscalationModalOpen(true);
                              }}
                              className="inline-flex items-center gap-1 rounded-md bg-destructive text-white hover:bg-destructive/90 px-2 py-0.5 text-[9px] font-bold transition-colors cursor-pointer"
                            >
                              Raise Escalation
                            </button>
                          )}
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </div>

        </div>
      </div>

      {/* Raise Escalation Modal */}
      {escalationModalOpen && escalationModalSvc && (
        <Modal title="Raise WBS Escalation" onClose={() => setEscalationModalOpen(false)}>
          <div className="space-y-4 text-xs">
            {/* Read-Only Project Info */}
            <div className="bg-muted/30 border border-border rounded-lg p-3 grid grid-cols-2 gap-3">
              <div>
                <span className="text-[10px] uppercase font-bold text-muted-foreground block">Project ID</span>
                <span className="font-semibold text-gray-800">{project.projectSeqId || project.id}</span>
              </div>
              <div>
                <span className="text-[10px] uppercase font-bold text-muted-foreground block">Project Name</span>
                <span className="font-semibold text-gray-800">{project.name}</span>
              </div>
              <div>
                <span className="text-[10px] uppercase font-bold text-muted-foreground block">Client Name</span>
                <span className="font-semibold text-gray-800">{clientInfo?.name || "—"}</span>
              </div>
              <div>
                <span className="text-[10px] uppercase font-bold text-muted-foreground block">Service Name</span>
                <span className="font-semibold text-primary">{escalationModalSvc.serviceName}</span>
              </div>
            </div>

            {/* Type & Priority */}
            <div className="grid grid-cols-2 gap-3">
              <div className="flex flex-col gap-1">
                <label className="font-bold text-gray-700">Escalation Type <span className="text-destructive">*</span></label>
                <select
                  value={escType}
                  onChange={(e) => setEscType(e.target.value)}
                  className="form-input rounded-md border border-border p-2 bg-card text-xs outline-none"
                >
                  <option value="Prerequisite Pending">Prerequisite Pending</option>
                  <option value="Client Dependency">Client Dependency</option>
                  <option value="Billing Issue">Billing Issue</option>
                  <option value="Technical Blocker">Technical Blocker</option>
                  <option value="Resource Blocker">Resource Blocker</option>
                  <option value="Approval Pending">Approval Pending</option>
                  <option value="Infrastructure Issue">Infrastructure Issue</option>
                  <option value="Requirement Clarification">Requirement Clarification</option>
                  <option value="Timeline Risk">Timeline Risk</option>
                  <option value="Other">Other</option>
                </select>
              </div>

              <div className="flex flex-col gap-1">
                <label className="font-bold text-gray-700">Priority <span className="text-destructive">*</span></label>
                <select
                  value={escPriority}
                  onChange={(e) => setEscPriority(e.target.value as any)}
                  className="form-input rounded-md border border-border p-2 bg-card text-xs outline-none"
                >
                  <option value="Low">Low</option>
                  <option value="Medium">Medium</option>
                  <option value="High">High</option>
                  <option value="Critical">Critical</option>
                </select>
              </div>
            </div>

            {/* Subject */}
            <div className="flex flex-col gap-1">
              <label className="font-bold text-gray-700">Subject <span className="text-destructive">*</span></label>
              <input
                type="text"
                placeholder="e.g. Client has not provided production access"
                value={escSubject}
                onChange={(e) => setEscSubject(e.target.value)}
                className="form-input rounded-md border border-border p-2 bg-card text-xs outline-none"
              />
            </div>

            {/* Description */}
            <div className="flex flex-col gap-1">
              <label className="font-bold text-gray-700">Description <span className="text-destructive">*</span></label>
              <textarea
                placeholder="Explain what is blocked, why work cannot continue, required action, and expected resolution..."
                value={escDescription}
                onChange={(e) => setEscDescription(e.target.value)}
                rows={3}
                className="w-full rounded-md border border-border bg-card p-2 text-xs outline-none"
              />
            </div>

            {/* Attachment */}
            <div className="flex flex-col gap-1">
              <label className="font-bold text-gray-700">Attachment</label>
              <div className="flex items-center gap-2">
                <label className="border border-border rounded-md px-3 py-1.5 bg-muted/40 cursor-pointer hover:bg-muted/80 text-[10px] font-semibold">
                  📎 Upload File
                  <input
                    type="file"
                    className="hidden"
                    onChange={(e) => {
                      if (e.target.files?.[0]) {
                        setEscAttachmentName(e.target.files[0].name);
                      }
                    }}
                  />
                </label>
                <span className="text-[10px] text-muted-foreground">
                  {escAttachmentName || "No file selected (email logs, screenshot, docs...)"}
                </span>
                {escAttachmentName && (
                  <button onClick={() => setEscAttachmentName("")} className="text-destructive text-[10px] hover:underline">Remove</button>
                )}
              </div>
            </div>

            {/* Escalate To (Multi-Select Stakeholders) */}
            <div className="flex flex-col gap-1">
              <label className="font-bold text-gray-700">Escalate To (Select Stakeholders) <span className="text-destructive">*</span></label>
              <div className="border border-border rounded-md p-2 bg-card max-h-32 overflow-y-auto space-y-1">
                {stakeholders.map((p) => {
                  const isSelected = escTo.includes(p.name);
                  return (
                    <label key={p.id} className="flex items-center gap-2 cursor-pointer hover:bg-accent/40 p-1 rounded-sm text-xs select-none">
                      <input
                        type="checkbox"
                        checked={isSelected}
                        onChange={() => {
                          if (isSelected) {
                            setEscTo(prev => prev.filter(name => name !== p.name));
                          } else {
                            setEscTo(prev => [...prev, p.name]);
                          }
                        }}
                        className="h-3.5 w-3.5 accent-primary cursor-pointer animate-none"
                      />
                      <span>{p.name} ({p.role})</span>
                    </label>
                  );
                })}
              </div>
              <p className="text-[10px] text-muted-foreground">Only stakeholders associated with this project are listed.</p>
            </div>

            {/* Expected Resolution Date */}
            <div className="flex flex-col gap-1">
              <label className="font-bold text-gray-700">Expected Resolution Date</label>
              <input
                type="date"
                value={escResolutionDate}
                onChange={(e) => setEscResolutionDate(e.target.value)}
                className="form-input rounded-md border border-border p-2 bg-card text-xs outline-none"
              />
            </div>

            {/* Actions */}
            <div className="flex justify-end gap-2 border-t border-border pt-3">
              <button
                onClick={() => {
                  setEscalationModalOpen(false);
                  setEscalationModalSvc(null);
                }}
                className="rounded-md border border-input bg-card px-4 py-2 text-xs font-semibold hover:bg-accent"
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  if (!escSubject.trim() || !escDescription.trim() || escTo.length === 0) {
                    toast.error("Please fill all mandatory fields (Subject, Description, and select at least one recipient)");
                    return;
                  }
                  dhStore.addEscalationAlert({
                    projectId: project.id,
                    title: escSubject,
                    description: escDescription,
                    priority: escPriority,
                    raisedByName: user.name || "Dhanshree",
                    serviceName: escalationModalSvc.serviceName,
                    escalationType: escType,
                    escalatedTo: escTo,
                    expectedResolutionDate: escResolutionDate || undefined,
                    attachments: escAttachmentName ? [escAttachmentName] : []
                  });
                  toast.success("Escalation raised successfully!", { description: `Notification sent to: ${escTo.join(", ")}` });
                  setEscalationModalOpen(false);
                  setEscalationModalSvc(null);
                  setEscSubject("");
                  setEscDescription("");
                  setEscTo([]);
                  setEscResolutionDate("");
                  setEscAttachmentName("");
                }}
                className="rounded-md bg-destructive text-white hover:bg-destructive/90 px-4 py-2 text-xs font-semibold"
              >
                Send Escalation
              </button>
            </div>
          </div>
        </Modal>
      )}

      {/* WBS Assignment Modal */}
      {assignModalMode && (
        <WbsAssignmentModal
          project={project}
          prereq={prereq}
          teamPool={teamPool}
          clientInfo={clientInfo}
          mode={assignModalMode}
          onClose={() => setAssignModalMode(null)}
        />
      )}
    </>
  );
}

// Updated Assignment Modal with intelligent filtering
function WbsAssignmentModal({
  project,
  prereq,
  teamPool,
  clientInfo,
  mode,
  onClose,
}: {
  project: Project;
  prereq: DhProjectPrereq;
  teamPool: Person[];
  clientInfo: { name: string; type: "NEW" | "OLD"; previousPmIds: string[] } | null;
  mode: "pm" | "spm";
  onClose: () => void;
}) {
  const [selectedPMs, setSelectedPMs] = useState<string[]>(prereq.assignedPmIds);
  const [selectedSPMs, setSelectedSPMs] = useState<string[]>(prereq.assignedSpmIds);
  const [pmQuery, setPmQuery] = useState("");
  const [spmQuery, setSpmQuery] = useState("");

  // Show all available team members regardless of client type
  const filteredPool = useMemo(() => {
    return teamPool;
  }, [teamPool]);

  const pmVisiblePool = filteredPool.filter(p =>
    !selectedSPMs.includes(p.id) &&
    (!pmQuery.trim() || p.name.toLowerCase().includes(pmQuery.toLowerCase()))
  );
  const spmVisiblePool = filteredPool.filter(p =>
    !selectedPMs.includes(p.id) &&
    (!spmQuery.trim() || p.name.toLowerCase().includes(spmQuery.toLowerCase()))
  );

  const selectedPMPeople = filteredPool.filter(p => selectedPMs.includes(p.id));
  const selectedSPMPeople = filteredPool.filter(p => selectedSPMs.includes(p.id));

  const togglePM = (id: string) => {
    setSelectedPMs(s => (s.includes(id) ? s.filter(x => x !== id) : [...s, id]));
  };

  const toggleSPM = (id: string) => {
    setSelectedSPMs(s => (s.includes(id) ? s.filter(x => x !== id) : [...s, id]));
  };

  const handleSubmit = () => {
    if (mode === "pm" && selectedPMs.length === 0) {
      toast.error("Please select at least one Project Manager");
      return;
    }
    if (mode === "spm" && selectedSPMs.length === 0) {
      toast.error("Please select at least one Senior Project Manager");
      return;
    }

    // Merge with existing assignments — keep the other role's assignments intact
    const finalPMs = mode === "pm" ? selectedPMs : prereq.assignedPmIds;
    const finalSPMs = mode === "spm" ? selectedSPMs : prereq.assignedSpmIds;

    dhStore.assignPMs(project.id, finalPMs, finalSPMs);
    toast.success(
      mode === "pm" ? "PM Assigned" : "Senior PM Assigned",
      {
        description: mode === "pm"
          ? `${selectedPMs.length} PM(s) assigned successfully.`
          : `${selectedSPMs.length} SPM(s) assigned successfully.`
      }
    );
    onClose();
  };

  const title = mode === "pm" ? "Assign Project Manager" : "Assign Senior Project Manager";

  return (
    <Modal title={title} onClose={onClose}>
      <div className="space-y-4">
        <p className="text-xs text-muted-foreground">
          {mode === "pm"
            ? "Select one or more Project Managers to assign to this project."
            : "Select one or more Senior Project Managers to assign to this project."}
        </p>

        <div>
          {mode === "pm" ? (
            /* Project Managers Selection */
            <div className="space-y-2">
              <label className="text-xs font-medium text-muted-foreground">Project Managers</label>
              <div className="relative">
                <Search className="pointer-events-none absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
                <input
                  value={pmQuery}
                  onChange={(e) => setPmQuery(e.target.value)}
                  placeholder="Search PM..."
                  className="h-9 w-full rounded-md border border-input bg-background pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
                />
              </div>
              {selectedPMPeople.length > 0 && (
                <div className="flex flex-wrap gap-1.5">
                  {selectedPMPeople.map(p => (
                    <span key={p.id} className="inline-flex items-center gap-1 rounded-full border border-border bg-primary/10 px-2 py-0.5 text-xs">
                      <Avatar name={p.name} size={16} /> {p.name}
                      <button onClick={() => togglePM(p.id)} className="ml-1 text-muted-foreground hover:text-foreground">
                        <X className="h-3 w-3" />
                      </button>
                    </span>
                  ))}
                </div>
              )}
              <ul className="max-h-56 divide-y divide-border overflow-y-auto rounded-md border border-border">
                {pmVisiblePool.map(p => {
                  const isSel = selectedPMs.includes(p.id);
                  const ongoingCount = getOngoingProjectCountForPM(p.id);
                  return (
                    <li key={p.id}>
                      <button
                        onClick={() => togglePM(p.id)}
                        className={cn("flex w-full items-center gap-2 px-3 py-2 text-left hover:bg-accent/40 text-xs", isSel && "bg-primary/5")}
                      >
                        <Avatar name={p.name} size={22} />
                        <div className="flex-1 min-w-0">
                          <div className="font-medium">{p.name}</div>
                          <div className="text-[10px] text-muted-foreground">{ongoingCount} Ongoing Projects</div>
                        </div>
                        {isSel && <Check className="h-4 w-4 flex-shrink-0 text-primary" />}
                      </button>
                    </li>
                  );
                })}
                {pmVisiblePool.length === 0 && (
                  <li className="px-3 py-4 text-center text-xs text-muted-foreground">
                    {pmQuery ? "No match" : "No available members"}
                  </li>
                )}
              </ul>
            </div>
          ) : (
            /* Senior PMs Selection */
            <div className="space-y-2">
              <label className="text-xs font-medium text-muted-foreground">Senior Project Managers</label>
              <div className="relative">
                <Search className="pointer-events-none absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
                <input
                  value={spmQuery}
                  onChange={(e) => setSpmQuery(e.target.value)}
                  placeholder="Search SPM..."
                  className="h-9 w-full rounded-md border border-input bg-background pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
                />
              </div>
              {selectedSPMPeople.length > 0 && (
                <div className="flex flex-wrap gap-1.5">
                  {selectedSPMPeople.map(p => (
                    <span key={p.id} className="inline-flex items-center gap-1 rounded-full border border-border bg-primary/10 px-2 py-0.5 text-xs">
                      <Avatar name={p.name} size={16} /> {p.name}
                      <button onClick={() => toggleSPM(p.id)} className="ml-1 text-muted-foreground hover:text-foreground">
                        <X className="h-3 w-3" />
                      </button>
                    </span>
                  ))}
                </div>
              )}
              <ul className="max-h-56 divide-y divide-border overflow-y-auto rounded-md border border-border">
                {spmVisiblePool.map(p => {
                  const isSel = selectedSPMs.includes(p.id);
                  const ongoingCount = getOngoingProjectCountForPM(p.id);
                  return (
                    <li key={p.id}>
                      <button
                        onClick={() => toggleSPM(p.id)}
                        className={cn("flex w-full items-center gap-2 px-3 py-2 text-left hover:bg-accent/40 text-xs", isSel && "bg-primary/5")}
                      >
                        <Avatar name={p.name} size={22} />
                        <div className="flex-1 min-w-0">
                          <div className="font-medium">{p.name}</div>
                          <div className="text-[10px] text-muted-foreground">{ongoingCount} Ongoing Projects</div>
                        </div>
                        {isSel && <Check className="h-4 w-4 flex-shrink-0 text-primary" />}
                      </button>
                    </li>
                  );
                })}
                {spmVisiblePool.length === 0 && (
                  <li className="px-3 py-4 text-center text-xs text-muted-foreground">
                    {spmQuery ? "No match" : "No available members"}
                  </li>
                )}
              </ul>
            </div>
          )}
        </div>

        <div className="flex justify-end gap-2 border-t border-border pt-3">
          <button onClick={onClose} className="rounded-md border border-input bg-card px-3 py-1.5 text-xs hover:bg-accent">
            Cancel
          </button>
          <button
            onClick={handleSubmit}
            className="rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90"
          >
            {mode === "pm" ? "Assign PM" : "Assign SPM"}
          </button>
        </div>
      </div>
    </Modal>
  );
}
