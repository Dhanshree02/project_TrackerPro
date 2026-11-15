import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import { apiFetch, type AuthUser } from "@/lib/api-client";

export type AuthStatus = "loading" | "authed" | "anonymous";

interface AuthContextValue {
  status: AuthStatus;
  user: AuthUser | null;
  permissionsReady: boolean;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
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
    <AuthContext.Provider value={{ status, user, permissionsReady: status !== "loading", logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used inside AuthProvider");
  return ctx;
}
