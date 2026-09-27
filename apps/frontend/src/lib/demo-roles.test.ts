import { describe, expect, it } from "vitest";
import {
  DEMO_PERSONAS,
  getDemoPersona,
  isDemoRoleKey,
  mockAuthUser,
} from "./demo-roles";
import { DEFAULT_ROLE_PERMISSIONS } from "./rbac";

describe("DEMO_PERSONAS catalog", () => {
  it("includes all directory employees plus IT Admin", () => {
    expect(DEMO_PERSONAS.length).toBeGreaterThanOrEqual(59);
  });

  it("strictly separates normal Admin (Full Access) from IT Admin (Restricted)", () => {
    const adminPersona = getDemoPersona("Admin");
    const itAdminPersona = getDemoPersona("IT Admin");

    // Must be completely different users
    expect(adminPersona.email).toBe("admin@acme.co");
    expect(itAdminPersona.email).toBe("itadmin@acme.co");
    expect(adminPersona.name).toBe("Admin User");
    expect(itAdminPersona.name).toBe("IT Admin User");
    expect(adminPersona.roleKey).toBe("Admin");
    expect(itAdminPersona.roleKey).toBe("IT Admin");
    expect(adminPersona.code).toBe("TK-0004");
    expect(itAdminPersona.code).toBe("TK-0004-IT");

    // Admin has super-admin full access (> 50 permissions)
    const adminPerms = DEFAULT_ROLE_PERMISSIONS["Admin"] ?? [];
    expect(adminPerms.length).toBeGreaterThan(50);
    expect(adminPerms).toContain("projects.view");
    expect(adminPerms).toContain("customers.view");
    expect(adminPerms).toContain("reports.sales");

    // IT Admin has restricted access (< 25 permissions)
    const itAdminPerms = DEFAULT_ROLE_PERMISSIONS["IT Admin"] ?? [];
    expect(itAdminPerms.length).toBeLessThan(25);
    expect(itAdminPerms).toContain("resources.view");
    expect(itAdminPerms).toContain("settings.view");
    expect(itAdminPerms).not.toContain("projects.view");
    expect(itAdminPerms).not.toContain("customers.view");
    expect(itAdminPerms).not.toContain("reports.view");
  });

  it("assigns unique keys, codes, and emails to every persona", () => {
    const keys = new Set(DEMO_PERSONAS.map((p) => p.key));
    const codes = new Set(DEMO_PERSONAS.map((p) => p.code));
    const emails = new Set(DEMO_PERSONAS.map((p) => p.email.toLowerCase()));
    expect(keys.size).toBe(DEMO_PERSONAS.length);
    expect(codes.size).toBe(DEMO_PERSONAS.length);
    expect(emails.size).toBe(DEMO_PERSONAS.length);
  });

  it("has valid emails and roles for all personas", () => {
    for (const persona of DEMO_PERSONAS) {
      expect(persona.email).toMatch(/@acme\.co$/);
      expect(persona.roleKey).toBeTruthy();
      expect(persona.name).toBeTruthy();
      expect(persona.avatar).toBeTruthy();
      expect(persona.category).toBeTruthy();
    }
  });

  it("finds persona by employee code (e.g. TK-0046 Arjun Singh)", () => {
    const arjun = getDemoPersona("TK-0046");
    expect(arjun.name).toBe("Arjun Singh");
    expect(arjun.email).toBe("arjun@acme.co");
    expect(arjun.roleKey).toBe("Testing-Team Member");
  });

  it("finds persona by role (e.g. CEO or Admin vs IT Admin)", () => {
    const ceo = getDemoPersona("CEO");
    expect(ceo.name).toBe("Vikrant Malhotra");
    expect(ceo.roleKey).toBe("CEO");

    const admin = getDemoPersona("Admin");
    expect(admin.name).toBe("Admin User");
    expect(admin.roleKey).toBe("Admin");

    const itAdmin = getDemoPersona("IT Admin");
    expect(itAdmin.name).toBe("IT Admin User");
    expect(itAdmin.roleKey).toBe("IT Admin");
  });

  it("finds persona by email (case-insensitive)", () => {
    const divya = getDemoPersona("DIVYA.RAO@ACME.CO");
    expect(divya.name).toBe("Divya Rao");
    expect(divya.code).toBe("TK-0040");
    expect(divya.roleKey).toBe("Testing-Manager");

    const itAdmin = getDemoPersona("itadmin@acme.co");
    expect(itAdmin.name).toBe("IT Admin User");
    expect(itAdmin.roleKey).toBe("IT Admin");

    const admin = getDemoPersona("admin@acme.co");
    expect(admin.name).toBe("Admin User");
    expect(admin.roleKey).toBe("Admin");
  });

  it("verifies isDemoRoleKey correctly identifies codes, emails, and roles", () => {
    expect(isDemoRoleKey("TK-0001")).toBe(true);
    expect(isDemoRoleKey("TK-0004-IT")).toBe(true);
    expect(isDemoRoleKey("TKI-0010")).toBe(true);
    expect(isDemoRoleKey("CEO")).toBe(true);
    expect(isDemoRoleKey("Admin")).toBe(true);
    expect(isDemoRoleKey("IT Admin")).toBe(true);
    expect(isDemoRoleKey("admin@acme.co")).toBe(true);
    expect(isDemoRoleKey("itadmin@acme.co")).toBe(true);
    expect(isDemoRoleKey("non-existent-user")).toBe(false);
  });

  it("mockAuthUser produces a valid AuthUser with correct permissions", () => {
    const adminUser = mockAuthUser("Admin");
    expect(adminUser.name).toBe("Admin User");
    expect(adminUser.role).toBe("Admin");
    expect(adminUser.permissions.length).toBeGreaterThan(50);

    const itAdminUser = mockAuthUser("IT Admin");
    expect(itAdminUser.name).toBe("IT Admin User");
    expect(itAdminUser.role).toBe("IT Admin");
    expect(itAdminUser.permissions.length).toBeLessThan(25);
  });
});
