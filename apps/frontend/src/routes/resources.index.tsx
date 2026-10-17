import { createFileRoute, Navigate } from "@tanstack/react-router";

export const Route = createFileRoute("/resources/")({
  component: () => <Navigate to="/employee-directory" replace />,
});
