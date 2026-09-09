/** Next client project number, padded to at least two digits (`01`, `02`, `10`). */
export function formatClientProjectCount(existingCount: number): string {
  const next = Math.max(0, existingCount) + 1;
  return String(next).padStart(2, "0");
}

/**
 * Unique selected service names in first-seen order.
 * Empty / whitespace-only names are ignored.
 */
export function uniqueServiceNames(names: readonly string[]): string[] {
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

/**
 * `{ClientName}({SubVentureName})_{ServiceNameOrMixed}_{ClientProjectCount}`
 *
 * One unique service → that service name. More than one → `Mixed`.
 * Sub-venture is used as stored (hyphenated 3rd-child names included).
 * Returns "" until client, sub-venture, and at least one service are present.
 */
export function buildOnboardingProjectName(input: {
  clientName: string;
  subVentureName: string;
  serviceNames: readonly string[];
  existingClientProjectCount: number;
}): string {
  const clientName = input.clientName.trim();
  const subVentureName = input.subVentureName.trim();
  const services = uniqueServiceNames(input.serviceNames);
  if (!clientName || !subVentureName || services.length === 0) return "";

  const servicePart = services.length === 1 ? services[0] : "Mixed";
  const count = formatClientProjectCount(input.existingClientProjectCount);
  return `${clientName}(${subVentureName})_${servicePart}_${count}`;
}

/**
 * New projects use the generated name. A renewal keeps the selected
 * project's name exactly — no `(1)` suffix and no new-project convention.
 */
export function resolveOnboardingProjectName(input: {
  isRenewal: boolean;
  previousProjectName?: string | null;
  clientName: string;
  subVentureName: string;
  serviceNames: readonly string[];
  existingClientProjectCount: number;
}): string {
  if (input.isRenewal) return (input.previousProjectName ?? "").trim();
  return buildOnboardingProjectName(input);
}
