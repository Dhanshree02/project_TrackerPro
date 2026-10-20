import { describe, expect, it } from "vitest";
import type { ApiEmployeeListItem } from "@/modules/employees/api/employees";
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

  it("uses profile Assigned RBAC before Testing heuristics", () => {
    const salesTm = row({
      employeeCode: "TK-0099",
      fullName: "Sales Person",
      workEmail: "sales@talakunchi.com",
      department: "Functional - Sales",
      designation: "Sales Executive",
      jobRoleName: "Team Member",
      role: "Sales team member",
    });
    expect(mapEmployeeAccessRoleKey(salesTm)).toBe("Sales team member");
  });

  it("maps Excel designation rows before Testing heuristics", () => {
    const socLead = row({
      employeeCode: "TK-0200",
      fullName: "SOC Lead",
      workEmail: "soc.lead@talakunchi.com",
      department: "Services - Operations",
      designation: "SOC Lead - I",
      jobRoleName: "Project Manager",
    });
    expect(mapEmployeeAccessRoleKey(socLead)).toBe("SOC-Manager");
  });

  it("does not treat on-floor Team Member in Role column as RBAC access", () => {
    const misfiled = row({
      employeeCode: "TK-0100",
      fullName: "Test User",
      workEmail: "test@talakunchi.com",
      jobRoleName: "Team Member",
      role: "Team Member",
    });
    expect(mapEmployeeAccessRoleKey(misfiled)).toBe("Testing-Team Member");
  });

  it("assigns different permission sets", () => {
    const adminPersona = employeeListItemToPersona(superAdmin);
    const itPersona = employeeListItemToPersona(itStaff);
    expect(adminPersona.roleKey).toBe("Admin");
    expect(itPersona.roleKey).toBe("IT Admin");
    expect(adminPersona.permissions).toEqual([]);
    expect(itPersona.permissions).toEqual([]);
  });
});
