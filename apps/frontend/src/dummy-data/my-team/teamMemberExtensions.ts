// ─── My Team — Team Member Extensions ────────────────────────────────────────
// Extends the existing Person records in @/lib/mock-data with My Team-specific
// fields that are not part of the core Person shape (designation, department,
// today's attendance status, and avatar colour).
//
// Only references personIds that already exist in the people[] array.
// If a new person is added to people[], add a corresponding extension here so
// they appear automatically in the My Team calendar.
//
// Future: replace seedTeamMemberExtensions with an API call to
//         GET /my-team/members when the backend is ready.

import type { MemberStatus } from "@/modules/my-team/types";

export interface TeamMemberExtension {
  /** Must match a Person.id from @/lib/mock-data people[]. */
  personId: string;
  designation: string;
  department: string;
  /** Today's attendance status shown in the summary cards. */
  status: MemberStatus;
  /** Hex colour used for the avatar circle. */
  avatarColor: string;
}

export const seedTeamMemberExtensions: TeamMemberExtension[] = [
  // u1 — Aarav Mehta  (Senior PM in mock-data)
  {
    personId: "u1",
    designation: "Senior Project Manager",
    department: "Engineering",
    status: "Active",
    avatarColor: "#40aaf2",
  },
  // u2 — Riya Kapoor  (Engagement Manager in mock-data)
  {
    personId: "u2",
    designation: "Engagement Manager",
    department: "Delivery",
    status: "WFH",
    avatarColor: "#8b75c8",
  },
  // u3 — Vikram Shah  (PM in mock-data)
  {
    personId: "u3",
    designation: "Project Manager",
    department: "Engineering",
    status: "On Leave",
    avatarColor: "#cf67bd",
  },
  // u4 — Sana Iyer  (PM in mock-data)
  {
    personId: "u4",
    designation: "Project Manager",
    department: "Product",
    status: "Active",
    avatarColor: "#55b7a4",
  },
  // u5 — Nikhil Rao  (TL in mock-data)
  {
    personId: "u5",
    designation: "Tech Lead",
    department: "Engineering",
    status: "Active",
    avatarColor: "#ef9b52",
  },
];
