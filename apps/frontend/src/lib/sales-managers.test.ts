import { describe, expect, it } from "vitest";
import { isFunctionalSalesDepartment, isSalesManagerDesignation } from "./sales-managers";

describe("isSalesManagerDesignation", () => {
  it("matches the 2 designated Sales Manager designations", () => {
    expect(isSalesManagerDesignation("Business Development Associate - I")).toBe(true);
    expect(isSalesManagerDesignation("Customer Success Representative - II")).toBe(true);
    expect(isSalesManagerDesignation("business development associate - i")).toBe(true);
    expect(isSalesManagerDesignation("customer success representative - ii")).toBe(true);
    expect(isSalesManagerDesignation("  Business Development Associate - I  ")).toBe(true);
  });

  it("rejects other designations", () => {
    expect(isSalesManagerDesignation("Sales Manager")).toBe(false);
    expect(isSalesManagerDesignation("Delivery Account Manager - I")).toBe(false);
    expect(isSalesManagerDesignation("Associate Customer Success Representative - II")).toBe(false);
    expect(isSalesManagerDesignation("")).toBe(false);
    expect(isSalesManagerDesignation(null)).toBe(false);
  });
});

describe("isFunctionalSalesDepartment", () => {
  it("matches the live catalog name and code", () => {
    expect(isFunctionalSalesDepartment("Functional - Sales")).toBe(true);
    expect(isFunctionalSalesDepartment("functional - sales")).toBe(true);
    expect(isFunctionalSalesDepartment("  Functional  -  Sales  ")).toBe(true);
    expect(isFunctionalSalesDepartment("functional_sales")).toBe(true);
  });

  it("rejects other departments", () => {
    expect(isFunctionalSalesDepartment("Functional - HR")).toBe(false);
    expect(isFunctionalSalesDepartment("Sales")).toBe(false);
    expect(isFunctionalSalesDepartment("")).toBe(false);
    expect(isFunctionalSalesDepartment(null)).toBe(false);
  });
});

