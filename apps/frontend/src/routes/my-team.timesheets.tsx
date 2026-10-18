import { createFileRoute } from "@tanstack/react-router";
import { TimesheetsPage } from "@/modules/timesheets";

export const Route = createFileRoute("/my-team/timesheets")({
  head: () => ({
    meta: [
      { title: "Timesheets — Pulse PMO" },
      { name: "description", content: "My Team timesheet management." },
    ],
  }),
  component: TimesheetsPage,
});
