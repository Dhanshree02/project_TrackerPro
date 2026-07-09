import { createFileRoute, Link, Navigate } from "@tanstack/react-router";
import { Shield, ChevronRight } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";

export const Route = createFileRoute("/dh-settings")({
  head: () => ({
    meta: [
      { title: "Settings — Pulse PMO" },
      { name: "description", content: "Manage application configuration and security settings." },
    ],
  }),
  component: SettingsPage,
});

function SettingsPage() {
  const { isDhanshree } = useRoleContext();
  if (!isDhanshree) return <Navigate to="/" />;

  return (
    <AppShell title="Settings" subtitle="Manage application configuration">
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
        <Link
          to="/dh-settings-security-roles"
          id="settings-security-roles-card"
          className="group flex items-center gap-4 rounded-xl border border-border bg-card p-5 shadow-sm transition-all hover:border-primary/50 hover:shadow-md"
        >
          <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary transition-colors group-hover:bg-primary/15">
            <Shield className="h-5 w-5" />
          </div>
          <div className="min-w-0 flex-1">
            <h3 className="text-sm font-semibold text-foreground">Security Roles</h3>
            <p className="mt-0.5 text-xs text-muted-foreground">
              Manage user roles and module permissions
            </p>
          </div>
          <ChevronRight className="h-4 w-4 shrink-0 text-muted-foreground transition-transform group-hover:translate-x-0.5 group-hover:text-foreground" />
        </Link>
      </div>
    </AppShell>
  );
}
