using PMS.API.Modules.Timesheets.DTOs;

namespace PMS.API.Modules.Timesheets.Services;

public interface ITimesheetService
{
    Task<TimesheetWeekDto?> GetMineAsync(DateOnly weekStart, CancellationToken ct = default);

    Task<TimesheetWeekDto?> GetPreviousAsync(DateOnly weekStart, CancellationToken ct = default);

    Task<TimesheetWeekDto> SaveDraftAsync(SaveTimesheetRequest request, CancellationToken ct = default);

    Task<TimesheetWeekDto> SubmitAsync(SaveTimesheetRequest request, CancellationToken ct = default);

    Task<IReadOnlyList<TimesheetWeekDto>> ListForApprovalAsync(CancellationToken ct = default);

    Task<TimesheetWeekDto> DecideAsync(Guid timesheetId, DecideTimesheetRequest request, CancellationToken ct = default);
}
