import { createFileRoute } from "@tanstack/react-router";
import { HealthAdditionalRequirementsPage } from "@/modules/health";

export const Route = createFileRoute("/health-additional-requirements")({
  head: () => ({
    meta: [
      { title: "Additional Client Requirements — Pulse PMO" },
      {
        name: "description",
        content: "Manage additional requirements raised by clients post-onboarding.",
      },
    ],
  }),
  component: HealthAdditionalRequirementsPage,
});
