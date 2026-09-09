import { useEffect, useState } from "react";
import {
  fetchAllEmployees,
  fetchDepartmentOptions,
  fetchEmployees,
  type ApiEmployeeListItem,
} from "@/lib/api/employees";

export const FUNCTIONAL_SALES_DEPARTMENT = "Functional - Sales";

/** Matches mst_departments name/code for the Sales org unit. */
export function isFunctionalSalesDepartment(nameOrCode: string | null | undefined): boolean {
  const n = (nameOrCode ?? "").trim().toLowerCase().replace(/\s+/g, " ");
  return n === "functional - sales" || n === "functional-sales" || n === "functional_sales";
}

async function fetchEmployeesByDepartment(departmentId: string): Promise<ApiEmployeeListItem[]> {
  const first = await fetchEmployees({ departmentId, perPage: 100, status: "Active" });
  const all = [...(first.items ?? [])];
  for (let p = 2; p <= (first.totalPages || 1); p++) {
    const next = await fetchEmployees({
      departmentId,
      page: p,
      perPage: 100,
      status: "Active",
    });
    all.push(...(next.items ?? []));
  }
  return all;
}

/** Active employees whose department is Functional - Sales. */
export async function fetchSalesManagers(): Promise<ApiEmployeeListItem[]> {
  const departments = await fetchDepartmentOptions();
  const salesDeptIds = departments.filter((d) => isFunctionalSalesDepartment(d.name) || isFunctionalSalesDepartment(d.code)).map((d) => d.id);

  const byId = new Map<string, ApiEmployeeListItem>();
  if (salesDeptIds.length > 0) {
    const pages = await Promise.all(salesDeptIds.map((id) => fetchEmployeesByDepartment(id)));
    for (const item of pages.flat()) byId.set(item.id, item);
  }

  const all = await fetchAllEmployees();
  for (const e of all) {
    if (isFunctionalSalesDepartment(e.department)) byId.set(e.id, e);
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
