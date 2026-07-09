import { createFileRoute, Link, Navigate } from "@tanstack/react-router";
import { useMemo, useState, useEffect } from "react";
import { Search, Plus, Download, ChevronLeft, ChevronRight, X } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { Avatar, ProgressBar } from "@/components/pills";
import { cn } from "@/lib/utils";
import {
  employees,
  departments,
  designationsList,
  employeeStatuses,
  type EmployeeStatus,
} from "@/lib/employee-data";

export const Route = createFileRoute("/dh-employee-directory/")({
  head: () => ({
    meta: [
      { title: "Employee Directory — Pulse PMO" },
      { name: "description", content: "Browse and manage the full employee directory." },
    ],
  }),
  component: EmployeeDirectoryPage,
});

const PAGE_SIZE = 15;

// ── Status pill ────────────────────────────────────
function EmpStatusBadge({ status }: { status: string }) {
  const map: Record<string, string> = {
    Active: "border-success/30 bg-success/10 text-success",
    Probation: "border-warning/40 bg-warning/15 text-warning-foreground",
    "Notice Period": "border-destructive/30 bg-destructive/10 text-destructive",
    Inactive: "border-muted-foreground/30 bg-muted text-muted-foreground",
    "On Leave": "border-info/30 bg-info/10 text-info",
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

// ── Select helper ─────────────────────────────────
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

// ── Onboarding slide-over panel ───────────────────
function OnboardingPanel({ open, onClose }: { open: boolean; onClose: () => void }) {
  useEffect(() => {
    if (open) document.body.style.overflow = "hidden";
    else document.body.style.overflow = "";
    return () => { document.body.style.overflow = ""; };
  }, [open]);

  if (!open) return null;

  const inputCls =
    "h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring";

  function FormField({ label, type = "text", placeholder = "" }: { label: string; type?: string; placeholder?: string }) {
    return (
      <label className="block">
        <span className="mb-1 block text-xs font-medium text-muted-foreground">{label}</span>
        <input type={type} placeholder={placeholder} className={inputCls} />
      </label>
    );
  }
  function FormSelect({ label, options }: { label: string; options: string[] }) {
    return (
      <label className="block">
        <span className="mb-1 block text-xs font-medium text-muted-foreground">{label}</span>
        <select className={inputCls}>
          <option value="">Select…</option>
          {options.map((o) => <option key={o}>{o}</option>)}
        </select>
      </label>
    );
  }
  function FormSection({ title, children }: { title: string; children: React.ReactNode }) {
    return (
      <section className="rounded-lg border border-border bg-card p-5">
        <h3 className="mb-4 text-sm font-semibold text-foreground">{title}</h3>
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">{children}</div>
      </section>
    );
  }
  function UploadSlot({ label }: { label: string }) {
    return (
      <div className="flex flex-col items-center justify-center rounded-md border-2 border-dashed border-border bg-muted/30 px-4 py-6 text-center">
        <Plus className="mb-2 h-5 w-5 text-muted-foreground" />
        <div className="text-xs font-medium text-foreground">{label}</div>
        <div className="text-[11px] text-muted-foreground">PDF, JPG · up to 5 MB</div>
      </div>
    );
  }

  return (
    <div className="fixed inset-0 z-50 flex justify-end">
      <div className="absolute inset-0 bg-black/40" onClick={onClose} />
      <div className="relative flex h-full w-full max-w-4xl flex-col bg-background shadow-2xl">
        {/* header */}
        <div className="flex items-center justify-between border-b border-border bg-card px-6 py-4">
          <div>
            <h2 className="text-base font-semibold">Onboard New Employee</h2>
            <p className="text-xs text-muted-foreground">Fill in employee details to create their profile.</p>
          </div>
          <button onClick={onClose} className="rounded-md p-1.5 text-muted-foreground hover:bg-accent">
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* scrollable body */}
        <div className="flex-1 space-y-5 overflow-y-auto px-6 py-6">
          <FormSection title="1. Personal Information">
            <FormField label="First Name" /><FormField label="Last Name" />
            <FormField label="Email ID" type="email" /><FormField label="Personal Email" type="email" />
            <FormField label="Mobile Number" /><FormField label="Alternate Contact Number" />
            <FormSelect label="Gender" options={["Male","Female","Other"]} />
            <FormField label="Date of Birth" type="date" />
            <FormSelect label="Marital Status" options={["Single","Married","Other"]} />
            <FormField label="Nationality" />
            <div className="md:col-span-2"><FormField label="Address" /></div>
          </FormSection>

          <FormSection title="2. Organization Assignment">
            <FormField label="Employee ID" placeholder="EMP-1049" />
            <FormSelect label="Department" options={departments} />
            <FormField label="Designation" />
            <FormField label="Role" />
            <FormSelect label="Reporting Manager" options={["Rakesh Menon","Sunita Verma","David Thomas"]} />
            <FormSelect label="Business Unit" options={["Cloud Platform","Consumer Apps","Enterprise"]} />
            <FormField label="Team" />
            <FormSelect label="Project Site" options={["Onsite","Offsite"]} />
            <FormSelect label="Work Location" options={["Andheri Office","Dombivali Office","Bengaluru","Hyderabad","Pune","Mumbai","Remote"]} />
            <FormSelect label="Office Branch" options={["HQ Tower","Tech Park East","Tech Park West"]} />
          </FormSection>

          <FormSection title="3. Employment Information">
            <FormField label="Date of Joining" type="date" />
            <FormSelect label="Category" options={["Permanent - Bond", "Permanent - Without Bond", "Contract-based", "Intern - Paid", "Intern - Unpaid"]} />
            <FormField label="Asset ID" placeholder="TK-4029" />
            <FormSelect label="Employment Status" options={["Active - Probation", "Active", "Resignation - Under Review", "Resignation - Accepted", "Inactive - After Onboarding"]} />
            <FormSelect label="Exit Type" options={["NA", "Resign", "Absconded", "Terminated", "Suspension"]} />
            <FormField label="Exit Comment" placeholder="Reason for resignation/termination" />
            <FormField label="Probation Period" placeholder="6 months" />
            <FormField label="Notice Period" placeholder="90 days" />
            <FormField label="Salary Band" placeholder="L4" />
          </FormSection>

          <FormSection title="4. Skills & Qualifications">
            <FormField label="Highest Qualification" />
            <FormField label="Certifications" />
            <FormField label="Technical Skills" placeholder="React, Node.js" />
            <FormField label="Functional Skills" />
            <FormField label="Experience" placeholder="5 years" />
            <FormField label="Previous Organization" />
          </FormSection>

          <FormSection title="5. Compliance Information">
            <FormField label="PAN Number" />
            <FormField label="Aadhaar Number" />
            <FormField label="PF/UAN Number" />
            <FormField label="Bank Account Number" />
            <FormField label="IFSC Code" />
          </FormSection>

          <section className="rounded-lg border border-border bg-card p-5">
            <h3 className="mb-4 text-sm font-semibold text-foreground">6. Document Uploads</h3>
            <div className="grid grid-cols-2 gap-4 md:grid-cols-3 lg:grid-cols-6">
              {["Resume","PAN Card","Aadhaar Card","Offer Letter","Education Certs","Experience Letters"].map((d) => (
                <UploadSlot key={d} label={d} />
              ))}
            </div>
          </section>
        </div>

        {/* footer */}
        <div className="flex items-center justify-end gap-2 border-t border-border bg-card px-6 py-4">
          <button onClick={onClose} className="rounded-md border border-input bg-card px-4 py-2 text-sm font-medium text-foreground hover:bg-accent">Cancel</button>
          <button className="rounded-md border border-input bg-card px-4 py-2 text-sm font-medium text-foreground hover:bg-accent">Save Draft</button>
          <button className="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90">Create Employee</button>
        </div>
      </div>
    </div>
  );
}

// ── Main page ────────────────────────────────────
function EmployeeDirectoryPage() {
  const { isDhanshree } = useRoleContext();
  const [q, setQ] = useState("");
  const [dept, setDept] = useState("");
  const [desig, setDesig] = useState("");
  const [status, setStatus] = useState("");
  const [page, setPage] = useState(1);
  const [onboardOpen, setOnboardOpen] = useState(false);

  if (!isDhanshree) return <Navigate to="/" />;

  const rows = useMemo(() => {
    return employees.filter((e) => {
      const matchQ =
        !q ||
        `${e.firstName} ${e.lastName} ${e.id} ${e.email} ${e.department} ${e.designation} ${e.reportingManager} ${e.workLocation}`
          .toLowerCase()
          .includes(q.toLowerCase());
      return (
        matchQ &&
        (!dept || e.department === dept) &&
        (!desig || e.designation === desig) &&
        (!status || e.status === status)
      );
    });
  }, [q, dept, desig, status]);

  const totalPages = Math.max(1, Math.ceil(rows.length / PAGE_SIZE));
  const currentPage = Math.min(page, totalPages);
  const pageRows = rows.slice((currentPage - 1) * PAGE_SIZE, currentPage * PAGE_SIZE);

  // reset page when filters change
  useMemo(() => setPage(1), [q, dept, desig, status]);

  return (
    <AppShell title="Employee Directory" subtitle={`${rows.length} of ${employees.length} employees`}>
      {/* Header */}
      <div className="mb-5 flex flex-wrap items-start justify-between gap-3">
        <div>
          <h2 className="text-lg font-semibold tracking-tight">Employee Directory</h2>
          <p className="text-xs text-muted-foreground">{rows.length} of {employees.length} employees</p>
        </div>
        <button
          onClick={() => setOnboardOpen(true)}
          className="inline-flex items-center gap-2 rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
        >
          <Plus className="h-4 w-4" />
          Add Employee
        </button>
      </div>

      {/* Filters */}
      <div className="mb-4 grid grid-cols-1 gap-3 rounded-xl border border-border bg-card p-3 md:grid-cols-5">
        <div className="relative md:col-span-2">
          <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Search by name, ID, dept, skill, manager, location…"
            className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
        </div>
        <FilterSelect value={dept} onChange={setDept} placeholder="All Departments" options={departments} />
        <FilterSelect value={desig} onChange={setDesig} placeholder="All Designations" options={designationsList} />
        <div className="flex gap-2">
          <div className="flex-1">
            <FilterSelect value={status} onChange={setStatus} placeholder="All Status" options={employeeStatuses} />
          </div>
          <button className="inline-flex items-center gap-1.5 rounded-md border border-input bg-card px-3 text-sm hover:bg-accent">
            <Download className="h-3.5 w-3.5" />
            Export
          </button>
        </div>
      </div>

      {/* Table */}
      <div className="overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
        <table className="w-full text-sm">
          <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr>
              {[
                "Employee ID",
                "Name",
                "Email",
                "Department",
                "Designation",
                "Reporting Manager",
                "Location",
                "Category",
                "Joining Date",
                "Status",
                "KPI",
              ].map((h) => (
                <th key={h} className="whitespace-nowrap px-3 py-2.5 font-medium">
                  {h}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {pageRows.map((e) => (
              <tr
                key={e.id}
                className="cursor-pointer transition-colors hover:bg-accent/30"
              >
                <td className="whitespace-nowrap px-3 py-2.5 font-mono text-xs text-muted-foreground">
                  {e.id}
                </td>
                <td className="whitespace-nowrap px-3 py-2.5">
                  <Link
                    to="/dh-employee-directory/$id"
                    params={{ id: e.id }}
                    className="flex items-center gap-2"
                  >
                    <Avatar name={`${e.firstName} ${e.lastName}`} size={28} />
                    <span className="font-medium">{e.firstName} {e.lastName}</span>
                  </Link>
                </td>
                <td className="whitespace-nowrap px-3 py-2.5 text-muted-foreground">
                  {e.email}
                </td>
                <td className="whitespace-nowrap px-3 py-2.5">{e.department}</td>
                <td className="whitespace-nowrap px-3 py-2.5">{e.designation}</td>
                <td className="whitespace-nowrap px-3 py-2.5 text-muted-foreground">
                  {e.reportingManager}
                </td>
                <td className="whitespace-nowrap px-3 py-2.5">{e.workLocation}</td>
                <td className="whitespace-nowrap px-3 py-2.5">{e.category}</td>
                <td className="whitespace-nowrap px-3 py-2.5 text-muted-foreground">
                  {e.joiningDate}
                </td>
                <td className="whitespace-nowrap px-3 py-2.5">
                  <EmpStatusBadge status={e.status} />
                </td>
                <td className="whitespace-nowrap px-3 py-2.5">
                  <div className="flex items-center gap-2">
                    <ProgressBar value={e.kpiScore} className="w-16" />
                    <span className="text-xs font-medium tabular-nums">{e.kpiScore}</span>
                  </div>
                </td>
              </tr>
            ))}
            {pageRows.length === 0 && (
              <tr>
                <td colSpan={11} className="px-3 py-10 text-center text-sm text-muted-foreground">
                  No employees match your filters
                </td>
              </tr>
            )}
          </tbody>
        </table>

        {/* Pagination */}
        <div className="flex items-center justify-between border-t border-border px-4 py-3 text-xs text-muted-foreground">
          <div>
            Showing {rows.length === 0 ? 0 : (currentPage - 1) * PAGE_SIZE + 1}–
            {Math.min(currentPage * PAGE_SIZE, rows.length)} of {rows.length}
          </div>
          <div className="flex items-center gap-1">
            <button
              onClick={() => setPage((p) => Math.max(1, p - 1))}
              disabled={currentPage <= 1}
              className="inline-flex items-center gap-1 rounded-md border border-input px-2.5 py-1 hover:bg-accent disabled:opacity-40"
            >
              <ChevronLeft className="h-3 w-3" /> Previous
            </button>
            <span className="px-2 tabular-nums">{currentPage} / {totalPages}</span>
            <button
              onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
              disabled={currentPage >= totalPages}
              className="inline-flex items-center gap-1 rounded-md border border-input px-2.5 py-1 hover:bg-accent disabled:opacity-40"
            >
              Next <ChevronRight className="h-3 w-3" />
            </button>
          </div>
        </div>
      </div>

      {/* Onboarding panel */}
      <OnboardingPanel open={onboardOpen} onClose={() => setOnboardOpen(false)} />
    </AppShell>
  );
}
