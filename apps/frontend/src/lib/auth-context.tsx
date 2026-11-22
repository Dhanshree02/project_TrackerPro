import { createContext, useContext, useEffect, useLayoutEffect, useState, type ReactNode } from "react";
import { apiFetch, type AuthUser } from "@/lib/api-client";
import {
  getDemoPersona,
  getStoredDemoRole,
  mockAuthUser,
  setStoredDemoRole,
  type DemoRoleKey,
} from "@/lib/user-personas";
import { loadEmployeePersonas } from "@/lib/employee-personas";

export type AuthStatus = "loading" | "authed" | "anonymous";

/** Production uses Microsoft sign-in. Development and UAT keep the user switch. */
export function isProductionLogin(): boolean {
  return (import.meta.env.VITE_APP_ENV as string | undefined)?.trim().toLowerCase() === "production";
}

interface AuthContextValue {
  status: AuthStatus;
  user: AuthUser | null;
  demoRole: DemoRoleKey | null;
  permissionsReady: boolean;
  switchDemoRole: (role: DemoRoleKey) => Promise<void>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  if (isProductionLogin()) {
    return <ProductionAuthProvider>{children}</ProductionAuthProvider>;
  }
  return <DevelopmentAuthProvider>{children}</DevelopmentAuthProvider>;
}

function ProductionAuthProvider({ children }: { children: ReactNode }) {
  const [status, setStatus] = useState<AuthStatus>("loading");
  const [user, setUser] = useState<AuthUser | null>(null);

  useEffect(() => {
    let cancelled = false;
    void apiFetch<AuthUser>("/api/v1/auth/me")
      .then((me) => {
        if (cancelled) return;
        setUser({ ...me, permissions: me.permissions ?? [] });
        setStatus("authed");
      })
      .catch(() => {
        if (cancelled) return;
        setUser(null);
        setStatus("anonymous");
      });
    return () => {
      cancelled = true;
    };
  }, []);

  const logout = async () => {
    try {
      await apiFetch("/api/v1/auth/logout", { method: "POST" });
    } catch {
      // The cookie is cleared when the request reached the API.
    }
    setUser(null);
    setStatus("anonymous");
    window.location.assign("/login");
  };

  return (
    <AuthContext.Provider
      value={{
        status,
        user,
        demoRole: null,
        permissionsReady: status !== "loading",
        switchDemoRole: async () => {},
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

function DevelopmentAuthProvider({ children }: { children: ReactNode }) {
  const initialRole = getStoredDemoRole();
  const [demoRole, setDemoRole] = useState<DemoRoleKey>(() => initialRole);
  const [user, setUser] = useState<AuthUser | null>(() => mockAuthUser(initialRole));

  const switchDemoRole = async (role: DemoRoleKey) => {
    setStoredDemoRole(role);
    setDemoRole(role);
    setUser(mockAuthUser(role));
  };

  // The server cannot read the last switched employee, so apply it before paint.
  useLayoutEffect(() => {
    const stored = getStoredDemoRole();
    const persona = getDemoPersona(stored);
    setDemoRole(persona.key as DemoRoleKey);
    setUser((current) => (current?.email === persona.email ? current : mockAuthUser(persona.key)));
  }, []);

  useEffect(() => {
    let cancelled = false;
    void loadEmployeePersonas().then(() => {
      if (cancelled) return;
      const stored = getStoredDemoRole();
      const persona = getDemoPersona(stored);
      setDemoRole(persona.key as DemoRoleKey);
      setUser(mockAuthUser(persona.key));
    });
    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <AuthContext.Provider
      value={{
        status: "authed",
        user,
        demoRole,
        permissionsReady: true,
        switchDemoRole,
        logout: async () => {},
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used inside AuthProvider");
  return ctx;
}
