using Microsoft.AspNetCore.Mvc;
using PMS.API.Modules.Catalogs.DTOs;
using PMS.API.Modules.Catalogs.Services;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.Catalogs.Controllers;

/// <summary>
/// Leave Calendar Master API.
/// Used by administrators to manage company holidays with tags and colors,
/// which automatically reflect across the Team Dashboard.
/// </summary>
[ApiController]
[Route("api/v1/leave-calendar")]
public class LeaveCalendarController(ILeaveCalendarService leaveCalendarService) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<LeaveCalendarHolidayDto>>>> GetHolidays(
        [FromQuery] int? year,
        CancellationToken ct)
    {
        var holidays = await leaveCalendarService.GetHolidaysAsync(year, ct);
        return Ok(ApiResponse<IReadOnlyList<LeaveCalendarHolidayDto>>.Ok(holidays));
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<ApiResponse<LeaveCalendarHolidayDto>>> GetById(
        Guid id,
        CancellationToken ct)
    {
        var holiday = await leaveCalendarService.GetHolidayByIdAsync(id, ct);
        if (holiday is null)
        {
            return NotFound(ApiResponse<LeaveCalendarHolidayDto>.Fail("NotFound", $"Holiday with ID '{id}' was not found."));
        }
        return Ok(ApiResponse<LeaveCalendarHolidayDto>.Ok(holiday));
    }

    [HttpPost]
    public async Task<ActionResult<ApiResponse<LeaveCalendarHolidayDto>>> CreateHoliday(
        [FromBody] UpsertLeaveCalendarHolidayRequest request,
        CancellationToken ct)
    {
        var created = await leaveCalendarService.CreateHolidayAsync(request, ct);
        return Ok(ApiResponse<LeaveCalendarHolidayDto>.Ok(created));
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult<ApiResponse<LeaveCalendarHolidayDto>>> UpdateHoliday(
        Guid id,
        [FromBody] UpsertLeaveCalendarHolidayRequest request,
        CancellationToken ct)
    {
        var updated = await leaveCalendarService.UpdateHolidayAsync(id, request, ct);
        return Ok(ApiResponse<LeaveCalendarHolidayDto>.Ok(updated));
    }

    [HttpDelete("{id:guid}")]
    public async Task<ActionResult<ApiResponse<Guid>>> DeleteHoliday(
        Guid id,
        CancellationToken ct)
    {
        await leaveCalendarService.DeleteHolidayAsync(id, ct);
        return Ok(ApiResponse<Guid>.Ok(id));
    }

    [HttpDelete("year/{year:int}")]
    public async Task<ActionResult<ApiResponse<int>>> ClearYearHolidays(
        int year,
        CancellationToken ct)
    {
        await leaveCalendarService.ClearYearHolidaysAsync(year, ct);
        return Ok(ApiResponse<int>.Ok(year));
    }

    [HttpPost("bulk")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<LeaveCalendarHolidayDto>>>> BulkCreateHolidays(
        [FromBody] IReadOnlyList<UpsertLeaveCalendarHolidayRequest> requests,
        CancellationToken ct)
    {
        var created = await leaveCalendarService.BulkCreateHolidaysAsync(requests, ct);
        return Ok(ApiResponse<IReadOnlyList<LeaveCalendarHolidayDto>>.Ok(created));
    }
}
