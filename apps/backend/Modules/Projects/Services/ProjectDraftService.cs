using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Shared.Common.Wrappers;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.Projects.Services;

public sealed class ProjectDraftService(AppDbContext db) : IProjectDraftService
{
    public async Task<PagedResult<ProjectDraftListDto>> GetDraftsAsync(ProjectDraftQueryParameters queryParams, CancellationToken ct = default)
    {
        var query = db.ProjectDrafts
            .AsNoTracking()
            .Where(x => x.Status == "active");

        if (!string.IsNullOrWhiteSpace(queryParams.Search))
        {
            var s = queryParams.Search.Trim().ToLower();
            query = query.Where(x =>
                x.ProjectName.ToLower().Contains(s) ||
                (x.ClientName != null && x.ClientName.ToLower().Contains(s)));
        }

        var total = await query.CountAsync(ct);

        var items = await query
            .OrderByDescending(x => x.UpdatedAtUtc ?? x.CreatedAtUtc)
            .Skip((queryParams.Page - 1) * queryParams.PerPage)
            .Take(queryParams.PerPage)
            .Select(x => new ProjectDraftListDto(
                x.Id,
                x.ProjectName,
                x.ClientId,
                x.ClientName,
                x.SalesPerson,
                x.CreatedByName,
                x.UpdatedByName,
                x.Status,
                x.RowVersion,
                x.CreatedAtUtc,
                x.UpdatedAtUtc
            ))
            .ToListAsync(ct);

        return new PagedResult<ProjectDraftListDto>(items, queryParams.Page, queryParams.PerPage, total);
    }

    public async Task<ProjectDraftDto?> GetDraftByIdAsync(Guid id, CancellationToken ct = default)
    {
        var draft = await db.ProjectDrafts
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id, ct);

        if (draft is null) return null;

        return MapToDto(draft);
    }

    public async Task<ProjectDraftDto> CreateDraftAsync(CreateProjectDraftRequest request, CancellationToken ct = default)
    {
        var draft = new ProjectDraft
        {
            ProjectName = request.ProjectName.Trim(),
            ClientId = request.ClientId,
            ClientName = request.ClientName?.Trim(),
            SalesPerson = request.SalesPerson?.Trim(),
            CreatedByName = request.SavedByName.Trim(),
            UpdatedByName = request.SavedByName.Trim(),
            FormSnapshotJson = request.FormSnapshotJson,
            Status = "active"
        };

        db.ProjectDrafts.Add(draft);
        await db.SaveChangesAsync(ct);

        // Reload to retrieve database-generated values including xmin RowVersion
        var saved = await db.ProjectDrafts.AsNoTracking().FirstAsync(x => x.Id == draft.Id, ct);
        return MapToDto(saved);
    }

    public async Task<ProjectDraftDto> UpdateDraftAsync(Guid id, UpdateProjectDraftRequest request, CancellationToken ct = default)
    {
        var draft = await db.ProjectDrafts.FirstOrDefaultAsync(x => x.Id == id, ct)
            ?? throw new NotFoundException($"Project draft with ID '{id}' was not found.");

        if (draft.Status == "converted")
        {
            throw new ConflictException("This draft has already been converted to a project.");
        }

        // Apply concurrency token check if provided
        if (request.RowVersion > 0)
        {
            db.Entry(draft).Property(d => d.RowVersion).OriginalValue = request.RowVersion;
        }

        draft.ProjectName = request.ProjectName.Trim();
        draft.ClientId = request.ClientId;
        draft.ClientName = request.ClientName?.Trim();
        draft.SalesPerson = request.SalesPerson?.Trim();
        draft.UpdatedByName = request.SavedByName.Trim();
        draft.FormSnapshotJson = request.FormSnapshotJson;

        try
        {
            await db.SaveChangesAsync(ct);
        }
        catch (DbUpdateConcurrencyException)
        {
            throw new ConflictException("This draft was updated by another user. Please reload the latest version before saving.");
        }

        var updated = await db.ProjectDrafts.AsNoTracking().FirstAsync(x => x.Id == draft.Id, ct);
        return MapToDto(updated);
    }

    public async Task<bool> DeleteDraftAsync(Guid id, CancellationToken ct = default)
    {
        var draft = await db.ProjectDrafts.FirstOrDefaultAsync(x => x.Id == id, ct)
            ?? throw new NotFoundException($"Project draft with ID '{id}' was not found.");

        db.ProjectDrafts.Remove(draft); // triggers soft delete in AppDbContext
        await db.SaveChangesAsync(ct);
        return true;
    }

    public async Task<bool> MarkDraftConvertedAsync(Guid id, CancellationToken ct = default)
    {
        var draft = await db.ProjectDrafts.FirstOrDefaultAsync(x => x.Id == id, ct);
        if (draft is null) return false;

        draft.Status = "converted";
        await db.SaveChangesAsync(ct);
        return true;
    }

    private static ProjectDraftDto MapToDto(ProjectDraft d) => new(
        d.Id,
        d.ProjectName,
        d.ClientId,
        d.ClientName,
        d.SalesPerson,
        d.CreatedByName,
        d.UpdatedByName,
        d.Status,
        d.RowVersion,
        d.CreatedAtUtc,
        d.UpdatedAtUtc,
        d.FormSnapshotJson
    );
}
