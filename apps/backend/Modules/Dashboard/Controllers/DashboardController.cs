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

    [HttpGet("role-allocation")]
    public async Task<ActionResult<ApiResponse<RoleAllocationDto>>> RoleAllocation(
        [FromQuery] TeamSummaryQuery? query,
        CancellationToken ct)
    {
        var result = await dashboard.GetRoleAllocationAsync(query ?? new TeamSummaryQuery(), ct);
        return Ok(ApiResponse<RoleAllocationDto>.Ok(result));
    }
}
