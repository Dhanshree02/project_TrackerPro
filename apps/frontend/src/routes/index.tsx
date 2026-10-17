import { createFileRoute } from "@tanstack/react-router";
import { AppShell } from "@/components/app-shell";
import { useRoleContext, roleLabels } from "@/lib/role-context";
import { TeamMisSection } from "@/components/dashboard/team-mis-section";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "Dashboard — Pulse PMO" },
      {
        name: "description",
        content: "Track assigned projects, health, and pending approvals at a glance.",
      },
    ],
  }),
  component: Dashboard,
});

function Dashboard() {
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
