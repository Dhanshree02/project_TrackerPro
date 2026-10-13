import { createFileRoute, redirect } from "@tanstack/react-router";

export const Route = createFileRoute("/settings/masters")({
  beforeLoad: () => {
    throw redirect({ to: "/projects" });
  },
});
