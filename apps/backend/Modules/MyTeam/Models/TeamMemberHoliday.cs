using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.MyTeam.Models;

public class TeamMemberHoliday : BaseEntity
{
    public Guid EmployeeId { get; set; }

    public DateOnly HolidayDate { get; set; }

    public string Name { get; set; } = string.Empty;

    public string? Comment { get; set; }

    public Employee? Employee { get; set; }
}
