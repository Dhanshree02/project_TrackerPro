import { createFileRoute, Navigate } from "@tanstack/react-router";

export const Route = createFileRoute("/dh-settings")({
  head: () => ({
    meta: [
      { title: "Settings — Pulse PMO" },
      { name: "description", content: "Manage application configuration and security settings." },
    ],
  }),
  component: () => <Navigate to="/dh-settings-masters" replace />,
});
