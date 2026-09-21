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
  const { can, isDhanshree } = useRoleContext();
  const { hasAny } = usePermissions();
  const [activeTab, setActiveTab] = useState<MasterTab>("projects");

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
    services,
    customerMasters,
    addProjectMaster,
    updateProjectMaster,
    deleteProjectMaster,
    addContractType,
    addDepartment,
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
      <div className="mb-6 flex items-center justify-between border-b border-border">
        <div className="flex items-center">
          <button
            onClick={() => setActiveTab("projects")}
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

          <button
            onClick={() => setActiveTab("customers")}
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

          <button
            onClick={() => setActiveTab("resources")}
            className={cn(
              "relative flex items-center gap-2 px-4 py-2.5 text-sm font-medium transition-colors",
              activeTab === "resources"
                ? "text-primary font-semibold"
                : "text-muted-foreground hover:text-foreground",
            )}
          >
            <Users className="h-4 w-4" />
            <span>Resource Masters</span>
            {activeTab === "resources" && (
              <span className="absolute inset-x-0 -bottom-px h-0.5 rounded-full bg-primary" />
            )}
          </button>
        </div>

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
      </div>

      {/* ── Active Tab Content ───────────────────────────────────────────── */}
      {activeTab === "projects" && (
        <ProjectMastersSection
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
          onAddService={addService}
        />
      )}

      {activeTab === "customers" && (
        <CustomerMastersSection
          customerMasters={customerMasters}
          onAdd={addCustomerMasterItem}
          onUpdate={updateCustomerMasterItem}
          onDelete={deleteCustomerMasterItem}
        />
      )}

      {activeTab === "resources" && <ResourceMastersSection />}
    </AppShell>
  );
}
