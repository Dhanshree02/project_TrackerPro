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

export interface CatalogSubDepartment {
  id: string;
  name: string;
  services: CatalogServiceItem[];
}

export interface CatalogTreeDepartment {
  id: string;
  groupId: string;
  contractType: string;
  name: string;
  subDepartments: CatalogSubDepartment[];
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
  const [tree, setTree] = useState<CatalogTreeDepartment[]>([]);

  const loadFromDb = useCallback(async () => {
    try {
      const groups = await fetchServiceHierarchy();
      const ctList = groups.map((g) => g.name);
      const nextServices: Record<string, CatalogServiceItem[]> = {};
      const nextGroups: Record<string, "Resource" | "Scope"> = {};
      const nextTree: CatalogTreeDepartment[] = [];

      for (const group of groups) {
        const isRes =
          group.code.toUpperCase() === "RESOURCE" ||
          group.name.toLowerCase().includes("resource");
        const grpLabel: "Resource" | "Scope" = isRes ? "Resource" : "Scope";
        for (const dept of group.departments) {
          nextGroups[dept.name] = grpLabel;
          const items: CatalogServiceItem[] = [];
          const subDepartments: CatalogSubDepartment[] = [];
          for (const sub of dept.subDepartments) {
            const services: CatalogServiceItem[] = sub.services.map((svc) => ({
              id: svc.id,
              name: svc.name,
              tool: svc.defaultTools ?? "",
              unitPrice: svc.defaultUnitPrice ? Number(svc.defaultUnitPrice) : 0,
              days: svc.defaultDurationDays ?? 0,
            }));
            items.push(...services);
            subDepartments.push({ id: sub.id, name: sub.name, services });
          }
          nextServices[dept.name] = items;
          nextTree.push({
            id: dept.id,
            groupId: group.id,
            contractType: group.name,
            name: dept.name,
            subDepartments,
          });
        }
      }

      setContractTypes(ctList);
      setDeptServices(nextServices);
      setDeptGroups(nextGroups);
      setTree(nextTree);
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

  const getDepartmentsForContract = useCallback(
    (contractType: string) => tree.filter((dept) => dept.contractType === contractType).map((dept) => dept.name),
    [tree],
  );

  const getSubDepartments = useCallback(
    (contractType: string, department: string) =>
      tree.find((dept) => dept.contractType === contractType && dept.name === department)?.subDepartments.map((sub) => sub.name) ?? [],
    [tree],
  );

  const getGroupId = useCallback(
    (contractType: string) => tree.find((dept) => dept.contractType === contractType)?.groupId,
    [tree],
  );

  const getDepartmentId = useCallback(
    (contractType: string, department: string) =>
      tree.find((dept) => dept.contractType === contractType && dept.name === department)?.id,
    [tree],
  );

  const getSubDepartmentId = useCallback(
    (contractType: string, department: string, subDepartment: string) =>
      tree.find((dept) => dept.contractType === contractType && dept.name === department)?.subDepartments.find((sub) => sub.name === subDepartment)?.id,
    [tree],
  );

  const getServicesForSubDepartment = useCallback(
    (contractType: string, department: string, subDepartment: string) =>
      tree
        .find((dept) => dept.contractType === contractType && dept.name === department)
        ?.subDepartments.find((sub) => sub.name === subDepartment)?.services ?? [],
    [tree],
  );
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
    (name: string, group: "Resource" | "Scope" = "Scope", contractType?: string): { success: boolean; error?: string } => {
      const trimmed = name.trim();
      if (!trimmed) {
        return { success: false, error: "Department name is required." };
      }
      if (Object.keys(deptServices).some((d) => d.toLowerCase() === trimmed.toLowerCase())) {
        return { success: false, error: `Department "${trimmed}" already exists.` };
      }

      setDeptServices((prev) => ({ ...prev, [trimmed]: [] }));
      setDeptGroups((prev) => ({ ...prev, [trimmed]: group }));
      if (contractType?.trim()) {
        const contract = contractType.trim();
        setTree((prev) =>
          prev.some((dept) => dept.contractType === contract && dept.name.toLowerCase() === trimmed.toLowerCase())
            ? prev
            : [...prev, { id: "", groupId: "", contractType: contract, name: trimmed, subDepartments: [] }],
        );
      }
      toast.success(`Department "${trimmed}" added`);
      return { success: true };
    },
    [deptServices],
  );

  const addService = useCallback(
    (
      dept: string,
      service: { name: string; tool?: string; unitPrice?: number; days?: number },
      placement?: { contractType?: string; subDepartment?: string },
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
      const contract = placement?.contractType?.trim();
      const subName = placement?.subDepartment?.trim();
      if (contract && subName) {
        setTree((prev) =>
          prev.map((node) => {
            if (node.contractType !== contract || node.name !== trimmedDept) return node;
            const hasSub = node.subDepartments.some((sub) => sub.name.toLowerCase() === subName.toLowerCase());
            const subDepartments = hasSub
              ? node.subDepartments.map((sub) =>
                  sub.name.toLowerCase() === subName.toLowerCase()
                    ? { ...sub, services: [...sub.services, newServiceItem] }
                    : sub,
                )
              : [...node.subDepartments, { id: "", name: subName, services: [newServiceItem] }];
            return { ...node, subDepartments };
          }),
        );
      }
      toast.success(`Service "${trimmedName}" added to ${trimmedDept}`);
      return { success: true };
    },
    [deptServices],
  );

  const resetCatalog = useCallback(() => loadFromDb(), [loadFromDb]);

  return {
    contractTypes,
    departments,
    deptServices,
    deptGroups,
    allServices,
    getServicesForDepartment,
    getDepartmentsForContract,
    getSubDepartments,
    getServicesForSubDepartment,
    getGroupId,
    getDepartmentId,
    getSubDepartmentId,
    addContractType,
    addDepartment,
    addService,
    resetCatalog,
  };
}
