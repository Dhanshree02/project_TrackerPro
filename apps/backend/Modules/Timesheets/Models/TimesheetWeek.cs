using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Timesheets.Models;

/// <summary>One employee's timesheet for a Monday-start week.</summary>
public class TimesheetWeek : BaseEntity
{
    public Guid EmployeeId { get; set; }

    public DateOnly WeekStart { get; set; }

    /// <summary>draft, submitted, approved, rejected, or change_requested.</summary>
    public string Status { get; set; } = "draft";

    public decimal TotalHours { get; set; }

    public DateTime? SubmittedAtUtc { get; set; }

    public Guid? ReviewedByEmployeeId { get; set; }

    public DateTime? ReviewedAtUtc { get; set; }

    public string? ReviewComment { get; set; }

    public Employee? Employee { get; set; }

    public ICollection<TimesheetEntry> Entries { get; set; } = [];
}
