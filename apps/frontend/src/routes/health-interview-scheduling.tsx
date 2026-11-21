import { createFileRoute } from "@tanstack/react-router";
import { HealthInterviewSchedulingPage } from "@/modules/health/pages/health-interview-scheduling-page";

export const Route = createFileRoute("/health-interview-scheduling")({
  head: () => ({
    meta: [
      { title: "Interview Scheduling — Pulse PMO" },
      { name: "description", content: "Manage client interview scheduling and resource feedback." },
    ],
  }),
  component: HealthInterviewSchedulingPage,
});
