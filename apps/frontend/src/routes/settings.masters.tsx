import { createFileRoute, Navigate } from "@tanstack/react-router";

export const Route = createFileRoute("/settings/masters")({
  component: () => <Navigate to="/dh-settings-masters" replace />,
});
