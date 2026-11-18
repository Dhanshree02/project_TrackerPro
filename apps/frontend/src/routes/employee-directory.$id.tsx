import { createFileRoute } from "@tanstack/react-router";
import { EmployeeProfilePage } from "@/modules/employees";

export const Route = createFileRoute("/employee-directory/$id")({
  head: () => ({
    meta: [
      { title: "Employee Profile — Pulse PMO" },
      { name: "description", content: "View full profile of an employee." },
    ],
  }),
  component: EmployeeProfilePage,
});
