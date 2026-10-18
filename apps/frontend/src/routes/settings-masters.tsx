import { createFileRoute } from "@tanstack/react-router";
import { SettingsMastersPage } from "@/modules/settings";

export const Route = createFileRoute("/settings-masters")({
  head: () => ({
    meta: [
      { title: "Masters — Settings — Pulse PMO" },
      { name: "description", content: "Centralized configuration and master data management." },
    ],
  }),
  component: SettingsMastersPage,
});
