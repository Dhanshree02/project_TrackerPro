import { useEffect, useState, type FormEvent } from "react";
import { createFileRoute, Navigate } from "@tanstack/react-router";
import { isProductionLogin, useAuth } from "@/lib/auth-context";
import { apiFetch } from "@/lib/api-client";

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
  const microsoftOnly = isProductionLogin();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);

  useEffect(() => {
    if (!error) return;
    window.history.replaceState(window.history.state, "", "/login");
  }, [error]);

  if (status === "authed") return <Navigate to="/" replace />;

  const handlePasswordLogin = async (e: FormEvent) => {
    e.preventDefault();
    setFormError(null);
    if (!email.trim() || !password) {
      setFormError("Enter your email and password.");
      return;
    }
    setSubmitting(true);
    try {
      await apiFetch("/api/v1/auth/login", {
        method: "POST",
        body: JSON.stringify({ email: email.trim(), password }),
      });
      window.location.assign("/");
    } catch (err) {
      setFormError(err instanceof Error ? err.message : "Invalid email or password.");
      setSubmitting(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-background px-4">
      <div className="w-full max-w-md rounded-2xl border border-border bg-card p-8 shadow-sm">
        <h1 className="text-5xl font-bold tracking-tight text-primary">PMS</h1>
        <p className="mt-3 text-2xl font-semibold text-foreground">Sign in</p>
        <p className="mt-2 text-sm text-muted-foreground">
          {microsoftOnly
            ? "Use your Talakunchi Microsoft 365 account."
            : "Sign in with your UAT email and password."}
        </p>
        {(formError || notice) && (
          <p className="mt-4 rounded-md border border-destructive/30 bg-destructive/10 px-3 py-2 text-sm text-destructive">
            {formError ?? (notice ? (ERRORS[notice] ?? "Sign-in could not be completed.") : null)}
          </p>
        )}
        {microsoftOnly ? (
          <a
            href="/api/v1/auth/microsoft/start"
            className="mt-6 inline-flex w-full items-center justify-center rounded-md bg-primary px-4 py-2.5 text-sm font-medium text-primary-foreground hover:bg-primary/90"
          >
            {status === "loading" ? "Checking session…" : "Sign in with Microsoft"}
          </a>
        ) : (
          <form onSubmit={handlePasswordLogin} className="mt-6 space-y-4">
            <div>
              <label htmlFor="login-email" className="block text-sm font-medium text-foreground">
                Email
              </label>
              <input
                id="login-email"
                type="email"
                autoComplete="username"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="uat.admin@talakunchi.com"
                className="mt-1.5 w-full rounded-md border border-input bg-background px-3 py-2 text-sm text-foreground outline-none ring-offset-background focus:ring-2 focus:ring-ring"
              />
            </div>
            <div>
              <label htmlFor="login-password" className="block text-sm font-medium text-foreground">
                Password
              </label>
              <input
                id="login-password"
                type="password"
                autoComplete="current-password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Enter password"
                className="mt-1.5 w-full rounded-md border border-input bg-background px-3 py-2 text-sm text-foreground outline-none ring-offset-background focus:ring-2 focus:ring-ring"
              />
            </div>
            <button
              type="submit"
              disabled={submitting || status === "loading"}
              className="inline-flex w-full items-center justify-center rounded-md bg-primary px-4 py-2.5 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-60"
            >
              {submitting ? "Signing in…" : status === "loading" ? "Checking session…" : "Sign in"}
            </button>
          </form>
        )}
      </div>
    </div>
  );
}
