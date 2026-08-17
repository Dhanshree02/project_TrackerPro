import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useRoleContext } from "@/lib/role-context";
import { usePermissions } from "@/lib/permissions";
import { MyTeamPage } from "@/modules/my-team";

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
  const { isDhanshree, isEmployee } = useRoleContext();
  const { hasPermission } = usePermissions();
  // Employees never see the My Team module — their entry point is Timesheet.
  if (isEmployee) return <Navigate to="/timesheet" />;
  if (!isDhanshree && !hasPermission("my-team.dashboard.view")) return <Navigate to="/" />;
  return <MyTeamPage />;
}
