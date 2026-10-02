import { createContext, useContext, useState, useEffect, type ReactNode } from "react";
import type { AuthUser } from "@/lib/api-client";
import {
  getStoredDemoRole,
  mockAuthUser,
  setStoredDemoRole,
  type DemoRoleKey,
} from "@/lib/demo-roles";
import { PERMISSIONS_CHANGED_EVENT } from "@/lib/rbac";

export type AuthStatus = "authed" | "loading";

interface AuthContextValue {
  status: AuthStatus;
  user: AuthUser | null;
  demoRole: DemoRoleKey;
  switchDemoRole: (role: DemoRoleKey) => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const initialRole = getStoredDemoRole();
  const [status] = useState<AuthStatus>("authed");
  const [demoRole, setDemoRole] = useState<DemoRoleKey>(() => initialRole);
  const [user, setUser] = useState<AuthUser | null>(() => mockAuthUser(initialRole));

  useEffect(() => {
    const handlePermsChange = () => {
      setUser(mockAuthUser(demoRole));
    };
    window.addEventListener(PERMISSIONS_CHANGED_EVENT, handlePermsChange);
    return () => window.removeEventListener(PERMISSIONS_CHANGED_EVENT, handlePermsChange);
  }, [demoRole]);

  const switchDemoRole = async (role: DemoRoleKey) => {
    setStoredDemoRole(role);
    setDemoRole(role);
    setUser(mockAuthUser(role));
  };

  return (
    <AuthContext.Provider value={{ status, user, demoRole, switchDemoRole }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used inside AuthProvider");
  return ctx;
}
