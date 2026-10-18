import { AppShell } from "@/components/app-shell";
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

  return (
    <AppShell
      title={`Welcome back, ${user.name.split(" ")[0]}`}
      subtitle={`${isEmployee ? "Employee" : isAccounts ? "Accounts & Finance" : isSales ? "Sales & BD" : roleLabels[role]} · ${assignedProjects.length} projects across ${new Set(assignedProjects.map((p) => p.clientId)).size} customers${isBO ? " · executive overview" : isHOD ? " · department view" : isPMO ? " · governance + allocation view" : ""}`}
    >
      <TeamMisSection />
    </AppShell>
  );
}
