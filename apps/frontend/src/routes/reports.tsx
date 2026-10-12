import { createFileRoute, Navigate } from "@tanstack/react-router";

export const Route = createFileRoute("/reports")({
  head: () => ({
    meta: [
      { title: "Reports — Pulse PMO" },
      {
        name: "description",
        content: "Department reports: delivery, client, resource, escalation and project health.",
      },
    ],
  }),
  component: ReportsPage,
});

function ReportsPage() {
  return <Navigate to="/dh-reports" replace />;
}
