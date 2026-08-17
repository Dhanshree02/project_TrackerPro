import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import {
  changePassword as apiChangePassword,
  getMe,
  login as apiLogin,
  logout as apiLogout,
  restoreSession,
  type AuthUser,
} from "@/lib/api-client";

export type AuthStatus = "loading" | "authed" | "anon";

interface AuthContextValue {
  status: AuthStatus;
  user: AuthUser | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  changePassword: (currentPassword: string, newPassword: string) => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [status, setStatus] = useState<AuthStatus>("loading");
  const [user, setUser] = useState<AuthUser | null>(null);

  useEffect(() => {
    let cancelled = false;

    (async () => {
      try {
        const restored = await restoreSession();
        if (cancelled) return;
        if (!restored) {
          setStatus("anon");
          return;
        }
        const me = await getMe();
        if (cancelled) return;
        setUser(me);
        setStatus("authed");
      } catch {
        if (!cancelled) setStatus("anon");
      }
    })();

    return () => {
      cancelled = true;
    };
  }, []);

  const login = async (email: string, password: string) => {
    await apiLogin(email, password);
    const me = await getMe();
    setUser(me);
    setStatus("authed");
  };

  const logout = async () => {
    await apiLogout();
    setUser(null);
    setStatus("anon");
  };

  // After a successful change the backend clears MustChangePassword, so
  // re-fetch the profile to reflect it immediately.
  const changePassword = async (currentPassword: string, newPassword: string) => {
    await apiChangePassword(currentPassword, newPassword);
    const me = await getMe();
    setUser(me);
  };

  return (
    <AuthContext.Provider value={{ status, user, login, logout, changePassword }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used inside AuthProvider");
  return ctx;
}
