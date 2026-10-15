import { describe, expect, it } from "vitest";
import { composeWbsId } from "./wbs-id";

describe("composeWbsId", () => {
  it("places the financial year, sub-venture id, and project id between slashes", () => {
    expect(composeWbsId("2026-27", "C013-01", "P056")).toBe("IN-2026-27/C013-01/P056");
  });

  it("keeps each sub-venture id distinct under the same client", () => {
    expect(composeWbsId("2026-27", "C013-01", "P056")).toContain("/C013-01/");
    expect(composeWbsId("2026-27", "C013-03", "P057")).toContain("/C013-03/");
  });

  it("changes only the financial year when that component changes", () => {
    const first = composeWbsId("2026-27", "C019-01", "P056");
    const nextYear = composeWbsId("2027-28", "C019-01", "P056");
    expect(first).toBe("IN-2026-27/C019-01/P056");
    expect(nextYear).toBe("IN-2027-28/C019-01/P056");
  });
});
