using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Catalogs.Models;

/// <summary>
/// Company-wide Holiday Calendar holiday master entry.
/// Entered by admin in Settings -> Masters -> Holiday Calendar.
/// Reflects across the Team Dashboard.
/// </summary>
public class LeaveCalendarHoliday : BaseEntity
{
    public DateOnly HolidayDate { get; set; }

    public string Name { get; set; } = string.Empty;

    public int Year { get; set; }
}
