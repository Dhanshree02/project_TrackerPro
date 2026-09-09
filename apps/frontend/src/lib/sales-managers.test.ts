import { describe, expect, it } from "vitest";
import { isFunctionalSalesDepartment } from "./sales-managers";

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
