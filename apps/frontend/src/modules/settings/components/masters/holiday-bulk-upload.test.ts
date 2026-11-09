import { describe, it, expect } from "vitest";
import * as XLSX from "xlsx";
import {
  normalizeDateString,
  formatDateDisplay,
} from "./holiday-bulk-upload-dialog";

describe("Holiday Bulk Upload Utilities", () => {
  describe("normalizeDateString", () => {
    it("handles standard ISO YYYY-MM-DD", () => {
      expect(normalizeDateString("2026-01-26")).toBe("2026-01-26");
      expect(normalizeDateString("2026-12-25")).toBe("2026-12-25");
      expect(normalizeDateString("2026-08-15")).toBe("2026-08-15");
    });

    it("handles slashed ISO YYYY/MM/DD", () => {
      expect(normalizeDateString("2026/01/26")).toBe("2026-01-26");
    });

    it("handles DD-MM-YYYY format", () => {
      expect(normalizeDateString("26-01-2026")).toBe("2026-01-26");
      expect(normalizeDateString("15-08-2026")).toBe("2026-08-15");
    });

    it("handles DD/MM/YYYY format", () => {
      expect(normalizeDateString("26/01/2026")).toBe("2026-01-26");
      expect(normalizeDateString("02/10/2026")).toBe("2026-10-02");
    });

    it("handles JavaScript Date objects", () => {
      const d = new Date(2026, 0, 26); // Jan 26, 2026
      expect(normalizeDateString(d)).toBe("2026-01-26");
    });

    it("handles Excel numeric serial dates", () => {
      // 46048 is approx 2026-01-26 in Excel serial epoch
      const parsed = normalizeDateString(46048);
      expect(parsed).toMatch(/^2026-/);
    });

    it("returns null for empty, null, undefined or unparseable inputs", () => {
      expect(normalizeDateString(null)).toBeNull();
      expect(normalizeDateString(undefined)).toBeNull();
      expect(normalizeDateString("")).toBeNull();
      expect(normalizeDateString("    ")).toBeNull();
      expect(normalizeDateString("invalid-date-string")).toBeNull();
    });
  });

  describe("formatDateDisplay", () => {
    it("formats ISO date string into readable label with weekday", () => {
      const formatted = formatDateDisplay("2026-01-26");
      expect(formatted).toContain("Jan");
      expect(formatted).toContain("26");
      expect(formatted).toContain("2026");
    });
  });

  describe("Excel Workbook roundtrip with sample columns", () => {
    it("parses Date and Holiday Name headers from generated worksheet", () => {
      const rows = [
        { Date: "2026-01-26", "Holiday Name": "Republic Day" },
        { Date: "2026-08-15", "Holiday Name": "Independence Day" },
      ];

      const ws = XLSX.utils.json_to_sheet(rows);
      const wb = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(wb, ws, "Holidays");

      const buffer = XLSX.write(wb, { bookType: "xlsx", type: "array" });
      const readWb = XLSX.read(buffer, { type: "array" });
      const sheetName = readWb.SheetNames[0];
      expect(sheetName).toBe("Holidays");

      const parsedJson = XLSX.utils.sheet_to_json<Record<string, unknown>>(readWb.Sheets[sheetName]);
      expect(parsedJson).toHaveLength(2);
      expect(parsedJson[0]["Date"]).toBe("2026-01-26");
      expect(parsedJson[0]["Holiday Name"]).toBe("Republic Day");
      expect(parsedJson[1]["Date"]).toBe("2026-08-15");
      expect(parsedJson[1]["Holiday Name"]).toBe("Independence Day");
    });
  });
});

