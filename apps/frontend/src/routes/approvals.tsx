import { createFileRoute, Navigate } from "@tanstack/react-router";

export const Route = createFileRoute("/approvals")({
  component: () => <Navigate to="/action-centre" replace />,
});
