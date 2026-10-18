import { apiFetch } from "@/lib/api-client";

export type TimesheetStatus = "draft" | "submitted" | "approved" | "rejected" | "change_requested";

export interface TimesheetDay {
  dayIndex: number;
  hours: number;
  comment: string | null;
}

export interface TimesheetLine {
  id: string;
  projectKey: string;
  projectName: string;
  taskKey: string;
  taskName: string;
  days: TimesheetDay[];
  reviewDecision: "approved" | "rejected" | "change_requested" | null;
}

export interface TimesheetWeek {
  id: string;
  employeeId: string;
  employeeName: string;
  employeeCode: string;
  weekStart: string;
  status: TimesheetStatus;
  totalHours: number;
  submittedAtUtc: string | null;
  reviewComment: string | null;
  viewerCanReview: boolean;
  entries: TimesheetLine[];
}

export interface SaveTimesheetLine {
  projectKey: string;
  projectName: string;
  taskKey: string;
  taskName: string;
  days: TimesheetDay[];
}

export function getMyTimesheet(weekStart: string) {
  return apiFetch<TimesheetWeek | null>(`/api/v1/timesheets/mine?weekStart=${weekStart}`);
}

export function getPreviousTimesheet(weekStart: string) {
  return apiFetch<TimesheetWeek | null>(`/api/v1/timesheets/mine/previous?weekStart=${weekStart}`);
}

export function saveTimesheetDraft(weekStart: string, entries: SaveTimesheetLine[]) {
  return apiFetch<TimesheetWeek>("/api/v1/timesheets/mine", {
    method: "PUT",
    body: JSON.stringify({ weekStart, entries }),
  });
}

export function submitTimesheet(weekStart: string, entries: SaveTimesheetLine[]) {
  return apiFetch<TimesheetWeek>("/api/v1/timesheets/mine/submit", {
    method: "POST",
    body: JSON.stringify({ weekStart, entries }),
  });
}

export function listTimesheetApprovals() {
  return apiFetch<TimesheetWeek[]>("/api/v1/timesheets/approvals");
}

export function listMyTimesheetHistory() {
  return apiFetch<TimesheetWeek[]>("/api/v1/timesheets/mine/history");
}

export function decideTimesheet(
  id: string,
  entryIds: string[],
  action: "approved" | "rejected" | "change_requested",
  comment: string,
) {
  return apiFetch<TimesheetWeek>(`/api/v1/timesheets/${id}/decisions`, {
    method: "POST",
    body: JSON.stringify({ entryIds, action, comment }),
  });
}
