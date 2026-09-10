import { createFileRoute, Link, Navigate, useNavigate } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { X, AlertTriangle } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useAuth } from "@/lib/auth-context";
import { useRoleContext } from "@/lib/role-context";
import { Avatar } from "@/components/pills";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import {
  fetchEmployee,
  offboardEmployee,
  toUiEmployee,
} from "@/lib/api/employees";
import type { Employee } from "@/lib/employee-data";
import { EmployeeFormModal } from "@/components/employee-form-modal";

export const Route = createFileRoute("/dh-employee-directory/$id")({
  head: () => ({
    meta: [
      { title: "Employee Profile — Pulse PMO" },
      { name: "description", content: "View full profile of an employee." },
    ],
  }),
  component: EmployeeProfilePage,
});

// ── Helpers ────────────────────────────────────────

function EmpStatusBadge({ status }: { status?: string }) {
  if (!status) return <span className="text-muted-foreground">—</span>;
  const map: Record<string, string> = {
    Active: "border-success/30 bg-success/10 text-success",
    "Active - Probation": "border-warning/40 bg-warning/15 text-warning-foreground",
    "Resignation - Under Review": "border-warning/40 bg-warning/15 text-warning-foreground",
    "Resignation - Accepted": "border-destructive/30 bg-destructive/10 text-destructive",
    "Inactive - After Onboarding": "border-muted-foreground/30 bg-muted text-muted-foreground",
    Probation: "border-warning/40 bg-warning/15 text-warning-foreground",
    "Notice Period": "border-destructive/30 bg-destructive/10 text-destructive",
    Inactive: "border-muted-foreground/30 bg-muted text-muted-foreground",
    "On Leave": "border-info/30 bg-info/10 text-info",
    Confirmed: "border-success/30 bg-success/10 text-success",
    Pending: "border-warning/40 bg-warning/15 text-warning-foreground",
  };
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full border px-2.5 py-0.5 text-[11px] font-medium",
        map[status] ?? "border-border bg-muted text-muted-foreground",
      )}
    >
      {status}
    </span>
  );
}

function Row({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="border-b border-border py-2.5 last:border-0">
      <div className="text-[11px] font-medium uppercase tracking-wider text-muted-foreground">
        {label}
      </div>
      <div className="mt-1 text-sm font-medium text-foreground">
        {value == null || value === "" ? "—" : value}
      </div>
    </div>
  );
}

function Grid({ children }: { children: React.ReactNode }) {
  return <div className="grid grid-cols-1 gap-x-8 gap-y-1 md:grid-cols-2 lg:grid-cols-3">{children}</div>;
}

function addDaysIso(isoDate: string, days: number): string {
  const [y, m, d] = isoDate.split("-").map(Number);
  if (!y || !m || !d) return "";
  const next = new Date(y, m - 1, d);
  next.setDate(next.getDate() + days);
  return `${next.getFullYear()}-${String(next.getMonth() + 1).padStart(2, "0")}-${String(next.getDate()).padStart(2, "0")}`;
}

function todayIso(): string {
  const n = new Date();
  return `${n.getFullYear()}-${String(n.getMonth() + 1).padStart(2, "0")}-${String(n.getDate()).padStart(2, "0")}`;
}

function parseNoticeDays(value?: string): string {
  const match = value?.match(/\d+/);
  return match ? match[0] : "";
}

// ── Offboard Dialog ────────────────────────────────

function OffboardConfirmDialog({
  employee,
  isSubmitting,
  onConfirm,
  onCancel,
}: {
  employee: Employee;
  isSubmitting: boolean;
  onConfirm: (details: {
    resignationDate: string;
    lastWorkingDay: string;
    reasonForLeaving: string;
    noticePeriodServed: string;
  }) => void;
  onCancel: () => void;
}) {
  const [noticePeriodDays, setNoticePeriodDays] = useState(parseNoticeDays(employee.noticePeriod));
  const [resignationDate, setResignationDate] = useState(todayIso);
  const [reasonForLeaving, setReasonForLeaving] = useState("");
  const [errors, setErrors] = useState<Record<string, string>>({});

  const inputCls =
    "h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring text-foreground";
  const readOnlyCls = `${inputCls} bg-muted text-muted-foreground cursor-not-allowed`;

  const noticeDays = Number.parseInt(noticePeriodDays, 10);
  const lastWorkingDay =
    resignationDate && Number.isInteger(noticeDays) && noticeDays >= 0
      ? addDaysIso(resignationDate, noticeDays)
      : "";

  const submit = () => {
    const next: Record<string, string> = {};
    if (!noticePeriodDays.trim()) next.noticePeriodDays = "Notice period is required";
    else if (!Number.isInteger(noticeDays) || noticeDays < 0 || noticeDays > 730) {
      next.noticePeriodDays = "Enter notice period in days (0–730)";
    }
    if (!resignationDate) next.resignationDate = "Resignation date is required";
    if (!lastWorkingDay) next.lastWorkingDay = "Last working day could not be calculated";
    if (!reasonForLeaving.trim()) next.reasonForLeaving = "Reason for leaving is required";
    if (reasonForLeaving.trim().length > 500) next.reasonForLeaving = "Reason must be 500 characters or less";
    setErrors(next);
    if (Object.keys(next).length > 0) return;
    onConfirm({
      resignationDate,
      lastWorkingDay,
      reasonForLeaving: reasonForLeaving.trim(),
      noticePeriodServed: `${noticeDays} days`,
    });
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/50 backdrop-blur-[1px]" onClick={onCancel} />
      <div
        className="relative w-full max-w-lg rounded-xl border border-destructive/30 bg-card p-6 shadow-2xl animate-in fade-in zoom-in-95 duration-150"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-start gap-3">
          <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-destructive/10">
            <AlertTriangle className="h-5 w-5 text-destructive" />
          </div>
          <div className="min-w-0">
            <h2 className="text-base font-semibold text-foreground">Offboard Employee?</h2>
            <p className="mt-1 text-xs text-muted-foreground">
              This action cannot be undone. They will appear on Exit Summary immediately
              and stay in the directory until the day after last working day (notice period
              end).
            </p>
          </div>
          <button
            type="button"
            onClick={onCancel}
            disabled={isSubmitting}
            className="ml-auto shrink-0 rounded-md p-1 text-muted-foreground transition-colors hover:bg-accent disabled:opacity-50"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <div className="mt-4 flex items-center gap-3 rounded-lg border border-border bg-muted/30 p-3">
          <Avatar name={`${employee.firstName} ${employee.lastName}`} size={36} />
          <div className="min-w-0">
            <p className="truncate text-sm font-medium text-foreground">
              {employee.firstName} {employee.lastName}
            </p>
            <p className="text-[11px] text-muted-foreground">
              {employee.id} · {employee.department || "—"}
            </p>
          </div>
        </div>

        <div className="mt-4 grid grid-cols-1 gap-3 sm:grid-cols-2">
          <label className="block">
            <span className="mb-1 block text-xs font-medium text-muted-foreground">
              Notice Period (days) <span className="text-destructive">*</span>
            </span>
            <input
              autoComplete="off"
              type="number"
              min={0}
              max={730}
              step={1}
              inputMode="numeric"
              placeholder="e.g. 60"
              value={noticePeriodDays}
              onChange={(e) => setNoticePeriodDays(e.target.value.replace(/[^\d]/g, ""))}
              className={cn(inputCls, errors.noticePeriodDays && "border-destructive")}
              disabled={isSubmitting}
            />
            {errors.noticePeriodDays ? (
              <p className="mt-1 text-[11px] text-destructive">{errors.noticePeriodDays}</p>
            ) : null}
          </label>
          <label className="block">
            <span className="mb-1 block text-xs font-medium text-muted-foreground">
              Resignation Date <span className="text-destructive">*</span>
            </span>
            <input
              autoComplete="off"
              type="date"
              value={resignationDate}
              onChange={(e) => setResignationDate(e.target.value)}
              className={cn(inputCls, errors.resignationDate && "border-destructive")}
              disabled={isSubmitting}
            />
            {errors.resignationDate ? (
              <p className="mt-1 text-[11px] text-destructive">{errors.resignationDate}</p>
            ) : null}
          </label>
          <label className="block sm:col-span-2">
            <span className="mb-1 block text-xs font-medium text-muted-foreground">
              Last Working Day
            </span>
            <input
              autoComplete="off"
              type="date"
              value={lastWorkingDay}
              readOnly
              className={cn(readOnlyCls, errors.lastWorkingDay && "border-destructive")}
            />
            <p className="mt-1 text-[11px] text-muted-foreground">
              Calculated as resignation date + notice period days.
            </p>
            {errors.lastWorkingDay ? (
              <p className="mt-1 text-[11px] text-destructive">{errors.lastWorkingDay}</p>
            ) : null}
          </label>
          <label className="block sm:col-span-2">
            <span className="mb-1 block text-xs font-medium text-muted-foreground">
              Reason for Leaving <span className="text-destructive">*</span>
            </span>
            <input
              autoComplete="off"
              value={reasonForLeaving}
              onChange={(e) => setReasonForLeaving(e.target.value)}
              placeholder="Better opportunity"
              className={cn(inputCls, errors.reasonForLeaving && "border-destructive")}
              disabled={isSubmitting}
            />
            {errors.reasonForLeaving ? (
              <p className="mt-1 text-[11px] text-destructive">{errors.reasonForLeaving}</p>
            ) : null}
          </label>
        </div>

        <div className="mt-5 flex items-center justify-end gap-2 border-t border-border pt-4">
          <button
            type="button"
            onClick={onCancel}
            disabled={isSubmitting}
            className="rounded-md border border-input bg-card px-4 py-2 text-sm font-medium text-foreground transition-colors hover:bg-accent disabled:opacity-50"
          >
            Cancel
          </button>
          <button
            type="button"
            onClick={submit}
            disabled={isSubmitting}
            className="inline-flex items-center gap-2 rounded-md bg-destructive px-4 py-2 text-sm font-medium text-destructive-foreground shadow-sm transition-all hover:bg-destructive/90 disabled:opacity-60"
          >
            {isSubmitting ? "Offboarding…" : "Yes, Offboard"}
          </button>
        </div>
      </div>
    </div>
  );
}

// ── Profile Tabs Config ────────────────────────────

const tabs = [
  { id: "personal", label: "Personal Information" },
  { id: "org", label: "Organization Details" },
  { id: "employment", label: "Employment & Bond" },
  { id: "education", label: "Education & Experience" },
  { id: "pmo", label: "PMO Information" },
] as const;

// ── Main Page ──────────────────────────────────────

function EmployeeProfilePage() {
  const { status: authStatus } = useAuth();
  const { id } = Route.useParams();
  const navigate = useNavigate();
  const { isDhanshree, isHr, isEmployee, isPmFamily, isPmoFamily, isAccounts, isSales } =
    useRoleContext();

  const [emp, setEmp] = useState<Employee | null>(null);
  const [loadError, setLoadError] = useState(false);
  const [tab, setTab] = useState<string>("personal");
  const [isOffboarding, setIsOffboarding] = useState(false);
  const [offboardConfirmOpen, setOffboardConfirmOpen] = useState(false);
  const [editOpen, setEditOpen] = useState(false);

  const employeeId = decodeURIComponent(id ?? "").trim();

  // Load employee detail
  useEffect(() => {
    if (authStatus !== "authed") return;
    if (!employeeId) {
      setLoadError(true);
      return;
    }
    let cancelled = false;
    (async () => {
      try {
        const detail = await fetchEmployee(employeeId);
        if (cancelled) return;
        const loaded = toUiEmployee(detail);
        setEmp(loaded);
        setLoadError(false);
      } catch {
        if (!cancelled) setLoadError(true);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [authStatus, employeeId]);


  const basicDirectory = isEmployee || isPmFamily || isPmoFamily || isAccounts || isSales;
  if (!isDhanshree && !isHr && !basicDirectory) return <Navigate to="/" />;

  if (loadError) {
    return (
      <AppShell title="Employee Profile" subtitle="Not found">
        <div className="rounded-xl border border-border bg-card px-6 py-12 text-center">
          <p className="text-sm font-medium text-foreground">This employee profile could not be loaded.</p>
          <p className="mt-1 text-sm text-muted-foreground">
            The record may not exist in the database, or the API is unavailable.
          </p>
          <Link
            to="/dh-employee-directory"
            className="mt-4 inline-flex rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 transition-colors"
          >
            Back to directory
          </Link>
        </div>
      </AppShell>
    );
  }

  if (!emp) {
    return (
      <AppShell title="Employee Profile" subtitle="Loading…">
        <div className="py-12 text-center text-sm text-muted-foreground">Loading employee profile…</div>
      </AppShell>
    );
  }

  const handleOffboard = async (details: {
    resignationDate: string;
    lastWorkingDay: string;
    reasonForLeaving: string;
    noticePeriodServed: string;
  }) => {
    if (!emp || isOffboarding) return;
    setIsOffboarding(true);
    try {
      await offboardEmployee(emp.id, {
        resignationDate: details.resignationDate,
        lastWorkingDay: details.lastWorkingDay,
        reasonForLeaving: details.reasonForLeaving,
        noticePeriodServed: details.noticePeriodServed,
        exitType: "Resign",
        exitReason: details.reasonForLeaving,
      });
      setOffboardConfirmOpen(false);
      toast.success(
        `${emp.firstName} ${emp.lastName} added to Exit Summary. They stay in the directory until the day after last working day.`,
      );
      await navigate({ to: "/dh-exit-summary" });
    } catch (error: any) {
      toast.error(error?.message ?? "Failed to offboard employee");
    } finally {
      setIsOffboarding(false);
    }
  };

  const basicOnly = isEmployee || isPmFamily || isPmoFamily || isAccounts || isSales;
  const visibleTabs = basicOnly ? tabs.filter((t) => t.id === "personal") : tabs;

  return (
    <AppShell
      title={`${emp.firstName} ${emp.lastName}`}
      subtitle={`${emp.designation || "Employee"} · ${emp.department || "Organization"}`}
    >
      {/* Breadcrumb */}
      <div className="mb-4 flex items-center gap-2 text-xs text-muted-foreground">
        <Link to="/dh-employee-directory" className="hover:text-foreground transition-colors">
          Employee Directory
        </Link>
        <span>/</span>
        <span className="text-foreground font-medium">
          {emp.firstName} {emp.lastName}
        </span>
      </div>

      {/* Profile Header */}
      <div className="rounded-xl border border-border bg-card p-6 shadow-2xs">
        <div className="flex flex-wrap items-start justify-between gap-4">
          <div className="flex items-start gap-4">
            <Avatar name={`${emp.firstName} ${emp.lastName}`} size={52} />
            <div>
              <div className="flex flex-wrap items-center gap-3">
                <h1 className="text-xl font-semibold tracking-tight text-foreground">
                  {emp.firstName} {emp.lastName}
                </h1>
                <div className="flex flex-wrap items-center gap-2">
                  <EmpStatusBadge status={emp.confirmationStatus || emp.status} />
                  <span className="inline-flex items-center rounded-full border border-primary/30 bg-primary/10 px-2.5 py-0.5 text-[11px] font-medium text-primary">
                    {emp.category}
                  </span>
                </div>
              </div>
              <div className="mt-1 text-sm text-muted-foreground">
                {emp.designation || "—"} · {emp.department || "—"}
              </div>
              <div className="mt-2.5 flex flex-wrap gap-x-5 gap-y-1.5 text-xs text-muted-foreground">
                <span>
                  ID: <span className="font-mono font-medium text-foreground">{emp.id}</span>
                </span>
                <span>
                  Email: <span className="font-medium text-foreground">{emp.email}</span>
                </span>
                <span>
                  Work Location: <span className="font-medium text-foreground">{emp.workLocation || "—"}</span>
                </span>
                <span>
                  Reporting Manager:{" "}
                  <span className="font-medium text-foreground">{emp.reportingManager || "—"}</span>
                </span>
                <span>
                  Joining Date: <span className="font-medium text-foreground">{emp.joiningDate || "—"}</span>
                </span>
              </div>
            </div>
          </div>
          {!basicOnly && (
            <div className="flex flex-wrap gap-2">
              <button
                type="button"
                onClick={() => setEditOpen(true)}
                className="rounded-md border border-input bg-card px-3.5 py-2 text-sm font-medium text-foreground hover:bg-accent transition-colors shadow-2xs"
              >
                Edit Profile
              </button>
              <button
                type="button"
                onClick={() => setOffboardConfirmOpen(true)}
                disabled={isOffboarding || emp.status === "Notice Period"}
                className="rounded-md bg-destructive px-3.5 py-2 text-sm font-medium text-destructive-foreground hover:bg-destructive/90 disabled:opacity-60 transition-colors shadow-2xs"
              >
                {emp.status === "Notice Period" ? "On Notice Period" : "Offboard Employee"}
              </button>
            </div>
          )}
        </div>
      </div>

      {/* Tabs */}
      <div className="mt-6">
        <div className="flex flex-wrap gap-1 border-b border-border">
          {visibleTabs.map((t) => (
            <button
              key={t.id}
              onClick={() => setTab(t.id)}
              className={cn(
                "relative -mb-px whitespace-nowrap px-4 py-2.5 text-sm font-medium transition-colors",
                tab === t.id
                  ? "border-b-2 border-primary text-foreground font-semibold"
                  : "text-muted-foreground hover:text-foreground",
              )}
            >
              {t.label}
            </button>
          ))}
        </div>

        <div className="mt-5">
          {/* ── 1. Personal Information ── */}
          {tab === "personal" && (
            <div className="rounded-lg border border-border bg-card p-6 shadow-2xs">
              <Grid>
                <Row label="TK ID" value={emp.id} />
                <Row label="First Name" value={emp.firstName} />
                <Row label="Last Name" value={emp.lastName} />
                <Row label="Work Email ID" value={emp.email} />
                <Row label="Contact Number" value={emp.phone ? `+91 ${emp.phone}` : "—"} />
                <Row label="Alternate Contact" value={emp.altPhone ? `+91 ${emp.altPhone}` : "—"} />
                <Row label="Current Address - City" value={emp.address} />
                <Row label="Emergency Contact Name" value={emp.emergencyContactName} />
                <Row label="Emergency Contact Number" value={emp.emergencyContact ? `+91 ${emp.emergencyContact}` : "—"} />
                <Row label="Relation with Emergency Contact" value={emp.emergencyContactRelation} />
              </Grid>
            </div>
          )}

          {/* ── 2. Organization Assignment ── */}
          {tab === "org" && (
            <div className="rounded-lg border border-border bg-card p-6 shadow-2xs">
              <Grid>
                <Row label="Business Unit" value={emp.businessUnit} />
                <Row label="Department" value={emp.department} />
                <Row label="Designation" value={emp.designation} />
                <Row label="On Floor Role" value={emp.role} />
                <Row label="Reporting Manager" value={emp.reportingManager} />
                <Row label="Work Location" value={emp.workLocation} />
                {emp.workLocation === "Onsite" && (
                  <Row label="Location (Onsite)" value={emp.projectSite || "—"} />
                )}
              </Grid>
            </div>
          )}

          {/* ── 3. Employment & Bond Details ── */}
          {tab === "employment" && (
            <div className="rounded-lg border border-border bg-card p-6 shadow-2xs">
              <Grid>
                <Row label="Date of Joining" value={emp.joiningDate || "—"} />
                <Row
                  label="Employment Status"
                  value={<EmpStatusBadge status={emp.confirmationStatus || emp.status} />}
                />
                <Row
                  label="Probation Status"
                  value={
                    emp.probationStatus ||
                    (emp.confirmationStatus === "Active - Probation" ? "Ongoing" : "Completed")
                  }
                />
                <Row label="Worker Type" value={emp.workerType || emp.category} />
                <Row label="Employee Category" value={emp.category} />
                <Row label="Asset ID" value={emp.assetId || "—"} />
                <Row
                  label="Bond Delivered"
                  value={
                    emp.bondDelivered ||
                    (emp.category?.includes("Bond") && !emp.category?.includes("Without Bond")
                      ? "Yes"
                      : "No")
                  }
                />
                <Row
                  label="Bond Duration"
                  value={
                    emp.bondDurationMonths
                      ? `${emp.bondDurationMonths} Months`
                      : emp.category?.includes("Bond") && !emp.category?.includes("Without Bond")
                        ? "24 Months"
                        : "0 Months"
                  }
                />
                <Row label="Bond Expiry Date" value={emp.bondExpiryDate || "—"} />
                <Row label="Bond Status" value={emp.bondStatus || "—"} />
              </Grid>
            </div>
          )}

          {/* ── 4. Education & Experience ── */}
          {tab === "education" && (
            <div className="rounded-lg border border-border bg-card p-6 shadow-2xs">
              <Grid>
                <Row label="Graduation Degree" value={emp.gradDegree || "—"} />
                <Row label="Graduation Passing Year" value={emp.gradYear || "—"} />
                <Row
                  label="Post Graduation Degree"
                  value={emp.postGradDegree && emp.postGradDegree !== "NA" ? emp.postGradDegree : "NA"}
                />
                <Row
                  label="Post Graduation Passing Year"
                  value={emp.postGradYear && emp.postGradYear !== "NA" ? emp.postGradYear : "NA"}
                />
                <Row
                  label="Experience Type"
                  value={emp.expType || (emp.experience === "Fresher" ? "Fresher" : "Experienced")}
                />
                <Row
                  label="Total Prior Experience"
                  value={emp.priorTotalExp || emp.experience || "0"}
                />
                <Row
                  label="Relevant Prior Experience"
                  value={emp.priorRelevantExp || "0"}
                />
                <div className="col-span-full border-t border-border pt-4 mt-2">
                  <div className="text-[11px] font-medium uppercase tracking-wider text-muted-foreground mb-2.5">
                    Certifications
                  </div>
                  {emp.certifications && emp.certifications.length > 0 ? (
                    <div className="flex flex-wrap gap-2">
                      {emp.certifications.map((c) => (
                        <span
                          key={c}
                          className="rounded-full border border-primary/20 bg-primary/10 px-3 py-1 text-xs font-semibold text-primary"
                        >
                          {c}
                        </span>
                      ))}
                    </div>
                  ) : (
                    <p className="text-sm text-muted-foreground">—</p>
                  )}
                </div>
              </Grid>
            </div>
          )}

          {/* ── 5. PMO Information ── */}
          {tab === "pmo" && (
            <div className="rounded-lg border border-border bg-card p-6 shadow-2xs">
              <Grid>
                <Row label="PMO Department" value={emp.pmoDepartment} />
                <Row label="PMO Sub-Department" value={emp.subDepartment} />
                <Row label="Billable / Non-Billable Status" value={emp.billableStatus} />
                <Row label="Client Location" value={emp.clientLocation} />
                <Row label="Project Type" value={emp.projectType} />
                <Row label="Project Allocated" value={emp.projectAllocated} />
                <Row label="Client Engagement Manager" value={emp.clientEngManagerMapping} />
              </Grid>
            </div>
          )}


        </div>
      </div>

      {offboardConfirmOpen && (
        <OffboardConfirmDialog
          employee={emp}
          isSubmitting={isOffboarding}
          onConfirm={(details) => void handleOffboard(details)}
          onCancel={() => {
            if (!isOffboarding) setOffboardConfirmOpen(false);
          }}
        />
      )}

      {/* Unified Edit Profile Modal */}
      <EmployeeFormModal
        mode="edit"
        open={editOpen}
        onClose={() => setEditOpen(false)}
        initialEmployee={emp}
        onSuccess={async (saved) => {
          if (saved) {
            setEmp(saved);
            if (saved.id !== emp.id) {
              await navigate({
                to: "/dh-employee-directory/$id",
                params: { id: saved.id },
                replace: true,
              });
            }
          } else {
            try {
              const detail = await fetchEmployee(emp.id);
              setEmp(toUiEmployee(detail));
            } catch {}
          }
        }}
      />
    </AppShell>
  );
}
