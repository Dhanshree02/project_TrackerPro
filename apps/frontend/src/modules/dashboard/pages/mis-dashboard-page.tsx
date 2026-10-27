import { AppShell } from "@/components/app-shell";
import { usePermissions } from "@/lib/permissions";
import { useRoleContext, roleLabels } from "@/lib/role-context";
import { TeamMisSection } from "@/modules/dashboard/components/team-mis-section";

export function MisDashboardPage() {
  const {
    user,
    role,
    isPMO,
    isBO,
    isHOD,
    isEmployee,
    isAccounts,
    isSales,
    assignedProjects,
  } = useRoleContext();
  const { canView } = usePermissions();

  if (!canView("dashboard")) {
    return (
      <AppShell title="Dashboard">
        <div className="mx-auto max-w-md rounded-xl border border-border bg-card p-12 text-center shadow-sm mt-8">
          <h2 className="text-base font-semibold text-foreground">Access Restricted</h2>
          <p className="mt-2 text-xs text-muted-foreground">
            Your role does not have permission to view the Dashboard.
          </p>
        </div>
      </AppShell>
    );
  }

  return (
    <AppShell
      title={`Welcome back, ${user.name.split(" ")[0]}`}
      subtitle={`${isEmployee ? "Employee" : isAccounts ? "Accounts & Finance" : isSales ? "Sales & BD" : roleLabels[role]} · ${assignedProjects.length} projects across ${new Set(assignedProjects.map((p) => p.clientId)).size} customers${isBO ? " · executive overview" : isHOD ? " · department view" : isPMO ? " · governance + allocation view" : ""}`}
    >
      <TeamMisSection />
    </AppShell>
  );
}
