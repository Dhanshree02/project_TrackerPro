// ─── My Team — Schedule Entries ──────────────────────────────────────────────
// Seed attendance / schedule data for Jun–Sep 2026.
//
// Member IDs correspond to existing Person.id values in @/lib/mock-data:
//   u1 → Aarav Mehta   u2 → Riya Kapoor   u3 → Vikram Shah
//   u4 → Sana Iyer     u5 → Nikhil Rao
//
// Future: replace this file with an API call to
//         GET /my-team/schedule?month=YYYY-MM when the backend is ready.

import type { ScheduleEntry } from "@/modules/my-team/types";

export const seedScheduleEntries: ScheduleEntry[] = [
  // ── June 2026 — u1 (Aarav Mehta) ────────────────────────────────────────────
  { memberId: "u1", date: "2026-06-01", type: "wfh" },
  { memberId: "u1", date: "2026-06-05", type: "wfh", sequenceId: "u1-jun-05-07" },
  { memberId: "u1", date: "2026-06-10", type: "wfh", sequenceId: "u1-jun-10-11" },
  { memberId: "u1", date: "2026-06-11", type: "wfh", sequenceId: "u1-jun-10-11" },
  { memberId: "u1", date: "2026-06-15", type: "holiday" },
  { memberId: "u1", date: "2026-06-18", type: "wfh", sequenceId: "u1-jun-18-22" },
  { memberId: "u1", date: "2026-06-19", type: "onDuty", sequenceId: "u1-jun-18-22" },
  { memberId: "u1", date: "2026-06-22", type: "wfh", sequenceId: "u1-jun-18-22" },
  { memberId: "u1", date: "2026-06-24", type: "wfh", sequenceId: "u1-jun-24-28" },
  { memberId: "u1", date: "2026-06-25", type: "paidLeave", sequenceId: "u1-jun-24-28" },
  { memberId: "u1", date: "2026-06-26", type: "paidLeave", sequenceId: "u1-jun-24-28" },

  // ── June 2026 — u2 (Riya Kapoor) ─────────────────────────────────────────────
  { memberId: "u2", date: "2026-06-02", type: "wfh", sequenceId: "u2-jun-02-03" },
  { memberId: "u2", date: "2026-06-03", type: "wfh", sequenceId: "u2-jun-02-03" },
  { memberId: "u2", date: "2026-06-08", type: "paidLeave", sequenceId: "u2-jun-08-09" },
  { memberId: "u2", date: "2026-06-09", type: "paidLeave", sequenceId: "u2-jun-08-09" },
  { memberId: "u2", date: "2026-06-12", type: "onDuty" },
  { memberId: "u2", date: "2026-06-15", type: "holiday" },
  { memberId: "u2", date: "2026-06-19", type: "unpaidLeave", sequenceId: "u2-jun-19-22" },
  { memberId: "u2", date: "2026-06-22", type: "unpaidLeave", sequenceId: "u2-jun-19-22" },
  { memberId: "u2", date: "2026-06-29", type: "wfh" },

  // ── June 2026 — u3 (Vikram Shah) ─────────────────────────────────────────────
  { memberId: "u3", date: "2026-06-04", type: "paidLeave", sequenceId: "u3-jun-04-05" },
  { memberId: "u3", date: "2026-06-05", type: "paidLeave", sequenceId: "u3-jun-04-05" },
  { memberId: "u3", date: "2026-06-15", type: "holiday" },
  { memberId: "u3", date: "2026-06-17", type: "noAttendance" },
  { memberId: "u3", date: "2026-06-24", type: "paidLeave", sequenceId: "u3-jun-24-28" },
  { memberId: "u3", date: "2026-06-25", type: "paidLeave", sequenceId: "u3-jun-24-28" },
  { memberId: "u3", date: "2026-06-26", type: "paidLeave", sequenceId: "u3-jun-24-28" },

  // ── June 2026 — u4 (Sana Iyer) ───────────────────────────────────────────────
  { memberId: "u4", date: "2026-06-01", type: "onDuty" },
  { memberId: "u4", date: "2026-06-15", type: "holiday" },
  { memberId: "u4", date: "2026-06-18", type: "wfh", sequenceId: "u4-jun-18-19" },
  { memberId: "u4", date: "2026-06-19", type: "wfh", sequenceId: "u4-jun-18-19" },
  { memberId: "u4", date: "2026-06-29", type: "paidLeave", sequenceId: "u4-jun-27-29" },

  // ── June 2026 — u5 (Nikhil Rao) ──────────────────────────────────────────────
  { memberId: "u5", date: "2026-06-03", type: "wfh", sequenceId: "u5-jun-03-04" },
  { memberId: "u5", date: "2026-06-04", type: "wfh", sequenceId: "u5-jun-03-04" },
  { memberId: "u5", date: "2026-06-10", type: "onDuty" },
  { memberId: "u5", date: "2026-06-15", type: "holiday" },
  { memberId: "u5", date: "2026-06-22", type: "paidLeave", sequenceId: "u5-jun-20-23" },
  { memberId: "u5", date: "2026-06-23", type: "paidLeave", sequenceId: "u5-jun-20-23" },

  // ── July 2026 — u1 ───────────────────────────────────────────────────────────
  { memberId: "u1", date: "2026-07-02", type: "wfh", sequenceId: "u1-jul-02-03" },
  { memberId: "u1", date: "2026-07-03", type: "wfh", sequenceId: "u1-jul-02-03" },
  { memberId: "u1", date: "2026-07-10", type: "paidLeave", sequenceId: "u1-jul-10-12" },
  { memberId: "u1", date: "2026-07-20", type: "onDuty" },
  { memberId: "u1", date: "2026-07-28", type: "holiday" },

  // ── July 2026 — u2 ───────────────────────────────────────────────────────────
  { memberId: "u2", date: "2026-07-01", type: "wfh" },
  { memberId: "u2", date: "2026-07-08", type: "onDuty" },
  { memberId: "u2", date: "2026-07-16", type: "paidLeave", sequenceId: "u2-jul-16-19" },
  { memberId: "u2", date: "2026-07-17", type: "paidLeave", sequenceId: "u2-jul-16-19" },
  { memberId: "u2", date: "2026-07-28", type: "holiday" },

  // ── July 2026 — u3 ───────────────────────────────────────────────────────────
  { memberId: "u3", date: "2026-07-06", type: "wfh", sequenceId: "u3-jul-06-07" },
  { memberId: "u3", date: "2026-07-07", type: "wfh", sequenceId: "u3-jul-06-07" },
  { memberId: "u3", date: "2026-07-15", type: "noAttendance" },
  { memberId: "u3", date: "2026-07-24", type: "unpaidLeave", sequenceId: "u3-jul-24-26" },
  { memberId: "u3", date: "2026-07-28", type: "holiday" },

  // ── July 2026 — u4 ───────────────────────────────────────────────────────────
  { memberId: "u4", date: "2026-07-03", type: "onDuty" },
  { memberId: "u4", date: "2026-07-13", type: "wfh", sequenceId: "u4-jul-13-14" },
  { memberId: "u4", date: "2026-07-14", type: "wfh", sequenceId: "u4-jul-13-14" },
  { memberId: "u4", date: "2026-07-28", type: "holiday" },
  { memberId: "u4", date: "2026-07-29", type: "paidLeave", sequenceId: "u4-jul-29-31" },
  { memberId: "u4", date: "2026-07-30", type: "paidLeave", sequenceId: "u4-jul-29-31" },
  { memberId: "u4", date: "2026-07-31", type: "paidLeave", sequenceId: "u4-jul-29-31" },

  // ── July 2026 — u5 ───────────────────────────────────────────────────────────
  { memberId: "u5", date: "2026-07-02", type: "wfh" },
  { memberId: "u5", date: "2026-07-09", type: "onDuty" },
  { memberId: "u5", date: "2026-07-17", type: "paidLeave", sequenceId: "u5-jul-17-19" },
  { memberId: "u5", date: "2026-07-28", type: "holiday" },

  // ── August 2026 — u1 ─────────────────────────────────────────────────────────
  { memberId: "u1", date: "2026-08-03", type: "wfh" },
  { memberId: "u1", date: "2026-08-14", type: "paidLeave" },
  { memberId: "u1", date: "2026-08-15", type: "holiday" },
  { memberId: "u1", date: "2026-08-17", type: "paidLeave" },
  { memberId: "u1", date: "2026-08-28", type: "paidLeave", sequenceId: "u1-aug-28-30" },

  // ── August 2026 — u2 ─────────────────────────────────────────────────────────
  { memberId: "u2", date: "2026-08-05", type: "wfh", sequenceId: "u2-aug-05-06" },
  { memberId: "u2", date: "2026-08-06", type: "wfh", sequenceId: "u2-aug-05-06" },
  { memberId: "u2", date: "2026-08-15", type: "holiday" },
  { memberId: "u2", date: "2026-08-20", type: "onDuty" },
  { memberId: "u2", date: "2026-08-24", type: "unpaidLeave", sequenceId: "u2-aug-24-25" },
  { memberId: "u2", date: "2026-08-25", type: "unpaidLeave", sequenceId: "u2-aug-24-25" },

  // ── August 2026 — u3 ─────────────────────────────────────────────────────────
  { memberId: "u3", date: "2026-08-07", type: "noAttendance" },
  { memberId: "u3", date: "2026-08-15", type: "holiday" },
  { memberId: "u3", date: "2026-08-18", type: "paidLeave", sequenceId: "u3-aug-18-20" },
  { memberId: "u3", date: "2026-08-19", type: "paidLeave", sequenceId: "u3-aug-18-20" },
  { memberId: "u3", date: "2026-08-20", type: "paidLeave", sequenceId: "u3-aug-18-20" },

  // ── August 2026 — u4 ─────────────────────────────────────────────────────────
  { memberId: "u4", date: "2026-08-04", type: "onDuty" },
  { memberId: "u4", date: "2026-08-11", type: "wfh" },
  { memberId: "u4", date: "2026-08-15", type: "holiday" },
  { memberId: "u4", date: "2026-08-21", type: "paidLeave", sequenceId: "u4-aug-21-23" },

  // ── August 2026 — u5 ─────────────────────────────────────────────────────────
  { memberId: "u5", date: "2026-08-03", type: "wfh", sequenceId: "u5-aug-03-04" },
  { memberId: "u5", date: "2026-08-04", type: "wfh", sequenceId: "u5-aug-03-04" },
  { memberId: "u5", date: "2026-08-15", type: "holiday" },
  { memberId: "u5", date: "2026-08-26", type: "onDuty" },

  // ── September 2026 — u1 ──────────────────────────────────────────────────────
  { memberId: "u1", date: "2026-09-01", type: "wfh", sequenceId: "u1-sep-01-02" },
  { memberId: "u1", date: "2026-09-02", type: "wfh", sequenceId: "u1-sep-01-02" },
  { memberId: "u1", date: "2026-09-11", type: "paidLeave", sequenceId: "u1-sep-11-13" },

  // ── September 2026 — u2 ──────────────────────────────────────────────────────
  { memberId: "u2", date: "2026-09-07", type: "onDuty" },
  { memberId: "u2", date: "2026-09-17", type: "paidLeave", sequenceId: "u2-sep-17-20" },
  { memberId: "u2", date: "2026-09-18", type: "paidLeave", sequenceId: "u2-sep-17-20" },

  // ── September 2026 — u3 ──────────────────────────────────────────────────────
  { memberId: "u3", date: "2026-09-03", type: "wfh" },
  { memberId: "u3", date: "2026-09-15", type: "noAttendance" },
  { memberId: "u3", date: "2026-09-28", type: "unpaidLeave", sequenceId: "u3-sep-28-30" },
  { memberId: "u3", date: "2026-09-29", type: "unpaidLeave", sequenceId: "u3-sep-28-30" },
  { memberId: "u3", date: "2026-09-30", type: "unpaidLeave", sequenceId: "u3-sep-28-30" },

  // ── September 2026 — u4 ──────────────────────────────────────────────────────
  { memberId: "u4", date: "2026-09-04", type: "onDuty" },
  { memberId: "u4", date: "2026-09-09", type: "wfh", sequenceId: "u4-sep-09-10" },
  { memberId: "u4", date: "2026-09-10", type: "wfh", sequenceId: "u4-sep-09-10" },
  { memberId: "u4", date: "2026-09-25", type: "paidLeave", sequenceId: "u4-sep-25-27" },

  // ── September 2026 — u5 ──────────────────────────────────────────────────────
  { memberId: "u5", date: "2026-09-02", type: "wfh" },
  { memberId: "u5", date: "2026-09-14", type: "onDuty" },
  { memberId: "u5", date: "2026-09-21", type: "paidLeave", sequenceId: "u5-sep-21-22" },
  { memberId: "u5", date: "2026-09-22", type: "paidLeave", sequenceId: "u5-sep-21-22" },
];
