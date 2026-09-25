import { createFileRoute, Navigate } from "@tanstack/react-router";

export const Route = createFileRoute("/health")({
  component: () => <Navigate to="/projects" replace />,
});
