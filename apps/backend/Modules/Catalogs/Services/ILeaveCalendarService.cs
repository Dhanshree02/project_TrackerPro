using PMS.API.Modules.Catalogs.DTOs;

namespace PMS.API.Modules.Catalogs.Services;

public interface ILeaveCalendarService
{
    Task<IReadOnlyList<LeaveCalendarHolidayDto>> GetHolidaysAsync(int? year, CancellationToken ct = default);

    Task<LeaveCalendarHolidayDto?> GetHolidayByIdAsync(Guid id, CancellationToken ct = default);

    Task<LeaveCalendarHolidayDto> CreateHolidayAsync(UpsertLeaveCalendarHolidayRequest request, CancellationToken ct = default);

    Task<LeaveCalendarHolidayDto> UpdateHolidayAsync(Guid id, UpsertLeaveCalendarHolidayRequest request, CancellationToken ct = default);

    Task DeleteHolidayAsync(Guid id, CancellationToken ct = default);

    Task<IReadOnlyList<LeaveCalendarHolidayDto>> BulkCreateHolidaysAsync(
        IReadOnlyList<UpsertLeaveCalendarHolidayRequest> requests,
        CancellationToken ct = default);
}

