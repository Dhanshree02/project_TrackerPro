namespace PMS.API.Modules.MyTeam.DTOs;

public sealed record TeamCalendarDto(
    IReadOnlyList<TeamMemberDto> Members,
    IReadOnlyList<TeamDayEntryDto> Entries,
    IReadOnlyList<TeamMemberScheduleDto> Schedules);

public sealed record TeamMemberDto(
    Guid Id,
    string Name,
    string Initials,
    string Designation,
    string Department);

public sealed record TeamDayEntryDto(
    Guid EmployeeId,
    DateOnly Date,
    string? Attendance,
    string? Shift);

public sealed record TeamMemberScheduleDto(
    Guid EmployeeId,
    IReadOnlyList<short> WorkingDays,
    string? Notes,
    IReadOnlyList<TeamHolidayDto> Holidays);

public sealed record TeamHolidayDto(DateOnly Date, string Name, string? Comment);

public sealed record UpsertTeamDaysRequest(
    Guid EmployeeId,
    IReadOnlyList<DateOnly> Dates,
    string? Attendance,
    string? Shift);

public sealed record SaveTeamScheduleRequest(
    IReadOnlyList<short> WorkingDays,
    string? Notes,
    IReadOnlyList<TeamHolidayInput> Holidays);

public sealed record TeamHolidayInput(DateOnly Date, string Name, string? Comment);
