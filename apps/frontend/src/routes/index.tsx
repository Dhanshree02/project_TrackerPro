import { createFileRoute } from "@tanstack/react-router";
import { MisDashboardPage } from "@/modules/dashboard/pages/mis-dashboard-page";

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
  component: MisDashboardPage,
});
