import { describe, expect, it } from "vitest";
import { formatSubDepartmentDisplay, normalizeSubDepartmentKey } from "./sub-department";

describe("sub-department", () => {
  it("replaces Dept. with Department", () => {
    expect(formatSubDepartmentDisplay("Leading Delivery Dept.")).toBe("Leading Delivery Department");
    expect(formatSubDepartmentDisplay("Leading Sales & A/C Dept.")).toBe(
      "Leading Sales & A/C Department",
    );
  });

  it("normalizes legacy and new labels for filters", () => {
    expect(normalizeSubDepartmentKey("Leading Delivery Dept.")).toBe(
      normalizeSubDepartmentKey("Leading Delivery Department"),
    );
  });
});
