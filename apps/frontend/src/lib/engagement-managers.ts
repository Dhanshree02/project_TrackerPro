import { useEffect, useState } from "react";
import {
  fetchAllEmployees,
  fetchDesignationOptions,
  fetchEmployees,
  type ApiEmployeeListItem,
} from "@/lib/api/employees";

export const ENGAGEMENT_MANAGER_DESIGNATIONS = [
  "Delivery Account Manager - I",
  "Delivery Account Manager - II",
  "Senior Delivery Account Manager - I",
  "Senior Delivery Account Manager - II",
] as const;

export function isEngagementManagerDesignation(designationName: string | null | undefined): boolean {
  if (!designationName) return false;
  const normalized = designationName
    .trim()
    .toLowerCase()
    .replace(/\s*-\s*/g, " - ")
    .replace(/\s+/g, " ");
  return (
    normalized === "delivery account manager - i" ||
    normalized === "delivery account manager - ii" ||
    normalized === "senior delivery account manager - i" ||
    normalized === "senior delivery account manager - ii"
  );
}

/** Active employees whose designation is one of the Delivery Account Manager designations. */
export async function fetchEngagementManagers(): Promise<ApiEmployeeListItem[]> {
  const byId = new Map<string, ApiEmployeeListItem>();

  try {
    const designations = await fetchDesignationOptions();
    const emDesignationIds = (Array.isArray(designations) ? designations : [])
      .filter((d) => isEngagementManagerDesignation(d.name))
      .map((d) => d.id);

    if (emDesignationIds.length > 0) {
      const pages = await Promise.all(
        emDesignationIds.map((designationId) =>
          fetchEmployees({ designationId, perPage: 100, status: "Active" })
            .then((p) => p.items ?? [])
            .catch(() => [] as ApiEmployeeListItem[]),
        ),
      );
      for (const item of pages.flat()) {
        if (item?.id) byId.set(item.id, item);
      }
    }
  } catch (err) {
    console.warn("fetchEngagementManagers: designation query failed", err);
  }

  // Augmentation / directory fallback
  try {
    const all = await fetchAllEmployees();
    for (const e of all) {
      if (isEngagementManagerDesignation(e.designation)) {
        if ((!e.status || e.status === "Active") && !byId.has(e.id)) {
          byId.set(e.id, e);
        }
      }
    }
  } catch (err) {
    if (byId.size === 0) {
      console.warn("fetchEngagementManagers: fetchAllEmployees fallback also failed", err);
    }
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
