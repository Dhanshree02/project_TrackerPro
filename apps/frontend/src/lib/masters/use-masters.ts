import { useState, useEffect, useCallback } from "react";
import { toast } from "sonner";
import type { CustomerMasterCategory, CustomerMastersState, ProjectMasterItem, SimpleMasterItem } from "./types";
import {
  INITIAL_CUSTOMER_MASTERS,
  INITIAL_PROJECT_MASTERS,
} from "./mock-data";
import { useProjectCatalogStore } from "./project-catalog-store";

const STORAGE_KEY_PROJECT = "trackerpro_project_masters_v2";
const STORAGE_KEY_CUSTOMER = "trackerpro_customer_masters_v1";

function loadFromStorage<T>(key: string, fallback: T): T {
  if (typeof window === "undefined") return fallback;
  try {
    const raw = localStorage.getItem(key);
    if (!raw) return fallback;
    return JSON.parse(raw);
  } catch (e) {
    console.error(`Failed to load ${key} from storage:`, e);
    return fallback;
  }
}

function saveToStorage<T>(key: string, value: T): void {
  if (typeof window === "undefined") return;
  try {
    localStorage.setItem(key, JSON.stringify(value));
  } catch (e) {
    console.error(`Failed to save ${key} to storage:`, e);
  }
}

export function useMastersStore() {
  const {
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
  } = useProjectCatalogStore();

  const [projectMasters, setProjectMasters] = useState<ProjectMasterItem[]>(() => {
    const loaded = loadFromStorage<ProjectMasterItem[]>(STORAGE_KEY_PROJECT, INITIAL_PROJECT_MASTERS);
    return (loaded || []).map((p) => ({
      ...p,
      contractType: p.contractType || p.group || "Scope Based",
      group: p.group || p.contractType || "Scope Based",
    }));
  });

  const [customerMasters, setCustomerMasters] = useState<CustomerMastersState>(() =>
    loadFromStorage<CustomerMastersState>(STORAGE_KEY_CUSTOMER, INITIAL_CUSTOMER_MASTERS),
  );

  // Sync with localStorage
  useEffect(() => {
    saveToStorage(STORAGE_KEY_PROJECT, projectMasters);
  }, [projectMasters]);

  useEffect(() => {
    saveToStorage(STORAGE_KEY_CUSTOMER, customerMasters);
  }, [customerMasters]);

  // --- Project Master Operations ---
  const addProjectMaster = useCallback(
    (item: Omit<ProjectMasterItem, "id" | "createdAt">): { success: boolean; error?: string } => {
      const contractTypeVal = (item.contractType || item.group || "").trim();
      // Validate
      if (!contractTypeVal) return { success: false, error: "Please select a Contract Type." };
      if (!item.department?.trim()) return { success: false, error: "Please select a Department." };
      if (!item.service?.trim()) return { success: false, error: "Please select a Service." };
      if (!item.tools?.trim()) return { success: false, error: "Tools field cannot be empty." };
      if (!item.duration?.trim()) return { success: false, error: "Duration field cannot be empty." };
      if (item.unitPrice === undefined || item.unitPrice === null || Number.isNaN(Number(item.unitPrice)) || Number(item.unitPrice) <= 0) {
        return { success: false, error: "Unit Price must be a positive numeric value." };
      }

      // Check duplicates (same contractType, department, service)
      const duplicate = projectMasters.some(
        (p) =>
          (p.contractType || p.group || "").toLowerCase() === contractTypeVal.toLowerCase() &&
          p.department.toLowerCase() === item.department.toLowerCase() &&
          p.service.toLowerCase() === item.service.toLowerCase(),
      );

      if (duplicate) {
        return {
          success: false,
          error: `A project master for ${contractTypeVal} → ${item.department} → ${item.service} already exists.`,
        };
      }

      const newItem: ProjectMasterItem = {
        id: `pm-${Date.now()}`,
        contractType: contractTypeVal,
        group: contractTypeVal,
        department: item.department.trim(),
        service: item.service.trim(),
        tools: item.tools.trim(),
        duration: item.duration.trim(),
        unitPrice: Number(item.unitPrice),
        createdAt: new Date().toISOString(),
      };

      setProjectMasters((prev) => [newItem, ...prev]);
      toast.success("Project Master added successfully");
      return { success: true };
    },
    [projectMasters],
  );

  const updateProjectMaster = useCallback(
    (id: string, item: Omit<ProjectMasterItem, "id" | "createdAt">): { success: boolean; error?: string } => {
      const contractTypeVal = (item.contractType || item.group || "").trim();
      if (!contractTypeVal) return { success: false, error: "Please select a Contract Type." };
      if (!item.department?.trim()) return { success: false, error: "Please select a Department." };
      if (!item.service?.trim()) return { success: false, error: "Please select a Service." };
      if (!item.tools?.trim()) return { success: false, error: "Tools field cannot be empty." };
      if (!item.duration?.trim()) return { success: false, error: "Duration field cannot be empty." };
      if (item.unitPrice === undefined || item.unitPrice === null || Number.isNaN(Number(item.unitPrice)) || Number(item.unitPrice) <= 0) {
        return { success: false, error: "Unit Price must be a positive numeric value." };
      }

      const duplicate = projectMasters.some(
        (p) =>
          p.id !== id &&
          (p.contractType || p.group || "").toLowerCase() === contractTypeVal.toLowerCase() &&
          p.department.toLowerCase() === item.department.toLowerCase() &&
          p.service.toLowerCase() === item.service.toLowerCase(),
      );

      if (duplicate) {
        return {
          success: false,
          error: `Another project master for ${contractTypeVal} → ${item.department} → ${item.service} already exists.`,
        };
      }

      setProjectMasters((prev) =>
        prev.map((p) =>
          p.id === id
            ? {
                ...p,
                contractType: contractTypeVal,
                group: contractTypeVal,
                department: item.department.trim(),
                service: item.service.trim(),
                tools: item.tools.trim(),
                duration: item.duration.trim(),
                unitPrice: Number(item.unitPrice),
              }
            : p,
        ),
      );
      toast.success("Project Master updated successfully");
      return { success: true };
    },
    [projectMasters],
  );

  const deleteProjectMaster = useCallback((id: string) => {
    setProjectMasters((prev) => prev.filter((p) => p.id !== id));
    toast.success("Project Master deleted");
  }, []);

  // --- Customer Master Operations ---
  const addCustomerMasterItem = useCallback(
    (category: CustomerMasterCategory, name: string, extra?: { code?: string; description?: string }): { success: boolean; error?: string } => {
      const trimmed = name.trim();
      if (!trimmed) {
        return { success: false, error: "Name is required." };
      }

      const list = customerMasters[category] || [];
      const duplicate = list.some((item) => item.name.toLowerCase() === trimmed.toLowerCase());
      if (duplicate) {
        return { success: false, error: `"${trimmed}" already exists in this master category.` };
      }

      const newItem: SimpleMasterItem = {
        id: `${category.slice(0, 3)}-${Date.now()}`,
        name: trimmed,
        code: extra?.code?.trim(),
        description: extra?.description?.trim(),
        createdAt: new Date().toISOString(),
      };

      setCustomerMasters((prev) => ({
        ...prev,
        [category]: [newItem, ...prev[category]],
      }));

      toast.success(`Added "${trimmed}" to ${category}`);
      return { success: true };
    },
    [customerMasters],
  );

  const updateCustomerMasterItem = useCallback(
    (
      category: CustomerMasterCategory,
      id: string,
      name: string,
      extra?: { code?: string; description?: string },
    ): { success: boolean; error?: string } => {
      const trimmed = name.trim();
      if (!trimmed) {
        return { success: false, error: "Name is required." };
      }

      const list = customerMasters[category] || [];
      const duplicate = list.some((item) => item.id !== id && item.name.toLowerCase() === trimmed.toLowerCase());
      if (duplicate) {
        return { success: false, error: `"${trimmed}" already exists in this master category.` };
      }

      setCustomerMasters((prev) => ({
        ...prev,
        [category]: prev[category].map((item) =>
          item.id === id
            ? {
                ...item,
                name: trimmed,
                code: extra?.code !== undefined ? extra.code.trim() : item.code,
                description: extra?.description !== undefined ? extra.description.trim() : item.description,
              }
            : item,
        ),
      }));

      toast.success(`Updated "${trimmed}"`);
      return { success: true };
    },
    [customerMasters],
  );

  const deleteCustomerMasterItem = useCallback((category: CustomerMasterCategory, id: string) => {
    setCustomerMasters((prev) => ({
      ...prev,
      [category]: prev[category].filter((item) => item.id !== id),
    }));
    toast.success("Master item deleted");
  }, []);

  const resetAllToDefaults = useCallback(() => {
    resetCatalog();
    setProjectMasters(INITIAL_PROJECT_MASTERS);
    setCustomerMasters(INITIAL_CUSTOMER_MASTERS);
    toast.info("Masters reset to default initial data");
  }, [resetCatalog]);

  return {
    projectMasters,
    customerMasters,
    contractTypes,
    groups: contractTypes,
    departments,
    deptServices,
    deptGroups,
    services: allServices,
    allServices,
    getServicesForDepartment,
    addContractType,
    addDepartment,
    addService,
    addProjectMaster,
    updateProjectMaster,
    deleteProjectMaster,
    addCustomerMasterItem,
    updateCustomerMasterItem,
    deleteCustomerMasterItem,
    resetAllToDefaults,
  };
}
