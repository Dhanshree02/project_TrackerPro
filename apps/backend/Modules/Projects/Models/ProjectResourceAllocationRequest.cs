using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

public class ProjectResourceAllocationRequest : BaseEntity
{
    public Guid ProjectId { get; set; }
    public Project? Project { get; set; }

    public Guid EmployeeId { get; set; }
    public Employee? Employee { get; set; }

    public Guid? DepartmentId { get; set; }
    public MstDepartment? Department { get; set; }

    public string? SubDepartment { get; set; }
    public DateOnly AllocationStartDate { get; set; }
    public DateOnly AllocationEndDate { get; set; }
    public string Billability { get; set; } = "Billable";
    public bool IsTeamLead { get; set; }
    public string ResourceType { get; set; } = "Dedicated";
    public bool IsShadowTeam { get; set; }

    public string Status { get; set; } = "Pending";

    public Guid? RequestedByEmployeeId { get; set; }
    public string? RequestedByName { get; set; }

    public Guid? ApproverEmployeeId { get; set; }
    public string? ApproverName { get; set; }

    public string? CommentsJson { get; set; }
    public string? HistoryJson { get; set; }
}
