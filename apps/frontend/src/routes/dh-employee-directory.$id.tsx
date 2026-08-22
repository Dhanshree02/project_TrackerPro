import { createFileRoute, Link, Navigate, useNavigate } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { X, FileText, ChevronLeft, ChevronRight, AlertTriangle } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useAuth } from "@/lib/auth-context";
import { useRoleContext } from "@/lib/role-context";
import { Avatar, ProgressBar } from "@/components/pills";
import { cn } from "@/lib/utils";
import {
  FIELD_MAX,
  emailError,
  fieldInputCls,
  isoDateToday,
  phoneError,
  toEmailInput,
  toTenDigitPhone,
} from "@/lib/form-validation";
import { toast } from "sonner";
import {
  fetchEmployee,
  offboardEmployee,
  toUiEmployee,
  updateEmployee,
  fetchDepartmentOptions,
  fetchDesignationOptions,
  fetchNationalityOptions,
  fetchJobRoleOptions,
  fetchSalaryBandOptions,
  fetchReportingManagerOptions,
  fetchBusinessUnitOptions,
  fetchWorkLocationOptions,
  fetchOfficeOptions,
  type ApiMetaOption,
} from "@/lib/api/employees";
import { fetchNationalities, type CatalogOption } from "@/lib/api/catalogs";
import { CreatableCatalogSelect, SearchableSelect } from "@/components/creatable-catalog-select";
import {
  departments,
  type Employee,
  type EmployeeStatus,
  type ConfirmationStatus,
  type ComplianceStatus,
} from "@/lib/employee-data";

const getCostCenter = (e: any) => {
  const hoDepts = [
    "Human Resources",
    "Finance",
    "Executive Office",
    "Operations",
    "Marketing",
    "Sales",
  ];
  return hoDepts.includes(e.department) ? "HO" : "Delivery Dept";
};

export const Route = createFileRoute("/dh-employee-directory/$id")({
  head: () => ({
    meta: [
      { title: "Employee Profile — Pulse PMO" },
      { name: "description", content: "View full profile and performance of an employee." },
    ],
  }),
  component: EmployeeProfilePage,
});

// ── helpers ────────────────────────────────────────

function EmpStatusBadge({ status }: { status: string }) {
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
    Compliant: "border-success/30 bg-success/10 text-success",
    "Non-Compliant": "border-destructive/30 bg-destructive/10 text-destructive",
    Verified: "border-success/30 bg-success/10 text-success",
  };
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full border px-2 py-0.5 text-[11px] font-medium",
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
      <div className="mt-1 text-sm text-foreground">
        {value == null || value === "" ? "—" : value}
      </div>
    </div>
  );
}

function Grid({ children }: { children: React.ReactNode }) {
  return <div className="grid grid-cols-1 gap-x-8 md:grid-cols-2 lg:grid-cols-3">{children}</div>;
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
    "h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring";
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

// ── Edit Profile Panel ─────────────────────────────
function EditProfilePanel({
  open,
  onClose,
  employee,
  onSave,
}: {
  open: boolean;
  onClose: () => void;
  employee: Employee;
  onSave: (updated: Employee) => Promise<void>;
}) {
  useEffect(() => {
    if (open) document.body.style.overflow = "hidden";
    else document.body.style.overflow = "";
    return () => {
      document.body.style.overflow = "";
    };
  }, [open]);

  const [formData, setFormData] = useState<Employee>({ ...employee });
  const [isSaving, setIsSaving] = useState(false);

  // Metadata catalogs
  const [nationalities, setNationalities] = useState<ApiMetaOption[]>([]);
  const [departmentsList, setDepartmentsList] = useState<ApiMetaOption[]>([]);
  const [designationsList, setDesignationsList] = useState<ApiMetaOption[]>([]);
  const [businessUnitsList, setBusinessUnitsList] = useState<ApiMetaOption[]>([]);
  const [workLocationsList, setWorkLocationsList] = useState<ApiMetaOption[]>([]);
  const [officesList, setOfficesList] = useState<ApiMetaOption[]>([]);
  const [salaryBandsList, setSalaryBandsList] = useState<ApiMetaOption[]>([]);
  const [reportingManagersList, setReportingManagersList] = useState<ApiMetaOption[]>([]);

  useEffect(() => {
    if (open) {
      setFormData({ ...employee });
      setIsSaving(false);
      void fetchNationalityOptions().then(setNationalities).catch(() => {});
      void fetchDepartmentOptions().then(setDepartmentsList).catch(() => {});
      void fetchBusinessUnitOptions().then(setBusinessUnitsList).catch(() => {});
      void fetchWorkLocationOptions().then(setWorkLocationsList).catch(() => {});
      void fetchSalaryBandOptions().then(setSalaryBandsList).catch(() => {});
      void fetchReportingManagerOptions().then(setReportingManagersList).catch(() => {});
    }
  }, [open, employee]);

  // Scoped designations
  useEffect(() => {
    if (!open) return;
    const currentDept = departmentsList.find((d) => d.name === formData.department);
    void fetchDesignationOptions(currentDept?.id).then(setDesignationsList).catch(() => {});
  }, [open, formData.department, departmentsList]);

  // Scoped office branches
  useEffect(() => {
    if (!open) return;
    const currentLoc = workLocationsList.find((l) => l.name === formData.workLocation);
    void fetchOfficeOptions(currentLoc?.id).then(setOfficesList).catch(() => {});
  }, [open, formData.workLocation, workLocationsList]);

  if (!open) return null;

  const inputCls =
    "h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring text-foreground";

  const handleChange = (field: keyof Employee, value: any) => {
    setFormData((prev) => ({
      ...prev,
      [field]:
        field === "phone" || field === "altPhone" || field === "emergencyContact"
          ? toTenDigitPhone(String(value))
          : field === "pan"
            ? String(value).toUpperCase().replace(/[^A-Z0-9]/g, "").slice(0, 10)
            : field === "pfUan"
              ? String(value).replace(/\D/g, "").slice(0, 12)
              : field === "bankAccount"
                ? String(value).replace(/\D/g, "").slice(0, 18)
                : value,
    }));
  };

  const handleSkillsChange = (val: string) => {
    setFormData((prev) => ({
      ...prev,
      skills: val
        .split(",")
        .map((s) => s.trim())
        .filter(Boolean),
    }));
  };

  const handleLanguagesChange = (val: string) => {
    setFormData((prev) => ({
      ...prev,
      languages: val
        .split(",")
        .map((s) => s.trim())
        .filter(Boolean),
    }));
  };

  const handleCertificationsChange = (val: string) => {
    setFormData((prev) => ({
      ...prev,
      certifications: val
        .split(",")
        .map((s) => s.trim())
        .filter(Boolean),
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    // Required Field Validations
    if (!formData.firstName.trim()) {
      toast.error("First Name is required");
      return;
    }
    if (!formData.lastName.trim()) {
      toast.error("Last Name is required");
      return;
    }
    const mailErr = emailError(formData.email, true);
    if (mailErr) {
      toast.error(mailErr);
      return;
    }
    if (formData.personalEmail) {
      const personalMailErr = emailError(formData.personalEmail);
      if (personalMailErr) {
        toast.error(personalMailErr);
        return;
      }
    }
    const mobileErr = phoneError(formData.phone ?? "");
    if (mobileErr) {
      toast.error(mobileErr);
      return;
    }
    if (formData.altPhone) {
      const altErr = phoneError(formData.altPhone);
      if (altErr) {
        toast.error(`Alternate Contact: ${altErr}`);
        return;
      }
    }
    if (formData.emergencyContact) {
      const emErr = phoneError(formData.emergencyContact);
      if (emErr) {
        toast.error(`Emergency Contact: ${emErr}`);
        return;
      }
    }
    if (!formData.gender) {
      toast.error("Gender is required");
      return;
    }
    if (!formData.dob) {
      toast.error("Date of Birth is required");
      return;
    }
    if (!formData.department) {
      toast.error("Department is required");
      return;
    }
    if (!formData.designation) {
      toast.error("Designation is required");
      return;
    }
    if (!formData.workLocation) {
      toast.error("Work Location is required");
      return;
    }
    if (!formData.officeBranch) {
      toast.error("Office Branch is required");
      return;
    }
    if (!formData.joiningDate) {
      toast.error("Date of Joining is required");
      return;
    }

    setIsSaving(true);
    try {
      await onSave({
        ...formData,
        email: formData.email.trim(),
        personalEmail: (formData.personalEmail ?? "").trim(),
      });
      toast.success("Profile updated successfully!");
      onClose();
    } catch (error: any) {
      toast.error(error?.message ?? "Failed to update employee");
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex justify-end">
      <div className="absolute inset-0 bg-black/40" onClick={onClose} />
      <form
        noValidate
        autoComplete="off"
        onSubmit={handleSubmit}
        className="relative flex h-full w-full max-w-4xl flex-col bg-background shadow-2xl"
      >
        {/* header */}
        <div className="flex items-center justify-between border-b border-border bg-card px-6 py-4">
          <div>
            <h2 className="text-base font-semibold">Edit Employee Profile</h2>
            <p className="text-xs text-muted-foreground">
              Modify records for {employee.firstName} {employee.lastName} ({employee.id}).
            </p>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="rounded-md p-1.5 text-muted-foreground hover:bg-accent"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* scrollable body */}
        <div className="flex-1 space-y-5 overflow-y-auto px-6 py-6">
          {/* Section 1: Personal Info */}
          <section className="rounded-lg border border-border bg-card p-5">
            <h3 className="mb-4 text-sm font-semibold text-foreground">1. Personal Information</h3>
            <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  First Name <span className="text-destructive">*</span>
                </span>
                <input
                  autoComplete="off"
                  type="text"
                  value={formData.firstName}
                  maxLength={FIELD_MAX.firstName}
                  onChange={(e) => handleChange("firstName", e.target.value)}
                  className={inputCls}
                  required
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Last Name <span className="text-destructive">*</span>
                </span>
                <input
                  autoComplete="off"
                  type="text"
                  value={formData.lastName}
                  maxLength={FIELD_MAX.lastName}
                  onChange={(e) => handleChange("lastName", e.target.value)}
                  className={inputCls}
                  required
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Work Email <span className="text-destructive">*</span>
                </span>
                <input
                  type="text"
                  inputMode="email"
                  autoComplete="off"
                  value={formData.email}
                  maxLength={FIELD_MAX.email}
                  onChange={(e) => handleChange("email", toEmailInput(e.target.value))}
                  onBlur={() => handleChange("email", formData.email.trim())}
                  className={fieldInputCls(inputCls, Boolean(emailError(formData.email, true)))}
                  required
                />
                {emailError(formData.email, true) ? (
                  <p className="mt-1 text-[11px] text-destructive">{emailError(formData.email, true)}</p>
                ) : null}
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Personal Email
                </span>
                <input
                  type="text"
                  inputMode="email"
                  autoComplete="off"
                  value={formData.personalEmail}
                  maxLength={FIELD_MAX.email}
                  onChange={(e) => handleChange("personalEmail", toEmailInput(e.target.value))}
                  onBlur={() => handleChange("personalEmail", formData.personalEmail.trim())}
                  className={fieldInputCls(inputCls, Boolean(emailError(formData.personalEmail ?? "")))}
                />
                {emailError(formData.personalEmail ?? "") ? (
                  <p className="mt-1 text-[11px] text-destructive">
                    {emailError(formData.personalEmail ?? "")}
                  </p>
                ) : null}
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Mobile Number <span className="text-destructive">*</span>
                </span>
                <div className="relative flex rounded-md">
                  <span className="inline-flex items-center rounded-l-md border border-r-0 border-input bg-muted px-2.5 text-xs font-semibold text-muted-foreground select-none">
                    +91
                  </span>
                  <input
                    autoComplete="off"
                    type="tel"
                    inputMode="numeric"
                    maxLength={FIELD_MAX.phone}
                    placeholder="9876543210"
                    value={formData.phone}
                    onChange={(e) => handleChange("phone", e.target.value)}
                    className={cn(
                      fieldInputCls(inputCls, Boolean(phoneError(formData.phone ?? ""))),
                      "rounded-l-none",
                    )}
                  />
                </div>
                {phoneError(formData.phone ?? "") ? (
                  <p className="mt-1 text-[11px] text-destructive">{phoneError(formData.phone ?? "")}</p>
                ) : null}
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Alternate Contact
                </span>
                <div className="relative flex rounded-md">
                  <span className="inline-flex items-center rounded-l-md border border-r-0 border-input bg-muted px-2.5 text-xs font-semibold text-muted-foreground select-none">
                    +91
                  </span>
                  <input
                    autoComplete="off"
                    type="tel"
                    inputMode="numeric"
                    maxLength={FIELD_MAX.phone}
                    placeholder="9876543210"
                    value={formData.altPhone}
                    onChange={(e) => handleChange("altPhone", e.target.value)}
                    className={cn(
                      fieldInputCls(inputCls, Boolean(phoneError(formData.altPhone ?? ""))),
                      "rounded-l-none",
                    )}
                  />
                </div>
                {phoneError(formData.altPhone ?? "") ? (
                  <p className="mt-1 text-[11px] text-destructive">
                    {phoneError(formData.altPhone ?? "")}
                  </p>
                ) : null}
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Emergency Contact <span className="text-destructive">*</span>
                </span>
                <div className="relative flex rounded-md">
                  <span className="inline-flex items-center rounded-l-md border border-r-0 border-input bg-muted px-2.5 text-xs font-semibold text-muted-foreground select-none">
                    +91
                  </span>
                  <input
                    autoComplete="off"
                    type="tel"
                    inputMode="numeric"
                    maxLength={FIELD_MAX.phone}
                    placeholder="9876543210"
                    value={formData.emergencyContact}
                    onChange={(e) => handleChange("emergencyContact", e.target.value)}
                    className={cn(
                      fieldInputCls(inputCls, Boolean(phoneError(formData.emergencyContact ?? ""))),
                      "rounded-l-none",
                    )}
                  />
                </div>
                {phoneError(formData.emergencyContact ?? "") ? (
                  <p className="mt-1 text-[11px] text-destructive">
                    {phoneError(formData.emergencyContact ?? "")}
                  </p>
                ) : null}
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Gender <span className="text-destructive">*</span>
                </span>
                <select
                  autoComplete="off"
                  value={formData.gender}
                  onChange={(e) => handleChange("gender", e.target.value)}
                  className={inputCls}
                >
                  <option value="">Select…</option>
                  <option value="Male">Male</option>
                  <option value="Female">Female</option>
                  <option value="Other">Other</option>
                </select>
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Date of Birth <span className="text-destructive">*</span>
                </span>
                <input
                  autoComplete="off"
                  type="date"
                  value={formData.dob}
                  onChange={(e) => handleChange("dob", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Marital Status
                </span>
                <select
                  autoComplete="off"
                  value={formData.maritalStatus}
                  onChange={(e) => handleChange("maritalStatus", e.target.value)}
                  className={inputCls}
                >
                  <option value="Single">Single</option>
                  <option value="Married">Married</option>
                  <option value="Other">Other</option>
                </select>
              </label>
              <SearchableSelect
                label="Nationality"
                required
                options={nationalities.map((n) => ({ value: n.name, label: n.name }))}
                value={formData.nationality}
                onChange={(v) => handleChange("nationality", v)}
                placeholder="Select nationality…"
              />
              <div className="md:col-span-2 lg:col-span-2">
                <label className="block">
                  <span className="mb-1 block text-xs font-medium text-muted-foreground">
                    Address <span className="text-destructive">*</span>
                  </span>
                  <textarea
                    rows={2}
                    autoComplete="off"
                    value={formData.address}
                    maxLength={FIELD_MAX.address}
                    onChange={(e) => handleChange("address", e.target.value)}
                    className={cn(inputCls, "h-auto min-h-[64px] py-2 resize-y leading-relaxed")}
                  />
                </label>
              </div>
            </div>
          </section>

          {/* Section 2: Organization Assignment */}
          <section className="rounded-lg border border-border bg-card p-5">
            <h3 className="mb-4 text-sm font-semibold text-foreground">
              2. Organization Assignment
            </h3>
            <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Employee ID
                </span>
                <input
                  autoComplete="off"
                  type="text"
                  value={formData.id}
                  disabled
                  className={cn(inputCls, "bg-muted cursor-not-allowed font-mono text-xs")}
                />
              </label>

              <SearchableSelect
                label="Department"
                required
                options={departmentsList.map((d) => ({ value: d.name, label: d.name }))}
                value={formData.department}
                onChange={(v) => handleChange("department", v)}
                placeholder="Select department…"
              />

              <SearchableSelect
                label="Designation"
                required
                options={designationsList.map((d) => ({ value: d.name, label: d.name }))}
                value={formData.designation}
                onChange={(v) => handleChange("designation", v)}
                placeholder="Select designation…"
              />

              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Job Role</span>
                <input
                  autoComplete="off"
                  type="text"
                  value={formData.role}
                  onChange={(e) => handleChange("role", e.target.value)}
                  className={inputCls}
                />
              </label>

              <SearchableSelect
                label="Reporting Manager"
                required
                options={reportingManagersList.map((m) => ({ value: m.name, label: m.name }))}
                value={formData.reportingManager}
                onChange={(v) => handleChange("reportingManager", v)}
                placeholder="Select reporting manager…"
              />

              <SearchableSelect
                label="Business Unit"
                options={businessUnitsList.map((b) => ({ value: b.name, label: b.name }))}
                value={formData.businessUnit}
                onChange={(v) => handleChange("businessUnit", v)}
                placeholder="Select business unit…"
              />

              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Team</span>
                <input
                  autoComplete="off"
                  type="text"
                  value={formData.team}
                  onChange={(e) => handleChange("team", e.target.value)}
                  className={inputCls}
                />
              </label>

              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Project Site
                </span>
                <select
                  autoComplete="off"
                  value={formData.projectSite}
                  onChange={(e) => handleChange("projectSite", e.target.value)}
                  className={inputCls}
                >
                  <option value="Onsite">Onsite</option>
                  <option value="Offsite">Offsite</option>
                </select>
              </label>

              <SearchableSelect
                label="Work Location"
                required
                options={workLocationsList.map((l) => ({ value: l.name, label: l.name }))}
                value={formData.workLocation}
                onChange={(v) => handleChange("workLocation", v)}
                placeholder="Select work location…"
              />

              <SearchableSelect
                label="Office Branch"
                required
                options={officesList.map((o) => ({ value: o.name, label: o.name }))}
                value={formData.officeBranch}
                onChange={(v) => handleChange("officeBranch", v)}
                placeholder="Select office branch…"
              />
            </div>
          </section>

          {/* Section 3: Employment Information */}
          <section className="rounded-lg border border-border bg-card p-5">
            <h3 className="mb-4 text-sm font-semibold text-foreground">
              3. Employment Information
            </h3>
            <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Date of Joining <span className="text-destructive">*</span>
                </span>
                <input
                  autoComplete="off"
                  type="date"
                  value={formData.joiningDate}
                  onChange={(e) => handleChange("joiningDate", e.target.value)}
                  className={inputCls}
                  required
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Category
                </span>
                <select
                  autoComplete="off"
                  value={formData.category}
                  onChange={(e) => handleChange("category", e.target.value)}
                  className={inputCls}
                >
                  <option value="Permanent - Bond">Permanent - Bond</option>
                  <option value="Permanent - Without Bond">Permanent - Without Bond</option>
                  <option value="Contract-based">Contract-based</option>
                  <option value="Intern - Paid">Intern - Paid</option>
                  <option value="Intern - Unpaid">Intern - Unpaid</option>
                </select>
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Employment Status <span className="text-destructive">*</span>
                </span>
                <select
                  autoComplete="off"
                  value={formData.status}
                  onChange={(e) => handleChange("status", e.target.value)}
                  className={inputCls}
                >
                  <option value="Active - Probation">Active - Probation</option>
                  <option value="Active">Active</option>
                </select>
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Confirmation Status
                </span>
                <select
                  autoComplete="off"
                  value={formData.confirmationStatus}
                  onChange={(e) => handleChange("confirmationStatus", e.target.value)}
                  className={inputCls}
                >
                  <option value="Active - Probation">Active - Probation</option>
                  <option value="Active">Active</option>
                  <option value="Resignation - Under Review">Resignation - Under Review</option>
                  <option value="Resignation - Accepted">Resignation - Accepted</option>
                  <option value="Inactive - After Onboarding">Inactive - After Onboarding</option>
                </select>
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Employment Type <span className="text-destructive">*</span>
                </span>
                <select
                  autoComplete="off"
                  value={formData.employmentType}
                  onChange={(e) => handleChange("employmentType", e.target.value)}
                  className={inputCls}
                >
                  <option value="Full-time">Full-time</option>
                  <option value="Part-time">Part-time</option>
                  <option value="Contract">Contract</option>
                </select>
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Contract Type
                </span>
                <select
                  autoComplete="off"
                  value={formData.contractType}
                  onChange={(e) => handleChange("contractType", e.target.value)}
                  className={inputCls}
                >
                  <option value="Standard">Standard</option>
                  <option value="Retainer">Retainer</option>
                  <option value="Freelance">Freelance</option>
                  <option value="Consultant">Consultant</option>
                </select>
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Bond Status
                </span>
                <select
                  autoComplete="off"
                  value={formData.bondStatus}
                  onChange={(e) => handleChange("bondStatus", e.target.value)}
                  className={inputCls}
                >
                  <option value="No Bond">No Bond</option>
                  <option value="Yes - 1 Year">Yes - 1 Year</option>
                  <option value="Yes - 2 Years">Yes - 2 Years</option>
                </select>
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Notice Period
                </span>
                <select
                  autoComplete="off"
                  value={formData.noticePeriod}
                  onChange={(e) => handleChange("noticePeriod", e.target.value)}
                  className={inputCls}
                >
                  <option value="15 Days">15 Days</option>
                  <option value="30 Days">30 Days</option>
                  <option value="60 Days">60 Days</option>
                  <option value="90 Days">90 Days</option>
                  <option value="Immediate">Immediate</option>
                </select>
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Asset ID
                </span>
                <input
                  autoComplete="off"
                  type="text"
                  value={formData.assetId}
                  onChange={(e) => handleChange("assetId", e.target.value)}
                  className={inputCls}
                  placeholder="e.g. TK-LAP-1024"
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Probation Status
                </span>
                <select
                  autoComplete="off"
                  value={formData.probationStatus}
                  onChange={(e) => handleChange("probationStatus", e.target.value)}
                  className={inputCls}
                >
                  <option value="Ongoing">Ongoing</option>
                  <option value="Completed">Completed</option>
                  <option value="Not Completed">Not Completed</option>
                </select>
              </label>
            </div>
          </section>

          {/* Section 4: Skills & Qualifications */}
          <section className="rounded-lg border border-border bg-card p-5">
            <h3 className="mb-4 text-sm font-semibold text-foreground">
              4. Skills & Qualifications
            </h3>
            <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
              <label className="block md:col-span-2">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Education / Highest Qualification
                </span>
                <input
                  autoComplete="off"
                  type="text"
                  value={formData.education}
                  onChange={(e) => handleChange("education", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Technical Skills (comma separated)
                </span>
                <input
                  autoComplete="off"
                  type="text"
                  value={formData.skills.join(", ")}
                  onChange={(e) => handleSkillsChange(e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Languages (comma separated)
                </span>
                <input
                  autoComplete="off"
                  type="text"
                  value={formData.languages.join(", ")}
                  onChange={(e) => handleLanguagesChange(e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block md:col-span-2">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Certifications (comma separated)
                </span>
                <input
                  autoComplete="off"
                  type="text"
                  value={formData.certifications.join(", ")}
                  onChange={(e) => handleCertificationsChange(e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Relevant Experience
                </span>
                <input
                  autoComplete="off"
                  type="text"
                  value={formData.experience}
                  onChange={(e) => handleChange("experience", e.target.value)}
                  className={inputCls}
                  placeholder="e.g. 4.5 Years"
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Previous Company
                </span>
                <input
                  autoComplete="off"
                  type="text"
                  value={formData.previousCompany}
                  onChange={(e) => handleChange("previousCompany", e.target.value)}
                  className={inputCls}
                  placeholder="e.g. Infosys Ltd"
                />
              </label>
            </div>
          </section>

          {/* Section 5: Compliance & Financial */}
          <section className="rounded-lg border border-border bg-card p-5">
            <h3 className="mb-4 text-sm font-semibold text-foreground">
              5. Compliance & Financial
            </h3>
            <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  PAN Number <span className="text-destructive">*</span>
                </span>
                <input
                  autoComplete="off"
                  type="text"
                  maxLength={10}
                  placeholder="e.g. ABCDE1234F"
                  value={formData.pan}
                  onChange={(e) => handleChange("pan", e.target.value)}
                  className={inputCls}
                  required
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Bank Account Number <span className="text-destructive">*</span>
                </span>
                <input
                  autoComplete="off"
                  type="text"
                  maxLength={18}
                  placeholder="Enter bank account number"
                  value={formData.bankAccount}
                  onChange={(e) => handleChange("bankAccount", e.target.value)}
                  className={inputCls}
                  required
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  PF/UAN Number
                </span>
                <input
                  autoComplete="off"
                  type="text"
                  maxLength={12}
                  placeholder="Enter 12-digit UAN"
                  value={formData.pfUan}
                  onChange={(e) => handleChange("pfUan", e.target.value)}
                  className={inputCls}
                />
              </label>
              <SearchableSelect
                label="Salary Band"
                required
                options={salaryBandsList.map((s) => ({ value: s.name, label: s.name }))}
                value={formData.salaryBand}
                onChange={(v) => handleChange("salaryBand", v)}
                placeholder="Select salary band…"
              />
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Tax Regime
                </span>
                <select
                  autoComplete="off"
                  value={formData.taxRegime}
                  onChange={(e) => handleChange("taxRegime", e.target.value)}
                  className={inputCls}
                >
                  <option value="New Regime">New Regime</option>
                  <option value="Old Regime">Old Regime</option>
                </select>
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">
                  Compliance Status
                </span>
                <select
                  autoComplete="off"
                  value={formData.complianceStatus}
                  onChange={(e) => handleChange("complianceStatus", e.target.value)}
                  className={inputCls}
                >
                  <option value="Compliant">Compliant</option>
                  <option value="Pending">Pending</option>
                  <option value="Non-Compliant">Non-Compliant</option>
                </select>
              </label>
            </div>
          </section>
        </div>

        {/* footer */}
        <div className="flex items-center justify-end gap-2 border-t border-border bg-card px-6 py-4">
          <button
            type="button"
            onClick={onClose}
            className="rounded-md border border-input bg-card px-4 py-2 text-sm font-medium text-foreground hover:bg-accent"
          >
            Cancel
          </button>
          <button
            type="submit"
            disabled={isSaving}
            className="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-60"
          >
            {isSaving ? "Saving..." : "Save Changes"}
          </button>
        </div>
      </form>
    </div>
  );
}

// ── Tabs config ────────────────────────────────────
const tabs = [
  { id: "basic", label: "Basic Information" },
  { id: "org", label: "Organization Details" },
  { id: "employment", label: "Employment Details" },
  { id: "skills", label: "Skills & Qualifications" },
  { id: "kpi", label: "KPI & Performance" },
  { id: "finance", label: "Financial & Compliance" },
] as const;

// ── Main page ──────────────────────────────────────
function EmployeeProfilePage() {
  const { status: authStatus } = useAuth();
  const { id } = Route.useParams();
  const navigate = useNavigate();
  const { isDhanshree, isHr, isEmployee, isPmFamily, isPmoFamily, isAccounts, isSales } =
    useRoleContext();
  const [emp, setEmp] = useState<Employee | null>(null);
  const [loadError, setLoadError] = useState(false);
  const [tab, setTab] = useState<string>("basic");
  const [isOffboarding, setIsOffboarding] = useState(false);
  const [offboardConfirmOpen, setOffboardConfirmOpen] = useState(false);
  const [editOpen, setEditOpen] = useState(false);
  const [localAssetId, setLocalAssetId] = useState("");
  const [assetTypeInput, setAssetTypeInput] = useState<"TK" | "Customer">("TK");
  const [assetIdInput, setAssetIdInput] = useState("");

  const employeeId = decodeURIComponent(id ?? "").trim();

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
        setLocalAssetId(loaded.assetId);
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
  useEffect(() => {
    if (typeof window !== "undefined" && window.location.hash === "#kpi" && !basicDirectory) {
      setTab("kpi");
    }
  }, [basicDirectory]);

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
            className="mt-4 inline-flex rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
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
        <div className="py-12 text-center text-sm text-muted-foreground">Loading employee…</div>
      </AppShell>
    );
  }

  const handleSaveProfile = async (updatedEmp: Employee) => {
    const [nats, depts, bands] = await Promise.all([
      fetchNationalityOptions().catch(() => []),
      fetchDepartmentOptions().catch(() => []),
      fetchSalaryBandOptions().catch(() => []),
    ]);
    const nationalityId = nats.find((n) => n.name === updatedEmp.nationality)?.id ?? null;
    const departmentId = depts.find((d) => d.name === updatedEmp.department)?.id ?? null;
    const desigs = departmentId ? await fetchDesignationOptions(departmentId).catch(() => []) : [];
    const designationId = desigs.find((d) => d.name === updatedEmp.designation)?.id ?? null;
    const salaryBandId = bands.find((b) => b.name === updatedEmp.salaryBand)?.id ?? null;

    const saved = await updateEmployee(updatedEmp.id, {
      firstName: updatedEmp.firstName,
      lastName: updatedEmp.lastName,
      workEmail: updatedEmp.email.trim(),
      personalEmail: updatedEmp.personalEmail.trim() || null,
      phone: updatedEmp.phone || null,
      altPhone: updatedEmp.altPhone || null,
      gender: updatedEmp.gender || null,
      dateOfBirth: updatedEmp.dob || null,
      address: updatedEmp.address || null,
      emergencyContact: updatedEmp.emergencyContact || null,
      maritalStatus: updatedEmp.maritalStatus || null,
      nationality: updatedEmp.nationality || null,
      nationalityId,
      department: updatedEmp.department || null,
      departmentId,
      designation: updatedEmp.designation || null,
      designationId,
      role: updatedEmp.role || null,
      businessUnit: updatedEmp.businessUnit || null,
      workLocation: updatedEmp.workLocation || null,
      officeBranch: updatedEmp.officeBranch || null,
      category: updatedEmp.category || null,
      team: updatedEmp.team || null,
      joiningDate: updatedEmp.joiningDate || null,
      status: updatedEmp.status,
      confirmationStatus: updatedEmp.confirmationStatus,
      probationStatus: updatedEmp.probationStatus || null,
      experience: updatedEmp.experience || null,
      previousCompany: updatedEmp.previousCompany || null,
      employmentType: updatedEmp.employmentType || null,
      contractType: updatedEmp.contractType || null,
      bondStatus: updatedEmp.bondStatus || null,
      noticePeriod: updatedEmp.noticePeriod || null,
      projectSite: updatedEmp.projectSite || null,
      assetId: updatedEmp.assetId || null,
      exitType: updatedEmp.exitType || null,
      exitReason: updatedEmp.exitReason || null,
      education: updatedEmp.education || null,
      skills: updatedEmp.skills,
      certifications: updatedEmp.certifications,
      languages: updatedEmp.languages,
      kpiScore: updatedEmp.kpiScore,
      quarterlyKpi: updatedEmp.quarterlyKpi,
      annualRating: updatedEmp.annualRating,
      goalCompletion: updatedEmp.goalCompletion,
      attendance: updatedEmp.attendance,
      reportingEfficiency: updatedEmp.reportingEfficiency,
      promotionReadiness: updatedEmp.promotionReadiness || null,
      managerFeedback: updatedEmp.managerFeedback || null,
      pan: updatedEmp.pan || null,
      bankAccount: updatedEmp.bankAccount || null,
      salaryBand: updatedEmp.salaryBand || null,
      salaryBandId,
      pfUan: updatedEmp.pfUan || null,
      taxRegime: updatedEmp.taxRegime || null,
      complianceStatus: updatedEmp.complianceStatus,
    });

    setEmp(toUiEmployee(saved));
    setLocalAssetId(toUiEmployee(saved).assetId);
  };

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
  const visibleTabs = basicOnly ? tabs.filter((t) => t.id === "basic") : tabs;

  return (
    <AppShell
      title={`${emp.firstName} ${emp.lastName}`}
      subtitle={`${emp.designation} · ${emp.department}`}
    >
      {/* Breadcrumb */}
      <div className="mb-4 flex items-center gap-2 text-xs text-muted-foreground">
        <Link to="/dh-employee-directory" className="hover:text-foreground transition-colors">
          Employee Directory
        </Link>
        <span>/</span>
        <span className="text-foreground">
          {emp.firstName} {emp.lastName}
        </span>
      </div>

      {/* Profile header */}
      <div className="rounded-xl border border-border bg-card p-6">
        <div className="flex flex-wrap items-start justify-between gap-4">
          <div className="flex items-start gap-4">
            <Avatar name={`${emp.firstName} ${emp.lastName}`} size={52} />
            <div>
              <div className="flex flex-wrap items-center gap-3">
                <h1 className="text-xl font-semibold tracking-tight">
                  {emp.firstName} {emp.lastName}
                </h1>
                <div className="flex flex-wrap items-center gap-2">
                  <EmpStatusBadge status={emp.status} />
                  {/* <span className={cn(
                    "inline-flex items-center rounded-full border px-2 py-0.5 text-[11px] font-medium",
                    emp.projectSite === "Onsite"
                      ? "border-info/30 bg-info/10 text-info"
                      : "border-muted-foreground/30 bg-muted text-muted-foreground"
                  )}>
                    {emp.projectSite}
                  </span> */}
                  <span className="inline-flex items-center rounded-full border border-primary/30 bg-primary/10 px-2 py-0.5 text-[11px] font-medium text-primary">
                    {emp.category}
                  </span>
                </div>
              </div>
              <div className="mt-1 text-sm text-muted-foreground">
                {emp.designation} · {emp.department}
              </div>
              <div className="mt-2 flex flex-wrap gap-x-5 gap-y-1.5 text-xs text-muted-foreground">
                <span>
                  ID: <span className="font-mono text-foreground">{emp.id}</span>
                </span>
                <span>Email: {emp.email}</span>
                <span>
                  Project Site:{" "}
                  <span className="font-medium text-foreground">{emp.projectSite}</span>
                </span>
                <span>
                  Location: <span className="font-medium text-foreground">{emp.workLocation}</span>
                </span>
                <span>
                  Reporting Manager:{" "}
                  <span className="font-medium text-foreground">{emp.reportingManager}</span>
                </span>
                <span>
                  Cost Center:{" "}
                  <span className="font-medium text-foreground">{getCostCenter(emp)}</span>
                </span>
              </div>
            </div>
          </div>
          {!basicOnly && (
            <div className="flex flex-wrap gap-2">
              <button
                onClick={() => setEditOpen(true)}
                className="rounded-md border border-input bg-card px-3 py-2 text-sm font-medium hover:bg-accent"
              >
                Edit Profile
              </button>
              <button className="rounded-md border border-input bg-card px-3 py-2 text-sm font-medium hover:bg-accent">
                Generate Report
              </button>
              <button
                type="button"
                onClick={() => setOffboardConfirmOpen(true)}
                disabled={isOffboarding || emp.status === "Notice Period"}
                className="rounded-md bg-destructive px-3 py-2 text-sm font-medium text-destructive-foreground hover:bg-destructive/90 disabled:opacity-60"
              >
                {emp.status === "Notice Period" ? "On Notice Period" : "Offboard Employee"}
              </button>
            </div>
          )}
        </div>
      </div>

      {/* Tabs */}
      <div className="mt-6">
        <div className="flex flex-wrap gap-1 border-b border-border overflow-x-auto">
          {visibleTabs.map((t) => (
            <button
              key={t.id}
              onClick={() => setTab(t.id)}
              className={cn(
                "relative -mb-px whitespace-nowrap px-4 py-2.5 text-sm font-medium transition-colors",
                tab === t.id
                  ? "border-b-2 border-primary text-foreground"
                  : "text-muted-foreground hover:text-foreground",
              )}
            >
              {t.label}
            </button>
          ))}
        </div>

        <div className="mt-5">
          {/* ── Basic ────────── */}
          {tab === "basic" && (
            <div className="rounded-lg border border-border bg-card p-6">
              <Grid>
                <Row label="Employee ID" value={emp.id} />
                <Row label="First Name" value={emp.firstName} />
                <Row label="Last Name" value={emp.lastName} />
                <Row label="Email ID" value={emp.email} />
                <Row label="Personal Email" value={emp.personalEmail} />
                <Row label="Contact Number" value={emp.phone ? `+91 ${emp.phone}` : "—"} />
                <Row label="Alternate Contact" value={emp.altPhone ? `+91 ${emp.altPhone}` : "—"} />
                <Row label="Gender" value={emp.gender} />
                <Row label="Date of Birth" value={emp.dob} />
                <Row label="Address" value={emp.address} />
                <Row label="Emergency Contact" value={emp.emergencyContact ? `+91 ${emp.emergencyContact}` : "—"} />
                <Row label="Marital Status" value={emp.maritalStatus} />
                <Row label="Nationality" value={emp.nationality} />
                <Row label="Employment Status" value={<EmpStatusBadge status={emp.status} />} />
              </Grid>
            </div>
          )}

          {/* ── Organization ── */}
          {tab === "org" && (
            <div className="rounded-lg border border-border bg-card p-6">
              <Grid>
                <Row label="Department" value={emp.department} />
                <Row label="Designation" value={emp.designation} />
                <Row label="Role" value={emp.role} />
                <Row label="Reporting Manager" value={emp.reportingManager} />
                <Row label="Business Unit" value={emp.businessUnit} />
                <Row label="Work Location" value={emp.workLocation} />
                <Row label="Office" value={emp.officeBranch} />
                <Row label="Employee Category" value={emp.category} />
                <Row label="Team Name" value={emp.team} />
              </Grid>
            </div>
          )}

          {/* ── Employment ──── */}
          {tab === "employment" && (
            <div className="rounded-lg border border-border bg-card p-6">
              <Grid>
                <Row label="Date of Joining" value={emp.joiningDate || "—"} />
                <Row
                  label="Employment Status"
                  value={<EmpStatusBadge status={emp.confirmationStatus} />}
                />
                <Row
                  label="Asset ID"
                  value={
                    localAssetId && localAssetId !== "None" ? (
                      <span className="font-semibold text-foreground">{localAssetId}</span>
                    ) : (
                      <div className="flex items-center gap-1.5 mt-1">
                        <select
                          value={assetTypeInput}
                          onChange={(e) => setAssetTypeInput(e.target.value as "TK" | "Customer")}
                          className="h-8 rounded-md border border-input bg-card px-2 text-xs outline-none focus-visible:ring-1 focus-visible:ring-ring text-foreground"
                        >
                          <option value="TK">TK Asset</option>
                          <option value="Customer">Customer Asset</option>
                        </select>
                        <input
                          type="text"
                          placeholder="Enter ID (e.g. 8831)..."
                          value={assetIdInput}
                          onChange={(e) => setAssetIdInput(e.target.value)}
                          className="h-8 w-32 rounded-md border border-input bg-card px-2.5 text-xs outline-none focus-visible:ring-1 focus-visible:ring-ring text-foreground"
                        />
                        <button
                          onClick={() => {
                            if (assetIdInput.trim()) {
                              setLocalAssetId(
                                `${assetTypeInput === "TK" ? "TK" : "Customer"}-${assetIdInput.trim()}`,
                              );
                            }
                          }}
                          className="rounded bg-primary px-2.5 py-1 text-[11px] font-medium text-primary-foreground hover:bg-primary/90"
                        >
                          Assign
                        </button>
                      </div>
                    )
                  }
                />
                <Row label="Exit Type" value={emp.exitType} />
                <Row label="Exit Comment" value={emp.exitReason} />
                <Row label="Probation Status" value={emp.probationStatus} />
                <Row label="Experience" value={emp.experience} />
                <Row label="Previous Company" value={emp.previousCompany} />
                <Row label="Employment Type" value={emp.employmentType} />
                <Row label="Contract Type" value={emp.contractType} />
                <Row label="Bond Status" value={emp.bondStatus} />
                <Row label="Notice Period" value={emp.noticePeriod} />
              </Grid>
            </div>
          )}

          {/* ── Skills ─────── */}
          {tab === "skills" && (
            <div className="space-y-4">
              <div className="rounded-lg border border-border bg-card p-6">
                <h3 className="mb-3 text-sm font-semibold">Education</h3>
                <div className="text-sm text-foreground">{emp.education}</div>
              </div>
              <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                <div className="rounded-lg border border-border bg-card p-6">
                  <h3 className="mb-3 text-sm font-semibold">Technical Skills</h3>
                  <div className="flex flex-wrap gap-2">
                    {emp.skills.length === 0 ? (
                      <span className="text-sm text-muted-foreground">—</span>
                    ) : (
                      emp.skills.map((s) => (
                        <span
                          key={s}
                          className="rounded-full border border-border bg-muted px-2.5 py-1 text-xs font-medium"
                        >
                          {s}
                        </span>
                      ))
                    )}
                  </div>
                </div>
                <div className="rounded-lg border border-border bg-card p-6">
                  <h3 className="mb-3 text-sm font-semibold">Functional Skills</h3>
                  <div className="flex flex-wrap gap-2">
                    <span className="text-sm text-muted-foreground">—</span>
                  </div>
                </div>
                <div className="rounded-lg border border-border bg-card p-6">
                  <h3 className="mb-3 text-sm font-semibold">Certifications</h3>
                  {emp.certifications.length === 0 ? (
                    <span className="text-sm text-muted-foreground">—</span>
                  ) : (
                    <ul className="space-y-1.5 text-sm">
                      {emp.certifications.map((c) => (
                        <li key={c} className="flex items-center gap-2 text-foreground">
                          <span className="h-1 w-1 rounded-full bg-primary" />
                          {c}
                        </li>
                      ))}
                    </ul>
                  )}
                </div>
                <div className="rounded-lg border border-border bg-card p-6">
                  <h3 className="mb-3 text-sm font-semibold">Languages Known</h3>
                  <div className="flex flex-wrap gap-2">
                    {emp.languages.length === 0 ? (
                      <span className="text-sm text-muted-foreground">—</span>
                    ) : (
                      emp.languages.map((l) => (
                        <span
                          key={l}
                          className="rounded-full border border-border bg-muted px-2.5 py-1 text-xs font-medium"
                        >
                          {l}
                        </span>
                      ))
                    )}
                  </div>
                </div>
                <div className="rounded-lg border border-border bg-card p-6 md:col-span-2">
                  <h3 className="mb-3 text-sm font-semibold">Training Programs</h3>
                  <ul className="space-y-2 text-sm">
                    {[
                      "Leadership Foundations · Completed Mar 2025",
                      "Advanced Cloud Architecture · Completed Aug 2024",
                      "Inclusive Hiring · In Progress",
                    ].map((t) => (
                      <li
                        key={t}
                        className="flex justify-between border-b border-border pb-2 last:border-0 last:pb-0 text-foreground"
                      >
                        {t}
                      </li>
                    ))}
                  </ul>
                </div>
              </div>
            </div>
          )}

          {/* ── KPI ──────────── */}
          {tab === "kpi" && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4 md:grid-cols-4">
                {[
                  { l: "Quarterly KPI", v: `${emp.quarterlyKpi}/100` },
                  { l: "Annual Rating", v: `${emp.annualRating}/5` },
                  { l: "Goal Completion", v: `${emp.goalCompletion}%` },
                  { l: "Attendance", v: `${emp.attendance}%` },
                  { l: "Reporting Efficiency", v: `${emp.reportingEfficiency}%` },
                  { l: "Promotion Readiness", v: emp.promotionReadiness },
                ].map((k) => (
                  <div key={k.l} className="rounded-lg border border-border bg-card p-4">
                    <div className="text-[11px] uppercase tracking-wider text-muted-foreground">
                      {k.l}
                    </div>
                    <div className="mt-2 text-xl font-semibold">{k.v}</div>
                  </div>
                ))}
              </div>

              <div className="rounded-lg border border-border bg-card p-5">
                <h3 className="text-sm font-semibold">KPI Trend</h3>
                <div className="mt-4 h-56">
                  <svg viewBox="0 0 400 200" className="h-full w-full">
                    {/* grid lines */}
                    {[0, 50, 100, 150, 200].map((y) => (
                      <line
                        key={y}
                        x1="0"
                        y1={y}
                        x2="400"
                        y2={y}
                        className="stroke-border"
                        strokeWidth="0.5"
                      />
                    ))}
                    <polyline
                      fill="none"
                      className="stroke-primary"
                      strokeWidth="2.5"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      points="0,150 50,130 100,120 150,90 200,100 250,70 300,80 350,55 400,40"
                    />
                    {[150, 130, 120, 90, 100, 70, 80, 55, 40].map((y, i) => (
                      <circle key={i} cx={i * 50} cy={y} r="3.5" className="fill-primary" />
                    ))}
                  </svg>
                </div>
              </div>

              <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                <div className="rounded-lg border border-border bg-card p-5">
                  <h3 className="mb-3 text-sm font-semibold">Manager Feedback</h3>
                  <p className="text-sm text-muted-foreground leading-relaxed">
                    {emp.managerFeedback}
                  </p>
                </div>
                <div className="rounded-lg border border-border bg-card p-5">
                  <h3 className="mb-3 text-sm font-semibold">Performance History</h3>
                  <ol className="relative border-l-2 border-border pl-4 space-y-4">
                    {[
                      { q: "Q1 2026", v: "Exceeded · 92" },
                      { q: "Q4 2025", v: "Met · 85" },
                      { q: "Q3 2025", v: "Met · 81" },
                      { q: "Q2 2025", v: "Developing · 74" },
                    ].map((p) => (
                      <li key={p.q} className="relative">
                        <span className="absolute -left-[1.3rem] top-0.5 h-3 w-3 rounded-full bg-primary ring-2 ring-card" />
                        <div className="text-xs text-muted-foreground">{p.q}</div>
                        <div className="text-sm font-medium">{p.v}</div>
                      </li>
                    ))}
                  </ol>
                </div>
              </div>
            </div>
          )}

          {/* ── Finance ─────── */}
          {tab === "finance" && (
            <div className="rounded-lg border border-border bg-card p-6">
              <Grid>
                <Row label="PAN Number" value={emp.pan} />
                <Row label="Bank Account" value={emp.bankAccount} />
                <Row label="Salary Band" value={emp.salaryBand} />
                <Row label="PF/UAN Number" value={emp.pfUan} />
                <Row label="Tax Regime" value={emp.taxRegime} />
                <Row
                  label="Compliance Status"
                  value={<EmpStatusBadge status={emp.complianceStatus} />}
                />
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

      {/* Edit Profile panel */}
      <EditProfilePanel
        open={editOpen}
        onClose={() => setEditOpen(false)}
        employee={emp}
        onSave={handleSaveProfile}
      />
    </AppShell>
  );
}

// ── Employee Calendar Component ───────────────────
interface CalendarOverride {
  type: "Working" | "W-OFF" | "Leave" | "Holiday";
  shift?: string;
  leaveType?: string;
  reason?: string;
}

function EmployeeCalendar({
  emp,
  onUpdateEmp,
}: {
  emp: Employee;
  onUpdateEmp: (updated: Employee) => void;
}) {
  const [currentYear, setCurrentYear] = useState(2026);
  const [currentMonth, setCurrentMonth] = useState(5); // June (0-indexed)

  const [selectedDate, setSelectedDate] = useState<Date | null>(null);
  const [isDayModalOpen, setIsDayModalOpen] = useState(false);
  const [isShiftModalOpen, setIsShiftModalOpen] = useState(false);
  const [isWeeklyOffModalOpen, setIsWeeklyOffModalOpen] = useState(false);

  // Form states for Manage Day details modal
  const [dayType, setDayType] = useState<"Working" | "W-OFF" | "Leave" | "Holiday">("Working");
  const [shiftTiming, setShiftTiming] = useState("9:30 AM - 7:00 PM");
  const [leaveType, setLeaveType] = useState("Casual Leave");
  const [reason, setReason] = useState("");

  // Form states for Request Shift Change modal
  const [reqShiftDate, setReqShiftDate] = useState("2026-06-01");
  const [reqShiftNew, setReqShiftNew] = useState("9:30 AM - 7:00 PM");
  const [reqShiftReason, setReqShiftReason] = useState("");

  // Form states for Request Weekly Off modal
  const [reqWOffDate, setReqWOffDate] = useState("2026-06-06");
  const [reqWOffReason, setReqWOffReason] = useState("");

  const monthsList = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  const handlePrevMonth = () => {
    if (currentMonth === 0) {
      setCurrentMonth(11);
      setCurrentYear(currentYear - 1);
    } else {
      setCurrentMonth(currentMonth - 1);
    }
  };

  const handleNextMonth = () => {
    if (currentMonth === 11) {
      setCurrentMonth(0);
      setCurrentYear(currentYear + 1);
    } else {
      setCurrentMonth(currentMonth + 1);
    }
  };

  // Generate calendar days
  const daysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate();
  const startDay = new Date(currentYear, currentMonth, 1).getDay();
  // Mon = 0, Tue = 1, ..., Sun = 6
  const adjustedStartDay = startDay === 0 ? 6 : startDay - 1;

  const daysGrid: (number | null)[] = [];
  for (let i = 0; i < adjustedStartDay; i++) {
    daysGrid.push(null);
  }
  for (let i = 1; i <= daysInMonth; i++) {
    daysGrid.push(i);
  }

  // Handle click on day cell
  const handleDayClick = (dayNum: number) => {
    const dateStr = `${currentYear}-${String(currentMonth + 1).padStart(2, "0")}-${String(dayNum).padStart(2, "0")}`;
    const dateObj = new Date(currentYear, currentMonth, dayNum);
    setSelectedDate(dateObj);

    // Load existing override or default
    const existing = emp.calendarOverrides?.[dateStr];
    if (existing) {
      setDayType(existing.type);
      setShiftTiming(existing.shift || "9:30 AM - 7:00 PM");
      setLeaveType(existing.leaveType || "Casual Leave");
      setReason(existing.reason || "");
    } else {
      // Default: Sat/Sun are W-OFF, others Working
      const isWeekend = dateObj.getDay() === 0 || dateObj.getDay() === 6;
      setDayType(isWeekend ? "W-OFF" : "Working");
      setShiftTiming("9:30 AM - 7:00 PM");
      setLeaveType("Casual Leave");
      setReason("");
    }
    setIsDayModalOpen(true);
  };

  // Save day override
  const handleSaveDayOverride = (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedDate) return;

    const dateStr = `${selectedDate.getFullYear()}-${String(selectedDate.getMonth() + 1).padStart(2, "0")}-${String(selectedDate.getDate()).padStart(2, "0")}`;

    const newOverrides = { ...(emp.calendarOverrides || {}) };
    newOverrides[dateStr] = {
      type: dayType,
      shift: dayType === "Working" ? shiftTiming : undefined,
      leaveType: dayType === "Leave" ? leaveType : undefined,
      reason: reason.trim() ? reason : undefined,
    };

    onUpdateEmp({
      ...emp,
      calendarOverrides: newOverrides,
    });

    toast.success(
      `Calendar updated for ${monthsList[selectedDate.getMonth()]} ${selectedDate.getDate()}, ${selectedDate.getFullYear()}`,
    );
    setIsDayModalOpen(false);
  };

  // Reset day override to default
  const handleResetDayOverride = () => {
    if (!selectedDate) return;
    const dateStr = `${selectedDate.getFullYear()}-${String(selectedDate.getMonth() + 1).padStart(2, "0")}-${String(selectedDate.getDate()).padStart(2, "0")}`;

    const newOverrides = { ...(emp.calendarOverrides || {}) };
    delete newOverrides[dateStr];

    onUpdateEmp({
      ...emp,
      calendarOverrides: newOverrides,
    });

    toast.success("Reset to schedule defaults");
    setIsDayModalOpen(false);
  };

  // Submit Shift Change Request
  const handleShiftRequestSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const dateStr = reqShiftDate;
    const newOverrides = { ...(emp.calendarOverrides || {}) };
    newOverrides[dateStr] = {
      type: "Working",
      shift: reqShiftNew,
      reason: `[Shift Request] ${reqShiftReason}`,
    };
    onUpdateEmp({
      ...emp,
      calendarOverrides: newOverrides,
    });

    toast.success("Shift change request submitted and updated successfully!");
    setIsShiftModalOpen(false);
    setReqShiftReason("");
  };

  // Submit Weekly Off Request
  const handleWeeklyOffRequestSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const dateStr = reqWOffDate;
    const newOverrides = { ...(emp.calendarOverrides || {}) };
    newOverrides[dateStr] = {
      type: "W-OFF",
      reason: `[W-OFF Request] ${reqWOffReason}`,
    };
    onUpdateEmp({
      ...emp,
      calendarOverrides: newOverrides,
    });

    toast.success("Weekly off request submitted and updated successfully!");
    setIsWeeklyOffModalOpen(false);
    setReqWOffReason("");
  };

  const getDayInfo = (dayNum: number) => {
    const dateStr = `${currentYear}-${String(currentMonth + 1).padStart(2, "0")}-${String(dayNum).padStart(2, "0")}`;
    const dateObj = new Date(currentYear, currentMonth, dayNum);
    const override = emp.calendarOverrides?.[dateStr];

    if (override) {
      return override;
    }

    const isWeekend = dateObj.getDay() === 0 || dateObj.getDay() === 6;
    return {
      type: isWeekend ? ("W-OFF" as const) : ("Working" as const),
      shift: isWeekend ? undefined : "9:30 AM - 7:00 PM",
    };
  };

  return (
    <div className="space-y-6">
      {/* Calendar Card */}
      <div className="rounded-xl border border-border bg-card p-6 shadow-sm">
        {/* Calendar Header */}
        <div className="mb-6 flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center gap-2">
            <button
              onClick={handlePrevMonth}
              className="rounded-md border border-input bg-card p-2 hover:bg-accent text-foreground transition-colors"
            >
              <ChevronLeft className="h-4 w-4" />
            </button>
            <div className="relative">
              <select
                autoComplete="off"
                value={currentMonth}
                onChange={(e) => setCurrentMonth(Number(e.target.value))}
                className="h-9 rounded-md border border-input bg-card px-3 text-sm font-semibold outline-none focus:ring-1 focus:ring-ring text-foreground pr-8 appearance-none"
              >
                {monthsList.map((m, idx) => (
                  <option key={m} value={idx}>
                    {m}
                  </option>
                ))}
              </select>
              <select
                autoComplete="off"
                value={currentYear}
                onChange={(e) => setCurrentYear(Number(e.target.value))}
                className="h-9 ml-1.5 rounded-md border border-input bg-card px-3 text-sm font-semibold outline-none focus:ring-1 focus:ring-ring text-foreground"
              >
                {[2024, 2025, 2026, 2027, 2028].map((y) => (
                  <option key={y} value={y}>
                    {y}
                  </option>
                ))}
              </select>
            </div>
            <button
              onClick={handleNextMonth}
              className="rounded-md border border-input bg-card p-2 hover:bg-accent text-foreground transition-colors"
            >
              <ChevronRight className="h-4 w-4" />
            </button>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={() => {
                setReqShiftDate(`${currentYear}-${String(currentMonth + 1).padStart(2, "0")}-01`);
                setIsShiftModalOpen(true);
              }}
              className="rounded-md border border-primary/20 bg-primary/5 px-4 py-2 text-xs font-semibold text-primary hover:bg-primary/10 transition-all"
            >
              Request shift change
            </button>
            <button
              onClick={() => {
                setReqWOffDate(`${currentYear}-${String(currentMonth + 1).padStart(2, "0")}-06`);
                setIsWeeklyOffModalOpen(true);
              }}
              className="rounded-md border border-primary/20 bg-primary/5 px-4 py-2 text-xs font-semibold text-primary hover:bg-primary/10 transition-all"
            >
              Request weekly off
            </button>
          </div>
        </div>

        {/* Days of Week Header */}
        <div className="grid grid-cols-7 border border-border bg-muted/30 text-center rounded-t-lg">
          {["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"].map((d) => (
            <div
              key={d}
              className="py-3 text-xs font-semibold tracking-wider text-muted-foreground border-r border-border last:border-0"
            >
              {d}
            </div>
          ))}
        </div>

        {/* Calendar Monthly Grid */}
        <div className="grid grid-cols-7 border-x border-b border-border divide-y divide-border bg-background rounded-b-lg overflow-hidden">
          {daysGrid.map((dayNum, index) => {
            const colClass =
              "border-r border-border last:border-r-0 min-h-[100px] p-2 relative flex flex-col justify-between group hover:bg-muted/10 transition-all cursor-pointer";

            if (dayNum === null) {
              return (
                <div key={`empty-${index}`} className={cn(colClass, "bg-muted/5 cursor-default")} />
              );
            }

            const dayInfo = getDayInfo(dayNum);
            const isToday = currentYear === 2026 && currentMonth === 5 && dayNum === 26;

            return (
              <div
                key={`day-${dayNum}`}
                onClick={() => handleDayClick(dayNum)}
                className={cn(colClass, isToday && "ring-1 ring-primary/40 bg-primary/[0.01]")}
              >
                {/* Corner Today Indicator Triangle */}
                {isToday && (
                  <div className="absolute bottom-0 left-0 w-0 h-0 border-b-[16px] border-b-primary border-r-[16px] border-r-transparent" />
                )}

                {/* Day number */}
                <div className="flex items-center justify-between">
                  <span
                    className={cn(
                      "text-xs font-semibold",
                      isToday ? "text-primary font-bold text-sm" : "text-foreground/80",
                    )}
                  >
                    {dayNum}
                  </span>

                  {/* Status indicator badges */}
                  {dayInfo.type === "Leave" && (
                    <span className="text-[9px] font-bold text-destructive bg-destructive/10 border border-destructive/20 rounded px-1">
                      LEAVE
                    </span>
                  )}
                  {dayInfo.type === "Holiday" && (
                    <span className="text-[9px] font-bold text-emerald-600 bg-emerald-50 border border-emerald-100 rounded px-1">
                      HOLIDAY
                    </span>
                  )}
                </div>

                {/* Day Details */}
                <div className="mt-4 flex flex-col justify-end">
                  {dayInfo.type === "Working" && (
                    <div className="text-[11px] font-medium text-foreground/70">
                      {dayInfo.shift}
                    </div>
                  )}
                  {dayInfo.type === "W-OFF" && (
                    <div className="self-start inline-flex items-center rounded border border-amber-200/40 bg-amber-100/70 text-amber-700 font-semibold px-2 py-0.5 text-[10px] tracking-wide shadow-sm">
                      W-OFF
                    </div>
                  )}
                  {dayInfo.type === "Leave" && (
                    <div className="text-[10px] text-muted-foreground italic truncate">
                      {dayInfo.leaveType || "On Leave"}
                    </div>
                  )}
                  {dayInfo.type === "Holiday" && (
                    <div className="text-[10px] text-muted-foreground italic truncate">
                      Public Holiday
                    </div>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* ── Modal: Manage Day Details ── */}
      {isDayModalOpen && selectedDate && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-black/40" onClick={() => setIsDayModalOpen(false)} />
          <div
            className="relative w-full max-w-md rounded-xl bg-card border border-border p-6 shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <h3 className="mb-4 text-base font-semibold text-foreground">Manage Day Schedule</h3>
            <p className="mb-4 text-xs text-muted-foreground">
              Configure shift or leave status for{" "}
              <strong>
                {monthsList[selectedDate.getMonth()]} {selectedDate.getDate()},{" "}
                {selectedDate.getFullYear()}
              </strong>
              .
            </p>

            <form autoComplete="off" onSubmit={handleSaveDayOverride} className="space-y-4">
              <label className="block">
                <span className="mb-1.5 block text-xs font-medium text-muted-foreground">
                  Day Status Type
                </span>
                <select
                  autoComplete="off"
                  value={dayType}
                  onChange={(e) => setDayType(e.target.value as any)}
                  className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm text-foreground outline-none focus:ring-1 focus:ring-ring"
                >
                  <option value="Working">Working Day</option>
                  <option value="W-OFF">Weekly Off</option>
                  <option value="Leave">On Leave</option>
                  <option value="Holiday">Holiday</option>
                </select>
              </label>

              {dayType === "Working" && (
                <label className="block">
                  <span className="mb-1.5 block text-xs font-medium text-muted-foreground">
                    Shift Timing
                  </span>
                  <select
                    autoComplete="off"
                    value={shiftTiming}
                    onChange={(e) => setShiftTiming(e.target.value)}
                    className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm text-foreground outline-none focus:ring-1 focus:ring-ring"
                  >
                    <option value="9:30 AM - 7:00 PM">9:30 AM - 7:00 PM (Default Shift)</option>
                    <option value="9:00 AM - 6:00 PM">9:00 AM - 6:00 PM (Early Shift)</option>
                    <option value="12:00 PM - 9:00 PM">12:00 PM - 9:00 PM (Late Shift)</option>
                    <option value="10:00 PM - 6:00 AM">10:00 PM - 6:00 AM (Night Shift)</option>
                  </select>
                </label>
              )}

              {dayType === "Leave" && (
                <label className="block">
                  <span className="mb-1.5 block text-xs font-medium text-muted-foreground">
                    Leave Type
                  </span>
                  <select
                    autoComplete="off"
                    value={leaveType}
                    onChange={(e) => setLeaveType(e.target.value)}
                    className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm text-foreground outline-none focus:ring-1 focus:ring-ring"
                  >
                    <option value="Casual Leave">Casual Leave</option>
                    <option value="Sick Leave">Sick Leave</option>
                    <option value="Earned Leave">Earned Leave</option>
                    <option value="Maternity Leave">Maternity Leave</option>
                    <option value="Paternity Leave">Paternity Leave</option>
                    <option value="LWP (Leave Without Pay)">LWP (Leave Without Pay)</option>
                  </select>
                </label>
              )}

              <label className="block">
                <span className="mb-1.5 block text-xs font-medium text-muted-foreground">
                  Remarks / Reason
                </span>
                <textarea
                  autoComplete="off"
                  value={reason}
                  onChange={(e) => setReason(e.target.value)}
                  placeholder="E.g., Doctor appointment, customer alignment, holiday list update..."
                  className="w-full rounded-md border border-input bg-card p-2 text-sm text-foreground outline-none focus:ring-1 focus:ring-ring h-20"
                />
              </label>

              <div className="flex items-center justify-between border-t border-border pt-4">
                <button
                  type="button"
                  onClick={handleResetDayOverride}
                  className="rounded-md border border-input bg-card px-3 py-2 text-xs font-semibold text-destructive hover:bg-destructive/5 hover:border-destructive/20 transition-all"
                >
                  Reset to Default
                </button>
                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={() => setIsDayModalOpen(false)}
                    className="rounded-md border border-input bg-card px-4 py-2 text-xs font-semibold text-foreground hover:bg-accent"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="rounded-md bg-primary px-4 py-2 text-xs font-semibold text-primary-foreground hover:bg-primary/90"
                  >
                    Save Changes
                  </button>
                </div>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ── Modal: Request Shift Change ── */}
      {isShiftModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div
            className="absolute inset-0 bg-black/40"
            onClick={() => setIsShiftModalOpen(false)}
          />
          <div
            className="relative w-full max-w-md rounded-xl bg-card border border-border p-6 shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <h3 className="mb-4 text-base font-semibold text-foreground">Request Shift Change</h3>
            <p className="mb-4 text-xs text-muted-foreground">
              Submit a formal request to alter the assigned work shift.
            </p>

            <form autoComplete="off" onSubmit={handleShiftRequestSubmit} className="space-y-4">
              <label className="block">
                <span className="mb-1.5 block text-xs font-medium text-muted-foreground">
                  Effective Date
                </span>
                <input
                  autoComplete="off"
                  type="date"
                  value={reqShiftDate}
                  onChange={(e) => setReqShiftDate(e.target.value)}
                  className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm text-foreground outline-none focus:ring-1 focus:ring-ring"
                  required
                />
              </label>

              <label className="block">
                <span className="mb-1.5 block text-xs font-medium text-muted-foreground">
                  Target Work Shift
                </span>
                <select
                  autoComplete="off"
                  value={reqShiftNew}
                  onChange={(e) => setReqShiftNew(e.target.value)}
                  className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm text-foreground outline-none focus:ring-1 focus:ring-ring"
                >
                  <option value="9:30 AM - 7:00 PM">9:30 AM - 7:00 PM (Default Shift)</option>
                  <option value="9:00 AM - 6:00 PM">9:00 AM - 6:00 PM (Early Shift)</option>
                  <option value="12:00 PM - 9:00 PM">12:00 PM - 9:00 PM (Late Shift)</option>
                  <option value="10:00 PM - 6:00 AM">10:00 PM - 6:00 AM (Night Shift)</option>
                </select>
              </label>

              <label className="block">
                <span className="mb-1.5 block text-xs font-medium text-muted-foreground">
                  Reason for Request
                </span>
                <textarea
                  autoComplete="off"
                  value={reqShiftReason}
                  onChange={(e) => setReqShiftReason(e.target.value)}
                  placeholder="Explain why the shift change is required..."
                  className="w-full rounded-md border border-input bg-card p-2 text-sm text-foreground outline-none focus:ring-1 focus:ring-ring h-20"
                  required
                />
              </label>

              <div className="flex items-center justify-end gap-2 border-t border-border pt-4">
                <button
                  type="button"
                  onClick={() => setIsShiftModalOpen(false)}
                  className="rounded-md border border-input bg-card px-4 py-2 text-xs font-semibold text-foreground hover:bg-accent"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="rounded-md bg-primary px-4 py-2 text-xs font-semibold text-primary-foreground hover:bg-primary/90"
                >
                  Submit Request
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ── Modal: Request Weekly Off ── */}
      {isWeeklyOffModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div
            className="absolute inset-0 bg-black/40"
            onClick={() => setIsWeeklyOffModalOpen(false)}
          />
          <div
            className="relative w-full max-w-md rounded-xl bg-card border border-border p-6 shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <h3 className="mb-4 text-base font-semibold text-foreground">Request Weekly Off</h3>
            <p className="mb-4 text-xs text-muted-foreground">
              Submit a request to change the weekly off day.
            </p>

            <form autoComplete="off" onSubmit={handleWeeklyOffRequestSubmit} className="space-y-4">
              <label className="block">
                <span className="mb-1.5 block text-xs font-medium text-muted-foreground">
                  Off Date Requested
                </span>
                <input
                  autoComplete="off"
                  type="date"
                  value={reqWOffDate}
                  onChange={(e) => setReqWOffDate(e.target.value)}
                  className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm text-foreground outline-none focus:ring-1 focus:ring-ring"
                  required
                />
              </label>

              <label className="block">
                <span className="mb-1.5 block text-xs font-medium text-muted-foreground">
                  Reason / Description
                </span>
                <textarea
                  autoComplete="off"
                  value={reqWOffReason}
                  onChange={(e) => setReqWOffReason(e.target.value)}
                  placeholder="Explain why the weekly off change is required..."
                  className="w-full rounded-md border border-input bg-card p-2 text-sm text-foreground outline-none focus:ring-1 focus:ring-ring h-20"
                  required
                />
              </label>

              <div className="flex items-center justify-end gap-2 border-t border-border pt-4">
                <button
                  type="button"
                  onClick={() => setIsWeeklyOffModalOpen(false)}
                  className="rounded-md border border-input bg-card px-4 py-2 text-xs font-semibold text-foreground hover:bg-accent"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="rounded-md bg-primary px-4 py-2 text-xs font-semibold text-primary-foreground hover:bg-primary/90"
                >
                  Submit Request
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
