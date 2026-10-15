using Microsoft.AspNetCore.Mvc;
using PMS.API.Modules.Dashboard.DTOs;
using PMS.API.Modules.Dashboard.Services;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.Dashboard.Controllers;

[ApiController]
[Route("api/v1/dashboard")]
public class DashboardController(IDashboardService dashboard) : ControllerBase
{
    [HttpGet("team-summary")]
    public async Task<ActionResult<ApiResponse<TeamSummaryDto>>> TeamSummary(
        [FromQuery] TeamSummaryQuery? query,
        CancellationToken ct)
    {
        var result = await dashboard.GetTeamSummaryAsync(query ?? new TeamSummaryQuery(), ct);
        return Ok(ApiResponse<TeamSummaryDto>.Ok(result));
    }

    [HttpGet("onsite-utilization")]
    public async Task<ActionResult<ApiResponse<OnsiteUtilizationDto>>> OnsiteUtilization(
        [FromQuery] TeamSummaryQuery? query,
        CancellationToken ct)
    {
        var result = await dashboard.GetOnsiteUtilizationAsync(query ?? new TeamSummaryQuery(), ct);
        return Ok(ApiResponse<OnsiteUtilizationDto>.Ok(result));
    }

    [HttpGet("onsite-project-counts")]
    public async Task<ActionResult<ApiResponse<OnsiteProjectCountDto>>> OnsiteProjectCounts(
        [FromQuery] TeamSummaryQuery? query,
        CancellationToken ct)
    {
        var result = await dashboard.GetOnsiteProjectCountsAsync(query ?? new TeamSummaryQuery(), ct);
        return Ok(ApiResponse<OnsiteProjectCountDto>.Ok(result));
    }

    [HttpGet("offsite-utilization")]
    public async Task<ActionResult<ApiResponse<OffsiteTeamUtilizationDto>>> OffsiteUtilization(
        [FromQuery] TeamSummaryQuery? query,
        CancellationToken ct)
    {
        var result = await dashboard.GetOffsiteTeamUtilizationAsync(query ?? new TeamSummaryQuery(), ct);
        return Ok(ApiResponse<OffsiteTeamUtilizationDto>.Ok(result));
    }

    [HttpGet("resignation-counts")]
    public async Task<ActionResult<ApiResponse<ResignationCountDto>>> ResignationCounts(
        [FromQuery] TeamSummaryQuery? query,
        CancellationToken ct)
    {
        var result = await dashboard.GetResignationCountsAsync(query ?? new TeamSummaryQuery(), ct);
        return Ok(ApiResponse<ResignationCountDto>.Ok(result));
    }

    [HttpGet("offsite-capacity")]
    public async Task<ActionResult<ApiResponse<OffsiteCapacityDto>>> OffsiteCapacity(
        [FromQuery] TeamSummaryQuery? query,
        CancellationToken ct)
    {
        var result = await dashboard.GetOffsiteCapacityAsync(query ?? new TeamSummaryQuery(), ct);
        return Ok(ApiResponse<OffsiteCapacityDto>.Ok(result));
    }

    [HttpGet("role-allocation")]
    public async Task<ActionResult<ApiResponse<RoleAllocationDto>>> RoleAllocation(
        [FromQuery] TeamSummaryQuery? query,
        CancellationToken ct)
    {
        var result = await dashboard.GetRoleAllocationAsync(query ?? new TeamSummaryQuery(), ct);
        return Ok(ApiResponse<RoleAllocationDto>.Ok(result));
    }
}
