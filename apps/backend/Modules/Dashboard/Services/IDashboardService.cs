using PMS.API.Modules.Dashboard.DTOs;

namespace PMS.API.Modules.Dashboard.Services;

public interface IDashboardService
{
    Task<TeamSummaryDto> GetTeamSummaryAsync(TeamSummaryQuery query, CancellationToken ct = default);

    Task<OnsiteUtilizationDto> GetOnsiteUtilizationAsync(TeamSummaryQuery query, CancellationToken ct = default);

    Task<RoleAllocationDto> GetRoleAllocationAsync(TeamSummaryQuery query, CancellationToken ct = default);

    Task<OnsiteProjectCountDto> GetOnsiteProjectCountsAsync(TeamSummaryQuery query, CancellationToken ct = default);

    Task<OffsiteTeamUtilizationDto> GetOffsiteTeamUtilizationAsync(TeamSummaryQuery query, CancellationToken ct = default);

    Task<ResignationCountDto> GetResignationCountsAsync(TeamSummaryQuery query, CancellationToken ct = default);

    Task<OffsiteCapacityDto> GetOffsiteCapacityAsync(TeamSummaryQuery query, CancellationToken ct = default);
}
