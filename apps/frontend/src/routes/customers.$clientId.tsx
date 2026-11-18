import { createFileRoute } from "@tanstack/react-router";
import { CustomerDetailPage } from "@/modules/customers";
import {
  loadCustomerDetail,
  validateCustomerDetailSearch,
} from "@/modules/customers/loaders/customer-detail-loader";

export const Route = createFileRoute("/customers/$clientId")({
  validateSearch: validateCustomerDetailSearch,
  loader: async ({ params }) => loadCustomerDetail(params.clientId),
  head: ({ loaderData }) => ({
    meta: [
      { title: `${loaderData?.client?.name ?? "Customer"} — Customers — Pulse PMO` },
      {
        name: "description",
        content: `360° customer view and project history for ${loaderData?.client?.name ?? "customer"}.`,
      },
    ],
  }),
  component: CustomerDetailPage,
});
