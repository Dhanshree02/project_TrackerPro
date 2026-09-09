/** True when this record was created as a renewal of an earlier WBS. */
export function isRenewedProject(project: { renewedFromWbsId?: string } | null | undefined): boolean {
  return Boolean(project?.renewedFromWbsId?.trim());
}

/** Find the original project by its stored WBS ID. */
export function findProjectByWbsId<T extends { wbsId?: string }>(
  projects: readonly T[],
  wbsId: string | undefined | null,
): T | undefined {
  const id = (wbsId ?? "").trim();
  if (!id) return undefined;
  const needle = id.toLowerCase();
  return projects.find((p) => (p.wbsId ?? "").trim().toLowerCase() === needle);
}
