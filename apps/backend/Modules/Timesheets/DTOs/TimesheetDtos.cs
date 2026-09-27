namespace PMS.API.Modules.Timesheets.DTOs;

public sealed record TimesheetDayDto(short DayIndex, decimal Hours, string? Comment);

public sealed record TimesheetLineDto(
    Guid Id,
    string ProjectKey,
    string ProjectName,
    string TaskKey,
    string TaskName,
    IReadOnlyList<TimesheetDayDto> Days,
    string? ReviewDecision);

public sealed record TimesheetWeekDto(
    Guid Id,
    Guid EmployeeId,
    string EmployeeName,
    string EmployeeCode,
    DateOnly WeekStart,
    string Status,
    decimal TotalHours,
    DateTime? SubmittedAtUtc,
    string? ReviewComment,
    bool ViewerCanReview,
    IReadOnlyList<TimesheetLineDto> Entries);

public sealed record SaveTimesheetLineRequest(
    string ProjectKey,
    string ProjectName,
    string TaskKey,
    string TaskName,
    IReadOnlyList<TimesheetDayDto> Days);

public sealed record SaveTimesheetRequest(
    DateOnly WeekStart,
    IReadOnlyList<SaveTimesheetLineRequest> Entries);

public sealed record DecideTimesheetRequest(
    IReadOnlyList<Guid> EntryIds,
    string Action,
    string Comment);
