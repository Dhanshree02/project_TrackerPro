import { createFileRoute } from "@tanstack/react-router";
import { ActionCentrePage } from "@/modules/action-centre/pages/action-centre-page";

export const Route = createFileRoute("/action-centre")({
  validateSearch: (search: Record<string, unknown>): { tab?: string } => ({
    tab: typeof search.tab === "string" && search.tab.trim() ? search.tab : undefined,
  }),
  head: () => ({
    meta: [
      { title: "Action Centre — Pulse PMO" },
      {
        name: "description",
        content: "Bucket list, timesheets, approvals and alerts in one place.",
      },
    ],
  }),
  component: ActionCentrePage,
});
