import { afterEach, beforeEach, describe, expect, it } from "vitest";
import {
  clearOnboardingFormState,
  onboardingSnapshotHasContent,
  readOnboardingFormState,
  writeOnboardingFormState,
  type OnboardingFormSnapshot,
} from "./onboarding-form-state";

const memory = new Map<string, string>();

beforeEach(() => {
  memory.clear();
  Object.defineProperty(globalThis, "window", {
    configurable: true,
    value: {
      localStorage: {
        getItem: (key: string) => memory.get(key) ?? null,
        setItem: (key: string, value: string) => {
          memory.set(key, value);
        },
        removeItem: (key: string) => {
          memory.delete(key);
        },
      },
    },
  });
});

function snapshot(overrides: Partial<OnboardingFormSnapshot> = {}): OnboardingFormSnapshot {
  return {
    isRenewal: false,
    wbsSearch: "",
    renewalProject: null,
    selectedClientId: "",
    clientSearch: "",
    selectedSubVenture: "",
    svSearch: "",
    contractType: "",
    engagementManager: "",
    salesPerson: "",
    projectType: "",
    projectIssuedDate: "2026-09-29",
    billingModel: "",
    paymentTerms: "",
    customPayments: [],
    currency: "INR",
    taxPercent: 18,
    poStatus: "",
    poNumber: "",
    poDate: "",
    targetDate: "",
    contactName: "",
    contactNumber: "",
    contactEmail: "",
    sectionAComments: "",
    sectionBComments: "",
    selectedServices: {},
    serviceRows: [],
    invoiceRows: [],
    currentDraftId: null,
    currentRowVersion: 0,
    ...overrides,
  };
}

describe("onboarding form browser state", () => {
  afterEach(() => {
    clearOnboardingFormState();
  });

  it("keeps an unfinished form and reads it back", () => {
    const saved = snapshot({
      clientSearch: "Kotak",
      selectedSubVenture: "Kotak Securities",
      projectType: "Long Term",
      serviceRows: [{ name: "Service A" }, { name: "Service B" }],
      billingModel: "Quarterly Arrears",
    });

    writeOnboardingFormState(saved);

    expect(readOnboardingFormState()).toMatchObject({
      clientSearch: "Kotak",
      selectedSubVenture: "Kotak Securities",
      projectType: "Long Term",
      billingModel: "Quarterly Arrears",
    });
    expect(readOnboardingFormState()?.serviceRows).toHaveLength(2);
  });

  it("does not keep an empty form", () => {
    writeOnboardingFormState(snapshot());
    expect(readOnboardingFormState()).toBeNull();
    expect(onboardingSnapshotHasContent(snapshot())).toBe(false);
  });

  it("clears after a successful save", () => {
    writeOnboardingFormState(snapshot({ engagementManager: "Pradeep Singh", isRenewal: true, wbsSearch: "IN-2026-27-C009-P046" }));
    clearOnboardingFormState();
    expect(readOnboardingFormState()).toBeNull();
  });
});
