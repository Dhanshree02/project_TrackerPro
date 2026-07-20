import { createFileRoute, Navigate } from "@tanstack/react-router";

export const Route = createFileRoute("/dh-resource-pool")({
  component: () => <Navigate to="/dh-employee-directory" search={{ tab: "pool" }} replace />,
});
