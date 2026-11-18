import { createFileRoute } from "@tanstack/react-router";
import { ProjectDetailPage } from "@/modules/projects";
import { loadProjectDetail } from "@/modules/projects/loaders/project-detail-loader";

export const Route = createFileRoute("/projects/$projectId")({
  ssr: false,
  loader: async ({ params }) => loadProjectDetail(params.projectId),
  head: ({ loaderData }) => ({
    meta: [
      { title: `${loaderData?.project?.name ?? "Project"} — Pulse PMO` },
      { name: "description", content: loaderData?.project?.description ?? "Project details." },
    ],
  }),
  component: ProjectDetailPage,
});
