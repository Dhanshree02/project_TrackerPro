import { useState, useEffect, useCallback } from "react";
import { toast } from "sonner";
import type {
  CustomerMasterCategory,
  CustomerMastersState,
  ProjectMasterItem,
  SimpleMasterItem,
  ResourceMastersState,
  ResourceMasterCategory,
  DepartmentHierarchyItem,
  EmailDomainItem,
  CityMasterItem,
  TkIdFormatItem,
  TkIdMasterItem,
  SimpleResourceMasterItem,
} from "./types";
import {
  INITIAL_CUSTOMER_MASTERS,
  INITIAL_PROJECT_MASTERS,
} from "./mock-data";
import { INITIAL_RESOURCE_MASTERS } from "./resource-mock-data";
import { useProjectCatalogStore } from "./project-catalog-store";

const STORAGE_KEY_PROJECT = "trackerpro_project_masters_v2";
const STORAGE_KEY_CUSTOMER = "trackerpro_customer_masters_v1";
const STORAGE_KEY_RESOURCE = "trackerpro_resource_masters_v2";

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

  const [resourceMasters, setResourceMasters] = useState<ResourceMastersState>(() =>
    loadFromStorage<ResourceMastersState>(STORAGE_KEY_RESOURCE, INITIAL_RESOURCE_MASTERS),
  );

  // Sync with localStorage
  useEffect(() => {
    saveToStorage(STORAGE_KEY_PROJECT, projectMasters);
  }, [projectMasters]);

  useEffect(() => {
    saveToStorage(STORAGE_KEY_CUSTOMER, customerMasters);
  }, [customerMasters]);

  useEffect(() => {
    saveToStorage(STORAGE_KEY_RESOURCE, resourceMasters);
  }, [resourceMasters]);

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

  // ── Resource Master Operations ──────────────────────────────────────────
  const addDepartmentHierarchyItem = useCallback(
    (item: Omit<DepartmentHierarchyItem, "id" | "createdAt">): { success: boolean; error?: string } => {
      if (!item.departmentName?.trim()) return { success: false, error: "Department is required." };
      if (!item.designationName?.trim()) return { success: false, error: "Designation is required." };
      if (!item.onFloorRoleName?.trim()) return { success: false, error: "On Floor Role is required." };
      if (!item.assignedRbacRoleName?.trim()) return { success: false, error: "Assigned RBAC Role is required." };

      const duplicate = resourceMasters.departmentHierarchy.some(
        (h) =>
          h.departmentName.toLowerCase() === item.departmentName.trim().toLowerCase() &&
          h.designationName.toLowerCase() === item.designationName.trim().toLowerCase() &&
          h.onFloorRoleName.toLowerCase() === item.onFloorRoleName.trim().toLowerCase(),
      );

      if (duplicate) {
        return {
          success: false,
          error: `Hierarchy mapping for ${item.departmentName} → ${item.designationName} → ${item.onFloorRoleName} already exists.`,
        };
      }

      const newItem: DepartmentHierarchyItem = {
        id: `dh-${Date.now()}`,
        departmentId: item.departmentId,
        departmentName: item.departmentName.trim(),
        designationId: item.designationId,
        designationName: item.designationName.trim(),
        onFloorRoleId: item.onFloorRoleId,
        onFloorRoleName: item.onFloorRoleName.trim(),
        assignedRbacRoleId: item.assignedRbacRoleId,
        assignedRbacRoleName: item.assignedRbacRoleName.trim(),
        assignedRbacRoleCode: item.assignedRbacRoleCode?.trim(),
        isActive: item.isActive !== undefined ? item.isActive : true,
        createdAt: new Date().toISOString(),
      };

      setResourceMasters((prev) => ({
        ...prev,
        departmentHierarchy: [newItem, ...prev.departmentHierarchy],
      }));

      toast.success(`Added hierarchy mapping: ${newItem.departmentName} → ${newItem.designationName}`);
      return { success: true };
    },
    [resourceMasters.departmentHierarchy],
  );

  const updateDepartmentHierarchyItem = useCallback(
    (id: string, item: Partial<Omit<DepartmentHierarchyItem, "id" | "createdAt">>): { success: boolean; error?: string } => {
      setResourceMasters((prev) => ({
        ...prev,
        departmentHierarchy: prev.departmentHierarchy.map((h) =>
          h.id === id
            ? {
                ...h,
                ...item,
                departmentName: item.departmentName ? item.departmentName.trim() : h.departmentName,
                designationName: item.designationName ? item.designationName.trim() : h.designationName,
                onFloorRoleName: item.onFloorRoleName ? item.onFloorRoleName.trim() : h.onFloorRoleName,
                assignedRbacRoleName: item.assignedRbacRoleName ? item.assignedRbacRoleName.trim() : h.assignedRbacRoleName,
              }
            : h,
        ),
      }));

      toast.success("Updated hierarchy mapping");
      return { success: true };
    },
    [],
  );

  const deleteDepartmentHierarchyItem = useCallback((id: string) => {
    setResourceMasters((prev) => ({
      ...prev,
      departmentHierarchy: prev.departmentHierarchy.filter((h) => h.id !== id),
    }));
    toast.success("Hierarchy mapping deleted");
  }, []);

  const addEmailDomain = useCallback(
    (domainName: string, extra?: { displayName?: string; code?: string }): { success: boolean; error?: string } => {
      const trimmed = domainName.trim().toLowerCase().replace(/^@/, "");
      if (!trimmed) return { success: false, error: "Domain name cannot be empty." };
      if (!trimmed.includes(".")) return { success: false, error: "Please enter a valid domain (e.g. talakunchi.in)." };

      if (resourceMasters.emailDomains.some((d) => d.domainName.toLowerCase() === trimmed)) {
        return { success: false, error: `Domain "${trimmed}" already exists.` };
      }

      const newItem: EmailDomainItem = {
        id: `edm-${Date.now()}`,
        domainName: trimmed,
        displayName: extra?.displayName?.trim() || `@${trimmed}`,
        code: extra?.code?.trim() || trimmed.replace(/\./g, "_"),
        isActive: true,
        createdAt: new Date().toISOString(),
      };

      setResourceMasters((prev) => ({
        ...prev,
        emailDomains: [newItem, ...prev.emailDomains],
      }));

      toast.success(`Added email domain: @${trimmed}`);
      return { success: true };
    },
    [resourceMasters.emailDomains],
  );

  const updateEmailDomain = useCallback(
    (id: string, domainName: string, extra?: { displayName?: string; code?: string; isActive?: boolean }): { success: boolean; error?: string } => {
      const trimmed = domainName.trim().toLowerCase().replace(/^@/, "");
      if (!trimmed) return { success: false, error: "Domain name cannot be empty." };

      setResourceMasters((prev) => ({
        ...prev,
        emailDomains: prev.emailDomains.map((d) =>
          d.id === id
            ? {
                ...d,
                domainName: trimmed,
                displayName: extra?.displayName !== undefined ? extra.displayName.trim() : `@${trimmed}`,
                code: extra?.code !== undefined ? extra.code.trim() : d.code,
                isActive: extra?.isActive !== undefined ? extra.isActive : d.isActive,
              }
            : d,
        ),
      }));

      toast.success(`Updated domain @${trimmed}`);
      return { success: true };
    },
    [],
  );

  const deleteEmailDomain = useCallback((id: string) => {
    setResourceMasters((prev) => ({
      ...prev,
      emailDomains: prev.emailDomains.filter((d) => d.id !== id),
    }));
    toast.success("Email domain deleted");
  }, []);

  const addCity = useCallback(
    (name: string, extra?: { line?: string; code?: string; stationName?: string }): { success: boolean; error?: string } => {
      const trimmed = name.trim();
      if (!trimmed) return { success: false, error: "Station / City name cannot be empty." };

      const line = extra?.line?.trim() || "Western Line";
      const value = `${trimmed} (${line})`;

      if (resourceMasters.cities.some((c) => c.name.toLowerCase() === trimmed.toLowerCase() && c.line.toLowerCase() === line.toLowerCase())) {
        return { success: false, error: `Station "${trimmed}" on "${line}" already exists.` };
      }

      const newItem: CityMasterItem = {
        id: `stn-${Date.now()}`,
        name: trimmed,
        line,
        subLabel: line,
        value,
        code: extra?.code?.trim() || trimmed.toLowerCase().replace(/\s+/g, "_"),
        stationName: extra?.stationName?.trim() || trimmed,
        isActive: true,
        createdAt: new Date().toISOString(),
      };

      setResourceMasters((prev) => ({
        ...prev,
        cities: [newItem, ...prev.cities],
      }));

      toast.success(`Added station / city: ${trimmed} (${line})`);
      return { success: true };
    },
    [resourceMasters.cities],
  );

  const updateCity = useCallback(
    (id: string, name: string, extra?: { line?: string; code?: string; stationName?: string; isActive?: boolean }): { success: boolean; error?: string } => {
      const trimmed = name.trim();
      if (!trimmed) return { success: false, error: "Station / City name cannot be empty." };

      setResourceMasters((prev) => ({
        ...prev,
        cities: prev.cities.map((c) => {
          if (c.id !== id) return c;
          const line = extra?.line !== undefined ? extra.line.trim() : c.line;
          return {
            ...c,
            name: trimmed,
            line,
            subLabel: line,
            value: `${trimmed} (${line})`,
            code: extra?.code !== undefined ? extra.code.trim() : c.code,
            stationName: extra?.stationName !== undefined ? extra.stationName.trim() : c.stationName,
            isActive: extra?.isActive !== undefined ? extra.isActive : c.isActive,
          };
        }),
      }));

      toast.success(`Updated station / city: ${trimmed}`);
      return { success: true };
    },
    [],
  );

  const deleteCity = useCallback((id: string) => {
    setResourceMasters((prev) => ({
      ...prev,
      cities: prev.cities.filter((c) => c.id !== id),
    }));
    toast.success("Station / City deleted");
  }, []);

  const addTkIdFormat = useCallback(
    (item: Omit<TkIdFormatItem, "id" | "createdAt" | "sampleFormat">): { success: boolean; error?: string } => {
      const prefix = item.prefix.trim().toUpperCase();
      if (!prefix) return { success: false, error: "Prefix code (e.g. TK, TKI) is required." };

      if (resourceMasters.tkIdFormats?.some((f) => f.prefix.toUpperCase() === prefix)) {
        return { success: false, error: `TK ID format prefix "${prefix}" already exists.` };
      }

      const delim = item.delimiter !== undefined ? item.delimiter : "-";
      const digits = item.digits || 4;
      const seq = item.currentSequence || 1;
      const sample = `${prefix}${delim}${String(seq).padStart(digits, "0")}`;

      const newFormat: TkIdFormatItem = {
        id: `tkf-${Date.now()}`,
        prefix,
        name: item.name.trim() || `${prefix} ID Format`,
        targetCategory: item.targetCategory?.trim() || "Full-Time Employee",
        delimiter: delim,
        digits,
        currentSequence: seq,
        sampleFormat: sample,
        isActive: item.isActive !== undefined ? item.isActive : true,
        description: item.description?.trim(),
        createdAt: new Date().toISOString(),
      };

      setResourceMasters((prev) => ({
        ...prev,
        tkIdFormats: [newFormat, ...(prev.tkIdFormats || [])],
      }));

      toast.success(`Added TK ID format prefix: ${prefix} (${sample})`);
      return { success: true };
    },
    [resourceMasters.tkIdFormats],
  );

  const updateTkIdFormat = useCallback(
    (id: string, item: Partial<Omit<TkIdFormatItem, "id" | "createdAt">>): { success: boolean; error?: string } => {
      setResourceMasters((prev) => ({
        ...prev,
        tkIdFormats: (prev.tkIdFormats || []).map((f) => {
          if (f.id !== id) return f;
          const prefix = item.prefix !== undefined ? item.prefix.trim().toUpperCase() : f.prefix;
          const delim = item.delimiter !== undefined ? item.delimiter : f.delimiter;
          const digits = item.digits !== undefined ? item.digits : f.digits;
          const seq = item.currentSequence !== undefined ? item.currentSequence : f.currentSequence;
          const sample = `${prefix}${delim}${String(seq).padStart(digits, "0")}`;

          return {
            ...f,
            ...item,
            prefix,
            delimiter: delim,
            digits,
            currentSequence: seq,
            sampleFormat: sample,
            name: item.name !== undefined ? item.name.trim() : f.name,
            targetCategory: item.targetCategory !== undefined ? item.targetCategory.trim() : f.targetCategory,
            description: item.description !== undefined ? item.description.trim() : f.description,
          };
        }),
      }));

      toast.success("Updated TK ID format");
      return { success: true };
    },
    [],
  );

  const deleteTkIdFormat = useCallback((id: string) => {
    setResourceMasters((prev) => ({
      ...prev,
      tkIdFormats: (prev.tkIdFormats || []).filter((f) => f.id !== id),
    }));
    toast.success("TK ID format deleted");
  }, []);

  const addTkId = useCallback(
    (code: string, extra?: { prefix?: string; assignedTo?: string; status?: "Assigned" | "Available" | "Reserved" }): { success: boolean; error?: string } => {
      const trimmed = code.trim().toUpperCase();
      if (!trimmed) return { success: false, error: "TK ID cannot be empty." };

      if (resourceMasters.tkIds.some((t) => t.code.toUpperCase() === trimmed)) {
        return { success: false, error: `TK ID "${trimmed}" already exists.` };
      }

      const newItem: TkIdMasterItem = {
        id: `tk-${Date.now()}`,
        code: trimmed,
        prefix: extra?.prefix?.trim() || "TK-",
        assignedTo: extra?.assignedTo?.trim() || "",
        status: extra?.status || (extra?.assignedTo?.trim() ? "Assigned" : "Available"),
        createdAt: new Date().toISOString(),
      };

      setResourceMasters((prev) => ({
        ...prev,
        tkIds: [newItem, ...prev.tkIds],
      }));

      toast.success(`Added TK ID: ${trimmed}`);
      return { success: true };
    },
    [resourceMasters.tkIds],
  );

  const updateTkId = useCallback(
    (id: string, code: string, extra?: { prefix?: string; assignedTo?: string; status?: "Assigned" | "Available" | "Reserved" }): { success: boolean; error?: string } => {
      const trimmed = code.trim().toUpperCase();
      if (!trimmed) return { success: false, error: "TK ID cannot be empty." };

      setResourceMasters((prev) => ({
        ...prev,
        tkIds: prev.tkIds.map((t) =>
          t.id === id
            ? {
                ...t,
                code: trimmed,
                prefix: extra?.prefix !== undefined ? extra.prefix.trim() : t.prefix,
                assignedTo: extra?.assignedTo !== undefined ? extra.assignedTo.trim() : t.assignedTo,
                status: extra?.status !== undefined ? extra.status : t.status,
              }
            : t,
        ),
      }));

      toast.success(`Updated TK ID ${trimmed}`);
      return { success: true };
    },
    [],
  );

  const deleteTkId = useCallback((id: string) => {
    setResourceMasters((prev) => ({
      ...prev,
      tkIds: prev.tkIds.filter((t) => t.id !== id),
    }));
    toast.success("TK ID deleted");
  }, []);

  type SimpleCategory = "businessUnits" | "workLocations" | "graduationDegrees" | "postGraduationDegrees" | "certifications";

  const addResourceSimpleItem = useCallback(
    (category: SimpleCategory, name: string, extra?: { code?: string; description?: string }): { success: boolean; error?: string } => {
      const trimmed = name.trim();
      if (!trimmed) return { success: false, error: "Name cannot be empty." };

      if (resourceMasters[category].some((item) => item.name.toLowerCase() === trimmed.toLowerCase())) {
        return { success: false, error: `"${trimmed}" already exists in this master.` };
      }

      const newItem: SimpleResourceMasterItem = {
        id: `${category}-${Date.now()}`,
        name: trimmed,
        code: extra?.code?.trim() || trimmed.toLowerCase().replace(/\s+/g, "_"),
        description: extra?.description?.trim(),
        isActive: true,
        createdAt: new Date().toISOString(),
      };

      setResourceMasters((prev) => ({
        ...prev,
        [category]: [newItem, ...prev[category]],
      }));

      toast.success(`Added to ${category}: "${trimmed}"`);
      return { success: true };
    },
    [resourceMasters],
  );

  const updateResourceSimpleItem = useCallback(
    (category: SimpleCategory, id: string, name: string, extra?: { code?: string; description?: string; isActive?: boolean }): { success: boolean; error?: string } => {
      const trimmed = name.trim();
      if (!trimmed) return { success: false, error: "Name cannot be empty." };

      setResourceMasters((prev) => ({
        ...prev,
        [category]: prev[category].map((item) =>
          item.id === id
            ? {
                ...item,
                name: trimmed,
                code: extra?.code !== undefined ? extra.code.trim() : item.code,
                description: extra?.description !== undefined ? extra.description.trim() : item.description,
                isActive: extra?.isActive !== undefined ? extra.isActive : item.isActive,
              }
            : item,
        ),
      }));

      toast.success(`Updated "${trimmed}"`);
      return { success: true };
    },
    [],
  );

  const deleteResourceSimpleItem = useCallback((category: SimpleCategory, id: string) => {
    setResourceMasters((prev) => ({
      ...prev,
      [category]: prev[category].filter((item) => item.id !== id),
    }));
    toast.success("Master item deleted");
  }, []);

  const resetAllToDefaults = useCallback(() => {
    resetCatalog();
    setProjectMasters(INITIAL_PROJECT_MASTERS);
    setCustomerMasters(INITIAL_CUSTOMER_MASTERS);
    setResourceMasters(INITIAL_RESOURCE_MASTERS);
    toast.info("All masters reset to default initial data");
  }, [resetCatalog]);

  return {
    projectMasters,
    customerMasters,
    resourceMasters,
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
    // Resource master operations
    addDepartmentHierarchyItem,
    updateDepartmentHierarchyItem,
    deleteDepartmentHierarchyItem,
    addEmailDomain,
    updateEmailDomain,
    deleteEmailDomain,
    addCity,
    updateCity,
    deleteCity,
    addTkIdFormat,
    updateTkIdFormat,
    deleteTkIdFormat,
    addTkId,
    updateTkId,
    deleteTkId,
    addResourceSimpleItem,
    updateResourceSimpleItem,
    deleteResourceSimpleItem,
    resetAllToDefaults,
  };
}
