import { useEffect, useState } from "react";
import {
  fetchAllEmployees,
  fetchEmployees,
  type ApiEmployeeListItem,
} from "@/lib/api/employees";

/** Normalizes role / designation strings to check if employee has RBAC 'Sales Manager' */
export function isSalesManagerRole(roleOrDesignation?: string | null): boolean {
  if (!roleOrDesignation) return false;
  const r = roleOrDesignation.trim().toLowerCase();
  return (
    r === "sales manager" ||
    r === "sales_manager" ||
    r === "salesmanager" ||
    r === "sales manger" ||
    r === "functional - sales manager" ||
    r.includes("sales manager") ||
    r.includes("sales manger")
  );
}

/** Active employees whose RBAC is 'Sales Manager' / 'Sales Manger' in the database. */
export async function fetchSalesManagers(): Promise<ApiEmployeeListItem[]> {
  const byId = new Map<string, ApiEmployeeListItem>();

  // 1. Try server-side query with role
  try {
    const res = await fetchEmployees({ role: "Sales Manager", perPage: 100 });
    for (const item of res.items ?? []) {
      byId.set(item.id, item);
    }
  } catch (err) {
    console.warn("fetchEmployees with role query failed, falling back to full directory", err);
  }

  // 2. Fetch full directory to ensure no active employee with Sales Manager role or designation is missed
  try {
    const all = await fetchAllEmployees();
    for (const e of all) {
      if (isSalesManagerRole(e.role) || isSalesManagerRole(e.designation)) {
        byId.set(e.id, e);
      }
    }
  } catch (err) {
    console.error("Failed to load employees for Sales Managers pool", err);
  }

  return [...byId.values()].sort((a, b) => a.fullName.localeCompare(b.fullName));
}

export function filterSalesManagers(pool: ApiEmployeeListItem[], query: string): ApiEmployeeListItem[] {
  const q = query.trim().toLowerCase();
  if (!q) return pool;
  return pool.filter(
    (p) =>
      p.fullName.toLowerCase().includes(q) ||
      (p.role ?? "").toLowerCase().includes(q) ||
      (p.designation ?? "").toLowerCase().includes(q) ||
      (p.department ?? "").toLowerCase().includes(q) ||
      (p.workEmail ?? "").toLowerCase().includes(q) ||
      (p.employeeCode ?? "").toLowerCase().includes(q),
  );
}

export function useSalesManagers() {
  const [pool, setPool] = useState<ApiEmployeeListItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    fetchSalesManagers()
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
