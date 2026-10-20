import { describe, expect, it } from "vitest";
import {
  formatOnFloorRoleDisplay,
  isOnFloorProjectManager,
  matchesOnFloorRole,
  normalizeOnFloorRole,
  ON_FLOOR_MANAGER,
  ON_FLOOR_PROJECT_MANAGER,
} from "./on-floor-role";

describe("on-floor-role", () => {
  it("strips parenthetical abbreviations for display", () => {
    expect(formatOnFloorRoleDisplay("Leader (L)")).toBe("Leader");
    expect(formatOnFloorRoleDisplay("Team Leader (TL)")).toBe("Team Leader");
    expect(formatOnFloorRoleDisplay("Manager (Mng.)")).toBe("Manager");
    expect(formatOnFloorRoleDisplay("Sr. Manager (Sr.Mng.)")).toBe("Sr. Manager");
    expect(formatOnFloorRoleDisplay("Head Of Department (HOD)")).toBe("Head Of Department");
  });

  it("matches legacy and clean names", () => {
    expect(
      matchesOnFloorRole({ jobRoleName: "Manager (Mng.)" }, ON_FLOOR_MANAGER),
    ).toBe(true);
    expect(matchesOnFloorRole({ jobRoleName: "Manager" }, ON_FLOOR_MANAGER)).toBe(true);
    expect(normalizeOnFloorRole("Leader (L)")).toBe("leader");
  });

  it("treats Manager and Project Manager as assignable PMs", () => {
    expect(isOnFloorProjectManager({ jobRoleName: ON_FLOOR_MANAGER })).toBe(true);
    expect(isOnFloorProjectManager({ jobRoleName: ON_FLOOR_PROJECT_MANAGER })).toBe(true);
    expect(isOnFloorProjectManager({ jobRoleName: "Team Member" })).toBe(false);
  });
});
