/**
 * TrackerPro API client.
 *
 * Base URL:  `VITE_API_URL` (default http://localhost:5194 — the .NET API dev port)
 * Auth:      JWT bearer in the Authorization header.
 *            - Access token: kept in memory only (XSS-safe), short-lived (15 min).
 *            - Refresh token: HttpOnly + Secure cookie set by the backend on
 *              login/refresh. It never touches JavaScript, is never stored in
 *              localStorage/sessionStorage/state, and is rotated on every use.
 *            - Page reloads restore the session by calling POST /auth/refresh;
 *              the browser sends the cookie automatically.
 */

const API_BASE =
  (import.meta.env.VITE_API_URL as string | undefined) ??
  (import.meta.env.DEV ? "" : "http://localhost:5194");

/** Dev-only: API accepts unauthenticated requests via backend DevelopmentAuthBypassMiddleware. */
const DEV_BYPASS_AUTH = import.meta.env.DEV;

interface ApiEnvelope<T> {
  data: T | null;
  meta: {
    total?: number;
    page?: number;
    perPage?: number;
    totalPages?: number;
  } | null;
  errors: { code: string; field?: string; message: string }[] | null;
}

/** Profile returned by GET /api/v1/auth/me. */
export interface AuthUser {
  id: string;
  email: string;
  name: string;
  employeeId?: string | null;
  role?: string | null;
  roleId?: string | null;
  mustChangePassword: boolean;
  permissions: string[];
}

interface SessionPayload {
  accessToken: string;
  accessTokenExpiresAtUtc: string;
  user: AuthUser;
}

let accessToken: string | null = null;

// Monotonic counter bumped on every clearSession(). Lets an in-flight refresh
// detect that a logout happened while it was running, so it cannot resurrect
// the session.
let sessionEpoch = 0;

// Single-flight guard: the backend rotates the refresh cookie and treats a
// reused token as theft (revokes the whole family). Concurrent refreshes with
// the same cookie would trip that protection, so only one refresh request may
// be in flight; every other caller awaits the same promise.
let refreshInFlight: Promise<boolean> | null = null;

export function isAuthenticated(): boolean {
  if (DEV_BYPASS_AUTH) return true;
  return accessToken !== null;
}

export function setSession(access: string): void {
  accessToken = access;
}

export function clearSession(): void {
  sessionEpoch += 1;
  accessToken = null;
  // Drop any in-flight refresh so it cannot resurrect the session after logout.
  refreshInFlight = null;
}

/** Logs in with explicit credentials. The refresh token arrives as an HttpOnly cookie. */
export async function login(email: string, password: string): Promise<void> {
  const res = await rawFetch<ApiEnvelope<SessionPayload>>("/api/v1/auth/login", {
    method: "POST",
    body: JSON.stringify({ email, password }),
  });
  if (!res.ok || !res.envelope?.data?.accessToken) {
    throw new Error(res.envelope?.errors?.[0]?.message ?? "Login failed");
  }
  accessToken = res.envelope.data.accessToken;
}

/** Changes the password of the signed-in user. Throws on validation errors. */
export async function changePassword(currentPassword: string, newPassword: string): Promise<void> {
  await apiFetch("/api/v1/auth/change-password", {
    method: "PUT",
    body: JSON.stringify({ currentPassword, newPassword }),
  });
}

/**
 * Revokes the session on the backend (the HttpOnly refresh cookie is read,
 * revoked and cleared server-side) and clears local state.
 */
export async function logout(): Promise<void> {
  try {
    // No body needed — the cookie travels automatically. Anonymous endpoint, so
    // this still works after the access token expired.
    await rawFetch("/api/v1/auth/logout", { method: "POST" });
  } catch {
    // Best-effort — the session is cleared locally regardless.
  }
  clearSession();
}

/** Restores a session from the HttpOnly refresh cookie. Returns false when expired. */
export async function restoreSession(): Promise<boolean> {
  if (accessToken) return true;
  return refreshViaCookie();
}

/** Fetches the current user profile. Requires a live session. */
export async function getMe(): Promise<AuthUser> {
  return apiFetch<AuthUser>("/api/v1/auth/me");
}

/** Ensures a live session exists; throws when unauthenticated. */
export async function ensureAuthenticated(): Promise<void> {
  if (DEV_BYPASS_AUTH) return;
  if (accessToken) return;
  if (await restoreSession()) return;
  throw new Error("Not authenticated");
}

/**
 * Authenticated fetch. Retries once after a token refresh on 401.
 * Returns the API envelope's `data` payload.
 */
export async function apiFetch<T>(path: string, init?: RequestInit): Promise<T> {
  await ensureAuthenticated();

  const doFetch = () => rawFetch<ApiEnvelope<T>>(path, init, true);

  let result = await doFetch();

  // Access token expired — try the refresh cookie exactly once, then retry.
  // A second 401 means the refresh failed too; we do NOT loop.
  if (result.status === 401) {
    const refreshed = await refreshViaCookie();
    if (refreshed) result = await doFetch();
  }

  if (!result.ok) {
    const message = result.envelope?.errors?.[0]?.message ?? `Request failed (${result.status})`;
    const error = new Error(message) as Error & { status?: number };
    error.status = result.status;
    throw error;
  }

  // Bodyless success responses (e.g. 204 No Content) carry no envelope.
  if (result.envelope === null) return undefined as T;
  return result.envelope.data as T;
}

/** Single-flight refresh — only one request at a time; concurrent callers share it. */
function refreshViaCookie(): Promise<boolean> {
  if (refreshInFlight) return refreshInFlight;

  refreshInFlight = (async () => {
    const epoch = sessionEpoch;
    try {
      const res = await rawFetch<ApiEnvelope<SessionPayload>>("/api/v1/auth/refresh", {
        method: "POST",
      });
      if (!res.ok || !res.envelope?.data?.accessToken) {
        clearSession();
        return false;
      }
      // A logout/clear while the refresh was in flight must not re-establish
      // the session.
      if (sessionEpoch !== epoch) return false;
      accessToken = res.envelope.data.accessToken;
      return true;
    } catch {
      clearSession();
      return false;
    }
  })().finally(() => {
    refreshInFlight = null;
  });

  return refreshInFlight;
}

async function rawFetch<T>(
  path: string,
  init?: RequestInit,
  withAuth = false,
): Promise<{ ok: boolean; status: number; envelope: T }> {
  const headers = new Headers(init?.headers);
  headers.set("Content-Type", "application/json");
  if (withAuth && accessToken) headers.set("Authorization", `Bearer ${accessToken}`);

  // credentials: "include" is required so the HttpOnly refresh cookie is sent
  // with /auth/* requests (and matches the backend's AllowCredentials CORS).
  const res = await fetch(`${API_BASE}${path}`, { ...init, headers, credentials: "include" });

  let envelope = null as T | null;
  try {
    envelope = (await res.json()) as T;
  } catch {
    // non-JSON response (e.g. 204 No Content, proxy errors)
  }

  return { ok: res.ok, status: res.status, envelope: envelope as T };
}

export { API_BASE };
