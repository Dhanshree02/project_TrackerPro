import { describe, expect, it } from "vitest";
import {
  BOND_DELIVERED_OPTIONS,
  WORKER_TYPES,
  computeBondExpiryDate,
  computeBondStatus,
  formatBondExpiryDisplay,
} from "./employment-bond";

describe("employment bond helpers", () => {
  it("returns No bond defaults when bond is not delivered", () => {
    expect(formatBondExpiryDisplay("2026-09-10", "No", "12")).toBe("No");
    expect(computeBondStatus("No", "2026-09-10", "12")).toBe("No bond");
    expect(computeBondExpiryDate("2026-09-10", "No", "12")).toBeNull();
  });

  it("computes expiry from DOJ and duration when bond is delivered", () => {
    expect(computeBondExpiryDate("2026-09-10", "Yes", "12")).toBe("2027-09-10");
    expect(formatBondExpiryDisplay("2026-09-10", "Yes", "12")).toBe("2027-09-10");
    expect(computeBondStatus("Yes", "2026-09-10", "12")).toBe("In bond");
  });
});

describe("employment bond constants", () => {
  it("exposes worker and bond delivered options", () => {
    expect(WORKER_TYPES).toEqual(["Permanent", "Contract", "Intern"]);
    expect(BOND_DELIVERED_OPTIONS).toEqual(["Yes", "No"]);
  });
});
