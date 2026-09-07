using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Infrastructure.Storage;
using PMS.API.Modules.Repository.DTOs;
using PMS.API.Modules.Repository.Models;
using PMS.API.Modules.Users.Models;
using PMS.API.Shared.Common.Wrappers;
using PMS.API.Shared.Constants;

namespace PMS.API.Modules.Repository.Services;

public class RepositoryService(
    AppDbContext db,
    IFileStorageService storage,
    ICurrentUserService currentUser,
    ILogger<RepositoryService> logger) : IRepositoryService
{
    public async Task<PagedResult<RepositoryItemDto>> GetDocumentsAsync(
        int page,
        int perPage,
        string? category = null,
        string? search = null,
        CancellationToken ct = default)
    {
        var query = await ApplyVisibilityAsync(db.RepositoryItems.AsNoTracking(), ct);

        if (!string.IsNullOrWhiteSpace(category))
        {
            var catNorm = FileStorageService.NormalizeRepositoryCategoryDisplay(category);
            query = query.Where(r => r.Category == catNorm || EF.Functions.ILike(r.Category, $"%{catNorm}%"));
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var s = search.Trim();
            query = query.Where(r =>
                EF.Functions.ILike(r.FileName, $"%{s}%") ||
                EF.Functions.ILike(r.UploadedBy, $"%{s}%") ||
                EF.Functions.ILike(r.Category, $"%{s}%"));
        }

        var total = await query.CountAsync(ct);

        var items = await query
            .OrderByDescending(r => r.LastUpdated)
            .ThenByDescending(r => r.CreatedAtUtc)
            .Skip((page - 1) * perPage)
            .Take(perPage)
            .Select(r => new RepositoryItemDto(
                r.Id,
                r.FileName,
                r.Category,
                r.Size,
                r.LastUpdated,
                r.UploadedBy,
                r.CreatedAtUtc,
                r.Departments
                    .OrderBy(d => d.Department!.Name)
                    .Select(d => new RepositoryDepartmentDto(d.DepartmentId, d.Department!.Name))
                    .ToList()))
            .ToListAsync(ct);

        return new PagedResult<RepositoryItemDto>(items, page, perPage, total);
    }

    public async Task<RepositoryItemDto> UploadDocumentAsync(
        string category,
        IFormFile file,
        string? userEmailOrName = null,
        IReadOnlyList<Guid>? departmentIds = null,
        CancellationToken ct = default)
    {
        if (file == null || file.Length == 0)
        {
            throw new ArgumentException("No file provided for upload.");
        }

        var uniqueDeptIds = (departmentIds ?? [])
            .Where(id => id != Guid.Empty)
            .Distinct()
            .ToList();

        if (uniqueDeptIds.Count == 0)
        {
            throw new InvalidOperationException("Select at least one department that may view this document.");
        }

        var validDeptIds = await db.Departments
            .Where(d => d.IsActive && uniqueDeptIds.Contains(d.Id))
            .Select(d => d.Id)
            .ToListAsync(ct);

        if (validDeptIds.Count == 0)
        {
            throw new InvalidOperationException("None of the selected departments are valid. Refresh and try again.");
        }

        // Save file physically into category folder
        var stored = await storage.SaveRepositoryDocumentAsync(category, file, ct);

        // Resolve uploader name from active employees
        var uploader = await ResolveEmployeeNameAsync(userEmailOrName, ct);

        var doc = new RepositoryItem
        {
            Id = Guid.NewGuid(),
            FileName = stored.FileName,
            Category = stored.Category,
            Size = stored.SizeBytes,
            LastUpdated = DateTime.UtcNow,
            UploadedBy = uploader,
            FilePath = stored.RelativePath,
            CreatedAtUtc = DateTime.UtcNow,
            CreatedBy = currentUser.UserId
        };

        foreach (var deptId in validDeptIds)
        {
            doc.Departments.Add(new RepositoryDepartment
            {
                RepositoryItemId = doc.Id,
                DepartmentId = deptId,
            });
        }

        db.RepositoryItems.Add(doc);

        // Maintain Activity Log for upload
        var log = new RepositoryActivityLog
        {
            Id = Guid.NewGuid(),
            Action = "Uploaded",
            DocumentId = doc.Id,
            FileName = doc.FileName,
            Category = doc.Category,
            PerformedBy = uploader,
            Details = $"{uploader} uploaded {doc.FileName}",
            CreatedAtUtc = DateTime.UtcNow
        };

        db.RepositoryActivityLogs.Add(log);

        await db.SaveChangesAsync(ct);

        logger.LogInformation("Repository document uploaded: {FileName} ({Category}) by {User}", doc.FileName, doc.Category, uploader);

        var deptNames = await db.Departments
            .AsNoTracking()
            .Where(d => validDeptIds.Contains(d.Id))
            .OrderBy(d => d.Name)
            .Select(d => new RepositoryDepartmentDto(d.Id, d.Name))
            .ToListAsync(ct);

        return new RepositoryItemDto(
            doc.Id,
            doc.FileName,
            doc.Category,
            doc.Size,
            doc.LastUpdated,
            doc.UploadedBy,
            doc.CreatedAtUtc,
            deptNames);
    }

    public async Task<RepositoryItem?> GetDocumentByIdAsync(Guid id, CancellationToken ct = default)
    {
        if (!await CanAccessDocumentAsync(id, ct))
            return null;

        return await db.RepositoryItems.FirstOrDefaultAsync(r => r.Id == id, ct);
    }

    public async Task<bool> CanAccessDocumentAsync(Guid id, CancellationToken ct = default)
    {
        var exists = await db.RepositoryItems.AnyAsync(r => r.Id == id, ct);
        if (!exists) return false;

        var scope = await ResolveViewerScopeAsync(ct);
        if (scope.Unrestricted) return true;

        var hasAssignments = await db.RepositoryDepartments.AnyAsync(d => d.RepositoryItemId == id, ct);
        if (!hasAssignments) return true; // legacy documents stay visible

        if (currentUser.UserId.HasValue)
        {
            var uploadedByCurrentUser = await db.RepositoryItems
                .AnyAsync(r => r.Id == id && r.CreatedBy == currentUser.UserId, ct);
            if (uploadedByCurrentUser) return true;
        }

        if (scope.DepartmentId is null) return false;

        return await db.RepositoryDepartments
            .AnyAsync(d => d.RepositoryItemId == id && d.DepartmentId == scope.DepartmentId, ct);
    }

    public async Task<IReadOnlyList<RepositoryDepartmentOptionDto>> GetDepartmentOptionsAsync(CancellationToken ct = default)
    {
        return await db.Departments
            .AsNoTracking()
            .Where(d => d.IsActive)
            .OrderBy(d => d.Name)
            .Select(d => new RepositoryDepartmentOptionDto(d.Id, d.Code, d.Name))
            .ToListAsync(ct);
    }

    public async Task RecordViewAsync(
        Guid documentId,
        string? userEmailOrName = null,
        string action = "Downloaded",
        CancellationToken ct = default)
    {
        var doc = await db.RepositoryItems.FirstOrDefaultAsync(r => r.Id == documentId, ct);
        if (doc == null) return;
        if (!await CanAccessDocumentAsync(documentId, ct)) return;

        var viewer = await ResolveEmployeeNameAsync(userEmailOrName, ct);

        var log = new RepositoryActivityLog
        {
            Id = Guid.NewGuid(),
            Action = string.IsNullOrWhiteSpace(action) ? "Downloaded" : action,
            DocumentId = doc.Id,
            FileName = doc.FileName,
            Category = doc.Category,
            PerformedBy = viewer,
            Details = $"{viewer} {action.ToLower()} {doc.FileName}",
            CreatedAtUtc = DateTime.UtcNow
        };

        db.RepositoryActivityLogs.Add(log);
        await db.SaveChangesAsync(ct);
    }

    public async Task<bool> DeleteDocumentAsync(
        Guid id,
        string? userEmailOrName = null,
        CancellationToken ct = default)
    {
        var doc = await db.RepositoryItems.FirstOrDefaultAsync(r => r.Id == id, ct);
        if (doc == null) return false;
        if (!await CanAccessDocumentAsync(id, ct)) return false;

        // Try physical file deletion by category and filename
        storage.DeleteRepositoryFile(doc.Category, doc.FileName);

        // Soft delete from database
        db.RepositoryItems.Remove(doc);

        var performer = await ResolveEmployeeNameAsync(userEmailOrName, ct);

        // Maintain Activity Log for deletion
        var log = new RepositoryActivityLog
        {
            Id = Guid.NewGuid(),
            Action = "Deleted",
            DocumentId = doc.Id,
            FileName = doc.FileName,
            Category = doc.Category,
            PerformedBy = performer,
            Details = $"Deleted {doc.FileName} from {doc.Category}",
            CreatedAtUtc = DateTime.UtcNow
        };

        db.RepositoryActivityLogs.Add(log);

        await db.SaveChangesAsync(ct);

        logger.LogInformation("Repository document deleted: {FileName} ({Id}) by {User}", doc.FileName, id, performer);

        return true;
    }

    public async Task<IReadOnlyList<RepositoryActivityLogDto>> GetActivityLogsAsync(
        int limit = 100,
        CancellationToken ct = default)
    {
        limit = Math.Clamp(limit, 1, 500);

        return await db.RepositoryActivityLogs
            .AsNoTracking()
            .OrderByDescending(l => l.CreatedAtUtc)
            .Take(limit)
            .Select(l => new RepositoryActivityLogDto(
                l.Id,
                l.Action,
                l.DocumentId,
                l.FileName,
                l.Category,
                l.PerformedBy,
                l.Details,
                l.CreatedAtUtc))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<RepositoryActivityLogDto>> GetDocumentLogsAsync(
        Guid documentId,
        CancellationToken ct = default)
    {
        return await db.RepositoryActivityLogs
            .AsNoTracking()
            .Where(l => l.DocumentId == documentId)
            .OrderByDescending(l => l.CreatedAtUtc)
            .Select(l => new RepositoryActivityLogDto(
                l.Id,
                l.Action,
                l.DocumentId,
                l.FileName,
                l.Category,
                l.PerformedBy,
                l.Details,
                l.CreatedAtUtc))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<DocumentAccessSummaryDto>> GetDocumentAccessSummariesAsync(
        string? category = null,
        string? search = null,
        CancellationToken ct = default)
    {
        var docQuery = await ApplyVisibilityAsync(db.RepositoryItems.AsNoTracking(), ct);

        if (!string.IsNullOrWhiteSpace(category))
        {
            var normalizedCategory = FileStorageService.NormalizeRepositoryCategoryDisplay(category);
            docQuery = docQuery.Where(r => r.Category == normalizedCategory || EF.Functions.ILike(r.Category, $"%{normalizedCategory}%"));
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var s = search.Trim().ToLower();
            docQuery = docQuery.Where(r => r.FileName.ToLower().Contains(s) || r.UploadedBy.ToLower().Contains(s));
        }

        var docs = await docQuery.OrderByDescending(r => r.CreatedAtUtc).ToListAsync(ct);
        if (docs.Count == 0) return [];

        var docIds = docs.Select(d => d.Id).ToList();

        var accessLogs = await db.RepositoryActivityLogs
            .AsNoTracking()
            .Where(l => l.DocumentId != null && docIds.Contains(l.DocumentId.Value))
            .OrderByDescending(l => l.CreatedAtUtc)
            .ToListAsync(ct);

        var groupedLogs = accessLogs
            .GroupBy(l => l.DocumentId!.Value)
            .ToDictionary(g => g.Key, g => g.ToList());

        var result = new List<DocumentAccessSummaryDto>();

        foreach (var doc in docs)
        {
            var logs = groupedLogs.GetValueOrDefault(doc.Id) ?? [];
            var downloadOrViewLogs = logs
                .Where(l => l.Action == "Downloaded" || l.Action == "Viewed" || l.Action == "Uploaded")
                .ToList();

            var accessors = downloadOrViewLogs.Select(l => new DocumentAccessEntryDto(
                l.Id,
                l.PerformedBy,
                l.Action,
                l.CreatedAtUtc,
                l.Details
            )).ToList();

            var uniqueUsers = accessors.Select(a => a.EmployeeName.Trim().ToLower()).Distinct().Count();

            result.Add(new DocumentAccessSummaryDto(
                doc.Id,
                doc.FileName,
                doc.Category,
                doc.Size,
                doc.LastUpdated,
                doc.UploadedBy,
                accessors.Count(a => a.Action == "Downloaded" || a.Action == "Viewed"),
                uniqueUsers,
                accessors
            ));
        }

        return result;
    }

    public async Task<IReadOnlyList<RepositoryCategoryCountDto>> GetCategoryCountsAsync(CancellationToken ct = default)
    {
        var visible = await ApplyVisibilityAsync(db.RepositoryItems.AsNoTracking(), ct);
        var counts = await visible
            .GroupBy(r => r.Category)
            .Select(g => new { Category = g.Key, Count = g.Count() })
            .ToListAsync(ct);

        var techCount = counts.FirstOrDefault(c => c.Category == "Tech")?.Count ?? 0;
        var pmsCount = counts.FirstOrDefault(c => c.Category == "PMS")?.Count ?? 0;
        var impCount = counts.FirstOrDefault(c => c.Category == "IMP")?.Count ?? 0;

        return
        [
            new RepositoryCategoryCountDto("tech", "Tech. SOPs", "Technical Standard Operating Procedures for engineering and infrastructure.", techCount),
            new RepositoryCategoryCountDto("pms", "PMS. SOPs", "Project Management System Standard Operating Procedures.", pmsCount),
            new RepositoryCategoryCountDto("imp", "IMP Templates", "Important templates, company-wide policies, guidelines, and compliance documents.", impCount)
        ];
    }

    private async Task<string> ResolveEmployeeNameAsync(string? providedNameOrEmail, CancellationToken ct = default)
    {
        if (!string.IsNullOrWhiteSpace(providedNameOrEmail))
        {
            var raw = providedNameOrEmail.Trim();
            if (raw.Contains('@'))
            {
                var emp = await db.Employees
                    .AsNoTracking()
                    .FirstOrDefaultAsync(e => EF.Functions.ILike(e.WorkEmail, raw) || (e.PersonalEmail != null && EF.Functions.ILike(e.PersonalEmail, raw)), ct);
                if (emp != null && !string.IsNullOrWhiteSpace(emp.FirstName))
                {
                    return $"{emp.FirstName} {emp.LastName}".Trim();
                }
            }
            return raw;
        }

        if (currentUser.UserId.HasValue)
        {
            var emp = await db.Employees
                .AsNoTracking()
                .FirstOrDefaultAsync(e => e.Id == currentUser.UserId.Value || e.UserId == currentUser.UserId.Value, ct);
            if (emp != null && !string.IsNullOrWhiteSpace(emp.FirstName))
            {
                return $"{emp.FirstName} {emp.LastName}".Trim();
            }
        }

        if (!string.IsNullOrWhiteSpace(currentUser.Email))
        {
            var emp = await db.Employees
                .AsNoTracking()
                .FirstOrDefaultAsync(e => EF.Functions.ILike(e.WorkEmail, currentUser.Email), ct);
            if (emp != null && !string.IsNullOrWhiteSpace(emp.FirstName))
            {
                return $"{emp.FirstName} {emp.LastName}".Trim();
            }
            return currentUser.Email;
        }

        return "Dhanshree Pansare";
    }

    private sealed record ViewerScope(bool Unrestricted, Guid? DepartmentId);

    private async Task<ViewerScope> ResolveViewerScopeAsync(CancellationToken ct)
    {
        var role = currentUser.Role ?? "";
        if (string.Equals(role, nameof(UserRole.Admin), StringComparison.OrdinalIgnoreCase)
            || string.Equals(role, nameof(UserRole.Dhanshree), StringComparison.OrdinalIgnoreCase)
            || string.Equals(role, nameof(UserRole.BusinessOwner), StringComparison.OrdinalIgnoreCase)
            || currentUser.HasPermission(Permissions.UsersManage))
        {
            return new ViewerScope(true, null);
        }

        Guid? departmentId = null;

        if (currentUser.UserId.HasValue)
        {
            var uid = currentUser.UserId.Value;
            departmentId = await db.Employees
                .AsNoTracking()
                .Where(e => e.UserId == uid || e.Id == uid)
                .Select(e => e.DepartmentId)
                .FirstOrDefaultAsync(ct);
        }

        if (departmentId is null && !string.IsNullOrWhiteSpace(currentUser.Email))
        {
            var email = currentUser.Email.Trim();
            departmentId = await db.Employees
                .AsNoTracking()
                .Where(e => EF.Functions.ILike(e.WorkEmail, email))
                .Select(e => e.DepartmentId)
                .FirstOrDefaultAsync(ct);
        }

        return new ViewerScope(false, departmentId);
    }

    private async Task<IQueryable<RepositoryItem>> ApplyVisibilityAsync(
        IQueryable<RepositoryItem> query,
        CancellationToken ct)
    {
        var scope = await ResolveViewerScopeAsync(ct);
        if (scope.Unrestricted) return query;

        var userId = currentUser.UserId;
        var deptId = scope.DepartmentId;

        return query.Where(r =>
            !r.Departments.Any()
            || (userId.HasValue && r.CreatedBy == userId)
            || (deptId.HasValue && r.Departments.Any(d => d.DepartmentId == deptId.Value)));
    }

    private static string FormatFileSize(long bytes)
    {
        if (bytes == 0) return "0 B";
        string[] sizes = ["B", "KB", "MB", "GB", "TB"];
        int order = 0;
        double len = bytes;
        while (len >= 1024 && order < sizes.Length - 1)
        {
            order++;
            len /= 1024;
        }
        return $"{len:0.##} {sizes[order]}";
    }
}
