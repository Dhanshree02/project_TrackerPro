import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
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

export function AuthProvider({ children }: { children: ReactNode }) {
  const initialRole = getStoredDemoRole();
  // Dev mode: always treat the selected demo role as authenticated immediately.
  const [status, setStatus] = useState<AuthStatus>("authed");
  const [user, setUser] = useState<AuthUser | null>(() => mockAuthUser(initialRole));
  const [demoRole, setDemoRole] = useState<DemoRoleKey>(() => initialRole);

  useEffect(() => {
    let cancelled = false;

    (async () => {
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
        // Backend dev bypass allows API calls without a JWT.
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
    const me = await getMe();
    setUser({ ...me, mustChangePassword: false });
    setStatus("authed");
  };

  const loginWithMicrosoft = async (idToken: string) => {
    await apiLoginWithMicrosoft(idToken);
    const me = await getMe();
    setUser({ ...me, mustChangePassword: false });
    setStatus("authed");
  };

  const switchDemoRole = async (role: DemoRoleKey) => {
    if (role === demoRole && status === "authed") return;
    setStoredDemoRole(role);
    setDemoRole(role);
    setUser(mockAuthUser(role));
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
  };

  const logout = async () => {
    try {
      await apiLogout();
    } catch {
      // ignore
    }
    const role = getStoredDemoRole();
    setUser(mockAuthUser(role));
    setStatus("authed");
    try {
      const next = await signInAsDemoRole(role);
      setUser(next);
    } catch {
      setUser(mockAuthUser(role));
    }
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
