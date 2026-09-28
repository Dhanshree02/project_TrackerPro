using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// One employee/resource assigned to a project's Project Team or Shadow Team.
/// Department/SubDepartment are snapshotted from the employee at assignment time
/// but DepartmentId is always taken from the employee record, never trusted from clients.
/// </summary>
public class ProjectTeamMember : BaseEntity
{
    public Guid ProjectId { get; set; }

    public Project? Project { get; set; }

    public Guid EmployeeId { get; set; }

    public Employee? Employee { get; set; }

    /// <summary>FK to mst_departments — copied from the employee at assign time.</summary>
    public Guid? DepartmentId { get; set; }

    public MstDepartment? Department { get; set; }

    /// <summary>
    /// Employee sub-department text (HR stores this as a string, not a master FK).
    /// </summary>
    public string? SubDepartment { get; set; }

    public DateOnly AllocationStartDate { get; set; }

    public DateOnly AllocationEndDate { get; set; }

    /// <summary>"Billable" or "Non-Billable".</summary>
    public string Billability { get; set; } = "Billable";

    public bool IsTeamLead { get; set; }

    /// <summary>"Dedicated" or "Shared Resource".</summary>
    public string ResourceType { get; set; } = "Dedicated";

    /// <summary>
    /// When true this row belongs to Shadow Team (interns).
    /// When false it belongs to Project Team (non-interns).
    /// </summary>
    public bool IsShadowTeam { get; set; }
}
