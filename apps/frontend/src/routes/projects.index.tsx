import { createFileRoute } from "@tanstack/react-router";
import { ProjectsListPage } from "@/modules/projects";

export const Route = createFileRoute("/projects/")({
  head: () => ({
    meta: [
      { title: "Projects — Pulse PMO" },
      { name: "description", content: "Active, archived and all projects in one workspace." },
    ],
  }),
  component: ProjectsListPage,
});
