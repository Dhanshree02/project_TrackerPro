import { useEffect } from "react";
import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useAuth } from "@/lib/auth-context";

const ERRORS: Record<string, string> = {
  not_configured: "Microsoft sign-in is not configured on this server.",
  microsoft_denied: "Microsoft did not complete the sign-in.",
  sign_in_expired: "That sign-in expired. Start again.",
  sign_in_failed: "Microsoft sign-in could not be completed.",
  not_an_employee: "This Microsoft account is not an active employee.",
  no_account: "This employee does not have a login account yet. HR needs to save the profile with an Assigned RBAC Role.",
  account_inactive: "This login account is turned off.",
};

type LoginWindow = Window & { __pmsLoginNotice?: string };

function loginNotice(error?: string) {
  if (typeof window === "undefined") return error;
  const browser = window as LoginWindow;
  if (error) browser.__pmsLoginNotice = error;
  return error ?? browser.__pmsLoginNotice;
}

export const Route = createFileRoute("/login")({
  validateSearch: (search: Record<string, unknown>): { error?: string } => {
    if (typeof search.error === "string" && search.error.length > 0) return { error: search.error };
    return {};
  },
  head: () => ({
    meta: [{ title: "Sign in — PMS" }],
  }),
  component: LoginPage,
});

function LoginPage() {
  const { status } = useAuth();
  const { error } = Route.useSearch();
  const notice = loginNotice(error);

  useEffect(() => {
    if (!error) return;
    window.history.replaceState(window.history.state, "", "/login");
  }, [error]);

  if (status === "authed") return <Navigate to="/" replace />;

  return (
    <div className="flex min-h-screen items-center justify-center bg-background px-4">
      <div className="w-full max-w-md rounded-2xl border border-border bg-card p-8 shadow-sm">
        <h1 className="text-5xl font-bold tracking-tight text-primary">PMS</h1>
        <p className="mt-3 text-2xl font-semibold text-foreground">Sign in</p>
        <p className="mt-2 text-sm text-muted-foreground">
          Use your Talakunchi Microsoft 365 account.
        </p>
        {notice && (
          <p className="mt-4 rounded-md border border-destructive/30 bg-destructive/10 px-3 py-2 text-sm text-destructive">
            {ERRORS[notice] ?? "Sign-in could not be completed."}
          </p>
        )}
        <a
          href="/api/v1/auth/microsoft/start"
          className="mt-6 inline-flex w-full items-center justify-center rounded-md bg-primary px-4 py-2.5 text-sm font-medium text-primary-foreground hover:bg-primary/90"
        >
          {status === "loading" ? "Checking session…" : "Sign in with Microsoft"}
        </a>
      </div>
    </div>
  );
}
