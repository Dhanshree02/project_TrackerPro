import { describe, expect, it } from "vitest";
import {
  buildOnboardingProjectName,
  countProjectsForClient,
  formatClientProjectCount,
  projectNameDescriptor,
  resolveOnboardingProjectName,
  uniqueTrimmedNames,
} from "./onboarding-project-name";

describe("formatClientProjectCount", () => {
  it("pads the next count to two digits", () => {
    expect(formatClientProjectCount(0)).toBe("01");
    expect(formatClientProjectCount(1)).toBe("02");
    expect(formatClientProjectCount(9)).toBe("10");
    expect(formatClientProjectCount(99)).toBe("100");
  });
});

describe("uniqueTrimmedNames", () => {
  it("drops blanks and keeps first-seen casing", () => {
    expect(
      uniqueTrimmedNames([" Network Penetration Testing ", "", "Web Application Security", "network penetration testing"]),
    ).toEqual(["Network Penetration Testing", "Web Application Security"]);
  });
});

describe("projectNameDescriptor", () => {
  it("uses the sub-department when one service is selected", () => {
    expect(projectNameDescriptor(["Network Penetration Testing"])).toBe(
      "Network Penetration Testing",
    );
  });

  it("uses the shared sub-department when every service has the same one", () => {
    expect(
      projectNameDescriptor([
        "Network Penetration Testing",
        "Network Penetration Testing",
        "Network Penetration Testing",
      ]),
    ).toBe("Network Penetration Testing");
  });

  it("uses Mixed when selected services have different sub-departments", () => {
    expect(
      projectNameDescriptor([
        "Network Penetration Testing",
        "Web Application Security",
        "Mobile Application Security",
      ]),
    ).toBe("Mixed");
  });

  it("uses Mixed even when those sub-departments share a department", () => {
    expect(
      projectNameDescriptor(["Network Penetration Testing", "API Penetration Testing"]),
    ).toBe("Mixed");
  });
});

describe("countProjectsForClient", () => {
  it("counts every project for that client, across sub-ventures", () => {
    const projects = [
      { clientId: "kotak" },
      { clientId: "kotak" },
      { clientId: "other" },
    ];
    expect(countProjectsForClient(projects, "kotak")).toBe(2);
    expect(countProjectsForClient(projects, " missing ")).toBe(0);
    expect(countProjectsForClient(projects, "")).toBe(0);
  });
});

describe("buildOnboardingProjectName", () => {
  it("uses the sub-department when only one service is selected", () => {
    expect(
      buildOnboardingProjectName({
        clientName: "Kotak",
        subVentureName: "Kotak Securities",
        subDepartmentNames: ["Network Penetration Testing"],
        existingClientProjectCount: 0,
      }),
    ).toBe("Kotak(Kotak Securities)_Network Penetration Testing_01");
  });

  it("does not use the service name or the department name", () => {
    const name = buildOnboardingProjectName({
      clientName: "Kotak",
      subVentureName: "Kotak Securities",
      subDepartmentNames: ["Network Penetration Testing"],
      existingClientProjectCount: 0,
    });
    expect(name).not.toContain("External Network Penetration Testing");
    expect(name).not.toBe("Kotak(Kotak Securities)_Penetration Testing_01");
  });

  it("uses the same sub-department when multiple services share it", () => {
    expect(
      buildOnboardingProjectName({
        clientName: "Kotak",
        subVentureName: "Kotak Securities",
        subDepartmentNames: [
          "Network Penetration Testing",
          "Network Penetration Testing",
        ],
        existingClientProjectCount: 1,
      }),
    ).toBe("Kotak(Kotak Securities)_Network Penetration Testing_02");
  });

  it("uses Mixed when selected services belong to different sub-departments", () => {
    expect(
      buildOnboardingProjectName({
        clientName: "Kotak",
        subVentureName: "Kotak Securities",
        subDepartmentNames: ["Network Penetration Testing", "Web Application Security"],
        existingClientProjectCount: 2,
      }),
    ).toBe("Kotak(Kotak Securities)_Mixed_03");
  });

  it("uses Mixed when services come from different departments", () => {
    expect(
      buildOnboardingProjectName({
        clientName: "Kotak",
        subVentureName: "Kotak Securities",
        subDepartmentNames: ["Network Penetration Testing", "Network Vulnerability Assessment"],
        existingClientProjectCount: 3,
      }),
    ).toBe("Kotak(Kotak Securities)_Mixed_04");
  });

  it("keeps a hyphenated sub-venture name as-is", () => {
    expect(
      buildOnboardingProjectName({
        clientName: "Kotak",
        subVentureName: "Kotak Securities-Neo",
        subDepartmentNames: ["Network Penetration Testing", "Web Application Security"],
        existingClientProjectCount: 2,
      }),
    ).toBe("Kotak(Kotak Securities-Neo)_Mixed_03");

    expect(
      buildOnboardingProjectName({
        clientName: "Kotak",
        subVentureName: "Kotak Securities-Neo",
        subDepartmentNames: ["Network Penetration Testing"],
        existingClientProjectCount: 3,
      }),
    ).toBe("Kotak(Kotak Securities-Neo)_Network Penetration Testing_04");
  });

  it("continues the client count across later projects", () => {
    expect(
      buildOnboardingProjectName({
        clientName: "Kotak",
        subVentureName: "Kotak Securities",
        subDepartmentNames: ["Web Application Penetration Testing"],
        existingClientProjectCount: 1,
      }),
    ).toBe("Kotak(Kotak Securities)_Web Application Penetration Testing_02");
  });

  it("stays empty until client, sub-venture, and a sub-department are all present", () => {
    const base = {
      clientName: "Kotak",
      subVentureName: "Kotak Securities",
      subDepartmentNames: ["Network Penetration Testing"],
      existingClientProjectCount: 0,
    };
    expect(buildOnboardingProjectName({ ...base, clientName: "" })).toBe("");
    expect(buildOnboardingProjectName({ ...base, subVentureName: "  " })).toBe("");
    expect(buildOnboardingProjectName({ ...base, subDepartmentNames: [] })).toBe("");
    expect(buildOnboardingProjectName({ ...base, subDepartmentNames: ["  "] })).toBe("");
  });
});

describe("resolveOnboardingProjectName", () => {
  const generatedArgs = {
    clientName: "Kotak",
    subVentureName: "Kotak Securities",
    subDepartmentNames: ["Web Application Penetration Testing"],
    existingClientProjectCount: 1,
  };

  it("keeps the previous name exactly on renewal", () => {
    expect(
      resolveOnboardingProjectName({
        ...generatedArgs,
        isRenewal: true,
        previousProjectName: "Kotak(Kotak Securities)_Infra PT_01",
      }),
    ).toBe("Kotak(Kotak Securities)_Infra PT_01");
  });

  it("does not append a copy suffix or rebuild the name on renewal", () => {
    expect(
      resolveOnboardingProjectName({
        ...generatedArgs,
        isRenewal: true,
        previousProjectName: "Kotak(Kotak Securities)_Infra PT_01",
      }),
    ).not.toContain("(1)");
    expect(
      resolveOnboardingProjectName({
        ...generatedArgs,
        isRenewal: true,
        previousProjectName: "Kotak(Kotak Securities)_Infra PT_01",
      }),
    ).not.toBe("Kotak(Kotak Securities)_Web Application Penetration Testing_02");
  });

  it("uses the generated name for a normal new project", () => {
    expect(
      resolveOnboardingProjectName({
        ...generatedArgs,
        isRenewal: false,
        previousProjectName: "Kotak(Kotak Securities)_Infra PT_01",
      }),
    ).toBe("Kotak(Kotak Securities)_Web Application Penetration Testing_02");
  });
});
