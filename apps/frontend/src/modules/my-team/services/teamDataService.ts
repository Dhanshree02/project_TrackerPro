// ─── My Team Service ──────────────────────────────────────────────────────────
// Currently returns dummy data. When APIs are ready, only this file changes.
// UI components must NOT be modified when switching to real API responses.

import { people } from "@/lib/mock-data";
import { seedTeamMemberExtensions } from "@/dummy-data/my-team/teamMemberExtensions";
import { seedScheduleEntries } from "@/dummy-data/my-team/scheduleEntries";
import { attendanceMeta } from "@/modules/my-team/constants";
import type { TeamMember, TeamSchedule } from "@/modules/my-team/types";

export const teamDataService = {
  /**
   * Returns team members for the current user's direct reports.
   * Maps existing Person records from @/lib/mock-data with the My Team-specific
   * extension fields (designation, department, status, avatarColor).
   *
   * Future: replace body with `await api.get("/my-team/members")`
   */
  getTeamMembers(): TeamMember[] {
    return seedTeamMemberExtensions
      .map((ext) => {
        const person = people.find((p) => p.id === ext.personId);
        if (!person) return null;

        return {
          id: person.id,
          name: person.name,
          // person.avatar holds the initials string (e.g. "AM") in mock-data
          initials: person.avatar,
          designation: ext.designation,
          department: ext.department,
          status: ext.status,
          avatarColor: ext.avatarColor,
        } satisfies TeamMember;
      })
      .filter((m): m is TeamMember => m !== null);
  },

  /**
   * Builds the initial team schedule from seed entries.
   * Initialises an empty slot for every team member, then applies each
   * schedule entry so the event lookup functions have a consistent structure.
   *
   * Future: replace body with `await api.get("/my-team/schedule?month=YYYY-MM")`
   */
  createInitialSchedule(teamMembers: TeamMember[]): TeamSchedule {
    const schedule: TeamSchedule = {};

    // Create an empty record for every member first so lookups never throw.
    teamMembers.forEach((member) => {
      schedule[member.id] = {};
    });

    seedScheduleEntries.forEach((entry) => {
      // Silently skip entries for members not present in the current team list.
      if (!schedule[entry.memberId]) return;

      schedule[entry.memberId][entry.date] = {
        type: entry.type,
        title: entry.title ?? attendanceMeta[entry.type].label,
        sequenceId: entry.sequenceId,
      };
    });

    return schedule;
  },
};
