/**
 * TrackerPro API client.
 *
 * Base URL: `VITE_API_URL` (default http://localhost:5194 — the .NET API dev port)
 * Dev Mode: Operates seamlessly with backend bypass headers (X-User-Email, X-User-Role)
 *           driven by the frontend User Switcher dropdown. M365 authentication
 *           will be integrated after full feature development.
 */

import { getStoredDemoRole, getDemoPersona } from "@/lib/demo-roles";

const API_BASE =
  (import.meta.env.VITE_API_URL as string | undefined) ??
  (import.meta.env.DEV ? "" : "http://localhost:5194");

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
  role?: string | null;
  roleId?: string | null;
  mustChangePassword: boolean;
  permissions: string[];
}

export function isAuthenticated(): boolean {
  return true;
}

export async function ensureAuthenticated(): Promise<void> {
  return Promise.resolve();
}

/**
 * API fetch wrapper. Attaches the current persona's identity headers
 * so backend development bypass identifies the switched user.
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

/** Authenticated file download (Excel sample, etc.). */
export async function apiDownload(path: string, filename: string): Promise<void> {
  const headers = new Headers();
  const currentRole = getStoredDemoRole();
  const persona = getDemoPersona(currentRole);
  if (persona) {
    headers.set("X-User-Email", persona.email);
    headers.set("X-User-Role", persona.roleKey || "Admin");
    headers.set("X-User-Id", persona.id);
  }

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
  const headers = new Headers(init?.headers);
  if (!(init?.body instanceof FormData)) {
    headers.set("Content-Type", "application/json");
  }

  // Send switched user context to backend
  const currentRole = getStoredDemoRole();
  const persona = getDemoPersona(currentRole);
  if (persona) {
    headers.set("X-User-Email", persona.email);
    headers.set("X-User-Role", persona.roleKey || "Admin");
    headers.set("X-User-Id", persona.id);
  }

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
