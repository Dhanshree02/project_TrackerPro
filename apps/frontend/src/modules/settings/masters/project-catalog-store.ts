import { useState, useEffect, useCallback } from "react";
import { toast } from "sonner";
import { fetchServiceHierarchy } from "@/lib/api/catalogs";

export interface CatalogServiceItem {
  id: string;
  name: string;
  tool: string;
  unitPrice: number;
  days: number;
}

export const DEFAULT_CONTRACT_TYPES: string[] = [];
export const DEFAULT_DEPT_GROUPS: Record<string, "Resource" | "Scope"> = {};
export const DEFAULT_DEPT_SERVICES: Record<string, CatalogServiceItem[]> = {};

export function getProjectCatalog() {
  return {
    contractTypes: [] as string[],
    departments: [] as string[],
    deptServices: {} as Record<string, CatalogServiceItem[]>,
    deptGroups: {} as Record<string, "Resource" | "Scope">,
    allServices: [] as string[],
  };
}

export function useProjectCatalogStore() {
  const [contractTypes, setContractTypes] = useState<string[]>([]);
  const [deptServices, setDeptServices] = useState<Record<string, CatalogServiceItem[]>>({});
  const [deptGroups, setDeptGroups] = useState<Record<string, "Resource" | "Scope">>({});

  const loadFromDb = useCallback(async () => {
    try {
      const groups = await fetchServiceHierarchy();
      const ctList = groups.map((g) => g.name);
      const nextServices: Record<string, CatalogServiceItem[]> = {};
      const nextGroups: Record<string, "Resource" | "Scope"> = {};

      for (const group of groups) {
        const isRes =
          group.code.toUpperCase() === "RESOURCE" ||
          group.name.toLowerCase().includes("resource");
        const grpLabel: "Resource" | "Scope" = isRes ? "Resource" : "Scope";
        for (const dept of group.departments) {
          nextGroups[dept.name] = grpLabel;
          const items: CatalogServiceItem[] = [];
          for (const sub of dept.subDepartments) {
            for (const svc of sub.services) {
              items.push({
                id: svc.code,
                name: svc.name,
                tool: svc.defaultTools ?? "",
                unitPrice: svc.defaultUnitPrice ? Number(svc.defaultUnitPrice) : 0,
                days: svc.defaultDurationDays ?? 0,
              });
            }
          }
          nextServices[dept.name] = items;
        }
      }

      setContractTypes(ctList);
      setDeptServices(nextServices);
      setDeptGroups(nextGroups);
    } catch {
      toast.error("Could not load project service catalog from database");
    }
  }, []);

  useEffect(() => {
    void loadFromDb();
  }, [loadFromDb]);

  const departments = Object.keys(deptServices);

  const allServices = Object.values(deptServices)
    .flatMap((items) => items.map((i) => i.name))
    .filter((v, idx, arr) => arr.indexOf(v) === idx);

  const getServicesForDepartment = useCallback(
    (dept: string): CatalogServiceItem[] => {
      return deptServices[dept] || [];
    },
    [deptServices],
  );

  const addContractType = useCallback(
    (name: string): { success: boolean; error?: string } => {
      const trimmed = name.trim();
      if (!trimmed) {
        return { success: false, error: "Contract Type name is required." };
      }
      if (contractTypes.some((ct) => ct.toLowerCase() === trimmed.toLowerCase())) {
        return { success: false, error: `Contract Type "${trimmed}" already exists.` };
      }

      setContractTypes((prev) => [...prev, trimmed]);
      toast.success(`Contract Type "${trimmed}" added`);
      return { success: true };
    },
    [contractTypes],
  );

  const addDepartment = useCallback(
    (name: string, group: "Resource" | "Scope" = "Scope"): { success: boolean; error?: string } => {
      const trimmed = name.trim();
      if (!trimmed) {
        return { success: false, error: "Department name is required." };
      }
      if (Object.keys(deptServices).some((d) => d.toLowerCase() === trimmed.toLowerCase())) {
        return { success: false, error: `Department "${trimmed}" already exists.` };
      }

      setDeptServices((prev) => ({ ...prev, [trimmed]: [] }));
      setDeptGroups((prev) => ({ ...prev, [trimmed]: group }));
      toast.success(`Department "${trimmed}" added`);
      return { success: true };
    },
    [deptServices],
  );

  const addService = useCallback(
    (
      dept: string,
      service: { name: string; tool?: string; unitPrice?: number; days?: number },
    ): { success: boolean; error?: string } => {
      const trimmedDept = dept.trim();
      const trimmedName = service.name.trim();

      if (!trimmedDept) {
        return { success: false, error: "Please select a Department first." };
      }
      if (!trimmedName) {
        return { success: false, error: "Service name is required." };
      }

      const existingDeptServices = deptServices[trimmedDept] || [];
      if (existingDeptServices.some((s) => s.name.toLowerCase() === trimmedName.toLowerCase())) {
        return { success: false, error: `Service "${trimmedName}" already exists in ${trimmedDept}.` };
      }

      const idPrefix = trimmedDept.replace(/[^A-Za-z0-9]/g, "").slice(0, 3).toUpperCase() || "SVC";
      const newServiceItem: CatalogServiceItem = {
        id: `${idPrefix}${String(existingDeptServices.length + 1).padStart(3, "0")}`,
        name: trimmedName,
        tool: service.tool?.trim() || "",
        unitPrice: service.unitPrice && service.unitPrice > 0 ? service.unitPrice : 0,
        days: service.days && service.days > 0 ? service.days : 0,
      };

      setDeptServices((prev) => ({
        ...prev,
        [trimmedDept]: [...existingDeptServices, newServiceItem],
      }));
      setDeptGroups((prev) => (prev[trimmedDept] ? prev : { ...prev, [trimmedDept]: "Scope" }));
      toast.success(`Service "${trimmedName}" added to ${trimmedDept}`);
      return { success: true };
    },
    [deptServices],
  );

  const resetCatalog = useCallback(() => {
    void loadFromDb();
  }, [loadFromDb]);

  return {
    contractTypes,
    departments,
    deptServices,
    deptGroups,
    allServices,
    getServicesForDepartment,
    addContractType,
    addDepartment,
    addService,
    resetCatalog,
  };
}
