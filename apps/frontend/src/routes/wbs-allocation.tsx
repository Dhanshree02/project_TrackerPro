import { createFileRoute, Navigate } from "@tanstack/react-router";

export const Route = createFileRoute("/wbs-allocation")({
  component: () => <Navigate to="/projects" replace />,
});
