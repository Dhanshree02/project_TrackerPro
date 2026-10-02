import { createContext, useContext, useState, type ReactNode } from "react";
import type { AuthUser } from "@/lib/api-client";
import {
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
  switchDemoRole: (role: DemoRoleKey) => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const initialRole = getStoredDemoRole();
  const [status] = useState<AuthStatus>("authed");
  const [demoRole, setDemoRole] = useState<DemoRoleKey>(() => initialRole);
  const [user, setUser] = useState<AuthUser | null>(() => mockAuthUser(initialRole));

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
