import { useState, useEffect, useCallback } from "react";
import { toast } from "sonner";
import type { CustomerMasterCategory, CustomerMastersState, ProjectMasterItem } from "./types";
import {
  INITIAL_CUSTOMER_MASTERS,
  INITIAL_PROJECT_MASTERS,
} from "./defaults";
import { useProjectCatalogStore } from "./project-catalog-store";
import {
  createCity,
  createContactDesignation,
  createContactType,
  createCountry,
  createIndustry,
  createServiceCatalog,
  createServiceDepartment,
  createServiceGroup,
  createServiceSubDepartment,
  deleteCity,
  deleteContactDesignation,
  deleteContactType,
  deleteCountry,
  deleteIndustry,
  deleteServiceCatalog,
  durationDaysFromText,
  fetchCities,
  fetchContactDesignations,
  fetchContactTypes,
  fetchCountries,
  fetchIndustries,
  fetchServiceHierarchy,
  isCatalogGuid,
  updateCity,
  updateContactDesignation,
  updateContactType,
  updateCountry,
  updateIndustry,
  updateServiceCatalog,
} from "@/lib/api/catalogs";

export function useMastersStore() {
  const {
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
    resetCatalog,
  } = useProjectCatalogStore();

  const [projectMasters, setProjectMasters] = useState<ProjectMasterItem[]>(INITIAL_PROJECT_MASTERS);
  const [customerMasters, setCustomerMasters] = useState<CustomerMastersState>(INITIAL_CUSTOMER_MASTERS);

  const loadMastersFromDb = useCallback(async () => {
    try {
      const [groups, designations, industries, countries, cities, contactTypes] = await Promise.all([
        fetchServiceHierarchy(),
        fetchContactDesignations(),
        fetchIndustries(),
        fetchCountries(),
        fetchCities(),
        fetchContactTypes(),
      ]);

      const projRows: ProjectMasterItem[] = [];
      for (const group of groups) {
        const isResource =
          group.code.toUpperCase() === "RESOURCE" ||
          group.name.toLowerCase().includes("resource");
        const contractTypeLabel = isResource ? "Resource Based" : "Scope Based";
        for (const dept of group.departments) {
            for (const sub of dept.subDepartments) {
            for (const svc of sub.services) {
              projRows.push({
                id: svc.id || `pm-${svc.code.toLowerCase()}`,
                contractType: group.name,
                group: contractTypeLabel,
                department: dept.name,
                subDepartment: sub.name,
                service: svc.name,
                tools: svc.defaultTools ?? "",
                duration: `${svc.defaultDurationDays ?? 0} Days`,
                unitPrice: Number(svc.defaultUnitPrice ?? 0),
                createdAt: new Date().toISOString(),
              });
            }
          }
        }
      }
      setProjectMasters(projRows);

      const nowIso = new Date().toISOString();
      setCustomerMasters({
        designations: designations.map((d) => ({ id: d.id, name: d.name, code: d.code, createdAt: nowIso })),
        industries: industries.map((i) => ({ id: i.id, name: i.name, code: i.code, createdAt: nowIso })),
        countries: countries.map((c) => ({ id: c.id, name: c.name, code: c.code, createdAt: nowIso })),
        cities: cities.map((c) => ({
          id: c.id,
          name: c.name,
          code: c.code,
          countryId: c.countryId,
          countryName: countries.find((country) => country.id === c.countryId)?.name,
          createdAt: nowIso,
        })),
        contactTypes: contactTypes.map((ct) => ({ id: ct.id, name: ct.name, code: ct.code, createdAt: nowIso })),
      });
    } catch {
      toast.error("Could not load master catalogs from database");
    }
  }, []);

  useEffect(() => {
    void loadMastersFromDb();
  }, [loadMastersFromDb]);

  const reloadProjectCatalog = useCallback(async () => {
    await resetCatalog();
    await loadMastersFromDb();
  }, [loadMastersFromDb, resetCatalog]);

  const masterError = (error: unknown, fallback: string) =>
    error instanceof Error && error.message ? error.message : fallback;

  // --- Project Master Operations (database only) ---
  const saveProjectMaster = useCallback(
    async (input: {
      serviceId?: string;
      subDepartmentId?: string;
      service: string;
      tools: string;
      duration: string;
      unitPrice: number;
    }): Promise<{ success: boolean; error?: string }> => {
      const days = durationDaysFromText(input.duration);
      if (!input.tools.trim()) return { success: false, error: "Tools field cannot be empty." };
      if (!days) return { success: false, error: "Duration must be a number of days." };
      if (!Number.isFinite(input.unitPrice) || input.unitPrice <= 0) {
        return { success: false, error: "Unit Price must be a positive numeric value." };
      }

      try {
        if (isCatalogGuid(input.serviceId)) {
          await updateServiceCatalog(input.serviceId, {
            defaultTools: input.tools.trim(),
            defaultUnitPrice: input.unitPrice,
            defaultDurationDays: days,
          });
        } else if (isCatalogGuid(input.subDepartmentId)) {
          await createServiceCatalog({
            subDepartmentId: input.subDepartmentId,
            name: input.service.trim(),
            defaultTools: input.tools.trim(),
            defaultUnitPrice: input.unitPrice,
            defaultDurationDays: days,
          });
        } else {
          return { success: false, error: "Choose a service that is already stored in the database." };
        }

        await reloadProjectCatalog();
        toast.success("Project Master saved");
        return { success: true };
      } catch (error) {
        return { success: false, error: masterError(error, "Could not save the project master.") };
      }
    },
    [reloadProjectCatalog],
  );

  const updateProjectMaster = useCallback(
    async (
      id: string,
      item: Omit<ProjectMasterItem, "id" | "createdAt"> & { subDepartmentId?: string },
    ): Promise<{ success: boolean; error?: string }> => {
      const days = durationDaysFromText(item.duration);
      if (!isCatalogGuid(id)) return { success: false, error: "This row is not stored in the database." };
      if (!item.tools?.trim()) return { success: false, error: "Tools field cannot be empty." };
      if (!days) return { success: false, error: "Duration must be a number of days." };
      if (item.unitPrice === undefined || item.unitPrice === null || Number.isNaN(Number(item.unitPrice)) || Number(item.unitPrice) <= 0) {
        return { success: false, error: "Unit Price must be a positive numeric value." };
      }

      try {
        await updateServiceCatalog(id, {
          name: item.service.trim(),
          subDepartmentId: isCatalogGuid(item.subDepartmentId) ? item.subDepartmentId : undefined,
          defaultTools: item.tools.trim(),
          defaultUnitPrice: Number(item.unitPrice),
          defaultDurationDays: days,
        });
        await reloadProjectCatalog();
        toast.success("Project Master updated");
        return { success: true };
      } catch (error) {
        return { success: false, error: masterError(error, "Could not update the project master.") };
      }
    },
    [reloadProjectCatalog],
  );

  const deleteProjectMaster = useCallback(
    async (id: string) => {
      if (!isCatalogGuid(id)) {
        toast.error("This row is not stored in the database.");
        return;
      }
      try {
        await deleteServiceCatalog(id);
        await reloadProjectCatalog();
        toast.success("Project Master deleted");
      } catch (error) {
        toast.error(masterError(error, "Could not delete the project master."));
      }
    },
    [reloadProjectCatalog],
  );

  const addContractType = useCallback(
    async (name: string): Promise<{ success: boolean; error?: string }> => {
      const trimmed = name.trim();
      if (!trimmed) return { success: false, error: "Contract Type name is required." };
      try {
        await createServiceGroup(trimmed);
        await reloadProjectCatalog();
        toast.success(`Contract Type "${trimmed}" saved`);
        return { success: true };
      } catch (error) {
        return { success: false, error: masterError(error, "Could not save the contract type.") };
      }
    },
    [reloadProjectCatalog],
  );

  const addDepartment = useCallback(
    async (name: string, groupId?: string): Promise<{ success: boolean; error?: string }> => {
      const trimmed = name.trim();
      if (!trimmed) return { success: false, error: "Department name is required." };
      if (!isCatalogGuid(groupId)) return { success: false, error: "Select a contract type from the database first." };
      try {
        await createServiceDepartment(groupId, trimmed);
        await reloadProjectCatalog();
        toast.success(`Department "${trimmed}" saved`);
        return { success: true };
      } catch (error) {
        return { success: false, error: masterError(error, "Could not save the department.") };
      }
    },
    [reloadProjectCatalog],
  );

  const addSubDepartment = useCallback(
    async (name: string, departmentId?: string): Promise<{ success: boolean; error?: string }> => {
      const trimmed = name.trim();
      if (!trimmed) return { success: false, error: "Sub-department name is required." };
      if (!isCatalogGuid(departmentId)) return { success: false, error: "Select a department from the database first." };
      try {
        await createServiceSubDepartment(departmentId, trimmed);
        await reloadProjectCatalog();
        toast.success(`Sub-department "${trimmed}" saved`);
        return { success: true };
      } catch (error) {
        return { success: false, error: masterError(error, "Could not save the sub-department.") };
      }
    },
    [reloadProjectCatalog],
  );

  const addService = useCallback(
    async (
      _dept: string,
      service: { name: string; tool?: string; unitPrice?: number; days?: number },
      placement?: { contractType?: string; subDepartment?: string; subDepartmentId?: string },
    ): Promise<{ success: boolean; error?: string }> => {
      const trimmed = service.name.trim();
      const subDepartmentId = placement?.subDepartmentId;
      if (!trimmed) return { success: false, error: "Service name is required." };
      if (!isCatalogGuid(subDepartmentId)) {
        return { success: false, error: "Select a sub-department from the database first." };
      }
      try {
        await createServiceCatalog({
          subDepartmentId,
          name: trimmed,
          defaultTools: service.tool?.trim() || null,
          defaultUnitPrice: service.unitPrice && service.unitPrice > 0 ? service.unitPrice : null,
          defaultDurationDays: service.days && service.days > 0 ? service.days : null,
        });
        await reloadProjectCatalog();
        toast.success(`Service "${trimmed}" saved`);
        return { success: true };
      } catch (error) {
        return { success: false, error: masterError(error, "Could not save the service.") };
      }
    },
    [reloadProjectCatalog],
  );

  // --- Customer Master Operations ---
  const addCustomerMasterItem = useCallback(
    async (
      category: CustomerMasterCategory,
      name: string,
      extra?: { code?: string; description?: string; countryId?: string },
    ): Promise<{ success: boolean; error?: string }> => {
      const trimmed = name.trim();
      if (!trimmed) return { success: false, error: "Name is required." };
      if (category === "cities" && !isCatalogGuid(extra?.countryId)) {
        return { success: false, error: "Select the country this city belongs to." };
      }
      try {
        const payload = { name: trimmed, code: extra?.code?.trim() || null };
        if (category === "designations") await createContactDesignation(payload);
        else if (category === "industries") await createIndustry(payload);
        else if (category === "countries") await createCountry(payload);
        else if (category === "contactTypes") await createContactType(payload);
        else await createCity({ ...payload, countryId: extra!.countryId! });
        await loadMastersFromDb();
        toast.success(`Saved "${trimmed}"`);
        return { success: true };
      } catch (error) {
        return { success: false, error: masterError(error, "Could not save this master.") };
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
      if (!isCatalogGuid(id)) return { success: false, error: "This row is not stored in the database." };
      if (category === "cities" && !isCatalogGuid(extra?.countryId)) {
        return { success: false, error: "Select the country this city belongs to." };
      }
      try {
        const payload = { name: trimmed, code: extra?.code?.trim() || null };
        if (category === "designations") await updateContactDesignation(id, payload);
        else if (category === "industries") await updateIndustry(id, payload);
        else if (category === "countries") await updateCountry(id, payload);
        else if (category === "contactTypes") await updateContactType(id, payload);
        else await updateCity(id, { ...payload, countryId: extra!.countryId! });
        await loadMastersFromDb();
        toast.success(`Updated "${trimmed}"`);
        return { success: true };
      } catch (error) {
        return { success: false, error: masterError(error, "Could not update this master.") };
      }
    },
    [loadMastersFromDb],
  );

  const deleteCustomerMasterItem = useCallback(
    async (category: CustomerMasterCategory, id: string) => {
      if (!isCatalogGuid(id)) {
        toast.error("This row is not stored in the database.");
        return;
      }
      try {
        if (category === "designations") await deleteContactDesignation(id);
        else if (category === "industries") await deleteIndustry(id);
        else if (category === "countries") await deleteCountry(id);
        else if (category === "contactTypes") await deleteContactType(id);
        else await deleteCity(id);
        await loadMastersFromDb();
        toast.success("Master item deleted");
      } catch (error) {
        toast.error(masterError(error, "Could not delete this master."));
      }
    },
    [loadMastersFromDb],
  );

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
    deptServices,
    deptGroups,
    services: allServices,
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
    addSubDepartment,
    addService,
    saveProjectMaster,
    updateProjectMaster,
    deleteProjectMaster,
    addCustomerMasterItem,
    updateCustomerMasterItem,
    deleteCustomerMasterItem,
    resetAllToDefaults,
  };
}
