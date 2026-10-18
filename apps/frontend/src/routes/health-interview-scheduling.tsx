import { createFileRoute } from "@tanstack/react-router";
import { HealthInterviewSchedulingPage } from "@/modules/health";

export const Route = createFileRoute("/health-interview-scheduling")({
  head: () => ({
    meta: [
      { title: "Interview Scheduling — Pulse PMO" },
      { name: "description", content: "Manage client interview scheduling and resource feedback." },
    ],
  }),
  component: HealthInterviewSchedulingPage,
});
