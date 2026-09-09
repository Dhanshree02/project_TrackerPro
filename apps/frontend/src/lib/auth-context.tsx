import { createContext, useContext, useEffect, useState, useCallback, type ReactNode } from "react";
import {
  changePassword as apiChangePassword,
  getMe,
  login as apiLogin,
  loginWithMicrosoft as apiLoginWithMicrosoft,
  logout as apiLogout,
  restoreSession,
  type AuthUser,
} from "@/lib/api-client";
import {
  DEMO_PASSWORD,
  getDemoPersona,
  getStoredDemoRole,
  mockAuthUser,
  setStoredDemoRole,
  type DemoRoleKey,
} from "@/lib/demo-roles";
import { RBAC_STORAGE_KEY } from "@/lib/rbac";

export type AuthStatus = "loading" | "authed" | "anon";

interface AuthContextValue {
  status: AuthStatus;
  user: AuthUser | null;
  demoRole: DemoRoleKey;
  switchDemoRole: (role: DemoRoleKey) => Promise<void>;
  login: (email: string, password: string) => Promise<void>;
  loginWithMicrosoft: (idToken: string) => Promise<void>;
  logout: () => Promise<void>;
  changePassword: (currentPassword: string, newPassword: string) => Promise<void>;
  refreshPermissions: () => void;
}

const AuthContext = createContext<AuthContextValue | null>(null);

async function signInAsDemoRole(role: DemoRoleKey): Promise<AuthUser> {
  const persona = getDemoPersona(role);
  try {
    await apiLogin(persona.email, DEMO_PASSWORD);
    const me = await getMe();
    return {
      ...me,
      role: persona.key,
      mustChangePassword: false,
      permissions: persona.permissions,
    };
  } catch {
    return mockAuthUser(role);
  }
}

const AUTH_SESSION_KEY = "pulse_auth_active";

export function AuthProvider({ children }: { children: ReactNode }) {
  const initialRole = getStoredDemoRole();
  const isInitiallyActive = typeof window !== "undefined" && localStorage.getItem(AUTH_SESSION_KEY) === "true";

  const [status, setStatus] = useState<AuthStatus>(() => (isInitiallyActive ? "authed" : "anon"));
  const [user, setUser] = useState<AuthUser | null>(() => (isInitiallyActive ? mockAuthUser(initialRole) : null));
  const [demoRole, setDemoRole] = useState<DemoRoleKey>(() => initialRole);

  const refreshPermissions = useCallback(() => {
    const role = getStoredDemoRole();
    const persona = getDemoPersona(role);
    setUser((prev) => {
      if (!prev) return isInitiallyActive ? mockAuthUser(role) : null;
      return {
        ...prev,
        permissions: persona.permissions,
      };
    });
  }, [isInitiallyActive]);

  useEffect(() => {
    // Listen for custom rbac updates to keep active session in sync
    const onRbacUpdate = () => {
      refreshPermissions();
    };
    window.addEventListener("pulse-rbac-updated", onRbacUpdate);
    window.addEventListener("storage", onRbacUpdate);
    return () => {
      window.removeEventListener("pulse-rbac-updated", onRbacUpdate);
      window.removeEventListener("storage", onRbacUpdate);
    };
  }, [refreshPermissions]);

  useEffect(() => {
    let cancelled = false;

    (async () => {
      const isStoredActive = typeof window !== "undefined" && localStorage.getItem(AUTH_SESSION_KEY) === "true";
      if (!isStoredActive) {
        if (!cancelled) {
          setStatus("anon");
          setUser(null);
        }
        return;
      }

      const role = getStoredDemoRole();
      if (!cancelled) {
        setDemoRole(role);
        setUser(mockAuthUser(role));
        setStatus("authed");
      }

      try {
        const restored = await restoreSession();
        if (cancelled) return;
        if (restored) {
          const me = await getMe();
          if (cancelled) return;
          setUser({
            ...me,
            role,
            mustChangePassword: false,
            permissions: getDemoPersona(role).permissions,
          });
          setStatus("authed");
          return;
        }
      } catch {
        // Backend dev bypass
      }

      try {
        const next = await signInAsDemoRole(role);
        if (cancelled) return;
        setUser(next);
      } catch {
        if (!cancelled) setUser(mockAuthUser(role));
      }
      if (!cancelled) setStatus("authed");
    })();

    return () => {
      cancelled = true;
    };
  }, []);

  const login = async (email: string, password: string) => {
    await apiLogin(email, password);
    try {
      const me = await getMe();
      setUser({ ...me, mustChangePassword: false });
    } catch {
      const role = getStoredDemoRole();
      setUser(mockAuthUser(role));
    }
    if (typeof window !== "undefined") {
      localStorage.setItem(AUTH_SESSION_KEY, "true");
    }
    setStatus("authed");
  };

  const loginWithMicrosoft = async (idToken: string) => {
    await apiLoginWithMicrosoft(idToken);
    try {
      const me = await getMe();
      setUser({ ...me, mustChangePassword: false });
    } catch {
      const role = getStoredDemoRole();
      setUser(mockAuthUser(role));
    }
    if (typeof window !== "undefined") {
      localStorage.setItem(AUTH_SESSION_KEY, "true");
    }
    setStatus("authed");
  };

  const switchDemoRole = async (role: DemoRoleKey) => {
    setStoredDemoRole(role);
    setDemoRole(role);
    setUser(mockAuthUser(role));
    if (typeof window !== "undefined") {
      localStorage.setItem(AUTH_SESSION_KEY, "true");
    }
    setStatus("authed");
    try {
      await apiLogout();
    } catch {
      // Local switch still proceeds if the API is unreachable.
    }
    try {
      const next = await signInAsDemoRole(role);
      setUser(next);
    } catch {
      setUser(mockAuthUser(role));
    }
    setStatus("authed");
    window.dispatchEvent(new CustomEvent("pulse-rbac-updated"));
  };

  const logout = async () => {
    try {
      await apiLogout();
    } catch {
      // ignore
    }
    if (typeof window !== "undefined") {
      localStorage.removeItem(AUTH_SESSION_KEY);
    }
    clearSession();
    setUser(null);
    setStatus("anon");
  };

  const changePassword = async (currentPassword: string, newPassword: string) => {
    await apiChangePassword(currentPassword, newPassword);
    const me = await getMe();
    setUser({ ...me, mustChangePassword: false });
  };

  return (
    <AuthContext.Provider
      value={{
        status,
        user,
        demoRole,
        switchDemoRole,
        login,
        loginWithMicrosoft,
        logout,
        changePassword,
        refreshPermissions,
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
