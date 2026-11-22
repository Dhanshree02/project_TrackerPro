import { createFileRoute } from "@tanstack/react-router";
import { ProjectDetailPage } from "@/modules/projects/pages/project-detail-page";

export const Route = createFileRoute("/projects/$projectId")({
  ssr: false,
  loader: () => ({ project: undefined, client: undefined }),
  head: ({ loaderData }) => ({
    meta: [
      { title: `${loaderData?.project?.name ?? "Project"} — Pulse PMO` },
      { name: "description", content: loaderData?.project?.description ?? "Project details." },
    ],
  }),
  component: ProjectDetailPage,
});
