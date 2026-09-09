import { describe, expect, it } from "vitest";
import {
  buildOnboardingProjectName,
  countProjectsForClient,
  formatClientProjectCount,
  resolveOnboardingProjectName,
  uniqueServiceNames,
} from "./onboarding-project-name";

describe("formatClientProjectCount", () => {
  it("pads the next count to two digits", () => {
    expect(formatClientProjectCount(0)).toBe("01");
    expect(formatClientProjectCount(1)).toBe("02");
    expect(formatClientProjectCount(9)).toBe("10");
    expect(formatClientProjectCount(99)).toBe("100");
  });
});

describe("uniqueServiceNames", () => {
  it("drops blanks and keeps first-seen casing", () => {
    expect(uniqueServiceNames([" Infra PT ", "", "AppSec PT", "infra pt"])).toEqual([
      "Infra PT",
      "AppSec PT",
    ]);
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
  it("uses the service name when only one service is selected", () => {
    expect(
      buildOnboardingProjectName({
        clientName: "Kotak",
        subVentureName: "Kotak Securities",
        serviceNames: ["Infra PT"],
        existingClientProjectCount: 0,
      }),
    ).toBe("Kotak(Kotak Securities)_Infra PT_01");
  });

  it("uses Mixed when more than one service is selected", () => {
    expect(
      buildOnboardingProjectName({
        clientName: "Kotak",
        subVentureName: "Kotak Securities",
        serviceNames: ["Infra PT", "AppSec PT", "Cloud Security"],
        existingClientProjectCount: 1,
      }),
    ).toBe("Kotak(Kotak Securities)_Mixed_02");
  });

  it("keeps a hyphenated sub-venture name as-is", () => {
    expect(
      buildOnboardingProjectName({
        clientName: "Kotak",
        subVentureName: "Kotak Securities-Neo",
        serviceNames: ["Infra PT", "AppSec PT"],
        existingClientProjectCount: 2,
      }),
    ).toBe("Kotak(Kotak Securities-Neo)_Mixed_03");

    expect(
      buildOnboardingProjectName({
        clientName: "Kotak",
        subVentureName: "Kotak Securities-Neo",
        serviceNames: ["Infra PT"],
        existingClientProjectCount: 3,
      }),
    ).toBe("Kotak(Kotak Securities-Neo)_Infra PT_04");
  });

  it("continues the client count across later projects", () => {
    expect(
      buildOnboardingProjectName({
        clientName: "Kotak",
        subVentureName: "Kotak Securities",
        serviceNames: ["AppSec PT"],
        existingClientProjectCount: 1,
      }),
    ).toBe("Kotak(Kotak Securities)_AppSec PT_02");
  });

  it("stays empty until client, sub-venture, and a service are all present", () => {
    const base = {
      clientName: "Kotak",
      subVentureName: "Kotak Securities",
      serviceNames: ["Infra PT"],
      existingClientProjectCount: 0,
    };
    expect(buildOnboardingProjectName({ ...base, clientName: "" })).toBe("");
    expect(buildOnboardingProjectName({ ...base, subVentureName: "  " })).toBe("");
    expect(buildOnboardingProjectName({ ...base, serviceNames: [] })).toBe("");
  });
});

describe("resolveOnboardingProjectName", () => {
  const generatedArgs = {
    clientName: "Kotak",
    subVentureName: "Kotak Securities",
    serviceNames: ["AppSec PT"],
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
    ).not.toBe("Kotak(Kotak Securities)_AppSec PT_02");
  });

  it("uses the generated name for a normal new project", () => {
    expect(
      resolveOnboardingProjectName({
        ...generatedArgs,
        isRenewal: false,
        previousProjectName: "Kotak(Kotak Securities)_Infra PT_01",
      }),
    ).toBe("Kotak(Kotak Securities)_AppSec PT_02");
  });
});
