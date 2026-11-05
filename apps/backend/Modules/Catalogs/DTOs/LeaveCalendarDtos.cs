namespace PMS.API.Modules.Catalogs.DTOs;

public sealed record LeaveCalendarHolidayDto(
    Guid Id,
    DateOnly Date,
    string Name,
    int Year,
    DateTime CreatedAtUtc);

public sealed record UpsertLeaveCalendarHolidayRequest(
    DateOnly Date,
    string Name);
