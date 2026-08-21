using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Resources.Models;

public class ExitedEmployee : BaseEntity
{
    public Guid OriginalEmployeeId { get; set; }
    public string EmployeeCode { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string? DepartmentName { get; set; }
    public string? DesignationName { get; set; }
    public string? WorkEmail { get; set; }
    public string? PersonalEmail { get; set; }
    public string? Phone { get; set; }
    public string? StatusAtExit { get; set; }
    public string? ExitType { get; set; }
    public string? ExitReason { get; set; }

    public DateOnly? ResignationDate { get; set; }
    public DateOnly? LastWorkingDay { get; set; }
    public string? ReasonForLeaving { get; set; }
    public string? NoticePeriodServed { get; set; }
    public string? ExitChecklistJson { get; set; }
    public string? AssetReturnJson { get; set; }
    public string? FinalSettlementJson { get; set; }
    public DateTime ExitedAtUtc { get; set; } = DateTime.UtcNow;
    public Guid? ExitedBy { get; set; }
}
