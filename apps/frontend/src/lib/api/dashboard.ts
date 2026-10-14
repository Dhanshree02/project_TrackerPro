import { apiFetch } from "@/lib/api-client";

export type DashboardQuarter = "Q1" | "Q2" | "Q3" | "Q4";

/** Graph shows charts, list shows tables, both shows the tables and the charts together. */
export type MisDashboardView = "graph" | "list" | "both";

export interface TeamSummaryMonth {
  month: string;
  year: number;
  totalTeamSize: number;
  onsiteTeam: number;
  offsiteTeam: number;
  onsitePercentage: number;
  offsitePercentage: number;
  onboarding: number;
  offboarding: number;
}

export interface TeamSummary {
  quarter: DashboardQuarter;
  financialYear: number;
  months: TeamSummaryMonth[];
}

/** Financial year starts in April. October 2026 is FY 2026, Q3. */
export function currentDashboardQuarter(today = new Date()): DashboardQuarter {
  const month = today.getMonth() + 1;
  if (month >= 4 && month <= 6) return "Q1";
  if (month >= 7 && month <= 9) return "Q2";
  if (month >= 10 && month <= 12) return "Q3";
  return "Q4";
}

export interface OnsiteUtilizationMonth {
  month: string;
  year: number;
  totalOnsiteTeam: number;
  billable: number;
  nonBillable: number;
  billablePercentage: number;
  nonBillablePercentage: number;
  nonBillableProjects: string[];
}

export interface OnsiteUtilization {
  quarter: DashboardQuarter;
  financialYear: number;
  months: OnsiteUtilizationMonth[];
}

export function fetchTeamSummary(quarter: DashboardQuarter, signal?: AbortSignal): Promise<TeamSummary> {
  const params = new URLSearchParams({ quarter });
  return apiFetch<TeamSummary>(`/api/v1/dashboard/team-summary?${params.toString()}`, { signal });
}

export interface RoleAllocationMonth {
  month: string;
  year: number;
  onsiteTm: number;
  onsiteLeads: number;
  offsiteTm: number;
  offsiteLeads: number;
  offsitePm: number;
}

export interface RoleAllocation {
  quarter: DashboardQuarter;
  financialYear: number;
  months: RoleAllocationMonth[];
}

export interface OnsiteProjectCountMonth {
  month: string;
  year: number;
}

export interface OnsiteProjectCountRow {
  projectName: string;
  onsiteResourceCount: number;
  monthlyCounts: number[];
}

export interface OnsiteProjectCounts {
  quarter: DashboardQuarter;
  financialYear: number;
  months: OnsiteProjectCountMonth[];
  projects: OnsiteProjectCountRow[];
}

export function fetchOnsiteProjectCounts(
  quarter: DashboardQuarter,
  signal?: AbortSignal,
): Promise<OnsiteProjectCounts> {
  const params = new URLSearchParams({ quarter });
  return apiFetch<OnsiteProjectCounts>(`/api/v1/dashboard/onsite-project-counts?${params.toString()}`, { signal });
}

export interface OffsiteServiceActivityMonth {
  month: string;
  year: number;
}

export interface OffsiteServiceActivityRow {
  department: string;
  monthlyCounts: number[];
}

export interface OffsiteServiceActivity {
  quarter: DashboardQuarter;
  financialYear: number;
  months: OffsiteServiceActivityMonth[];
  departments: OffsiteServiceActivityRow[];
}

export interface OffsiteTeamUtilizationMonth {
  month: string;
  year: number;
}

export interface OffsiteTeamUtilizationRow {
  department: string;
  teamStrength: number[];
  utilization: number[];
}

export interface OffsiteTeamUtilization {
  quarter: DashboardQuarter;
  financialYear: number;
  months: OffsiteTeamUtilizationMonth[];
  departments: OffsiteTeamUtilizationRow[];
}

export function fetchOffsiteTeamUtilization(
  quarter: DashboardQuarter,
  signal?: AbortSignal,
): Promise<OffsiteTeamUtilization> {
  const params = new URLSearchParams({ quarter });
  return apiFetch<OffsiteTeamUtilization>(`/api/v1/dashboard/offsite-utilization?${params.toString()}`, { signal });
}

export function fetchOffsiteServiceActivity(
  quarter: DashboardQuarter,
  signal?: AbortSignal,
): Promise<OffsiteServiceActivity> {
  const params = new URLSearchParams({ quarter });
  return apiFetch<OffsiteServiceActivity>(`/api/v1/dashboard/offsite-service-activity?${params.toString()}`, { signal });
}

export function fetchRoleAllocation(
  quarter: DashboardQuarter,
  signal?: AbortSignal,
): Promise<RoleAllocation> {
  const params = new URLSearchParams({ quarter });
  return apiFetch<RoleAllocation>(`/api/v1/dashboard/role-allocation?${params.toString()}`, { signal });
}

export function fetchOnsiteUtilization(
  quarter: DashboardQuarter,
  signal?: AbortSignal,
): Promise<OnsiteUtilization> {
  const params = new URLSearchParams({ quarter });
  return apiFetch<OnsiteUtilization>(`/api/v1/dashboard/onsite-utilization?${params.toString()}`, { signal });
}
