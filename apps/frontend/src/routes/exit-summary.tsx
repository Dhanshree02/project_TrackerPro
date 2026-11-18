import { createFileRoute } from "@tanstack/react-router";
import { ExitSummaryPage } from "@/modules/employees";

export const Route = createFileRoute("/exit-summary")({
  head: () => ({
    meta: [
      { title: "Exit Summary — Pulse PMO" },
      {
        name: "description",
        content: "Offboarding analytics, clearances tracking and historical exit logs.",
      },
    ],
  }),
  component: ExitSummaryPage,
});
