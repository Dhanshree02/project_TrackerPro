import { createFileRoute } from "@tanstack/react-router";
import { SettingsSecurityRolesPage } from "@/modules/settings";

export const Route = createFileRoute("/settings-security-roles")({
  head: () => ({
    meta: [
      { title: "Roles & Permissions — Settings — Pulse PMO" },
      { name: "description", content: "Assign user roles and fine-grained module permissions." },
    ],
  }),
  component: SettingsSecurityRolesPage,
});
