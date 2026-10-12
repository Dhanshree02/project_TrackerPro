import { useEffect, useState } from "react";
import {
  fetchAllEmployees,
  fetchEmployees,
  type ApiEmployeeListItem,
} from "@/lib/api/employees";

/** Normalizes role / designation strings to check if employee has RBAC 'EM (Engagement Manager)' */
export function isEngagementManagerRole(roleOrDesignation?: string | null): boolean {
  if (!roleOrDesignation) return false;
  const r = roleOrDesignation.trim().toLowerCase();
  return (
    r === "engagementmanager" ||
    r === "engagement manager" ||
    r === "engagement_manager" ||
    r === "engagement manager (em)" ||
    r === "em (engagement manager)" ||
    r === "em" ||
    r.includes("engagement manager") ||
    r.startsWith("em (")
  );
}

/** Active employees whose RBAC is 'EM (Engagement Manager)' / 'EngagementManager' in the database. */
export async function fetchEngagementManagers(): Promise<ApiEmployeeListItem[]> {
  const byId = new Map<string, ApiEmployeeListItem>();

  // 1. Try server-side query with role
  try {
    const res = await fetchEmployees({ role: "EngagementManager", perPage: 100 });
    for (const item of res.items ?? []) {
      byId.set(item.id, item);
    }
  } catch (err) {
    console.warn("fetchEmployees with role query failed, falling back to full directory", err);
  }

  // 2. Fetch full active directory to guarantee anyone with EM role or designation is included
  try {
    const all = await fetchAllEmployees();
    for (const e of all) {
      if (isEngagementManagerRole(e.role) || isEngagementManagerRole(e.designation)) {
        byId.set(e.id, e);
      }
    }
  } catch (err) {
    console.error("Failed to load employees for Engagement Managers pool", err);
  }

  return [...byId.values()].sort((a, b) => a.fullName.localeCompare(b.fullName));
}

export function filterEngagementManagers(
  pool: ApiEmployeeListItem[],
  query: string,
): ApiEmployeeListItem[] {
  const q = query.trim().toLowerCase();
  if (!q) return pool;
  return pool.filter(
    (p) =>
      p.fullName.toLowerCase().includes(q) ||
      (p.role ?? "").toLowerCase().includes(q) ||
      (p.designation ?? "").toLowerCase().includes(q) ||
      (p.workEmail ?? "").toLowerCase().includes(q) ||
      (p.employeeCode ?? "").toLowerCase().includes(q),
  );
}

export function useEngagementManagers() {
  const [pool, setPool] = useState<ApiEmployeeListItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    fetchEngagementManagers()
      .then((items) => {
        if (!cancelled) setPool(items);
      })
      .catch(() => {
        if (!cancelled) setPool([]);
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  return { pool, loading };
}
