import { createFileRoute, Link } from "@tanstack/react-router";
import { ShieldX } from "lucide-react";
import { DEFAULT_DEMO_ROLE, setStoredDemoRole } from "@/lib/user-personas";

export const Route = createFileRoute("/access-denied")({
  head: () => ({
    meta: [
      { title: "Access Denied — Pulse PMO" },
      { name: "description", content: "You don't have permission to view this page." },
    ],
  }),
  component: AccessDeniedPage,
});

function continueAsAdmin() {
  setStoredDemoRole(DEFAULT_DEMO_ROLE);
  window.location.assign("/");
}

function AccessDeniedPage() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-background px-4">
      <div className="max-w-md text-center">
        <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-destructive/10 text-destructive">
          <ShieldX className="h-7 w-7" />
        </div>
        <h1 className="mt-5 text-7xl font-bold tracking-tight text-foreground">403</h1>
        <h2 className="mt-2 text-xl font-semibold text-foreground">Access Denied</h2>
        <p className="mt-2 text-sm text-muted-foreground">
          This browser session is using a role that cannot open this page. Opening the app by
          IP uses a different saved user than localhost. Continue as Admin, or pick another
          person from Switch User after you are back in.
        </p>
        <div className="mt-6 flex flex-wrap items-center justify-center gap-2">
          <button
            type="button"
            onClick={continueAsAdmin}
            className="inline-flex items-center justify-center rounded-md bg-primary px-5 py-2.5 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90"
          >
            Continue as Admin
          </button>
          <Link
            to="/"
            className="inline-flex items-center justify-center rounded-md border border-input bg-background px-5 py-2.5 text-sm font-medium text-foreground transition-colors hover:bg-accent"
          >
            Back to dashboard
          </Link>
        </div>
      </div>
    </div>
  );
}
