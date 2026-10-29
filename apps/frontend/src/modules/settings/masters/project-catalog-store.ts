import { useState, useEffect, useCallback } from "react";
import { toast } from "sonner";
import { fetchServiceHierarchy, createServiceSubDepartment } from "@/lib/api/catalogs";
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
  abbreviation?: string;
}

export const DEFAULT_CONTRACT_TYPES: string[] = [];
export const DEFAULT_DEPT_GROUPS: Record<string, "Resource" | "Scope"> = {};
export const DEFAULT_DEPT_SERVICES: Record<string, CatalogServiceItem[]> = {};

function deptKey(contractType: string, department: string) {
  return `${contractType.trim().toLowerCase()}::${department.trim().toLowerCase()}`;
}

function subDeptKey(contractType: string, department: string, subDepartment: string) {
  return `${contractType.trim().toLowerCase()}::${department.trim().toLowerCase()}::${subDepartment.trim().toLowerCase()}`;
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
  /** Key: contractType::department -> all services in dept */
  const [deptServices, setDeptServices] = useState<Record<string, CatalogServiceItem[]>>({});
  /** Key: contractType::department -> subDepartment names */
  const [deptSubDepartments, setDeptSubDepartments] = useState<Record<string, string[]>>({});
  /** Key: contractType::department::subDepartment -> services */
  const [subDeptServices, setSubDeptServices] = useState<Record<string, CatalogServiceItem[]>>({});
  const [deptGroups, setDeptGroups] = useState<Record<string, "Resource" | "Scope">>({});
  const [contractTypeDepts, setContractTypeDepts] = useState<Record<string, string[]>>({});

  const loadFromDb = useCallback(async () => {
    try {
      const groups = await fetchServiceHierarchy();
      const ctList = groups.map((g) => g.name);
      const nextServices: Record<string, CatalogServiceItem[]> = {};
      const nextDeptSubDepartments: Record<string, string[]> = {};
      const nextSubDeptServices: Record<string, CatalogServiceItem[]> = {};
      const nextGroups: Record<string, "Resource" | "Scope"> = {};
      const nextContractTypeDepts: Record<string, string[]> = {};

      for (const group of groups) {
        const cKey = group.name.trim().toLowerCase();
        nextContractTypeDepts[cKey] = group.departments.map((d) => d.name);
        const isRes =
          group.code.toUpperCase() === "RESOURCE" ||
          group.name.toLowerCase().includes("resource");
        const grpLabel: "Resource" | "Scope" = isRes ? "Resource" : "Scope";
        for (const dept of group.departments) {
          const dKey = deptKey(group.name, dept.name);
          nextGroups[dKey] = grpLabel;
          const deptAllItems: CatalogServiceItem[] = [];
          const subNames: string[] = [];

          for (const sub of dept.subDepartments) {
            subNames.push(sub.name);
            const sdKey = subDeptKey(group.name, dept.name, sub.name);
            const subItems: CatalogServiceItem[] = [];
            for (const svc of sub.services) {
              const item: CatalogServiceItem = {
                id: svc.id,
                name: svc.name,
                tool: svc.defaultTools ?? "",
                unitPrice: svc.defaultUnitPrice ? Number(svc.defaultUnitPrice) : 0,
                days: svc.defaultDurationDays ?? 0,
                abbreviation: svc.abbreviation ?? undefined,
              };
              subItems.push(item);
              deptAllItems.push(item);
            }
            nextSubDeptServices[sdKey] = subItems;
          }
          nextDeptSubDepartments[dKey] = subNames;
          nextServices[dKey] = deptAllItems;
        }
      }

      setContractTypes(ctList);
      setDeptServices(nextServices);
      setDeptSubDepartments(nextDeptSubDepartments);
      setSubDeptServices(nextSubDeptServices);
      setDeptGroups(nextGroups);
      setContractTypeDepts(nextContractTypeDepts);
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
        return Object.values(contractTypeDepts)
          .flat()
          .filter((v, idx, arr) => arr.indexOf(v) === idx);
      }
      const cKey = contractType.trim().toLowerCase();
      if (contractTypeDepts[cKey]?.length) {
        return contractTypeDepts[cKey];
      }
      const prefix = `${cKey}::`;
      return Object.keys(deptServices)
        .filter((k) => k.startsWith(prefix))
        .map((k) => k.slice(prefix.length));
    },
    [contractTypeDepts, deptServices],
  );

  const subDepartmentsForDepartment = useCallback(
    (contractType: string, dept: string): string[] => {
      return deptSubDepartments[deptKey(contractType, dept)] || [];
    },
    [deptSubDepartments],
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

  const getServicesForSubDepartment = useCallback(
    (contractType: string, dept: string, subDept: string): CatalogServiceItem[] => {
      return subDeptServices[subDeptKey(contractType, dept, subDept)] || [];
    },
    [subDeptServices],
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

  const addSubDepartment = useCallback(
    async (
      contractType: string,
      dept: string,
      name: string,
    ): Promise<{ success: boolean; error?: string }> => {
      const trimmedCt = contractType.trim();
      const trimmedDept = dept.trim();
      const trimmedName = name.trim();
      if (!trimmedCt) {
        return { success: false, error: "Please select a Contract Type first." };
      }
      if (!trimmedDept) {
        return { success: false, error: "Please select a Department first." };
      }
      if (!trimmedName) {
        return { success: false, error: "Sub-department name is required." };
      }

      const existing = deptSubDepartments[deptKey(trimmedCt, trimmedDept)] || [];
      if (existing.some((s) => s.toLowerCase() === trimmedName.toLowerCase())) {
        return { success: false, error: `Sub-department "${trimmedName}" already exists in ${trimmedDept}.` };
      }

      try {
        await createServiceSubDepartment(trimmedCt, trimmedDept, trimmedName);
        await loadFromDb();
        toast.success(`Sub-department "${trimmedName}" added to ${trimmedDept}`);
        return { success: true };
      } catch (error) {
        return {
          success: false,
          error: error instanceof Error ? error.message : "Could not add sub-department",
        };
      }
    },
    [deptSubDepartments, loadFromDb],
  );

  const addService = useCallback(
    async (
      contractType: string,
      dept: string,
      service: { name: string; tool?: string; unitPrice?: number; days?: number; subDepartment?: string; abbreviation?: string },
    ): Promise<{ success: boolean; error?: string }> => {
      const trimmedCt = contractType.trim();
      const trimmedDept = dept.trim();
      const trimmedName = service.name.trim();
      const trimmedSubDept = service.subDepartment?.trim();

      if (!trimmedCt) {
        return { success: false, error: "Please select a Contract Type first." };
      }
      if (!trimmedDept) {
        return { success: false, error: "Please select a Department first." };
      }
      if (!trimmedName) {
        return { success: false, error: "Service name is required." };
      }

      try {
        await createServiceOnly({
          contractType: trimmedCt,
          department: trimmedDept,
          subDepartment: trimmedSubDept || undefined,
          service: trimmedName,
          tools: service.tool?.trim(),
          durationDays: service.days,
          unitPrice: service.unitPrice,
          abbreviation: service.abbreviation?.trim() || undefined,
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
    [loadFromDb],
  );

  const resetCatalog = useCallback(() => {
    void loadFromDb();
  }, [loadFromDb]);

  const flatDepartments = Object.values(contractTypeDepts).flat().length
    ? Object.values(contractTypeDepts).flat().filter((v, idx, arr) => arr.indexOf(v) === idx)
    : Object.keys(deptServices).map((k) => k.split("::")[1] ?? k);

  return {
    contractTypes,
    departments: flatDepartments,
    departmentsForContractType: departments,
    subDepartmentsForDepartment,
    deptServices,
    deptSubDepartments,
    subDeptServices,
    deptGroups,
    allServices,
    getServicesForDepartment,
    getServicesForSubDepartment,
    addContractType,
    addDepartment,
    addSubDepartment,
    addService,
    resetCatalog,
    reloadCatalog: loadFromDb,
  };
}
