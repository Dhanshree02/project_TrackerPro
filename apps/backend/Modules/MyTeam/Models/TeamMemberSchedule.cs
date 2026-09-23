using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.MyTeam.Models;

public class TeamMemberSchedule : BaseEntity
{
    public Guid EmployeeId { get; set; }

    /// <summary>0 = Sunday … 6 = Saturday. Default Monday–Friday.</summary>
    public short[] WorkingDays { get; set; } = [1, 2, 3, 4, 5];

    public string? Notes { get; set; }

    public Employee? Employee { get; set; }
}
