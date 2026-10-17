namespace PMS.API.Modules.Dashboard.DTOs;

public sealed class TeamSummaryQuery
{
    /// <summary>rolling = previous two months plus the current month. A quarter code selects that financial quarter instead.</summary>
    public string? Period { get; set; }

    public string? Quarter { get; set; }

    /// <summary>Financial-year start year. April 2026–March 2027 is 2026.</summary>
    public int? FinancialYear { get; set; }
}

public sealed record TeamSummaryDto(
    string Quarter,
    int FinancialYear,
    IReadOnlyList<TeamSummaryMonthDto> Months);

public sealed record RoleAllocationDto(
    string Quarter,
    int FinancialYear,
    IReadOnlyList<RoleAllocationMonthDto> Months);

public sealed record RoleAllocationMonthDto(
    string Month,
    int Year,
    int OnsiteTm,
    int OnsiteLeads,
    int OffsiteTm,
    int OffsiteLeads,
    int OffsitePm,
    int OnsitePm);

public sealed record OnsiteProjectCountDto(
    string Quarter,
    int FinancialYear,
    IReadOnlyList<OnsiteProjectCountMonthDto> Months,
    IReadOnlyList<OnsiteProjectCountRowDto> Projects);

public sealed record OnsiteProjectCountMonthDto(string Month, int Year);

public sealed record OnsiteProjectCountRowDto(
    string ProjectName,
    int OnsiteResourceCount,
    IReadOnlyList<int> MonthlyCounts);

public sealed record OffsiteTeamUtilizationDto(
    string Quarter,
    int FinancialYear,
    IReadOnlyList<OffsiteTeamUtilizationMonthDto> Months,
    IReadOnlyList<OffsiteTeamUtilizationRowDto> Departments);

public sealed record OffsiteTeamUtilizationMonthDto(string Month, int Year);

public sealed record OffsiteTeamUtilizationRowDto(
    string Department,
    IReadOnlyList<int> TeamStrength,
    IReadOnlyList<int> Utilization);

public sealed record ResignationCountDto(
    string Quarter,
    int FinancialYear,
    IReadOnlyList<ResignationCountRowDto> Offsite,
    IReadOnlyList<ResignationCountRowDto> Onsite);

public sealed record ResignationCountRowDto(
    string Role,
    int TotalCount,
    int BondFree,
    int OnPaper);

public sealed record OffsiteCapacityDto(
    string Quarter,
    int FinancialYear,
    int CalendarDays,
    IReadOnlyList<OffsiteCapacityMonthDto> Months,
    IReadOnlyList<OffsiteCapacityRowDto> Departments);

public sealed record OffsiteCapacityMonthDto(string Month, int Year);

public sealed record OffsiteCapacityRowDto(
    string SubDepartment,
    string? Effort,
    string? CapacityUnit,
    IReadOnlyList<int> Tm,
    IReadOnlyList<int> EffectiveDays,
    IReadOnlyList<int?> MonthlyCapacity);

public sealed record OnsiteUtilizationDto(
    string Quarter,
    int FinancialYear,
    IReadOnlyList<OnsiteUtilizationMonthDto> Months);

public sealed record OnsiteUtilizationMonthDto(
    string Month,
    int Year,
    int TotalOnsiteTeam,
    int Billable,
    int NonBillable,
    int BillablePercentage,
    int NonBillablePercentage,
    IReadOnlyList<string> NonBillableProjects);

public sealed record TeamSummaryMonthDto(
    string Month,
    int Year,
    int TotalTeamSize,
    int OnsiteTeam,
    int OffsiteTeam,
    int OnsitePercentage,
    int OffsitePercentage,
    int Onboarding,
    int Offboarding);
