import { describe, it, expect } from "vitest";
import { deriveProjectDates, formatDateDMY } from "./project-dates";

describe("deriveProjectDates", () => {
  it("selects earliest start date and latest end date from multiple services", () => {
    const services = [
      { startDate: "2026-05-01", endDate: "2026-06-15" },
      { startDate: "2026-04-10", endDate: "2026-05-20" },
      { startDate: "2026-06-01", endDate: "2026-08-31" },
      { startDate: "2026-05-15", endDate: "2026-07-30" },
    ];

    const { startDate, endDate } = deriveProjectDates(services);
    expect(startDate).toBe("2026-04-10");
    expect(endDate).toBe("2026-08-31");
  });

  it("handles single service correctly", () => {
    const services = [{ startDate: "2026-06-01", endDate: "2026-09-30" }];
    const { startDate, endDate } = deriveProjectDates(services);
    expect(startDate).toBe("2026-06-01");
    expect(endDate).toBe("2026-09-30");
  });

  it("ignores empty or invalid dates in services", () => {
    const services = [
      { startDate: "", endDate: "" },
      { startDate: "2026-07-01", endDate: "2026-09-15" },
      { startDate: "2026-06-10", endDate: null },
    ];
    const { startDate, endDate } = deriveProjectDates(services);
    expect(startDate).toBe("2026-06-10");
    expect(endDate).toBe("2026-09-15");
  });

  it("falls back to project dates when services list is empty", () => {
    const { startDate, endDate } = deriveProjectDates([], "2026-04-01", "2026-10-31");
    expect(startDate).toBe("2026-04-01");
    expect(endDate).toBe("2026-10-31");
  });
});

describe("formatDateDMY", () => {
  it("formats YYYY-MM-DD string into DD/MM/YYYY", () => {
    expect(formatDateDMY("2026-04-10")).toBe("10/04/2026");
    expect(formatDateDMY("2026-08-31")).toBe("31/08/2026");
    expect(formatDateDMY("2026-01-05")).toBe("05/01/2026");
    expect(formatDateDMY("2026-12-25")).toBe("25/12/2026");
  });

  it("formats Date object into DD/MM/YYYY", () => {
    const d = new Date(2026, 3, 10);
    expect(formatDateDMY(d)).toBe("10/04/2026");
  });

  it("handles null and empty values gracefully", () => {
    expect(formatDateDMY(null)).toBe("—");
    expect(formatDateDMY(undefined)).toBe("—");
    expect(formatDateDMY("")).toBe("—");
  });
});

