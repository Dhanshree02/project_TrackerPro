using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Timesheets.Models;

/// <summary>Hours and the employee's comment for one day of a timesheet line. DayIndex 0 is Monday.</summary>
public class TimesheetEntryDay : BaseEntity
{
    public Guid TimesheetEntryId { get; set; }

    public short DayIndex { get; set; }

    public decimal Hours { get; set; }

    public string? Comment { get; set; }

    public TimesheetEntry? TimesheetEntry { get; set; }
}
