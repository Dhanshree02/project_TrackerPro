import { createFileRoute, Navigate } from "@tanstack/react-router";

export const Route = createFileRoute("/dh-org-tree")({
  component: () => <Navigate to="/dh-employee-directory" replace />,
});
