import { createFileRoute } from "@tanstack/react-router";
import { ProjectOnboardingPage } from "@/modules/projects";

export const Route = createFileRoute("/projects/new")({
  validateSearch: (search: Record<string, unknown>): { draftId?: string } => ({
    draftId: typeof search.draftId === "string" ? search.draftId : undefined,
  }),
  head: () => ({
    meta: [{ title: "New Project — WBS Form" }],
  }),
  component: ProjectOnboardingPage,
});
