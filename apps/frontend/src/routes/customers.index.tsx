import { createFileRoute } from "@tanstack/react-router";
import { CustomersListPage } from "@/modules/customers";

export const Route = createFileRoute("/customers/")({
  head: () => ({
    meta: [
      { title: "Customers — Pulse PMO" },
      { name: "description", content: "All customers, projects and engagement health." },
    ],
  }),
  component: CustomersListPage,
});
