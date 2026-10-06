using Microsoft.AspNetCore.Mvc;
using PMS.API.Modules.Timesheets.DTOs;
using PMS.API.Modules.Timesheets.Services;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.Timesheets.Controllers;

[ApiController]
[Route("api/v1/timesheets")]
public class TimesheetsController(ITimesheetService timesheets) : ControllerBase
{
    [HttpGet("mine")]
    public async Task<ActionResult<ApiResponse<TimesheetWeekDto?>>> Mine(
        [FromQuery] DateOnly weekStart,
        CancellationToken ct)
    {
        return Ok(ApiResponse<TimesheetWeekDto?>.Ok(await timesheets.GetMineAsync(weekStart, ct)));
    }

    [HttpGet("mine/history")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<TimesheetWeekDto>>>> MineHistory(CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<TimesheetWeekDto>>.Ok(await timesheets.ListMineAsync(ct)));
    }

    [HttpGet("mine/previous")]
    public async Task<ActionResult<ApiResponse<TimesheetWeekDto?>>> Previous(
        [FromQuery] DateOnly weekStart,
        CancellationToken ct)
    {
        return Ok(ApiResponse<TimesheetWeekDto?>.Ok(await timesheets.GetPreviousAsync(weekStart, ct)));
    }

    [HttpPut("mine")]
    public async Task<ActionResult<ApiResponse<TimesheetWeekDto>>> SaveDraft(
        [FromBody] SaveTimesheetRequest request,
        CancellationToken ct)
    {
        return Ok(ApiResponse<TimesheetWeekDto>.Ok(await timesheets.SaveDraftAsync(request, ct)));
    }

    [HttpPost("mine/submit")]
    public async Task<ActionResult<ApiResponse<TimesheetWeekDto>>> Submit(
        [FromBody] SaveTimesheetRequest request,
        CancellationToken ct)
    {
        return Ok(ApiResponse<TimesheetWeekDto>.Ok(await timesheets.SubmitAsync(request, ct)));
    }

    [HttpGet("approvals")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<TimesheetWeekDto>>>> Approvals(CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<TimesheetWeekDto>>.Ok(await timesheets.ListForApprovalAsync(ct)));
    }

    [HttpPost("{id:guid}/decisions")]
    public async Task<ActionResult<ApiResponse<TimesheetWeekDto>>> Decide(
        Guid id,
        [FromBody] DecideTimesheetRequest request,
        CancellationToken ct)
    {
        return Ok(ApiResponse<TimesheetWeekDto>.Ok(await timesheets.DecideAsync(id, request, ct)));
    }
}
