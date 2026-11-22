import { createFileRoute } from "@tanstack/react-router";
import { CustomersListPage } from "@/modules/customers/pages/customers-list-page";

export const Route = createFileRoute("/customers/")({
  ssr: false,
  head: () => ({
    meta: [
      { title: "Customers — Pulse PMO" },
      { name: "description", content: "All customers, projects and engagement health." },
    ],
  }),
  component: CustomersListPage,
});
