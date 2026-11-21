import { createFileRoute } from "@tanstack/react-router";
import { EmployeeDirectoryPage } from "@/modules/employees";

export const Route = createFileRoute("/employee-directory/")({
  ssr: false,
  validateSearch: (search: Record<string, unknown>): { tab?: "directory" | "pool" } => ({
    tab:
      search.tab === "directory" || search.tab === "pool"
        ? (search.tab as "directory" | "pool")
        : undefined,
  }),
  head: () => ({
    meta: [
      { title: "Employee Directory — Pulse PMO" },
      {
        name: "description",
        content: "Browse and manage the full employee directory.",
      },
    ],
  }),
  component: EmployeeDirectoryPage,
});
