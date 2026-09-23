/** True when this record was created as a renewal of an earlier WBS or project. */
export function isRenewedProject(
  project:
    | {
        renewedFromWbsId?: string | null;
        renewedFromProjectId?: string | null;
        renewedFromProjectCode?: string | null;
        isRenewal?: boolean;
        renewed?: boolean;
        wbsDetails?: any;
      }
    | null
    | undefined,
): boolean {
  if (!project) return false;
  if (Boolean(project.renewedFromWbsId && String(project.renewedFromWbsId).trim())) return true;
  if (Boolean(project.renewedFromProjectId && String(project.renewedFromProjectId).trim())) return true;
  if (Boolean(project.renewedFromProjectCode && String(project.renewedFromProjectCode).trim())) return true;
  if (Boolean(project.isRenewal) || Boolean(project.renewed)) return true;
  if (Boolean(project.wbsDetails?.isRenewal) || Boolean(project.wbsDetails?.renewedFromWbsId)) return true;
  return false;
}

/** Find the original project by its stored WBS ID or project ID. */
export function findProjectByWbsId<T extends { wbsId?: string; id?: string; projectSeqId?: string }>(
  projects: readonly T[],
  wbsId: string | undefined | null,
): T | undefined {
  const id = (wbsId ?? "").trim();
  if (!id) return undefined;
  const needle = id.toLowerCase();
  return projects.find(
    (p) =>
      (p.wbsId ?? "").trim().toLowerCase() === needle ||
      (p.id ?? "").trim().toLowerCase() === needle ||
      (p.projectSeqId ?? "").trim().toLowerCase() === needle,
  );
}
