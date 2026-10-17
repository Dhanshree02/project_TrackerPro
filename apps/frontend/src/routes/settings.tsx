import { createFileRoute, Navigate } from "@tanstack/react-router";

export const Route = createFileRoute("/settings")({
  head: () => ({
    meta: [
      { title: "Settings — Pulse PMO" },
      { name: "description", content: "Manage application configuration and security settings." },
    ],
  }),
  component: () => <Navigate to="/settings-masters" replace />,
});
