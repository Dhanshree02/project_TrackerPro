import { useEffect, useState } from "react";
import {
  fetchAllEmployees,
  fetchDesignationOptions,
  fetchEmployees,
  type ApiEmployeeListItem,
} from "@/lib/api/employees";

/** Active employees whose designation is Engagement Manager (from mst_designations / employees). */
export async function fetchEngagementManagers(): Promise<ApiEmployeeListItem[]> {
  const designations = await fetchDesignationOptions();
  const emDesignationIds = designations
    .filter((d) => (d.name ?? "").trim().toLowerCase() === "engagement manager")
    .map((d) => d.id);

  let items: ApiEmployeeListItem[] = [];
  if (emDesignationIds.length > 0) {
    const pages = await Promise.all(
      emDesignationIds.map((designationId) =>
        fetchEmployees({ designationId, perPage: 100, status: "Active" }).then((p) => p.items),
      ),
    );
    const byId = new Map<string, ApiEmployeeListItem>();
    for (const item of pages.flat()) byId.set(item.id, item);
    items = [...byId.values()];
  }

  const all = await fetchAllEmployees();
  for (const e of all) {
    if ((e.designation ?? "").trim().toLowerCase() === "engagement manager") {
      if (!items.some((x) => x.id === e.id)) items.push(e);
    }
  }

  return items.sort((a, b) => a.fullName.localeCompare(b.fullName));
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
