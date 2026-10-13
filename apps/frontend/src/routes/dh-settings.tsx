import { createFileRoute, Navigate, redirect } from "@tanstack/react-router";

export const Route = createFileRoute("/dh-settings")({
  beforeLoad: () => {
    throw redirect({ to: "/projects" });
  },
  head: () => ({
    meta: [
      { title: "Settings — Pulse PMO" },
      { name: "description", content: "Manage application configuration and security settings." },
    ],
  }),
  component: () => <Navigate to="/dh-settings-masters" replace />,
});
