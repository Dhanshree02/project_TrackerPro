import { createFileRoute, Navigate } from "@tanstack/react-router";
import { Clock } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";

export const Route = createFileRoute("/my-team/timesheets")({
  head: () => ({
    meta: [
      { title: "Timesheets — Pulse PMO" },
      { name: "description", content: "Team timesheet management." },
    ],
  }),
  component: TimesheetsRoute,
});

function TimesheetsRoute() {
  const { isDhanshree } = useRoleContext();
  if (!isDhanshree) return <Navigate to="/" />;

  return (
    <AppShell
      title="Timesheets"
      subtitle="Team timesheet management"
    >
      <div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-border bg-card py-24 text-center">
        <div className="mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-primary/10">
          <Clock className="h-7 w-7 text-primary" />
        </div>
        <h2 className="text-base font-semibold">Timesheets — Coming Soon</h2>
        <p className="mt-2 max-w-xs text-sm text-muted-foreground">
          Timesheet management for your team will be available here. Check back soon.
        </p>
      </div>
    </AppShell>
  );
}
