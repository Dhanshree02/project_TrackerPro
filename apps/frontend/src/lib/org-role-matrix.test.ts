import { describe, expect, it } from "vitest";
import { findOrgRoleRow, ON_FLOOR_ROLES, rbacKeyFromExcel } from "./org-role-matrix";

describe("org-role-matrix", () => {
  it("keeps the Excel on-floor catalog at 10 unique names", () => {
    expect(ON_FLOOR_ROLES).toEqual([
      "Leader",
      "IT Admin",
      "Accounts",
      "HR",
      "Manager",
      "Team Member",
      "Team Leader",
      "Project Manager",
      "Sr. Manager",
      "Head Of Department",
    ]);
  });

  it("maps designation + department to Excel on-floor and RBAC keys", () => {
    expect(findOrgRoleRow("Functional - Sales", "Sales Associate")).toMatchObject({
      onFloorRole: "Team Member",
      rbacRole: "Sales team member",
    });
    expect(findOrgRoleRow("Services - Operations", "SOC Lead - I")).toMatchObject({
      onFloorRole: "Project Manager",
      rbacRole: "SOC-Manager",
    });
    expect(findOrgRoleRow("Services - Consulting", "Associate Manager - III")).toMatchObject({
      onFloorRole: "Manager",
      rbacRole: "Consulting-Manager",
    });
    expect(findOrgRoleRow("Services - Testing", "Associate Manager - III")).toMatchObject({
      onFloorRole: "Team Leader",
      rbacRole: "Testing-Team Leader",
    });
  });

  it("maps Intern from the department row in the spreadsheet", () => {
    expect(findOrgRoleRow("Functional - Accounts", "Intern")).toMatchObject({
      onFloorRole: "Team Member",
      rbacRole: "Accounts",
      subDepartment: "Functional - Accounts",
    });
    expect(findOrgRoleRow("Functional - Project Management", "Intern")).toMatchObject({
      onFloorRole: "Team Member",
      rbacRole: "PM - Team Member",
    });
    expect(findOrgRoleRow("Core", "Intern")).toBeUndefined();
  });

  it("normalizes Excel RBAC labels to existing auth.tbl_roles names", () => {
    expect(rbacKeyFromExcel("PMO (Project Management Office)")).toBe("PMO");
    expect(rbacKeyFromExcel("EM (Engagement Manager)")).toBe("EngagementManager");
    expect(rbacKeyFromExcel("SOC- Manager")).toBe("SOC-Manager");
    expect(rbacKeyFromExcel("Sales Team Member")).toBe("Sales team member");
  });
});
