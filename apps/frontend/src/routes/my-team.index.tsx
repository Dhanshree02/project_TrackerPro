import { createFileRoute, Navigate } from "@tanstack/react-router";
import { MyTeamPage } from "@/modules/my-team";
import { usePermissions } from "@/lib/permissions";
import { useRoleContext } from "@/lib/role-context";

export const Route = createFileRoute("/my-team/")({
  head: () => ({
    meta: [
      { title: "My Team — Pulse PMO" },
      {
        name: "description",
        content: "Reporting team attendance, availability, and leave visibility calendar.",
      },
    ],
  }),
  component: MyTeamRoute,
});

function MyTeamRoute() {
  const { isAdmin, isDhanshree } = useRoleContext();
  const { hasAny } = usePermissions();

  const canViewTeamDashboard =
    isAdmin ||
    isDhanshree ||
    hasAny("My team|Team Dashboard:view", "my-team.team-dashboard.view");

  if (!canViewTeamDashboard) {
    return <Navigate to="/my-team/timesheets" replace />;
  }

  return <MyTeamPage />;
}
