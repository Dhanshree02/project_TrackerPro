import { useState, useEffect, useCallback } from "react";
import { toast } from "sonner";
import { fetchServiceHierarchy } from "@/lib/api/catalogs";
import {
  createServiceDepartment,
  createServiceGroup,
  createServiceOnly,
} from "@/modules/settings/api/project-masters";

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

function deptKey(contractType: string, department: string) {
  return `${contractType.trim().toLowerCase()}::${department.trim().toLowerCase()}`;
}

function contractTypeFromDeptGroup(group: "Resource" | "Scope"): string {
  return group === "Resource" ? "Resource" : "Scope";
}

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
  /** Key: contractType::department */
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
          const key = deptKey(group.name, dept.name);
          nextGroups[key] = grpLabel;
          const items: CatalogServiceItem[] = [];
          for (const sub of dept.subDepartments) {
            for (const svc of sub.services) {
              items.push({
                id: svc.id,
                name: svc.name,
                tool: svc.defaultTools ?? "",
                unitPrice: svc.defaultUnitPrice ? Number(svc.defaultUnitPrice) : 0,
                days: svc.defaultDurationDays ?? 0,
              });
            }
          }
          nextServices[key] = items;
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

  const departments = useCallback(
    (contractType?: string) => {
      if (!contractType) {
        return Object.keys(deptServices).map((k) => k.split("::")[1] ?? k);
      }
      const prefix = `${contractType.trim().toLowerCase()}::`;
      return Object.keys(deptServices)
        .filter((k) => k.startsWith(prefix))
        .map((k) => k.slice(prefix.length));
    },
    [deptServices],
  );

  const allServices = Object.values(deptServices)
    .flatMap((items) => items.map((i) => i.name))
    .filter((v, idx, arr) => arr.indexOf(v) === idx);

  const getServicesForDepartment = useCallback(
    (contractType: string, dept: string): CatalogServiceItem[] => {
      return deptServices[deptKey(contractType, dept)] || [];
    },
    [deptServices],
  );

  const addContractType = useCallback(
    async (name: string): Promise<{ success: boolean; error?: string }> => {
      const trimmed = name.trim();
      if (!trimmed) {
        return { success: false, error: "Contract Type name is required." };
      }
      if (contractTypes.some((ct) => ct.toLowerCase() === trimmed.toLowerCase())) {
        return { success: false, error: `Contract Type "${trimmed}" already exists.` };
      }
      try {
        await createServiceGroup(trimmed);
        await loadFromDb();
        toast.success(`Contract Type "${trimmed}" added`);
        return { success: true };
      } catch (error) {
        return {
          success: false,
          error: error instanceof Error ? error.message : "Could not add contract type",
        };
      }
    },
    [contractTypes, loadFromDb],
  );

  const addDepartment = useCallback(
    async (
      name: string,
      contractTypeOrGroup: string | "Resource" | "Scope" = "Scope",
    ): Promise<{ success: boolean; error?: string }> => {
      const trimmed = name.trim();
      if (!trimmed) {
        return { success: false, error: "Department name is required." };
      }
      const contractType =
        contractTypeOrGroup === "Resource" || contractTypeOrGroup === "Scope"
          ? contractTypeFromDeptGroup(contractTypeOrGroup)
          : contractTypeOrGroup.trim();

      const key = deptKey(contractType, trimmed);
      if (key in deptServices) {
        return { success: false, error: `Department "${trimmed}" already exists for this contract type.` };
      }

      try {
        await createServiceDepartment(contractType, trimmed);
        await loadFromDb();
        toast.success(`Department "${trimmed}" added`);
        return { success: true };
      } catch (error) {
        return {
          success: false,
          error: error instanceof Error ? error.message : "Could not add department",
        };
      }
    },
    [deptServices, loadFromDb],
  );

  const addService = useCallback(
    async (
      contractType: string,
      dept: string,
      service: { name: string; tool?: string; unitPrice?: number; days?: number },
    ): Promise<{ success: boolean; error?: string }> => {
      const trimmedCt = contractType.trim();
      const trimmedDept = dept.trim();
      const trimmedName = service.name.trim();

      if (!trimmedCt) {
        return { success: false, error: "Please select a Contract Type first." };
      }
      if (!trimmedDept) {
        return { success: false, error: "Please select a Department first." };
      }
      if (!trimmedName) {
        return { success: false, error: "Service name is required." };
      }

      const existing = deptServices[deptKey(trimmedCt, trimmedDept)] || [];
      if (existing.some((s) => s.name.toLowerCase() === trimmedName.toLowerCase())) {
        return { success: false, error: `Service "${trimmedName}" already exists in ${trimmedDept}.` };
      }

      try {
        await createServiceOnly({
          contractType: trimmedCt,
          department: trimmedDept,
          service: trimmedName,
          tools: service.tool?.trim(),
          durationDays: service.days,
          unitPrice: service.unitPrice,
        });
        await loadFromDb();
        toast.success(`Service "${trimmedName}" added to ${trimmedDept}`);
        return { success: true };
      } catch (error) {
        return {
          success: false,
          error: error instanceof Error ? error.message : "Could not add service",
        };
      }
    },
    [deptServices, loadFromDb],
  );

  const resetCatalog = useCallback(() => {
    void loadFromDb();
  }, [loadFromDb]);

  const flatDepartments = Object.keys(deptServices).map((k) => k.split("::")[1] ?? k);

  return {
    contractTypes,
    departments: flatDepartments,
    departmentsForContractType: departments,
    deptServices,
    deptGroups,
    allServices,
    getServicesForDepartment,
    addContractType,
    addDepartment,
    addService,
    resetCatalog,
    reloadCatalog: loadFromDb,
  };
}
