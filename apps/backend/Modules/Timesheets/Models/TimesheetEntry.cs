using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Timesheets.Models;

/// <summary>
/// One project and task line on a weekly timesheet.
/// Project and task are stored as the ids the screen sends today.
/// Foreign keys are added after the project tables are merged.
/// </summary>
public class TimesheetEntry : BaseEntity
{
    public Guid TimesheetWeekId { get; set; }

    public string ProjectKey { get; set; } = "";

    public string TaskKey { get; set; } = "";

    public string ProjectName { get; set; } = "";

    public string TaskName { get; set; } = "";

    /// <summary>approved, rejected, or change_requested. Null until a manager decides this line.</summary>
    public string? ReviewDecision { get; set; }

    public TimesheetWeek? TimesheetWeek { get; set; }

    public ICollection<TimesheetEntryDay> Days { get; set; } = [];
}
