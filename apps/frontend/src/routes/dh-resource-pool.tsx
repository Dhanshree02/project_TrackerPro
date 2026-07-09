import { createFileRoute, Link, Navigate } from "@tanstack/react-router";
import React, { useMemo, useState, useRef } from "react";
import { Search, Download, ChevronLeft, ChevronRight, Eye, UserPlus, X } from "lucide-react";
import { toast } from "sonner";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { Avatar, ProgressBar } from "@/components/pills";
import { cn } from "@/lib/utils";
import {
  employees,
  departments,
  employeeStatuses,
} from "@/lib/employee-data";
import { people, projects } from "@/lib/mock-data";
import { Modal } from "@/routes/projects.index";

export const Route = createFileRoute("/dh-resource-pool")({
  head: () => ({
    meta: [
      { title: "Resource Pool — Pulse PMO" },
      { name: "description", content: "View and manage employee resource pool and allocation statuses." },
    ],
  }),
  component: ResourcePoolPage,
});

const PAGE_SIZE = 15;

type AllocationStatus = "Occupied" | "OnLeave" | "Free" | "Trainee";

// ── Deterministic helper to get allocation status for mock purposes ──
function getAllocationStatus(e: any): AllocationStatus {
  if (e.status === "On Leave") return "OnLeave";
  if (e.category.includes("Intern") || e.designation.toLowerCase().includes("intern")) return "Trainee";

  const person = people.find((p) =>
    p.name.toLowerCase() === `${e.firstName} ${e.lastName}`.toLowerCase() ||
    p.name.toLowerCase().includes(e.firstName.toLowerCase())
  );

  if (person) {
    const hasProject = projects.some((p) => p.pmId === person.id || p.tlId === person.id || p.teamIds.includes(person.id));
    if (hasProject) return "Occupied";
  }

  return "Free";
}

function getAllocationType(e: any): "Dedicated" | "Shared" {
  const person = people.find((p) =>
    p.name.toLowerCase() === `${e.firstName} ${e.lastName}`.toLowerCase() ||
    p.name.toLowerCase().includes(e.firstName.toLowerCase())
  );
  if (person) {
    const assignedProjs = projects.filter((p) => p.pmId === person.id || p.tlId === person.id || p.teamIds.includes(person.id));
    if (assignedProjs.length === 1) return "Dedicated";
    if (assignedProjs.length > 1) return "Shared";
  }
  const idx = parseInt(e.id.replace("EMP-", "")) || 0;
  return idx % 2 === 0 ? "Dedicated" : "Shared";
}

function getAllocationDuration(e: any): string {
  const status = getAllocationStatus(e);
  if (status === "OnLeave") return "—";
  if (status === "Trainee") return "3 Months (Probation)";

  const person = people.find((p) =>
    p.name.toLowerCase() === `${e.firstName} ${e.lastName}`.toLowerCase() ||
    p.name.toLowerCase().includes(e.firstName.toLowerCase())
  );

  if (person) {
    const proj = projects.find((p) => p.pmId === person.id || p.tlId === person.id || p.teamIds.includes(person.id));
    if (proj) {
      if (!proj.startDate || !proj.endDate) return "Indefinite";
      const formatDate = (dateStr: string) => {
        const d = new Date(dateStr);
        const day = String(d.getDate()).padStart(2, '0');
        const month = String(d.getMonth() + 1).padStart(2, '0');
        const year = d.getFullYear();
        return `${day}/${month}/${year}`;
      };
      return `${formatDate(proj.startDate)} → ${formatDate(proj.endDate)}`;
    }
  }

  return "—";
}

function getLocalLocation(e: any): string {
  const locationsList = ["Borivali", "Virar", "Vasai", "Bandra", "Andheri", "Dombivali", "Thane", "Kurla", "Goregaon", "Malad"];
  const idx = parseInt(e.id.replace("EMP-", "")) || 0;
  return locationsList[idx % locationsList.length];
}


// ── Allocation Status pill ───────────────────────────
function AllocationStatusBadge({ status }: { status: AllocationStatus }) {
  const map: Record<AllocationStatus, string> = {
    Occupied: "border-blue-500/30 bg-blue-500/10 text-blue-600 dark:text-blue-400",
    OnLeave: "border-amber-500/30 bg-amber-500/10 text-amber-600 dark:text-amber-400",
    Free: "border-emerald-500/30 bg-emerald-500/10 text-emerald-600 dark:text-emerald-400",
    Trainee: "border-slate-500/30 bg-slate-500/10 text-slate-600 dark:text-slate-400",
  };

  const labels: Record<AllocationStatus, string> = {
    Occupied: "Occupied",
    OnLeave: "On Leave",
    Free: "Free",
    Trainee: "Trainee",
  };

  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full border px-2 py-0.5 text-[11px] font-semibold tracking-wide shadow-xs",
        map[status]
      )}
    >
      {labels[status]}
    </span>
  );
}

// ── Filter Select ──────────────────────────────────
function FilterSelect({
  value,
  onChange,
  placeholder,
  options,
}: {
  value: string;
  onChange: (v: string) => void;
  placeholder: string;
  options: string[];
}) {
  return (
    <select
      value={value}
      onChange={(e) => onChange(e.target.value)}
      className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
    >
      <option value="">{placeholder}</option>
      {options.map((o) => (
        <option key={o}>{o}</option>
      ))}
    </select>
  );
}

// ── Metric Row helper inside modal ─────────────────
function MetricRow({ label, value, bar }: { label: string; value: string; bar: number }) {
  return (
    <div>
      <div className="mb-1 flex items-center justify-between text-[11px]">
        <span className="text-muted-foreground">{label}</span>
        <span className="font-semibold text-foreground tabular-nums">{value}</span>
      </div>
      <ProgressBar value={bar} />
    </div>
  );
}

// ── Resource Workload Modal ────────────────────────
function ResourceTasksModal({
  employee,
  onClose,
}: {
  employee: typeof employees[number];
  onClose: () => void;
}) {
  const person = useMemo(() => {
    return people.find((p) => p.name.toLowerCase() === `${employee.firstName} ${employee.lastName}`.toLowerCase());
  }, [employee]);

  const assignedProjs = useMemo(() => {
    if (person) {
      return projects.filter((p) => p.pmId === person.id || p.tlId === person.id || p.teamIds.includes(person.id));
    }
    // Fallback: assign 1-2 projects deterministically based on employee ID index to make it feel populated
    const idx = parseInt(employee.id.replace("EMP-", "")) || 0;
    const proj1 = projects[idx % projects.length];
    const proj2 = projects[(idx + 1) % projects.length];
    return [proj1, proj2];
  }, [employee, person]);

  const count = assignedProjs.length;
  const isOnLeave = employee.status === "On Leave";
  const utilization = isOnLeave ? 0 : Math.min(100, count * 35 + 20);
  const availability = 100 - utilization;

  return (
    <Modal title={`${employee.firstName} ${employee.lastName} — Workload & Tasks`} onClose={onClose} wide>
      <div className="grid gap-6 md:grid-cols-3">
        {/* Resource info column */}
        <div className="space-y-4">
          <div className="flex items-center gap-3 rounded-lg border border-border bg-accent/25 p-3">
            <Avatar name={`${employee.firstName} ${employee.lastName}`} size={42} />
            <div>
              <div className="text-sm font-semibold">{employee.firstName} {employee.lastName}</div>
              <div className="text-[11px] text-muted-foreground">{employee.department} · {employee.designation}</div>
              <div className="text-[11px] text-muted-foreground font-mono">{employee.id}</div>
              {isOnLeave && (
                <span className="mt-1 inline-flex rounded-full border border-amber-500/30 bg-amber-500/10 px-1.5 py-0.5 text-[9px] font-semibold uppercase text-amber-600 dark:text-amber-400">On Leave</span>
              )}
            </div>
          </div>

          <MetricRow label="Utilization" value={`${utilization}%`} bar={utilization} />
          <MetricRow label="Availability" value={`${availability}%`} bar={availability} />

          <div>
            <div className="mb-1.5 text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">Skills</div>
            <div className="flex flex-wrap gap-1">
              {employee.skills.map((s) => (
                <span key={s} className="rounded-full border border-border bg-muted px-2 py-0.5 text-[11px] font-medium text-foreground/80">
                  {s}
                </span>
              ))}
            </div>
          </div>
        </div>

        {/* Assigned projects column */}
        <div className="md:col-span-2 space-y-3">
          <h4 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
            Active Projects & Tasks ({assignedProjs.length})
          </h4>
          <ul className="space-y-2">
            {assignedProjs.length === 0 && (
              <li className="text-sm text-muted-foreground">No active project assignments.</li>
            )}
            {assignedProjs.map((p) => (
              <li key={p.id} className="flex flex-col gap-2 rounded-lg border border-border bg-card p-3 text-xs">
                <div className="flex items-center justify-between">
                  <span className="font-semibold text-foreground text-sm">{p.name}</span>
                  <span className="text-[10px] uppercase font-semibold text-muted-foreground bg-muted border border-border px-2 py-0.5 rounded-full">
                    {p.status}
                  </span>
                </div>
                <div className="flex items-center gap-4 mt-1">
                  <div className="flex-1">
                    <div className="mb-1 flex items-center justify-between text-[10px] text-muted-foreground">
                      <span>Project Progress</span>
                      <span className="font-semibold">{p.progress}%</span>
                    </div>
                    <ProgressBar value={p.progress} className="h-1.5" />
                  </div>
                </div>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </Modal>
  );
}

// ── Request Allocation Modal ──────────────────────
function RequestAllocationModal({
  employee,
  onClose,
}: {
  employee: typeof employees[number];
  onClose: () => void;
}) {
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [comment, setComment] = useState("");
  const [taggedPeople, setTaggedPeople] = useState<typeof people>([]);
  const [mentionQuery, setMentionQuery] = useState<string | null>(null);
  const [mentionIndex, setMentionIndex] = useState(-1);
  const [showDropdown, setShowDropdown] = useState(false);
  const [dropdownPosition, setDropdownPosition] = useState({ top: 0, left: 0 });

  const textareaRef = useRef<HTMLTextAreaElement>(null);

  // Filter people for mentions
  const filteredPeople = useMemo(() => {
    if (mentionQuery === null) return [];
    return people.filter(p =>
      p.name.toLowerCase().includes(mentionQuery.toLowerCase()) &&
      !taggedPeople.some(tp => tp.id === p.id)
    ).slice(0, 5); // limit to 5 results
  }, [mentionQuery, taggedPeople]);

  const handleTextareaChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    const value = e.target.value;
    setComment(value);

    const selectionStart = e.target.selectionStart;
    const beforeCursor = value.slice(0, selectionStart);
    
    // Check if user is typing a mention (word starting with @)
    const match = beforeCursor.match(/@(\w*)$/);
    if (match) {
      setMentionQuery(match[1]);
      setShowDropdown(true);
      
      // Calculate coordinates for the suggestions dropdown
      if (textareaRef.current) {
        const textLines = beforeCursor.split("\n");
        const currentLine = textLines.length;
        const currentCol = textLines[textLines.length - 1].length;
        setDropdownPosition({
          top: currentLine * 20 + 35,
          left: Math.min(250, currentCol * 8 + 10)
        });
      }
    } else {
      setShowDropdown(false);
      setMentionQuery(null);
    }
  };

  const handleSelectPerson = (person: typeof people[number]) => {
    if (!textareaRef.current) return;
    const value = comment;
    const selectionStart = textareaRef.current.selectionStart;
    const beforeCursor = value.slice(0, selectionStart);
    const afterCursor = value.slice(selectionStart);

    // Replace the @query with the person's name
    const newBeforeCursor = beforeCursor.replace(/@(\w*)$/, `@${person.name} `);
    const newValue = newBeforeCursor + afterCursor;
    
    setComment(newValue);
    setTaggedPeople(prev => {
      if (prev.some(p => p.id === person.id)) return prev;
      return [...prev, person];
    });
    setShowDropdown(false);
    setMentionQuery(null);

    // Focus back on textarea and set cursor position
    setTimeout(() => {
      if (textareaRef.current) {
        textareaRef.current.focus();
        const newCursorPos = newBeforeCursor.length;
        textareaRef.current.setSelectionRange(newCursorPos, newCursorPos);
      }
    }, 0);
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (showDropdown && filteredPeople.length > 0) {
      if (e.key === "ArrowDown") {
        e.preventDefault();
        setMentionIndex(prev => (prev + 1) % filteredPeople.length);
      } else if (e.key === "ArrowUp") {
        e.preventDefault();
        setMentionIndex(prev => (prev - 1 + filteredPeople.length) % filteredPeople.length);
      } else if (e.key === "Enter" || e.key === "Tab") {
        e.preventDefault();
        const selected = filteredPeople[mentionIndex >= 0 ? mentionIndex : 0];
        if (selected) {
          handleSelectPerson(selected);
        }
      } else if (e.key === "Escape") {
        e.preventDefault();
        setShowDropdown(false);
        setMentionQuery(null);
      }
    }
  };

  const handleRemoveTag = (personId: string) => {
    setTaggedPeople(prev => prev.filter(p => p.id !== personId));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!startDate || !endDate) {
      toast.error("Please enter both start and end dates");
      return;
    }
    if (new Date(startDate) > new Date(endDate)) {
      toast.error("Start date cannot be after end date");
      return;
    }

    toast.success(`Allocation request for ${employee.firstName} ${employee.lastName} sent to ${employee.reportingManager}!`);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div className="absolute inset-0 bg-black/40 backdrop-blur-[1px]" onClick={onClose} />

      {/* Modal Content */}
      <div 
        className="relative w-full max-w-lg rounded-xl border border-border bg-card p-6 shadow-2xl animate-in fade-in zoom-in-95 duration-150"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between border-b border-border pb-4">
          <div>
            <h2 className="text-base font-semibold text-foreground">Request Allocation</h2>
            <p className="text-xs text-muted-foreground">
              Request allocation of {employee.firstName} {employee.lastName} (ID: {employee.id})
            </p>
          </div>
          <button onClick={onClose} className="rounded-md p-1 text-muted-foreground hover:bg-accent transition-colors">
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* Reporting Manager Display Header */}
        <div className="my-4 rounded-lg bg-primary/5 border border-primary/10 p-3.5 flex items-center justify-between">
          <div>
            <div className="text-[10px] uppercase font-bold tracking-wider text-primary/80">Routing To:</div>
            <div className="mt-0.5 text-sm font-semibold text-foreground">{employee.reportingManager}</div>
            <div className="text-[11px] text-muted-foreground font-medium">Reporting Manager Action Center</div>
          </div>
          <span className="inline-flex rounded-full bg-primary/10 px-2 py-0.5 text-[10px] font-medium text-primary">
            Auto-Routed
          </span>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <label className="block">
              <span className="mb-1 block text-xs font-medium text-muted-foreground">Start Date</span>
              <input
                type="date"
                value={startDate}
                onChange={(e) => setStartDate(e.target.value)}
                className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm text-foreground outline-none focus:ring-1 focus:ring-ring"
                required
              />
            </label>
            <label className="block">
              <span className="mb-1 block text-xs font-medium text-muted-foreground">End Date</span>
              <input
                type="date"
                value={endDate}
                onChange={(e) => setEndDate(e.target.value)}
                className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm text-foreground outline-none focus:ring-1 focus:ring-ring"
                required
              />
            </label>
          </div>

          <div className="relative">
            <label className="block">
              <span className="mb-1 block text-xs font-medium text-muted-foreground">
                Comments (Type @ to tag team members)
              </span>
              <textarea
                ref={textareaRef}
                value={comment}
                onChange={handleTextareaChange}
                onKeyDown={handleKeyDown}
                placeholder="E.g., @Aarav Patel we need him for the frontend tasks starting next week..."
                className="w-full rounded-md border border-input bg-card p-3 text-sm text-foreground outline-none focus:ring-1 focus:ring-ring min-h-[100px] resize-none"
              />
            </label>

            {/* Live @ Mentions Dropdown */}
            {showDropdown && filteredPeople.length > 0 && (
              <div 
                className="absolute z-50 w-56 rounded-md border border-border bg-popover text-popover-foreground shadow-lg overflow-hidden py-1"
                style={{ top: `${dropdownPosition.top}px`, left: `${dropdownPosition.left}px` }}
              >
                {filteredPeople.map((p, idx) => (
                  <button
                    key={p.id}
                    type="button"
                    onClick={() => handleSelectPerson(p)}
                    onMouseEnter={() => setMentionIndex(idx)}
                    className={cn(
                      "w-full text-left px-3 py-1.5 text-xs flex items-center gap-2 hover:bg-accent hover:text-accent-foreground",
                      (mentionIndex === idx || (mentionIndex === -1 && idx === 0)) && "bg-accent text-accent-foreground"
                    )}
                  >
                    <Avatar name={p.name} size={20} />
                    <span>{p.name}</span>
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Tagged people badges */}
          {taggedPeople.length > 0 && (
            <div>
              <span className="block text-xs font-medium text-muted-foreground mb-1.5">Tagged CC's ({taggedPeople.length}):</span>
              <div className="flex flex-wrap gap-1.5">
                {taggedPeople.map(p => (
                  <span 
                    key={p.id} 
                    className="inline-flex items-center gap-1.5 rounded-full border border-primary/20 bg-primary/5 px-2.5 py-0.5 text-xs text-primary font-medium shadow-xs"
                  >
                    <Avatar name={p.name} size={16} />
                    <span>{p.name}</span>
                    <button 
                      type="button" 
                      onClick={() => handleRemoveTag(p.id)}
                      className="ml-1 rounded-full p-0.5 hover:bg-primary/10 text-primary/70 hover:text-primary transition-colors"
                    >
                      <X className="h-3 w-3" />
                    </button>
                  </span>
                ))}
              </div>
            </div>
          )}

          <div className="flex items-center justify-end gap-2 border-t border-border pt-4 mt-2">
            <button
              type="button"
              onClick={onClose}
              className="rounded-md border border-input bg-card px-4 py-2 text-sm font-medium text-foreground hover:bg-accent transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 shadow-sm transition-all"
            >
              Send Request
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

function ResourcePoolPage() {
  const { isDhanshree } = useRoleContext();
  const [q, setQ] = useState("");
  const [dept, setDept] = useState("");
  const [allocStatus, setAllocStatus] = useState<string>("");
  const [page, setPage] = useState(1);
  const [selectedEmployee, setSelectedEmployee] = useState<typeof employees[number] | null>(null);
  const [allocReqEmployee, setAllocReqEmployee] = useState<typeof employees[number] | null>(null);
  const [empStatus, setEmpStatus] = useState<string>("");

  if (!isDhanshree) return <Navigate to="/" />;

  const rows = useMemo(() => {
    return employees.filter((e) => {
      const statusVal = getAllocationStatus(e);
      const matchQ =
        !q ||
        `${e.firstName} ${e.lastName} ${e.id} ${e.email} ${e.department} ${e.designation} ${e.reportingManager} ${e.workLocation}`
          .toLowerCase()
          .includes(q.toLowerCase());

      const matchStatus = !allocStatus || statusVal === allocStatus;
      const matchDept = !dept || e.department === dept;
      const matchEmpStatus = !empStatus || e.status === empStatus;

      return matchQ && matchStatus && matchDept && matchEmpStatus;
    });
  }, [q, dept, allocStatus, empStatus]);

  const totalPages = Math.max(1, Math.ceil(rows.length / PAGE_SIZE));
  const currentPage = Math.min(page, totalPages);
  const pageRows = rows.slice((currentPage - 1) * PAGE_SIZE, currentPage * PAGE_SIZE);

  // Reset page when filters change
  useMemo(() => setPage(1), [q, dept, allocStatus, empStatus]);

  return (
    <AppShell title="Resource Pool" subtitle={`${rows.length} of ${employees.length} resources active`}>
      {/* Header */}
      <div className="mb-5 flex flex-wrap items-start justify-between gap-3">
        {/* <div>
          <h2 className="text-lg font-semibold tracking-tight">Resource Pool</h2>
          <p className="text-xs text-muted-foreground">{rows.length} of {employees.length} total resources</p>
        </div> */}
      </div>

      {/* Filters */}
      <div className="mb-4 grid grid-cols-1 gap-3 rounded-xl border border-border bg-card p-3 md:grid-cols-5">
        <div className="relative">
          <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Search resources..."
            className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
        </div>
        <FilterSelect value={dept} onChange={setDept} placeholder="All Departments" options={departments} />
        <FilterSelect
          value={allocStatus}
          onChange={setAllocStatus}
          placeholder="All Allocation Status"
          options={["Occupied", "OnLeave", "Free", "Training"]}
        />
        <FilterSelect
          value={empStatus}
          onChange={setEmpStatus}
          placeholder="All Employment Status"
          options={employeeStatuses}
        />
        <div className="flex">
          <button className="h-9 w-full inline-flex items-center justify-center gap-1.5 rounded-md border border-input bg-card px-3 text-sm hover:bg-accent">
            <Download className="h-3.5 w-3.5" />
            Export Pool
          </button>
        </div>
      </div>

      {/* Table */}
      <div className="overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
        <table className="w-full text-sm">
          <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr>
              {[
                "Dept",
                "Emp Name",
                "Reporting Manager",
                "Allocation Status",
                "Allocation Type",
                "Allocation Duration",
                "Location",
                "Office Site",
                "Project Site",
                "Tasks",
              ].map((h) => (
                <th key={h} className={cn("whitespace-nowrap px-4 py-3 font-medium", h === "Tasks" ? "text-right" : "text-left")}>
                  {h}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {pageRows.map((e) => {
              const statusVal = getAllocationStatus(e);
              return (
                <tr
                  key={e.id}
                  className="cursor-pointer transition-colors hover:bg-accent/30"
                >
                  <td className="whitespace-nowrap px-4 py-3 font-semibold text-foreground/90">
                    {e.department}
                  </td>
                  <td className="whitespace-nowrap px-4 py-3 font-medium">
                    <Link
                      to="/dh-employee-directory/$id"
                      params={{ id: e.id }}
                      className="flex items-center gap-2.5 hover:text-primary transition-colors"
                    >
                      <Avatar name={`${e.firstName} ${e.lastName}`} size={28} />
                      <span className="font-semibold">{e.firstName} {e.lastName}</span>
                    </Link>
                  </td>
                  <td className="whitespace-nowrap px-4 py-3 text-muted-foreground">
                    {e.reportingManager}
                  </td>
                  <td className="whitespace-nowrap px-4 py-3">
                    <AllocationStatusBadge status={statusVal} />
                  </td>
                  <td className="whitespace-nowrap px-4 py-3">
                    <span className={cn(
                      "inline-flex items-center rounded-full border px-2 py-0.5 text-[11px] font-semibold tracking-wide shadow-xs",
                      getAllocationType(e) === "Dedicated"
                        ? "border-indigo-500/30 bg-indigo-500/10 text-indigo-600 dark:text-indigo-400"
                        : "border-slate-500/30 bg-slate-500/10 text-slate-600 dark:text-slate-400"
                    )}>
                      {getAllocationType(e)}
                    </span>
                  </td>
                  <td className="whitespace-nowrap px-4 py-3 font-medium text-foreground/80">
                    {getAllocationDuration(e)}
                  </td>
                  <td className="whitespace-nowrap px-4 py-3 text-muted-foreground">
                    {getLocalLocation(e)}
                  </td>
                  <td className="whitespace-nowrap px-4 py-3 text-muted-foreground">
                    {e.workLocation}
                  </td>
                  <td className="whitespace-nowrap px-4 py-3">
                    <span className={cn(
                      "inline-flex items-center rounded-full border px-2 py-0.5 text-[11px] font-medium",
                      e.projectSite === "Onsite"
                        ? "border-info/30 bg-info/10 text-info"
                        : "border-muted-foreground/30 bg-muted text-muted-foreground"
                    )}>
                      {e.projectSite}
                    </span>
                  </td>
                  <td className="whitespace-nowrap px-4 py-3 text-right">
                    <button
                      onClick={(evt) => {
                        evt.stopPropagation();
                        setAllocReqEmployee(e);
                      }}
                      title="Request Allocation"
                      className="mr-1.5 inline-flex h-7 px-2.5 items-center justify-center gap-1 rounded-md border border-primary/20 bg-primary/5 text-xs font-semibold text-primary hover:bg-primary/10 transition-colors"
                    >
                      <UserPlus className="h-3.5 w-3.5" />
                    </button>
                    <button
                      onClick={(evt) => {
                        evt.stopPropagation();
                        setSelectedEmployee(e);
                      }}
                      className="inline-flex h-7 px-2.5 items-center justify-center gap-1 rounded-md border border-input bg-card text-xs font-semibold text-muted-foreground hover:bg-accent hover:text-foreground transition-colors"
                    >
                      <Eye className="h-3.5 w-3.5" />
                    </button>
                  </td>
                </tr>
              );
            })}
            {pageRows.length === 0 && (
              <tr>
                <td colSpan={10} className="px-4 py-12 text-center text-sm text-muted-foreground">
                  No resources match the selected criteria.
                </td>
              </tr>
            )}
          </tbody>
        </table>

        {/* Pagination */}
        <div className="flex items-center justify-between border-t border-border px-4 py-3 text-xs text-muted-foreground bg-muted/10">
          <div>
            Showing {rows.length === 0 ? 0 : (currentPage - 1) * PAGE_SIZE + 1}–
            {Math.min(currentPage * PAGE_SIZE, rows.length)} of {rows.length}
          </div>
          <div className="flex items-center gap-1.5">
            <button
              onClick={() => setPage((p) => Math.max(1, p - 1))}
              disabled={currentPage <= 1}
              className="inline-flex items-center gap-1 rounded-md border border-input px-2.5 py-1.5 hover:bg-accent disabled:opacity-40"
            >
              <ChevronLeft className="h-3.5 w-3.5" /> Previous
            </button>
            <span className="px-2 tabular-nums font-medium">{currentPage} / {totalPages}</span>
            <button
              onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
              disabled={currentPage >= totalPages}
              className="inline-flex items-center gap-1 rounded-md border border-input px-2.5 py-1.5 hover:bg-accent disabled:opacity-40"
            >
              Next <ChevronRight className="h-3.5 w-3.5" />
            </button>
          </div>
        </div>
      </div>

      {/* Interactive Workload Tasks Modal */}
      {selectedEmployee && (
        <ResourceTasksModal
          employee={selectedEmployee}
          onClose={() => setSelectedEmployee(null)}
        />
      )}

      {/* Allocation Request Modal */}
      {allocReqEmployee && (
        <RequestAllocationModal
          employee={allocReqEmployee}
          onClose={() => setAllocReqEmployee(null)}
        />
      )}
    </AppShell>
  );
}
