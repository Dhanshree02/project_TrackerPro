import { createFileRoute, Navigate } from "@tanstack/react-router";

export const Route = createFileRoute("/allocation")({
  component: () => <Navigate to="/projects" replace />,
});
