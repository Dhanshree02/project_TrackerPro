import { createFileRoute } from "@tanstack/react-router";
import { RolesPermissionsPage } from "@/modules/settings";

export const Route = createFileRoute("/settings-security-roles")({
  head: () => ({
    meta: [
      { title: "Roles & Permissions — Settings — Pulse PMO" },
      { name: "description", content: "Choose view or view and manage for each module." },
    ],
  }),
  component: RolesPermissionsPage,
});
