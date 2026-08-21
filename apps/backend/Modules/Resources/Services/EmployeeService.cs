using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Resources.DTOs;
using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Common.Wrappers;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.Resources.Services;

public sealed class EmployeeService(AppDbContext db) : IEmployeeService
{
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
                e.WorkEmail.ToLower().Contains(needle));
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
                e.CreatedAtUtc))
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

    public async Task<EmployeeDetailDto> CreateEmployeeAsync(CreateEmployeeRequest request, CancellationToken ct = default)
    {
        var entity = new Employee
        {
            EmployeeCode = request.EmployeeCode.Trim(),
            FirstName = request.FirstName.Trim(),
            LastName = request.LastName.Trim(),
            WorkEmail = request.WorkEmail.Trim().ToLowerInvariant(),
            PersonalEmail = request.PersonalEmail,
            Phone = request.Phone,
            AltPhone = request.AltPhone,
            Gender = request.Gender,
            DateOfBirth = request.DateOfBirth,
            Address = request.Address,
            EmergencyContact = request.EmergencyContact,
            MaritalStatus = request.MaritalStatus,
            Nationality = request.Nationality,
            NationalityId = request.NationalityId ?? await ResolveNationalityIdAsync(request.Nationality, ct),
            DepartmentId = request.DepartmentId,
            DesignationId = request.DesignationId,
            Role = request.Role,
            JobRoleId = request.JobRoleId,
            ReportingManagerId = request.ReportingManagerId,
            BusinessUnit = request.BusinessUnit,
            WorkLocation = request.WorkLocation,
            OfficeBranch = request.OfficeBranch,
            Category = request.Category,
            Team = request.Team,
            JoiningDate = request.JoiningDate,
            Status = request.Status,
            ConfirmationStatus = request.ConfirmationStatus,
            ProbationStatus = request.ProbationStatus,
            Experience = request.Experience,
            PreviousCompany = request.PreviousCompany,
            EmploymentType = request.EmploymentType,
            ContractType = request.ContractType,
            BondStatus = request.BondStatus,
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
            Pan = request.Pan,
            BankAccount = request.BankAccount,
            SalaryBand = request.SalaryBand,
            SalaryBandId = request.SalaryBandId,
            ProbationPeriod = request.ProbationPeriod,
            PfUan = request.PfUan,
            TaxRegime = request.TaxRegime,
            ComplianceStatus = request.ComplianceStatus,
        };

        await ApplyCatalogNamesAsync(entity, ct);

        db.Employees.Add(entity);
        await db.SaveChangesAsync(ct);
        return (await GetEmployeeAsync(entity.Id.ToString(), ct))!;
    }

    public async Task<EmployeeDetailDto?> UpdateEmployeeAsync(string idOrCode, UpdateEmployeeRequest request, CancellationToken ct = default)
    {
        var entity = await BuildEmployeeLookupQuery(idOrCode).FirstOrDefaultAsync(ct);
        if (entity is null) return null;

        if (request.FirstName is not null) entity.FirstName = request.FirstName.Trim();
        if (request.LastName is not null) entity.LastName = request.LastName.Trim();
        if (request.WorkEmail is not null) entity.WorkEmail = request.WorkEmail.Trim().ToLowerInvariant();
        if (request.PersonalEmail is not null) entity.PersonalEmail = request.PersonalEmail;
        if (request.Phone is not null) entity.Phone = request.Phone;
        if (request.AltPhone is not null) entity.AltPhone = request.AltPhone;
        if (request.Gender is not null) entity.Gender = request.Gender;
        if (request.DateOfBirth.HasValue) entity.DateOfBirth = request.DateOfBirth;
        if (request.Address is not null) entity.Address = request.Address;
        if (request.EmergencyContact is not null) entity.EmergencyContact = request.EmergencyContact;
        if (request.MaritalStatus is not null) entity.MaritalStatus = request.MaritalStatus;
        if (request.Nationality is not null) entity.Nationality = request.Nationality;
        if (request.NationalityId.HasValue) entity.NationalityId = request.NationalityId;
        if (request.DepartmentId.HasValue) entity.DepartmentId = request.DepartmentId;
        if (request.DesignationId.HasValue) entity.DesignationId = request.DesignationId;
        if (request.Role is not null) entity.Role = request.Role;
        if (request.JobRoleId.HasValue) entity.JobRoleId = request.JobRoleId;
        if (request.ReportingManagerId.HasValue) entity.ReportingManagerId = request.ReportingManagerId;
        if (request.BusinessUnit is not null) entity.BusinessUnit = request.BusinessUnit;
        if (request.WorkLocation is not null) entity.WorkLocation = request.WorkLocation;
        if (request.OfficeBranch is not null) entity.OfficeBranch = request.OfficeBranch;
        if (request.Category is not null) entity.Category = request.Category;
        if (request.Team is not null) entity.Team = request.Team;
        if (!string.IsNullOrWhiteSpace(request.Department))
        {
            var dept = await db.Departments.FirstOrDefaultAsync(d => d.Name == request.Department, ct);
            if (dept is not null) entity.DepartmentId = dept.Id;
        }
        else if (request.DepartmentId.HasValue) entity.DepartmentId = request.DepartmentId;
        if (!string.IsNullOrWhiteSpace(request.Designation))
        {
            var desig = await db.Designations.FirstOrDefaultAsync(d => d.Name == request.Designation, ct);
            if (desig is not null) entity.DesignationId = desig.Id;
        }
        else if (request.DesignationId.HasValue) entity.DesignationId = request.DesignationId;
        if (request.JoiningDate.HasValue) entity.JoiningDate = request.JoiningDate;
        if (request.Status is not null) entity.Status = request.Status;
        if (request.ConfirmationStatus is not null) entity.ConfirmationStatus = request.ConfirmationStatus;
        if (request.ProbationStatus is not null) entity.ProbationStatus = request.ProbationStatus;
        if (request.Experience is not null) entity.Experience = request.Experience;
        if (request.PreviousCompany is not null) entity.PreviousCompany = request.PreviousCompany;
        if (request.EmploymentType is not null) entity.EmploymentType = request.EmploymentType;
        if (request.ContractType is not null) entity.ContractType = request.ContractType;
        if (request.BondStatus is not null) entity.BondStatus = request.BondStatus;
        if (request.NoticePeriod is not null) entity.NoticePeriod = request.NoticePeriod;
        if (request.ProjectSite is not null) entity.ProjectSite = request.ProjectSite;
        if (request.AssetId is not null) entity.AssetId = request.AssetId;
        if (request.ExitType is not null) entity.ExitType = request.ExitType;
        if (request.ExitReason is not null) entity.ExitReason = request.ExitReason;
        if (request.Education is not null) entity.Education = request.Education;
        if (request.Skills is not null) entity.Skills = request.Skills;
        if (request.Certifications is not null) entity.Certifications = request.Certifications;
        if (request.Languages is not null) entity.Languages = request.Languages;
        if (request.KpiScore.HasValue) entity.KpiScore = request.KpiScore;
        if (request.QuarterlyKpi.HasValue) entity.QuarterlyKpi = request.QuarterlyKpi;
        if (request.AnnualRating.HasValue) entity.AnnualRating = request.AnnualRating;
        if (request.GoalCompletion.HasValue) entity.GoalCompletion = request.GoalCompletion;
        if (request.Attendance.HasValue) entity.Attendance = request.Attendance;
        if (request.ReportingEfficiency.HasValue) entity.ReportingEfficiency = request.ReportingEfficiency;
        if (request.PromotionReadiness is not null) entity.PromotionReadiness = request.PromotionReadiness;
        if (request.ManagerFeedback is not null) entity.ManagerFeedback = request.ManagerFeedback;
        if (request.Pan is not null) entity.Pan = request.Pan;
        if (request.BankAccount is not null) entity.BankAccount = request.BankAccount;
        if (request.SalaryBand is not null) entity.SalaryBand = request.SalaryBand;
        if (request.SalaryBandId.HasValue) entity.SalaryBandId = request.SalaryBandId;
        if (request.ProbationPeriod is not null) entity.ProbationPeriod = request.ProbationPeriod;
        if (request.PfUan is not null) entity.PfUan = request.PfUan;
        if (request.TaxRegime is not null) entity.TaxRegime = request.TaxRegime;
        if (request.ComplianceStatus is not null) entity.ComplianceStatus = request.ComplianceStatus;

        await ApplyCatalogNamesAsync(entity, ct);
        await db.SaveChangesAsync(ct);
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
            exited = existingExit;
        }

        // Stay in the directory through last working day; hide from the next calendar day.
        if (request.LastWorkingDay is null || request.LastWorkingDay < TodayInIst())
            db.Employees.Remove(employee);

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
                e.ReasonForLeaving))
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
            .Select(d => new MetaOptionDto(d.Id, d.Code, d.Name, d.DepartmentId))
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
        CancellationToken ct = default)
    {
        var trimmed = RequireName(name);
        var dept = await db.Departments.FirstOrDefaultAsync(d => d.Id == departmentId, ct)
            ?? throw new NotFoundException("Department not found.");

        var existing = await db.Designations.FirstOrDefaultAsync(
            d => d.DepartmentId == departmentId && d.Name == trimmed, ct);
        if (existing is not null)
            return new MetaOptionDto(existing.Id, existing.Code, existing.Name, existing.DepartmentId);

        var entity = new MstDesignation
        {
            Code = await UniqueCodeAsync(
                Truncate($"{dept.Code}_{Slug(trimmed)}", 80),
                c => db.Designations.AnyAsync(d => d.Code == c, ct)),
            Name = trimmed,
            DepartmentId = departmentId,
            IsActive = true,
        };
        db.Designations.Add(entity);
        await db.SaveChangesAsync(ct);
        return new MetaOptionDto(entity.Id, entity.Code, entity.Name, entity.DepartmentId);
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
        var dueIds = await db.ExitedEmployees
            .Where(x => x.LastWorkingDay != null && x.LastWorkingDay < today)
            .Select(x => x.OriginalEmployeeId)
            .Distinct()
            .ToListAsync(ct);
        if (dueIds.Count == 0) return;

        var stillListed = await db.Employees.Where(e => dueIds.Contains(e.Id)).ToListAsync(ct);
        if (stillListed.Count == 0) return;

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
        e.ReasonForLeaving);

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
        e.BankAccount,
        e.SalaryBandRef?.Name ?? e.SalaryBand,
        e.PfUan,
        e.TaxRegime,
        e.ComplianceStatus);

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

        if (entity.JobRoleId is Guid roleId)
        {
            var role = await db.JobRoles.FirstOrDefaultAsync(r => r.Id == roleId, ct);
            if (role is not null) entity.Role = role.Name;
        }

        if (entity.SalaryBandId is Guid bandId)
        {
            var band = await db.SalaryBands.FirstOrDefaultAsync(b => b.Id == bandId, ct);
            if (band is not null) entity.SalaryBand = band.Name;
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
}
