import { createContext, useContext, useEffect, useLayoutEffect, useState, type ReactNode } from "react";
import { apiFetch, type AuthUser } from "@/lib/api-client";
import {
  getDemoPersona,
  getStoredDemoRole,
  mockAuthUser,
  setStoredDemoRole,
  type DemoRoleKey,
} from "@/lib/demo-roles";

export type AuthStatus = "authed";

interface AuthContextValue {
  status: AuthStatus;
  user: AuthUser | null;
  demoRole: DemoRoleKey;
  permissionsReady: boolean;
  switchDemoRole: (role: DemoRoleKey) => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const initialRole = getStoredDemoRole();
  const [status] = useState<AuthStatus>("authed");
  const [demoRole, setDemoRole] = useState<DemoRoleKey>(() => initialRole);
  const [user, setUser] = useState<AuthUser | null>(() => mockAuthUser(initialRole));
  const [permissionsReady, setPermissionsReady] = useState(false);

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
    setPermissionsReady(false);
    apiFetch<{ role?: string; permissions?: string[] }>("/api/v1/rbac/effective")
      .then((access) => {
        const permissions = access?.permissions ?? [];
        if (cancelled || permissions.length === 0) return;
        setUser((current) =>
          current
            ? { ...current, role: access.role || current.role, permissions }
            : current,
        );
      })
      .catch(() => {})
      .finally(() => {
        if (!cancelled) setPermissionsReady(true);
      });
    return () => {
      cancelled = true;
    };
  }, [demoRole]);

  return (
    <AuthContext.Provider value={{ status, user, demoRole, permissionsReady, switchDemoRole }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used inside AuthProvider");
  return ctx;
}
