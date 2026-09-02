import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useEffect, useState, type FormEvent } from "react";
import {
  AlertCircle,
  Eye,
  EyeOff,
  Loader2,
  Lock,
  LogIn,
  Mail,
  ShieldCheck,
  Sparkles,
} from "lucide-react";
import { toast } from "sonner";
import { useAuth } from "@/lib/auth-context";
import {
  handleMsalRedirectResult,
  loginWithMicrosoftPopup,
  loginWithMicrosoftRedirect,
} from "@/lib/msal-client";

export const Route = createFileRoute("/login")({
  head: () => ({
    meta: [
      { title: "Sign in — Pulse PMO" },
      {
        name: "description",
        content: "Sign in to Pulse PMO using Microsoft SSO or your organization credentials.",
      },
    ],
  }),
  component: LoginPage,
});

function LoginPage() {
  const { login, loginWithMicrosoft } = useAuth();
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);
  const [loading, setLoading] = useState(false);
  const [msLoading, setMsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // If this window is the popup callback window, show minimal state
  const isPopupCallback =
    typeof window !== "undefined" && Boolean(window.opener && window.name.includes("msal"));

  useEffect(() => {
    let active = true;
    (async () => {
      try {
        const response = await handleMsalRedirectResult();
        if (response?.idToken && active) {
          setMsLoading(true);
          await loginWithMicrosoft(response.idToken);
          toast.success("Welcome!", {
            description: `Signed in as ${response.account?.name || response.account?.username || "Microsoft account"}`,
          });
          navigate({ to: "/" });
        }
      } catch (err) {
        if (active) {
          const msg = err instanceof Error ? err.message : "Microsoft redirect sign-in failed.";
          setError(msg);
        }
      }
    })();
    return () => {
      active = false;
    };
  }, [loginWithMicrosoft, navigate]);

  if (isPopupCallback) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-slate-50 dark:bg-background">
        <div className="flex items-center gap-2.5 rounded-xl border border-slate-200 bg-white p-4 shadow-sm text-sm text-muted-foreground dark:border-border dark:bg-card">
          <Loader2 className="h-5 w-5 animate-spin text-primary" />
          <span>Authenticating with Microsoft…</span>
        </div>
      </div>
    );
  }

  // Microsoft Single Sign-On Handler (Full page redirect flow)
  const handleMicrosoftLogin = async () => {
    setError(null);
    setMsLoading(true);

    try {
      if (typeof window !== "undefined") {
        sessionStorage.removeItem("msal.interaction.status");
      }
      await loginWithMicrosoftRedirect();
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Microsoft sign-in failed to initiate.";
      setError(msg);
      toast.error("Microsoft sign-in error", { description: msg });
      setMsLoading(false);
    }
  };

  // Manual Email / Password Login Handler
  const handleManualLogin = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);

    const cleanEmail = email.trim();
    if (!cleanEmail) {
      setError("Please enter your organization email or Employee ID.");
      return;
    }
    if (!password) {
      setError("Please enter your password.");
      return;
    }

    setLoading(true);
    try {
      await login(cleanEmail, password);
      toast.success("Welcome back!", {
        description: `Signed in as ${cleanEmail}`,
      });
      navigate({ to: "/" });
    } catch (err) {
      const msg =
        err instanceof Error ? err.message : "Invalid credentials. Please check and try again.";
      setError(msg);
      toast.error("Login failed", { description: msg });
    } finally {
      setLoading(false);
    }
  };

  const handleFillDemo = () => {
    setEmail("dhanshree@acme.co");
    setPassword("Password@123");
    setError(null);
  };

  return (
    <div className="relative flex min-h-screen flex-col items-center justify-center overflow-hidden bg-slate-50/80 px-4 py-8 dark:bg-background">
      {/* Background ambient glows */}
      <div
        className="pointer-events-none absolute -left-28 -top-28 h-96 w-96 rounded-full bg-blue-500/10 blur-3xl"
        aria-hidden="true"
      />
      <div
        className="pointer-events-none absolute -bottom-28 -right-28 h-96 w-96 rounded-full bg-indigo-500/10 blur-3xl"
        aria-hidden="true"
      />

      <div className="relative z-10 w-full max-w-md">
        {/* Main Login Card */}
        <div className="rounded-2xl border border-slate-200/90 bg-white p-7 shadow-[0_8px_30px_rgb(0,0,0,0.06)] sm:p-9 dark:border-border/80 dark:bg-card">
          {/* 1. PMS Logo & Header */}
          <div className="flex flex-col items-center text-center">
            <div
              className="flex h-14 w-14 items-center justify-center rounded-2xl bg-gradient-to-br from-blue-600 via-primary to-indigo-600 text-2xl font-extrabold tracking-tight text-white shadow-md ring-4 ring-blue-500/15"
              aria-label="Pulse PMO Logo"
            >
              P
            </div>

            <h1 className="mt-4 text-2xl font-bold tracking-tight text-foreground sm:text-3xl">
              Welcome to PMS
            </h1>
            <p className="mt-1 text-sm text-muted-foreground">
              Sign in to continue to your workspace
            </p>
          </div>

          {/* 2. Microsoft SSO Login Button */}
          <div className="mt-6">
            <button
              type="button"
              onClick={handleMicrosoftLogin}
              disabled={msLoading || loading}
              className="group flex h-11 w-full cursor-pointer items-center justify-center gap-3 rounded-xl border border-slate-300 bg-white px-4 text-sm font-semibold text-slate-800 shadow-2xs transition-all duration-150 hover:border-slate-400 hover:bg-slate-50 hover:shadow-xs active:scale-[0.99] disabled:cursor-not-allowed disabled:opacity-60 dark:border-border dark:bg-muted/40 dark:text-foreground dark:hover:border-border/80 dark:hover:bg-muted/70"
            >
              {msLoading ? (
                <Loader2 className="h-4.5 w-4.5 animate-spin text-primary" />
              ) : (
                <svg
                  className="h-4.5 w-4.5 shrink-0 transition-transform duration-150 group-hover:scale-105"
                  viewBox="0 0 21 21"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                  aria-hidden="true"
                >
                  <rect x="1" y="1" width="9" height="9" fill="#F25022" />
                  <rect x="11" y="1" width="9" height="9" fill="#7FBA00" />
                  <rect x="1" y="11" width="9" height="9" fill="#00A4EF" />
                  <rect x="11" y="11" width="9" height="9" fill="#FFB900" />
                </svg>
              )}
              <span>{msLoading ? "Connecting to Microsoft…" : "Login with Microsoft"}</span>
            </button>
            <p className="mt-1.5 text-center text-[11px] font-medium text-muted-foreground">
              Your organization account
            </p>
          </div>

          {/* 3. Divider: OR continue with credentials */}
          <div className="relative my-5 flex items-center justify-center">
            <div className="w-full border-t border-slate-200 dark:border-border/70" />
            <span className="absolute bg-white px-3 text-[11px] font-semibold uppercase tracking-wider text-muted-foreground dark:bg-card">
              or sign in with password
            </span>
          </div>

          {/* 4. Manual Credentials Form */}
          <form onSubmit={handleManualLogin} className="space-y-4">
            {/* Error Message Banner */}
            {error && (
              <div className="flex items-start gap-2 rounded-lg border border-destructive/30 bg-destructive/10 p-3 text-xs text-destructive">
                <AlertCircle className="mt-0.5 h-4 w-4 shrink-0" />
                <span>{error}</span>
              </div>
            )}

            {/* Email / ID Input */}
            <div>
              <label htmlFor="email" className="mb-1.5 block text-xs font-semibold text-foreground">
                Email or Employee ID
              </label>
              <div className="relative">
                <Mail className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <input
                  id="email"
                  type="text"
                  autoComplete="username"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="name@acme.co"
                  className="h-10 w-full rounded-lg border border-input bg-background pl-9 pr-3 text-sm text-foreground outline-none transition-colors focus-visible:border-primary focus-visible:ring-2 focus-visible:ring-ring"
                />
              </div>
            </div>

            {/* Password Input */}
            <div>
              <div className="mb-1.5 flex items-center justify-between">
                <label htmlFor="password" className="text-xs font-semibold text-foreground">
                  Password
                </label>
                <button
                  type="button"
                  onClick={() =>
                    toast.info("Password Reset", {
                      description: "Please contact your PMS Administrator or IT Helpdesk.",
                    })
                  }
                  className="text-xs font-medium text-primary hover:underline cursor-pointer"
                >
                  Forgot password?
                </button>
              </div>
              <div className="relative">
                <Lock className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <input
                  id="password"
                  type={showPassword ? "text" : "password"}
                  autoComplete="current-password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••••••"
                  className="h-10 w-full rounded-lg border border-input bg-background pl-9 pr-10 text-sm text-foreground outline-none transition-colors focus-visible:border-primary focus-visible:ring-2 focus-visible:ring-ring"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword((prev) => !prev)}
                  className="absolute right-2.5 top-1/2 -translate-y-1/2 p-1 text-muted-foreground transition-colors hover:text-foreground cursor-pointer"
                  title={showPassword ? "Hide password" : "Show password"}
                  aria-label={showPassword ? "Hide password" : "Show password"}
                >
                  {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                </button>
              </div>
            </div>

            {/* Remember Me Checkbox */}
            <div className="flex items-center justify-between pt-0.5">
              <label className="flex items-center gap-2 text-xs text-muted-foreground cursor-pointer select-none">
                <input
                  type="checkbox"
                  checked={rememberMe}
                  onChange={(e) => setRememberMe(e.target.checked)}
                  className="h-3.5 w-3.5 rounded border-input text-primary focus:ring-primary"
                />
                <span>Remember me on this device</span>
              </label>
            </div>

            {/* Sign In Submit Button */}
            <button
              type="submit"
              disabled={loading}
              className="inline-flex h-11 w-full cursor-pointer items-center justify-center gap-2 rounded-xl bg-primary text-sm font-semibold text-primary-foreground shadow-sm transition-all hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-60"
            >
              {loading ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <LogIn className="h-4 w-4" />
              )}
              <span>{loading ? "Signing in…" : "Sign In"}</span>
            </button>

            {/* Quick Demo Fill Button */}
            <button
              type="button"
              onClick={handleFillDemo}
              className="inline-flex h-8 w-full items-center justify-center gap-1.5 rounded-lg border border-dashed border-slate-300 bg-slate-50/70 text-xs font-medium text-slate-600 transition-colors hover:border-primary/50 hover:bg-blue-50/50 hover:text-primary dark:border-border dark:bg-muted/30 dark:text-muted-foreground dark:hover:text-foreground cursor-pointer"
            >
              <Sparkles className="h-3 w-3 text-primary" />
              <span>Fill Demo Admin Credentials (dhanshree@acme.co)</span>
            </button>
          </form>

          {/* Security Assurance Badge */}
          <div className="mt-6 border-t border-slate-200/80 pt-4 dark:border-border/60">
            <div className="flex items-center justify-center gap-1.5 text-xs text-muted-foreground/80">
              <ShieldCheck className="h-4 w-4 text-emerald-600 dark:text-emerald-400" />
              <span>Protected by Role-Based Access Control (RBAC)</span>
            </div>
          </div>
        </div>

        {/* Brand Footer */}
        <p className="mt-6 text-center text-xs text-muted-foreground">
          Pulse PMO · Enterprise Project Management Platform
        </p>
      </div>
    </div>
  );
}
