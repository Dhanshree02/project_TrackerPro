namespace PMS.API.Modules.Catalogs.DTOs;

public sealed record LeaveCalendarHolidayDto(
    Guid Id,
    DateOnly Date,
    string Name,
    string Tag,
    string Color,
    string? Description,
    int Year,
    DateTime CreatedAtUtc);

public sealed record UpsertLeaveCalendarHolidayRequest(
    DateOnly Date,
    string Name,
    string Tag,
    string Color,
    string? Description);

