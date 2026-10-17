import { createFileRoute, Navigate, redirect } from "@tanstack/react-router";

export const Route = createFileRoute("/reports")({
  beforeLoad: () => {
    throw redirect({ to: "/projects" });
  },
  component: () => <Navigate to="/projects" replace />,
});
