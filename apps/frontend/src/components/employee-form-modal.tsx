import { useMemo, useState, useEffect, useRef } from "react";
import { createPortal } from "react-dom";
import { X, Plus, FileText } from "lucide-react";
import { toast } from "sonner";
import { cn } from "@/lib/utils";
import {
  ALLOWED_WORK_EMAIL_DOMAIN_OPTIONS,
  FIELD_MAX,
  isAllowedWorkEmailDomain,
  isoDateToday,
  toDigits,
  toLettersName,
  toEmailInput,
  toEmailLocalPart,
  isValidEmailLocalPart,
  joinTkId,
  splitTkId,
  toTenDigitPhone,
  type TkIdPrefix,
} from "@/lib/form-validation";
import { CreatableCatalogSelect, SearchableSelect } from "@/components/creatable-catalog-select";
import { TkIdField } from "@/components/tk-id-field";
import { WorkEmailField } from "@/components/work-email-field";
import { FORM_CONTROL_CLS, FORM_ERROR_CLS, FORM_LABEL_CLS } from "@/components/form-row";
import {
  createBusinessUnitOption,
  createDepartmentOption,
  createDesignationOption,
  createEmployee,
  updateEmployee,
  createJobRoleOption,
  createReportingManagerOption,
  createWorkLocationOption,
  fetchBusinessUnitOptions,
  fetchDepartmentOptions,
  fetchDesignationOptions,
  fetchEmailDomainOptions,
  fetchJobRoleOptions,
  fetchEmployeeStatusOptions,
  fetchReportingManagerOptions,
  fetchWorkLocationOptions,
  fetchCertificationOptions,
  createCertificationOption,
  fetchGraduationDegreeOptions,
  createGraduationDegreeOption,
  fetchPostGraduationDegreeOptions,
  createPostGraduationDegreeOption,
  toUiEmployee,
  type ApiMetaOption,
} from "@/lib/api/employees";
import {
  EMPTY_ONBOARD,
  validateOnboardField,
  validateOnboardForm,
  blankToNull,
  csvToList,
  EMERGENCY_RELATION_OPTIONS,
  BILLABLE_STATUS_OPTIONS,
  PROJECT_TYPE_OPTIONS,
  PMO_DEPARTMENT_OPTIONS,
  PMO_DEPARTMENT_SUB_DEPARTMENTS,
  formatExpDisplay,
  employeeToOnboardValues,
  type OnboardErrors,
  type OnboardField,
  type OnboardValues,
} from "@/lib/onboard-validation";
import {
  WORKER_TYPES,
  BOND_DELIVERED_OPTIONS,
  computeBondStatus,
  formatBondExpiryDisplay,
} from "@/lib/employment-bond";
import type { Employee } from "@/lib/employee-data";
import { MUMBAI_RAILWAY_STATIONS } from "@/lib/mumbai-stations";
import { allProjects, allClients } from "@/lib/dh-store";

// ── Local Form Components ─────────────────────────

function FormField({
  label,
  type = "text",
  placeholder = "",
  value,
  onChange,
  onBlur,
  error,
  required,
  readOnly,
  disabled,
  prefix,
  suffix,
  className,
  name,
  inputMode,
  maxLength = FIELD_MAX.text,
  min,
  max,
  hideErrorText,
}: {
  label: string;
  type?: string;
  placeholder?: string;
  value?: string;
  onChange?: (value: string) => void;
  onBlur?: () => void;
  error?: string | boolean;
  required?: boolean;
  readOnly?: boolean;
  disabled?: boolean;
  prefix?: string;
  suffix?: string;
  className?: string;
  name?: string;
  inputMode?: React.HTMLAttributes<HTMLInputElement>["inputMode"];
  maxLength?: number;
  min?: string;
  max?: string;
  hideErrorText?: boolean;
}) {
  return (
    <label className={cn("block", className)}>
      {label ? (
        <span className={FORM_LABEL_CLS}>
          {label}
          {required ? <span className="text-destructive"> *</span> : null}
        </span>
      ) : null}
      <div className="relative">
        {prefix ? (
          <span className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-xs text-muted-foreground">
            {prefix}
          </span>
        ) : null}
        <input
          autoComplete="new-password"
          data-lpignore="true"
          data-1p-ignore="true"
          data-bwignore="true"
          data-form-type="other"
          id={name ? `form-${name}` : undefined}
          type={type}
          placeholder={placeholder}
          maxLength={maxLength}
          min={min}
          max={max}
          inputMode={inputMode}
          readOnly={readOnly}
          disabled={disabled}
          value={value ?? ""}
          onChange={(e) => onChange?.(e.target.value)}
          onBlur={onBlur}
          className={cn(
            FORM_CONTROL_CLS,
            prefix && "pl-10",
            suffix && "pr-16",
            error && "border-destructive focus-visible:ring-destructive",
            readOnly && "cursor-not-allowed bg-muted text-muted-foreground",
            disabled && "cursor-not-allowed bg-muted text-muted-foreground opacity-70",
          )}
          aria-label={label}
          aria-invalid={Boolean(error)}
          aria-required={required}
          aria-disabled={disabled}
        />
        {suffix ? (
          <span className="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-xs text-muted-foreground">
            {suffix}
          </span>
        ) : null}
      </div>
      {error && typeof error === "string" && !hideErrorText ? (
        <p className={FORM_ERROR_CLS}>{error}</p>
      ) : null}
    </label>
  );
}

function FormSelect({
  label,
  options,
  value,
  onChange,
  error,
  required,
  disabled,
  placeholder = "Select…",
  showSearch,
}: {
  label: string;
  options: Array<string | { value: string; label: string; subLabel?: string }>;
  value?: string;
  onChange?: (value: string) => void;
  error?: string;
  required?: boolean;
  disabled?: boolean;
  placeholder?: string;
  showSearch?: boolean;
}) {
  return (
    <SearchableSelect
      label={label}
      options={options}
      value={value}
      onChange={onChange}
      error={error}
      required={required}
      disabled={disabled}
      placeholder={placeholder}
      showSearch={showSearch}
    />
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

const CURRENT_YEAR = new Date().getFullYear();
const PASSING_YEAR_OPTIONS = Array.from({ length: 55 }, (_, i) => String(CURRENT_YEAR - i));

function CertificationMultiSelect({
  label,
  certOptions,
  value,
  onChange,
  onCreate,
}: {
  label: string;
  certOptions: ApiMetaOption[];
  value: string;
  onChange: (newValue: string) => void;
  onCreate: (name: string) => Promise<ApiMetaOption>;
}) {
  const selectedList = useMemo(() => csvToList(value), [value]);

  const addCert = (certName: string) => {
    if (!certName) return;
    if (selectedList.some((c) => c.toLowerCase() === certName.toLowerCase())) return;
    const nextList = [...selectedList, certName];
    onChange(nextList.join(", "));
  };

  const removeCert = (certName: string) => {
    const nextList = selectedList.filter((c) => c.toLowerCase() !== certName.toLowerCase());
    onChange(nextList.join(", "));
  };

  const catalogSelectOptions = useMemo(() => {
    return certOptions
      .filter((opt) => !selectedList.some((s) => s.toLowerCase() === opt.name.toLowerCase()))
      .map((opt) => ({ id: opt.id, code: opt.code, name: opt.name }));
  }, [certOptions, selectedList]);

  return (
    <div className="space-y-2">
      <span className={FORM_LABEL_CLS}>{label}</span>
      <CreatableCatalogSelect
        label=""
        options={catalogSelectOptions}
        valueId=""
        placeholder="Search or add certification (e.g. CEH, OSCP, CISSP, ISO 27001)…"
        onSelect={(_, name) => {
          if (name) addCert(name);
        }}
        onCreate={async (name) => {
          const created = await onCreate(name);
          addCert(created.name);
          return created;
        }}
      />
      {selectedList.length > 0 && (
        <div className="flex flex-wrap gap-1.5 p-2.5 rounded-lg border border-border bg-muted/30">
          {selectedList.map((cert) => (
            <span
              key={cert}
              className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-primary/10 text-primary border border-primary/20 shadow-2xs"
            >
              {cert}
              <button
                type="button"
                onClick={() => removeCert(cert)}
                className="hover:text-destructive text-primary/70 transition-colors ml-0.5"
                title="Remove certification"
              >
                <X className="h-3.5 w-3.5" />
              </button>
            </span>
          ))}
        </div>
      )}
    </div>
  );
}

// ── Props ──────────────────────────────────────────

export interface EmployeeFormModalProps {
  open: boolean;
  onClose: () => void;
  mode: "create" | "edit";
  initialEmployee?: Employee | null;
  existingCodes?: string[];
  managers?: { id: string; name: string }[];
  onSuccess: (saved?: Employee) => void | Promise<void>;
}

// ── Component ──────────────────────────────────────

export function EmployeeFormModal({
  open,
  onClose,
  mode,
  initialEmployee,
  existingCodes = [],
  managers,
  onSuccess,
}: EmployeeFormModalProps) {
  const [form, setForm] = useState<OnboardValues>(EMPTY_ONBOARD);
  const [errors, setErrors] = useState<OnboardErrors>({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Metadata catalogs
  const [deptOptions, setDeptOptions] = useState<ApiMetaOption[]>([]);
  const [desigOptions, setDesigOptions] = useState<ApiMetaOption[]>([]);
  const [roleOptions, setRoleOptions] = useState<ApiMetaOption[]>([]);
  const [employeeStatusOptions, setEmployeeStatusOptions] = useState<ApiMetaOption[]>([]);
  const [emailDomainOptions, setEmailDomainOptions] = useState<ApiMetaOption[]>([]);
  const [managerOptions, setManagerOptions] = useState<ApiMetaOption[]>([]);
  const [buOptions, setBuOptions] = useState<ApiMetaOption[]>([]);
  const [workLocOptions, setWorkLocOptions] = useState<ApiMetaOption[]>([]);
  const [gradDegreeOptions, setGradDegreeOptions] = useState<ApiMetaOption[]>([]);
  const [postGradDegreeOptions, setPostGradDegreeOptions] = useState<ApiMetaOption[]>([]);
  const [certOptions, setCertOptions] = useState<ApiMetaOption[]>([]);

  // Split parts
  const [workEmailPrefix, setWorkEmailPrefix] = useState("");
  const [workEmailDomain, setWorkEmailDomain] = useState("");
  const [tkPrefix, setTkPrefix] = useState<TkIdPrefix>("TK");

  const formRef = useRef<OnboardValues>(EMPTY_ONBOARD);
  useEffect(() => {
    formRef.current = form;
  }, [form]);

  // Lock background scroll when open
  useEffect(() => {
    if (open) document.body.style.overflow = "hidden";
    else document.body.style.overflow = "";
    return () => {
      document.body.style.overflow = "";
    };
  }, [open]);

  // Project allocation options
  const projectAllocatedOptions = useMemo(() => {
    try {
      const list = allProjects().map((p: any) => ({
        value: p.name,
        label: p.projectCode ? `${p.name} (${p.projectCode})` : p.name,
      }));
      return [{ value: "Internal / Bench", label: "Internal / Bench" }, ...list];
    } catch {
      return [{ value: "Internal / Bench", label: "Internal / Bench" }];
    }
  }, []);

  const getEngagementManagerForProject = (projectName: string): string => {
    if (!projectName || projectName === "Internal / Bench") return "";
    try {
      const projects = allProjects();
      const proj = projects.find(
        (p: any) =>
          p.name.toLowerCase() === projectName.toLowerCase() ||
          (p.projectCode && `${p.name} (${p.projectCode})`.toLowerCase() === projectName.toLowerCase()),
      );
      if (proj) {
        if (proj.engagementManager) return proj.engagementManager;
        if (proj.clientId) {
          const clients = allClients();
          const client = clients.find((c) => c.id === proj.clientId);
          if (client?.engagementManager) return client.engagementManager;
          if (client?.name) return `${client.name} — Engagement Manager`;
        }
      }
    } catch {}
    return "Assigned Engagement Manager";
  };

  const pmoSubDeptOptions = useMemo(() => {
    if (!form.pmoDepartment) return [];
    return PMO_DEPARTMENT_SUB_DEPARTMENTS[form.pmoDepartment] ?? [];
  }, [form.pmoDepartment]);

  // Load catalogs and initialize form on open
  useEffect(() => {
    if (!open) {
      setForm(EMPTY_ONBOARD);
      setErrors({});
      setIsSubmitting(false);
      return;
    }

    // Initialize values based on mode
    if (mode === "edit" && initialEmployee) {
      const initVals = employeeToOnboardValues(initialEmployee);
      setForm(initVals);
      formRef.current = initVals;

      // Split email
      const email = initialEmployee.email || "";
      const atIdx = email.indexOf("@");
      if (atIdx > 0) {
        setWorkEmailPrefix(email.slice(0, atIdx));
        setWorkEmailDomain(email.slice(atIdx + 1));
      } else {
        setWorkEmailPrefix(email);
        setWorkEmailDomain("talakunchi.com");
      }

      // Split TK ID
      const { prefix } = splitTkId(initialEmployee.id);
      setTkPrefix(prefix);
    } else {
      setForm(EMPTY_ONBOARD);
      formRef.current = EMPTY_ONBOARD;
      setWorkEmailPrefix("");
      setWorkEmailDomain("talakunchi.com");
      setTkPrefix("TK");
    }

    // Load catalogs
    void fetchDepartmentOptions()
      .then(setDeptOptions)
      .catch(() => toast.error("Could not load departments"));

    // In edit mode, load ALL statuses; in create mode, load only onboarding statuses
    const onlyOnboarding = mode === "create";
    void fetchEmployeeStatusOptions(onlyOnboarding)
      .then((rows) => {
        const list = rows ?? [];
        setEmployeeStatusOptions(list);
        if (mode === "create" && list.length > 0) {
          setForm((prev) => ({
            ...prev,
            employeeStatusId: prev.employeeStatusId || list[0].id,
          }));
        } else if (mode === "edit" && initialEmployee) {
          // Resolve employeeStatusId from initial employee if needed
          const matched = list.find(
            (s) =>
              s.name.toLowerCase() === (initialEmployee.confirmationStatus || initialEmployee.status || "").toLowerCase(),
          );
          if (matched) {
            setForm((prev) => ({ ...prev, employeeStatusId: prev.employeeStatusId || matched.id }));
          }
        }
      })
      .catch(() => toast.error("Could not load employee statuses"));

    void fetchBusinessUnitOptions()
      .then((bus) => {
        const list = bus ?? [];
        setBuOptions(list);
        if (mode === "create" && list.length > 0) {
          setForm((prev) => ({
            ...prev,
            businessUnit: prev.businessUnit || list[0].name,
          }));
        }
      })
      .catch(() => toast.error("Could not load business units"));

    void fetchWorkLocationOptions()
      .then((locs) => setWorkLocOptions(locs ?? []))
      .catch(() => toast.error("Could not load work locations"));

    void fetchGraduationDegreeOptions()
      .then((degs) => setGradDegreeOptions(degs ?? []))
      .catch(() => toast.error("Could not load graduation degrees"));

    void fetchPostGraduationDegreeOptions()
      .then((degs) => setPostGradDegreeOptions(degs ?? []))
      .catch(() => toast.error("Could not load post graduation degrees"));

    void fetchCertificationOptions()
      .then((certs) => setCertOptions(certs ?? []))
      .catch(() => toast.error("Could not load certifications"));

    void fetchReportingManagerOptions()
      .then((mgrs) => {
        const list = mgrs ?? [];
        setManagerOptions(list);
        if (mode === "edit" && initialEmployee) {
          const matched = list.find(
            (m) =>
              (initialEmployee.reportingManagerId && (m.id === initialEmployee.reportingManagerId || m.parentId === initialEmployee.reportingManagerId)) ||
              (initialEmployee.reportingManager && m.name.toLowerCase() === initialEmployee.reportingManager.toLowerCase()),
          );
          if (matched) {
            setForm((prev) => ({ ...prev, reportingManagerId: matched.id }));
          }
        }
      })
      .catch(() => toast.error("Could not load reporting managers"));

    void fetchEmailDomainOptions()
      .then((domains) => {
        const filtered = (domains ?? []).filter((d) =>
          isAllowedWorkEmailDomain(d.code.replace(/^@/, "")),
        );
        const list = filtered.length > 0 ? filtered : ALLOWED_WORK_EMAIL_DOMAIN_OPTIONS;
        setEmailDomainOptions(list);
        if (mode === "create" && list.length > 0) {
          const firstDomain = list[0].code.replace(/^@/, "");
          setWorkEmailDomain(firstDomain);
        }
      })
      .catch(() => {
        setEmailDomainOptions(ALLOWED_WORK_EMAIL_DOMAIN_OPTIONS);
        if (mode === "create") setWorkEmailDomain("talakunchi.com");
      });
  }, [open, mode, initialEmployee, managers]);

  // Dynamic designations when department changes
  useEffect(() => {
    if (!open || !form.departmentId) {
      setDesigOptions([]);
      return;
    }
    void fetchDesignationOptions(form.departmentId)
      .then(setDesigOptions)
      .catch(() => setDesigOptions([]));
  }, [open, form.departmentId]);

  // Dynamic roles when designation changes
  useEffect(() => {
    if (!open || !form.designationId) {
      setRoleOptions([]);
      return;
    }
    let cancelled = false;
    void fetchJobRoleOptions(form.designationId)
      .then((roles) => {
        if (cancelled) return;
        const list = roles ?? [];
        setRoleOptions(list);
        setForm((prev) => {
          if (prev.designationId !== form.designationId) return prev;
          const stillValid = list.some((r) => r.id === prev.jobRoleId);
          if (stillValid) return prev;
          return { ...prev, jobRoleId: list[0]?.id ?? "" };
        });
      })
      .catch(() => {
        if (!cancelled) setRoleOptions([]);
      });
    return () => {
      cancelled = true;
    };
  }, [open, form.designationId]);

  const selectedWorkLoc = useMemo(() => {
    if (!form.workLocation) return undefined;
    const target = form.workLocation.trim().toLowerCase();
    return workLocOptions.find(
      (l) =>
        l.name.toLowerCase() === target ||
        l.id.toLowerCase() === target ||
        (l.code && l.code.toLowerCase() === target),
    );
  }, [workLocOptions, form.workLocation]);

  const bondExpiryDisplay = useMemo(
    () => formatBondExpiryDisplay(form.joiningDate, form.bondDelivered, form.bondDurationMonths),
    [form.joiningDate, form.bondDelivered, form.bondDurationMonths],
  );

  const bondStatusDisplay = useMemo(
    () => computeBondStatus(form.bondDelivered, form.joiningDate, form.bondDurationMonths),
    [form.bondDelivered, form.joiningDate, form.bondDurationMonths],
  );

  if (!open) return null;

  // Field change handler
  const setField = (field: OnboardField, value: string) => {
    const nextValue =
      field === "phone" || field === "altPhone" || field === "emergencyContact"
        ? toTenDigitPhone(value)
        : field === "firstName" || field === "lastName" || field === "emergencyContactName"
          ? toLettersName(value)
          : field === "workEmail"
            ? toEmailInput(value)
            : field === "bondDurationMonths"
              ? toDigits(value, 3)
              : field === "priorTotalExpYears" ||
                field === "priorTotalExpMonths" ||
                field === "priorRelevantExpYears" ||
                field === "priorRelevantExpMonths"
                ? toDigits(value, 2)
                : value;

    const updatedForm = { ...formRef.current, [field]: nextValue };
    if (field === "departmentId") {
      updatedForm.designationId = "";
      updatedForm.jobRoleId = "";
    }
    if (field === "designationId") updatedForm.jobRoleId = "";
    if (field === "bondDelivered" && nextValue === "No") {
      updatedForm.bondDurationMonths = "0";
    }
    if (field === "projectAllocated") {
      const autoEm = getEngagementManagerForProject(nextValue);
      updatedForm.clientEngManagerMapping = autoEm;
    }

    if (
      field === "priorTotalExpYears" ||
      field === "priorTotalExpMonths" ||
      field === "priorRelevantExpYears" ||
      field === "priorRelevantExpMonths"
    ) {
      const totY = field === "priorTotalExpYears" ? nextValue : updatedForm.priorTotalExpYears;
      const totM = field === "priorTotalExpMonths" ? nextValue : updatedForm.priorTotalExpMonths;
      const relY = field === "priorRelevantExpYears" ? nextValue : updatedForm.priorRelevantExpYears;
      const relM = field === "priorRelevantExpMonths" ? nextValue : updatedForm.priorRelevantExpMonths;

      updatedForm.priorTotalExp = formatExpDisplay(totY, totM);
      updatedForm.priorRelevantExp = formatExpDisplay(relY, relM);
    }

    formRef.current = updatedForm;
    setForm(updatedForm);

    setErrors((prev) => {
      const nextErrors = { ...prev };
      const validationOpts = { isEdit: mode === "edit" };
      const excludeCodes = mode === "edit" && initialEmployee ? existingCodes.filter((c) => c !== initialEmployee.id) : existingCodes;
      const message = validateOnboardField(field, updatedForm, excludeCodes, validationOpts);
      if (message) nextErrors[field] = message;
      else delete nextErrors[field];

      if (field === "gradYear" || field === "gradDegree") {
        const gradDegMsg = validateOnboardField("gradDegree", updatedForm, excludeCodes, validationOpts);
        if (gradDegMsg) nextErrors.gradDegree = gradDegMsg;
        else delete nextErrors.gradDegree;

        const gradYrMsg = validateOnboardField("gradYear", updatedForm, excludeCodes, validationOpts);
        if (gradYrMsg) nextErrors.gradYear = gradYrMsg;
        else delete nextErrors.gradYear;
      }

      if (field === "gradYear" || field === "postGradDegree" || field === "postGradYear") {
        const postGradDegMsg = validateOnboardField("postGradDegree", updatedForm, excludeCodes, validationOpts);
        if (postGradDegMsg) nextErrors.postGradDegree = postGradDegMsg;
        else delete nextErrors.postGradDegree;

        const postGradMsg = validateOnboardField("postGradYear", updatedForm, excludeCodes, validationOpts);
        if (postGradMsg) nextErrors.postGradYear = postGradMsg;
        else delete nextErrors.postGradYear;
      }

      if (
        field === "priorTotalExp" ||
        field === "priorTotalExpYears" ||
        field === "priorTotalExpMonths" ||
        field === "priorRelevantExp" ||
        field === "priorRelevantExpYears" ||
        field === "priorRelevantExpMonths"
      ) {
        const totMonthsMsg = validateOnboardField("priorTotalExpMonths", updatedForm, excludeCodes, validationOpts);
        if (totMonthsMsg) nextErrors.priorTotalExpMonths = totMonthsMsg;
        else delete nextErrors.priorTotalExpMonths;

        const relMonthsMsg = validateOnboardField("priorRelevantExpMonths", updatedForm, excludeCodes, validationOpts);
        if (relMonthsMsg) nextErrors.priorRelevantExpMonths = relMonthsMsg;
        else delete nextErrors.priorRelevantExpMonths;

        const relMsg = validateOnboardField("priorRelevantExpYears", updatedForm, excludeCodes, validationOpts);
        if (relMsg) {
          nextErrors.priorRelevantExp = relMsg;
          nextErrors.priorRelevantExpYears = relMsg;
        } else {
          delete nextErrors.priorRelevantExp;
          delete nextErrors.priorRelevantExpYears;
        }
      }

      if (field === "projectAllocated" && updatedForm.clientEngManagerMapping) {
        delete nextErrors.clientEngManagerMapping;
      }

      return nextErrors;
    });
  };

  const blurField = (field: OnboardField) => {
    const currentForm = formRef.current;
    if (field === "workEmail") {
      const trimmed = currentForm[field].trim();
      if (trimmed !== currentForm[field]) {
        setField(field, trimmed);
        return;
      }
    }
    const validationOpts = { isEdit: mode === "edit" };
    const excludeCodes = mode === "edit" && initialEmployee ? existingCodes.filter((c) => c !== initialEmployee.id) : existingCodes;
    const message = validateOnboardField(field, currentForm, excludeCodes, validationOpts);
    setErrors((prev) => {
      const nextErrors = { ...prev };
      if (message) nextErrors[field] = message;
      else delete nextErrors[field];
      return nextErrors;
    });
  };

  // Submit handler
  const handleSubmit = async (e?: React.FormEvent) => {
    e?.preventDefault();
    const validationOpts = { isEdit: mode === "edit" };
    const excludeCodes = mode === "edit" && initialEmployee ? existingCodes.filter((c) => c !== initialEmployee.id) : existingCodes;
    const nextErrors = validateOnboardForm(form, excludeCodes, validationOpts);
    setErrors(nextErrors);
    if (Object.keys(nextErrors).length > 0) {
      toast.error("Please complete all mandatory fields");
      return;
    }
    setIsSubmitting(true);
    try {
      // Resolve creatable IDs
      let resolvedDepartmentId = form.departmentId || null;
      if (resolvedDepartmentId && resolvedDepartmentId.startsWith("__new__")) {
        const rawName = resolvedDepartmentId.replace(/^__new__/, "");
        const createdDept = await createDepartmentOption(rawName);
        resolvedDepartmentId = createdDept.id;
        setDeptOptions((prev) =>
          prev.map((d) => (d.id === form.departmentId ? createdDept : d)),
        );
      }

      let resolvedDesignationId = form.designationId || null;
      if (resolvedDesignationId && resolvedDesignationId.startsWith("__new__")) {
        const rawName = resolvedDesignationId.replace(/^__new__/, "");
        if (!resolvedDepartmentId) {
          toast.error("Department is required for the new designation");
          setIsSubmitting(false);
          return;
        }
        const createdDesig = await createDesignationOption(rawName, resolvedDepartmentId);
        resolvedDesignationId = createdDesig.id;
        setDesigOptions((prev) =>
          prev.map((d) => (d.id === form.designationId ? createdDesig : d)),
        );
      }

      let resolvedJobRoleId = form.jobRoleId || null;
      let resolvedRoleName = roleOptions.find((r) => r.id === form.jobRoleId)?.name ?? null;
      if (resolvedJobRoleId && resolvedJobRoleId.startsWith("__new__")) {
        const rawName = resolvedJobRoleId.replace(/^__new__/, "");
        if (!resolvedDesignationId) {
          toast.error("Designation is required for the new role");
          setIsSubmitting(false);
          return;
        }
        const createdRole = await createJobRoleOption(rawName, resolvedDesignationId);
        resolvedJobRoleId = createdRole.id;
        resolvedRoleName = createdRole.name;
        setRoleOptions((prev) =>
          prev.map((r) => (r.id === form.jobRoleId ? createdRole : r)),
        );
      }

      let resolvedReportingManagerId = form.reportingManagerId.trim() || null;
      if (resolvedReportingManagerId && resolvedReportingManagerId.startsWith("__new__")) {
        const rawName = resolvedReportingManagerId.replace(/^__new__/, "");
        const createdMgr = await createReportingManagerOption(rawName);
        resolvedReportingManagerId = createdMgr.id;
        setManagerOptions((prev) =>
          prev.map((m) => (m.id === form.reportingManagerId ? createdMgr : m)),
        );
      } else if (resolvedReportingManagerId) {
        const currentMgr = managerOptions.find(
          (m) => m.id === resolvedReportingManagerId || (m.parentId && m.parentId === resolvedReportingManagerId),
        );
        if (currentMgr) {
          resolvedReportingManagerId = currentMgr.id;
        }
      }

      let resolvedBusinessUnit = form.businessUnit.trim() || null;
      if (resolvedBusinessUnit && resolvedBusinessUnit.startsWith("__new__")) {
        const rawName = resolvedBusinessUnit.replace(/^__new__/, "");
        const createdBu = await createBusinessUnitOption(rawName);
        resolvedBusinessUnit = createdBu.name;
        setBuOptions((prev) =>
          prev.map((b) => (b.id === form.businessUnit ? createdBu : b)),
        );
      }

      let resolvedWorkLocation = form.workLocation.trim() || null;
      if (resolvedWorkLocation && resolvedWorkLocation.startsWith("__new__")) {
        const rawName = resolvedWorkLocation.replace(/^__new__/, "");
        const createdLoc = await createWorkLocationOption(rawName);
        resolvedWorkLocation = createdLoc.name;
        setWorkLocOptions((prev) =>
          prev.map((w) => (w.id === form.workLocation ? createdLoc : w)),
        );
      }

      const selectedStatus = employeeStatusOptions.find((s) => s.id === form.employeeStatusId);
      const employeeStatusName = selectedStatus?.name ?? (mode === "create" ? "Active" : initialEmployee?.confirmationStatus || "Active");

      const bondDelivered = form.bondDelivered.trim() || "No";
      const bondDurationMonths =
        bondDelivered === "Yes" ? Number(form.bondDurationMonths || "0") : 0;
      const bondExpiryIso =
        bondDelivered === "Yes"
          ? formatBondExpiryDisplay(form.joiningDate, bondDelivered, form.bondDurationMonths)
          : null;
      const bondExpiryDate =
        bondExpiryIso && bondExpiryIso !== "No" && bondExpiryIso !== "—" ? bondExpiryIso : null;
      const bondStatus = computeBondStatus(
        bondDelivered,
        form.joiningDate,
        form.bondDurationMonths,
      );
      const empCode = form.employeeCode.trim();

      const calculatedCategory =
        form.workerType === "Intern"
          ? "Intern - Paid"
          : form.workerType === "Contract"
            ? "Contract-based"
            : bondDelivered === "Yes"
              ? "Permanent - Bond"
              : "Permanent - Without Bond";

      const experienceString =
        form.expType === "Fresher"
          ? "Fresher"
          : `${formatExpDisplay(form.priorTotalExpYears, form.priorTotalExpMonths) || form.priorTotalExp || "0"} (Relevant: ${formatExpDisplay(form.priorRelevantExpYears, form.priorRelevantExpMonths) || form.priorRelevantExp || "0"})`;

      const educationString = form.gradDegree
        ? `${form.gradDegree}${form.gradYear ? " (" + form.gradYear + ")" : ""}${
            form.postGradDegree && form.postGradDegree !== "NA"
              ? ", " + form.postGradDegree + (form.postGradYear && form.postGradYear !== "NA" ? " (" + form.postGradYear + ")" : "")
              : ""
          }`
        : blankToNull(form.education);

      // Probation status resolution
      const probationStatus =
        mode === "edit"
          ? form.probationStatus || (employeeStatusName === "Active - Probation" ? "Ongoing" : "Completed")
          : employeeStatusName === "Active - Probation"
            ? "Ongoing"
            : "Completed";

      const payload: Record<string, unknown> = {
        employeeCode: empCode,
        firstName: form.firstName.trim(),
        lastName: form.lastName.trim(),
        workEmail: form.workEmail.trim(),
        personalEmail: blankToNull(form.personalEmail),
        phone: blankToNull(form.phone),
        altPhone: blankToNull(form.altPhone),
        address: blankToNull(form.address),
        emergencyContact: blankToNull(form.emergencyContact),
        emergencyContactName: blankToNull(form.emergencyContactName),
        emergencyContactRelation: blankToNull(form.emergencyContactRelation),
        departmentId: resolvedDepartmentId,
        designationId: resolvedDesignationId,
        jobRoleId: resolvedJobRoleId,
        role: resolvedRoleName,
        reportingManagerId: resolvedReportingManagerId,
        businessUnit: resolvedBusinessUnit,
        workLocation: resolvedWorkLocation,
        category: calculatedCategory,
        joiningDate: blankToNull(form.joiningDate),
        status: employeeStatusName.startsWith("Inactive")
          ? "Inactive"
          : employeeStatusName.startsWith("Resignation")
            ? "Notice Period"
            : "Active",
        employeeStatusId: form.employeeStatusId || null,
        confirmationStatus: employeeStatusName,
        probationStatus,
        experience: experienceString,
        previousCompany: blankToNull(form.previousCompany),
        employmentType: blankToNull(form.workerType),
        bondDelivered,
        bondDurationMonths,
        bondExpiryDate,
        bondStatus,
        projectSite: resolvedWorkLocation === "Onsite" ? blankToNull(form.projectSite) : null,
        assetId: blankToNull(form.assetId),
        education: educationString,
        gradDegree: blankToNull(form.gradDegree),
        gradYear: blankToNull(form.gradYear),
        postGradDegree: form.postGradDegree === "NA" ? "NA" : blankToNull(form.postGradDegree),
        postGradYear: form.postGradYear === "NA" ? "NA" : blankToNull(form.postGradYear),
        expType: form.expType,
        priorTotalExp: formatExpDisplay(form.priorTotalExpYears, form.priorTotalExpMonths) || form.priorTotalExp || "0",
        priorRelevantExp: formatExpDisplay(form.priorRelevantExpYears, form.priorRelevantExpMonths) || form.priorRelevantExp || "0",
        certifications: csvToList(form.certifications),
        pmoDepartment: blankToNull(form.pmoDepartment),
        subDepartment: blankToNull(form.subDepartment),
        billableStatus: blankToNull(form.billableStatus),
        clientLocation: blankToNull(form.clientLocation),
        projectType: blankToNull(form.projectType),
        projectAllocated: blankToNull(form.projectAllocated),
        clientEngManagerMapping: blankToNull(form.clientEngManagerMapping),
      };

      let savedResult: Employee | undefined;
      if (mode === "create") {
        const created = await createEmployee(payload);
        savedResult = toUiEmployee(created);
        toast.success("Employee onboarded successfully");
      } else if (initialEmployee) {
        const updated = await updateEmployee(initialEmployee.id, payload);
        savedResult = toUiEmployee(updated);
        toast.success("Employee profile updated successfully");
      }

      await onSuccess(savedResult);
      onClose();
    } catch (error: any) {
      toast.error(error?.message ?? `Failed to ${mode === "create" ? "onboard" : "update"} employee`);
    } finally {
      setIsSubmitting(false);
    }
  };

  const panelContent = (
    <div className="fixed inset-0 z-[100] flex justify-end">
      <div className="absolute inset-0 bg-black/50 backdrop-blur-[1px] transition-opacity" onClick={onClose} />
      <div className="relative flex h-full w-full max-w-4xl flex-col bg-background shadow-2xl animate-in slide-in-from-right duration-200">
        {/* header */}
        <div className="flex items-center justify-between border-b border-border bg-card px-6 py-4">
          <div>
            <h2 className="text-base font-semibold text-foreground">
              {mode === "create" ? "Onboard New Employee" : `Edit Employee: ${initialEmployee?.firstName} ${initialEmployee?.lastName} (${initialEmployee?.id})`}
            </h2>
            <p className="text-xs text-muted-foreground">
              {mode === "create"
                ? "Fill in employee details to create their profile."
                : "Update employee details across the 5 canonical sections."}
            </p>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="rounded-md p-1.5 text-muted-foreground hover:bg-accent hover:text-foreground transition-colors"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <form
          noValidate
          autoComplete="off"
          autoCorrect="off"
          data-lpignore="true"
          data-1p-ignore="true"
          data-form-type="other"
          onSubmit={handleSubmit}
          className="relative flex min-h-0 flex-1 flex-col"
        >
          {/* Decoy fields absorb Chrome autofill */}
          <div aria-hidden="true" className="pointer-events-none absolute h-0 w-0 overflow-hidden opacity-0">
            <input type="text" name="username" autoComplete="username" tabIndex={-1} defaultValue="" />
            <input type="email" name="email" autoComplete="email" tabIndex={-1} defaultValue="" />
            <input type="password" name="password" autoComplete="new-password" tabIndex={-1} defaultValue="" />
          </div>

          {/* scrollable body */}
          <div className="flex-1 space-y-5 overflow-y-auto px-6 py-6">
            <FormSection title="1. Personal Information">
              <FormField
                label="First Name"
                name="firstName"
                required
                maxLength={FIELD_MAX.firstName}
                placeholder="First name"
                value={form.firstName}
                onChange={(v) => setField("firstName", v)}
                onBlur={() => blurField("firstName")}
                error={errors.firstName}
              />
              <FormField
                label="Last Name"
                name="lastName"
                required
                maxLength={FIELD_MAX.lastName}
                placeholder="Last name"
                value={form.lastName}
                onChange={(v) => setField("lastName", v)}
                onBlur={() => blurField("lastName")}
                error={errors.lastName}
              />
              <WorkEmailField
                required
                id="form-workEmail"
                prefix={workEmailPrefix}
                domain={workEmailDomain}
                domainOptions={emailDomainOptions}
                error={errors.workEmail}
                prefixInputProps={{
                  readOnly: true,
                  autoComplete: "new-password",
                  "data-lpignore": "true",
                  "data-1p-ignore": "true",
                  "data-bwignore": "true",
                  "data-form-type": "other",
                  onFocus: (e) => e.currentTarget.removeAttribute("readonly"),
                  onMouseDown: (e) => e.currentTarget.removeAttribute("readonly"),
                } as any}
                onPrefixChange={(raw) => {
                  const cleanPrefix = toEmailLocalPart(raw);
                  setWorkEmailPrefix(cleanPrefix);
                  const fullEmail = cleanPrefix ? `${cleanPrefix}@${workEmailDomain}` : "";
                  setForm((prev) => ({ ...prev, workEmail: fullEmail }));
                  setErrors((prev) => {
                    const next = { ...prev };
                    if (!cleanPrefix) next.workEmail = "Work email is required";
                    else if (!isValidEmailLocalPart(cleanPrefix))
                      next.workEmail = "Only alphanumeric and '.' allowed";
                    else delete next.workEmail;
                    return next;
                  });
                }}
                onDomainChange={(newDomain) => {
                  setWorkEmailDomain(newDomain);
                  const fullEmail = workEmailPrefix ? `${workEmailPrefix}@${newDomain}` : "";
                  setForm((prev) => ({ ...prev, workEmail: fullEmail }));
                  if (workEmailPrefix && isValidEmailLocalPart(workEmailPrefix)) {
                    setErrors((prev) => {
                      const next = { ...prev };
                      delete next.workEmail;
                      return next;
                    });
                  }
                }}
                onPrefixBlur={() => {
                  if (!workEmailPrefix) {
                    setErrors((prev) => ({ ...prev, workEmail: "Work email is required" }));
                  } else if (!isValidEmailLocalPart(workEmailPrefix)) {
                    setErrors((prev) => ({
                      ...prev,
                      workEmail: "Only alphanumeric and '.' allowed",
                    }));
                  }
                }}
              />
              <FormField
                label="Phone (Personal)"
                name="phone"
                required
                inputMode="numeric"
                maxLength={FIELD_MAX.phone}
                placeholder="10-digit number"
                prefix="+91"
                value={form.phone}
                onChange={(v) => setField("phone", v)}
                onBlur={() => blurField("phone")}
                error={errors.phone}
              />
              <FormField
                label="Alternate Contact Number"
                name="altPhone"
                inputMode="numeric"
                maxLength={FIELD_MAX.phone}
                placeholder="10-digit number"
                prefix="+91"
                value={form.altPhone}
                onChange={(v) => setField("altPhone", v)}
                onBlur={() => blurField("altPhone")}
                error={errors.altPhone}
              />
              <div>
                <FormSelect
                  label="Current Address - City"
                  required
                  error={errors.address}
                  options={[...MUMBAI_RAILWAY_STATIONS]}
                  value={form.address}
                  onChange={(v) => setField("address", v)}
                  placeholder="Select railway station (Western, Central, Harbour, Trans-Harbour)…"
                  showSearch
                />
              </div>

              {/* Emergency Contact Group Header */}
              <div className="col-span-full pt-3 pb-1 border-t border-border/70">
                <div className="flex items-center gap-2">
                  <span className="h-1.5 w-1.5 rounded-full bg-rose-500" />
                  <h4 className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                    Emergency Contact Details
                  </h4>
                </div>
              </div>

              <FormField
                label="Emergency Contact Name"
                name="emergencyContactName"
                required
                maxLength={FIELD_MAX.emergencyContactName}
                placeholder="Full name of emergency contact"
                value={form.emergencyContactName}
                onChange={(v) => setField("emergencyContactName", v)}
                onBlur={() => blurField("emergencyContactName")}
                error={errors.emergencyContactName}
              />
              <FormField
                label="Emergency Contact Number"
                name="emergencyContact"
                required
                inputMode="numeric"
                maxLength={FIELD_MAX.phone}
                placeholder="10-digit number"
                prefix="+91"
                value={form.emergencyContact}
                onChange={(v) => setField("emergencyContact", v)}
                onBlur={() => blurField("emergencyContact")}
                error={errors.emergencyContact}
              />
              <FormSelect
                label="Relation with Emergency Contact"
                required
                error={errors.emergencyContactRelation}
                options={[...EMERGENCY_RELATION_OPTIONS]}
                value={form.emergencyContactRelation}
                onChange={(v) => setField("emergencyContactRelation", v)}
                placeholder="Select relation…"
              />
            </FormSection>

            <FormSection title="2. Organization Assignment">
              <TkIdField
                required
                prefix={tkPrefix}
                digits={splitTkId(form.employeeCode).digits}
                onChange={(prefix, digits) => {
                  setTkPrefix(prefix);
                  setField("employeeCode", joinTkId(prefix, digits));
                }}
                onBlur={() => blurField("employeeCode")}
                error={errors.employeeCode}
              />
              <CreatableCatalogSelect
                label="Department"
                required
                error={errors.departmentId}
                options={deptOptions}
                valueId={form.departmentId}
                onSelect={(id) => setField("departmentId", id)}
                onCreate={async (name) => {
                  const trimmed = name.trim();
                  const existing = deptOptions.find(
                    (d) => d.name.toLowerCase() === trimmed.toLowerCase(),
                  );
                  if (existing) return existing;
                  const temp = { id: `__new__${trimmed}`, code: `__new__${trimmed}`, name: trimmed };
                  setDeptOptions((prev) => [...prev, temp]);
                  return temp;
                }}
              />
              <CreatableCatalogSelect
                label="Designation"
                required
                error={errors.designationId}
                options={desigOptions}
                valueId={form.designationId}
                disabled={!form.departmentId}
                disabledHint="Select a department first"
                onSelect={(id) => setField("designationId", id)}
                onCreate={async (name) => {
                  const trimmed = name.trim();
                  const existing = desigOptions.find(
                    (d) => d.name.toLowerCase() === trimmed.toLowerCase(),
                  );
                  if (existing) return existing;
                  const temp = { id: `__new__${trimmed}`, code: `__new__${trimmed}`, name: trimmed };
                  setDesigOptions((prev) => [...prev, temp]);
                  return temp;
                }}
              />
              <CreatableCatalogSelect
                label="On Floor Role"
                options={roleOptions}
                valueId={form.jobRoleId}
                disabled={!form.designationId}
                disabledHint="Select a designation first"
                placeholder="Select on floor role"
                onSelect={(id) => setField("jobRoleId", id)}
                onCreate={async (name) => {
                  const trimmed = name.trim();
                  const existing = roleOptions.find(
                    (r) => r.name.toLowerCase() === trimmed.toLowerCase(),
                  );
                  if (existing) return existing;
                  const temp = { id: `__new__${trimmed}`, code: `__new__${trimmed}`, name: trimmed };
                  setRoleOptions((prev) => [...prev, temp]);
                  return temp;
                }}
              />
              <div className="md:col-span-2 lg:col-span-2">
                <CreatableCatalogSelect
                  label="Business Unit"
                  options={buOptions}
                  valueId={buOptions.find((b) => b.name === form.businessUnit || b.id === form.businessUnit)?.id ?? form.businessUnit}
                  placeholder="Select business unit"
                  onSelect={(id, name) => setField("businessUnit", name || id)}
                  onCreate={async (name) => {
                    const trimmed = name.trim();
                    const existing = buOptions.find((b) => b.name.toLowerCase() === trimmed.toLowerCase());
                    if (existing) return existing;
                    const temp = { id: `__new__${trimmed}`, code: `__new__${trimmed}`, name: trimmed };
                    setBuOptions((prev) => [...prev, temp]);
                    return temp;
                  }}
                />
              </div>
              <CreatableCatalogSelect
                label="Reporting Manager"
                required
                error={errors.reportingManagerId}
                options={managerOptions}
                valueId={
                  managerOptions.find(
                    (m) => m.id === form.reportingManagerId || (m.parentId && m.parentId === form.reportingManagerId),
                  )?.id ?? form.reportingManagerId
                }
                placeholder="Select reporting manager"
                onSelect={(id) => setField("reportingManagerId", id)}
                onCreate={async (name) => {
                  const trimmed = name.trim();
                  const existing = managerOptions.find(
                    (m) => m.name.toLowerCase() === trimmed.toLowerCase(),
                  );
                  if (existing) return existing;
                  const temp = { id: `__new__${trimmed}`, code: `__new__${trimmed}`, name: trimmed };
                  setManagerOptions((prev) => [...prev, temp]);
                  return temp;
                }}
              />
              <CreatableCatalogSelect
                label="Work Location"
                required
                error={errors.workLocation}
                options={workLocOptions}
                valueId={selectedWorkLoc?.id ?? form.workLocation}
                placeholder="Select work location"
                onSelect={(id, name) => {
                  const resolvedName = name || id;
                  const loc = workLocOptions.find(
                    (l) =>
                      l.id === id ||
                      l.name.toLowerCase() === resolvedName.toLowerCase() ||
                      (l.code && l.code.toLowerCase() === resolvedName.toLowerCase()),
                  );
                  const selectedName = loc ? loc.name : resolvedName;
                  setForm((prev) => ({
                    ...prev,
                    workLocation: selectedName,
                    projectSite: selectedName === "Onsite" ? prev.projectSite : "",
                  }));
                }}
                onCreate={async (name) => {
                  const trimmed = name.trim();
                  const existing = workLocOptions.find((w) => w.name.toLowerCase() === trimmed.toLowerCase());
                  if (existing) return existing;
                  try {
                    const created = await createWorkLocationOption(trimmed);
                    setWorkLocOptions((prev) => [...prev, created]);
                    return created;
                  } catch {
                    const temp = { id: `__new__${trimmed}`, code: `__new__${trimmed}`, name: trimmed };
                    setWorkLocOptions((prev) => [...prev, temp]);
                    return temp;
                  }
                }}
              />
              <FormField
                label="Location"
                disabled={form.workLocation !== "Onsite"}
                placeholder="Enter onsite location"
                maxLength={200}
                value={form.workLocation === "Onsite" ? form.projectSite : ""}
                onChange={(v) => setField("projectSite", v)}
              />
            </FormSection>

            <FormSection title="3. Employment Information">
              <FormField
                label="Date of Joining"
                type="date"
                required={mode === "create"}
                min={mode === "create" ? isoDateToday() : undefined}
                value={form.joiningDate}
                onChange={(v) => setField("joiningDate", v)}
                onBlur={() => blurField("joiningDate")}
                error={mode === "create" ? errors.joiningDate : undefined}
              />
              <FormField
                label="Asset ID"
                placeholder="e.g. AST-1001"
                maxLength={FIELD_MAX.assetId}
                value={form.assetId}
                onChange={(v) => setField("assetId", v)}
              />
              <FormSelect
                label="Employee Status"
                required
                error={errors.employeeStatusId}
                options={employeeStatusOptions.map((s) => ({ value: s.id, label: s.name }))}
                value={form.employeeStatusId}
                onChange={(v) => setField("employeeStatusId", v)}
              />
              {mode === "edit" ? (
                <FormSelect
                  label="Probation Status"
                  options={["Ongoing", "Completed", "Not Completed"]}
                  value={form.probationStatus || "Ongoing"}
                  onChange={(v) => setField("probationStatus", v)}
                />
              ) : null}
              <FormSelect
                label="Worker Type"
                required
                error={errors.workerType}
                options={[...WORKER_TYPES]}
                value={form.workerType}
                onChange={(v) => setField("workerType", v)}
              />
              <FormSelect
                label="Bond Delivered"
                required
                error={errors.bondDelivered}
                options={[...BOND_DELIVERED_OPTIONS]}
                value={form.bondDelivered}
                onChange={(v) => setField("bondDelivered", v)}
              />
              <FormField
                label="Bond Duration"
                inputMode="numeric"
                maxLength={3}
                placeholder="Months"
                suffix="months"
                disabled={form.bondDelivered !== "Yes"}
                value={form.bondDelivered === "Yes" ? form.bondDurationMonths : "0"}
                onChange={(v) => setField("bondDurationMonths", v)}
                onBlur={() => blurField("bondDurationMonths")}
                error={errors.bondDurationMonths}
              />
              <FormField
                label="Bond Expiry Date"
                readOnly
                value={bondExpiryDisplay}
              />
              <FormField
                label="Bond Status"
                readOnly
                value={bondStatusDisplay}
              />
            </FormSection>

            <FormSection title="4. Education & Experience">
              <CreatableCatalogSelect
                label="Graduation Degree Name"
                options={gradDegreeOptions}
                valueId={
                  gradDegreeOptions.find(
                    (g) => g.name.toLowerCase() === form.gradDegree.toLowerCase() || g.id === form.gradDegree,
                  )?.id ?? form.gradDegree
                }
                placeholder="Select or add graduation degree (BE, B.Tech, B.Sc)…"
                required={Boolean(form.gradYear && form.gradYear !== "NA")}
                error={errors.gradDegree}
                onSelect={(id, name) => {
                  setField("gradDegree", name || id);
                }}
                onCreate={async (name) => {
                  const created = await createGraduationDegreeOption(name);
                  setGradDegreeOptions((prev) => [...prev, created]);
                  return created;
                }}
              />

              <FormSelect
                label="Graduation - Passing Year"
                options={PASSING_YEAR_OPTIONS.map((y) => ({ value: y, label: y }))}
                value={form.gradYear}
                required={Boolean(form.gradDegree && form.gradDegree !== "NA")}
                onChange={(v) => {
                  setField("gradYear", v);
                }}
                placeholder="Select graduation passing year…"
                error={errors.gradYear}
              />

              <CreatableCatalogSelect
                label="Post Graduation Degree Name"
                options={postGradDegreeOptions}
                valueId={
                  postGradDegreeOptions.find(
                    (p) => p.name.toLowerCase() === form.postGradDegree.toLowerCase() || p.id === form.postGradDegree,
                  )?.id ?? form.postGradDegree
                }
                placeholder="Select or add post graduation degree (MBA, M.Tech, NA)…"
                error={errors.postGradDegree}
                onSelect={(id, name) => {
                  const degName = name || id;
                  setField("postGradDegree", degName);
                  if (degName === "NA") {
                    setField("postGradYear", "NA");
                  } else if (!formRef.current.postGradYear || formRef.current.postGradYear === "NA") {
                    setField("postGradYear", "");
                  }
                }}
                onCreate={async (name) => {
                  const created = await createPostGraduationDegreeOption(name);
                  setPostGradDegreeOptions((prev) => [...prev, created]);
                  return created;
                }}
              />

              <FormSelect
                label="Post Graduation - Passing Year"
                options={[
                  { value: "NA", label: "NA" },
                  ...PASSING_YEAR_OPTIONS.filter((y) => {
                    if (!form.gradYear || form.gradYear === "NA") return true;
                    const gYear = parseInt(form.gradYear, 10);
                    return isNaN(gYear) || parseInt(y, 10) >= gYear;
                  }).map((y) => ({ value: y, label: y })),
                ]}
                value={form.postGradDegree === "NA" ? "NA" : form.postGradYear}
                disabled={form.postGradDegree === "NA"}
                required={Boolean(form.postGradDegree && form.postGradDegree !== "NA")}
                onChange={(v) => {
                  setField("postGradYear", v);
                }}
                placeholder="Select post graduation passing year…"
                error={errors.postGradYear}
              />

              <FormSelect
                label="Exp / Fresher"
                options={[
                  { value: "Fresher", label: "Fresher" },
                  { value: "Experienced", label: "Experienced" },
                ]}
                value={form.expType || "Fresher"}
                onChange={(v) => {
                  setForm((prev) => ({
                    ...prev,
                    expType: v,
                    priorTotalExp: v === "Fresher" ? "0" : prev.priorTotalExp === "0" ? "" : prev.priorTotalExp,
                    priorRelevantExp: v === "Fresher" ? "0" : prev.priorRelevantExp === "0" ? "" : prev.priorRelevantExp,
                    priorTotalExpYears: v === "Fresher" ? "0" : prev.priorTotalExpYears === "0" ? "" : prev.priorTotalExpYears,
                    priorTotalExpMonths: v === "Fresher" ? "0" : prev.priorTotalExpMonths === "0" ? "" : prev.priorTotalExpMonths,
                    priorRelevantExpYears: v === "Fresher" ? "0" : prev.priorRelevantExpYears === "0" ? "" : prev.priorRelevantExpYears,
                    priorRelevantExpMonths: v === "Fresher" ? "0" : prev.priorRelevantExpMonths === "0" ? "" : prev.priorRelevantExpMonths,
                  }));
                }}
              />

              <div className="space-y-1">
                <span className={FORM_LABEL_CLS}>Total exp prior to Talakunchi</span>
                <div className="grid grid-cols-2 gap-2">
                  <FormField
                    label=""
                    placeholder="0"
                    suffix="yrs"
                    inputMode="numeric"
                    maxLength={2}
                    disabled={form.expType === "Fresher"}
                    value={form.expType === "Fresher" ? "0" : form.priorTotalExpYears}
                    onChange={(v) => setField("priorTotalExpYears", v)}
                    onBlur={() => blurField("priorTotalExpYears")}
                    error={Boolean(errors.priorTotalExpYears)}
                    hideErrorText
                  />
                  <FormField
                    label=""
                    placeholder="0"
                    suffix="months"
                    inputMode="numeric"
                    maxLength={2}
                    disabled={form.expType === "Fresher"}
                    value={form.expType === "Fresher" ? "0" : form.priorTotalExpMonths}
                    onChange={(v) => setField("priorTotalExpMonths", v)}
                    onBlur={() => blurField("priorTotalExpMonths")}
                    error={Boolean(errors.priorTotalExpMonths)}
                    hideErrorText
                  />
                </div>
                {errors.priorTotalExpMonths ? (
                  <p className={FORM_ERROR_CLS}>{errors.priorTotalExpMonths}</p>
                ) : (errors.priorTotalExp || errors.priorTotalExpYears) ? (
                  <p className={FORM_ERROR_CLS}>{errors.priorTotalExp || errors.priorTotalExpYears}</p>
                ) : null}
              </div>

              <div className="space-y-1">
                <span className={FORM_LABEL_CLS}>Relevant exp prior to Talakunchi</span>
                <div className="grid grid-cols-2 gap-2">
                  <FormField
                    label=""
                    placeholder="0"
                    suffix="yrs"
                    inputMode="numeric"
                    maxLength={2}
                    disabled={form.expType === "Fresher"}
                    value={form.expType === "Fresher" ? "0" : form.priorRelevantExpYears}
                    onChange={(v) => setField("priorRelevantExpYears", v)}
                    onBlur={() => blurField("priorRelevantExpYears")}
                    error={Boolean(errors.priorRelevantExpYears || errors.priorRelevantExp)}
                    hideErrorText
                  />
                  <FormField
                    label=""
                    placeholder="0"
                    suffix="months"
                    inputMode="numeric"
                    maxLength={2}
                    disabled={form.expType === "Fresher"}
                    value={form.expType === "Fresher" ? "0" : form.priorRelevantExpMonths}
                    onChange={(v) => setField("priorRelevantExpMonths", v)}
                    onBlur={() => blurField("priorRelevantExpMonths")}
                    error={Boolean(errors.priorRelevantExpMonths || errors.priorRelevantExp || errors.priorRelevantExpYears)}
                    hideErrorText
                  />
                </div>
                {errors.priorRelevantExpMonths ? (
                  <p className={FORM_ERROR_CLS}>{errors.priorRelevantExpMonths}</p>
                ) : (errors.priorRelevantExp || errors.priorRelevantExpYears) ? (
                  <p className={FORM_ERROR_CLS}>{errors.priorRelevantExp || errors.priorRelevantExpYears}</p>
                ) : null}
              </div>

              <div className="md:col-span-2 lg:col-span-2">
                <CertificationMultiSelect
                  label="Certification Details"
                  certOptions={certOptions}
                  value={form.certifications}
                  onChange={(val) => setField("certifications", val)}
                  onCreate={async (name) => {
                    const created = await createCertificationOption(name);
                    setCertOptions((prev) => [...prev, created]);
                    return created;
                  }}
                />
              </div>
            </FormSection>

            {mode === "edit" && (
              <FormSection title="5. PMO Section">
                <FormSelect
                  label="Department"
                  options={PMO_DEPARTMENT_OPTIONS}
                  value={form.pmoDepartment}
                  onChange={(v) => {
                    setField("pmoDepartment", v);
                    const subDepts = PMO_DEPARTMENT_SUB_DEPARTMENTS[v] ?? [];
                    if (subDepts.length === 1) {
                      setField("subDepartment", subDepts[0]);
                    } else if (!subDepts.includes(form.subDepartment)) {
                      setField("subDepartment", "");
                    }
                  }}
                  placeholder="Select department…"
                  showSearch
                />
                <FormSelect
                  label="Sub Departments"
                  options={pmoSubDeptOptions}
                  value={form.subDepartment}
                  onChange={(v) => setField("subDepartment", v)}
                  placeholder={
                    !form.pmoDepartment
                      ? "Select department first…"
                      : pmoSubDeptOptions.length === 0
                        ? "No sub-departments"
                        : "Select sub-department…"
                  }
                  disabled={!form.pmoDepartment || pmoSubDeptOptions.length === 0}
                  showSearch={pmoSubDeptOptions.length > 4}
                  error={errors.subDepartment}
                />
                <FormSelect
                  label="Billable / Non Billable Status"
                  options={[...BILLABLE_STATUS_OPTIONS]}
                  value={form.billableStatus}
                  onChange={(v) => setField("billableStatus", v)}
                  placeholder="Select status…"
                />
                <FormSelect
                  label="Client Location"
                  options={[...MUMBAI_RAILWAY_STATIONS]}
                  value={form.clientLocation}
                  onChange={(v) => setField("clientLocation", v)}
                  placeholder="Select railway station (Western, Central, Harbour, Trans-Harbour)…"
                  showSearch
                />
                <FormSelect
                  label="Project Type"
                  options={[...PROJECT_TYPE_OPTIONS]}
                  value={form.projectType}
                  onChange={(v) => setField("projectType", v)}
                  placeholder="Select project type…"
                />
                <FormSelect
                  label="Project Allocated"
                  options={projectAllocatedOptions}
                  value={form.projectAllocated}
                  onChange={(v) => {
                    setField("projectAllocated", v);
                    const autoEM = getEngagementManagerForProject(v);
                    setField("clientEngManagerMapping", autoEM);
                  }}
                  placeholder="Select allocated project…"
                  showSearch
                />
                <div className="space-y-1">
                  <FormField
                    label="Client Engagement Manager"
                    name="clientEngManagerMapping"
                    disabled
                    readOnly
                    placeholder={
                      form.projectAllocated && form.projectAllocated !== "Internal / Bench"
                        ? "Auto-derived from project's customer"
                        : "—"
                    }
                    value={form.clientEngManagerMapping}
                    onChange={(v) => setField("clientEngManagerMapping", v)}
                    onBlur={() => blurField("clientEngManagerMapping")}
                    error={errors.clientEngManagerMapping}
                  />
                  {form.projectAllocated && form.clientEngManagerMapping && form.projectAllocated !== "Internal / Bench" ? (
                    <p className="text-[11px] text-muted-foreground">
                      Auto-mapped from {form.projectAllocated} (Customer Engagement Manager)
                    </p>
                  ) : null}
                </div>
              </FormSection>
            )}
          </div>

          {/* footer */}
          <div className="flex items-center justify-end gap-2 border-t border-border bg-card px-6 py-4">
            <button
              type="button"
              onClick={onClose}
              className="rounded-md border border-input bg-card px-4 py-2 text-sm font-medium text-foreground hover:bg-accent transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 transition-all disabled:opacity-60 shadow-sm"
            >
              {isSubmitting
                ? mode === "create"
                  ? "Onboarding…"
                  : "Saving…"
                : mode === "create"
                  ? "Complete Onboarding"
                  : "Save Changes"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );

  return typeof document !== "undefined" ? createPortal(panelContent, document.body) : panelContent;
}
