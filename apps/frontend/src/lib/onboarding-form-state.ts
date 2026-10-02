/**
 * Unfinished Project Onboarding form, kept in the browser so leaving the page
 * does not wipe what the user has typed.
 *
 * This is not a saved draft. Save Draft writes project_drafts through the API.
 * This key is removed after Save Draft or Create WBS succeeds.
 */
const STORAGE_KEY = "trackerpro_onboarding_form_v1";

export interface OnboardingFormSnapshot {
  isRenewal: boolean;
  wbsSearch: string;
  renewalProject: unknown;
  selectedClientId: string;
  clientSearch: string;
  selectedSubVenture: string;
  svSearch: string;
  contractType: string;
  engagementManager: string;
  salesPerson: string;
  projectType: string;
  projectIssuedDate: string;
  billingModel: string;
  paymentTerms: string;
  customPayments: { label: string; pct: number }[];
  currency: string;
  taxPercent: number;
  poStatus: string;
  poNumber: string;
  poDate: string;
  targetDate: string;
  contactName: string;
  contactNumber: string;
  contactEmail: string;
  sectionAComments: string;
  sectionBComments: string;
  selectedServices: Record<string, Record<string, boolean>>;
  serviceRows: unknown[];
  invoiceRows: unknown[];
  currentDraftId: string | null;
  currentRowVersion: number;
}

export function onboardingSnapshotHasContent(snap: OnboardingFormSnapshot | null | undefined): boolean {
  if (!snap) return false;
  return Boolean(
    snap.isRenewal ||
    snap.wbsSearch?.trim() ||
    snap.selectedClientId ||
    snap.clientSearch?.trim() ||
    snap.selectedSubVenture?.trim() ||
    snap.svSearch?.trim() ||
    snap.contractType ||
    snap.engagementManager?.trim() ||
    snap.salesPerson ||
    snap.projectType ||
    snap.billingModel ||
    snap.paymentTerms ||
    snap.poStatus ||
    snap.poNumber?.trim() ||
    snap.poDate ||
    snap.targetDate ||
    snap.contactName?.trim() ||
    snap.contactNumber?.trim() ||
    snap.contactEmail?.trim() ||
    snap.sectionAComments?.trim() ||
    snap.sectionBComments?.trim() ||
    (snap.serviceRows && snap.serviceRows.length > 0) ||
    (snap.invoiceRows && snap.invoiceRows.length > 0) ||
    (snap.selectedServices && Object.keys(snap.selectedServices).length > 0) ||
    snap.currentDraftId,
  );
}

export function readOnboardingFormState(): OnboardingFormSnapshot | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as OnboardingFormSnapshot;
    return onboardingSnapshotHasContent(parsed) ? parsed : null;
  } catch {
    return null;
  }
}

export function writeOnboardingFormState(snap: OnboardingFormSnapshot): void {
  if (typeof window === "undefined") return;
  try {
    if (!onboardingSnapshotHasContent(snap)) {
      window.localStorage.removeItem(STORAGE_KEY);
      return;
    }
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(snap));
  } catch {
    // A full browser store should not block the form.
  }
}

export function clearOnboardingFormState(): void {
  if (typeof window === "undefined") return;
  try {
    window.localStorage.removeItem(STORAGE_KEY);
  } catch {
    // Ignore storage failures.
  }
}
