import { apiFetch } from "@/lib/api-client";

export type DashboardQuarter = "Q1" | "Q2" | "Q3" | "Q4";

/** rolling = previous two months plus the current month. A quarter code selects that financial quarter. */
export type DashboardPeriod = "rolling" | DashboardQuarter;

export function dashboardPeriodLabel(period: DashboardPeriod): string {
  return period === "rolling" ? "Last 3 Months" : period;
}

function dashboardQuery(period: DashboardPeriod): string {
  const params = new URLSearchParams(period === "rolling" ? { period: "rolling" } : { quarter: period });
  return params.toString();
}

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

export function fetchTeamSummary(period: DashboardPeriod, signal?: AbortSignal): Promise<TeamSummary> {
  return apiFetch<TeamSummary>(`/api/v1/dashboard/team-summary?${dashboardQuery(period)}`, { signal });
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
  period: DashboardPeriod,
  signal?: AbortSignal,
): Promise<OnsiteProjectCounts> {
  return apiFetch<OnsiteProjectCounts>(`/api/v1/dashboard/onsite-project-counts?${dashboardQuery(period)}`, { signal });
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
  period: DashboardPeriod,
  signal?: AbortSignal,
): Promise<OffsiteTeamUtilization> {
  return apiFetch<OffsiteTeamUtilization>(`/api/v1/dashboard/offsite-utilization?${dashboardQuery(period)}`, { signal });
}

export function fetchRoleAllocation(
  period: DashboardPeriod,
  signal?: AbortSignal,
): Promise<RoleAllocation> {
  return apiFetch<RoleAllocation>(`/api/v1/dashboard/role-allocation?${dashboardQuery(period)}`, { signal });
}

export interface ResignationCountRow {
  role: string;
  totalCount: number;
  bondFree: number;
  onPaper: number;
}

export interface ResignationCounts {
  quarter: string;
  financialYear: number;
  offsite: ResignationCountRow[];
  onsite: ResignationCountRow[];
}

export function fetchResignationCounts(
  period: DashboardPeriod,
  signal?: AbortSignal,
): Promise<ResignationCounts> {
  return apiFetch<ResignationCounts>(`/api/v1/dashboard/resignation-counts?${dashboardQuery(period)}`, { signal });
}

export interface OffsiteCapacityMonth {
  month: string;
  year: number;
}

export interface OffsiteCapacityRow {
  subDepartment: string;
  effort: string | null;
  capacityUnit: string | null;
  tm: number[];
  effectiveDays: number[];
  monthlyCapacity: Array<number | null>;
}

export interface OffsiteCapacity {
  quarter: string;
  financialYear: number;
  calendarDays: number;
  months: OffsiteCapacityMonth[];
  departments: OffsiteCapacityRow[];
}

export function fetchOffsiteCapacity(
  period: DashboardPeriod,
  signal?: AbortSignal,
): Promise<OffsiteCapacity> {
  return apiFetch<OffsiteCapacity>(`/api/v1/dashboard/offsite-capacity?${dashboardQuery(period)}`, { signal });
}

export function fetchOnsiteUtilization(
  period: DashboardPeriod,
  signal?: AbortSignal,
): Promise<OnsiteUtilization> {
  return apiFetch<OnsiteUtilization>(`/api/v1/dashboard/onsite-utilization?${dashboardQuery(period)}`, { signal });
}
