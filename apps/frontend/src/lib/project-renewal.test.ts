import { describe, expect, it } from "vitest";
import { findProjectByWbsId, isRenewedProject } from "./project-renewal";

describe("isRenewedProject", () => {
  it("is true when a previous WBS ID or project ID is stored or renewal flag is set", () => {
    expect(isRenewedProject({ renewedFromWbsId: "IN-2026-27-C002-P004" })).toBe(true);
    expect(isRenewedProject({ renewedFromProjectId: "proj-123" })).toBe(true);
    expect(isRenewedProject({ isRenewal: true })).toBe(true);
    expect(isRenewedProject({ renewed: true })).toBe(true);
    expect(isRenewedProject({ renewedFromWbsId: "  " })).toBe(false);
    expect(isRenewedProject({})).toBe(false);
    expect(isRenewedProject(null)).toBe(false);
  });
});

describe("findProjectByWbsId", () => {
  const projects = [
    { id: "p1", wbsId: "IN-2026-27-C002-P004" },
    { id: "p2", wbsId: "IN-2026-27-C002-P005" },
  ];

  it("returns the matching project", () => {
    expect(findProjectByWbsId(projects, "IN-2026-27-C002-P004")?.id).toBe("p1");
    expect(findProjectByWbsId(projects, " in-2026-27-c002-p005 ")?.id).toBe("p2");
  });

  it("returns undefined when missing or blank", () => {
    expect(findProjectByWbsId(projects, "IN-1999-00-C000-P000")).toBeUndefined();
    expect(findProjectByWbsId(projects, "")).toBeUndefined();
    expect(findProjectByWbsId(projects, null)).toBeUndefined();
  });
});
