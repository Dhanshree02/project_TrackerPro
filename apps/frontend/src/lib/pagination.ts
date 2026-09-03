/** Sentinel value: show every row (no client-side slice / fetch all server pages). */
export const PAGE_SIZE_ALL = 0;

export const PAGE_SIZE_OPTIONS = [10, 15, 25, 50, 100] as const;

export function isAllPageSize(pageSize: number): boolean {
  return pageSize === PAGE_SIZE_ALL;
}

export function effectivePageSize(pageSize: number, totalItems: number): number {
  return isAllPageSize(pageSize) ? Math.max(totalItems, 1) : pageSize;
}

export function totalPageCount(totalItems: number, pageSize: number): number {
  if (totalItems === 0 || isAllPageSize(pageSize)) return 1;
  return Math.max(1, Math.ceil(totalItems / pageSize));
}

export function paginationRange(
  page: number,
  pageSize: number,
  total: number,
): { from: number; to: number } {
  if (total === 0) return { from: 0, to: 0 };
  if (isAllPageSize(pageSize)) return { from: 1, to: total };
  return {
    from: (page - 1) * pageSize + 1,
    to: Math.min(page * pageSize, total),
  };
}

export function paginateSlice<T>(items: T[], page: number, pageSize: number): T[] {
  if (isAllPageSize(pageSize)) return items;
  const start = (page - 1) * pageSize;
  return items.slice(start, start + pageSize);
}
