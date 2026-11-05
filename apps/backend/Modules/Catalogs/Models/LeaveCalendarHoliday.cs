using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Catalogs.Models;

/// <summary>
/// Company-wide Leave Calendar holiday master entry.
/// Entered by admin in Settings -> Masters -> Leave Calendar.
/// Reflects across the Team Dashboard with its designated tag and color.
/// </summary>
public class LeaveCalendarHoliday : BaseEntity
{
    public DateOnly HolidayDate { get; set; }

    public string Name { get; set; } = string.Empty;

    public string Tag { get; set; } = "Public Holiday";

    public string Color { get; set; } = "#a6c63a";

    public string? Description { get; set; }

    public int Year { get; set; }
}

