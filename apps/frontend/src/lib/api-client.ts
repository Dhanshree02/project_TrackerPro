/**
 * API client. The session is an httpOnly cookie set by Microsoft sign-in.
 * The page does not send a bearer token or a user-switch header.
 */

const API_BASE =
  (import.meta.env.VITE_API_URL as string | undefined) ??
  (import.meta.env.DEV ? "" : "http://localhost:5194");

function requestHeaders(init?: HeadersInit): Headers {
  return new Headers(init);
}

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

/** Profile representation. */
export interface AuthUser {
  id: string;
  email: string;
  name: string;
  employeeId?: string | null;
  employeeCode?: string | null;
  role?: string | null;
  roleId?: string | null;
  mustChangePassword: boolean;
  permissions: string[];
  phone?: string | null;
  department?: string | null;
  subDepartment?: string | null;
  designation?: string | null;
  reportingManager?: string | null;
  workLocation?: string | null;
  status?: string | null;
}

export function isAuthenticated(): boolean {
  return false;
}

export async function ensureAuthenticated(): Promise<void> {
  return Promise.resolve();
}

/**
 * API fetch wrapper. The browser sends the session cookie.
 */
export async function apiFetch<T>(path: string, init?: RequestInit): Promise<T> {
  const result = await rawFetch<ApiEnvelope<T>>(path, init);

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

/** Authenticated file bytes (PO preview and download). */
export async function apiFetchBlob(path: string): Promise<Blob> {
  const headers = requestHeaders();
  const res = await fetch(`${API_BASE}${path}`, { headers, credentials: "include" });
  if (!res.ok) {
    let message = `Download failed (${res.status})`;
    try {
      const envelope = (await res.json()) as ApiEnvelope<unknown>;
      message = envelope.errors?.[0]?.message ?? message;
    } catch {
      // non-JSON error body
    }
    throw new Error(message);
  }
  return res.blob();
}

/** Authenticated file download (Excel sample, etc.). */
export async function apiDownload(path: string, filename: string): Promise<void> {
  const headers = requestHeaders();

  const res = await fetch(`${API_BASE}${path}`, { headers, credentials: "include" });

  if (!res.ok) {
    let message = `Download failed (${res.status})`;
    try {
      const envelope = (await res.json()) as ApiEnvelope<unknown>;
      message = envelope.errors?.[0]?.message ?? message;
    } catch {
      // non-JSON error body
    }
    throw new Error(message);
  }

  const blob = await res.blob();
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.download = filename;
  document.body.appendChild(anchor);
  anchor.click();
  anchor.remove();
  URL.revokeObjectURL(url);
}

async function rawFetch<T>(
  path: string,
  init?: RequestInit,
): Promise<{ ok: boolean; status: number; envelope: T }> {
  const headers = requestHeaders(init?.headers);
  if (!(init?.body instanceof FormData)) {
    headers.set("Content-Type", "application/json");
  }

  const res = await fetch(`${API_BASE}${path}`, { ...init, headers, credentials: "include" });
  if (
    res.status === 401 &&
    !path.startsWith("/api/v1/auth/") &&
    typeof window !== "undefined" &&
    window.location.pathname !== "/login"
  ) {
    window.location.assign("/login");
  }

  let envelope = null as T | null;
  try {
    envelope = (await res.json()) as T;
  } catch {
    // non-JSON response (e.g. 204 No Content, proxy errors)
  }

  return { ok: res.ok, status: res.status, envelope: envelope as T };
}

export { API_BASE };
