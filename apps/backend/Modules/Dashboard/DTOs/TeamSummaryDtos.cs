namespace PMS.API.Modules.Dashboard.DTOs;

public sealed class TeamSummaryQuery
{
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
    int OffsitePm);

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
