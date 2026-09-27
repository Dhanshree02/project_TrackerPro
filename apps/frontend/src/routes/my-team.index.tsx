import { createFileRoute } from "@tanstack/react-router";
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
  return <MyTeamPage />;
}
