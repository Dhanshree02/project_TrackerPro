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
  const { canView } = usePermissions();
  const { user, isDhanshree } = useRoleContext();
  const isAdmin = user.role.toLowerCase() === "admin";

  if (
    !isAdmin &&
    !isDhanshree &&
    !canView("team-dashboard") &&
    !canView("my-team") &&
    !canView("my-team-tab") &&
    !canView("9854b7f3-0001-4000-8000-000000000001") &&
    !canView("my-reportees") &&
    !canView("all-employees")
  ) {
    return <Navigate to="/" />;
  }

  return <MyTeamPage />;
}
