import { useEffect, useState } from "react";
import {
  fetchAllEmployees,
  fetchDesignationOptions,
  fetchEmployees,
  type ApiEmployeeListItem,
} from "@/lib/api/employees";

export const SALES_MANAGER_DESIGNATIONS = [
  "Business Development Associate - I",
  "Customer Success Representative - II",
] as const;

export const FUNCTIONAL_SALES_DEPARTMENT = "Functional - Sales";

/** Matches mst_departments name/code for the Sales org unit (legacy fallback). */
export function isFunctionalSalesDepartment(nameOrCode: string | null | undefined): boolean {
  const n = (nameOrCode ?? "").trim().toLowerCase().replace(/\s+/g, " ");
  return n === "functional - sales" || n === "functional-sales" || n === "functional_sales";
}

/** Matches the 2 designated Sales Manager designations from the database. */
export function isSalesManagerDesignation(designationName: string | null | undefined): boolean {
  if (!designationName) return false;
  const normalized = designationName
    .trim()
    .toLowerCase()
    .replace(/\s*-\s*/g, " - ")
    .replace(/\s+/g, " ");
  return (
    normalized === "business development associate - i" ||
    normalized === "customer success representative - ii"
  );
}

/** Active employees whose designation is Business Development Associate - I or Customer Success Representative - II. */
export async function fetchSalesManagers(): Promise<ApiEmployeeListItem[]> {
  const byId = new Map<string, ApiEmployeeListItem>();

  try {
    const designations = await fetchDesignationOptions();
    const targetDesignationIds = (Array.isArray(designations) ? designations : [])
      .filter((d) => isSalesManagerDesignation(d.name))
      .map((d) => d.id);

    if (targetDesignationIds.length > 0) {
      const pages = await Promise.all(
        targetDesignationIds.map((designationId) =>
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
    console.warn("fetchSalesManagers: designation query failed", err);
  }

  // Augmentation / directory fallback
  try {
    const all = await fetchAllEmployees();
    for (const e of all) {
      if (isSalesManagerDesignation(e.designation)) {
        if ((!e.status || e.status === "Active") && !byId.has(e.id)) {
          byId.set(e.id, e);
        }
      }
    }
  } catch (err) {
    if (byId.size === 0) {
      console.warn("fetchSalesManagers: fetchAllEmployees fallback also failed", err);
    }
  }

  return [...byId.values()].sort((a, b) => a.fullName.localeCompare(b.fullName));
}

export function filterSalesManagers(pool: ApiEmployeeListItem[], query: string): ApiEmployeeListItem[] {
  const q = query.trim().toLowerCase();
  if (!q) return pool;
  return pool.filter(
    (p) =>
      p.fullName.toLowerCase().includes(q) ||
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
