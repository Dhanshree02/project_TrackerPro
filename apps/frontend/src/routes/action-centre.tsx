import { createFileRoute } from "@tanstack/react-router";
import { ActionCentrePage } from "@/modules/action-centre";

export const Route = createFileRoute("/action-centre")({
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
