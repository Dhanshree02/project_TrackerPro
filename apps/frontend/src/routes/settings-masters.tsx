import { createFileRoute } from "@tanstack/react-router";
import { SettingsMastersPage } from "@/modules/settings/pages/settings-masters-page";

export const Route = createFileRoute("/settings-masters")({
  head: () => ({
    meta: [
      { title: "Masters — Settings — Pulse PMO" },
      { name: "description", content: "Centralized configuration and master data management." },
    ],
  }),
  component: SettingsMastersPage,
});
