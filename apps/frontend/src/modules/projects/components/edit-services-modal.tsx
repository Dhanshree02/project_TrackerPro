import React, { useState, useEffect, useMemo, useRef } from "react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  fetchServiceHierarchy,
  type ServiceHierarchyGroup,
  type ServiceHierarchyDept,
  type ServiceHierarchySubDept,
  type ServiceHierarchyItem,
} from "@/lib/api/catalogs";
import {
  type ApiProjectService,
  type ServiceModificationImpactDto,
  addProjectService,
  updateProjectService,
  deleteProjectService,
  fetchServiceModificationImpact,
} from "../api/projects";
import { toast } from "sonner";
import {
  Plus,
  Trash2,
  Edit2,
  AlertTriangle,
  CheckCircle2,
  Layers,
  ArrowRight,
  Info,
  ShieldAlert,
  RotateCcw,
} from "lucide-react";

// --- Contract Type & Resource Helpers ---
export function isResourceContract(ct?: string | null): boolean {
  if (!ct) return false;
  const norm = ct.trim().toLowerCase();
  return norm === "resource" || norm === "resource based" || norm.startsWith("resource");
}

export function isScopeContract(ct?: string | null): boolean {
  if (!ct) return false;
  const norm = ct.trim().toLowerCase();
  return norm === "scope" || norm === "scope based" || norm.startsWith("scope");
}

// --- Date & Working Day Calculation Helpers ---
const HOURS_PER_DAY = 8;

export function parseIsoDate(iso: string): Date | null {
  if (!iso) return null;
  const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(iso);
  if (!m) return null;
  return new Date(Number(m[1]), Number(m[2]) - 1, Number(m[3]));
}

export function formatIsoDate(d: Date): string {
  const y = d.getFullYear();
  const mo = String(d.getMonth() + 1).padStart(2, "0");
  const dd = String(d.getDate()).padStart(2, "0");
  return `${y}-${mo}-${dd}`;
}

export function isWeekend(d: Date): boolean {
  const dow = d.getDay();
  return dow === 0 || dow === 6; // Sunday = 0, Saturday = 6
}

export function snapToNextWorkingDay(d: Date): Date {
  const next = new Date(d.getTime());
  while (isWeekend(next)) {
    next.setDate(next.getDate() + 1);
  }
  return next;
}

export function snapToPrevWorkingDay(d: Date): Date {
  const prev = new Date(d.getTime());
  while (isWeekend(prev)) {
    prev.setDate(prev.getDate() - 1);
  }
  return prev;
}

export function addWorkingDays(startIso: string, days: number): string {
  const parsed = parseIsoDate(startIso);
  if (!parsed || days <= 0) return startIso || "";
  const d = snapToNextWorkingDay(parsed);
  let remaining = days;
  while (remaining > 1) {
    d.setDate(d.getDate() + 1);
    if (!isWeekend(d)) {
      remaining--;
    }
  }
  return formatIsoDate(d);
}

export function countWorkingDays(startIso: string, endIso: string): number {
  const start = parseIsoDate(startIso);
  const end = parseIsoDate(endIso);
  if (!start || !end || end < start) return 0;
  let count = 0;
  const d = new Date(start.getTime());
  while (d <= end) {
    if (!isWeekend(d)) count++;
    d.setDate(d.getDate() + 1);
  }
  return count;
}

export function addCalendarMonths(startIso: string, months: number): string {
  const d = parseIsoDate(startIso) || new Date(startIso);
  d.setMonth(d.getMonth() + months);
  const nonWeekend = isWeekend(d) ? snapToPrevWorkingDay(d) : d;
  return formatIsoDate(nonWeekend);
}

export function computeEndDate(row: {
  startDate: string;
  frequency: string;
  durationDays: number;
}): string {
  if (!row.startDate) return "";
  const parsedStart = parseIsoDate(row.startDate);
  const validStart = parsedStart ? snapToNextWorkingDay(parsedStart) : null;
  const startIso = validStart ? formatIsoDate(validStart) : row.startDate;

  if (row.frequency === "Half yearly") return addCalendarMonths(startIso, 6);
  if (row.frequency === "Yearly") return addCalendarMonths(startIso, 12);
  if (row.durationDays > 0) return addWorkingDays(startIso, row.durationDays);
  return "";
}

// --- Resource Level Distribution Helpers ---
export const RESOURCE_LEVELS = ["L1", "L2", "Senior"] as const;
export type ResourceLevelName = (typeof RESOURCE_LEVELS)[number];
export type ResourceDist = Record<ResourceLevelName, number>;

export const EMPTY_DIST = (): ResourceDist => ({ L1: 0, L2: 0, Senior: 0 });

export function distTotal(d: ResourceDist): number {
  return RESOURCE_LEVELS.reduce((sum, level) => sum + (Number(d[level]) || 0), 0);
}

export function formatDist(d: ResourceDist): string {
  return RESOURCE_LEVELS.filter((level) => (d[level] || 0) > 0)
    .map((level) => `${level}=${d[level]}`)
    .join(", ");
}

export function parseDist(s?: string | null): ResourceDist {
  const d = EMPTY_DIST();
  if (!s) return d;
  if (RESOURCE_LEVELS.includes(s as ResourceLevelName)) {
    d[s as ResourceLevelName] = 1;
    return d;
  }
  for (const part of s.split(",")) {
    const m = part.trim().match(/^(L1|L2|Senior)\s*=\s*(\d+)$/i);
    if (m) d[m[1] as ResourceLevelName] = Number(m[2]);
  }
  return d;
}

export function distToResourceLevel(d: ResourceDist, qty: number): string {
  if (qty <= 1) {
    return RESOURCE_LEVELS.find((level) => d[level] > 0) || "";
  }
  return formatDist(d);
}

interface ResourceDistSelectorProps {
  qty: number;
  resourceLevel: string;
  resourceDist: ResourceDist;
  onChange: (levelStr: string, dist: ResourceDist) => void;
}

function ResourceDistSelector({
  qty,
  resourceLevel,
  resourceDist,
  onChange,
}: ResourceDistSelectorProps) {
  const [open, setOpen] = useState(false);
  const [draft, setDraft] = useState<ResourceDist>(resourceDist);
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    setDraft(resourceDist);
  }, [resourceDist]);

  const assigned = distTotal(draft);
  const committedAssigned = distTotal(resourceDist);
  const isValid = qty <= 1 ? !!resourceLevel : committedAssigned === qty;

  function bump(level: ResourceLevelName, delta: number) {
    setDraft((prev) => {
      const next = { ...prev };
      const nextVal = (next[level] || 0) + delta;
      if (nextVal < 0) return prev;
      if (delta > 0 && distTotal(next) >= qty) return prev;
      next[level] = nextVal;
      return next;
    });
  }

  function handleSave() {
    const total = distTotal(draft);
    if (total !== qty) {
      toast.error(`Total resource distribution must equal ${qty} (currently ${total})`);
      return;
    }
    onChange(distToResourceLevel(draft, qty), draft);
    setOpen(false);
  }

  if (qty <= 1) {
    return (
      <select
        value={RESOURCE_LEVELS.includes(resourceLevel as ResourceLevelName) ? resourceLevel : ""}
        onChange={(e) => {
          const v = e.target.value as ResourceLevelName | "";
          const d = EMPTY_DIST();
          if (v) d[v] = 1;
          onChange(v, d);
        }}
        className={`h-8 w-full rounded-md border px-2 text-xs bg-background ${
          !isValid ? "border-destructive text-destructive" : "border-input"
        }`}
      >
        <option value="">— Select Level —</option>
        {RESOURCE_LEVELS.map((lvl) => (
          <option key={lvl} value={lvl}>
            {lvl}
          </option>
        ))}
      </select>
    );
  }

  return (
    <div className="relative" ref={containerRef}>
      <button
        type="button"
        onClick={() => {
          setDraft(resourceDist);
          setOpen((v) => !v);
        }}
        className={`h-8 w-full rounded-md border px-2.5 text-xs font-medium text-left truncate flex items-center justify-between transition-colors bg-background ${
          !isValid
            ? "border-destructive/70 bg-destructive/5 text-destructive"
            : "border-input hover:bg-accent/40"
        }`}
      >
        <span className="truncate">
          {formatDist(resourceDist) || "— Set Distribution —"}
        </span>
        <span
          className={`ml-1 shrink-0 px-1.5 py-0.2 rounded text-[10px] font-bold ${
            committedAssigned === qty
              ? "bg-emerald-100 text-emerald-800"
              : "bg-destructive/20 text-destructive"
          }`}
        >
          {committedAssigned}/{qty}
        </span>
      </button>

      {open && (
        <div className="absolute z-50 mt-1 w-64 rounded-lg border border-border bg-card p-3 shadow-lg text-xs space-y-2">
          <div className="flex items-center justify-between border-b pb-1.5">
            <span className="font-semibold text-foreground">Resource Distribution</span>
            <span
              className={`font-bold ${
                assigned === qty ? "text-emerald-600" : "text-amber-600"
              }`}
            >
              Total: {assigned} / {qty}
            </span>
          </div>

          <div className="space-y-1.5">
            {RESOURCE_LEVELS.map((lvl) => (
              <div key={lvl} className="flex items-center justify-between py-0.5">
                <span className="font-medium text-muted-foreground">{lvl}</span>
                <div className="flex items-center gap-1.5">
                  <button
                    type="button"
                    onClick={() => bump(lvl, -1)}
                    disabled={(draft[lvl] || 0) <= 0}
                    className="h-6 w-6 rounded border border-border bg-muted/40 font-bold hover:bg-muted disabled:opacity-40"
                  >
                    -
                  </button>
                  <span className="w-6 text-center font-bold">{draft[lvl] || 0}</span>
                  <button
                    type="button"
                    onClick={() => bump(lvl, 1)}
                    disabled={assigned >= qty}
                    className="h-6 w-6 rounded border border-border bg-muted/40 font-bold hover:bg-muted disabled:opacity-40"
                  >
                    +
                  </button>
                </div>
              </div>
            ))}
          </div>

          <div className="flex justify-end gap-1.5 pt-1 border-t">
            <Button
              type="button"
              variant="ghost"
              size="sm"
              className="h-7 text-xs"
              onClick={() => setOpen(false)}
            >
              Cancel
            </Button>
            <Button
              type="button"
              size="sm"
              className="h-7 text-xs bg-primary text-primary-foreground"
              disabled={assigned !== qty}
              onClick={handleSave}
            >
              Confirm ({assigned}/{qty})
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}

// --- Main Edit Services Modal Component ---
export interface EditServicesModalProps {
  isOpen: boolean;
  onClose: () => void;
  projectId: string;
  projectName: string;
  existingServices: ApiProjectService[];
  currency?: string;
  contractType?: string | null;
  projectType?: string | null;
  projectStartDate?: string | null;
  projectEndDate?: string | null;
  onServicesUpdated: () => void;
}

export function EditServicesModal({
  isOpen,
  onClose,
  projectId,
  projectName,
  existingServices,
  currency = "INR",
  contractType,
  projectType,
  projectStartDate,
  projectEndDate,
  onServicesUpdated,
}: EditServicesModalProps) {
  const [activeTab, setActiveTab] = useState<"list" | "add" | "review">("list");

  const isResource = isResourceContract(contractType);

  // Catalog state
  const [catalogHierarchy, setCatalogHierarchy] = useState<ServiceHierarchyGroup[]>([]);
  const [loadingCatalog, setLoadingCatalog] = useState(false);

  // Staged modifications and deletions
  const [stagedAdds, setStagedAdds] = useState<Array<any>>([]);
  const [stagedMods, setStagedMods] = useState<
    Array<{
      serviceId: string;
      serviceName: string;
      originalQty: number;
      targetQty: number;
      originalResourceLevel: string;
      targetResourceLevel: string;
      targetUnitPrice?: number;
      impact?: ServiceModificationImpactDto;
    }>
  >([]);
  const [stagedDeletes, setStagedDeletes] = useState<
    Array<{
      serviceId: string;
      serviceName: string;
      qty: number;
    }>
  >([]);

  // Editing state for an existing service (Modifying quantity)
  const [modifyingServiceId, setModifyingServiceId] = useState<string | null>(null);
  const [modQty, setModQty] = useState<number>(1);
  const [modLevel, setModLevel] = useState<string>("");
  const [modDist, setModDist] = useState<ResourceDist>(EMPTY_DIST());
  const [modImpact, setModImpact] = useState<ServiceModificationImpactDto | null>(null);
  const [loadingImpact, setLoadingImpact] = useState(false);

  // Deleting confirmation state
  const [deletingService, setDeletingService] = useState<ApiProjectService | null>(null);

  // Default start date (next working day from today or projectStartDate)
  const defaultStartDate = useMemo(() => {
    if (projectStartDate) {
      const p = parseIsoDate(projectStartDate);
      if (p) return formatIsoDate(snapToNextWorkingDay(p));
    }
    return formatIsoDate(snapToNextWorkingDay(new Date()));
  }, [projectStartDate]);

  // Add Service Form State
  const [selectedDept, setSelectedDept] = useState("");
  const [selectedSubDept, setSelectedSubDept] = useState("");
  const [serviceName, setServiceName] = useState("");
  const [isCustomServiceName, setIsCustomServiceName] = useState(false);
  const [serviceDescription, setServiceDescription] = useState("");
  const [serviceQty, setServiceQty] = useState<number>(1);
  const [serviceResourceLevel, setServiceResourceLevel] = useState("");
  const [serviceResourceDist, setServiceResourceDist] = useState<ResourceDist>(EMPTY_DIST());
  const [frequency, setFrequency] = useState<string>(
    projectType === "Short term (Ad-hoc)" ? "Once" : "Once"
  );
  const [serviceModel, setServiceModel] = useState<string>(isResource ? "NA" : "Initial Test");
  const [deliveryModel, setDeliveryModel] = useState<string>("Offsite");
  const [locationText, setLocationText] = useState("");
  const [finalDeliveryFormat, setFinalDeliveryFormat] = useState<string>("PDF");
  const [tools, setTools] = useState("");
  const [startDate, setStartDate] = useState(defaultStartDate);
  const [endDate, setEndDate] = useState(() =>
    computeEndDate({ startDate: defaultStartDate, frequency: "Once", durationDays: 5 })
  );
  const [durationDays, setDurationDays] = useState<number>(5);
  const [unitPrice, setUnitPrice] = useState<number>(50000);

  const [saving, setSaving] = useState(false);

  // Sync service model and frequency default whenever contractType or projectType changes
  useEffect(() => {
    if (isResource) {
      setServiceModel("NA");
    }
    if (projectType === "Short term (Ad-hoc)") {
      setFrequency("Once");
    }
  }, [isResource, projectType]);

  // Load catalog on mount
  useEffect(() => {
    if (!isOpen) return;
    setLoadingCatalog(true);
    fetchServiceHierarchy()
      .then((data) => {
        setCatalogHierarchy(data || []);
      })
      .catch((err) => {
        console.error("Failed to load catalog hierarchy:", err);
      })
      .finally(() => setLoadingCatalog(false));
  }, [isOpen]);

  // Hierarchy Group filtered by contract type (Resource group vs Scope group)
  const targetHierarchyGroup = useMemo(() => {
    if (!catalogHierarchy || catalogHierarchy.length === 0) return null;
    if (isResource) {
      return (
        catalogHierarchy.find(
          (g) => g.code.toUpperCase() === "RESOURCE" || g.name.toLowerCase().includes("resource")
        ) ?? null
      );
    }
    return (
      catalogHierarchy.find(
        (g) => g.code.toUpperCase() === "SCOPE" || g.name.toLowerCase().includes("scope")
      ) ?? null
    );
  }, [catalogHierarchy, isResource]);

  // Departments List from master catalog according to contract type
  const departmentsList = useMemo(() => {
    if (!catalogHierarchy || catalogHierarchy.length === 0) return [];
    const groups = targetHierarchyGroup ? [targetHierarchyGroup] : catalogHierarchy;
    const depts: Array<{ id: string; name: string; dept: ServiceHierarchyDept }> = [];
    groups.forEach((g) => {
      g.departments.forEach((d) => {
        if (!depts.some((existing) => existing.name === d.name)) {
          depts.push({ id: d.id, name: d.name, dept: d });
        }
      });
    });
    return depts;
  }, [catalogHierarchy, targetHierarchyGroup]);

  // Sub-Departments List under the selected Department
  const subDepartmentsList = useMemo(() => {
    if (!selectedDept) return [];
    const deptObj = departmentsList.find((d) => d.name === selectedDept);
    return deptObj?.dept.subDepartments || [];
  }, [selectedDept, departmentsList]);

  // Available Services under selected Sub-Department
  const availableServicesList = useMemo(() => {
    if (!selectedSubDept) return [];
    const subObj = subDepartmentsList.find((s) => s.name === selectedSubDept);
    return subObj?.services || [];
  }, [selectedSubDept, subDepartmentsList]);

  // Handler when selecting Service Name from the subdepartment catalog
  function handleServiceNameSelect(nameVal: string) {
    if (nameVal === "__custom__") {
      setIsCustomServiceName(true);
      setServiceName("");
      return;
    }
    setIsCustomServiceName(false);
    setServiceName(nameVal);

    const svc = availableServicesList.find((s) => s.name === nameVal);
    if (svc) {
      setTools(svc.defaultTools || "");
      const price = svc.defaultUnitPrice ? Number(svc.defaultUnitPrice) : 50000;
      setUnitPrice(price);
      const days = svc.defaultDurationDays || 5;
      setDurationDays(days);
      const computedEnd = computeEndDate({
        startDate,
        frequency,
        durationDays: days,
      });
      setEndDate(computedEnd);
      setServiceDescription(svc.description || "");
    }
  }

  // Recalculate end date and hours when start date, frequency, or duration days change
  function handleStartDateChange(newStart: string) {
    setStartDate(newStart);
    const computed = computeEndDate({
      startDate: newStart,
      frequency,
      durationDays,
    });
    if (computed) setEndDate(computed);
  }

  function handleFrequencyChange(newFreq: string) {
    setFrequency(newFreq);
    const computed = computeEndDate({
      startDate,
      frequency: newFreq,
      durationDays,
    });
    if (computed) {
      setEndDate(computed);
      if (newFreq === "Half yearly" || newFreq === "Yearly") {
        const workingDays = countWorkingDays(startDate, computed);
        if (workingDays > 0) setDurationDays(workingDays);
      }
    }
  }

  function handleDurationDaysChange(newDays: number) {
    const d = Math.max(1, newDays || 1);
    setDurationDays(d);
    const computed = computeEndDate({
      startDate,
      frequency,
      durationDays: d,
    });
    if (computed) setEndDate(computed);
  }

  function handleEndDateChange(newEnd: string) {
    setEndDate(newEnd);
    if (startDate && newEnd && newEnd >= startDate) {
      const working = countWorkingDays(startDate, newEnd);
      if (working > 0) setDurationDays(working);
    }
  }

  // Check impact when modifying service quantity downwards
  async function checkModificationImpact(svc: ApiProjectService, targetQty: number) {
    if (targetQty >= svc.qty) {
      setModImpact(null);
      return;
    }
    try {
      setLoadingImpact(true);
      const impact = await fetchServiceModificationImpact(projectId, svc.id, targetQty);
      setModImpact(impact);
    } catch (err) {
      console.warn("Could not fetch modification impact:", err);
    } finally {
      setLoadingImpact(false);
    }
  }

  function startModifying(svc: ApiProjectService) {
    setModifyingServiceId(svc.id);
    const currentQty = svc.qty || 1;
    setModQty(currentQty);
    setModLevel(svc.resourceLevel || "");
    setModDist(parseDist(svc.resourceLevel));
    setModImpact(null);
  }

  function stageModification(svc: ApiProjectService) {
    if (modQty === svc.qty && modLevel === (svc.resourceLevel || "")) {
      setModifyingServiceId(null);
      return;
    }
    const distTotalCount = distTotal(modDist);
    if (modQty > 1 && distTotalCount !== modQty) {
      toast.error(`Resource distribution total (${distTotalCount}) must equal quantity (${modQty})`);
      return;
    }

    setStagedMods((prev) => {
      const filtered = prev.filter((m) => m.serviceId !== svc.id);
      return [
        ...filtered,
        {
          serviceId: svc.id,
          serviceName: svc.serviceName,
          originalQty: svc.qty,
          targetQty: modQty,
          originalResourceLevel: svc.resourceLevel || "—",
          targetResourceLevel: modLevel,
          impact: modImpact || undefined,
        },
      ];
    });

    setModifyingServiceId(null);
    toast.info(`Modification staged for "${svc.serviceName}"`);
  }

  function stageDeletion(svc: ApiProjectService) {
    setStagedDeletes((prev) => {
      if (prev.some((d) => d.serviceId === svc.id)) return prev;
      return [...prev, { serviceId: svc.id, serviceName: svc.serviceName, qty: svc.qty }];
    });
    setStagedMods((prev) => prev.filter((m) => m.serviceId !== svc.id));
    setDeletingService(null);
    toast.info(`Service "${svc.serviceName}" marked for soft-deletion`);
  }

  // Prepares and stages a new service addition
  function handleStageNewService() {
    if (!selectedDept) {
      toast.error("Please select a Department.");
      return;
    }
    if (!selectedSubDept) {
      toast.error("Please select a Sub-Department.");
      return;
    }
    if (!serviceName.trim()) {
      toast.error("Please provide or select a Service Name.");
      return;
    }
    if (deliveryModel === "Onsite" && !locationText.trim()) {
      toast.error("Delivery Site / Location is required when Delivery Model is Onsite.");
      return;
    }
    const totalDist = distTotal(serviceResourceDist);
    if (serviceQty > 1 && totalDist !== serviceQty) {
      toast.error(`Resource distribution total (${totalDist}) must equal Quantity (${serviceQty}).`);
      return;
    }

    const durationHrs = durationDays * HOURS_PER_DAY;
    const totalDays = serviceQty * durationDays;
    const totalHrs = serviceQty * durationHrs;
    const total = serviceQty * unitPrice;

    // Determine next sequential Service ID (WBS-XX)
    const takenIds = new Set(
      [...existingServices, ...stagedAdds]
        .map((s) => s.taskId)
        .filter(Boolean)
    );
    let nextNum = 1;
    while (takenIds.has(`WBS-${String(nextNum).padStart(2, "0")}`)) {
      nextNum++;
    }
    const generatedTaskId = `WBS-${String(nextNum).padStart(2, "0")}`;

    const matchedCatalogSvc = availableServicesList.find((s) => s.name.trim().toLowerCase() === serviceName.trim().toLowerCase());
    const newServicePayload = {
      department: selectedDept,
      subDepartment: selectedSubDept,
      serviceCatalogId: matchedCatalogSvc?.id || null,
      serviceAbbreviation: (matchedCatalogSvc?.abbreviation || "").trim() || null,
      abbreviation: (matchedCatalogSvc?.abbreviation || "").trim() || null,
      taskId: generatedTaskId,
      serviceName: serviceName.trim(),
      description: serviceDescription.trim(),
      qty: serviceQty,
      resourceLevel: serviceResourceLevel || (serviceQty === 1 ? "L1" : formatDist(serviceResourceDist)),
      frequency,
      serviceModel: isResource ? "NA" : serviceModel,
      deliveryModel,
      location: deliveryModel,
      locationText: deliveryModel === "Onsite" ? locationText.trim() : "",
      finalDeliveryFormat,
      tools: tools.trim(),
      startDate,
      endDate,
      durationDays,
      durationHours: durationHrs,
      totalDays,
      totalHours: totalHrs,
      unitPrice,
      total,
      changeStatus: "Newly Added",
    };

    setStagedAdds((prev) => [...prev, newServicePayload]);
    toast.success(`Service "${serviceName.trim()}" added to staged changes`);

    // Reset add form
    setSelectedDept("");
    setSelectedSubDept("");
    setServiceName("");
    setIsCustomServiceName(false);
    setServiceDescription("");
    setServiceQty(1);
    setServiceResourceLevel("");
    setServiceResourceDist(EMPTY_DIST());
    setTools("");
    setActiveTab("list");
  }

  // Save all staged changes to backend
  async function handleSaveAllChanges() {
    setSaving(true);
    try {
      // 1. Process Soft Deletions
      for (const del of stagedDeletes) {
        await deleteProjectService(projectId, del.serviceId);
      }

      // 2. Process Staged Modifications
      for (const mod of stagedMods) {
        await updateProjectService(projectId, mod.serviceId, {
          qty: mod.targetQty,
          resourceLevel: mod.targetResourceLevel,
          asPendingModification: true,
        });
      }

      // 3. Process Staged Additions
      for (const add of stagedAdds) {
        await addProjectService(projectId, add);
      }

      toast.success("Service changes saved successfully!");
      setStagedAdds([]);
      setStagedMods([]);
      setStagedDeletes([]);
      onServicesUpdated();
      onClose();
    } catch (err: any) {
      console.error("Failed to save service changes:", err);
      toast.error(err?.message || "Failed to save service changes");
    } finally {
      setSaving(false);
    }
  }

  const totalStagedCount = stagedAdds.length + stagedMods.length + stagedDeletes.length;

  return (
    <>
      <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
        <DialogContent className="max-w-[95vw] xl:max-w-7xl max-h-[90vh] flex flex-col p-0 overflow-hidden">
          {/* Header */}
          <DialogHeader className="px-6 pt-5 pb-3 border-b border-border bg-card">
            <div className="flex items-center justify-between">
              <div>
                <DialogTitle className="text-base font-bold flex items-center gap-2">
                  <Layers className="h-5 w-5 text-primary" />
                  Manage Project Services (WBS)
                </DialogTitle>
                <DialogDescription className="text-xs text-muted-foreground mt-0.5">
                  Project: <span className="font-semibold text-foreground">{projectName}</span>
                  {contractType && (
                    <Badge variant="outline" className="ml-2 text-[10px] font-semibold bg-primary/5 text-primary">
                      Contract: {contractType}
                    </Badge>
                  )}
                </DialogDescription>
              </div>

              {/* Navigation Tabs */}
              <div className="flex items-center rounded-lg border border-border p-1 bg-muted/30 text-xs">
                <button
                  type="button"
                  onClick={() => setActiveTab("list")}
                  className={`px-3 py-1.5 rounded-md font-medium transition-colors ${
                    activeTab === "list"
                      ? "bg-background text-foreground shadow-xs"
                      : "text-muted-foreground hover:text-foreground"
                  }`}
                >
                  Current Services ({existingServices.length})
                </button>
                <button
                  type="button"
                  onClick={() => setActiveTab("add")}
                  className={`px-3 py-1.5 rounded-md font-medium transition-colors flex items-center gap-1.5 ${
                    activeTab === "add"
                      ? "bg-primary text-primary-foreground shadow-xs"
                      : "text-muted-foreground hover:text-foreground"
                  }`}
                >
                  <Plus className="h-3.5 w-3.5" />
                  Add Service
                </button>
                <button
                  type="button"
                  onClick={() => setActiveTab("review")}
                  className={`px-3 py-1.5 rounded-md font-medium transition-colors flex items-center gap-1.5 ${
                    activeTab === "review"
                      ? "bg-background text-foreground shadow-xs"
                      : "text-muted-foreground hover:text-foreground"
                  }`}
                >
                  Review Changes
                  {totalStagedCount > 0 && (
                    <span className="h-4 w-4 rounded-full bg-amber-500 text-white text-[10px] font-bold flex items-center justify-center">
                      {totalStagedCount}
                    </span>
                  )}
                </button>
              </div>
            </div>
          </DialogHeader>

          {/* Modal Content */}
          <div className="flex-1 overflow-y-auto p-6 bg-background">
            {/* TAB 1: CURRENT SERVICES LIST WITH PREDEFINED COLUMNS */}
            {activeTab === "list" && (
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <p className="text-xs text-muted-foreground">
                    Review and manage services assigned to this project. You can modify quantities or initiate soft deletions.
                  </p>
                  <Button
                    size="sm"
                    className="h-8 text-xs bg-primary text-primary-foreground gap-1.5"
                    onClick={() => setActiveTab("add")}
                  >
                    <Plus className="h-3.5 w-3.5" />
                    + Add New Service
                  </Button>
                </div>

                {/* Services Table */}
                <div className="overflow-x-auto rounded-lg border border-border shadow-xs bg-card">
                  <table className="min-w-[2100px] w-full text-xs text-left divide-y divide-border">
                    <thead className="bg-muted/60 uppercase tracking-wider text-[10px] font-bold text-muted-foreground">
                      <tr>
                        <th className="px-3 py-3 w-10 text-center">#</th>
                        <th className="px-3 py-3 min-w-[140px] whitespace-nowrap">Department</th>
                        <th className="px-3 py-3 min-w-[160px] whitespace-nowrap">Sub-Department</th>
                        <th className="px-3 py-3 min-w-[90px] whitespace-nowrap">Service ID</th>
                        <th className="px-3 py-3 min-w-[200px] whitespace-nowrap">Service Name</th>
                        <th className="px-3 py-3 min-w-[180px] whitespace-nowrap">Description</th>
                        <th className="px-3 py-3 min-w-[60px] text-center whitespace-nowrap">Qty</th>
                        <th className="px-3 py-3 min-w-[130px] text-center whitespace-nowrap">Resource Level</th>
                        <th className="px-3 py-3 min-w-[110px] whitespace-nowrap">Frequency</th>
                        <th className="px-3 py-3 min-w-[130px] whitespace-nowrap">Service Model</th>
                        <th className="px-3 py-3 min-w-[110px] whitespace-nowrap">Delivery Model</th>
                        <th className="px-3 py-3 min-w-[120px] whitespace-nowrap">Delivery Site</th>
                        <th className="px-3 py-3 min-w-[130px] whitespace-nowrap">Final Delivery Format</th>
                        <th className="px-3 py-3 min-w-[120px] whitespace-nowrap">Tools</th>
                        <th className="px-3 py-3 min-w-[110px] text-center whitespace-nowrap">WBS Start Date</th>
                        <th className="px-3 py-3 min-w-[110px] text-center whitespace-nowrap">WBS End Date</th>
                        <th className="px-3 py-3 min-w-[90px] text-center whitespace-nowrap">Duration (Days)</th>
                        <th className="px-3 py-3 min-w-[90px] text-center whitespace-nowrap">Duration (Hrs)</th>
                        <th className="px-3 py-3 min-w-[80px] text-center whitespace-nowrap">Total Days</th>
                        <th className="px-3 py-3 min-w-[80px] text-center whitespace-nowrap">Total Hrs</th>
                        <th className="px-3 py-3 min-w-[100px] text-right whitespace-nowrap">Unit Price</th>
                        <th className="px-3 py-3 min-w-[100px] text-right whitespace-nowrap">Total</th>
                        <th className="px-3 py-3 min-w-[110px] text-center whitespace-nowrap">Status</th>
                        <th className="px-3 py-3 min-w-[150px] text-center sticky right-0 bg-white shadow-[-4px_0_6px_-2px_rgba(0,0,0,0.06)] border-l border-border/40 z-20">Actions</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-border/60">
                      {existingServices.map((svc, idx) => {
                        const isStagedForDel = stagedDeletes.some((d) => d.serviceId === svc.id);
                        const stagedMod = stagedMods.find((m) => m.serviceId === svc.id);
                        const isModifying = modifyingServiceId === svc.id;
                        const isDeleted = svc.isDeleted || isStagedForDel;

                        return (
                          <React.Fragment key={svc.id}>
                            <tr
                              className={`hover:bg-accent/25 transition-colors ${
                                isDeleted
                                  ? "bg-destructive/5 opacity-60 line-through"
                                  : stagedMod
                                    ? "bg-amber-500/10"
                                    : ""
                              }`}
                            >
                              <td className="px-3 py-2 text-center text-muted-foreground">{idx + 1}</td>
                              <td className="px-3 py-2 font-medium whitespace-nowrap">{svc.department}</td>
                              <td className="px-3 py-2 text-muted-foreground whitespace-nowrap">{svc.subDepartment || "—"}</td>
                              <td className="px-3 py-2 font-mono text-[11px] text-muted-foreground whitespace-nowrap">
                                {svc.taskId || `WBS-${String(idx + 1).padStart(2, "0")}`}
                              </td>
                              <td className="px-3 py-2 font-semibold text-foreground whitespace-nowrap">
                                {svc.serviceName}
                              </td>
                              <td className="px-3 py-2 text-muted-foreground max-w-[200px] truncate" title={svc.description || ""}>
                                {svc.description || "—"}
                              </td>
                              <td className="px-3 py-2 text-center font-bold">
                                {stagedMod ? (
                                  <span className="text-amber-600 font-extrabold">
                                    {stagedMod.originalQty} ➔ {stagedMod.targetQty}
                                  </span>
                                ) : (
                                  svc.qty
                                )}
                              </td>
                              <td className="px-3 py-2 text-center whitespace-nowrap">
                                {stagedMod ? stagedMod.targetResourceLevel : svc.resourceLevel || "—"}
                              </td>
                              <td className="px-3 py-2 whitespace-nowrap">{svc.frequency || "Once"}</td>
                              <td className="px-3 py-2 whitespace-nowrap">{svc.serviceModel || "NA"}</td>
                              <td className="px-3 py-2 whitespace-nowrap">{svc.deliveryModel || svc.location || "Offsite"}</td>
                              <td className="px-3 py-2 whitespace-nowrap">{svc.locationText || "—"}</td>
                              <td className="px-3 py-2 whitespace-nowrap">{svc.finalDeliveryFormat || "PDF"}</td>
                              <td className="px-3 py-2 text-muted-foreground whitespace-nowrap">{svc.tools || "—"}</td>
                              <td className="px-3 py-2 text-center font-mono text-[11px] whitespace-nowrap">
                                {svc.startDate ? String(svc.startDate).slice(0, 10) : "—"}
                              </td>
                              <td className="px-3 py-2 text-center font-mono text-[11px] whitespace-nowrap">
                                {svc.endDate ? String(svc.endDate).slice(0, 10) : "—"}
                              </td>
                              <td className="px-3 py-2 text-center font-mono">{svc.durationDays || 5}</td>
                              <td className="px-3 py-2 text-center font-mono">{svc.durationHours || (svc.durationDays || 5) * 8}</td>
                              <td className="px-3 py-2 text-center font-mono">
                                {stagedMod ? (
                                  <span className="text-amber-600 font-bold">{stagedMod.targetQty * (svc.durationDays || 5)}</span>
                                ) : (
                                  svc.totalDays || (svc.qty || 1) * (svc.durationDays || 5)
                                )}
                              </td>
                              <td className="px-3 py-2 text-center font-mono">
                                {stagedMod ? (
                                  <span className="text-amber-600 font-bold">{stagedMod.targetQty * (svc.durationHours || 40)}</span>
                                ) : (
                                  svc.totalHours || (svc.qty || 1) * (svc.durationHours || 40)
                                )}
                              </td>
                              <td className="px-3 py-2 text-right font-mono">
                                {currency} {(svc.unitPrice || 0).toLocaleString()}
                              </td>
                              <td className="px-3 py-2 text-right font-mono font-bold">
                                {stagedMod ? (
                                  <span className="text-amber-600 font-bold">
                                    {currency} {(stagedMod.targetQty * (svc.unitPrice || 0)).toLocaleString()}
                                  </span>
                                ) : (
                                  `${currency} ${(svc.total || (svc.qty || 1) * (svc.unitPrice || 0)).toLocaleString()}`
                                )}
                              </td>
                              <td className="px-3 py-2 text-center whitespace-nowrap">
                                {isDeleted ? (
                                  <Badge variant="outline" className="text-[10px] bg-destructive/10 text-destructive border-destructive/20">
                                    Deleted
                                  </Badge>
                                ) : stagedMod ? (
                                  <Badge variant="outline" className="text-[10px] bg-amber-50 text-amber-700 border-amber-300">
                                    Mod Staged
                                  </Badge>
                                ) : svc.changeStatus === "Newly Added" ? (
                                  <Badge variant="outline" className="text-[10px] bg-blue-50 text-blue-700 border-blue-200">
                                    Newly Added
                                  </Badge>
                                ) : (
                                  <Badge variant="outline" className="text-[10px] bg-emerald-50 text-emerald-700 border-emerald-200">
                                    Active
                                  </Badge>
                                )}
                              </td>
                              <td className="px-3 py-2 text-center sticky right-0 bg-white shadow-[-4px_0_6px_-2px_rgba(0,0,0,0.06)] border-l border-border/30 whitespace-nowrap z-10">
                                {isStagedForDel ? (
                                  <Button
                                    size="sm"
                                    variant="ghost"
                                    className="h-7 text-xs text-muted-foreground hover:bg-muted"
                                    onClick={() => setStagedDeletes((prev) => prev.filter((d) => d.serviceId !== svc.id))}
                                  >
                                    <RotateCcw className="h-3.5 w-3.5 mr-1" />
                                    Undo Delete
                                  </Button>
                                ) : (
                                  <div className="flex items-center justify-center gap-1.5">
                                    <Button
                                      size="sm"
                                      variant="outline"
                                      className="h-7 text-xs"
                                      onClick={() => (isModifying ? setModifyingServiceId(null) : startModifying(svc))}
                                    >
                                      <Edit2 className="h-3.5 w-3.5 mr-1 text-primary" />
                                      {isModifying ? "Close" : "Modify"}
                                    </Button>
                                    <Button
                                      size="sm"
                                      variant="ghost"
                                      className="h-7 px-2 text-xs text-destructive hover:bg-destructive/10"
                                      onClick={() => setDeletingService(svc)}
                                    >
                                      <Trash2 className="h-3.5 w-3.5 mr-1" />
                                      Delete
                                    </Button>
                                  </div>
                                )}
                              </td>
                            </tr>

                            {/* INLINE MODIFY DRAWER */}
                            {isModifying && (
                              <tr className="bg-amber-500/5 border-b border-amber-500/20">
                                <td colSpan={24} className="p-4">
                                  <div className="max-w-xl rounded-lg border border-amber-300/80 bg-card p-4 space-y-3.5 shadow-xs">
                                    <div className="flex items-center justify-between pb-2 border-b border-border/60">
                                      <span className="text-xs font-bold text-foreground flex items-center gap-1.5">
                                        <Edit2 className="h-4 w-4 text-amber-600" />
                                        Modify Quantity &amp; Resource Distribution for: <span className="text-primary">{svc.serviceName}</span>
                                      </span>
                                      <span className="text-xs text-muted-foreground bg-muted/60 px-2.5 py-0.5 rounded border border-border">
                                        Current Qty: <strong className="text-foreground">{svc.qty}</strong>
                                      </span>
                                    </div>

                                    <div className="flex items-start gap-3">
                                      <div className="w-48">
                                        <label className="block text-xs font-semibold text-foreground mb-1.5 whitespace-nowrap">
                                          Target Quantity:
                                        </label>
                                        <input
                                          type="number"
                                          min={1}
                                          max={99}
                                          value={modQty}
                                          onChange={(e) => {
                                            const next = Math.max(1, parseInt(e.target.value) || 1);
                                            setModQty(next);
                                            checkModificationImpact(svc, next);
                                          }}
                                          className="h-8 w-full rounded-md border border-input bg-background px-3 text-xs font-semibold focus-visible:ring-1 focus-visible:ring-primary outline-none shadow-xs"
                                        />
                                      </div>

                                      <div className="w-48 space-y-3">
                                        <div>
                                          <label className="block text-xs font-semibold text-foreground mb-1.5 whitespace-nowrap">
                                            Resource Level Distribution:
                                          </label>
                                          <ResourceDistSelector
                                            qty={modQty}
                                            resourceLevel={modLevel}
                                            resourceDist={modDist}
                                            onChange={(lvlStr, dist) => {
                                              setModLevel(lvlStr);
                                              setModDist(dist);
                                            }}
                                          />
                                        </div>

                                        {/* Action buttons placed directly below Resource Level Distribution */}
                                        <div className="flex items-center gap-2 pt-1">
                                          <Button
                                            size="sm"
                                            variant="ghost"
                                            className="h-8 text-xs cursor-pointer px-3"
                                            onClick={() => setModifyingServiceId(null)}
                                          >
                                            Cancel
                                          </Button>
                                          <Button
                                            size="sm"
                                            className="h-8 text-xs bg-primary text-primary-foreground cursor-pointer px-3 whitespace-nowrap shadow-xs"
                                            onClick={() => stageModification(svc)}
                                          >
                                            Stage Modification
                                          </Button>
                                        </div>
                                      </div>
                                    </div>

                                    {/* IMPACT WARNING IF QUANTITY DECREASED */}
                                    {modQty < svc.qty && (
                                      <div className="rounded-lg border border-amber-500/40 bg-amber-500/10 p-3 text-xs space-y-1.5">
                                        <div className="flex items-center gap-2 font-bold text-amber-900">
                                          <AlertTriangle className="h-4 w-4 text-amber-600 shrink-0" />
                                          Quantity Reduction Impact Detected:
                                        </div>
                                        <p className="text-amber-800">
                                          Decreasing quantity from <strong>{svc.qty}</strong> to <strong>{modQty}</strong> will deactivate branch(es) beyond AP{modQty} (e.g. {modImpact?.removedBranchPhases?.join(", ") || `AP${modQty + 1}`}).
                                        </p>
                                        {loadingImpact ? (
                                          <p className="text-xs text-muted-foreground italic">Checking affected tasks &amp; recorded hours...</p>
                                        ) : modImpact && (
                                          <ul className="list-disc list-inside text-amber-900 font-medium pl-1 space-y-0.5">
                                            <li>Assigned task(s) affected: <strong>{modImpact.assignedTasksAffected}</strong></li>
                                            <li>Utilized hours recorded in branches: <strong>{modImpact.hoursUtilizedInAffectedBranches} hrs</strong></li>
                                            <li>Completed work present: <strong>{modImpact.hasCompletedWork ? "Yes" : "No"}</strong></li>
                                          </ul>
                                        )}
                                        <p className="text-[11px] text-muted-foreground pt-1 border-t border-amber-200">
                                          Historical work and timesheet logs will be safely retained in the database for audits, but active tracking will be discontinued for deactivated branches.
                                        </p>
                                      </div>
                                    )}
                                  </div>
                                </td>
                              </tr>
                            )}
                          </React.Fragment>
                        );
                      })}

                      {existingServices.length === 0 && (
                        <tr>
                          <td colSpan={24} className="px-4 py-8 text-center text-xs text-muted-foreground">
                            No services currently assigned to this project.
                          </td>
                        </tr>
                      )}
                    </tbody>
                  </table>
                </div>
              </div>
            )}

            {/* TAB 2: ADD NEW SERVICE FORM WITH SECTION A COLUMNS */}
            {activeTab === "add" && (
              <div className="space-y-4 max-w-4xl mx-auto">
                <div className="rounded-lg border border-border bg-muted/20 p-3 text-xs text-muted-foreground flex items-center gap-2">
                  <Info className="h-4 w-4 text-primary shrink-0" />
                  <span>
                    Adding service for contract type: <strong>{contractType || "Standard"}</strong>.
                    {isResource ? " Departments are populated from the Resource Group with Service Model set to NA." : " Departments are populated from the Service Catalog."}
                  </span>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                  {/* Department */}
                  <div>
                    <label className="block text-xs font-semibold text-foreground mb-1">
                      Department <span className="text-destructive">*</span>
                    </label>
                    <select
                      value={selectedDept}
                      onChange={(e) => {
                        setSelectedDept(e.target.value);
                        setSelectedSubDept("");
                        setServiceName("");
                        setIsCustomServiceName(false);
                      }}
                      className="h-8 w-full rounded-md border border-input bg-background px-2.5 text-xs focus-visible:ring-1 focus-visible:ring-primary outline-none"
                    >
                      <option value="">— Select Department —</option>
                      {departmentsList.map((d) => (
                        <option key={d.id} value={d.name}>
                          {d.name}
                        </option>
                      ))}
                    </select>
                  </div>

                  {/* Sub-Department */}
                  <div>
                    <label className="block text-xs font-semibold text-foreground mb-1">
                      Sub-Department <span className="text-destructive">*</span>
                    </label>
                    <select
                      value={selectedSubDept}
                      disabled={!selectedDept}
                      onChange={(e) => {
                        setSelectedSubDept(e.target.value);
                        setServiceName("");
                        setIsCustomServiceName(false);
                      }}
                      className="h-8 w-full rounded-md border border-input bg-background px-2.5 text-xs focus-visible:ring-1 focus-visible:ring-primary outline-none disabled:opacity-50"
                    >
                      <option value="">— Select Sub-Department —</option>
                      {subDepartmentsList.map((s) => (
                        <option key={s.id} value={s.name}>
                          {s.name}
                        </option>
                      ))}
                    </select>
                  </div>

                  {/* Service Name Selector (from master catalog under subdepartment) */}
                  <div>
                    <label className="block text-xs font-semibold text-foreground mb-1">
                      Service Name <span className="text-destructive">*</span>
                    </label>
                    {!isCustomServiceName ? (
                      <select
                        value={serviceName}
                        disabled={!selectedSubDept}
                        onChange={(e) => handleServiceNameSelect(e.target.value)}
                        className="h-8 w-full rounded-md border border-input bg-background px-2.5 text-xs focus-visible:ring-1 focus-visible:ring-primary outline-none disabled:opacity-50"
                      >
                        <option value="">— Select Service Name —</option>
                        {availableServicesList.map((svc) => (
                          <option key={svc.id} value={svc.name}>
                            {svc.name}
                          </option>
                        ))}
                        <option value="__custom__">+ Enter Custom Service Name</option>
                      </select>
                    ) : (
                      <div className="flex items-center gap-1">
                        <input
                          type="text"
                          value={serviceName}
                          onChange={(e) => setServiceName(e.target.value)}
                          placeholder="Type custom service name..."
                          className="h-8 w-full rounded-md border border-input bg-background px-2.5 text-xs focus-visible:ring-1 focus-visible:ring-primary outline-none"
                        />
                        <Button
                          type="button"
                          variant="ghost"
                          size="sm"
                          className="h-8 px-2 text-[10px]"
                          onClick={() => {
                            setIsCustomServiceName(false);
                            setServiceName("");
                          }}
                        >
                          Cancel
                        </Button>
                      </div>
                    )}
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                  {/* Description */}
                  <div className="md:col-span-2">
                    <label className="block text-xs font-semibold text-foreground mb-1">
                      Description / Scope
                    </label>
                    <input
                      type="text"
                      value={serviceDescription}
                      onChange={(e) => setServiceDescription(e.target.value)}
                      placeholder="e.g. Comprehensive scope and deliverable description"
                      className="h-8 w-full rounded-md border border-input bg-background px-2.5 text-xs focus-visible:ring-1 focus-visible:ring-primary outline-none"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                  {/* Quantity */}
                  <div>
                    <label className="block text-xs font-semibold text-foreground mb-1">
                      Quantity <span className="text-destructive">*</span>
                    </label>
                    <input
                      type="number"
                      min={1}
                      max={99}
                      value={serviceQty}
                      onChange={(e) => {
                        const val = Math.max(1, parseInt(e.target.value) || 1);
                        setServiceQty(val);
                      }}
                      className="h-8 w-full rounded-md border border-input bg-background px-2.5 text-xs focus-visible:ring-1 focus-visible:ring-primary outline-none font-semibold"
                    />
                  </div>

                  {/* Resource Level Distribution */}
                  <div>
                    <label className="block text-xs font-semibold text-foreground mb-1">
                      Resource Level
                    </label>
                    <ResourceDistSelector
                      qty={serviceQty}
                      resourceLevel={serviceResourceLevel}
                      resourceDist={serviceResourceDist}
                      onChange={(lvlStr, dist) => {
                        setServiceResourceLevel(lvlStr);
                        setServiceResourceDist(dist);
                      }}
                    />
                  </div>

                  {/* Frequency */}
                  <div>
                    <label className="block text-xs font-semibold text-foreground mb-1">
                      Frequency
                    </label>
                    {projectType === "Short term (Ad-hoc)" ? (
                      <input
                        type="text"
                        value="Once"
                        readOnly
                        className="h-8 w-full rounded-md border border-input bg-muted px-2.5 text-xs text-center cursor-not-allowed"
                      />
                    ) : (
                      <select
                        value={frequency}
                        onChange={(e) => handleFrequencyChange(e.target.value)}
                        className="h-8 w-full rounded-md border border-input bg-background px-2.5 text-xs focus-visible:ring-1 focus-visible:ring-primary outline-none"
                      >
                        <option value="Once">Once</option>
                        <option value="Half yearly">Half yearly</option>
                        <option value="Yearly">Yearly</option>
                      </select>
                    )}
                  </div>

                  {/* Service Model */}
                  <div>
                    <label className="block text-xs font-semibold text-foreground mb-1">
                      Service Model
                    </label>
                    {isResource ? (
                      <input
                        type="text"
                        value="NA"
                        readOnly
                        className="h-8 w-full rounded-md border border-input bg-muted px-2.5 text-xs text-center cursor-not-allowed"
                      />
                    ) : (
                      <select
                        value={serviceModel}
                        onChange={(e) => setServiceModel(e.target.value)}
                        className="h-8 w-full rounded-md border border-input bg-background px-2.5 text-xs focus-visible:ring-1 focus-visible:ring-primary outline-none"
                      >
                        <option value="Initial Test">Initial Test</option>
                        <option value="Initial + 1 Re-test">Initial + 1 Re-test</option>
                        <option value="Initial + 2 Re-test">Initial + 2 Re-test</option>
                        <option value="Initial + 3 Re-test">Initial + 3 Re-test</option>
                      </select>
                    )}
                  </div>
                </div>

                <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                  {/* Delivery Model */}
                  <div>
                    <label className="block text-xs font-semibold text-foreground mb-1">
                      Delivery Model
                    </label>
                    <select
                      value={deliveryModel}
                      onChange={(e) => {
                        const val = e.target.value;
                        setDeliveryModel(val);
                        if (val !== "Onsite") setLocationText("");
                      }}
                      className="h-8 w-full rounded-md border border-input bg-background px-2.5 text-xs focus-visible:ring-1 focus-visible:ring-primary outline-none"
                    >
                      <option value="Onsite">Onsite</option>
                      <option value="Offsite">Offsite</option>
                      <option value="Hybrid">Hybrid</option>
                    </select>
                  </div>

                  {/* Delivery Site / Location */}
                  <div>
                    <label className="block text-xs font-semibold text-foreground mb-1">
                      Delivery Site {deliveryModel === "Onsite" && <span className="text-destructive">*</span>}
                    </label>
                    <input
                      type="text"
                      value={locationText}
                      disabled={deliveryModel !== "Onsite"}
                      onChange={(e) => setLocationText(e.target.value)}
                      placeholder={deliveryModel === "Onsite" ? "e.g. Pune DC" : "—"}
                      className={`h-8 w-full rounded-md border border-input px-2.5 text-xs focus-visible:ring-1 focus-visible:ring-primary outline-none ${
                        deliveryModel !== "Onsite" ? "bg-muted cursor-not-allowed text-muted-foreground" : "bg-background"
                      }`}
                    />
                  </div>

                  {/* Final Delivery Format */}
                  <div>
                    <label className="block text-xs font-semibold text-foreground mb-1">
                      Final Delivery Format
                    </label>
                    <select
                      value={finalDeliveryFormat}
                      onChange={(e) => setFinalDeliveryFormat(e.target.value)}
                      className="h-8 w-full rounded-md border border-input bg-background px-2.5 text-xs focus-visible:ring-1 focus-visible:ring-primary outline-none"
                    >
                      <option value="PDF">PDF</option>
                      <option value="Excel">Excel</option>
                      <option value="Squad 1">Squad 1</option>
                      <option value="Other Toolbase">Other Toolbase</option>
                    </select>
                  </div>

                  {/* Tools */}
                  <div>
                    <label className="block text-xs font-semibold text-foreground mb-1">
                      Tools
                    </label>
                    <input
                      type="text"
                      value={tools}
                      onChange={(e) => setTools(e.target.value)}
                      placeholder="e.g. Jira, Burp Suite"
                      className="h-8 w-full rounded-md border border-input bg-background px-2.5 text-xs focus-visible:ring-1 focus-visible:ring-primary outline-none"
                    />
                  </div>
                </div>

                {/* DATES, DURATION & TOTALS */}
                <div className="grid grid-cols-2 md:grid-cols-4 gap-3 pt-1">
                  {/* WBS Start Date */}
                  <div>
                    <label className="block text-xs font-semibold text-foreground mb-1">
                      WBS Start Date
                    </label>
                    <input
                      type="date"
                      value={startDate}
                      onChange={(e) => handleStartDateChange(e.target.value)}
                      className="h-8 w-full rounded-md border border-input bg-background px-2 text-xs focus-visible:ring-1 focus-visible:ring-primary outline-none"
                    />
                  </div>

                  {/* WBS End Date */}
                  <div>
                    <label className="block text-xs font-semibold text-foreground mb-1">
                      WBS End Date
                    </label>
                    <input
                      type="date"
                      value={endDate}
                      min={startDate || undefined}
                      onChange={(e) => handleEndDateChange(e.target.value)}
                      className="h-8 w-full rounded-md border border-input bg-background px-2 text-xs focus-visible:ring-1 focus-visible:ring-primary outline-none"
                    />
                  </div>

                  {/* Duration (Days) */}
                  <div>
                    <label className="block text-xs font-semibold text-foreground mb-1">
                      Duration (Days)
                    </label>
                    <input
                      type="number"
                      min={1}
                      value={durationDays}
                      onChange={(e) => handleDurationDaysChange(parseInt(e.target.value) || 1)}
                      className="h-8 w-full rounded-md border border-input bg-background px-2 text-xs focus-visible:ring-1 focus-visible:ring-primary outline-none"
                    />
                  </div>

                  {/* Duration (Hrs) */}
                  <div>
                    <label className="block text-xs font-semibold text-foreground mb-1">
                      Duration (Hrs)
                    </label>
                    <input
                      type="number"
                      value={durationDays * HOURS_PER_DAY}
                      readOnly
                      className="h-8 w-full rounded-md border border-input bg-muted px-2 text-xs cursor-not-allowed font-mono"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 md:grid-cols-4 gap-3 pt-1">
                  {/* Total Days */}
                  <div>
                    <label className="block text-xs font-semibold text-foreground mb-1">
                      Total Days
                    </label>
                    <input
                      type="number"
                      value={serviceQty * durationDays}
                      readOnly
                      className="h-8 w-full rounded-md border border-input bg-muted px-2 text-xs cursor-not-allowed font-mono"
                    />
                  </div>

                  {/* Total Hrs */}
                  <div>
                    <label className="block text-xs font-semibold text-foreground mb-1">
                      Total Hrs
                    </label>
                    <input
                      type="number"
                      value={serviceQty * durationDays * HOURS_PER_DAY}
                      readOnly
                      className="h-8 w-full rounded-md border border-input bg-muted px-2 text-xs cursor-not-allowed font-mono"
                    />
                  </div>

                  {/* Unit Price */}
                  <div>
                    <label className="block text-xs font-semibold text-foreground mb-1">
                      Unit Price ({currency})
                    </label>
                    <input
                      type="number"
                      min={0}
                      value={unitPrice}
                      onChange={(e) => setUnitPrice(Math.max(0, parseFloat(e.target.value) || 0))}
                      className="h-8 w-full rounded-md border border-input bg-background px-2 text-xs focus-visible:ring-1 focus-visible:ring-primary outline-none font-mono"
                    />
                  </div>

                  {/* Total */}
                  <div>
                    <label className="block text-xs font-semibold text-foreground mb-1">
                      Total ({currency})
                    </label>
                    <input
                      type="text"
                      value={`${currency} ${(serviceQty * unitPrice).toLocaleString()}`}
                      readOnly
                      className="h-8 w-full rounded-md border border-input bg-muted px-2 text-xs cursor-not-allowed font-mono font-bold text-foreground"
                    />
                  </div>
                </div>

                <div className="flex justify-end gap-2 pt-3 border-t">
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    className="h-8 text-xs"
                    onClick={() => setActiveTab("list")}
                  >
                    Cancel
                  </Button>
                  <Button
                    type="button"
                    size="sm"
                    className="h-8 text-xs bg-primary text-primary-foreground gap-1.5"
                    onClick={handleStageNewService}
                  >
                    <Plus className="h-3.5 w-3.5" />
                    Stage Service Addition
                  </Button>
                </div>
              </div>
            )}

            {/* TAB 3: REVIEW STAGED CHANGES */}
            {activeTab === "review" && (
              <div className="space-y-4 max-w-3xl mx-auto">
                <div className="rounded-lg border border-border bg-card p-4 shadow-xs space-y-3">
                  <h4 className="text-sm font-bold text-foreground flex items-center gap-2">
                    <CheckCircle2 className="h-4 w-4 text-primary" />
                    Review Pending Service Changes
                  </h4>
                  <p className="text-xs text-muted-foreground">
                    Carefully review all additions, modifications, and deletions before committing.
                  </p>

                  {totalStagedCount === 0 && (
                    <div className="py-8 text-center text-xs text-muted-foreground">
                      No changes staged. Modify quantities or add a new service first.
                    </div>
                  )}

                  {/* Staged Additions */}
                  {stagedAdds.length > 0 && (
                    <div className="space-y-2 pt-2 border-t">
                      <span className="text-xs font-bold text-blue-700">
                        New Services to Add ({stagedAdds.length})
                      </span>
                      <div className="space-y-1.5">
                        {stagedAdds.map((add, i) => (
                          <div
                            key={i}
                            className="flex items-center justify-between rounded-md border border-blue-200 bg-blue-50/50 p-2.5 text-xs"
                          >
                            <div>
                              <span className="font-semibold text-foreground">{add.serviceName}</span>
                              <div className="text-[11px] text-muted-foreground">
                                {add.department} • {add.subDepartment} • Qty: {add.qty} ({add.resourceLevel}) • Duration: {add.durationDays} days • {currency} {add.total.toLocaleString()}
                              </div>
                            </div>
                            <Button
                              size="sm"
                              variant="ghost"
                              className="h-7 text-destructive text-xs"
                              onClick={() => setStagedAdds((prev) => prev.filter((_, idx) => idx !== i))}
                            >
                              Remove
                            </Button>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* Staged Modifications */}
                  {stagedMods.length > 0 && (
                    <div className="space-y-2 pt-2 border-t">
                      <span className="text-xs font-bold text-amber-700">
                        Service Modifications ({stagedMods.length})
                      </span>
                      <div className="space-y-1.5">
                        {stagedMods.map((mod) => (
                          <div
                            key={mod.serviceId}
                            className="flex items-center justify-between rounded-md border border-amber-200 bg-amber-50/50 p-2.5 text-xs"
                          >
                            <div>
                              <span className="font-semibold text-foreground">{mod.serviceName}</span>
                              <div className="text-[11px] text-amber-800 flex items-center gap-1.5 mt-0.5">
                                <span>Qty: {mod.originalQty} ➔ <strong>{mod.targetQty}</strong></span>
                                <span>•</span>
                                <span>Level: {mod.originalResourceLevel} ➔ <strong>{mod.targetResourceLevel}</strong></span>
                              </div>
                            </div>
                            <Button
                              size="sm"
                              variant="ghost"
                              className="h-7 text-destructive text-xs"
                              onClick={() => setStagedMods((prev) => prev.filter((m) => m.serviceId !== mod.serviceId))}
                            >
                              Remove
                            </Button>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* Staged Deletions */}
                  {stagedDeletes.length > 0 && (
                    <div className="space-y-2 pt-2 border-t">
                      <span className="text-xs font-bold text-destructive">
                        Services Marked for Soft Deletion ({stagedDeletes.length})
                      </span>
                      <div className="space-y-1.5">
                        {stagedDeletes.map((del) => (
                          <div
                            key={del.serviceId}
                            className="flex items-center justify-between rounded-md border border-destructive/20 bg-destructive/5 p-2.5 text-xs"
                          >
                            <div>
                              <span className="font-semibold text-foreground">{del.serviceName}</span>
                              <div className="text-[11px] text-muted-foreground">
                                Active work will be removed; historical timesheets and audit records retained.
                              </div>
                            </div>
                            <Button
                              size="sm"
                              variant="ghost"
                              className="h-7 text-xs"
                              onClick={() => setStagedDeletes((prev) => prev.filter((d) => d.serviceId !== del.serviceId))}
                            >
                              Cancel
                            </Button>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>

          {/* Footer */}
          <div className="px-6 py-3 border-t border-border bg-card flex items-center justify-between">
            <span className="text-xs text-muted-foreground">
              {totalStagedCount > 0 ? (
                <span>
                  <strong>{totalStagedCount}</strong> change(s) ready to commit
                </span>
              ) : (
                "No pending changes"
              )}
            </span>

            <div className="flex items-center gap-2">
              <Button
                type="button"
                variant="outline"
                size="sm"
                className="h-8 text-xs"
                onClick={onClose}
              >
                Close
              </Button>
              <Button
                type="button"
                size="sm"
                disabled={totalStagedCount === 0 || saving}
                className="h-8 text-xs bg-primary text-primary-foreground gap-1.5 shadow-xs"
                onClick={handleSaveAllChanges}
              >
                {saving ? "Saving..." : `Save All Changes (${totalStagedCount})`}
                <ArrowRight className="h-3.5 w-3.5" />
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>

      {/* CONFIRM SOFT DELETION DIALOG */}
      {deletingService && (
        <Dialog open={!!deletingService} onOpenChange={() => setDeletingService(null)}>
          <DialogContent className="max-w-md p-5 space-y-4">
            <DialogHeader>
              <DialogTitle className="text-sm font-bold text-destructive flex items-center gap-2">
                <ShieldAlert className="h-4 w-4" />
                Confirm Soft Deletion of Service
              </DialogTitle>
              <DialogDescription className="text-xs text-muted-foreground pt-1">
                Are you sure you want to delete <strong className="text-foreground">"{deletingService.serviceName}"</strong>?
              </DialogDescription>
            </DialogHeader>

            <div className="rounded-md border border-border bg-muted/30 p-3 text-xs space-y-2">
              <p className="text-foreground font-medium">This operation performs a safe soft deletion:</p>
              <ul className="list-disc list-inside text-muted-foreground space-y-1 pl-1">
                <li>Service and active task branches will be hidden from active work.</li>
                <li>Completed milestones, timesheets, and recorded hours are permanently preserved for audit.</li>
                <li>Can be viewed anytime by toggling "Show Inactive/Deleted".</li>
              </ul>
            </div>

            <div className="flex justify-end gap-2 pt-2">
              <Button
                size="sm"
                variant="outline"
                className="h-8 text-xs"
                onClick={() => setDeletingService(null)}
              >
                Cancel
              </Button>
              <Button
                size="sm"
                variant="destructive"
                className="h-8 text-xs gap-1.5"
                onClick={() => stageDeletion(deletingService)}
              >
                <Trash2 className="h-3.5 w-3.5" />
                Stage for Soft Deletion
              </Button>
            </div>
          </DialogContent>
        </Dialog>
      )}
    </>
  );
}
