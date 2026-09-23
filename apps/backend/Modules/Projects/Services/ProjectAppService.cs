using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Infrastructure.Storage;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Shared.Common.Wrappers;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.Projects.Services;

public sealed partial class ProjectAppService(AppDbContext db, IFileStorageService fileStorage) : IProjectAppService
{

    public async Task<PagedResult<ProjectDto>> GetProjectsAsync(ProjectQueryParameters queryParams, CancellationToken ct = default)
    {
        var query = db.Projects
            .Include(p => p.Client)
            .Include(p => p.SubVenture)
            .Include(p => p.ProjectManager)
            .Include(p => p.TeamLead)
            .Include(p => p.RenewedFromProject)
            .AsNoTracking();

        if (queryParams.ClientId.HasValue)
        {
            query = query.Where(p => p.ClientId == queryParams.ClientId.Value);
        }

        if (!string.IsNullOrWhiteSpace(queryParams.Status))
        {
            var status = queryParams.Status.Trim();
            if (status.Equals("active", StringComparison.OrdinalIgnoreCase))
            {
                query = query.Where(p => p.Status != "completed" && p.Status != "archived" && p.Status != "Archived");
            }
            else if (status.Equals("archived", StringComparison.OrdinalIgnoreCase))
            {
                query = query.Where(p => p.Status == "completed" || p.Status == "archived" || p.Status == "Archived");
            }
            else
            {
                query = query.Where(p => p.Status == status);
            }
        }

        if (!string.IsNullOrWhiteSpace(queryParams.WbsStatus))
        {
            query = query.Where(p => p.WbsStatus == queryParams.WbsStatus.Trim());
        }

        if (!string.IsNullOrWhiteSpace(queryParams.Search))
        {
            var s = queryParams.Search.Trim().ToLower();
            query = query.Where(p =>
                p.Name.ToLower().Contains(s) ||
                p.ProjectCode.ToLower().Contains(s) ||
                (p.WbsId != null && p.WbsId.ToLower().Contains(s)) ||
                (p.Client != null && p.Client.Name.ToLower().Contains(s)) ||
                (p.Description != null && p.Description.ToLower().Contains(s)));
        }

        var totalCount = await query.CountAsync(ct);
        var page = Math.Max(1, queryParams.Page);
        var pageSize = Math.Clamp(queryParams.PageSize, 1, 500);

        var items = await query
            .OrderByDescending(p => p.CreatedAtUtc)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(p => MapToDto(p))
            .ToListAsync(ct);

        return new PagedResult<ProjectDto>(items, page, pageSize, totalCount);
    }

    public async Task<ProjectDto?> GetProjectByIdAsync(Guid id, CancellationToken ct = default)
    {
        var project = await db.Projects
            .Include(p => p.Client)
            .Include(p => p.SubVenture)
            .Include(p => p.ProjectManager)
            .Include(p => p.TeamLead)
            .Include(p => p.RenewedFromProject)
            .AsNoTracking()
            .FirstOrDefaultAsync(p => p.Id == id, ct);

        return project == null ? null : MapToDto(project);
    }

    public async Task<ProjectDto> CreateProjectAsync(CreateProjectRequest request, CancellationToken ct = default)
    {
        var client = await db.Clients.FirstOrDefaultAsync(c => c.Id == request.ClientId, ct)
            ?? throw new NotFoundException($"Client with ID '{request.ClientId}' was not found.");

        string? subVentureName = null;
        if (request.SubVentureId.HasValue)
        {
            var sv = await db.SubVentures.FirstOrDefaultAsync(s => s.Id == request.SubVentureId.Value && s.ClientId == request.ClientId, ct)
                ?? throw new NotFoundException($"Sub-Venture with ID '{request.SubVentureId}' was not found for client.");
            subVentureName = sv.Name;
        }

        // Use transaction with advisory lock to ensure sequential code generation
        await using var tx = await db.Database.BeginTransactionAsync(ct);

        // Serialize sequence generation per client
        await db.Database.ExecuteSqlRawAsync(
            "SELECT pg_advisory_xact_lock(hashtext('project_seq_' || {0}));",
            request.ClientId.ToString());

        var nextCodeDto = await CalculateNextCodesInternalAsync(request.ClientId, client.Name, ct);

        // Project Name resolution
        var resolvedName = !string.IsNullOrWhiteSpace(request.Name)
            ? request.Name.Trim()
            : BuildProjectName(client.Name, subVentureName, request.SubDepartmentNames, nextCodeDto.ClientProjectCount);

        // Resolve RenewedFromProjectId from RenewedFromWbsId if not directly supplied
        var renewedFromProjectId = request.RenewedFromProjectId;
        if (!renewedFromProjectId.HasValue && !string.IsNullOrWhiteSpace(request.RenewedFromWbsId))
        {
            var wbsOrCode = request.RenewedFromWbsId.Trim();
            var orig = await db.Projects.AsNoTracking().FirstOrDefaultAsync(
                p => p.WbsId == wbsOrCode || p.ProjectCode == wbsOrCode, ct);
            if (orig != null)
            {
                renewedFromProjectId = orig.Id;
            }
        }

        var project = new Project
        {
            ProjectCode = !string.IsNullOrWhiteSpace(request.ProjectCode) ? request.ProjectCode : nextCodeDto.ProjectSeqId,
            WbsId = !string.IsNullOrWhiteSpace(request.WbsId) ? request.WbsId : nextCodeDto.WbsId,
            Name = resolvedName,
            Description = request.Description,
            ClientId = request.ClientId,
            SubVentureId = request.SubVentureId,
            Status = request.Status ?? "ongoing",
            Health = request.Health ?? "green",
            ContractType = request.ContractType,
            ProjectType = request.ProjectType,
            Currency = string.IsNullOrWhiteSpace(request.Currency) ? "INR" : request.Currency,
            TaxPercent = request.TaxPercent ?? 18m,
            StartDate = request.StartDate,
            EndDate = request.EndDate,
            Budget = request.Budget,
            Spent = 0m,
            TotalHours = request.TotalHours,
            TotalDays = request.TotalDays,
            InvoiceValue = request.InvoiceValue,
            ProjectManagerId = request.ProjectManagerId,
            TeamLeadId = request.TeamLeadId,
            EngagementManager = request.EngagementManager,
            EngagementManagerId = request.EngagementManagerId,
            SalesPerson = request.SalesPerson,
            SalesPersonId = request.SalesPersonId,
            ProjectIssuedDate = request.ProjectIssuedDate ?? DateOnly.FromDateTime(DateTime.UtcNow),
            SectionAComments = request.SectionAComments,
            SectionBComments = request.SectionBComments,
            WbsStatus = request.WbsStatus ?? "draft",
            WbsSubStatus = request.WbsSubStatus ?? "Draft",
            RenewedFromProjectId = renewedFromProjectId,
            PoStatus = request.PoStatus,
            PoNumber = request.PoNumber,
            PoDate = request.PoDate,
            BillingModel = request.BillingModel,
            PaymentTerms = request.PaymentTerms,
            TargetDate = request.TargetDate,
            AccountContactName = request.AccountContactName,
            AccountContactPhone = request.AccountContactPhone,
            AccountContactEmail = request.AccountContactEmail
        };

        db.Projects.Add(project);
        await db.SaveChangesAsync(ct);
        await tx.CommitAsync(ct);

        return (await GetProjectByIdAsync(project.Id, ct))!;
    }

    public async Task<ProjectDto> UpdateProjectAsync(Guid id, UpdateProjectRequest request, CancellationToken ct = default)
    {
        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == id, ct)
            ?? throw new NotFoundException($"Project with ID '{id}' was not found.");

        project.Name = request.Name.Trim();
        project.Description = request.Description;
        if (request.Status != null) project.Status = request.Status;
        if (request.Health != null) project.Health = request.Health;
        if (request.Progress.HasValue) project.Progress = request.Progress.Value;
        if (request.ContractType != null) project.ContractType = request.ContractType;
        if (request.ProjectType != null) project.ProjectType = request.ProjectType;
        if (request.Currency != null) project.Currency = request.Currency;
        if (request.TaxPercent.HasValue) project.TaxPercent = request.TaxPercent.Value;
        if (request.StartDate.HasValue) project.StartDate = request.StartDate;
        if (request.EndDate.HasValue) project.EndDate = request.EndDate;
        if (request.Budget.HasValue) project.Budget = request.Budget;
        if (request.Spent.HasValue) project.Spent = request.Spent.Value;
        if (request.TotalHours.HasValue) project.TotalHours = request.TotalHours;
        if (request.TotalDays.HasValue) project.TotalDays = request.TotalDays;
        if (request.InvoiceValue.HasValue) project.InvoiceValue = request.InvoiceValue;
        if (request.ProjectManagerId.HasValue) project.ProjectManagerId = request.ProjectManagerId;
        if (request.TeamLeadId.HasValue) project.TeamLeadId = request.TeamLeadId;
        if (request.EngagementManager != null) project.EngagementManager = request.EngagementManager;
        if (request.EngagementManagerId.HasValue) project.EngagementManagerId = request.EngagementManagerId;
        if (request.SalesPerson != null) project.SalesPerson = request.SalesPerson;
        if (request.SalesPersonId.HasValue) project.SalesPersonId = request.SalesPersonId;
        if (request.ProjectIssuedDate.HasValue) project.ProjectIssuedDate = request.ProjectIssuedDate;
        if (request.SectionAComments != null) project.SectionAComments = request.SectionAComments;
        if (request.SectionBComments != null) project.SectionBComments = request.SectionBComments;
        if (request.WbsStatus != null) project.WbsStatus = request.WbsStatus;
        if (request.WbsSubStatus != null) project.WbsSubStatus = request.WbsSubStatus;
        if (request.PoStatus != null) project.PoStatus = request.PoStatus;
        if (request.PoNumber != null) project.PoNumber = request.PoNumber;
        if (request.PoDate.HasValue) project.PoDate = request.PoDate;
        if (request.BillingModel != null) project.BillingModel = request.BillingModel;
        if (request.PaymentTerms != null) project.PaymentTerms = request.PaymentTerms;
        if (request.TargetDate.HasValue) project.TargetDate = request.TargetDate;
        if (request.AccountContactName != null) project.AccountContactName = request.AccountContactName;
        if (request.AccountContactPhone != null) project.AccountContactPhone = request.AccountContactPhone;
        if (request.AccountContactEmail != null) project.AccountContactEmail = request.AccountContactEmail;

        await db.SaveChangesAsync(ct);
        return (await GetProjectByIdAsync(id, ct))!;
    }

    public async Task<bool> DeleteProjectAsync(Guid id, CancellationToken ct = default)
    {
        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == id, ct);
        if (project == null) return false;

        db.Projects.Remove(project);
        await db.SaveChangesAsync(ct);
        return true;
    }

    public async Task<ProjectDto> UpdateStatusAsync(Guid id, string status, CancellationToken ct = default)
    {
        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == id, ct)
            ?? throw new NotFoundException($"Project with ID '{id}' was not found.");

        project.Status = status;
        await db.SaveChangesAsync(ct);
        return (await GetProjectByIdAsync(id, ct))!;
    }

    public async Task<ProjectDto> UpdateWbsStatusAsync(Guid id, string wbsStatus, string? wbsSubStatus = null, CancellationToken ct = default)
    {
        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == id, ct)
            ?? throw new NotFoundException($"Project with ID '{id}' was not found.");

        project.WbsStatus = wbsStatus;
        if (wbsSubStatus != null) project.WbsSubStatus = wbsSubStatus;
        await db.SaveChangesAsync(ct);
        return (await GetProjectByIdAsync(id, ct))!;
    }

    public async Task<NextProjectCodeDto> GetNextProjectCodeAsync(Guid clientId, CancellationToken ct = default)
    {
        var client = await db.Clients.FirstOrDefaultAsync(c => c.Id == clientId, ct)
            ?? throw new NotFoundException($"Client with ID '{clientId}' was not found.");

        return await CalculateNextCodesInternalAsync(clientId, client.Name, ct);
    }

    // ── Project Services Methods ──

    public async Task<IReadOnlyList<ProjectServiceDto>> GetProjectServicesAsync(Guid projectId, CancellationToken ct = default)
    {
        var exists = await db.Projects.AnyAsync(p => p.Id == projectId, ct);
        if (!exists)
            throw new NotFoundException($"Project with ID '{projectId}' was not found.");

        var services = await db.ProjectServices
            .Include(s => s.ResourceLevels)
            .Where(s => s.ProjectId == projectId)
            .OrderBy(s => s.SortOrder)
            .ThenBy(s => s.CreatedAtUtc)
            .ToListAsync(ct);

        return services.Select(MapToServiceDto).ToList();
    }

    public async Task<ProjectServiceDto?> GetProjectServiceByIdAsync(Guid projectId, Guid serviceId, CancellationToken ct = default)
    {
        var service = await db.ProjectServices
            .Include(s => s.ResourceLevels)
            .FirstOrDefaultAsync(s => s.ProjectId == projectId && s.Id == serviceId, ct);

        return service == null ? null : MapToServiceDto(service);
    }

    public async Task<ProjectServiceDto> AddProjectServiceAsync(Guid projectId, CreateProjectServiceRequest request, CancellationToken ct = default)
    {
        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == projectId, ct)
            ?? throw new NotFoundException($"Project with ID '{projectId}' was not found.");

        MstServiceCatalog? catalog = null;
        if (request.ServiceCatalogId.HasValue)
        {
            catalog = await db.ServiceCatalogs
                .Include(c => c.SubDepartment)
                    .ThenInclude(s => s!.Department)
                .FirstOrDefaultAsync(c => c.Id == request.ServiceCatalogId.Value, ct);
        }

        var department = !string.IsNullOrWhiteSpace(request.Department)
            ? request.Department
            : catalog?.SubDepartment?.Department?.Name ?? "General";

        var subDept = !string.IsNullOrWhiteSpace(request.SubDepartment)
            ? request.SubDepartment
            : catalog?.SubDepartment?.Name;

        var serviceName = !string.IsNullOrWhiteSpace(request.ServiceName)
            ? request.ServiceName
            : catalog?.Name ?? "Custom Service";

        var taskId = !string.IsNullOrWhiteSpace(request.TaskId)
            ? request.TaskId
            : catalog?.Code;

        var tools = !string.IsNullOrWhiteSpace(request.Tools)
            ? request.Tools
            : catalog?.DefaultTools;

        var unitPrice = request.UnitPrice ?? catalog?.DefaultUnitPrice ?? 0m;
        var durationDays = request.DurationDays ?? catalog?.DefaultDurationDays ?? 5;
        var durationHours = durationDays * 8;
        var qty = Math.Max(1, request.Qty);
        var totalDays = qty * durationDays;
        var totalHours = qty * durationHours;
        var total = qty * unitPrice;

        var resourceLevelStr = request.ResourceLevel;
        if (string.IsNullOrWhiteSpace(resourceLevelStr) && request.ResourceLevels != null && request.ResourceLevels.Count > 0)
        {
            resourceLevelStr = string.Join(", ", request.ResourceLevels.Where(l => l.Count > 0).Select(l => $"{l.Level}={l.Count}"));
        }

        var service = new ProjectServiceEntity
        {
            ProjectId = projectId,
            ServiceCatalogId = request.ServiceCatalogId,
            TaskId = taskId,
            Department = department,
            SubDepartment = subDept,
            ServiceName = serviceName,
            Qty = qty,
            Description = request.Description,
            ResourceLevel = resourceLevelStr,
            Frequency = request.Frequency ?? "Once",
            Location = request.Location ?? "Offsite",
            LocationText = request.LocationText,
            ServiceModel = request.ServiceModel ?? "Fixed",
            DeliveryModel = request.DeliveryModel ?? "Agile",
            FinalDeliveryFormat = request.FinalDeliveryFormat,
            BillingModel = request.BillingModel ?? project.BillingModel,
            Tools = tools,
            StartDate = request.StartDate ?? project.StartDate,
            EndDate = request.EndDate ?? project.EndDate,
            DurationDays = durationDays,
            DurationHours = durationHours,
            TotalDays = totalDays,
            TotalHours = totalHours,
            UnitPrice = unitPrice,
            Total = total,
            SortOrder = request.SortOrder
        };

        if (request.ResourceLevels != null && request.ResourceLevels.Count > 0)
        {
            foreach (var r in request.ResourceLevels)
            {
                service.ResourceLevels.Add(new ProjectServiceResourceLevel
                {
                    Level = r.Level,
                    Count = r.Count
                });
            }
        }

        db.ProjectServices.Add(service);
        await db.SaveChangesAsync(ct);

        // Recalculate project totals
        await RecalculateProjectRollupsAsync(projectId, ct);

        return (await GetProjectServiceByIdAsync(projectId, service.Id, ct))!;
    }

    public async Task<ProjectServiceDto> UpdateProjectServiceAsync(Guid projectId, Guid serviceId, UpdateProjectServiceRequest request, CancellationToken ct = default)
    {
        var service = await db.ProjectServices
            .Include(s => s.ResourceLevels)
            .FirstOrDefaultAsync(s => s.ProjectId == projectId && s.Id == serviceId, ct)
            ?? throw new NotFoundException($"Project Service with ID '{serviceId}' was not found.");

        if (request.Department != null) service.Department = request.Department;
        if (request.SubDepartment != null) service.SubDepartment = request.SubDepartment;
        if (request.ServiceName != null) service.ServiceName = request.ServiceName;
        if (request.Qty.HasValue) service.Qty = Math.Max(1, request.Qty.Value);
        if (request.Description != null) service.Description = request.Description;
        if (request.Frequency != null) service.Frequency = request.Frequency;
        if (request.Location != null) service.Location = request.Location;
        if (request.LocationText != null) service.LocationText = request.LocationText;
        if (request.ServiceModel != null) service.ServiceModel = request.ServiceModel;
        if (request.DeliveryModel != null) service.DeliveryModel = request.DeliveryModel;
        if (request.FinalDeliveryFormat != null) service.FinalDeliveryFormat = request.FinalDeliveryFormat;
        if (request.BillingModel != null) service.BillingModel = request.BillingModel;
        if (request.Tools != null) service.Tools = request.Tools;
        if (request.StartDate.HasValue) service.StartDate = request.StartDate;
        if (request.EndDate.HasValue) service.EndDate = request.EndDate;
        if (request.DurationDays.HasValue) service.DurationDays = request.DurationDays;
        if (request.UnitPrice.HasValue) service.UnitPrice = request.UnitPrice;
        if (request.SortOrder.HasValue) service.SortOrder = request.SortOrder.Value;

        // Recompute derived totals
        var dDays = service.DurationDays ?? 5;
        service.DurationHours = dDays * 8;
        service.TotalDays = service.Qty * dDays;
        service.TotalHours = service.Qty * (service.DurationHours ?? 40);
        service.Total = service.Qty * (service.UnitPrice ?? 0m);

        if (request.ResourceLevels != null)
        {
            db.ProjectServiceResourceLevels.RemoveRange(service.ResourceLevels);
            service.ResourceLevels.Clear();

            foreach (var r in request.ResourceLevels)
            {
                service.ResourceLevels.Add(new ProjectServiceResourceLevel
                {
                    ProjectServiceId = service.Id,
                    Level = r.Level,
                    Count = r.Count
                });
            }

            service.ResourceLevel = string.Join(", ", request.ResourceLevels.Where(l => l.Count > 0).Select(l => $"{l.Level}={l.Count}"));
        }
        else if (request.ResourceLevel != null)
        {
            service.ResourceLevel = request.ResourceLevel;
        }

        await db.SaveChangesAsync(ct);

        // Recalculate project totals
        await RecalculateProjectRollupsAsync(projectId, ct);

        return (await GetProjectServiceByIdAsync(projectId, serviceId, ct))!;
    }

    public async Task<bool> DeleteProjectServiceAsync(Guid projectId, Guid serviceId, CancellationToken ct = default)
    {
        var service = await db.ProjectServices.FirstOrDefaultAsync(s => s.ProjectId == projectId && s.Id == serviceId, ct);
        if (service == null) return false;

        db.ProjectServices.Remove(service);
        await db.SaveChangesAsync(ct);

        // Recalculate project totals
        await RecalculateProjectRollupsAsync(projectId, ct);

        return true;
    }

    public async Task<ProjectServiceDto> SetResourceLevelsAsync(Guid projectId, Guid serviceId, SetResourceLevelsRequest request, CancellationToken ct = default)
    {
        var service = await db.ProjectServices
            .Include(s => s.ResourceLevels)
            .FirstOrDefaultAsync(s => s.ProjectId == projectId && s.Id == serviceId, ct)
            ?? throw new NotFoundException($"Project Service with ID '{serviceId}' was not found.");

        var totalAllocated = request.Levels.Sum(l => l.Count);
        if (totalAllocated != service.Qty)
        {
            throw new ConflictException($"Sum of resource distribution counts ({totalAllocated}) must equal service Quantity ({service.Qty}).");
        }

        db.ProjectServiceResourceLevels.RemoveRange(service.ResourceLevels);
        service.ResourceLevels.Clear();

        foreach (var r in request.Levels)
        {
            service.ResourceLevels.Add(new ProjectServiceResourceLevel
            {
                ProjectServiceId = service.Id,
                Level = r.Level,
                Count = r.Count
            });
        }

        service.ResourceLevel = string.Join(", ", request.Levels.Where(l => l.Count > 0).Select(l => $"{l.Level}={l.Count}"));

        await db.SaveChangesAsync(ct);
        return (await GetProjectServiceByIdAsync(projectId, serviceId, ct))!;
    }

    private async Task RecalculateProjectRollupsAsync(Guid projectId, CancellationToken ct)
    {
        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == projectId, ct);
        if (project == null) return;

        var services = await db.ProjectServices.Where(s => s.ProjectId == projectId).ToListAsync(ct);
        if (services.Count > 0)
        {
            project.Budget = services.Sum(s => s.Total ?? 0m);
            project.TotalHours = services.Sum(s => s.TotalHours ?? 0);
            project.TotalDays = services.Sum(s => s.TotalDays ?? 0);
            await db.SaveChangesAsync(ct);
        }
    }

    private async Task<NextProjectCodeDto> CalculateNextCodesInternalAsync(Guid clientId, string clientName, CancellationToken ct)
    {
        var now = DateTime.UtcNow;
        var fyStartYear = now.Month >= 4 ? now.Year : now.Year - 1;
        var fyEndYear = (fyStartYear + 1) % 100;
        var fyStartDate = new DateTime(fyStartYear, 4, 1, 0, 0, 0, DateTimeKind.Utc);
        var fyEndDate = new DateTime(fyStartYear + 1, 4, 1, 0, 0, 0, DateTimeKind.Utc);

        // Global count of projects within this FY
        var globalFyProjectsCount = await db.Projects
            .IgnoreQueryFilters()
            .CountAsync(p => p.CreatedAtUtc >= fyStartDate && p.CreatedAtUtc < fyEndDate, ct);

        var projectSeqNum = globalFyProjectsCount + 1;
        var projectSeqId = "P" + projectSeqNum.ToString("D3");

        // Client position among all clients (ordered by CreatedAtUtc)
        var clientIndex = await db.Clients
            .OrderBy(c => c.CreatedAtUtc)
            .Select(c => c.Id)
            .ToListAsync(ct);

        var clientPos = clientIndex.IndexOf(clientId);
        var clientSeq = clientPos >= 0 ? clientPos + 1 : 1;
        var paddedClientId = "C" + clientSeq.ToString("D3");

        var wbsId = $"IN-{fyStartYear}-{fyEndYear:D2}-{paddedClientId}-{projectSeqId}";

        // Client-specific project count
        var clientProjectCount = await db.Projects
            .CountAsync(p => p.ClientId == clientId, ct) + 1;

        var formattedClientProjectCount = clientProjectCount.ToString("D2");

        return new NextProjectCodeDto(
            projectSeqId,
            wbsId,
            $"{fyStartYear}-{fyEndYear:D2}",
            clientProjectCount,
            formattedClientProjectCount);
    }

    public static string BuildProjectName(
        string clientName,
        string? subVentureName,
        IReadOnlyList<string>? subDepartmentNames,
        int clientProjectCount)
    {
        var cName = (clientName ?? "").Trim();
        var svName = (subVentureName ?? "").Trim();
        var descriptor = ProjectNameDescriptor(subDepartmentNames);
        var count = clientProjectCount.ToString("D2");

        if (!string.IsNullOrEmpty(svName))
        {
            return $"{cName}({svName})_{descriptor}_{count}";
        }
        return $"{cName}_{descriptor}_{count}";
    }

    public static string ProjectNameDescriptor(IReadOnlyList<string>? subDepartmentNames)
    {
        if (subDepartmentNames == null || subDepartmentNames.Count == 0)
            return "General";

        var unique = subDepartmentNames
            .Where(s => !string.IsNullOrWhiteSpace(s))
            .Select(s => s.Trim())
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();

        if (unique.Count == 0) return "General";
        if (unique.Count == 1) return unique[0].Replace(" ", "");
        return "Mixed";
    }

    // ── Project Tasks Methods ──

    public async Task<IReadOnlyList<ProjectTaskDto>> GetProjectTasksAsync(Guid projectId, CancellationToken ct = default)
    {
        var exists = await db.Projects.AnyAsync(p => p.Id == projectId, ct);
        if (!exists)
            throw new NotFoundException($"Project with ID '{projectId}' was not found.");

        var tasks = await db.ProjectTasks
            .Include(t => t.ProjectService)
            .Where(t => t.ProjectId == projectId)
            .OrderBy(t => t.SortOrder)
            .ThenBy(t => t.CreatedAtUtc)
            .ToListAsync(ct);

        return tasks.Select(MapToTaskDto).ToList();
    }

    public async Task<ProjectTaskDto?> GetProjectTaskByIdAsync(Guid projectId, Guid taskId, CancellationToken ct = default)
    {
        var task = await db.ProjectTasks
            .Include(t => t.ProjectService)
            .FirstOrDefaultAsync(t => t.ProjectId == projectId && t.Id == taskId, ct);

        return task == null ? null : MapToTaskDto(task);
    }

    public async Task<ProjectTaskDto> CreateProjectTaskAsync(Guid projectId, CreateProjectTaskRequest request, CancellationToken ct = default)
    {
        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == projectId, ct)
            ?? throw new NotFoundException($"Project with ID '{projectId}' was not found.");

        if (request.ProjectServiceId.HasValue)
        {
            var serviceExists = await db.ProjectServices.AnyAsync(s => s.Id == request.ProjectServiceId.Value && s.ProjectId == projectId, ct);
            if (!serviceExists)
                throw new NotFoundException($"Project Service with ID '{request.ProjectServiceId}' was not found for this project.");
        }

        var task = new ProjectTask
        {
            ProjectId = projectId,
            ProjectServiceId = request.ProjectServiceId,
            Title = request.Title.Trim(),
            Description = request.Description,
            Period = request.Period ?? "Q1",
            Phase = request.Phase ?? "Execution",
            Stage = request.Stage ?? "Ready to Start",
            Priority = request.Priority ?? "medium",
            PlannedStartDate = request.PlannedStartDate ?? project.StartDate,
            PlannedEndDate = request.PlannedEndDate ?? project.EndDate,
            EstimatedHours = request.EstimatedHours,
            SortOrder = request.SortOrder
        };

        db.ProjectTasks.Add(task);
        await db.SaveChangesAsync(ct);

        return (await GetProjectTaskByIdAsync(projectId, task.Id, ct))!;
    }

    public async Task<ProjectTaskDto> UpdateProjectTaskAsync(Guid projectId, Guid taskId, UpdateProjectTaskRequest request, CancellationToken ct = default)
    {
        var task = await db.ProjectTasks
            .Include(t => t.ProjectService)
            .FirstOrDefaultAsync(t => t.ProjectId == projectId && t.Id == taskId, ct)
            ?? throw new NotFoundException($"Project Task with ID '{taskId}' was not found.");

        if (request.ProjectServiceId.HasValue)
        {
            var serviceExists = await db.ProjectServices.AnyAsync(s => s.Id == request.ProjectServiceId.Value && s.ProjectId == projectId, ct);
            if (!serviceExists)
                throw new NotFoundException($"Project Service with ID '{request.ProjectServiceId}' was not found for this project.");
            task.ProjectServiceId = request.ProjectServiceId;
        }

        if (request.Title != null) task.Title = request.Title.Trim();
        if (request.Description != null) task.Description = request.Description;
        if (request.Period != null) task.Period = request.Period;
        if (request.Phase != null) task.Phase = request.Phase;
        if (request.Stage != null) task.Stage = request.Stage;
        if (request.Priority != null) task.Priority = request.Priority;
        if (request.PlannedStartDate.HasValue) task.PlannedStartDate = request.PlannedStartDate;
        if (request.PlannedEndDate.HasValue) task.PlannedEndDate = request.PlannedEndDate;
        if (request.ActualStartDate.HasValue) task.ActualStartDate = request.ActualStartDate;
        if (request.ActualEndDate.HasValue) task.ActualEndDate = request.ActualEndDate;
        if (request.EstimatedHours.HasValue) task.EstimatedHours = request.EstimatedHours;
        if (request.UtilizedHours.HasValue) task.UtilizedHours = request.UtilizedHours.Value;
        if (request.Progress.HasValue) task.Progress = request.Progress.Value;
        if (request.SortOrder.HasValue) task.SortOrder = request.SortOrder.Value;

        await db.SaveChangesAsync(ct);

        return (await GetProjectTaskByIdAsync(projectId, taskId, ct))!;
    }

    public async Task<bool> DeleteProjectTaskAsync(Guid projectId, Guid taskId, CancellationToken ct = default)
    {
        var task = await db.ProjectTasks.FirstOrDefaultAsync(t => t.ProjectId == projectId && t.Id == taskId, ct);
        if (task == null) return false;

        db.ProjectTasks.Remove(task);
        await db.SaveChangesAsync(ct);
        return true;
    }

    public async Task<ProjectTaskDto> UpdateTaskStageAsync(Guid projectId, Guid taskId, string stage, CancellationToken ct = default)
    {
        var task = await db.ProjectTasks
            .Include(t => t.ProjectService)
            .FirstOrDefaultAsync(t => t.ProjectId == projectId && t.Id == taskId, ct)
            ?? throw new NotFoundException($"Project Task with ID '{taskId}' was not found.");

        task.Stage = stage;

        if (stage.Equals("Ongoing", StringComparison.OrdinalIgnoreCase) && !task.ActualStartDate.HasValue)
        {
            task.ActualStartDate = DateOnly.FromDateTime(DateTime.UtcNow);
        }
        else if (stage.Equals("Completed", StringComparison.OrdinalIgnoreCase))
        {
            task.ActualEndDate ??= DateOnly.FromDateTime(DateTime.UtcNow);
            task.Progress = 100;
        }

        await db.SaveChangesAsync(ct);

        return (await GetProjectTaskByIdAsync(projectId, taskId, ct))!;
    }

    public async Task<AutoGeneratedTasksSummaryDto> AutoGenerateTasksFromServicesAsync(Guid projectId, CancellationToken ct = default)
    {
        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == projectId, ct)
            ?? throw new NotFoundException($"Project with ID '{projectId}' was not found.");

        var services = await db.ProjectServices
            .Where(s => s.ProjectId == projectId)
            .OrderBy(s => s.SortOrder)
            .ThenBy(s => s.CreatedAtUtc)
            .ToListAsync(ct);

        var newTasks = new List<ProjectTask>();
        int order = 1;

        foreach (var service in services)
        {
            if (service.Qty <= 1)
            {
                newTasks.Add(new ProjectTask
                {
                    ProjectId = projectId,
                    ProjectServiceId = service.Id,
                    Title = service.ServiceName,
                    Description = service.Description,
                    Period = "Q1",
                    Phase = "Execution",
                    Stage = "Ready to Start",
                    Priority = "medium",
                    PlannedStartDate = service.StartDate ?? project.StartDate,
                    PlannedEndDate = service.EndDate ?? project.EndDate,
                    EstimatedHours = service.TotalHours ?? ((service.DurationDays ?? 5) * 8),
                    SortOrder = order++ * 10
                });
            }
            else
            {
                var hoursPerUnit = service.DurationHours ?? ((service.DurationDays ?? 5) * 8);
                for (int i = 1; i <= service.Qty; i++)
                {
                    newTasks.Add(new ProjectTask
                    {
                        ProjectId = projectId,
                        ProjectServiceId = service.Id,
                        Title = $"{service.ServiceName} (Part {i})",
                        Description = service.Description,
                        Period = "Q1",
                        Phase = "Execution",
                        Stage = "Ready to Start",
                        Priority = "medium",
                        PlannedStartDate = service.StartDate ?? project.StartDate,
                        PlannedEndDate = service.EndDate ?? project.EndDate,
                        EstimatedHours = hoursPerUnit,
                        SortOrder = order++ * 10
                    });
                }
            }
        }

        if (newTasks.Count > 0)
        {
            db.ProjectTasks.AddRange(newTasks);
            await db.SaveChangesAsync(ct);
        }

        var createdTaskDtos = newTasks.Select(MapToTaskDto).ToList();
        return new AutoGeneratedTasksSummaryDto(projectId, newTasks.Count, createdTaskDtos);
    }

    // ── Task Assignments & Timer Methods ──

    public async Task<IReadOnlyList<ProjectTaskAssignmentDto>> GetTaskAssignmentsAsync(Guid projectId, Guid taskId, CancellationToken ct = default)
    {
        var taskExists = await db.ProjectTasks.AnyAsync(t => t.ProjectId == projectId && t.Id == taskId, ct);
        if (!taskExists)
            throw new NotFoundException($"Project Task with ID '{taskId}' was not found in this project.");

        var assignments = await db.ProjectTaskAssignments
            .Include(a => a.Employee)
            .Where(a => a.TaskId == taskId)
            .OrderBy(a => a.CreatedAtUtc)
            .ToListAsync(ct);

        return assignments.Select(MapToAssignmentDto).ToList();
    }

    public async Task<ProjectTaskAssignmentDto> AssignTaskResourceAsync(Guid projectId, Guid taskId, AssignTaskResourceRequest request, CancellationToken ct = default)
    {
        var task = await db.ProjectTasks.FirstOrDefaultAsync(t => t.ProjectId == projectId && t.Id == taskId, ct)
            ?? throw new NotFoundException($"Project Task with ID '{taskId}' was not found in this project.");

        var employeeExists = await db.Employees.AnyAsync(e => e.Id == request.EmployeeId, ct);
        if (!employeeExists)
            throw new NotFoundException($"Employee with ID '{request.EmployeeId}' was not found.");

        var existing = await db.ProjectTaskAssignments
            .Include(a => a.Employee)
            .FirstOrDefaultAsync(a => a.TaskId == taskId && a.EmployeeId == request.EmployeeId, ct);

        if (existing != null)
        {
            if (existing.IsActive)
                throw new ConflictException("Employee is already assigned to this task.");

            existing.IsActive = true;
            existing.Role = request.Role ?? existing.Role;
            if (request.AllocatedHours.HasValue) existing.AllocatedHours = request.AllocatedHours;
            await db.SaveChangesAsync(ct);
            return MapToAssignmentDto(existing);
        }

        var assignment = new ProjectTaskAssignment
        {
            TaskId = taskId,
            EmployeeId = request.EmployeeId,
            Role = request.Role ?? "Contributor",
            AllocatedHours = request.AllocatedHours,
            UtilizedHours = 0m,
            TimerAccumulatedSeconds = 0,
            IsActive = true
        };

        db.ProjectTaskAssignments.Add(assignment);
        await db.SaveChangesAsync(ct);

        var created = await db.ProjectTaskAssignments
            .Include(a => a.Employee)
            .FirstOrDefaultAsync(a => a.Id == assignment.Id, ct);

        return MapToAssignmentDto(created!);
    }

    public async Task<ProjectTaskAssignmentDto> UpdateTaskAssignmentAsync(Guid projectId, Guid taskId, Guid assignmentId, UpdateTaskAssignmentRequest request, CancellationToken ct = default)
    {
        var taskExists = await db.ProjectTasks.AnyAsync(t => t.ProjectId == projectId && t.Id == taskId, ct);
        if (!taskExists)
            throw new NotFoundException($"Project Task with ID '{taskId}' was not found in this project.");

        var assignment = await db.ProjectTaskAssignments
            .Include(a => a.Employee)
            .FirstOrDefaultAsync(a => a.TaskId == taskId && a.Id == assignmentId, ct)
            ?? throw new NotFoundException($"Task assignment with ID '{assignmentId}' was not found.");

        if (request.Role != null) assignment.Role = request.Role;
        if (request.AllocatedHours.HasValue) assignment.AllocatedHours = request.AllocatedHours;
        if (request.UtilizedHours.HasValue) assignment.UtilizedHours = request.UtilizedHours.Value;
        if (request.IsActive.HasValue) assignment.IsActive = request.IsActive.Value;

        await db.SaveChangesAsync(ct);
        return MapToAssignmentDto(assignment);
    }

    public async Task<bool> RemoveTaskAssignmentAsync(Guid projectId, Guid taskId, Guid assignmentId, CancellationToken ct = default)
    {
        var taskExists = await db.ProjectTasks.AnyAsync(t => t.ProjectId == projectId && t.Id == taskId, ct);
        if (!taskExists)
            throw new NotFoundException($"Project Task with ID '{taskId}' was not found in this project.");

        var assignment = await db.ProjectTaskAssignments
            .FirstOrDefaultAsync(a => a.TaskId == taskId && a.Id == assignmentId, ct);

        if (assignment == null) return false;

        db.ProjectTaskAssignments.Remove(assignment);
        await db.SaveChangesAsync(ct);
        return true;
    }

    public async Task<TimerStatusDto> StartTaskTimerAsync(Guid projectId, Guid taskId, Guid assignmentId, CancellationToken ct = default)
    {
        var task = await db.ProjectTasks.FirstOrDefaultAsync(t => t.ProjectId == projectId && t.Id == taskId, ct)
            ?? throw new NotFoundException($"Project Task with ID '{taskId}' was not found in this project.");

        var assignment = await db.ProjectTaskAssignments
            .FirstOrDefaultAsync(a => a.TaskId == taskId && a.Id == assignmentId, ct)
            ?? throw new NotFoundException($"Task assignment with ID '{assignmentId}' was not found.");

        if (!assignment.TimerStartedAtUtc.HasValue)
        {
            assignment.TimerStartedAtUtc = DateTime.UtcNow;

            // Auto-advance task stage from "Ready to Start" to "Ongoing"
            if (task.Stage.Equals("Ready to Start", StringComparison.OrdinalIgnoreCase))
            {
                task.Stage = "Ongoing";
                task.ActualStartDate ??= DateOnly.FromDateTime(DateTime.UtcNow);
            }

            await db.SaveChangesAsync(ct);
        }

        var totalSeconds = assignment.TimerAccumulatedSeconds;
        if (assignment.TimerStartedAtUtc.HasValue)
        {
            totalSeconds += (long)(DateTime.UtcNow - assignment.TimerStartedAtUtc.Value).TotalSeconds;
        }

        return new TimerStatusDto(
            assignment.Id,
            taskId,
            assignment.EmployeeId,
            true,
            assignment.TimerStartedAtUtc,
            totalSeconds,
            Math.Round((decimal)totalSeconds / 3600m, 2));
    }

    public async Task<TimerStatusDto> StopTaskTimerAsync(Guid projectId, Guid taskId, Guid assignmentId, CancellationToken ct = default)
    {
        var task = await db.ProjectTasks.FirstOrDefaultAsync(t => t.ProjectId == projectId && t.Id == taskId, ct)
            ?? throw new NotFoundException($"Project Task with ID '{taskId}' was not found in this project.");

        var assignment = await db.ProjectTaskAssignments
            .FirstOrDefaultAsync(a => a.TaskId == taskId && a.Id == assignmentId, ct)
            ?? throw new NotFoundException($"Task assignment with ID '{assignmentId}' was not found.");

        if (assignment.TimerStartedAtUtc.HasValue)
        {
            var elapsed = (long)(DateTime.UtcNow - assignment.TimerStartedAtUtc.Value).TotalSeconds;
            assignment.TimerAccumulatedSeconds += Math.Max(0, elapsed);
            assignment.TimerStartedAtUtc = null;
            assignment.UtilizedHours = Math.Round((decimal)assignment.TimerAccumulatedSeconds / 3600m, 2);

            // Recompute task utilized hours
            var otherAssignmentsTotal = await db.ProjectTaskAssignments
                .Where(a => a.TaskId == taskId && a.Id != assignmentId)
                .SumAsync(a => a.UtilizedHours, ct);

            task.UtilizedHours = otherAssignmentsTotal + assignment.UtilizedHours;

            await db.SaveChangesAsync(ct);
        }

        return new TimerStatusDto(
            assignment.Id,
            taskId,
            assignment.EmployeeId,
            false,
            null,
            assignment.TimerAccumulatedSeconds,
            Math.Round((decimal)assignment.TimerAccumulatedSeconds / 3600m, 2));
    }

    // ── Project Invoices Methods ──

    public async Task<IReadOnlyList<ProjectInvoiceDto>> GetProjectInvoicesAsync(Guid projectId, CancellationToken ct = default)
    {
        var exists = await db.Projects.AnyAsync(p => p.Id == projectId, ct);
        if (!exists)
            throw new NotFoundException($"Project with ID '{projectId}' was not found.");

        var invoices = await db.ProjectInvoices
            .Where(i => i.ProjectId == projectId)
            .OrderBy(i => i.SortOrder)
            .ThenBy(i => i.CreatedAtUtc)
            .ToListAsync(ct);

        return invoices.Select(MapToInvoiceDto).ToList();
    }

    public async Task<ProjectInvoiceDto?> GetProjectInvoiceByIdAsync(Guid projectId, Guid invoiceId, CancellationToken ct = default)
    {
        var invoice = await db.ProjectInvoices
            .FirstOrDefaultAsync(i => i.ProjectId == projectId && i.Id == invoiceId, ct);

        return invoice == null ? null : MapToInvoiceDto(invoice);
    }

    public async Task<ProjectInvoiceDto> CreateProjectInvoiceAsync(Guid projectId, CreateProjectInvoiceRequest request, CancellationToken ct = default)
    {
        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == projectId, ct)
            ?? throw new NotFoundException($"Project with ID '{projectId}' was not found.");

        var amount = request.Amount;
        if (amount == 0 && request.Percentage.HasValue && project.Budget.HasValue)
        {
            amount = Math.Round((project.Budget.Value * request.Percentage.Value) / 100m, 2);
        }

        var taxPercent = request.TaxPercent ?? project.TaxPercent;
        var taxAmount = request.TaxAmount ?? Math.Round(amount * (taxPercent / 100m), 2);
        var totalAmount = request.TotalAmount ?? (amount + taxAmount);

        var invoice = new ProjectInvoice
        {
            ProjectId = projectId,
            MilestoneName = request.MilestoneName.Trim(),
            Percentage = request.Percentage,
            Amount = amount,
            TaxAmount = taxAmount,
            TotalAmount = totalAmount,
            Status = request.Status ?? "Pending",
            InvoiceNumber = request.InvoiceNumber,
            InvoiceDate = request.InvoiceDate,
            DueDate = request.DueDate,
            PaymentDate = request.PaymentDate,
            Remarks = request.Remarks,
            SortOrder = request.SortOrder
        };

        db.ProjectInvoices.Add(invoice);
        await db.SaveChangesAsync(ct);

        await RecalculateProjectInvoiceRollupAsync(projectId, ct);

        return (await GetProjectInvoiceByIdAsync(projectId, invoice.Id, ct))!;
    }

    public async Task<ProjectInvoiceDto> UpdateProjectInvoiceAsync(Guid projectId, Guid invoiceId, UpdateProjectInvoiceRequest request, CancellationToken ct = default)
    {
        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == projectId, ct)
            ?? throw new NotFoundException($"Project with ID '{projectId}' was not found.");

        var invoice = await db.ProjectInvoices
            .FirstOrDefaultAsync(i => i.ProjectId == projectId && i.Id == invoiceId, ct)
            ?? throw new NotFoundException($"Project Invoice with ID '{invoiceId}' was not found.");

        if (request.MilestoneName != null) invoice.MilestoneName = request.MilestoneName.Trim();
        if (request.Percentage.HasValue) invoice.Percentage = request.Percentage.Value;
        if (request.Amount.HasValue) invoice.Amount = request.Amount.Value;

        var taxPercent = request.TaxPercent ?? project.TaxPercent;
        if (request.TaxAmount.HasValue)
        {
            invoice.TaxAmount = request.TaxAmount.Value;
        }
        else if (request.Amount.HasValue || request.TaxPercent.HasValue)
        {
            invoice.TaxAmount = Math.Round(invoice.Amount * (taxPercent / 100m), 2);
        }

        if (request.TotalAmount.HasValue)
        {
            invoice.TotalAmount = request.TotalAmount.Value;
        }
        else if (request.Amount.HasValue || request.TaxAmount.HasValue || request.TaxPercent.HasValue)
        {
            invoice.TotalAmount = invoice.Amount + invoice.TaxAmount;
        }

        if (request.Status != null) invoice.Status = request.Status;
        if (request.InvoiceNumber != null) invoice.InvoiceNumber = request.InvoiceNumber;
        if (request.InvoiceDate.HasValue) invoice.InvoiceDate = request.InvoiceDate;
        if (request.DueDate.HasValue) invoice.DueDate = request.DueDate;
        if (request.PaymentDate.HasValue) invoice.PaymentDate = request.PaymentDate;
        if (request.Remarks != null) invoice.Remarks = request.Remarks;
        if (request.SortOrder.HasValue) invoice.SortOrder = request.SortOrder.Value;

        await db.SaveChangesAsync(ct);
        await RecalculateProjectInvoiceRollupAsync(projectId, ct);

        return (await GetProjectInvoiceByIdAsync(projectId, invoiceId, ct))!;
    }

    public async Task<bool> DeleteProjectInvoiceAsync(Guid projectId, Guid invoiceId, CancellationToken ct = default)
    {
        var invoice = await db.ProjectInvoices
            .FirstOrDefaultAsync(i => i.ProjectId == projectId && i.Id == invoiceId, ct);

        if (invoice == null) return false;

        db.ProjectInvoices.Remove(invoice);
        await db.SaveChangesAsync(ct);
        await RecalculateProjectInvoiceRollupAsync(projectId, ct);

        return true;
    }

    public async Task<AutoGenerateInvoicesSummaryDto> AutoGenerateInvoicesAsync(Guid projectId, CancellationToken ct = default)
    {
        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == projectId, ct)
            ?? throw new NotFoundException($"Project with ID '{projectId}' was not found.");

        var totalBudget = project.Budget ?? project.InvoiceValue ?? 0m;
        var taxPercent = project.TaxPercent;
        var billingModel = (project.BillingModel ?? "50-50").Trim();

        var newInvoices = new List<ProjectInvoice>();

        if (billingModel.Contains("100", StringComparison.OrdinalIgnoreCase) || billingModel.Contains("Upfront", StringComparison.OrdinalIgnoreCase))
        {
            var amount = totalBudget;
            var tax = Math.Round(amount * (taxPercent / 100m), 2);
            newInvoices.Add(new ProjectInvoice
            {
                ProjectId = projectId,
                MilestoneName = "100% Upfront Advance Payment",
                Percentage = 100m,
                Amount = amount,
                TaxAmount = tax,
                TotalAmount = amount + tax,
                Status = "Pending",
                DueDate = project.StartDate,
                SortOrder = 1
            });
        }
        else if (billingModel.Contains("Quarter", StringComparison.OrdinalIgnoreCase))
        {
            var qAmount = Math.Round(totalBudget * 0.25m, 2);
            var qTax = Math.Round(qAmount * (taxPercent / 100m), 2);
            for (int q = 1; q <= 4; q++)
            {
                newInvoices.Add(new ProjectInvoice
                {
                    ProjectId = projectId,
                    MilestoneName = $"Q{q} Milestone (25%)",
                    Percentage = 25m,
                    Amount = qAmount,
                    TaxAmount = qTax,
                    TotalAmount = qAmount + qTax,
                    Status = "Pending",
                    SortOrder = q
                });
            }
        }
        else if (billingModel.Contains("Month", StringComparison.OrdinalIgnoreCase))
        {
            var mAmount = Math.Round(totalBudget / 12m, 2);
            var mTax = Math.Round(mAmount * (taxPercent / 100m), 2);
            var mPct = Math.Round(100m / 12m, 2);
            for (int m = 1; m <= 12; m++)
            {
                newInvoices.Add(new ProjectInvoice
                {
                    ProjectId = projectId,
                    MilestoneName = $"Month {m} Retainer ({mPct}%)",
                    Percentage = mPct,
                    Amount = mAmount,
                    TaxAmount = mTax,
                    TotalAmount = mAmount + mTax,
                    Status = "Pending",
                    SortOrder = m
                });
            }
        }
        else
        {
            // Default 50-50 milestone model
            var halfAmount = Math.Round(totalBudget * 0.50m, 2);
            var halfTax = Math.Round(halfAmount * (taxPercent / 100m), 2);

            newInvoices.Add(new ProjectInvoice
            {
                ProjectId = projectId,
                MilestoneName = "50% Advance Payment on Kickoff",
                Percentage = 50m,
                Amount = halfAmount,
                TaxAmount = halfTax,
                TotalAmount = halfAmount + halfTax,
                Status = "Pending",
                DueDate = project.StartDate,
                SortOrder = 1
            });

            newInvoices.Add(new ProjectInvoice
            {
                ProjectId = projectId,
                MilestoneName = "50% Final Payment on Completion",
                Percentage = 50m,
                Amount = halfAmount,
                TaxAmount = halfTax,
                TotalAmount = halfAmount + halfTax,
                Status = "Pending",
                DueDate = project.EndDate,
                SortOrder = 2
            });
        }

        if (newInvoices.Count > 0)
        {
            db.ProjectInvoices.AddRange(newInvoices);
            await db.SaveChangesAsync(ct);
            await RecalculateProjectInvoiceRollupAsync(projectId, ct);
        }

        var mapped = newInvoices.Select(MapToInvoiceDto).ToList();
        var totalVal = mapped.Sum(i => i.TotalAmount);

        return new AutoGenerateInvoicesSummaryDto(projectId, newInvoices.Count, totalVal, mapped);
    }

    // ── Project Documents Methods ──

    public async Task<IReadOnlyList<ProjectDocumentDto>> GetProjectDocumentsAsync(Guid projectId, CancellationToken ct = default)
    {
        var exists = await db.Projects.AnyAsync(p => p.Id == projectId, ct);
        if (!exists)
            throw new NotFoundException($"Project with ID '{projectId}' was not found.");

        var docs = await db.ProjectDocuments
            .Where(d => d.ProjectId == projectId)
            .OrderByDescending(d => d.CreatedAtUtc)
            .ToListAsync(ct);

        return docs.Select(MapToDocumentDto).ToList();
    }

    public async Task<ProjectDocumentDto?> GetProjectDocumentByIdAsync(Guid projectId, Guid documentId, CancellationToken ct = default)
    {
        var doc = await db.ProjectDocuments
            .FirstOrDefaultAsync(d => d.ProjectId == projectId && d.Id == documentId, ct);

        return doc == null ? null : MapToDocumentDto(doc);
    }

    public async Task<ProjectDocumentDto> UploadProjectDocumentAsync(Guid projectId, string? documentType, string? description, Microsoft.AspNetCore.Http.IFormFile file, CancellationToken ct = default)
    {
        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == projectId, ct)
            ?? throw new NotFoundException($"Project with ID '{projectId}' was not found.");

        if (file == null || file.Length == 0)
        {
            throw new InvalidOperationException("No file was uploaded.");
        }

        var category = string.IsNullOrWhiteSpace(documentType) ? "po" : documentType.Trim();
        var stored = await fileStorage.SaveProjectDocumentAsync(project.ProjectCode, category, file, ct);

        var docType = string.IsNullOrWhiteSpace(documentType) ? "PO" : documentType.Trim();

        var doc = new ProjectDocument
        {
            ProjectId = projectId,
            DocumentType = docType,
            FileName = stored.FileName,
            OriginalFileName = stored.OriginalFileName,
            FilePath = stored.RelativePath,
            ContentType = stored.ContentType,
            SizeBytes = stored.SizeBytes,
            Description = description
        };

        if (docType.Equals("PO", StringComparison.OrdinalIgnoreCase))
        {
            project.PoStatus = "Uploaded";
        }

        db.ProjectDocuments.Add(doc);
        await db.SaveChangesAsync(ct);

        return MapToDocumentDto(doc);
    }

    public async Task<(Stream Stream, string ContentType, string DownloadFileName)> DownloadProjectDocumentAsync(Guid projectId, Guid documentId, CancellationToken ct = default)
    {
        var doc = await db.ProjectDocuments.FirstOrDefaultAsync(d => d.ProjectId == projectId && d.Id == documentId, ct)
            ?? throw new NotFoundException($"Project Document with ID '{documentId}' was not found.");

        var fileResult = fileStorage.GetProjectFileStream(doc.FilePath);
        if (fileResult == null)
        {
            throw new NotFoundException($"Document file '{doc.FileName}' was not found in storage.");
        }

        return (fileResult.Value.Stream, fileResult.Value.ContentType, doc.OriginalFileName);
    }

    public async Task<bool> DeleteProjectDocumentAsync(Guid projectId, Guid documentId, CancellationToken ct = default)
    {
        var doc = await db.ProjectDocuments.FirstOrDefaultAsync(d => d.ProjectId == projectId && d.Id == documentId, ct);
        if (doc == null) return false;

        fileStorage.DeleteProjectFile(doc.FilePath);
        db.ProjectDocuments.Remove(doc);
        await db.SaveChangesAsync(ct);
        return true;
    }

    private async Task RecalculateProjectInvoiceRollupAsync(Guid projectId, CancellationToken ct)
    {
        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == projectId, ct);
        if (project == null) return;

        var totalInvoiced = await db.ProjectInvoices
            .Where(i => i.ProjectId == projectId)
            .SumAsync(i => i.TotalAmount, ct);

        if (totalInvoiced > 0)
        {
            project.InvoiceValue = totalInvoiced;
            await db.SaveChangesAsync(ct);
        }
    }

    public async Task<ProjectDto> RenewProjectAsync(Guid id, RenewProjectRequest request, CancellationToken ct = default)
    {
        var orig = await db.Projects
            .Include(p => p.Client)
            .Include(p => p.SubVenture)
            .FirstOrDefaultAsync(p => p.Id == id, ct)
            ?? throw new NotFoundException($"Project with ID '{id}' was not found.");

        await using var tx = await db.Database.BeginTransactionAsync(ct);

        await db.Database.ExecuteSqlRawAsync(
            "SELECT pg_advisory_xact_lock(hashtext('project_seq_' || {0}));",
            orig.ClientId.ToString());

        var nextCodeDto = await CalculateNextCodesInternalAsync(orig.ClientId, orig.Client?.Name ?? string.Empty, ct);

        var subDeptNames = await db.ProjectServices
            .Where(s => s.ProjectId == id && !string.IsNullOrWhiteSpace(s.SubDepartment))
            .Select(s => s.SubDepartment!)
            .Distinct()
            .ToListAsync(ct);

        var resolvedName = !string.IsNullOrWhiteSpace(request.Name)
            ? request.Name.Trim()
            : BuildProjectName(orig.Client?.Name ?? string.Empty, orig.SubVenture?.Name, subDeptNames, nextCodeDto.ClientProjectCount);

        var renewedProject = new Project
        {
            ProjectCode = nextCodeDto.ProjectSeqId,
            WbsId = nextCodeDto.WbsId,
            Name = resolvedName,
            Description = orig.Description,
            ClientId = orig.ClientId,
            SubVentureId = orig.SubVentureId,
            Status = "ongoing",
            Health = "green",
            ContractType = orig.ContractType,
            ProjectType = orig.ProjectType,
            Currency = orig.Currency,
            TaxPercent = orig.TaxPercent,
            StartDate = request.StartDate ?? orig.StartDate,
            EndDate = request.EndDate ?? orig.EndDate,
            Budget = orig.Budget,
            Spent = 0m,
            TotalHours = orig.TotalHours,
            TotalDays = orig.TotalDays,
            InvoiceValue = orig.InvoiceValue,
            ProjectManagerId = orig.ProjectManagerId,
            TeamLeadId = orig.TeamLeadId,
            EngagementManager = orig.EngagementManager,
            EngagementManagerId = orig.EngagementManagerId,
            SalesPerson = orig.SalesPerson,
            SalesPersonId = orig.SalesPersonId,
            ProjectIssuedDate = DateOnly.FromDateTime(DateTime.UtcNow),
            SectionAComments = orig.SectionAComments,
            SectionBComments = orig.SectionBComments,
            WbsStatus = "draft",
            WbsSubStatus = "Draft",
            RenewedFromProjectId = orig.Id,
            PoStatus = request.PoNumber != null ? "received" : "pending",
            PoNumber = request.PoNumber,
            PoDate = request.PoDate,
            BillingModel = orig.BillingModel,
            PaymentTerms = orig.PaymentTerms,
            TargetDate = orig.TargetDate,
            AccountContactName = orig.AccountContactName,
            AccountContactPhone = orig.AccountContactPhone,
            AccountContactEmail = orig.AccountContactEmail
        };

        db.Projects.Add(renewedProject);
        await db.SaveChangesAsync(ct);

        var serviceIdMapping = new Dictionary<Guid, Guid>();

        if (request.CloneServices)
        {
            var origServices = await db.ProjectServices
                .Include(s => s.ResourceLevels)
                .Where(s => s.ProjectId == id)
                .OrderBy(s => s.SortOrder)
                .ToListAsync(ct);

            foreach (var os in origServices)
            {
                var newService = new ProjectServiceEntity
                {
                    ProjectId = renewedProject.Id,
                    ServiceCatalogId = os.ServiceCatalogId,
                    TaskId = os.TaskId,
                    Department = os.Department,
                    SubDepartment = os.SubDepartment,
                    ServiceName = os.ServiceName,
                    Qty = os.Qty,
                    Description = os.Description,
                    ResourceLevel = os.ResourceLevel,
                    Frequency = os.Frequency,
                    Location = os.Location,
                    LocationText = os.LocationText,
                    ServiceModel = os.ServiceModel,
                    DeliveryModel = os.DeliveryModel,
                    FinalDeliveryFormat = os.FinalDeliveryFormat,
                    BillingModel = os.BillingModel,
                    Tools = os.Tools,
                    StartDate = renewedProject.StartDate,
                    EndDate = renewedProject.EndDate,
                    DurationDays = os.DurationDays,
                    DurationHours = os.DurationHours,
                    TotalDays = os.TotalDays,
                    TotalHours = os.TotalHours,
                    UnitPrice = os.UnitPrice,
                    Total = os.Total,
                    SortOrder = os.SortOrder
                };

                foreach (var rl in os.ResourceLevels)
                {
                    newService.ResourceLevels.Add(new ProjectServiceResourceLevel
                    {
                        Level = rl.Level,
                        Count = rl.Count
                    });
                }

                db.ProjectServices.Add(newService);
                await db.SaveChangesAsync(ct);
                serviceIdMapping[os.Id] = newService.Id;
            }
        }

        if (request.CloneTasks)
        {
            var origTasks = await db.ProjectTasks
                .Where(t => t.ProjectId == id)
                .OrderBy(t => t.SortOrder)
                .ToListAsync(ct);

            foreach (var ot in origTasks)
            {
                Guid? newServiceId = null;
                if (ot.ProjectServiceId.HasValue && serviceIdMapping.TryGetValue(ot.ProjectServiceId.Value, out var mappedId))
                {
                    newServiceId = mappedId;
                }

                var newTask = new ProjectTask
                {
                    ProjectId = renewedProject.Id,
                    ProjectServiceId = newServiceId,
                    Title = ot.Title,
                    Description = ot.Description,
                    Period = ot.Period,
                    Phase = ot.Phase,
                    Stage = "Ready to Start",
                    Priority = ot.Priority,
                    PlannedStartDate = renewedProject.StartDate,
                    PlannedEndDate = renewedProject.EndDate,
                    EstimatedHours = ot.EstimatedHours,
                    UtilizedHours = 0m,
                    Progress = 0,
                    SortOrder = ot.SortOrder
                };

                db.ProjectTasks.Add(newTask);
            }

            await db.SaveChangesAsync(ct);
        }

        await tx.CommitAsync(ct);

        return (await GetProjectByIdAsync(renewedProject.Id, ct))!;
    }

    public async Task<ProjectDto> SaveWbsDraftAsync(Guid id, SaveWbsDraftRequest request, CancellationToken ct = default)
    {
        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == id, ct)
            ?? throw new NotFoundException($"Project with ID '{id}' was not found.");

        project.WbsStatus = "draft";
        project.WbsSubStatus = request.WbsSubStatus ?? "Draft";
        if (request.SectionAComments != null) project.SectionAComments = request.SectionAComments;
        if (request.SectionBComments != null) project.SectionBComments = request.SectionBComments;

        if (request.Services != null)
        {
            var existingServices = await db.ProjectServices.Include(s => s.ResourceLevels).Where(s => s.ProjectId == id).ToListAsync(ct);
            db.ProjectServices.RemoveRange(existingServices);
            await db.SaveChangesAsync(ct);

            foreach (var sReq in request.Services)
            {
                await AddProjectServiceAsync(id, sReq, ct);
            }
        }

        if (request.Tasks != null)
        {
            var existingTasks = await db.ProjectTasks.Where(t => t.ProjectId == id).ToListAsync(ct);
            db.ProjectTasks.RemoveRange(existingTasks);
            await db.SaveChangesAsync(ct);

            foreach (var tReq in request.Tasks)
            {
                await CreateProjectTaskAsync(id, tReq, ct);
            }
        }

        await db.SaveChangesAsync(ct);
        await RecalculateProjectRollupsAsync(id, ct);

        return (await GetProjectByIdAsync(id, ct))!;
    }

    public async Task<WbsPublishResultDto> PublishWbsAsync(Guid id, PublishWbsRequest? request = null, CancellationToken ct = default)
    {
        var project = await db.Projects.Include(p => p.Client).FirstOrDefaultAsync(p => p.Id == id, ct)
            ?? throw new NotFoundException($"Project with ID '{id}' was not found.");

        var services = await db.ProjectServices.Include(s => s.ResourceLevels).Where(s => s.ProjectId == id).ToListAsync(ct);
        if (services.Count == 0)
        {
            throw new ConflictException("Cannot publish WBS: At least one Project Service must be configured in Section A.");
        }

        var tasks = await db.ProjectTasks.Where(t => t.ProjectId == id).ToListAsync(ct);

        project.WbsStatus = "published";
        project.WbsSubStatus = "Published";

        if (!string.IsNullOrWhiteSpace(request?.PublishComments))
        {
            project.SectionAComments = string.IsNullOrWhiteSpace(project.SectionAComments)
                ? request.PublishComments
                : $"{project.SectionAComments}\n[Published]: {request.PublishComments}";
        }

        await db.SaveChangesAsync(ct);

        return new WbsPublishResultDto(
            project.Id,
            project.WbsId ?? project.ProjectCode,
            project.WbsStatus,
            project.WbsSubStatus,
            services.Count,
            tasks.Count,
            project.Budget ?? 0m,
            project.TotalHours ?? 0m,
            DateTime.UtcNow);
    }

    private static ProjectDto MapToDto(Project p)
    {
        return new ProjectDto(
            p.Id,
            p.ProjectCode,
            p.WbsId,
            p.Name,
            p.Description,
            p.ClientId,
            p.Client?.Name ?? string.Empty,
            p.Client?.Logo,
            p.SubVentureId,
            p.SubVenture?.Name,
            p.Status,
            p.Health,
            p.Progress,
            p.ContractType,
            p.ProjectType,
            p.Currency,
            p.TaxPercent,
            p.StartDate,
            p.EndDate,
            p.Budget,
            p.Spent,
            p.TotalHours,
            p.TotalDays,
            p.InvoiceValue,
            p.ProjectManagerId,
            p.ProjectManager != null ? $"{p.ProjectManager.FirstName} {p.ProjectManager.LastName}".Trim() : null,
            p.TeamLeadId,
            p.TeamLead != null ? $"{p.TeamLead.FirstName} {p.TeamLead.LastName}".Trim() : null,
            p.EngagementManager,
            p.EngagementManagerId,
            p.SalesPerson,
            p.SalesPersonId,
            p.ProjectIssuedDate,
            p.SectionAComments,
            p.SectionBComments,
            p.WbsStatus,
            p.WbsSubStatus,
            p.RenewedFromProjectId,
            p.RenewedFromProject?.WbsId,
            p.PoStatus,
            p.PoNumber,
            p.PoDate,
            p.BillingModel,
            p.PaymentTerms,
            p.TargetDate,
            p.AccountContactName,
            p.AccountContactPhone,
            p.AccountContactEmail,
            p.CreatedAtUtc,
            p.UpdatedAtUtc);
    }

    private static ProjectServiceDto MapToServiceDto(ProjectServiceEntity s)
    {
        return new ProjectServiceDto(
            s.Id,
            s.ProjectId,
            s.ServiceCatalogId,
            s.TaskId,
            s.Department,
            s.SubDepartment,
            s.ServiceName,
            s.Qty,
            s.Description,
            s.ResourceLevel,
            s.Frequency,
            s.Location,
            s.LocationText,
            s.ServiceModel,
            s.DeliveryModel,
            s.FinalDeliveryFormat,
            s.BillingModel,
            s.Tools,
            s.StartDate,
            s.EndDate,
            s.DurationDays,
            s.DurationHours,
            s.TotalDays,
            s.TotalHours,
            s.UnitPrice,
            s.Total,
            s.SortOrder,
            s.ResourceLevels.Select(r => new ProjectServiceResourceLevelDto(r.Id, r.Level, r.Count)).ToList(),
            s.CreatedAtUtc,
            s.UpdatedAtUtc);
    }

    private static ProjectTaskDto MapToTaskDto(ProjectTask t)
    {
        return new ProjectTaskDto(
            t.Id,
            t.ProjectId,
            t.ProjectServiceId,
            t.ProjectService?.ServiceName,
            t.Title,
            t.Description,
            t.Period,
            t.Phase,
            t.Stage,
            t.Priority,
            t.PlannedStartDate,
            t.PlannedEndDate,
            t.ActualStartDate,
            t.ActualEndDate,
            t.EstimatedHours,
            t.UtilizedHours,
            t.Progress,
            t.SortOrder,
            t.CreatedAtUtc,
            t.UpdatedAtUtc);
    }

    private static ProjectTaskAssignmentDto MapToAssignmentDto(ProjectTaskAssignment a)
    {
        var currentAccumulated = a.TimerAccumulatedSeconds;
        if (a.TimerStartedAtUtc.HasValue)
        {
            var activeSecs = (long)(DateTime.UtcNow - a.TimerStartedAtUtc.Value).TotalSeconds;
            currentAccumulated += Math.Max(0, activeSecs);
        }

        var employeeName = a.Employee != null
            ? $"{a.Employee.FirstName} {a.Employee.LastName}".Trim()
            : string.Empty;

        return new ProjectTaskAssignmentDto(
            a.Id,
            a.TaskId,
            a.EmployeeId,
            employeeName,
            a.Employee?.EmployeeCode ?? string.Empty,
            a.Employee?.WorkEmail,
            a.Role,
            a.AllocatedHours,
            a.UtilizedHours,
            a.TimerStartedAtUtc,
            currentAccumulated,
            a.IsActive,
            a.TimerStartedAtUtc.HasValue,
            a.CreatedAtUtc,
            a.UpdatedAtUtc);
    }

    private static ProjectInvoiceDto MapToInvoiceDto(ProjectInvoice i)
    {
        return new ProjectInvoiceDto(
            i.Id,
            i.ProjectId,
            i.MilestoneName,
            i.Percentage,
            i.Amount,
            i.TaxAmount,
            i.TotalAmount,
            i.Status,
            i.InvoiceNumber,
            i.InvoiceDate,
            i.DueDate,
            i.PaymentDate,
            i.Remarks,
            i.SortOrder,
            i.CreatedAtUtc,
            i.UpdatedAtUtc);
    }

    private static ProjectDocumentDto MapToDocumentDto(ProjectDocument d)
    {
        return new ProjectDocumentDto(
            d.Id,
            d.ProjectId,
            d.DocumentType,
            d.FileName,
            d.OriginalFileName,
            d.FilePath,
            d.ContentType,
            d.SizeBytes,
            d.Description,
            d.CreatedAtUtc,
            d.UpdatedAtUtc);
    }
}






