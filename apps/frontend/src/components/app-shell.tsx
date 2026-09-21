import { useEffect, useState, type ReactNode } from "react";
import { Navigate, useRouterState } from "@tanstack/react-router";
import { AppSidebar } from "./app-sidebar";
import { AppTopbar } from "./app-topbar";
import { MobileTabs } from "./mobile-tabs";
import { useAuth } from "@/lib/auth-context";
import { usePermissions } from "@/lib/permissions";
import { useRoleContext } from "@/lib/role-context";
import { NAV_ITEMS, filterNavItems, resolveRoutePermission } from "@/lib/navigation";

function AuthGate() {
  const { status } = useAuth();

  if (status === "loading") {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background">
        <div className="flex flex-col items-center gap-3">
          <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary border-t-transparent" />
          <span className="text-xs text-muted-foreground">Signing you in…</span>
        </div>
      </div>
    );
  }

  if (status === "anon") {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background">
        <div className="flex flex-col items-center gap-3">
          <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary border-t-transparent" />
          <span className="text-xs text-muted-foreground">Signing you in…</span>
        </div>
      </div>
    );
  }

  return null;
}

export function AppShell({
  title,
  subtitle,
  children,
}: {
  title: string;
  subtitle?: ReactNode;
  children: ReactNode;
}) {
  const { status, user } = useAuth();
  const { isHr, isEmployee, isPmFamily, isPmoFamily, isAccounts, isSales } = useRoleContext();
  const [showScrollTop, setShowScrollTop] = useState(false);

  useEffect(() => {
    const onScroll = () => setShowScrollTop(window.scrollY > 300);
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  const pathname = useRouterState({ select: (s) => s.location.pathname });
  const { hasPermission, hasAny } = usePermissions();

  // Every AppShell page requires an authenticated session.
  // NOTE: must stay after all hooks (Rules of Hooks).
  if (status !== "authed") return <AuthGate />;

  // Enforce the temporary-password flow: no module is usable until the
  // MustChangePassword flag is cleared.
  if (user?.mustChangePassword) return <Navigate to="/change-password" />;

  // Users without dashboard access (e.g. HR) land on their first permitted
  // module after login instead of hitting the 403 page on the root route.
  if (pathname === "/" && !hasPermission("dashboard.view")) {
    const items = filterNavItems(NAV_ITEMS, hasPermission, hasAny, {
      isHr,
      isEmployee,
      isPmFamily,
      isPmoFamily,
      isAccounts,
      isSales,
    });
    const landing = items
      .map((i) => i.to ?? i.subItems?.[0]?.to)
      .find((to): to is string => Boolean(to));
    if (landing) return <Navigate to={landing} replace />;
  }

  // Route-level RBAC guard: direct URL access to a module the user has no
  // permission for shows the 403 page instead of rendering the module.
  const required = resolveRoutePermission(pathname);
  if (required !== null) {
    const keys = Array.isArray(required) ? required : [required];
    if (!hasAny(...keys)) return <Navigate to="/access-denied" replace />;
  }

  return (
    <div className="flex min-h-screen w-full isolate bg-background text-foreground">
      <AppSidebar />
      <div className="relative z-0 flex min-w-0 flex-1 flex-col bg-background">
        <AppTopbar title={title} subtitle={subtitle} />
        <main className="flex-1 overflow-x-hidden p-4 md:p-6">{children}</main>
        <MobileTabs />
      </div>

      {/* Scroll-to-top button — appears on all AppShell pages after 300px scroll */}
      <button
        onClick={() => window.scrollTo({ top: 0, behavior: "smooth" })}
        aria-label="Scroll to top"
        title="Scroll to top"
        style={{
          position: "fixed",
          bottom: 32,
          right: 24,
          zIndex: 999,
          width: 44,
          height: 44,
          borderRadius: "50%",
          background: "#1a84d4",
          color: "#fff",
          border: "none",
          cursor: "pointer",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          boxShadow: "0 4px 14px rgba(26,132,212,0.45)",
          opacity: showScrollTop ? 1 : 0,
          pointerEvents: showScrollTop ? "auto" : "none",
          transform: showScrollTop ? "translateY(0)" : "translateY(12px)",
          transition: "opacity 0.3s ease, transform 0.3s ease",
        }}
      >
        <svg
          width="18"
          height="18"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2.5"
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <polyline points="18 15 12 9 6 15" />
        </svg>
      </button>
    </div>
  );
}
