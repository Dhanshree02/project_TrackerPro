using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.MyTeam.Models;

public class TeamDayEntry : BaseEntity
{
    public Guid EmployeeId { get; set; }

    public DateOnly WorkDate { get; set; }

    /// <summary>onsite, wfh, or leave. Null means attendance was cleared.</summary>
    public string? Attendance { get; set; }

    /// <summary>Morning, Afternoon, Night, or General. Null reads as General.</summary>
    public string? Shift { get; set; }

    public Employee? Employee { get; set; }
}
