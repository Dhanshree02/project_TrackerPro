import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useRoleContext } from "@/lib/role-context";
import { MyTeamPage } from "@/modules/my-team";

export const Route = createFileRoute("/my-team/")({
  head: () => ({
    meta: [
      { title: "My Team — Pulse PMO" },
      {
        name: "description",
        content:
          "Reporting team attendance, availability, and leave visibility calendar.",
      },
    ],
  }),
  component: MyTeamRoute,
});

function MyTeamRoute() {
  const { isDhanshree } = useRoleContext();
  if (!isDhanshree) return <Navigate to="/" />;
  return <MyTeamPage />;
}
