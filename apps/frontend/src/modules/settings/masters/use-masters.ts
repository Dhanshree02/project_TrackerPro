import { useState, useEffect, useCallback } from "react";
import { toast } from "sonner";
import type { CustomerMasterCategory, CustomerMastersState, ProjectMasterItem, SimpleMasterItem } from "./types";
import { INITIAL_CUSTOMER_MASTERS } from "./defaults";
import { useProjectCatalogStore } from "./project-catalog-store";
import {
  fetchCities,
  fetchContactDesignations,
  fetchContactTypes,
  fetchCountries,
  fetchIndustries,
} from "@/lib/api/catalogs";
import {
  createProjectMaster,
  deleteProjectMaster,
  fetchProjectMasterRows,
  parseDurationDays,
  rowToProjectMasterItem,
  updateProjectMaster,
  isProjectMastersApiMissingError,
} from "@/modules/settings/api/project-masters";

export function useMastersStore() {
  const {
    contractTypes,
    departments,
    departmentsForContractType,
    deptServices,
    deptGroups,
    allServices,
    getServicesForDepartment,
    addContractType,
    addDepartment,
    addService,
    resetCatalog,
    reloadCatalog,
  } = useProjectCatalogStore();

  const [projectMasters, setProjectMasters] = useState<ProjectMasterItem[]>([]);
  const [customerMasters, setCustomerMasters] = useState<CustomerMastersState>(INITIAL_CUSTOMER_MASTERS);

  const loadProjectMastersFromDb = useCallback(async () => {
    try {
      const rows = await fetchProjectMasterRows();
      setProjectMasters(rows.map(rowToProjectMasterItem));
    } catch (error) {
      toast.error(
        isProjectMastersApiMissingError(error)
          ? "Project masters API is not available — rebuild and restart the backend container, then refresh."
          : error instanceof Error
            ? error.message
            : "Could not load project masters from database",
      );
    }
  }, []);

  const loadMastersFromDb = useCallback(async () => {
    await reloadCatalog();
    await loadProjectMastersFromDb();

    try {
      const [designations, industries, countries, cities, contactTypes] = await Promise.all([
        fetchContactDesignations(),
        fetchIndustries(),
        fetchCountries(),
        fetchCities(),
        fetchContactTypes(),
      ]);

      const nowIso = new Date().toISOString();
      setCustomerMasters({
        designations: designations.map((d) => ({ id: d.id, name: d.name, code: d.code, createdAt: nowIso })),
        industries: industries.map((i) => ({ id: i.id, name: i.name, code: i.code, createdAt: nowIso })),
        countries: countries.map((c) => ({ id: c.id, name: c.name, code: c.code, createdAt: nowIso })),
        cities: cities.map((c) => ({ id: c.id, name: c.name, code: c.code, createdAt: nowIso })),
        contactTypes: contactTypes.map((ct) => ({ id: ct.id, name: ct.name, code: ct.code, createdAt: nowIso })),
      });
    } catch {
      toast.error("Could not load customer master catalogs from database");
    }
  }, [reloadCatalog, loadProjectMastersFromDb]);

  useEffect(() => {
    void loadMastersFromDb();
  }, [loadMastersFromDb]);

  const addProjectMaster = useCallback(
    async (item: Omit<ProjectMasterItem, "id" | "createdAt">): Promise<{ success: boolean; error?: string }> => {
      const contractTypeVal = (item.contractType || item.group || "").trim();
      if (!contractTypeVal) return { success: false, error: "Please select a Contract Type." };
      if (!item.department?.trim()) return { success: false, error: "Please select a Department." };
      if (!item.service?.trim()) return { success: false, error: "Please select a Service." };
      if (!item.tools?.trim()) return { success: false, error: "Tools field cannot be empty." };
      const durationDays = parseDurationDays(item.duration);
      if (durationDays <= 0) return { success: false, error: "Duration field cannot be empty." };
      if (
        item.unitPrice === undefined ||
        item.unitPrice === null ||
        Number.isNaN(Number(item.unitPrice)) ||
        Number(item.unitPrice) <= 0
      ) {
        return { success: false, error: "Unit Price must be a positive numeric value." };
      }

      try {
        await createProjectMaster({
          contractType: contractTypeVal,
          department: item.department.trim(),
          service: item.service.trim(),
          tools: item.tools.trim(),
          durationDays,
          unitPrice: Number(item.unitPrice),
        });
        await loadMastersFromDb();
        toast.success("Project Master added successfully");
        return { success: true };
      } catch (error) {
        return {
          success: false,
          error: isProjectMastersApiMissingError(error)
            ? "Backend needs a rebuild to save project masters (missing /api/v1/catalogs/project-masters)."
            : error instanceof Error
              ? error.message
              : "Could not save project master",
        };
      }
    },
    [loadMastersFromDb],
  );

  const updateProjectMasterItem = useCallback(
    async (
      id: string,
      item: Omit<ProjectMasterItem, "id" | "createdAt">,
    ): Promise<{ success: boolean; error?: string }> => {
      const contractTypeVal = (item.contractType || item.group || "").trim();
      if (!contractTypeVal) return { success: false, error: "Please select a Contract Type." };
      if (!item.department?.trim()) return { success: false, error: "Please select a Department." };
      if (!item.service?.trim()) return { success: false, error: "Please select a Service." };
      if (!item.tools?.trim()) return { success: false, error: "Tools field cannot be empty." };
      const durationDays = parseDurationDays(item.duration);
      if (durationDays <= 0) return { success: false, error: "Duration field cannot be empty." };
      if (
        item.unitPrice === undefined ||
        item.unitPrice === null ||
        Number.isNaN(Number(item.unitPrice)) ||
        Number(item.unitPrice) <= 0
      ) {
        return { success: false, error: "Unit Price must be a positive numeric value." };
      }

      try {
        await updateProjectMaster(id, {
          contractType: contractTypeVal,
          department: item.department.trim(),
          service: item.service.trim(),
          tools: item.tools.trim(),
          durationDays,
          unitPrice: Number(item.unitPrice),
        });
        await loadMastersFromDb();
        toast.success("Project Master updated successfully");
        return { success: true };
      } catch (error) {
        return {
          success: false,
          error: isProjectMastersApiMissingError(error)
            ? "Backend needs a rebuild to save project masters (missing /api/v1/catalogs/project-masters)."
            : error instanceof Error
              ? error.message
              : "Could not update project master",
        };
      }
    },
    [loadMastersFromDb],
  );

  const deleteProjectMasterItem = useCallback(
    async (id: string): Promise<void> => {
      try {
        await deleteProjectMaster(id);
        await loadMastersFromDb();
        toast.success("Project Master deleted");
      } catch (error) {
        toast.error(error instanceof Error ? error.message : "Could not delete project master");
      }
    },
    [loadMastersFromDb],
  );

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
    void loadMastersFromDb();
    toast.info("Reloaded masters from database");
  }, [resetCatalog, loadMastersFromDb]);

  return {
    projectMasters,
    customerMasters,
    contractTypes,
    groups: contractTypes,
    departments,
    departmentsForContractType,
    deptServices,
    deptGroups,
    services: allServices,
    allServices,
    getServicesForDepartment,
    addContractType,
    addDepartment,
    addService,
    addProjectMaster,
    updateProjectMaster: updateProjectMasterItem,
    deleteProjectMaster: deleteProjectMasterItem,
    addCustomerMasterItem,
    updateCustomerMasterItem,
    deleteCustomerMasterItem,
    resetAllToDefaults,
  };
}
