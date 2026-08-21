import { createFileRoute, Navigate } from "@tanstack/react-router";

export const Route = createFileRoute("/resources/$employeeId")({
  head: () => ({
    meta: [
      { title: "Employee Details — Pulse PMO" },
      { name: "description", content: "Basic employee information from the resource directory." },
    ],
  }),
  component: EmployeeDetailsRedirect,
});

function EmployeeDetailsRedirect() {
  const { employeeId } = Route.useParams();
  return <Navigate to="/dh-employee-directory/$id" params={{ id: employeeId }} replace />;
}
