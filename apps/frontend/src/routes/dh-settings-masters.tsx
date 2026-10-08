import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useState } from "react";
import {
  FolderKanban,
  Building2,
  Users,
  Database,
  RotateCcw,
  Sparkles,
} from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { usePermissions } from "@/lib/permissions";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import { useMastersStore } from "@/lib/masters/use-masters";
import { ProjectMastersSection } from "@/components/masters/project-masters-section";
import { CustomerMastersSection } from "@/components/masters/customer-masters-section";
import { ResourceMastersSection } from "@/components/masters/resource-masters-section";

export const Route = createFileRoute("/dh-settings-masters")({
  head: () => ({
    meta: [
      { title: "Masters — Settings — Pulse PMO" },
      { name: "description", content: "Centralized configuration and master data management." },
    ],
  }),
  component: MastersPage,
});

type MasterTab = "projects" | "customers" | "resources";

function MastersPage() {
  const { can, isDhanshree, isAdmin } = useRoleContext();
  const { hasAny } = usePermissions();

  // Evaluate permissions for each of the 3 master sub-modules
  const canViewProjects =
    isAdmin ||
    isDhanshree ||
    hasAny(
      "Settings|Masters|Project Masters:view",
      "settings.masters.projects.view",
      "settings.masters.projects:view",
      "settings.masters.project:view"
    ) ||
    (can ? can("Settings|Masters|Project Masters:view") || can("settings.masters.projects.view") : false);

  const canManageProjects =
    isAdmin ||
    hasAny(
      "Settings|Masters|Project Masters:manage",
      "settings.masters.projects.manage",
      "settings.masters.projects:manage",
      "settings.masters.project:manage"
    ) ||
    (can ? can("Settings|Masters|Project Masters:manage") || can("settings.masters.projects.manage") : false);

  const canViewCustomers =
    isAdmin ||
    isDhanshree ||
    hasAny(
      "Settings|Masters|Customer Masters:view",
      "settings.masters.customers.view",
      "settings.masters.customers:view",
      "settings.masters.customer:view"
    ) ||
    (can ? can("Settings|Masters|Customer Masters:view") || can("settings.masters.customers.view") : false);

  const canManageCustomers =
    isAdmin ||
    hasAny(
      "Settings|Masters|Customer Masters:manage",
      "settings.masters.customers.manage",
      "settings.masters.customers:manage",
      "settings.masters.customer:manage"
    ) ||
    (can ? can("Settings|Masters|Customer Masters:manage") || can("settings.masters.customers.manage") : false);

  const canViewResources =
    isAdmin ||
    isDhanshree ||
    hasAny(
      "Settings|Masters|Resource Master:view",
      "settings.masters.resources.view",
      "settings.masters.resources:view",
      "settings.masters.resource:view"
    ) ||
    (can ? can("Settings|Masters|Resource Master:view") || can("settings.masters.resources.view") : false);

  const canManageResources =
    isAdmin ||
    hasAny(
      "Settings|Masters|Resource Master:manage",
      "settings.masters.resources.manage",
      "settings.masters.resources:manage",
      "settings.masters.resource:manage"
    ) ||
    (can ? can("Settings|Masters|Resource Master:manage") || can("settings.masters.resources.manage") : false);

  const availableTabs: MasterTab[] = [];
  if (canViewProjects) availableTabs.push("projects");
  if (canViewCustomers) availableTabs.push("customers");
  if (canViewResources) availableTabs.push("resources");

  const [selectedTab, setSelectedTab] = useState<MasterTab | null>(null);

  const canAccessPage =
    isAdmin ||
    isDhanshree ||
    availableTabs.length > 0 ||
    hasAny("settings.view", "Settings|Masters:view", "settings.masters.view") ||
    (can ? can("settings.view") || can("settings.masters.view") : false);

  if (!canAccessPage || (availableTabs.length === 0 && !isAdmin && !isDhanshree)) {
    return <Navigate to="/" />;
  }

  // Active tab defaults to the first authorized tab for the role
  const activeTab: MasterTab =
    selectedTab && availableTabs.includes(selectedTab)
      ? selectedTab
      : (availableTabs[0] ?? "projects");

  const canResetDefaults = isAdmin || isDhanshree || (canManageProjects && canManageCustomers && canManageResources);

  const {
    projectMasters,
    contractTypes,
    groups,
    departments,
    services,
    customerMasters,
    resourceMasters,
    addProjectMaster,
    updateProjectMaster,
    deleteProjectMaster,
    addContractType,
    addDepartment,
    addSubDepartment,
    addService,
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
    addResourceSimpleItem,
    updateResourceSimpleItem,
    deleteResourceSimpleItem,
    resetAllToDefaults,
  } = useMastersStore();

  const totalCustomerItems =
    (customerMasters?.designations?.length || 0) +
    (customerMasters?.industries?.length || 0) +
    (customerMasters?.countries?.length || 0) +
    (customerMasters?.cities?.length || 0) +
    (customerMasters?.contactTypes?.length || 0);

  const totalResourceItems =
    (resourceMasters?.departmentHierarchy?.length || 0) +
    (resourceMasters?.emailDomains?.length || 0) +
    (resourceMasters?.businessUnits?.length || 0) +
    (resourceMasters?.workLocations?.length || 0) +
    (resourceMasters?.graduationDegrees?.length || 0) +
    (resourceMasters?.postGraduationDegrees?.length || 0) +
    (resourceMasters?.certifications?.length || 0);

  return (
    <AppShell
      title="Masters"
      subtitle="Centralized configuration and master data management"
    >
      {/* ── Top Tabs & Actions (Project Masters, Customer Masters, Resource Masters) ─ */}
      <div className="mb-6 flex items-center justify-between border-b border-border">
        <div className="flex items-center">
          {canViewProjects && (
            <button
              onClick={() => setSelectedTab("projects")}
              className={cn(
                "relative flex items-center gap-2 px-4 py-2.5 text-sm font-medium transition-colors",
                activeTab === "projects"
                  ? "text-primary font-semibold"
                  : "text-muted-foreground hover:text-foreground",
              )}
            >
              <FolderKanban className="h-4 w-4" />
              <span>Project Masters</span>
              <Badge
                variant="secondary"
                className={cn(
                  "text-[10px] px-1.5 py-0",
                  activeTab === "projects" ? "bg-primary/15 text-primary font-semibold" : "",
                )}
              >
                {projectMasters.length}
              </Badge>
              {activeTab === "projects" && (
                <span className="absolute inset-x-0 -bottom-px h-0.5 rounded-full bg-primary" />
              )}
            </button>
          )}

          {canViewCustomers && (
            <button
              onClick={() => setSelectedTab("customers")}
              className={cn(
                "relative flex items-center gap-2 px-4 py-2.5 text-sm font-medium transition-colors",
                activeTab === "customers"
                  ? "text-primary font-semibold"
                  : "text-muted-foreground hover:text-foreground",
              )}
            >
              <Building2 className="h-4 w-4" />
              <span>Customer Masters</span>
              <Badge
                variant="secondary"
                className={cn(
                  "text-[10px] px-1.5 py-0",
                  activeTab === "customers" ? "bg-primary/15 text-primary font-semibold" : "",
                )}
              >
                {totalCustomerItems}
              </Badge>
              {activeTab === "customers" && (
                <span className="absolute inset-x-0 -bottom-px h-0.5 rounded-full bg-primary" />
              )}
            </button>
          )}

          {canViewResources && (
            <button
              onClick={() => setSelectedTab("resources")}
              className={cn(
                "relative flex items-center gap-2 px-4 py-2.5 text-sm font-medium transition-colors",
                activeTab === "resources"
                  ? "text-primary font-semibold"
                  : "text-muted-foreground hover:text-foreground",
              )}
            >
              <Users className="h-4 w-4" />
              <span>Resource Masters</span>
              <Badge
                variant="secondary"
                className={cn(
                  "text-[10px] px-1.5 py-0",
                  activeTab === "resources" ? "bg-primary/15 text-primary font-semibold" : "",
                )}
              >
                {totalResourceItems}
              </Badge>
              {activeTab === "resources" && (
                <span className="absolute inset-x-0 -bottom-px h-0.5 rounded-full bg-primary" />
              )}
            </button>
          )}
        </div>

        {canResetDefaults && (
          <Button
            variant="outline"
            size="sm"
            onClick={resetAllToDefaults}
            className="mb-1.5 h-7 text-[11px] gap-1.5 text-muted-foreground hover:text-foreground"
            title="Reset all masters to initial mock datasets"
          >
            <RotateCcw className="h-3 w-3" />
            Reset Defaults
          </Button>
        )}
      </div>

      {/* ── Active Tab Content ───────────────────────────────────────────── */}
      {activeTab === "projects" && canViewProjects && (
        <ProjectMastersSection
          canManage={canManageProjects}
          items={projectMasters}
          contractTypes={contractTypes}
          groups={groups}
          departments={departments}
          services={services}
          onAdd={addProjectMaster}
          onUpdate={updateProjectMaster}
          onDelete={deleteProjectMaster}
          onAddContractType={addContractType}
          onAddDepartment={addDepartment}
          onAddSubDepartment={addSubDepartment}
          onAddService={addService}
        />
      )}

      {activeTab === "customers" && canViewCustomers && (
        <CustomerMastersSection
          canManage={canManageCustomers}
          customerMasters={customerMasters}
          onAdd={addCustomerMasterItem}
          onUpdate={updateCustomerMasterItem}
          onDelete={deleteCustomerMasterItem}
        />
      )}

      {activeTab === "resources" && canViewResources && (
        <ResourceMastersSection
          canManage={canManageResources}
          resourceMasters={resourceMasters}
          onAddHierarchy={addDepartmentHierarchyItem}
          onUpdateHierarchy={updateDepartmentHierarchyItem}
          onDeleteHierarchy={deleteDepartmentHierarchyItem}
          onAddEmailDomain={addEmailDomain}
          onUpdateEmailDomain={updateEmailDomain}
          onDeleteEmailDomain={deleteEmailDomain}
          onAddSimpleItem={addResourceSimpleItem}
          onUpdateSimpleItem={updateResourceSimpleItem}
          onDeleteSimpleItem={deleteResourceSimpleItem}
        />
      )}
    </AppShell>
  );
}
