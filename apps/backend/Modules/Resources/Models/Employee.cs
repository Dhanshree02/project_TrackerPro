using PMS.API.Modules.Users.Models;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Resources.Models;

public class Employee : BaseEntity
{
    public string EmployeeCode { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string WorkEmail { get; set; } = string.Empty;
    public string? PersonalEmail { get; set; }
    public string? Phone { get; set; }
    public string? AltPhone { get; set; }
    public string? Gender { get; set; }
    public DateOnly? DateOfBirth { get; set; }
    public string? Address { get; set; }
    public string? EmergencyContact { get; set; }
    public string? EmergencyContactName { get; set; }
    public string? MaritalStatus { get; set; }
    public string? Nationality { get; set; }

    public Guid? NationalityId { get; set; }

    public Guid? DepartmentId { get; set; }
    public Guid? DesignationId { get; set; }
    public string? Role { get; set; }
    public Guid? JobRoleId { get; set; }
    public Guid? ReportingManagerId { get; set; }
    public string? BusinessUnit { get; set; }
    public string? WorkLocation { get; set; }
    public string? OfficeBranch { get; set; }
    public string? Category { get; set; }
    public string? Team { get; set; }
    public string? ProjectSite { get; set; }

    public DateOnly? JoiningDate { get; set; }
    public string? Status { get; set; }
    public string? ConfirmationStatus { get; set; }
    public string? ProbationStatus { get; set; }
    public string? ProbationPeriod { get; set; }
    public string? Experience { get; set; }
    public string? PreviousCompany { get; set; }
    public string? EmploymentType { get; set; }
    public string? ContractType { get; set; }
    public string? BondStatus { get; set; }
    public string? NoticePeriod { get; set; }
    public string? AssetId { get; set; }
    public string? ExitType { get; set; }
    public string? ExitReason { get; set; }

    public string? Education { get; set; }
    public List<string> Skills { get; set; } = [];
    public List<string> Certifications { get; set; } = [];
    public List<string> Languages { get; set; } = [];

    public decimal? KpiScore { get; set; }
    public decimal? QuarterlyKpi { get; set; }
    public decimal? AnnualRating { get; set; }
    public decimal? GoalCompletion { get; set; }
    public decimal? Attendance { get; set; }
    public decimal? ReportingEfficiency { get; set; }
    public string? PromotionReadiness { get; set; }
    public string? ManagerFeedback { get; set; }

    public string? Pan { get; set; }
    public string? Aadhaar { get; set; }
    public string? BankAccount { get; set; }
    public string? SalaryBand { get; set; }
    public Guid? SalaryBandId { get; set; }
    public string? PfUan { get; set; }
    public string? TaxRegime { get; set; }
    public string? ComplianceStatus { get; set; }

    public Guid? UserId { get; set; }
    public User? User { get; set; }
    public MstDepartment? Department { get; set; }
    public MstDesignation? Designation { get; set; }
    public MstNationality? NationalityRef { get; set; }
    public MstRole? JobRole { get; set; }
    public MstSalaryBand? SalaryBandRef { get; set; }
    public Employee? ReportingManager { get; set; }
}
