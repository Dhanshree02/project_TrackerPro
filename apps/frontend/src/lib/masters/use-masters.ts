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
  SimpleResourceMasterItem,
} from "./types";
import {
  INITIAL_CUSTOMER_MASTERS,
  INITIAL_PROJECT_MASTERS,
} from "./mock-data";
import { INITIAL_RESOURCE_MASTERS } from "./resource-mock-data";
import { useProjectCatalogStore } from "./project-catalog-store";

import {
  fetchServiceHierarchy,
  fetchProjectMasters,
  createProjectMaster,
  updateProjectMaster as updateProjectMasterApi,
  deleteProjectMaster as deleteProjectMasterApi,
  fetchCountries,
  createCountry,
  updateCountry,
  deleteCountry,
  fetchCities,
  createCity,
  updateCity,
  deleteCity,
  fetchIndustries,
  createIndustry,
  updateIndustry,
  deleteIndustry,
  fetchContactDesignations,
  createContactDesignation,
  updateContactDesignation,
  deleteContactDesignation,
  fetchContactTypes,
  createContactType,
  updateContactType,
  deleteContactType,
} from "@/lib/api/catalogs";

import {
  fetchResourceHierarchy,
  createResourceHierarchy,
  updateResourceHierarchy,
  deleteResourceHierarchy,
  fetchEmailDomains,
  createEmailDomain,
  updateEmailDomain as updateEmailDomainApi,
  deleteEmailDomain as deleteEmailDomainApi,
  fetchResourceCities,
  createResourceCity,
  updateResourceCity as updateResourceCityApi,
  deleteResourceCity as deleteResourceCityApi,
  fetchSimpleMasters,
  createSimpleMaster,
  updateSimpleMaster as updateSimpleMasterApi,
  deleteSimpleMaster as deleteSimpleMasterApi,
  type SimpleCategory,
} from "@/lib/api/resource-masters";

export function useMastersStore() {
  const {
    contractTypes,
    departments,
    deptServices,
    deptGroups,
    allServices,
    getServicesForDepartment,
    getSubDepartmentsForDepartment,
    addContractType,
    addDepartment,
    addSubDepartment,
    addService,
    resetCatalog,
  } = useProjectCatalogStore();

  const [projectMasters, setProjectMasters] = useState<ProjectMasterItem[]>([]);
  const [customerMasters, setCustomerMasters] = useState<CustomerMastersState>(INITIAL_CUSTOMER_MASTERS);
  const [resourceMasters, setResourceMasters] = useState<ResourceMastersState>(INITIAL_RESOURCE_MASTERS);

  // Authoritative fetch for Project Masters directly from PostgreSQL database
  useEffect(() => {
    let active = true;
    fetchProjectMasters()
      .then((items) => {
        if (!active) return;
        if (items && items.length > 0) {
          setProjectMasters(
            items.map((it) => ({
              id: it.id,
              contractType: it.contractType,
              group: it.group,
              department: it.department,
              subDepartment: it.subDepartment,
              service: it.service,
              tools: it.tools,
              duration: it.duration,
              unitPrice: Number(it.unitPrice),
              createdAt: it.createdAtUtc,
            })),
          );
        } else {
          // Fallback to hierarchy if project-masters endpoint returns empty
          fetchServiceHierarchy().then((hierarchy) => {
            if (!active || !hierarchy || hierarchy.length === 0) return;
            const list: ProjectMasterItem[] = [];
            for (const group of hierarchy) {
              for (const dept of group.departments) {
                if (!dept.subDepartments || dept.subDepartments.length === 0) {
                  list.push({
                    id: dept.id,
                    contractType: group.name,
                    group: group.name,
                    department: dept.name,
                    subDepartment: "—",
                    service: "—",
                    tools: "—",
                    duration: "—",
                    unitPrice: 0,
                    createdAt: new Date().toISOString(),
                  });
                } else {
                  for (const sub of dept.subDepartments) {
                    if (!sub.services || sub.services.length === 0) {
                      list.push({
                        id: sub.id,
                        contractType: group.name,
                        group: group.name,
                        department: dept.name,
                        subDepartment: sub.name,
                        service: "—",
                        tools: "—",
                        duration: "—",
                        unitPrice: 0,
                        createdAt: new Date().toISOString(),
                      });
                    } else {
                      for (const svc of sub.services) {
                        list.push({
                          id: svc.id,
                          contractType: group.name,
                          group: group.name,
                          department: dept.name,
                          subDepartment: sub.name,
                          service: svc.name,
                          tools: svc.defaultTools || "—",
                          duration: svc.defaultDurationDays ? `${svc.defaultDurationDays} Days` : "5 Days",
                          unitPrice: svc.defaultUnitPrice ? Number(svc.defaultUnitPrice) : 50000,
                          createdAt: new Date().toISOString(),
                        });
                      }
                    }
                  }
                }
              }
            }
            if (list.length > 0) {
              setProjectMasters(list);
            }
          });
        }
      })
      .catch((err) => {
        console.warn("Could not load project masters from PostgreSQL:", err);
      });

    return () => {
      active = false;
    };
  }, []);

  // Authoritative fetch for Customer Masters directly from PostgreSQL database tables
  useEffect(() => {
    let active = true;
    Promise.all([
      fetchContactDesignations(),
      fetchIndustries(),
      fetchCountries(),
      fetchCities(),
      fetchContactTypes(),
    ])
      .then(([designations, industries, countries, cities, contactTypes]) => {
        if (!active) return;
        setCustomerMasters({
          designations: (designations || []).map((d) => ({
            id: d.id,
            name: d.name,
            code: d.code,
            createdAt: new Date().toISOString(),
          })),
          industries: (industries || []).map((i) => ({
            id: i.id,
            name: i.name,
            code: i.code,
            createdAt: new Date().toISOString(),
          })),
          countries: (countries || []).map((c) => ({
            id: c.id,
            name: c.name,
            code: c.code,
            phoneCode: c.phoneCode,
            phoneDigits: c.phoneDigits,
            createdAt: new Date().toISOString(),
          })),
          cities: (cities || []).map((c) => ({
            id: c.id,
            name: c.name,
            code: c.code,
            country: c.countryId,
            countryId: c.countryId,
            countryName: c.countryName,
            createdAt: new Date().toISOString(),
          })),
          contactTypes: (contactTypes || []).map((ct) => ({
            id: ct.id,
            name: ct.name,
            code: ct.code,
            createdAt: new Date().toISOString(),
          })),
        });
      })
      .catch((err) => {
        console.warn("Could not load customer masters from PostgreSQL:", err);
      });

    return () => {
      active = false;
    };
  }, []);

  // Authoritative fetch for Resource Masters directly from local PostgreSQL database
  useEffect(() => {
    let active = true;
    Promise.all([
      fetchResourceHierarchy(),
      fetchEmailDomains(),
      fetchResourceCities(),
      fetchSimpleMasters("businessUnits"),
      fetchSimpleMasters("workLocations"),
      fetchSimpleMasters("graduationDegrees"),
      fetchSimpleMasters("postGraduationDegrees"),
      fetchSimpleMasters("certifications"),
    ])
      .then(
        ([
          hierarchy,
          emailDomains,
          cities,
          businessUnits,
          workLocations,
          graduationDegrees,
          postGraduationDegrees,
          certifications,
        ]) => {
          if (!active) return;
          setResourceMasters({
            departmentHierarchy: hierarchy || [],
            emailDomains: emailDomains || [],
            cities: cities || [],
            businessUnits: businessUnits || [],
            workLocations: workLocations || [],
            graduationDegrees: graduationDegrees || [],
            postGraduationDegrees: postGraduationDegrees || [],
            certifications: certifications || [],
          });
        },
      )
      .catch((err) => {
        console.warn("Could not load resource masters from PostgreSQL database:", err);
      });

    return () => {
      active = false;
    };
  }, []);

  // --- Project Master Operations (Synchronized with PostgreSQL) ---
  const addProjectMaster = useCallback(
    async (item: Omit<ProjectMasterItem, "id" | "createdAt">): Promise<{ success: boolean; error?: string }> => {
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

      // Check duplicates (same contractType, department, subDepartment, service)
      const duplicate = projectMasters.some(
        (p) =>
          (p.contractType || p.group || "").toLowerCase() === contractTypeVal.toLowerCase() &&
          p.department.toLowerCase() === item.department.toLowerCase() &&
          (p.subDepartment || "").toLowerCase() === (item.subDepartment || "").toLowerCase() &&
          p.service.toLowerCase() === item.service.toLowerCase(),
      );

      if (duplicate) {
        const subDeptText = item.subDepartment?.trim() ? ` → ${item.subDepartment.trim()}` : "";
        return {
          success: false,
          error: `A project master for ${contractTypeVal} → ${item.department}${subDeptText} → ${item.service} already exists.`,
        };
      }

      try {
        const created = await createProjectMaster({
          contractType: contractTypeVal,
          department: item.department.trim(),
          subDepartment: item.subDepartment?.trim() || "",
          service: item.service.trim(),
          tools: item.tools.trim(),
          duration: item.duration.trim(),
          unitPrice: Number(item.unitPrice),
        });

        const newItem: ProjectMasterItem = {
          id: created.id,
          contractType: created.contractType,
          group: created.group || created.contractType,
          department: created.department,
          subDepartment: created.subDepartment || undefined,
          service: created.service,
          tools: created.tools,
          duration: created.duration,
          unitPrice: Number(created.unitPrice),
          createdAt: created.createdAtUtc,
        };

        setProjectMasters((prev) => [newItem, ...prev]);
        toast.success("Project Master added and saved to database");
        return { success: true };
      } catch (err: any) {
        const errMsg = err?.message || "Failed to add project master to database";
        toast.error(errMsg);
        return { success: false, error: errMsg };
      }
    },
    [projectMasters],
  );

  const updateProjectMaster = useCallback(
    async (id: string, item: Omit<ProjectMasterItem, "id" | "createdAt">): Promise<{ success: boolean; error?: string }> => {
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
          (p.subDepartment || "").toLowerCase() === (item.subDepartment || "").toLowerCase() &&
          p.service.toLowerCase() === item.service.toLowerCase(),
      );

      if (duplicate) {
        const subDeptText = item.subDepartment?.trim() ? ` → ${item.subDepartment.trim()}` : "";
        return {
          success: false,
          error: `Another project master for ${contractTypeVal} → ${item.department}${subDeptText} → ${item.service} already exists.`,
        };
      }

      try {
        const updated = await updateProjectMasterApi(id, {
          contractType: contractTypeVal,
          department: item.department.trim(),
          subDepartment: item.subDepartment?.trim() || "",
          service: item.service.trim(),
          tools: item.tools.trim(),
          duration: item.duration.trim(),
          unitPrice: Number(item.unitPrice),
        });

        setProjectMasters((prev) =>
          prev.map((p) =>
            p.id === id
              ? {
                  ...p,
                  contractType: updated.contractType,
                  group: updated.group || updated.contractType,
                  department: updated.department,
                  subDepartment: updated.subDepartment || undefined,
                  service: updated.service,
                  tools: updated.tools,
                  duration: updated.duration,
                  unitPrice: Number(updated.unitPrice),
                }
              : p,
          ),
        );
        toast.success("Project Master updated and synchronized with database");
        return { success: true };
      } catch (err: any) {
        const errMsg = err?.message || "Failed to update project master in database";
        toast.error(errMsg);
        return { success: false, error: errMsg };
      }
    },
    [projectMasters],
  );

  const deleteProjectMaster = useCallback(async (id: string) => {
    try {
      await deleteProjectMasterApi(id);
      setProjectMasters((prev) => prev.filter((p) => p.id !== id));
      toast.success("Project Master deleted from database");
    } catch (err: any) {
      toast.error(err?.message || "Failed to delete project master from database");
    }
  }, []);

  // --- Customer Master Operations (Directly Connected to PostgreSQL Database) ---
  const addCustomerMasterItem = useCallback(
    async (
      category: CustomerMasterCategory,
      name: string,
      extra?: { code?: string; description?: string; countryId?: string; phoneCode?: string; phoneDigits?: number },
    ): Promise<{ success: boolean; error?: string }> => {
      const trimmed = name.trim();
      if (!trimmed) {
        return { success: false, error: "Name is required." };
      }

      try {
        let createdItem: SimpleMasterItem;

        if (category === "countries") {
          const res = await createCountry({
            name: trimmed,
            code: extra?.code?.trim(),
            phoneCode: extra?.phoneCode?.trim(),
            phoneDigits: extra?.phoneDigits,
          });
          createdItem = {
            id: res.id,
            name: res.name,
            code: res.code,
            phoneCode: res.phoneCode,
            phoneDigits: res.phoneDigits,
            createdAt: new Date().toISOString(),
          };
        } else if (category === "cities") {
          if (!extra?.countryId) {
            return { success: false, error: "Please select a Country for this city." };
          }
          const res = await createCity({
            name: trimmed,
            countryId: extra.countryId,
            code: extra?.code?.trim(),
          });
          createdItem = {
            id: res.id,
            name: res.name,
            code: res.code,
            country: res.countryId,
            countryId: res.countryId,
            countryName: res.countryName,
            createdAt: new Date().toISOString(),
          };
        } else if (category === "industries") {
          const res = await createIndustry({
            name: trimmed,
            code: extra?.code?.trim(),
          });
          createdItem = {
            id: res.id,
            name: res.name,
            code: res.code,
            createdAt: new Date().toISOString(),
          };
        } else if (category === "designations") {
          const res = await createContactDesignation({
            name: trimmed,
            code: extra?.code?.trim(),
          });
          createdItem = {
            id: res.id,
            name: res.name,
            code: res.code,
            createdAt: new Date().toISOString(),
          };
        } else if (category === "contactTypes") {
          const res = await createContactType({
            name: trimmed,
            code: extra?.code?.trim(),
          });
          createdItem = {
            id: res.id,
            name: res.name,
            code: res.code,
            createdAt: new Date().toISOString(),
          };
        } else {
          return { success: false, error: "Unknown master category" };
        }

        setCustomerMasters((prev) => ({
          ...prev,
          [category]: [createdItem, ...prev[category].filter((i) => i.id !== createdItem.id)],
        }));

        toast.success(`Saved "${trimmed}" in database`);
        return { success: true };
      } catch (err: any) {
        console.error(`Failed to create ${category} item:`, err);
        const msg = err?.message || `Failed to add item to ${category}.`;
        toast.error(msg);
        return { success: false, error: msg };
      }
    },
    [],
  );

  const updateCustomerMasterItem = useCallback(
    async (
      category: CustomerMasterCategory,
      id: string,
      name: string,
      extra?: { code?: string; description?: string; countryId?: string; phoneCode?: string; phoneDigits?: number },
    ): Promise<{ success: boolean; error?: string }> => {
      const trimmed = name.trim();
      if (!trimmed) {
        return { success: false, error: "Name is required." };
      }

      try {
        let updatedItem: SimpleMasterItem;

        if (category === "countries") {
          const res = await updateCountry(id, {
            name: trimmed,
            code: extra?.code?.trim(),
            phoneCode: extra?.phoneCode?.trim(),
            phoneDigits: extra?.phoneDigits,
          });
          updatedItem = {
            id: res.id,
            name: res.name,
            code: res.code,
            phoneCode: res.phoneCode,
            phoneDigits: res.phoneDigits,
            createdAt: new Date().toISOString(),
          };
        } else if (category === "cities") {
          const res = await updateCity(id, {
            name: trimmed,
            countryId: extra?.countryId,
            code: extra?.code?.trim(),
          });
          updatedItem = {
            id: res.id,
            name: res.name,
            code: res.code,
            country: res.countryId,
            countryId: res.countryId,
            countryName: res.countryName,
            createdAt: new Date().toISOString(),
          };
        } else if (category === "industries") {
          const res = await updateIndustry(id, {
            name: trimmed,
            code: extra?.code?.trim(),
          });
          updatedItem = {
            id: res.id,
            name: res.name,
            code: res.code,
            createdAt: new Date().toISOString(),
          };
        } else if (category === "designations") {
          const res = await updateContactDesignation(id, {
            name: trimmed,
            code: extra?.code?.trim(),
          });
          updatedItem = {
            id: res.id,
            name: res.name,
            code: res.code,
            createdAt: new Date().toISOString(),
          };
        } else if (category === "contactTypes") {
          const res = await updateContactType(id, {
            name: trimmed,
            code: extra?.code?.trim(),
          });
          updatedItem = {
            id: res.id,
            name: res.name,
            code: res.code,
            createdAt: new Date().toISOString(),
          };
        } else {
          return { success: false, error: "Unknown category" };
        }

        setCustomerMasters((prev) => ({
          ...prev,
          [category]: prev[category].map((item) => (item.id === id ? updatedItem : item)),
        }));

        toast.success(`Updated "${trimmed}" in database`);
        return { success: true };
      } catch (err: any) {
        console.error(`Failed to update ${category} item:`, err);
        const msg = err?.message || `Failed to update item in ${category}.`;
        toast.error(msg);
        return { success: false, error: msg };
      }
    },
    [],
  );

  const deleteCustomerMasterItem = useCallback(
    async (category: CustomerMasterCategory, id: string) => {
      try {
        if (category === "countries") {
          await deleteCountry(id);
          setCustomerMasters((prev) => ({
            ...prev,
            countries: prev.countries.filter((item) => item.id !== id),
            cities: prev.cities.filter((item) => item.countryId !== id && item.country !== id),
          }));
        } else if (category === "cities") {
          await deleteCity(id);
          setCustomerMasters((prev) => ({
            ...prev,
            cities: prev.cities.filter((item) => item.id !== id),
          }));
        } else if (category === "industries") {
          await deleteIndustry(id);
          setCustomerMasters((prev) => ({
            ...prev,
            industries: prev.industries.filter((item) => item.id !== id),
          }));
        } else if (category === "designations") {
          await deleteContactDesignation(id);
          setCustomerMasters((prev) => ({
            ...prev,
            designations: prev.designations.filter((item) => item.id !== id),
          }));
        } else if (category === "contactTypes") {
          await deleteContactType(id);
          setCustomerMasters((prev) => ({
            ...prev,
            contactTypes: prev.contactTypes.filter((item) => item.id !== id),
          }));
        }
        toast.success("Master item deleted from database");
      } catch (err: any) {
        console.error(`Failed to delete ${category} item:`, err);
        toast.error(err?.message || "Failed to delete master item.");
      }
    },
    [],
  );

  // ── Resource Master Operations (Directly Connected to Local PostgreSQL Database) ──
  const addDepartmentHierarchyItem = useCallback(
    async (item: Omit<DepartmentHierarchyItem, "id" | "createdAt">): Promise<{ success: boolean; error?: string }> => {
      if (!item.departmentName?.trim()) return { success: false, error: "Please select a Department." };
      if (!item.designationName?.trim()) return { success: false, error: "Please select a Designation." };
      if (!item.onFloorRoleName?.trim()) return { success: false, error: "Please select an On Floor Role." };
      if (!item.assignedRbacRoleName?.trim()) return { success: false, error: "Please select an RBAC Role." };

      try {
        const created = await createResourceHierarchy(item);
        try {
          const fresh = await fetchResourceHierarchy();
          if (fresh && fresh.length > 0) {
            setResourceMasters((prev) => ({
              ...prev,
              departmentHierarchy: fresh,
            }));
            toast.success(`Saved hierarchy mapping: ${created.departmentName} → ${created.designationName}`);
            return { success: true };
          }
        } catch {}
        setResourceMasters((prev) => ({
          ...prev,
          departmentHierarchy: [created, ...prev.departmentHierarchy.filter((h) => h.id !== created.id)],
        }));
        toast.success(`Saved hierarchy mapping: ${created.departmentName} → ${created.designationName}`);
        return { success: true };
      } catch (err: any) {
        console.error("Failed to add hierarchy mapping to database:", err);
        const msg = err?.message || "Failed to save hierarchy mapping to database.";
        toast.error(msg);
        return { success: false, error: msg };
      }
    },
    [],
  );

  const updateDepartmentHierarchyItem = useCallback(
    async (id: string, item: Partial<Omit<DepartmentHierarchyItem, "id" | "createdAt">>): Promise<{ success: boolean; error?: string }> => {
      try {
        const updated = await updateResourceHierarchy(id, item);
        try {
          const fresh = await fetchResourceHierarchy();
          if (fresh && fresh.length > 0) {
            setResourceMasters((prev) => ({
              ...prev,
              departmentHierarchy: fresh,
            }));
            toast.success("Updated hierarchy mapping in database");
            return { success: true };
          }
        } catch {}
        setResourceMasters((prev) => ({
          ...prev,
          departmentHierarchy: prev.departmentHierarchy.map((h) => (h.id === id ? updated : h)),
        }));
        toast.success("Updated hierarchy mapping in database");
        return { success: true };
      } catch (err: any) {
        console.error("Failed to update hierarchy mapping in database:", err);
        const msg = err?.message || "Failed to update hierarchy mapping in database.";
        toast.error(msg);
        return { success: false, error: msg };
      }
    },
    [],
  );

  const deleteDepartmentHierarchyItem = useCallback(
    async (id: string): Promise<void> => {
      try {
        await deleteResourceHierarchy(id);
        try {
          const fresh = await fetchResourceHierarchy();
          if (fresh) {
            setResourceMasters((prev) => ({
              ...prev,
              departmentHierarchy: fresh,
            }));
            toast.success("Hierarchy mapping deleted from database");
            return;
          }
        } catch {}
        setResourceMasters((prev) => ({
          ...prev,
          departmentHierarchy: prev.departmentHierarchy.filter((h) => h.id !== id),
        }));
        toast.success("Hierarchy mapping deleted from database");
      } catch (err: any) {
        console.error("Failed to delete hierarchy mapping from database:", err);
        toast.error(err?.message || "Failed to delete hierarchy mapping from database.");
      }
    },
    [],
  );

  const addEmailDomain = useCallback(
    async (domainName: string, extra?: { displayName?: string; code?: string }): Promise<{ success: boolean; error?: string }> => {
      const trimmed = domainName.trim().toLowerCase().replace(/^@/, "");
      if (!trimmed) return { success: false, error: "Domain name cannot be empty." };
      if (!trimmed.includes(".")) return { success: false, error: "Please enter a valid domain (e.g. talakunchi.in)." };

      try {
        const created = await createEmailDomain(trimmed, extra);
        setResourceMasters((prev) => ({
          ...prev,
          emailDomains: [created, ...prev.emailDomains.filter((d) => d.id !== created.id)],
        }));
        toast.success(`Saved email domain @${created.domainName} to database`);
        return { success: true };
      } catch (err: any) {
        console.error("Failed to add email domain to database:", err);
        const msg = err?.message || "Failed to save email domain to database.";
        toast.error(msg);
        return { success: false, error: msg };
      }
    },
    [],
  );

  const updateEmailDomain = useCallback(
    async (id: string, domainName: string, extra?: { displayName?: string; code?: string; isActive?: boolean }): Promise<{ success: boolean; error?: string }> => {
      const trimmed = domainName.trim().toLowerCase().replace(/^@/, "");
      if (!trimmed) return { success: false, error: "Domain name cannot be empty." };

      try {
        const updated = await updateEmailDomainApi(id, trimmed, extra);
        setResourceMasters((prev) => ({
          ...prev,
          emailDomains: prev.emailDomains.map((d) => (d.id === id ? updated : d)),
        }));
        toast.success(`Updated domain @${updated.domainName} in database`);
        return { success: true };
      } catch (err: any) {
        console.error("Failed to update email domain in database:", err);
        const msg = err?.message || "Failed to update email domain in database.";
        toast.error(msg);
        return { success: false, error: msg };
      }
    },
    [],
  );

  const deleteEmailDomain = useCallback(
    async (id: string): Promise<void> => {
      try {
        await deleteEmailDomainApi(id);
        setResourceMasters((prev) => ({
          ...prev,
          emailDomains: prev.emailDomains.filter((d) => d.id !== id),
        }));
        toast.success("Email domain deleted from database");
      } catch (err: any) {
        console.error("Failed to delete email domain:", err);
        toast.error(err?.message || "Failed to delete email domain from database.");
      }
    },
    [],
  );

  const addCity = useCallback(
    async (name: string, extra?: { line?: string; code?: string; stationName?: string }): Promise<{ success: boolean; error?: string }> => {
      const trimmed = name.trim();
      if (!trimmed) return { success: false, error: "Station / City name cannot be empty." };

      try {
        const created = await createResourceCity(trimmed, extra);
        setResourceMasters((prev) => ({
          ...prev,
          cities: [created, ...prev.cities.filter((c) => c.id !== created.id)],
        }));
        toast.success(`Saved station / city: ${created.name} (${created.line}) to database`);
        return { success: true };
      } catch (err: any) {
        console.error("Failed to add station / city to database:", err);
        const msg = err?.message || "Failed to save station / city to database.";
        toast.error(msg);
        return { success: false, error: msg };
      }
    },
    [],
  );

  const updateCity = useCallback(
    async (id: string, name: string, extra?: { line?: string; code?: string; stationName?: string; isActive?: boolean }): Promise<{ success: boolean; error?: string }> => {
      const trimmed = name.trim();
      if (!trimmed) return { success: false, error: "Station / City name cannot be empty." };

      try {
        const updated = await updateResourceCityApi(id, trimmed, extra);
        setResourceMasters((prev) => ({
          ...prev,
          cities: prev.cities.map((c) => (c.id === id ? updated : c)),
        }));
        toast.success(`Updated station / city: ${updated.name} in database`);
        return { success: true };
      } catch (err: any) {
        console.error("Failed to update station / city in database:", err);
        const msg = err?.message || "Failed to update station / city in database.";
        toast.error(msg);
        return { success: false, error: msg };
      }
    },
    [],
  );

  const deleteCity = useCallback(
    async (id: string): Promise<void> => {
      try {
        await deleteResourceCityApi(id);
        setResourceMasters((prev) => ({
          ...prev,
          cities: prev.cities.filter((c) => c.id !== id),
        }));
        toast.success("Station / City deleted from database");
      } catch (err: any) {
        console.error("Failed to delete station / city from database:", err);
        toast.error(err?.message || "Failed to delete station / city from database.");
      }
    },
    [],
  );

  const addTkIdFormat = useCallback(
    (_item: any): { success: boolean; error?: string } => ({ success: true }),
    [],
  );
  const updateTkIdFormat = useCallback(
    (_id: string, _item: any): { success: boolean; error?: string } => ({ success: true }),
    [],
  );
  const deleteTkIdFormat = useCallback((_id: string) => {}, []);
  const addTkId = useCallback(
    (_code: string, _extra?: any): { success: boolean; error?: string } => ({ success: true }),
    [],
  );
  const updateTkId = useCallback(
    (_id: string, _code: string, _extra?: any): { success: boolean; error?: string } => ({ success: true }),
    [],
  );
  const deleteTkId = useCallback((_id: string) => {}, []);

  const addResourceSimpleItem = useCallback(
    async (category: SimpleCategory, name: string, extra?: { code?: string; description?: string }): Promise<{ success: boolean; error?: string }> => {
      const trimmed = name.trim();
      if (!trimmed) return { success: false, error: "Name cannot be empty." };

      try {
        const created = await createSimpleMaster(category, trimmed, extra);
        setResourceMasters((prev) => ({
          ...prev,
          [category]: [created, ...prev[category].filter((item) => item.id !== created.id)],
        }));
        toast.success(`Saved "${created.name}" to database`);
        return { success: true };
      } catch (err: any) {
        console.error(`Failed to add item to ${category} in database:`, err);
        const msg = err?.message || "Failed to save item to database.";
        toast.error(msg);
        return { success: false, error: msg };
      }
    },
    [],
  );

  const updateResourceSimpleItem = useCallback(
    async (category: SimpleCategory, id: string, name: string, extra?: { code?: string; description?: string; isActive?: boolean }): Promise<{ success: boolean; error?: string }> => {
      const trimmed = name.trim();
      if (!trimmed) return { success: false, error: "Name cannot be empty." };

      try {
        const updated = await updateSimpleMasterApi(category, id, trimmed, extra);
        setResourceMasters((prev) => ({
          ...prev,
          [category]: prev[category].map((item) => (item.id === id ? updated : item)),
        }));
        toast.success(`Updated "${updated.name}" in database`);
        return { success: true };
      } catch (err: any) {
        console.error(`Failed to update item in ${category} in database:`, err);
        const msg = err?.message || "Failed to update item in database.";
        toast.error(msg);
        return { success: false, error: msg };
      }
    },
    [],
  );

  const deleteResourceSimpleItem = useCallback(
    async (category: SimpleCategory, id: string): Promise<void> => {
      try {
        await deleteSimpleMasterApi(category, id);
        setResourceMasters((prev) => ({
          ...prev,
          [category]: prev[category].filter((item) => item.id !== id),
        }));
        toast.success("Master item deleted from database");
      } catch (err: any) {
        console.error(`Failed to delete item from ${category} in database:`, err);
        toast.error(err?.message || "Failed to delete item from database.");
      }
    },
    [],
  );

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
    getSubDepartmentsForDepartment,
    addContractType,
    addDepartment,
    addSubDepartment,
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
