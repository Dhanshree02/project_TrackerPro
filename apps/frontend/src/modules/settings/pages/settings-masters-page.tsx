import { Navigate } from "@tanstack/react-router";
import { useState } from "react";
import {
  FolderKanban,
  Building2,
  Users,
  CalendarDays,
  Database,
  RotateCcw,
  Sparkles,
} from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { usePermissions } from "@/lib/permissions";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { UnderlineTabs } from "@/components/ui/underline-tabs";
import { useMastersStore } from "@/modules/settings/masters/use-masters";
import { ProjectMastersSection } from "@/modules/settings/components/masters/project-masters-section";
import { CustomerMastersSection } from "@/modules/settings/components/masters/customer-masters-section";
import { ResourceMastersSection } from "@/modules/settings/components/masters/resource-masters-section";
import { LeaveCalendarSection } from "@/modules/settings/components/masters/leave-calendar-section";
import {
  CUSTOMER_SCREEN_OPTIONS,
  PROJECT_SCREEN_OPTIONS,
  RESOURCE_SCREEN_OPTIONS,
  ScreenOptionsSection,
} from "@/modules/settings/components/masters/screen-options-section";

type MasterTab = "projects" | "customers" | "resources" | "leave-calendar";

export function SettingsMastersPage() {
  const { can, isDhanshree } = useRoleContext();
  const { hasAny } = usePermissions();
  const [activeTab, setActiveTab] = useState<MasterTab>("projects");
  const [resourceCount, setResourceCount] = useState<number | null>(null);
  const [leaveCalendarCount, setLeaveCalendarCount] = useState<number | null>(null);

  const allowed =
    isDhanshree ||
    (can ? can("settings.view") : false) ||
    hasAny("settings.view", "settings.manage_roles", "roles:manage", "users:manage");

  if (!allowed) return <Navigate to="/" />;

  const {
    projectMasters,
    contractTypes,
    groups,
    departments,
    departmentsForContractType,
    subDepartmentsForDepartment,
    services,
    getServicesForSubDepartment,
    customerMasters,
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
    resetAllToDefaults,
  } = useMastersStore();

  const totalCustomerItems =
    (customerMasters?.designations?.length || 0) +
    (customerMasters?.industries?.length || 0) +
    (customerMasters?.countries?.length || 0) +
    (customerMasters?.cities?.length || 0) +
    (customerMasters?.contactTypes?.length || 0);

  return (
    <AppShell
      title="Masters"
      subtitle="Centralized configuration and master data management"
    >
      {/* ── Top Tabs & Actions (Project Masters, Customer Masters, Resource Masters) ─ */}
      <div className="mb-6 flex items-center justify-between gap-3">
        <UnderlineTabs
          value={activeTab}
          onChange={setActiveTab}
          options={[
            {
              value: "projects",
              label: (
                <>
                  <FolderKanban className="h-4 w-4" />
                  Project Masters
                  <Badge variant="secondary" className="px-1.5 py-0 text-[10px]">
                    {projectMasters.length}
                  </Badge>
                </>
              ),
            },
            {
              value: "customers",
              label: (
                <>
                  <Building2 className="h-4 w-4" />
                  Customer Masters
                  <Badge variant="secondary" className="px-1.5 py-0 text-[10px]">
                    {totalCustomerItems}
                  </Badge>
                </>
              ),
            },
            {
              value: "resources",
              label: (
                <>
                  <Users className="h-4 w-4" />
                  Resource Masters
                  {resourceCount !== null && (
                    <Badge variant="secondary" className="px-1.5 py-0 text-[10px]">
                      {resourceCount}
                    </Badge>
                  )}
                </>
              ),
            },
            {
              value: "leave-calendar",
              label: (
                <>
                  <CalendarDays className="h-4 w-4" />
                  Holiday Calendar
                  {leaveCalendarCount !== null && (
                    <Badge variant="secondary" className="px-1.5 py-0 text-[10px]">
                      {leaveCalendarCount}
                    </Badge>
                  )}
                </>
              ),
            },
          ]}
        />

        <Button
          variant="outline"
          size="sm"
          onClick={activeTab === "leave-calendar" ? () => window.dispatchEvent(new CustomEvent("tk:reset-holiday-calendar")) : resetAllToDefaults}
          className="mb-1.5 h-7 text-[11px] gap-1.5 text-muted-foreground hover:text-foreground"
          title={activeTab === "leave-calendar" ? "Reset and clear all holidays for the selected year" : "Reset all masters to initial mock datasets"}
        >
          <RotateCcw className="h-3 w-3" />
          {activeTab === "leave-calendar" ? "Reset" : "Reset Defaults"}
        </Button>
      </div>

      {/* ── Active Tab Content ───────────────────────────────────────────── */}
      {activeTab === "projects" && (
        <ProjectMastersSection
          items={projectMasters}
          contractTypes={contractTypes}
          groups={groups}
          departments={departments}
          departmentsForContractType={departmentsForContractType}
          subDepartmentsForDepartment={subDepartmentsForDepartment}
          services={services}
          getServicesForSubDepartment={getServicesForSubDepartment}
          onAdd={addProjectMaster}
          onUpdate={updateProjectMaster}
          onDelete={deleteProjectMaster}
          onAddContractType={addContractType}
          onAddDepartment={addDepartment}
          onAddSubDepartment={addSubDepartment}
          onAddService={addService}
        />
      )}
      {activeTab === "projects" && <ScreenOptionsSection groups={PROJECT_SCREEN_OPTIONS} />}

      {activeTab === "customers" && (
        <>
          <CustomerMastersSection
            customerMasters={customerMasters}
            onAdd={addCustomerMasterItem}
            onUpdate={updateCustomerMasterItem}
            onDelete={deleteCustomerMasterItem}
          />
          <ScreenOptionsSection groups={CUSTOMER_SCREEN_OPTIONS} />
        </>
      )}

      {activeTab === "resources" && (
        <>
          <ResourceMastersSection onCountChange={setResourceCount} />
          <ScreenOptionsSection groups={RESOURCE_SCREEN_OPTIONS} />
        </>
      )}

      {activeTab === "leave-calendar" && (
        <LeaveCalendarSection onCountChange={setLeaveCalendarCount} />
      )}
    </AppShell>
  );
}
