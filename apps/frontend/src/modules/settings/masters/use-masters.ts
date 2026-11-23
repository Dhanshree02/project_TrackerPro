import { useState, useEffect, useCallback } from "react";
import { toast } from "sonner";
import type { CustomerMasterCategory, CustomerMastersState, ProjectMasterItem } from "./types";
import { INITIAL_CUSTOMER_MASTERS } from "./defaults";
import { useProjectCatalogStore } from "./project-catalog-store";
import {
  createCity,
  createContactDesignation,
  createContactType,
  createCountry,
  createIndustry,
  deleteCity,
  deleteContactDesignation,
  deleteContactType,
  deleteCountry,
  deleteIndustry,
  fetchCities,
  fetchContactDesignations,
  fetchContactTypes,
  fetchCountries,
  fetchIndustries,
  updateCity,
  updateContactDesignation,
  updateContactType,
  updateCountry,
  updateIndustry,
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
      const countryName = new Map(countries.map((country) => [country.id, country.name]));
      setCustomerMasters({
        designations: designations.map((d) => ({ id: d.id, name: d.name, code: d.code, createdAt: nowIso })),
        industries: industries.map((i) => ({ id: i.id, name: i.name, code: i.code, createdAt: nowIso })),
        countries: countries.map((c) => ({ id: c.id, name: c.name, code: c.code, createdAt: nowIso })),
        cities: cities.map((c) => ({
          id: c.id,
          name: c.name,
          code: c.code,
          countryId: c.countryId,
          description: countryName.get(c.countryId),
          createdAt: nowIso,
        })),
        contactTypes: contactTypes.map((ct) => ({
          id: ct.id,
          name: ct.name,
          code: ct.code,
          description: ct.description ?? undefined,
          createdAt: nowIso,
        })),
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
          subDepartment: item.subDepartment?.trim() || null,
          service: item.service.trim(),
          tools: item.tools.trim(),
          durationDays,
          unitPrice: Number(item.unitPrice),
          abbreviation: item.abbreviation?.trim() || null,
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
          subDepartment: item.subDepartment?.trim() || null,
          service: item.service.trim(),
          tools: item.tools.trim(),
          durationDays,
          unitPrice: Number(item.unitPrice),
          abbreviation: item.abbreviation?.trim() || null,
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
    async (
      category: CustomerMasterCategory,
      name: string,
      extra?: { code?: string; description?: string; countryId?: string },
    ): Promise<{ success: boolean; error?: string }> => {
      const trimmed = name.trim();
      if (!trimmed) return { success: false, error: "Name is required." };
      try {
        if (category === "industries") await createIndustry(trimmed, extra);
        else if (category === "countries") await createCountry(trimmed, extra);
        else if (category === "designations") await createContactDesignation(trimmed, extra);
        else if (category === "contactTypes") await createContactType(trimmed, extra);
        else {
          if (!extra?.countryId) return { success: false, error: "Select a country for this city." };
          await createCity(trimmed, extra.countryId, extra.code);
        }
        await loadMastersFromDb();
        toast.success(`Added "${trimmed}"`);
        return { success: true };
      } catch (error) {
        return { success: false, error: error instanceof Error ? error.message : "Could not save this master" };
      }
    },
    [loadMastersFromDb],
  );

  const updateCustomerMasterItem = useCallback(
    async (
      category: CustomerMasterCategory,
      id: string,
      name: string,
      extra?: { code?: string; description?: string; countryId?: string },
    ): Promise<{ success: boolean; error?: string }> => {
      const trimmed = name.trim();
      if (!trimmed) return { success: false, error: "Name is required." };
      try {
        if (category === "industries") await updateIndustry(id, trimmed, extra);
        else if (category === "countries") await updateCountry(id, trimmed, extra);
        else if (category === "designations") await updateContactDesignation(id, trimmed, extra);
        else if (category === "contactTypes") await updateContactType(id, trimmed, extra);
        else {
          if (!extra?.countryId) return { success: false, error: "Select a country for this city." };
          await updateCity(id, trimmed, extra.countryId, extra.code);
        }
        await loadMastersFromDb();
        toast.success(`Updated "${trimmed}"`);
        return { success: true };
      } catch (error) {
        return { success: false, error: error instanceof Error ? error.message : "Could not update this master" };
      }
    },
    [loadMastersFromDb],
  );

  const deleteCustomerMasterItem = useCallback(async (category: CustomerMasterCategory, id: string) => {
    try {
      if (category === "industries") await deleteIndustry(id);
      else if (category === "countries") await deleteCountry(id);
      else if (category === "designations") await deleteContactDesignation(id);
      else if (category === "contactTypes") await deleteContactType(id);
      else await deleteCity(id);
      await loadMastersFromDb();
      toast.success("Master item deleted");
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Could not delete this master");
    }
  }, [loadMastersFromDb]);

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
    subDepartmentsForDepartment,
    deptServices,
    deptSubDepartments,
    subDeptServices,
    deptGroups,
    services: allServices,
    allServices,
    getServicesForDepartment,
    getServicesForSubDepartment,
    addContractType,
    addDepartment,
    addSubDepartment,
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
