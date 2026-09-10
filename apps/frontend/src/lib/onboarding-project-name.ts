/** Next client project number, padded to at least two digits (`01`, `02`, `10`). */
export function formatClientProjectCount(existingCount: number): string {
  const next = Math.max(0, existingCount) + 1;
  return String(next).padStart(2, "0");
}

/**
 * Unique trimmed names in first-seen order.
 * Empty / whitespace-only values are ignored.
 */
export function uniqueTrimmedNames(names: readonly string[]): string[] {
  const seen = new Set<string>();
  const out: string[] = [];
  for (const raw of names) {
    const name = raw.trim();
    if (!name) continue;
    const key = name.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    out.push(name);
  }
  return out;
}

export function countProjectsForClient(
  projects: readonly { clientId: string }[],
  clientId: string,
): number {
  const id = clientId.trim();
  if (!id) return 0;
  return projects.filter((p) => p.clientId === id).length;
}

export type OnboardingProjectNameInput = {
  clientName: string;
  subVentureName: string;
  /** Sub-department of each selected service — never service or department names. */
  subDepartmentNames: readonly string[];
  existingClientProjectCount: number;
};

/**
 * One unique sub-department → that name. More than one unique sub-department → `Mixed`.
 * The descriptive part is never a service name or a department name.
 */
export function projectNameDescriptor(subDepartmentNames: readonly string[]): string {
  const subDepts = uniqueTrimmedNames(subDepartmentNames);
  if (subDepts.length === 0) return "";
  return subDepts.length === 1 ? subDepts[0] : "Mixed";
}

/**
 * `{ClientName}({SubVentureName})_{SubDepartmentOrMixed}_{ClientProjectCount}`
 *
 * Sub-venture is used as stored (hyphenated 3rd-child names included).
 * Returns "" until client, sub-venture, and at least one sub-department are present.
 */
export function buildOnboardingProjectName(input: OnboardingProjectNameInput): string {
  const clientName = input.clientName.trim();
  const subVentureName = input.subVentureName.trim();
  const descriptor = projectNameDescriptor(input.subDepartmentNames);
  if (!clientName || !subVentureName || !descriptor) return "";

  const count = formatClientProjectCount(input.existingClientProjectCount);
  return `${clientName}(${subVentureName})_${descriptor}_${count}`;
}

/**
 * New projects use the generated name. A renewal keeps the selected
 * project's name exactly — no `(1)` suffix and no new-project convention.
 */
export function resolveOnboardingProjectName(
  input: OnboardingProjectNameInput & {
    isRenewal: boolean;
    previousProjectName?: string | null;
  },
): string {
  if (input.isRenewal) return (input.previousProjectName ?? "").trim();
  return buildOnboardingProjectName(input);
}
