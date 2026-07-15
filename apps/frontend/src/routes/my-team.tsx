import { createFileRoute, Outlet } from "@tanstack/react-router";

export const Route = createFileRoute("/my-team")({
  component: () => <Outlet />,
});
