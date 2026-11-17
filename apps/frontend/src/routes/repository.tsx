import { createFileRoute } from "@tanstack/react-router";
import { RepositoryRoute } from "@/modules/repository/pages/repository-page";

export const Route = createFileRoute("/repository")({
  head: () => ({
    meta: [
      { title: "Repository — Pulse PMO" },
      {
        name: "description",
        content: "Organization documents, Standard Operating Procedures, and policy resources.",
      },
    ],
  }),
  component: RepositoryRoute,
});
