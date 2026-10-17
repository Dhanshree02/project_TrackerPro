import { createFileRoute, Navigate } from "@tanstack/react-router";

export const Route = createFileRoute("/timesheet")({
  component: () => <Navigate to="/my-team/timesheets" replace />,
});
