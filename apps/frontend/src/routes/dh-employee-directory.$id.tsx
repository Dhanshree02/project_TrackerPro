import { createFileRoute, Link, Navigate, notFound } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { X, FileText, ChevronLeft, ChevronRight } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { Avatar, ProgressBar } from "@/components/pills";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import {
  employees,
  departments,
  type Employee,
  type EmployeeStatus,
  type ConfirmationStatus,
  type ComplianceStatus,
} from "@/lib/employee-data";

const getCostCenter = (e: any) => {
  const hoDepts = ["Human Resources", "Finance", "Executive Office", "Operations", "Marketing", "Sales"];
  return hoDepts.includes(e.department) ? "HO" : "Delivery Dept";
};

export const Route = createFileRoute("/dh-employee-directory/$id")({
  head: () => ({
    meta: [
      { title: "Employee Profile — Pulse PMO" },
      { name: "description", content: "View full profile and performance of an employee." },
    ],
  }),
  loader: ({ params }) => {
    const emp = employees.find((e) => e.id === params.id);
    if (!emp) throw notFound();
    return { emp };
  },
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
      <div className="text-[11px] font-medium uppercase tracking-wider text-muted-foreground">{label}</div>
      <div className="mt-1 text-sm text-foreground">{value ?? "—"}</div>
    </div>
  );
}

function Grid({ children }: { children: React.ReactNode }) {
  return <div className="grid grid-cols-1 gap-x-8 md:grid-cols-2 lg:grid-cols-3">{children}</div>;
}

// ── Offboarding modal ──────────────────────────────
function OffboardingModal({ open, onClose, employee }: { open: boolean; onClose: () => void; employee: Employee }) {
  useEffect(() => {
    if (open) document.body.style.overflow = "hidden";
    else document.body.style.overflow = "";
    return () => { document.body.style.overflow = ""; };
  }, [open]);
  if (!open) return null;

  const inputCls = "h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring";

  const checklist = [
    "Manager exit interview scheduled",
    "HR exit interview scheduled",
    "Knowledge transfer document submitted",
    "Access revocation requested",
    "Pending leaves reconciled",
    "Final pay slip generated",
  ];
  const assets = [
    "Laptop · Dell XPS 15",
    "Mobile · iPhone 13",
    "Access Card #A-3392",
    "VPN Token",
    "Office Keys",
  ];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/40" onClick={onClose} />
      <div className="relative flex max-h-[90vh] w-full max-w-3xl flex-col rounded-xl bg-card shadow-2xl" onClick={(e) => e.stopPropagation()}>
        {/* header */}
        <div className="flex items-center justify-between border-b border-border px-6 py-4">
          <div>
            <h2 className="text-base font-semibold">Offboard Employee</h2>
            <p className="text-xs text-muted-foreground">{employee.firstName} {employee.lastName} · {employee.id} · {employee.department}</p>
          </div>
          <button onClick={onClose} className="rounded-md p-1.5 text-muted-foreground hover:bg-accent">
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* body */}
        <div className="space-y-5 overflow-y-auto px-6 py-5">
          <section>
            <h3 className="mb-3 text-sm font-semibold">Resignation Details</h3>
            <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
              <label className="block"><span className="mb-1 block text-xs font-medium text-muted-foreground">Resignation Date</span><input type="date" className={inputCls} /></label>
              <label className="block"><span className="mb-1 block text-xs font-medium text-muted-foreground">Last Working Day</span><input type="date" className={inputCls} /></label>
              <label className="block"><span className="mb-1 block text-xs font-medium text-muted-foreground">Reason for Leaving</span><input placeholder="Better opportunity" className={inputCls} /></label>
              <label className="block"><span className="mb-1 block text-xs font-medium text-muted-foreground">Notice Period Served</span><input placeholder="60 days" className={inputCls} /></label>
            </div>
          </section>

          <section>
            <h3 className="mb-3 text-sm font-semibold">Exit Checklist</h3>
            <div className="space-y-2 rounded-lg border border-border p-3">
              {checklist.map((c, i) => (
                <label key={c} className="flex items-center gap-3 rounded-md px-2 py-1.5 text-sm hover:bg-accent/30">
                  <input type="checkbox" defaultChecked={i < 3} className="h-4 w-4 rounded border-input" />
                  <span>{c}</span>
                </label>
              ))}
            </div>
          </section>

          <section>
            <h3 className="mb-3 text-sm font-semibold">Asset Return</h3>
            <div className="overflow-hidden rounded-lg border border-border">
              <table className="w-full text-sm">
                <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
                  <tr>
                    <th className="px-3 py-2 font-medium">Asset</th>
                    <th className="px-3 py-2 font-medium">Status</th>
                    <th className="px-3 py-2 font-medium">Returned On</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-border">
                  {assets.map((a, i) => (
                    <tr key={a} className="hover:bg-accent/30">
                      <td className="px-3 py-2">{a}</td>
                      <td className="px-3 py-2">
                        <span className={cn("inline-flex items-center rounded-full border px-2 py-0.5 text-[11px] font-medium",
                          i % 2 ? "border-warning/40 bg-warning/15 text-warning-foreground" : "border-success/30 bg-success/10 text-success"
                        )}>
                          {i % 2 ? "Pending" : "Returned"}
                        </span>
                      </td>
                      <td className="px-3 py-2 text-muted-foreground">{i % 2 ? "—" : "2026-05-22"}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </section>

          <section>
            <h3 className="mb-3 text-sm font-semibold">Final Settlement</h3>
            <div className="grid grid-cols-1 gap-3 md:grid-cols-3">
              {[
                { l: "Pending Salary", v: "₹ 1,24,500", s: "Processing" },
                { l: "Leave Encashment", v: "₹ 38,200", s: "Approved" },
                { l: "Gratuity", v: "₹ 2,15,000", s: "Pending" },
              ].map((x) => (
                <div key={x.l} className="rounded-lg border border-border p-3">
                  <div className="text-xs text-muted-foreground">{x.l}</div>
                  <div className="mt-1 text-base font-semibold">{x.v}</div>
                  <div className="mt-1 text-xs text-muted-foreground">{x.s}</div>
                </div>
              ))}
            </div>
          </section>
        </div>

        {/* footer */}
        <div className="flex items-center justify-end gap-2 border-t border-border px-6 py-4">
          <button onClick={onClose} className="rounded-md border border-input bg-card px-4 py-2 text-sm font-medium text-foreground hover:bg-accent">Cancel</button>
          <button className="rounded-md bg-destructive px-4 py-2 text-sm font-medium text-destructive-foreground hover:bg-destructive/90">Initiate Offboarding</button>
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
  onSave: (updated: Employee) => void;
}) {
  useEffect(() => {
    if (open) document.body.style.overflow = "hidden";
    else document.body.style.overflow = "";
    return () => {
      document.body.style.overflow = "";
    };
  }, [open]);

  const [formData, setFormData] = useState<Employee>({ ...employee });

  useEffect(() => {
    if (open) {
      setFormData({ ...employee });
    }
  }, [open, employee]);

  if (!open) return null;

  const inputCls =
    "h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring text-foreground";

  const handleChange = (field: keyof Employee, value: any) => {
    setFormData((prev) => ({
      ...prev,
      [field]: value,
    }));
  };

  const handleSkillsChange = (val: string) => {
    setFormData((prev) => ({
      ...prev,
      skills: val.split(",").map((s) => s.trim()).filter(Boolean),
    }));
  };

  const handleLanguagesChange = (val: string) => {
    setFormData((prev) => ({
      ...prev,
      languages: val.split(",").map((s) => s.trim()).filter(Boolean),
    }));
  };

  const handleCertificationsChange = (val: string) => {
    setFormData((prev) => ({
      ...prev,
      certifications: val.split(",").map((s) => s.trim()).filter(Boolean),
    }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave(formData);
    toast.success("Profile updated successfully!");
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex justify-end">
      <div className="absolute inset-0 bg-black/40" onClick={onClose} />
      <form
        onSubmit={handleSubmit}
        className="relative flex h-full w-full max-w-4xl flex-col bg-background shadow-2xl"
      >
        {/* header */}
        <div className="flex items-center justify-between border-b border-border bg-card px-6 py-4">
          <div>
            <h2 className="text-base font-semibold">Edit Employee Profile</h2>
            <p className="text-xs text-muted-foreground">
              Modify details for {employee.firstName} {employee.lastName}.
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
                <span className="mb-1 block text-xs font-medium text-muted-foreground">First Name</span>
                <input
                  type="text"
                  value={formData.firstName}
                  onChange={(e) => handleChange("firstName", e.target.value)}
                  className={inputCls}
                  required
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Last Name</span>
                <input
                  type="text"
                  value={formData.lastName}
                  onChange={(e) => handleChange("lastName", e.target.value)}
                  className={inputCls}
                  required
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Email ID</span>
                <input
                  type="email"
                  value={formData.email}
                  onChange={(e) => handleChange("email", e.target.value)}
                  className={inputCls}
                  required
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Personal Email</span>
                <input
                  type="email"
                  value={formData.personalEmail}
                  onChange={(e) => handleChange("personalEmail", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Mobile Number</span>
                <input
                  type="text"
                  value={formData.phone}
                  onChange={(e) => handleChange("phone", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Alternate Contact</span>
                <input
                  type="text"
                  value={formData.altPhone}
                  onChange={(e) => handleChange("altPhone", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Gender</span>
                <select
                  value={formData.gender}
                  onChange={(e) => handleChange("gender", e.target.value)}
                  className={inputCls}
                >
                  <option value="Male">Male</option>
                  <option value="Female">Female</option>
                  <option value="Other">Other</option>
                </select>
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Date of Birth</span>
                <input
                  type="date"
                  value={formData.dob}
                  onChange={(e) => handleChange("dob", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Marital Status</span>
                <select
                  value={formData.maritalStatus}
                  onChange={(e) => handleChange("maritalStatus", e.target.value)}
                  className={inputCls}
                >
                  <option value="Single">Single</option>
                  <option value="Married">Married</option>
                  <option value="Other">Other</option>
                </select>
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Nationality</span>
                <input
                  type="text"
                  value={formData.nationality}
                  onChange={(e) => handleChange("nationality", e.target.value)}
                  className={inputCls}
                />
              </label>
              <div className="md:col-span-2">
                <label className="block">
                  <span className="mb-1 block text-xs font-medium text-muted-foreground">Address</span>
                  <input
                    type="text"
                    value={formData.address}
                    onChange={(e) => handleChange("address", e.target.value)}
                    className={inputCls}
                  />
                </label>
              </div>
            </div>
          </section>

          {/* Section 2: Organization Assignment */}
          <section className="rounded-lg border border-border bg-card p-5">
            <h3 className="mb-4 text-sm font-semibold text-foreground">2. Organization Assignment</h3>
            <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Employee ID</span>
                <input
                  type="text"
                  value={formData.id}
                  disabled
                  className={cn(inputCls, "bg-muted cursor-not-allowed")}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Department</span>
                <select
                  value={formData.department}
                  onChange={(e) => handleChange("department", e.target.value)}
                  className={inputCls}
                >
                  {departments.map((d) => (
                    <option key={d} value={d}>
                      {d}
                    </option>
                  ))}
                </select>
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Designation</span>
                <input
                  type="text"
                  value={formData.designation}
                  onChange={(e) => handleChange("designation", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Role</span>
                <input
                  type="text"
                  value={formData.role}
                  onChange={(e) => handleChange("role", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Reporting Manager</span>
                <input
                  type="text"
                  value={formData.reportingManager}
                  onChange={(e) => handleChange("reportingManager", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Business Unit</span>
                <input
                  type="text"
                  value={formData.businessUnit}
                  onChange={(e) => handleChange("businessUnit", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Team</span>
                <input
                  type="text"
                  value={formData.team}
                  onChange={(e) => handleChange("team", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Project Site</span>
                <select
                  value={formData.projectSite}
                  onChange={(e) => handleChange("projectSite", e.target.value)}
                  className={inputCls}
                >
                  <option value="Onsite">Onsite</option>
                  <option value="Offsite">Offsite</option>
                </select>
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Work Location</span>
                <input
                  type="text"
                  value={formData.workLocation}
                  onChange={(e) => handleChange("workLocation", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Office Branch</span>
                <input
                  type="text"
                  value={formData.officeBranch}
                  onChange={(e) => handleChange("officeBranch", e.target.value)}
                  className={inputCls}
                />
              </label>
            </div>
          </section>

          {/* Section 3: Employment Information */}
          <section className="rounded-lg border border-border bg-card p-5">
            <h3 className="mb-4 text-sm font-semibold text-foreground">3. Employment Information</h3>
            <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Date of Joining</span>
                <input
                  type="date"
                  value={formData.joiningDate}
                  onChange={(e) => handleChange("joiningDate", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Category</span>
                <select
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
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Asset ID</span>
                <input
                  type="text"
                  value={formData.assetId}
                  onChange={(e) => handleChange("assetId", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Employment Status</span>
                <select
                  value={formData.status}
                  onChange={(e) => handleChange("status", e.target.value)}
                  className={inputCls}
                >
                  <option value="Active">Active</option>
                  <option value="Probation">Probation</option>
                  <option value="Notice Period">Notice Period</option>
                  <option value="Inactive">Inactive</option>
                  <option value="On Leave">On Leave</option>
                </select>
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Confirmation Status</span>
                <select
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
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Probation Status</span>
                <input
                  type="text"
                  value={formData.probationStatus}
                  onChange={(e) => handleChange("probationStatus", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Notice Period</span>
                <input
                  type="text"
                  value={formData.noticePeriod}
                  onChange={(e) => handleChange("noticePeriod", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Salary Band</span>
                <input
                  type="text"
                  value={formData.salaryBand}
                  onChange={(e) => handleChange("salaryBand", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Experience</span>
                <input
                  type="text"
                  value={formData.experience}
                  onChange={(e) => handleChange("experience", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Previous Company</span>
                <input
                  type="text"
                  value={formData.previousCompany}
                  onChange={(e) => handleChange("previousCompany", e.target.value)}
                  className={inputCls}
                />
              </label>
            </div>
          </section>

          {/* Section 4: Skills & Qualifications */}
          <section className="rounded-lg border border-border bg-card p-5">
            <h3 className="mb-4 text-sm font-semibold text-foreground">4. Skills & Qualifications</h3>
            <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
              <label className="block md:col-span-2">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Education / Highest Qualification</span>
                <input
                  type="text"
                  value={formData.education}
                  onChange={(e) => handleChange("education", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Technical Skills (comma separated)</span>
                <input
                  type="text"
                  value={formData.skills.join(", ")}
                  onChange={(e) => handleSkillsChange(e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Languages (comma separated)</span>
                <input
                  type="text"
                  value={formData.languages.join(", ")}
                  onChange={(e) => handleLanguagesChange(e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block md:col-span-2">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Certifications (comma separated)</span>
                <input
                  type="text"
                  value={formData.certifications.join(", ")}
                  onChange={(e) => handleCertificationsChange(e.target.value)}
                  className={inputCls}
                />
              </label>
            </div>
          </section>

          {/* Section 5: Compliance & Financial */}
          <section className="rounded-lg border border-border bg-card p-5">
            <h3 className="mb-4 text-sm font-semibold text-foreground">5. Compliance & Financial</h3>
            <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">PAN Number</span>
                <input
                  type="text"
                  value={formData.pan}
                  onChange={(e) => handleChange("pan", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Bank Account Number</span>
                <input
                  type="text"
                  value={formData.bankAccount}
                  onChange={(e) => handleChange("bankAccount", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">PF/UAN Number</span>
                <input
                  type="text"
                  value={formData.pfUan}
                  onChange={(e) => handleChange("pfUan", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Tax Regime</span>
                <input
                  type="text"
                  value={formData.taxRegime}
                  onChange={(e) => handleChange("taxRegime", e.target.value)}
                  className={inputCls}
                />
              </label>
              <label className="block">
                <span className="mb-1 block text-xs font-medium text-muted-foreground">Compliance Status</span>
                <select
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
            className="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
          >
            Save Changes
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
  const { isDhanshree } = useRoleContext();
  const { emp: loaderEmp } = Route.useLoaderData() as { emp: Employee };
  const [emp, setEmp] = useState<Employee>(loaderEmp);
  const [tab, setTab] = useState<string>("basic");
  const [offOpen, setOffOpen] = useState(false);
  const [editOpen, setEditOpen] = useState(false);
  const [localAssetId, setLocalAssetId] = useState(loaderEmp.assetId);
  const [assetTypeInput, setAssetTypeInput] = useState<"TK" | "Client">("TK");
  const [assetIdInput, setAssetIdInput] = useState("");

  if (!isDhanshree) return <Navigate to="/" />;

  useEffect(() => {
    if (typeof window !== "undefined" && window.location.hash === "#kpi") setTab("kpi");
  }, []);

  const handleSaveProfile = (updatedEmp: Employee) => {
    setEmp(updatedEmp);
    setLocalAssetId(updatedEmp.assetId);
  };

  return (
    <AppShell title={`${emp.firstName} ${emp.lastName}`} subtitle={`${emp.designation} · ${emp.department}`}>
      {/* Breadcrumb */}
      <div className="mb-4 flex items-center gap-2 text-xs text-muted-foreground">
        <Link to="/dh-employee-directory" className="hover:text-foreground transition-colors">Employee Directory</Link>
        <span>/</span>
        <span className="text-foreground">{emp.firstName} {emp.lastName}</span>
      </div>

      {/* Profile header */}
      <div className="rounded-xl border border-border bg-card p-6">
        <div className="flex flex-wrap items-start justify-between gap-4">
          <div className="flex items-start gap-4">
            <Avatar name={`${emp.firstName} ${emp.lastName}`} size={52} />
            <div>
              <div className="flex flex-wrap items-center gap-3">
                <h1 className="text-xl font-semibold tracking-tight">{emp.firstName} {emp.lastName}</h1>
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
              <div className="mt-1 text-sm text-muted-foreground">{emp.designation} · {emp.department}</div>
              <div className="mt-2 flex flex-wrap gap-x-5 gap-y-1.5 text-xs text-muted-foreground">
                <span>ID: <span className="font-mono text-foreground">{emp.id}</span></span>
                <span>Email: {emp.email}</span>
                <span>Project Site: <span className="font-medium text-foreground">{emp.projectSite}</span></span>
                <span>Location: <span className="font-medium text-foreground">{emp.workLocation}</span></span>
                <span>Reporting Manager: <span className="font-medium text-foreground">{emp.reportingManager}</span></span>
                <span>Cost Center: <span className="font-medium text-foreground">{getCostCenter(emp)}</span></span>
              </div>
            </div>
          </div>
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
              onClick={() => setOffOpen(true)}
              className="rounded-md bg-destructive px-3 py-2 text-sm font-medium text-destructive-foreground hover:bg-destructive/90"
            >
              Offboard Employee
            </button>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="mt-6">
        <div className="flex flex-wrap gap-1 border-b border-border overflow-x-auto">
          {tabs.map((t) => (
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
                <Row label="Contact Number" value={emp.phone} />
                <Row label="Alternate Contact" value={emp.altPhone} />
                <Row label="Gender" value={emp.gender} />
                <Row label="Date of Birth" value={emp.dob} />
                <Row label="Address" value={emp.address} />
                <Row label="Emergency Contact" value={emp.emergencyContact} />
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
                <Row label="Office Branch" value={emp.officeBranch} />
                <Row label="Employee Category" value={emp.category} />
                <Row label="Team Name" value={emp.team} />
              </Grid>
            </div>
          )}

          {/* ── Employment ──── */}
          {tab === "employment" && (
            <div className="rounded-lg border border-border bg-card p-6">
              <Grid>
                <Row label="Date of Joining" value={emp.joiningDate} />
                <Row label="Employment Status" value={<EmpStatusBadge status={emp.confirmationStatus} />} />
                <Row
                  label="Asset ID"
                  value={
                    localAssetId && localAssetId !== "None" ? (
                      <span className="font-semibold text-foreground">{localAssetId}</span>
                    ) : (
                      <div className="flex items-center gap-1.5 mt-1">
                        <select
                          value={assetTypeInput}
                          onChange={(e) => setAssetTypeInput(e.target.value as "TK" | "Client")}
                          className="h-8 rounded-md border border-input bg-card px-2 text-xs outline-none focus-visible:ring-1 focus-visible:ring-ring text-foreground"
                        >
                          <option value="TK">TK Asset</option>
                          <option value="Client">Client Asset</option>
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
                              setLocalAssetId(`${assetTypeInput === "TK" ? "TK" : "Client"}-${assetIdInput.trim()}`);
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
                    {emp.skills.map((s) => (
                      <span key={s} className="rounded-full border border-border bg-muted px-2.5 py-1 text-xs font-medium">{s}</span>
                    ))}
                  </div>
                </div>
                <div className="rounded-lg border border-border bg-card p-6">
                  <h3 className="mb-3 text-sm font-semibold">Functional Skills</h3>
                  <div className="flex flex-wrap gap-2">
                    {["Stakeholder Mgmt", "Roadmapping", "Mentoring"].map((s) => (
                      <span key={s} className="rounded-full border border-border bg-muted px-2.5 py-1 text-xs font-medium">{s}</span>
                    ))}
                  </div>
                </div>
                <div className="rounded-lg border border-border bg-card p-6">
                  <h3 className="mb-3 text-sm font-semibold">Certifications</h3>
                  <ul className="space-y-1.5 text-sm">
                    {emp.certifications.map((c) => (
                      <li key={c} className="flex items-center gap-2 text-foreground">
                        <span className="h-1 w-1 rounded-full bg-primary" />
                        {c}
                      </li>
                    ))}
                  </ul>
                </div>
                <div className="rounded-lg border border-border bg-card p-6">
                  <h3 className="mb-3 text-sm font-semibold">Languages Known</h3>
                  <div className="flex flex-wrap gap-2">
                    {emp.languages.map((l) => (
                      <span key={l} className="rounded-full border border-border bg-muted px-2.5 py-1 text-xs font-medium">{l}</span>
                    ))}
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
                      <li key={t} className="flex justify-between border-b border-border pb-2 last:border-0 last:pb-0 text-foreground">{t}</li>
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
                    <div className="text-[11px] uppercase tracking-wider text-muted-foreground">{k.l}</div>
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
                      <line key={y} x1="0" y1={y} x2="400" y2={y} className="stroke-border" strokeWidth="0.5" />
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
                  <p className="text-sm text-muted-foreground leading-relaxed">{emp.managerFeedback}</p>
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
                <Row label="Compliance Status" value={<EmpStatusBadge status={emp.complianceStatus} />} />
              </Grid>
            </div>
          )}


        </div>
      </div>

      {/* Offboarding modal */}
      <OffboardingModal open={offOpen} onClose={() => setOffOpen(false)} employee={emp} />

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
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
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

    toast.success(`Calendar updated for ${monthsList[selectedDate.getMonth()]} ${selectedDate.getDate()}, ${selectedDate.getFullYear()}`);
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
            <div key={d} className="py-3 text-xs font-semibold tracking-wider text-muted-foreground border-r border-border last:border-0">
              {d}
            </div>
          ))}
        </div>

        {/* Calendar Monthly Grid */}
        <div className="grid grid-cols-7 border-x border-b border-border divide-y divide-border bg-background rounded-b-lg overflow-hidden">
          {daysGrid.map((dayNum, index) => {
            const colClass = "border-r border-border last:border-r-0 min-h-[100px] p-2 relative flex flex-col justify-between group hover:bg-muted/10 transition-all cursor-pointer";
            
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
                  <span className={cn(
                    "text-xs font-semibold",
                    isToday ? "text-primary font-bold text-sm" : "text-foreground/80"
                  )}>
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
          <div className="relative w-full max-w-md rounded-xl bg-card border border-border p-6 shadow-2xl" onClick={(e) => e.stopPropagation()}>
            <h3 className="mb-4 text-base font-semibold text-foreground">
              Manage Day Schedule
            </h3>
            <p className="mb-4 text-xs text-muted-foreground">
              Configure shift or leave status for <strong>{monthsList[selectedDate.getMonth()]} {selectedDate.getDate()}, {selectedDate.getFullYear()}</strong>.
            </p>

            <form onSubmit={handleSaveDayOverride} className="space-y-4">
              <label className="block">
                <span className="mb-1.5 block text-xs font-medium text-muted-foreground">Day Status Type</span>
                <select
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
                  <span className="mb-1.5 block text-xs font-medium text-muted-foreground">Shift Timing</span>
                  <select
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
                  <span className="mb-1.5 block text-xs font-medium text-muted-foreground">Leave Type</span>
                  <select
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
                <span className="mb-1.5 block text-xs font-medium text-muted-foreground">Remarks / Reason</span>
                <textarea
                  value={reason}
                  onChange={(e) => setReason(e.target.value)}
                  placeholder="E.g., Doctor appointment, client alignment, holiday list update..."
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
          <div className="absolute inset-0 bg-black/40" onClick={() => setIsShiftModalOpen(false)} />
          <div className="relative w-full max-w-md rounded-xl bg-card border border-border p-6 shadow-2xl" onClick={(e) => e.stopPropagation()}>
            <h3 className="mb-4 text-base font-semibold text-foreground">
              Request Shift Change
            </h3>
            <p className="mb-4 text-xs text-muted-foreground">
              Submit a formal request to alter the assigned work shift.
            </p>

            <form onSubmit={handleShiftRequestSubmit} className="space-y-4">
              <label className="block">
                <span className="mb-1.5 block text-xs font-medium text-muted-foreground">Effective Date</span>
                <input
                  type="date"
                  value={reqShiftDate}
                  onChange={(e) => setReqShiftDate(e.target.value)}
                  className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm text-foreground outline-none focus:ring-1 focus:ring-ring"
                  required
                />
              </label>

              <label className="block">
                <span className="mb-1.5 block text-xs font-medium text-muted-foreground">Target Work Shift</span>
                <select
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
                <span className="mb-1.5 block text-xs font-medium text-muted-foreground">Reason for Request</span>
                <textarea
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
          <div className="absolute inset-0 bg-black/40" onClick={() => setIsWeeklyOffModalOpen(false)} />
          <div className="relative w-full max-w-md rounded-xl bg-card border border-border p-6 shadow-2xl" onClick={(e) => e.stopPropagation()}>
            <h3 className="mb-4 text-base font-semibold text-foreground">
              Request Weekly Off
            </h3>
            <p className="mb-4 text-xs text-muted-foreground">
              Submit a request to change the weekly off day.
            </p>

            <form onSubmit={handleWeeklyOffRequestSubmit} className="space-y-4">
              <label className="block">
                <span className="mb-1.5 block text-xs font-medium text-muted-foreground">Off Date Requested</span>
                <input
                  type="date"
                  value={reqWOffDate}
                  onChange={(e) => setReqWOffDate(e.target.value)}
                  className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm text-foreground outline-none focus:ring-1 focus:ring-ring"
                  required
                />
              </label>

              <label className="block">
                <span className="mb-1.5 block text-xs font-medium text-muted-foreground">Reason / Description</span>
                <textarea
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
