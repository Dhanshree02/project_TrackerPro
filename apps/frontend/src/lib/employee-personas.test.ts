import { describe, expect, it } from "vitest";
import type { ApiEmployeeListItem } from "@/lib/api/employees";
import { DEFAULT_ROLE_PERMISSIONS } from "@/lib/rbac";
import {
  employeeListItemToPersona,
  isItAdminProfile,
  isSuperAdminEmployee,
  mapEmployeeAccessRoleKey,
} from "./employee-personas";

function row(partial: Partial<ApiEmployeeListItem> & Pick<ApiEmployeeListItem, "employeeCode" | "fullName" | "workEmail">): ApiEmployeeListItem {
  return {
    id: "00000000-0000-4000-8000-000000000099",
    createdAtUtc: "2026-01-01T00:00:00Z",
    ...partial,
  };
}

describe("Super Admin vs IT Admin", () => {
  const superAdmin = row({
    employeeCode: "TK-0004",
    fullName: "Admin User",
    workEmail: "admin@talakunchi.com",
    department: "Functional - IT Administration",
    designation: "IT Admin",
    jobRoleName: "IT Admin",
  });

  const itStaff = row({
    employeeCode: "TK-0018",
    fullName: "Harsh Pandey",
    workEmail: "harsh.pandey.tk-0018@talakunchi.com",
    department: "Functional - IT Administration",
    designation: "IT Admin",
    jobRoleName: "IT Admin",
  });

  it("identifies super admin by code and email", () => {
    expect(isSuperAdminEmployee(superAdmin)).toBe(true);
    expect(isItAdminProfile(superAdmin)).toBe(false);
  });

  it("identifies IT Admin staff separately from super admin", () => {
    expect(isItAdminProfile(itStaff)).toBe(true);
    expect(isSuperAdminEmployee(itStaff)).toBe(false);
  });

  it("maps TK-0004 to Admin full access and IT staff to IT Admin", () => {
    expect(mapEmployeeAccessRoleKey(superAdmin)).toBe("Admin");
    expect(mapEmployeeAccessRoleKey(itStaff)).toBe("IT Admin");
  });

  it("prefers User Role Access from database when present", () => {
    expect(mapEmployeeAccessRoleKey(itStaff, "Testing-Team Member")).toBe("Testing-Team Member");
  });

  it("assigns different permission sets", () => {
    const adminPersona = employeeListItemToPersona(superAdmin);
    const itPersona = employeeListItemToPersona(itStaff);
    expect(adminPersona.roleKey).toBe("Admin");
    expect(itPersona.roleKey).toBe("IT Admin");
    expect(adminPersona.permissions.length).toBeGreaterThan(50);
    expect(itPersona.permissions.length).toBeLessThan(25);
    expect(DEFAULT_ROLE_PERMISSIONS.Admin).toContain("customers.view");
    expect(DEFAULT_ROLE_PERMISSIONS["IT Admin"]).not.toContain("customers.view");
  });
});
