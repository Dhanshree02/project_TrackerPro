using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Resources.DTOs;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Resources.Validators;
using PMS.API.Infrastructure.Storage;
using PMS.API.Shared.Common.Wrappers;
using PMS.API.Shared.Exceptions;
using PMS.API.Shared.Validation;

namespace PMS.API.Modules.Resources.Services;

public sealed class EmployeeService(AppDbContext db, IFileStorageService storage, ICurrentUserService currentUser) : IEmployeeService
{
    private (string Email, string Name) GetCurrentPerformer()
    {
        var email = !string.IsNullOrWhiteSpace(currentUser.Email) ? currentUser.Email.Trim() : "admin@acme.co";
        var name = !string.IsNullOrWhiteSpace(currentUser.Name) ? currentUser.Name.Trim() : "Admin User";
        return (email, name);
    }

    public async Task<PagedResult<EmployeeListItemDto>> GetEmployeesAsync(
        int page,
        int perPage,
        string? search,
        Guid? departmentId,
        Guid? designationId,
        string? status,
        CancellationToken ct = default)
    {
        await CompleteEndedNoticePeriodsAsync(ct);

        var query = db.Employees
            .Include(e => e.Department)
            .Include(e => e.Designation)
            .Include(e => e.ReportingManager)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(search))
        {
            var needle = search.Trim().ToLowerInvariant();
            query = query.Where(e =>
                e.FirstName.ToLower().Contains(needle) ||
                e.LastName.ToLower().Contains(needle) ||
                e.EmployeeCode.ToLower().Contains(needle) ||
                e.WorkEmail.ToLower().Contains(needle) ||
                (e.PersonalEmail != null && e.PersonalEmail.ToLower().Contains(needle)) ||
                (e.Phone != null && e.Phone.ToLower().Contains(needle)) ||
                (e.AltPhone != null && e.AltPhone.ToLower().Contains(needle)) ||
                (e.EmergencyContact != null && e.EmergencyContact.ToLower().Contains(needle)) ||
                (e.Pan != null && e.Pan.ToLower().Contains(needle)) ||
                (e.BankAccount != null && e.BankAccount.ToLower().Contains(needle)) ||
                (e.PfUan != null && e.PfUan.ToLower().Contains(needle)) ||
                (e.Education != null && e.Education.ToLower().Contains(needle)) ||
                (e.Address != null && e.Address.ToLower().Contains(needle)) ||
                (e.BusinessUnit != null && e.BusinessUnit.ToLower().Contains(needle)) ||
                (e.Team != null && e.Team.ToLower().Contains(needle)) ||
                (e.PreviousCompany != null && e.PreviousCompany.ToLower().Contains(needle)));
        }

        if (departmentId.HasValue)
            query = query.Where(e => e.DepartmentId == departmentId.Value);
        if (designationId.HasValue)
            query = query.Where(e => e.DesignationId == designationId.Value);
        if (!string.IsNullOrWhiteSpace(status))
            query = query.Where(e => e.Status == status);

        var total = await query.CountAsync(ct);
        var items = await query
            .OrderBy(e => e.FirstName).ThenBy(e => e.LastName)
            .Skip((page - 1) * perPage)
            .Take(perPage)
            .Select(e => new EmployeeListItemDto(
                e.Id,
                e.EmployeeCode,
                e.FirstName + " " + e.LastName,
                e.WorkEmail,
                e.Department != null ? e.Department.Name : null,
                e.Designation != null ? e.Designation.Name : null,
                e.ReportingManager != null
                    ? e.ReportingManager.FirstName + " " + e.ReportingManager.LastName
                    : null,
                e.JoiningDate,
                e.WorkLocation,
                e.OfficeBranch,
                e.Category,
                e.ProjectSite,
                e.KpiScore,
                e.Status,
                e.CreatedAtUtc,
                e.PersonalEmail,
                e.Phone,
                e.AltPhone,
                e.EmergencyContact,
                e.EmergencyContactName,
                e.EmergencyContactRelation,
                e.Pan,
                e.BankAccount,
                e.PfUan,
                e.Education,
                e.Skills,
                e.Certifications,
                e.Languages,
                e.Role,
                e.BusinessUnit,
                e.Team,
                e.Experience,
                e.PreviousCompany,
                e.PmoDepartment,
                e.SubDepartment,
                e.BillableStatus,
                e.ClientLocation,
                e.ProjectType,
                e.ProjectAllocated,
                e.ClientEngManagerMapping))
            .ToListAsync(ct);

        return new PagedResult<EmployeeListItemDto>(items, page, perPage, total);
    }

    public async Task<EmployeeDetailDto?> GetEmployeeAsync(string idOrCode, CancellationToken ct = default)
    {
        await CompleteEndedNoticePeriodsAsync(ct);

        var entity = await BuildEmployeeLookupQuery(idOrCode)
            .Include(e => e.Department)
            .Include(e => e.Designation)
            .Include(e => e.NationalityRef)
            .Include(e => e.JobRole)
            .Include(e => e.SalaryBandRef)
            .Include(e => e.ReportingManager)
            .FirstOrDefaultAsync(ct);

        return entity is null ? null : MapDetail(entity);
    }

    public Task<byte[]> GetBulkSampleExcelAsync(CancellationToken ct = default) =>
        EmployeeBulkWorkbook.BuildSampleAsync(db, ct);

    public Task<EmployeeBulkUploadResult> BulkUploadAsync(Stream stream, CancellationToken ct = default) =>
        new EmployeeBulkImporter(db, this).ImportAsync(stream, ct);

    public Task<EmployeeDetailDto> CreateEmployeeAsync(CreateEmployeeRequest request, CancellationToken ct = default) =>
        CreateEmployeeAsync(request, checkIdentity: true, ct);

    public async Task<EmployeeDetailDto> CreateEmployeeAsync(
        CreateEmployeeRequest request,
        bool checkIdentity,
        CancellationToken ct)
    {
        var empCode = EmployeeCodeRules.Normalize(request.EmployeeCode);
        if (string.IsNullOrWhiteSpace(empCode))
        {
            var isIntern = request.EmploymentType?.Equals("intern", StringComparison.OrdinalIgnoreCase) == true;
            empCode = await GetNextEmployeeCodeAsync(isIntern, ct);
        }
        else if (!EmployeeCodeRules.IsValid(empCode))
        {
            throw EmployeeCodeRules.FormatException();
        }

        var employeeStatus = request.EmployeeStatusId.HasValue
            ? await db.EmployeeStatuses.FirstOrDefaultAsync(s => s.Id == request.EmployeeStatusId.Value, ct)
            : null;
        var bondDelivered = string.IsNullOrWhiteSpace(request.BondDelivered) ? null : request.BondDelivered.Trim();
        var bondDurationMonths = bondDelivered?.Equals("Yes", StringComparison.OrdinalIgnoreCase) == true
            ? request.BondDurationMonths
            : 0;
        var bondExpiryDate = request.BondExpiryDate
            ?? BondRules.ComputeBondExpiry(request.JoiningDate, bondDelivered, bondDurationMonths);
        var bondStatus = BondRules.ComputeBondStatus(bondDelivered, bondExpiryDate);
        var confirmationStatus = employeeStatus?.Name ?? request.ConfirmationStatus;
        var directoryStatus = request.Status
            ?? (string.Equals(confirmationStatus, "Active", StringComparison.OrdinalIgnoreCase) ? "Active" : "Inactive");

        var subDepartment = request.SubDepartment;
        if (string.IsNullOrWhiteSpace(subDepartment) && request.DesignationId.HasValue)
        {
            var desig = await db.Designations.FirstOrDefaultAsync(d => d.Id == request.DesignationId.Value, ct);
            if (desig != null && !string.IsNullOrWhiteSpace(desig.SubDepartment))
            {
                subDepartment = desig.SubDepartment;
            }
        }

        var entity = new Employee
        {
            EmployeeCode = empCode,
            FirstName = request.FirstName.Trim(),
            LastName = request.LastName.Trim(),
            WorkEmail = EmailRules.Normalize(request.WorkEmail).ToLowerInvariant(),
            PersonalEmail = EmailRules.NullIfEmpty(request.PersonalEmail),
            Phone = PhoneRules.NullIfEmpty(request.Phone),
            AltPhone = PhoneRules.NullIfEmpty(request.AltPhone),
            Gender = request.Gender,
            DateOfBirth = request.DateOfBirth,
            Address = request.Address,
            EmergencyContact = request.EmergencyContact,
            EmergencyContactName = request.EmergencyContactName,
            EmergencyContactRelation = request.EmergencyContactRelation,
            MaritalStatus = request.MaritalStatus,
            Nationality = request.Nationality,
            NationalityId = request.NationalityId ?? await ResolveNationalityIdAsync(request.Nationality, ct),
            DepartmentId = request.DepartmentId,
            DesignationId = request.DesignationId,
            Role = request.Role,
            JobRoleId = request.JobRoleId,
            ReportingManagerId = request.ReportingManagerId.HasValue
                ? await ResolveReportingManagerIdAsync(request.ReportingManagerId.Value, ct)
                : null,
            BusinessUnit = request.BusinessUnit,
            WorkLocation = request.WorkLocation,
            OfficeBranch = request.OfficeBranch,
            Category = request.Category,
            Team = request.Team,
            JoiningDate = request.JoiningDate,
            Status = directoryStatus,
            EmployeeStatusId = employeeStatus?.Id ?? request.EmployeeStatusId,
            ConfirmationStatus = confirmationStatus,
            ProbationStatus = request.ProbationStatus,
            Experience = request.Experience,
            PreviousCompany = request.PreviousCompany,
            EmploymentType = request.EmploymentType,
            ContractType = request.ContractType,
            BondDelivered = bondDelivered,
            BondDurationMonths = bondDurationMonths,
            BondExpiryDate = bondExpiryDate,
            BondStatus = bondStatus,
            NoticePeriod = request.NoticePeriod,
            ProjectSite = request.ProjectSite,
            AssetId = request.AssetId,
            ExitType = string.IsNullOrWhiteSpace(request.ExitType) ? "NA" : request.ExitType,
            ExitReason = string.IsNullOrWhiteSpace(request.ExitReason) ? "NA" : request.ExitReason,
            Education = request.Education,
            Skills = request.Skills ?? [],
            Certifications = request.Certifications ?? [],
            Languages = request.Languages ?? [],
            KpiScore = request.KpiScore,
            QuarterlyKpi = request.QuarterlyKpi,
            AnnualRating = request.AnnualRating,
            GoalCompletion = request.GoalCompletion,
            Attendance = request.Attendance,
            ReportingEfficiency = request.ReportingEfficiency,
            PromotionReadiness = request.PromotionReadiness,
            ManagerFeedback = request.ManagerFeedback,
            Pan = EmployeeIdentityGuard.NormalizePan(request.Pan),
            Aadhaar = EmployeeIdentityGuard.NormalizeAadhaar(request.Aadhaar),
            BankAccount = request.BankAccount,
            SalaryBand = request.SalaryBand,
            SalaryBandId = request.SalaryBandId,
            ProbationPeriod = request.ProbationPeriod,
            PfUan = EmployeeIdentityGuard.NormalizeUan(request.PfUan),
            TaxRegime = request.TaxRegime,
            ComplianceStatus = request.ComplianceStatus,
            PmoDepartment = request.PmoDepartment,
            SubDepartment = subDepartment,
            BillableStatus = request.BillableStatus,
            ClientLocation = request.ClientLocation,
            ProjectType = request.ProjectType,
            ProjectAllocated = request.ProjectAllocated,
            ClientEngManagerMapping = request.ClientEngManagerMapping,
            GradDegree = request.GradDegree,
            GradYear = request.GradYear,
            PostGradDegree = request.PostGradDegree,
            PostGradYear = request.PostGradYear,
            ExpType = request.ExpType,
            PriorTotalExp = request.PriorTotalExp,
            PriorRelevantExp = request.PriorRelevantExp,
        };

        if (checkIdentity)
            await EmployeeIdentityGuard.EnsureUniqueAsync(db, EmployeeIdentityGuard.FromEntity(entity), null, ct);

        await ApplyCatalogNamesAsync(entity, ct);

        db.Employees.Add(entity);
        try
        {
            await db.SaveChangesAsync(ct);

            var (performerEmail, performerName) = GetCurrentPerformer();
            db.EmployeeActivityLogs.Add(new EmployeeActivityLog
            {
                Id = Guid.NewGuid(),
                EmployeeId = entity.Id,
                Action = "Created",
                PerformedByEmail = performerEmail,
                PerformedByName = performerName,
                Details = $"Profile created for {entity.FirstName} {entity.LastName} ({entity.EmployeeCode})",
                CreatedAtUtc = DateTime.UtcNow
            });
            await db.SaveChangesAsync(ct);
            await SyncLinkedUserAsync(entity, ct);
        }
        catch (DbUpdateException ex) when (IsUniqueViolation(ex))
        {
            throw new ConflictException(
                "Duplicate employee data. Work email, personal email, phone number, PAN, Aadhaar, and UAN must be unique.");
        }

        return (await GetEmployeeAsync(entity.Id.ToString(), ct))!;
    }

    public async Task<EmployeeDetailDto?> UpdateEmployeeAsync(string idOrCode, UpdateEmployeeRequest request, CancellationToken ct = default)
    {
        var entity = await BuildEmployeeLookupQuery(idOrCode).FirstOrDefaultAsync(ct);
        if (entity is null) return null;

        var changes = new List<string>();

        var previousCode = entity.EmployeeCode;
        if (!string.IsNullOrWhiteSpace(request.EmployeeCode))
        {
            var newCode = EmployeeCodeRules.Normalize(request.EmployeeCode);
            if (!EmployeeCodeRules.IsValid(newCode))
                throw EmployeeCodeRules.FormatException();
            if (entity.EmployeeCode != newCode) changes.Add("TK ID");
            entity.EmployeeCode = newCode;
        }

        if (request.FirstName is not null)
        {
            var v = request.FirstName.Trim();
            if (entity.FirstName != v) changes.Add("First Name");
            entity.FirstName = v;
        }
        if (request.LastName is not null)
        {
            var v = request.LastName.Trim();
            if (entity.LastName != v) changes.Add("Last Name");
            entity.LastName = v;
        }
        if (request.WorkEmail is not null)
        {
            var v = EmailRules.Normalize(request.WorkEmail).ToLowerInvariant();
            if (entity.WorkEmail != v) changes.Add("Work Email");
            entity.WorkEmail = v;
        }
        if (request.PersonalEmail is not null)
        {
            var v = EmailRules.NullIfEmpty(request.PersonalEmail);
            if (entity.PersonalEmail != v) changes.Add("Personal Email");
            entity.PersonalEmail = v;
        }
        if (request.Phone is not null)
        {
            var v = PhoneRules.NullIfEmpty(request.Phone);
            if (entity.Phone != v) changes.Add("Phone");
            entity.Phone = v;
        }
        if (request.AltPhone is not null)
        {
            var v = PhoneRules.NullIfEmpty(request.AltPhone);
            if (entity.AltPhone != v) changes.Add("Alt Phone");
            entity.AltPhone = v;
        }
        if (request.Gender is not null)
        {
            if (entity.Gender != request.Gender) changes.Add("Gender");
            entity.Gender = request.Gender;
        }
        if (request.DateOfBirth.HasValue)
        {
            if (entity.DateOfBirth != request.DateOfBirth) changes.Add("Date of Birth");
            entity.DateOfBirth = request.DateOfBirth;
        }
        if (request.Address is not null)
        {
            if (entity.Address != request.Address) changes.Add("Address");
            entity.Address = request.Address;
        }
        if (request.EmergencyContact is not null)
        {
            if (entity.EmergencyContact != request.EmergencyContact) changes.Add("Emergency Contact");
            entity.EmergencyContact = request.EmergencyContact;
        }
        if (request.EmergencyContactName is not null)
        {
            if (entity.EmergencyContactName != request.EmergencyContactName) changes.Add("Emergency Contact Name");
            entity.EmergencyContactName = request.EmergencyContactName;
        }
        if (request.EmergencyContactRelation is not null)
        {
            if (entity.EmergencyContactRelation != request.EmergencyContactRelation) changes.Add("Emergency Contact Relation");
            entity.EmergencyContactRelation = request.EmergencyContactRelation;
        }
        if (request.MaritalStatus is not null)
        {
            if (entity.MaritalStatus != request.MaritalStatus) changes.Add("Marital Status");
            entity.MaritalStatus = request.MaritalStatus;
        }
        if (request.Nationality is not null)
        {
            if (entity.Nationality != request.Nationality) changes.Add("Nationality");
            entity.Nationality = request.Nationality;
        }
        if (request.NationalityId.HasValue)
        {
            if (entity.NationalityId != request.NationalityId) changes.Add("Nationality");
            entity.NationalityId = request.NationalityId;
        }
        if (request.DepartmentId.HasValue)
        {
            if (entity.DepartmentId != request.DepartmentId) changes.Add("Department");
            entity.DepartmentId = request.DepartmentId;
        }
        if (request.DesignationId.HasValue)
        {
            if (entity.DesignationId != request.DesignationId) changes.Add("Designation");
            entity.DesignationId = request.DesignationId;
        }
        if (request.Role is not null)
        {
            if (entity.Role != request.Role) changes.Add("Role");
            entity.Role = request.Role;
        }
        if (request.JobRoleId.HasValue)
        {
            if (entity.JobRoleId != request.JobRoleId) changes.Add("Job Role");
            entity.JobRoleId = request.JobRoleId;
        }
        if (request.ReportingManagerId.HasValue)
        {
            var res = await ResolveReportingManagerIdAsync(request.ReportingManagerId.Value, ct);
            if (entity.ReportingManagerId != res) changes.Add("Reporting Manager");
            entity.ReportingManagerId = res;
        }
        if (request.BusinessUnit is not null)
        {
            if (entity.BusinessUnit != request.BusinessUnit) changes.Add("Business Unit");
            entity.BusinessUnit = request.BusinessUnit;
        }
        if (request.WorkLocation is not null)
        {
            if (entity.WorkLocation != request.WorkLocation) changes.Add("Work Location");
            entity.WorkLocation = request.WorkLocation;
        }
        if (request.OfficeBranch is not null)
        {
            if (entity.OfficeBranch != request.OfficeBranch) changes.Add("Office Branch");
            entity.OfficeBranch = request.OfficeBranch;
        }
        if (request.Category is not null)
        {
            if (entity.Category != request.Category) changes.Add("Category");
            entity.Category = request.Category;
        }
        if (request.Team is not null)
        {
            if (entity.Team != request.Team) changes.Add("Team");
            entity.Team = request.Team;
        }
        if (!string.IsNullOrWhiteSpace(request.Department))
        {
            var dept = await db.Departments.FirstOrDefaultAsync(d => d.Name == request.Department, ct);
            if (dept is not null && entity.DepartmentId != dept.Id)
            {
                changes.Add("Department");
                entity.DepartmentId = dept.Id;
            }
        }
        else if (request.DepartmentId.HasValue && entity.DepartmentId != request.DepartmentId)
        {
            changes.Add("Department");
            entity.DepartmentId = request.DepartmentId;
        }
        if (!string.IsNullOrWhiteSpace(request.Designation))
        {
            var desig = await db.Designations.FirstOrDefaultAsync(d => d.Name == request.Designation, ct);
            if (desig is not null && entity.DesignationId != desig.Id)
            {
                changes.Add("Designation");
                entity.DesignationId = desig.Id;
            }
        }
        else if (request.DesignationId.HasValue && entity.DesignationId != request.DesignationId)
        {
            changes.Add("Designation");
            entity.DesignationId = request.DesignationId;
        }
        if (request.JoiningDate.HasValue)
        {
            if (entity.JoiningDate != request.JoiningDate) changes.Add("Joining Date");
            entity.JoiningDate = request.JoiningDate;
        }
        if (request.Status is not null)
        {
            if (entity.Status != request.Status) changes.Add("Status");
            entity.Status = request.Status;
        }
        if (request.ConfirmationStatus is not null)
        {
            if (entity.ConfirmationStatus != request.ConfirmationStatus) changes.Add("Confirmation Status");
            entity.ConfirmationStatus = request.ConfirmationStatus;
        }
        if (request.ProbationStatus is not null)
        {
            if (entity.ProbationStatus != request.ProbationStatus) changes.Add("Probation Status");
            entity.ProbationStatus = request.ProbationStatus;
        }
        if (request.Experience is not null)
        {
            if (entity.Experience != request.Experience) changes.Add("Experience");
            entity.Experience = request.Experience;
        }
        if (request.PreviousCompany is not null)
        {
            if (entity.PreviousCompany != request.PreviousCompany) changes.Add("Previous Company");
            entity.PreviousCompany = request.PreviousCompany;
        }
        if (request.EmploymentType is not null)
        {
            if (entity.EmploymentType != request.EmploymentType) changes.Add("Employment Type");
            entity.EmploymentType = request.EmploymentType;
        }
        if (request.ContractType is not null)
        {
            if (entity.ContractType != request.ContractType) changes.Add("Contract Type");
            entity.ContractType = request.ContractType;
        }
        if (request.BondStatus is not null)
        {
            if (entity.BondStatus != request.BondStatus) changes.Add("Bond Status");
            entity.BondStatus = request.BondStatus;
        }
        if (request.NoticePeriod is not null)
        {
            if (entity.NoticePeriod != request.NoticePeriod) changes.Add("Notice Period");
            entity.NoticePeriod = request.NoticePeriod;
        }
        if (request.ProjectSite is not null)
        {
            if (entity.ProjectSite != request.ProjectSite) changes.Add("Location (Onsite)");
            entity.ProjectSite = request.ProjectSite;
        }
        if (request.AssetId is not null)
        {
            if (entity.AssetId != request.AssetId) changes.Add("Asset ID");
            entity.AssetId = request.AssetId;
        }
        if (request.ExitType is not null)
        {
            if (entity.ExitType != request.ExitType) changes.Add("Exit Type");
            entity.ExitType = request.ExitType;
        }
        if (request.ExitReason is not null)
        {
            if (entity.ExitReason != request.ExitReason) changes.Add("Exit Reason");
            entity.ExitReason = request.ExitReason;
        }
        if (request.Education is not null)
        {
            if (entity.Education != request.Education) changes.Add("Education");
            entity.Education = request.Education;
        }
        if (request.Skills is not null) entity.Skills = request.Skills;
        if (request.Certifications is not null) entity.Certifications = request.Certifications;
        if (request.Languages is not null) entity.Languages = request.Languages;
        if (request.KpiScore.HasValue)
        {
            if (entity.KpiScore != request.KpiScore) changes.Add("KPI Score");
            entity.KpiScore = request.KpiScore;
        }
        if (request.QuarterlyKpi.HasValue)
        {
            if (entity.QuarterlyKpi != request.QuarterlyKpi) changes.Add("Quarterly KPI");
            entity.QuarterlyKpi = request.QuarterlyKpi;
        }
        if (request.AnnualRating.HasValue)
        {
            if (entity.AnnualRating != request.AnnualRating) changes.Add("Annual Rating");
            entity.AnnualRating = request.AnnualRating;
        }
        if (request.GoalCompletion.HasValue)
        {
            if (entity.GoalCompletion != request.GoalCompletion) changes.Add("Goal Completion");
            entity.GoalCompletion = request.GoalCompletion;
        }
        if (request.Attendance.HasValue)
        {
            if (entity.Attendance != request.Attendance) changes.Add("Attendance");
            entity.Attendance = request.Attendance;
        }
        if (request.ReportingEfficiency.HasValue)
        {
            if (entity.ReportingEfficiency != request.ReportingEfficiency) changes.Add("Reporting Efficiency");
            entity.ReportingEfficiency = request.ReportingEfficiency;
        }
        if (request.PromotionReadiness is not null)
        {
            if (entity.PromotionReadiness != request.PromotionReadiness) changes.Add("Promotion Readiness");
            entity.PromotionReadiness = request.PromotionReadiness;
        }
        if (request.ManagerFeedback is not null)
        {
            if (entity.ManagerFeedback != request.ManagerFeedback) changes.Add("Manager Feedback");
            entity.ManagerFeedback = request.ManagerFeedback;
        }
        if (request.Pan is not null)
        {
            var v = EmployeeIdentityGuard.NormalizePan(request.Pan);
            if (entity.Pan != v) changes.Add("PAN");
            entity.Pan = v;
        }
        if (request.Aadhaar is not null)
        {
            var v = EmployeeIdentityGuard.NormalizeAadhaar(request.Aadhaar);
            if (entity.Aadhaar != v) changes.Add("Aadhaar");
            entity.Aadhaar = v;
        }
        if (request.BankAccount is not null)
        {
            if (entity.BankAccount != request.BankAccount) changes.Add("Bank Account");
            entity.BankAccount = request.BankAccount;
        }
        if (request.SalaryBand is not null)
        {
            if (entity.SalaryBand != request.SalaryBand) changes.Add("Salary Band");
            entity.SalaryBand = request.SalaryBand;
        }
        if (request.SalaryBandId.HasValue)
        {
            if (entity.SalaryBandId != request.SalaryBandId) changes.Add("Salary Band");
            entity.SalaryBandId = request.SalaryBandId;
        }
        if (request.ProbationPeriod is not null)
        {
            if (entity.ProbationPeriod != request.ProbationPeriod) changes.Add("Probation Period");
            entity.ProbationPeriod = request.ProbationPeriod;
        }
        if (request.PfUan is not null)
        {
            var v = EmployeeIdentityGuard.NormalizeUan(request.PfUan);
            if (entity.PfUan != v) changes.Add("PF UAN");
            entity.PfUan = v;
        }
        if (request.TaxRegime is not null)
        {
            if (entity.TaxRegime != request.TaxRegime) changes.Add("Tax Regime");
            entity.TaxRegime = request.TaxRegime;
        }
        if (request.ComplianceStatus is not null)
        {
            if (entity.ComplianceStatus != request.ComplianceStatus) changes.Add("Compliance Status");
            entity.ComplianceStatus = request.ComplianceStatus;
        }
        if (request.PmoDepartment is not null)
        {
            if (entity.PmoDepartment != request.PmoDepartment) changes.Add("PMO Department");
            entity.PmoDepartment = request.PmoDepartment;
        }
        if (request.SubDepartment is not null)
        {
            if (entity.SubDepartment != request.SubDepartment) changes.Add("Sub Department");
            entity.SubDepartment = request.SubDepartment;
        }
        else if (request.DesignationId.HasValue || (string.IsNullOrWhiteSpace(entity.SubDepartment) && entity.DesignationId.HasValue))
        {
            var targetDesigId = request.DesignationId ?? entity.DesignationId;
            if (targetDesigId.HasValue)
            {
                var desig = await db.Designations.FirstOrDefaultAsync(d => d.Id == targetDesigId.Value, ct);
                if (desig != null && !string.IsNullOrWhiteSpace(desig.SubDepartment))
                {
                    entity.SubDepartment = desig.SubDepartment;
                }
            }
        }
        if (request.BillableStatus is not null)
        {
            if (entity.BillableStatus != request.BillableStatus) changes.Add("Billable Status");
            entity.BillableStatus = request.BillableStatus;
        }
        if (request.ClientLocation is not null)
        {
            if (entity.ClientLocation != request.ClientLocation) changes.Add("Client Location");
            entity.ClientLocation = request.ClientLocation;
        }
        if (request.ProjectType is not null)
        {
            if (entity.ProjectType != request.ProjectType) changes.Add("Project Type");
            entity.ProjectType = request.ProjectType;
        }
        if (request.ProjectAllocated is not null)
        {
            if (entity.ProjectAllocated != request.ProjectAllocated) changes.Add("Project Allocated");
            entity.ProjectAllocated = request.ProjectAllocated;
        }
        if (request.ClientEngManagerMapping is not null)
        {
            if (entity.ClientEngManagerMapping != request.ClientEngManagerMapping) changes.Add("Client EM Mapping");
            entity.ClientEngManagerMapping = request.ClientEngManagerMapping;
        }
        if (request.GradDegree is not null)
        {
            if (entity.GradDegree != request.GradDegree) changes.Add("Graduation Degree");
            entity.GradDegree = request.GradDegree;
        }
        if (request.GradYear is not null)
        {
            if (entity.GradYear != request.GradYear) changes.Add("Graduation Year");
            entity.GradYear = request.GradYear;
        }
        if (request.PostGradDegree is not null)
        {
            if (entity.PostGradDegree != request.PostGradDegree) changes.Add("Post Graduation Degree");
            entity.PostGradDegree = request.PostGradDegree;
        }
        if (request.PostGradYear is not null)
        {
            if (entity.PostGradYear != request.PostGradYear) changes.Add("Post Graduation Year");
            entity.PostGradYear = request.PostGradYear;
        }
        if (request.ExpType is not null)
        {
            if (entity.ExpType != request.ExpType) changes.Add("Experience Type");
            entity.ExpType = request.ExpType;
        }
        if (request.PriorTotalExp is not null)
        {
            if (entity.PriorTotalExp != request.PriorTotalExp) changes.Add("Prior Total Experience");
            entity.PriorTotalExp = request.PriorTotalExp;
        }
        if (request.PriorRelevantExp is not null)
        {
            if (entity.PriorRelevantExp != request.PriorRelevantExp) changes.Add("Prior Relevant Experience");
            entity.PriorRelevantExp = request.PriorRelevantExp;
        }
        if (request.BondDelivered is not null)
        {
            if (entity.BondDelivered != request.BondDelivered) changes.Add("Bond Delivered");
            entity.BondDelivered = request.BondDelivered;
        }
        if (request.BondDurationMonths.HasValue)
        {
            if (entity.BondDurationMonths != request.BondDurationMonths) changes.Add("Bond Duration");
            entity.BondDurationMonths = request.BondDurationMonths;
        }
        if (request.BondExpiryDate.HasValue)
        {
            if (entity.BondExpiryDate != request.BondExpiryDate) changes.Add("Bond Expiry Date");
            entity.BondExpiryDate = request.BondExpiryDate;
        }
        if (request.EmployeeStatusId.HasValue)
        {
            if (entity.EmployeeStatusId != request.EmployeeStatusId) changes.Add("Employee Status");
            entity.EmployeeStatusId = request.EmployeeStatusId;
        }

        await EmployeeIdentityGuard.EnsureUniqueAsync(db, EmployeeIdentityGuard.FromEntity(entity), entity.Id, ct);
        await ApplyCatalogNamesAsync(entity, ct);
        try
        {
            await db.SaveChangesAsync(ct);

            var (performerEmail, performerName) = GetCurrentPerformer();
            var distinctChanges = changes.Distinct().ToList();
            var changeDesc = distinctChanges.Count > 0
                ? $"Updated: {string.Join(", ", distinctChanges.Take(6))}{(distinctChanges.Count > 6 ? $" (+{distinctChanges.Count - 6} more)" : "")}"
                : "Profile details updated";

            db.EmployeeActivityLogs.Add(new EmployeeActivityLog
            {
                Id = Guid.NewGuid(),
                EmployeeId = entity.Id,
                Action = "Updated",
                PerformedByEmail = performerEmail,
                PerformedByName = performerName,
                Details = changeDesc,
                CreatedAtUtc = DateTime.UtcNow
            });
            await db.SaveChangesAsync(ct);
            await SyncLinkedUserAsync(entity, ct);
        }
        catch (DbUpdateException ex) when (IsUniqueViolation(ex))
        {
            throw new ConflictException(
                "Duplicate employee data. TK ID, work email, personal email, phone number, PAN, Aadhaar, and UAN must be unique.");
        }

        // Uploaded documents live under storage/employees/{code}; keep them reachable after a TK ID change.
        if (!string.Equals(previousCode, entity.EmployeeCode, StringComparison.Ordinal))
            storage.MoveEmployeeDocuments(previousCode, entity.EmployeeCode);

        return await GetEmployeeAsync(entity.Id.ToString(), ct);
    }


    public async Task<ExitedEmployeeDto?> OffboardEmployeeAsync(string idOrCode, OffboardEmployeeRequest request, CancellationToken ct = default)
    {
        var employee = await BuildEmployeeLookupQuery(idOrCode)
            .Include(e => e.Department)
            .Include(e => e.Designation)
            .FirstOrDefaultAsync(ct);
        if (employee is null) return null;

        var existingExit = await db.ExitedEmployees
            .FirstOrDefaultAsync(x => x.OriginalEmployeeId == employee.Id, ct);

        await using var tx = await db.Database.BeginTransactionAsync(ct);

        var statusAtExit = employee.Status;
        employee.Status = "Notice Period";
        employee.ExitType = request.ExitType ?? employee.ExitType;
        employee.ExitReason = request.ExitReason ?? employee.ExitReason;
        if (!string.IsNullOrWhiteSpace(request.NoticePeriodServed))
            employee.NoticePeriod = request.NoticePeriodServed;

        ExitedEmployee exited;
        if (existingExit is null)
        {
            exited = new ExitedEmployee
            {
                OriginalEmployeeId = employee.Id,
                EmployeeCode = employee.EmployeeCode,
                FullName = employee.FirstName + " " + employee.LastName,
                DepartmentName = employee.Department?.Name,
                DesignationName = employee.Designation?.Name,
                WorkEmail = employee.WorkEmail,
                PersonalEmail = employee.PersonalEmail,
                Phone = employee.Phone,
                StatusAtExit = statusAtExit,
                ExitType = request.ExitType ?? employee.ExitType,
                ExitReason = request.ExitReason ?? employee.ExitReason,
                ResignationDate = request.ResignationDate,
                LastWorkingDay = request.LastWorkingDay,
                ReasonForLeaving = request.ReasonForLeaving,
                NoticePeriodServed = request.NoticePeriodServed,
                ExitChecklistJson = request.ExitChecklistJson,
                AssetReturnJson = request.AssetReturnJson,
                FinalSettlementJson = request.FinalSettlementJson,
                ClearanceCompleted = request.ClearanceCompleted
                    ?? (request.LastWorkingDay is not null && request.LastWorkingDay < TodayInIst()),
                ExitRating = ClampExitRating(request.ExitRating ?? employee.AnnualRating),
                ExitedAtUtc = DateTime.UtcNow,
            };
            db.ExitedEmployees.Add(exited);
        }
        else
        {
            existingExit.ResignationDate = request.ResignationDate ?? existingExit.ResignationDate;
            existingExit.LastWorkingDay = request.LastWorkingDay ?? existingExit.LastWorkingDay;
            existingExit.ReasonForLeaving = request.ReasonForLeaving ?? existingExit.ReasonForLeaving;
            existingExit.NoticePeriodServed = request.NoticePeriodServed ?? existingExit.NoticePeriodServed;
            existingExit.ExitType = request.ExitType ?? existingExit.ExitType;
            existingExit.ExitReason = request.ExitReason ?? existingExit.ExitReason;
            if (request.ClearanceCompleted.HasValue)
                existingExit.ClearanceCompleted = request.ClearanceCompleted.Value;
            var rating = ClampExitRating(request.ExitRating ?? employee.AnnualRating);
            if (rating.HasValue)
                existingExit.ExitRating = rating;
            exited = existingExit;
        }

        // Stay in the directory through last working day; hide from the next calendar day.
        if (request.LastWorkingDay is null || request.LastWorkingDay < TodayInIst())
            db.Employees.Remove(employee);

        var (offboardPerformerEmail, offboardPerformerName) = GetCurrentPerformer();
        db.EmployeeActivityLogs.Add(new EmployeeActivityLog
        {
            Id = Guid.NewGuid(),
            EmployeeId = employee.Id,
            Action = "Offboarded",
            PerformedByEmail = offboardPerformerEmail,
            PerformedByName = offboardPerformerName,
            Details = $"Offboarded employee (Reason: {request.ReasonForLeaving ?? "N/A"}, Last Working Day: {request.LastWorkingDay?.ToString("yyyy-MM-dd") ?? "N/A"})",
            CreatedAtUtc = DateTime.UtcNow
        });

        await db.SaveChangesAsync(ct);
        await tx.CommitAsync(ct);

        return MapExited(exited);
    }

    public async Task<PagedResult<ExitedEmployeeDto>> GetExitedEmployeesAsync(int page, int perPage, string? search, CancellationToken ct = default)
    {
        await CompleteEndedNoticePeriodsAsync(ct);

        var query = db.ExitedEmployees.AsQueryable();
        if (!string.IsNullOrWhiteSpace(search))
        {
            var needle = search.Trim().ToLowerInvariant();
            query = query.Where(e =>
                e.EmployeeCode.ToLower().Contains(needle) ||
                e.FullName.ToLower().Contains(needle) ||
                (e.DepartmentName != null && e.DepartmentName.ToLower().Contains(needle)) ||
                (e.ReasonForLeaving != null && e.ReasonForLeaving.ToLower().Contains(needle)) ||
                (e.ExitReason != null && e.ExitReason.ToLower().Contains(needle)));
        }

        var total = await query.CountAsync(ct);
        var items = await query.OrderByDescending(e => e.ExitedAtUtc)
            .Skip((page - 1) * perPage)
            .Take(perPage)
            .Select(e => new ExitedEmployeeDto(
                e.Id,
                e.OriginalEmployeeId,
                e.EmployeeCode,
                e.FullName,
                e.LastWorkingDay,
                e.ExitType,
                e.ExitReason,
                e.ExitedAtUtc,
                e.DepartmentName,
                e.DesignationName,
                e.ReasonForLeaving,
                e.ClearanceCompleted,
                e.ExitRating))
            .ToListAsync(ct);

        return new PagedResult<ExitedEmployeeDto>(items, page, perPage, total);
    }

    public async Task<IReadOnlyList<MetaOptionDto>> GetDepartmentsAsync(CancellationToken ct = default)
    {
        return await db.Departments
            .Where(d => d.IsActive)
            .OrderBy(d => d.Name)
            .Select(d => new MetaOptionDto(d.Id, d.Code, d.Name, null))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<MetaOptionDto>> GetDesignationsAsync(
        Guid? departmentId,
        CancellationToken ct = default)
    {
        var query = db.Designations.Where(d => d.IsActive);
        if (departmentId is not null)
            query = query.Where(d => d.DepartmentId == departmentId);

        return await query
            .OrderBy(d => d.Name)
            .Select(d => new MetaOptionDto(d.Id, d.Code, d.Name, d.DepartmentId, d.DefaultRoleId))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<MetaOptionDto>> GetNationalitiesAsync(CancellationToken ct = default)
    {
        return await db.Nationalities
            .Where(n => n.IsActive)
            .OrderBy(n => n.Name)
            .Select(n => new MetaOptionDto(n.Id, n.Code, n.Name, null))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<MetaOptionDto>> GetJobRolesAsync(
        Guid? designationId,
        CancellationToken ct = default)
    {
        var query = db.JobRoles.Where(r => r.IsActive);
        if (designationId is not null)
            query = query.Where(r => r.DesignationId == designationId);

        return await query
            .OrderBy(r => r.Name)
            .Select(r => new MetaOptionDto(r.Id, r.Code, r.Name, r.DesignationId))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<MetaOptionDto>> GetSalaryBandsAsync(CancellationToken ct = default)
    {
        return await db.SalaryBands
            .Where(b => b.IsActive)
            .OrderBy(b => b.Code)
            .Select(b => new MetaOptionDto(b.Id, b.Code, b.Name, null))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<MetaOptionDto>> GetEmailDomainsAsync(CancellationToken ct = default)
    {
        return await db.EmailDomains
            .Where(d => d.IsActive)
            .OrderBy(d => d.SortOrder)
            .ThenBy(d => d.DomainName)
            .Select(d => new MetaOptionDto(d.Id, d.DomainName, d.DisplayName, null))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<MetaOptionDto>> GetReportingManagersAsync(CancellationToken ct = default)
    {
        var list = await db.ReportingManagers
            .Where(m => m.IsActive)
            .OrderBy(m => m.SortOrder)
            .ThenBy(m => m.Name)
            .ToListAsync(ct);

        var results = new List<MetaOptionDto>(list.Count);
        foreach (var m in list)
        {
            var empId = m.EmployeeId;
            if (!empId.HasValue || !await db.Employees.AnyAsync(e => e.Id == empId.Value && e.DeletedAtUtc == null, ct))
            {
                var nameLower = m.Name.Trim().ToLower();
                var matched = await db.Employees.FirstOrDefaultAsync(e =>
                    e.DeletedAtUtc == null &&
                    ((e.FirstName + " " + e.LastName).ToLower() == nameLower
                     || e.FirstName.ToLower() == nameLower
                     || (!string.IsNullOrEmpty(m.Email) && e.WorkEmail.ToLower() == m.Email.ToLower())), ct);

                if (matched is not null)
                {
                    empId = matched.Id;
                    m.EmployeeId = matched.Id;
                    await db.SaveChangesAsync(ct);
                }
            }
            results.Add(new MetaOptionDto(empId ?? m.Id, m.Code, m.Name, m.Id));
        }

        return results;
    }

    public async Task<IReadOnlyList<MetaOptionDto>> GetBusinessUnitsAsync(CancellationToken ct = default)
    {
        return await db.BusinessUnits
            .Where(b => b.IsActive)
            .OrderBy(b => b.SortOrder)
            .ThenBy(b => b.Name)
            .Select(b => new MetaOptionDto(b.Id, b.Code, b.Name, null))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<MetaOptionDto>> GetWorkLocationsAsync(CancellationToken ct = default)
    {
        return await db.WorkLocations
            .Where(w => w.IsActive)
            .OrderBy(w => w.SortOrder)
            .ThenBy(w => w.Name)
            .Select(w => new MetaOptionDto(w.Id, w.Code, w.Name, null))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<MetaOptionDto>> GetOfficesAsync(Guid? workLocationId = null, CancellationToken ct = default)
    {
        var query = db.Offices.Where(o => o.IsActive);
        if (workLocationId.HasValue)
        {
            query = query.Where(o => o.WorkLocationId == workLocationId.Value);
        }

        return await query
            .OrderBy(o => o.SortOrder)
            .ThenBy(o => o.Name)
            .Select(o => new MetaOptionDto(o.Id, o.Code, o.Name, o.WorkLocationId))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<MetaOptionDto>> GetEmployeeStatusesAsync(
        bool onboardingOnly = false,
        CancellationToken ct = default)
    {
        var query = db.EmployeeStatuses.Where(s => s.IsActive);
        if (onboardingOnly)
            query = query.Where(s => s.AllowOnboarding);

        return await query
            .OrderBy(s => s.SortOrder)
            .ThenBy(s => s.Name)
            .Select(s => new MetaOptionDto(s.Id, s.Code, s.Name, null))
            .ToListAsync(ct);
    }

    public async Task<MetaOptionDto> CreateBusinessUnitAsync(string name, CancellationToken ct = default)
    {
        var trimmed = RequireName(name);
        var existing = await db.BusinessUnits.FirstOrDefaultAsync(b => b.Name.ToLower() == trimmed.ToLower(), ct);
        if (existing is not null)
            return new MetaOptionDto(existing.Id, existing.Code, existing.Name, null);

        var entity = new MstBusinessUnit
        {
            Code = await UniqueCodeAsync(Slug(trimmed), c => db.BusinessUnits.AnyAsync(b => b.Code == c, ct), 80),
            Name = trimmed,
            IsActive = true,
            SortOrder = 999,
        };
        db.BusinessUnits.Add(entity);
        await db.SaveChangesAsync(ct);
        return new MetaOptionDto(entity.Id, entity.Code, entity.Name, null);
    }

    public async Task<MetaOptionDto> CreateWorkLocationAsync(string name, CancellationToken ct = default)
    {
        var trimmed = RequireName(name);
        var existing = await db.WorkLocations.FirstOrDefaultAsync(w => w.Name.ToLower() == trimmed.ToLower(), ct);
        if (existing is not null)
            return new MetaOptionDto(existing.Id, existing.Code, existing.Name, null);

        var entity = new MstWorkLocation
        {
            Code = await UniqueCodeAsync(Slug(trimmed), c => db.WorkLocations.AnyAsync(w => w.Code == c, ct), 80),
            Name = trimmed,
            IsActive = true,
            SortOrder = 999,
        };
        db.WorkLocations.Add(entity);
        await db.SaveChangesAsync(ct);
        return new MetaOptionDto(entity.Id, entity.Code, entity.Name, null);
    }

    public async Task<MetaOptionDto> CreateOfficeAsync(string name, Guid? workLocationId = null, CancellationToken ct = default)
    {
        var trimmed = RequireName(name);
        var query = db.Offices.Where(o => o.Name.ToLower() == trimmed.ToLower());
        if (workLocationId.HasValue)
        {
            query = query.Where(o => o.WorkLocationId == workLocationId.Value);
        }

        var existing = await query.FirstOrDefaultAsync(ct);
        if (existing is not null)
            return new MetaOptionDto(existing.Id, existing.Code, existing.Name, existing.WorkLocationId);

        var prefix = workLocationId.HasValue
            ? (await db.WorkLocations.Where(w => w.Id == workLocationId.Value).Select(w => w.Code).FirstOrDefaultAsync(ct) ?? "off")
            : "off";

        var entity = new MstOffice
        {
            Code = await UniqueCodeAsync(Truncate($"{prefix}_{Slug(trimmed)}", 80), c => db.Offices.AnyAsync(o => o.Code == c, ct)),
            Name = trimmed,
            WorkLocationId = workLocationId,
            IsActive = true,
            SortOrder = 999,
        };
        db.Offices.Add(entity);
        await db.SaveChangesAsync(ct);
        return new MetaOptionDto(entity.Id, entity.Code, entity.Name, entity.WorkLocationId);
    }

    public async Task<MetaOptionDto> CreateReportingManagerAsync(string name, string? designation = null, CancellationToken ct = default)
    {
        var trimmed = RequireName(name);
        var existing = await db.ReportingManagers.FirstOrDefaultAsync(m => m.Name.ToLower() == trimmed.ToLower(), ct);
        if (existing is not null)
        {
            var resolvedId = await ResolveReportingManagerIdAsync(existing.Id, ct);
            return new MetaOptionDto(resolvedId ?? existing.Id, existing.Code, existing.Name, existing.Id);
        }

        var entity = new MstReportingManager
        {
            Code = await UniqueCodeAsync(Slug(trimmed), c => db.ReportingManagers.AnyAsync(m => m.Code == c, ct), 80),
            Name = trimmed,
            Designation = string.IsNullOrWhiteSpace(designation) ? null : designation.Trim(),
            IsActive = true,
            SortOrder = 999,
        };
        db.ReportingManagers.Add(entity);
        await db.SaveChangesAsync(ct);

        var empId = await ResolveReportingManagerIdAsync(entity.Id, ct);
        return new MetaOptionDto(empId ?? entity.Id, entity.Code, entity.Name, entity.Id);
    }

    public async Task<MetaOptionDto> CreateDepartmentAsync(string name, CancellationToken ct = default)
    {
        var trimmed = RequireName(name);
        var existing = await db.Departments.FirstOrDefaultAsync(d => d.Name == trimmed, ct);
        if (existing is not null)
            return new MetaOptionDto(existing.Id, existing.Code, existing.Name, null);

        var entity = new MstDepartment
        {
            Code = await UniqueCodeAsync(Slug(trimmed), c => db.Departments.AnyAsync(d => d.Code == c, ct), 50),
            Name = trimmed,
            IsActive = true,
        };
        db.Departments.Add(entity);
        await db.SaveChangesAsync(ct);
        return new MetaOptionDto(entity.Id, entity.Code, entity.Name, null);
    }

    public async Task<MetaOptionDto> CreateDesignationAsync(
        string name,
        Guid departmentId,
        Guid? defaultRoleId = null,
        CancellationToken ct = default)
    {
        var trimmed = RequireName(name);
        var dept = await db.Departments.FirstOrDefaultAsync(d => d.Id == departmentId, ct)
            ?? throw new NotFoundException("Department not found.");

        var existing = await db.Designations.FirstOrDefaultAsync(
            d => d.DepartmentId == departmentId && d.Name == trimmed, ct);
        if (existing is not null)
        {
            if (defaultRoleId.HasValue && existing.DefaultRoleId != defaultRoleId)
            {
                existing.DefaultRoleId = defaultRoleId;
                await db.SaveChangesAsync(ct);
            }
            return new MetaOptionDto(existing.Id, existing.Code, existing.Name, existing.DepartmentId, existing.DefaultRoleId);
        }

        var entity = new MstDesignation
        {
            Code = await UniqueCodeAsync(
                Truncate($"{dept.Code}_{Slug(trimmed)}", 80),
                c => db.Designations.AnyAsync(d => d.Code == c, ct)),
            Name = trimmed,
            DepartmentId = departmentId,
            DefaultRoleId = defaultRoleId,
            IsActive = true,
        };
        db.Designations.Add(entity);
        await db.SaveChangesAsync(ct);
        return new MetaOptionDto(entity.Id, entity.Code, entity.Name, entity.DepartmentId, entity.DefaultRoleId);
    }

    public async Task<MetaOptionDto> CreateJobRoleAsync(
        string name,
        Guid designationId,
        CancellationToken ct = default)
    {
        var trimmed = RequireName(name);
        var designation = await db.Designations.FirstOrDefaultAsync(d => d.Id == designationId, ct)
            ?? throw new NotFoundException("Designation not found.");

        var existing = await db.JobRoles.FirstOrDefaultAsync(
            r => r.DesignationId == designationId && r.Name == trimmed, ct);
        if (existing is not null)
            return new MetaOptionDto(existing.Id, existing.Code, existing.Name, existing.DesignationId);

        var entity = new MstRole
        {
            Code = await UniqueCodeAsync(
                Truncate($"{designation.Code}_{Slug(trimmed)}", 80),
                c => db.JobRoles.AnyAsync(r => r.Code == c, ct)),
            Name = trimmed,
            DesignationId = designationId,
            IsActive = true,
        };
        db.JobRoles.Add(entity);
        await db.SaveChangesAsync(ct);
        return new MetaOptionDto(entity.Id, entity.Code, entity.Name, entity.DesignationId);
    }

    public async Task<IReadOnlyList<EmployeeLookupDto>> LookupEmployeesAsync(IReadOnlyList<Guid> ids, CancellationToken ct = default)
    {
        if (ids.Count == 0) return [];
        return await db.Employees
            .Include(e => e.Department)
            .Include(e => e.Designation)
            .Where(e => ids.Contains(e.Id))
            .Select(e => new EmployeeLookupDto(
                e.Id,
                e.EmployeeCode,
                e.FirstName + " " + e.LastName,
                e.Department != null ? e.Department.Name : null,
                e.Designation != null ? e.Designation.Name : null,
                e.Status,
                e.WorkEmail))
            .ToListAsync(ct);
    }

    public async Task<EmployeeLookupDto?> GetEmployeeSummaryAsync(string idOrCode, CancellationToken ct = default)
    {
        return await BuildEmployeeLookupQuery(idOrCode)
            .Include(e => e.Department)
            .Include(e => e.Designation)
            .Select(e => new EmployeeLookupDto(
                e.Id,
                e.EmployeeCode,
                e.FirstName + " " + e.LastName,
                e.Department != null ? e.Department.Name : null,
                e.Designation != null ? e.Designation.Name : null,
                e.Status,
                e.WorkEmail))
            .FirstOrDefaultAsync(ct);
    }

    private IQueryable<Employee> BuildEmployeeLookupQuery(string idOrCode)
    {
        var key = idOrCode.Trim();
        if (Guid.TryParse(key, out var id))
        {
            return db.Employees.Where(e => e.Id == id);
        }

        return db.Employees.Where(e => e.EmployeeCode == key);
    }

    private async Task CompleteEndedNoticePeriodsAsync(CancellationToken ct)
    {
        var today = TodayInIst();
        var dueExits = await db.ExitedEmployees
            .Where(x => x.LastWorkingDay != null && x.LastWorkingDay < today)
            .ToListAsync(ct);
        if (dueExits.Count == 0) return;

        foreach (var row in dueExits.Where(x => !x.ClearanceCompleted))
            row.ClearanceCompleted = true;

        var dueIds = dueExits.Select(x => x.OriginalEmployeeId).Distinct().ToList();
        var stillListed = await db.Employees.Where(e => dueIds.Contains(e.Id)).ToListAsync(ct);
        foreach (var employee in stillListed)
            db.Employees.Remove(employee);
        await db.SaveChangesAsync(ct);
    }

    private static DateOnly TodayInIst()
    {
        TimeZoneInfo tz;
        try
        {
            tz = TimeZoneInfo.FindSystemTimeZoneById("India Standard Time");
        }
        catch (TimeZoneNotFoundException)
        {
            tz = TimeZoneInfo.FindSystemTimeZoneById("Asia/Kolkata");
        }

        return DateOnly.FromDateTime(TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, tz));
    }

    private static decimal? ClampExitRating(decimal? value)
    {
        if (value is null or <= 0) return null;
        return Math.Clamp(value.Value, 0.1m, 5.0m);
    }

    private static ExitedEmployeeDto MapExited(ExitedEmployee e) => new(
        e.Id,
        e.OriginalEmployeeId,
        e.EmployeeCode,
        e.FullName,
        e.LastWorkingDay,
        e.ExitType,
        e.ExitReason,
        e.ExitedAtUtc,
        e.DepartmentName,
        e.DesignationName,
        e.ReasonForLeaving,
        e.ClearanceCompleted,
        e.ExitRating);

    private static EmployeeDetailDto MapDetail(Employee e) => new(
        e.Id,
        e.EmployeeCode,
        e.FirstName,
        e.LastName,
        e.WorkEmail,
        e.PersonalEmail,
        e.Phone,
        e.AltPhone,
        e.Gender,
        e.DateOfBirth,
        e.Address,
        e.EmergencyContact,
        e.EmergencyContactName,
        e.EmergencyContactRelation,
        e.MaritalStatus,
        e.NationalityRef?.Name ?? e.Nationality,
        e.Department?.Name,
        e.Designation?.Name,
        e.JobRole?.Name ?? e.Role,
        e.ReportingManagerId,
        e.ReportingManager is null ? null : e.ReportingManager.FirstName + " " + e.ReportingManager.LastName,
        e.BusinessUnit,
        e.WorkLocation,
        e.OfficeBranch,
        e.Category,
        e.Team,
        e.JoiningDate,
        e.Status,
        e.ConfirmationStatus,
        e.ProbationStatus ?? e.ProbationPeriod,
        e.Experience,
        e.PreviousCompany,
        e.EmploymentType,
        e.ContractType,
        e.BondStatus,
        e.NoticePeriod,
        e.ProjectSite,
        e.AssetId,
        e.ExitType,
        e.ExitReason,
        e.Education,
        e.Skills,
        e.Certifications,
        e.Languages,
        e.KpiScore,
        e.QuarterlyKpi,
        e.AnnualRating,
        e.GoalCompletion,
        e.Attendance,
        e.ReportingEfficiency,
        e.PromotionReadiness,
        e.ManagerFeedback,
        e.Pan,
        e.Aadhaar,
        e.BankAccount,
        e.SalaryBandRef?.Name ?? e.SalaryBand,
        e.PfUan,
        e.TaxRegime,
        e.ComplianceStatus,
        e.PmoDepartment,
        e.SubDepartment,
        e.BillableStatus,
        e.ClientLocation,
        e.ProjectType,
        e.ProjectAllocated,
        e.ClientEngManagerMapping,
        e.GradDegree,
        e.GradYear,
        e.PostGradDegree,
        e.PostGradYear,
        e.ExpType,
        e.PriorTotalExp,
        e.PriorRelevantExp,
        e.BondDelivered,
        e.BondDurationMonths,
        e.BondExpiryDate,
        e.EmployeeStatusId,
        e.DepartmentId,
        e.DesignationId,
        e.JobRoleId);

    private async Task ApplyCatalogNamesAsync(Employee entity, CancellationToken ct)
    {
        if (entity.NationalityId is Guid nationalityId)
        {
            var nationality = await db.Nationalities.FirstOrDefaultAsync(n => n.Id == nationalityId, ct);
            if (nationality is not null) entity.Nationality = nationality.Name;
        }
        else if (!string.IsNullOrWhiteSpace(entity.Nationality))
        {
            entity.NationalityId = await ResolveNationalityIdAsync(entity.Nationality, ct);
        }

        if (entity.DesignationId is Guid desigId)
        {
            var desig = await db.Designations.Include(d => d.DefaultRole).FirstOrDefaultAsync(d => d.Id == desigId, ct);
            if (desig?.DefaultRole is not null && (string.IsNullOrWhiteSpace(entity.Role) || entity.Role == "Employee" || entity.Role == desig.Name))
            {
                entity.Role = desig.DefaultRole.Name;
            }
        }

        if (entity.SalaryBandId is Guid bandId)
        {
            var band = await db.SalaryBands.FirstOrDefaultAsync(b => b.Id == bandId, ct);
            if (band is not null) entity.SalaryBand = band.Name;
        }
    }

    private async Task SyncLinkedUserAsync(Employee entity, CancellationToken ct)
    {
        var user = await db.Users.FirstOrDefaultAsync(
            u => u.Email == entity.WorkEmail || u.EmployeeId == entity.EmployeeCode, ct);
        if (user is null) return;

        bool updated = false;

        string? deptName = entity.Department?.Name;
        if (deptName is null && entity.DepartmentId is Guid deptId)
        {
            var dept = await db.Departments.FirstOrDefaultAsync(d => d.Id == deptId, ct);
            deptName = dept?.Name;
        }

        string? desigName = entity.Designation?.Name;
        if (desigName is null && entity.DesignationId is Guid desigId)
        {
            var desig = await db.Designations.FirstOrDefaultAsync(d => d.Id == desigId, ct);
            desigName = desig?.Name;
        }

        if (!string.IsNullOrWhiteSpace(deptName) && user.Department != deptName)
        {
            user.Department = deptName;
            updated = true;
        }
        if (!string.IsNullOrWhiteSpace(desigName) && user.Designation != desigName)
        {
            user.Designation = desigName;
            updated = true;
        }
        if (!string.IsNullOrWhiteSpace(entity.Role))
        {
            var rbacRole = await db.Roles.FirstOrDefaultAsync(r => r.Name == entity.Role, ct);
            if (rbacRole is not null && user.RoleId != rbacRole.Id)
            {
                user.RoleId = rbacRole.Id;
                updated = true;
            }
        }
        if (updated)
        {
            await db.SaveChangesAsync(ct);
        }
    }

    private async Task<Guid?> ResolveNationalityIdAsync(string? name, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(name)) return null;
        var trimmed = name.Trim();
        var existing = await db.Nationalities.FirstOrDefaultAsync(
            n => n.Name == trimmed || n.Code == trimmed, ct);
        return existing?.Id;
    }

    private async Task<Guid?> ResolveReportingManagerIdAsync(Guid reportingManagerId, CancellationToken ct)
    {
        // 1. Check if the GUID directly matches an active Employee in employees table
        if (await db.Employees.AnyAsync(e => e.Id == reportingManagerId && e.DeletedAtUtc == null, ct))
        {
            return reportingManagerId;
        }

        // 2. Check if the GUID is an MstReportingManager Id
        var mst = await db.ReportingManagers.FirstOrDefaultAsync(m => m.Id == reportingManagerId, ct);
        if (mst is null)
        {
            return null;
        }

        // 3. If the catalog entry already links to an active employee in employees table
        if (mst.EmployeeId.HasValue && await db.Employees.AnyAsync(e => e.Id == mst.EmployeeId.Value && e.DeletedAtUtc == null, ct))
        {
            return mst.EmployeeId.Value;
        }

        // 4. Try matching an existing employee by full name or email
        var nameLower = mst.Name.Trim().ToLower();
        var matched = await db.Employees.FirstOrDefaultAsync(e =>
            e.DeletedAtUtc == null &&
            ((e.FirstName + " " + e.LastName).ToLower() == nameLower
             || (e.FirstName.ToLower() == nameLower)
             || (!string.IsNullOrEmpty(mst.Email) && e.WorkEmail.ToLower() == mst.Email.ToLower())), ct);

        if (matched is not null)
        {
            mst.EmployeeId = matched.Id;
            await db.SaveChangesAsync(ct);
            return matched.Id;
        }

        // 5. Create a manager Employee record so FK_employees_employees_ReportingManagerId is satisfied
        var parts = mst.Name.Trim().Split(' ', 2, StringSplitOptions.RemoveEmptyEntries);
        var fName = parts.Length > 0 ? parts[0] : mst.Name.Trim();
        var lName = parts.Length > 1 ? parts[1] : "";
        var code = await GetNextEmployeeCodeAsync(false, ct);
        var workEmail = !string.IsNullOrWhiteSpace(mst.Email) ? mst.Email.Trim().ToLowerInvariant() : $"{Slug(mst.Name)}@talakunchi.com";
        if (await db.Employees.AnyAsync(e => e.WorkEmail.ToLower() == workEmail.ToLower(), ct))
        {
            workEmail = $"{Slug(mst.Name)}.{Guid.NewGuid().ToString("N")[..4]}@talakunchi.com";
        }

        var managerEmp = new Employee
        {
            EmployeeCode = code,
            FirstName = fName,
            LastName = lName,
            WorkEmail = workEmail,
            Role = mst.Designation ?? "Reporting Manager",
            Status = "Active",
            ConfirmationStatus = "Active",
            Category = "Permanent - Without Bond",
            Skills = [],
            Certifications = [],
            Languages = ["English"],
            CreatedAtUtc = DateTime.UtcNow
        };
        db.Employees.Add(managerEmp);
        await db.SaveChangesAsync(ct);

        mst.EmployeeId = managerEmp.Id;
        await db.SaveChangesAsync(ct);

        return managerEmp.Id;
    }

    private static bool IsUniqueViolation(DbUpdateException ex) =>
        ex.InnerException is Npgsql.PostgresException { SqlState: "23505" };

    private static string RequireName(string name)
    {
        var trimmed = name?.Trim() ?? string.Empty;
        if (trimmed.Length == 0)
            throw new ConflictException("Name is required.");
        if (trimmed.Length > 150)
            throw new ConflictException("Name must be 150 characters or less.");
        return trimmed;
    }

    private static string Slug(string value)
    {
        var chars = value.Trim().ToLowerInvariant()
            .Select(c => char.IsLetterOrDigit(c) ? c : '_')
            .ToArray();
        var slug = new string(chars);
        while (slug.Contains("__", StringComparison.Ordinal))
            slug = slug.Replace("__", "_", StringComparison.Ordinal);
        return slug.Trim('_');
    }

    public async Task<string> GetNextEmployeeCodeAsync(bool isIntern, CancellationToken ct = default)
    {
        var prefix = isIntern ? "TKI-" : "TK-";
        var codes = await db.Employees
            .IgnoreQueryFilters()
            .Where(e => e.EmployeeCode.StartsWith(prefix))
            .Select(e => e.EmployeeCode)
            .ToListAsync(ct);

        var maxNum = 0;
        foreach (var c in codes)
        {
            var part = c[prefix.Length..];
            if (int.TryParse(part, out var n) && n > maxNum)
                maxNum = n;
        }

        return $"{prefix}{(maxNum + 1):D4}";
    }

    private static string Truncate(string value, int max) =>
        value.Length <= max ? value : value[..max].Trim('_');

    private static async Task<string> UniqueCodeAsync(
        string baseCode,
        Func<string, Task<bool>> exists,
        int maxLength = 80)
    {
        var code = string.IsNullOrWhiteSpace(baseCode) ? "item" : Truncate(baseCode, maxLength);
        var n = 2;
        while (await exists(code))
        {
            var suffix = $"_{n}";
            var prefix = Truncate(baseCode, Math.Max(1, maxLength - suffix.Length));
            code = prefix + suffix;
            n++;
        }
        return code;
    }

    public async Task<IReadOnlyList<MetaOptionDto>> GetCertificationsAsync(CancellationToken ct = default)
    {
        return await db.Certifications
            .Where(c => c.IsActive)
            .OrderBy(c => c.Name)
            .Select(c => new MetaOptionDto(c.Id, c.Code, c.Name, null))
            .ToListAsync(ct);
    }

    public async Task<MetaOptionDto> CreateCertificationAsync(string name, CancellationToken ct = default)
    {
        var trimmed = RequireName(name);
        var existing = await db.Certifications.FirstOrDefaultAsync(c => c.Name == trimmed, ct);
        if (existing is not null)
            return new MetaOptionDto(existing.Id, existing.Code, existing.Name, null);

        var entity = new MstCertification
        {
            Code = await UniqueCodeAsync(Slug(trimmed), c => db.Certifications.AnyAsync(x => x.Code == c, ct), 100),
            Name = trimmed,
            IsActive = true,
        };
        db.Certifications.Add(entity);
        await db.SaveChangesAsync(ct);
        return new MetaOptionDto(entity.Id, entity.Code, entity.Name, null);
    }

    public async Task<IReadOnlyList<MetaOptionDto>> GetGraduationDegreesAsync(CancellationToken ct = default)
    {
        return await db.GraduationDegrees
            .Where(g => g.IsActive)
            .OrderBy(g => g.Name)
            .Select(g => new MetaOptionDto(g.Id, g.Code, g.Name, null))
            .ToListAsync(ct);
    }

    public async Task<MetaOptionDto> CreateGraduationDegreeAsync(string name, CancellationToken ct = default)
    {
        var trimmed = RequireName(name);
        var existing = await db.GraduationDegrees.FirstOrDefaultAsync(g => g.Name == trimmed, ct);
        if (existing is not null)
            return new MetaOptionDto(existing.Id, existing.Code, existing.Name, null);

        var entity = new MstGraduationDegree
        {
            Code = await UniqueCodeAsync(Slug(trimmed), c => db.GraduationDegrees.AnyAsync(x => x.Code == c, ct), 100),
            Name = trimmed,
            IsActive = true,
        };
        db.GraduationDegrees.Add(entity);
        await db.SaveChangesAsync(ct);
        return new MetaOptionDto(entity.Id, entity.Code, entity.Name, null);
    }

    public async Task<IReadOnlyList<MetaOptionDto>> GetPostGraduationDegreesAsync(CancellationToken ct = default)
    {
        return await db.PostGraduationDegrees
            .Where(p => p.IsActive)
            .OrderBy(p => p.Name)
            .Select(p => new MetaOptionDto(p.Id, p.Code, p.Name, null))
            .ToListAsync(ct);
    }

    public async Task<MetaOptionDto> CreatePostGraduationDegreeAsync(string name, CancellationToken ct = default)
    {
        var trimmed = RequireName(name);
        var existing = await db.PostGraduationDegrees.FirstOrDefaultAsync(p => p.Name == trimmed, ct);
        if (existing is not null)
            return new MetaOptionDto(existing.Id, existing.Code, existing.Name, null);

        var entity = new MstPostGraduationDegree
        {
            Code = await UniqueCodeAsync(Slug(trimmed), c => db.PostGraduationDegrees.AnyAsync(x => x.Code == c, ct), 100),
            Name = trimmed,
            IsActive = true,
        };
        db.PostGraduationDegrees.Add(entity);
        await db.SaveChangesAsync(ct);
        return new MetaOptionDto(entity.Id, entity.Code, entity.Name, null);
    }

    public async Task<IReadOnlyList<EmployeeActivityLogDto>> GetEmployeeLogsAsync(string idOrCode, CancellationToken ct = default)
    {
        var employee = await BuildEmployeeLookupQuery(idOrCode)
            .Select(e => new { e.Id, e.EmployeeCode, e.FirstName, e.LastName, e.CreatedAtUtc, e.CreatedBy })
            .FirstOrDefaultAsync(ct);

        if (employee is null) return [];

        var logs = await db.EmployeeActivityLogs
            .AsNoTracking()
            .Where(l => l.EmployeeId == employee.Id)
            .OrderByDescending(l => l.CreatedAtUtc)
            .Select(l => new EmployeeActivityLogDto(
                l.Id,
                l.EmployeeId,
                l.Action,
                l.PerformedByEmail,
                l.PerformedByName,
                l.Details,
                l.CreatedAtUtc))
            .ToListAsync(ct);

        if (!logs.Any(l => string.Equals(l.Action, "Created", StringComparison.OrdinalIgnoreCase)))
        {
            string creatorEmail = "admin@acme.co";
            string creatorName = "Admin User";

            if (employee.CreatedBy.HasValue)
            {
                var creator = await db.Users.AsNoTracking().FirstOrDefaultAsync(u => u.Id == employee.CreatedBy.Value, ct);
                if (creator != null)
                {
                    creatorEmail = creator.Email;
                    creatorName = creator.Name;
                }
            }

            logs.Add(new EmployeeActivityLogDto(
                Guid.NewGuid(),
                employee.Id,
                "Created",
                creatorEmail,
                creatorName,
                $"Profile created for {employee.FirstName} {employee.LastName} ({employee.EmployeeCode})",
                employee.CreatedAtUtc));
        }

        return logs;
    }
}