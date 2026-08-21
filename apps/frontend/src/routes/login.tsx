import { createFileRoute, Navigate } from "@tanstack/react-router";

export const Route = createFileRoute("/login")({
  head: () => ({
    meta: [{ title: "Pulse PMO" }],
  }),
  component: LoginRedirect,
});

function LoginRedirect() {
  return <Navigate to="/" replace />;
}
