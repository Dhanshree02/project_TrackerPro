using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Users.DTOs;
using PMS.API.Modules.Users.Models;
using PMS.API.Shared.Constants;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.Users.Services;

public class RbacWidgetService(AppDbContext db) : IRbacWidgetService
{
    public async Task<List<ModuleCatalogDto>> GetCatalogTreeAsync(Guid? roleId = null, CancellationToken ct = default)
    {
        var modules = await db.MstModules
            .AsNoTracking()
            .Where(m => m.IsActive)
            .OrderBy(m => m.SortOrder)
            .ToListAsync(ct);

        var submodules = await db.MstSubmodules
            .AsNoTracking()
            .Where(s => s.IsActive)
            .OrderBy(s => s.SortOrder)
            .ToListAsync(ct);

        var widgets = await db.MstWidgets
            .AsNoTracking()
            .Where(w => w.IsActive)
            .OrderBy(w => w.SortOrder)
            .ToListAsync(ct);

        Dictionary<Guid, (short CanView, short CanManage)> permsMap = [];
        if (roleId.HasValue)
        {
            var perms = await db.RoleWidgetPermissions
                .AsNoTracking()
                .Where(p => p.RoleId == roleId.Value)
                .ToListAsync(ct);
            permsMap = perms.ToDictionary(p => p.WidgetId, p => (p.CanView, p.CanManage));
        }

        WidgetCatalogDto ToWidgetDto(MstWidget w)
        {
            var (canView, canManage) = permsMap.TryGetValue(w.Id, out var pVal) ? pVal : ((short)0, (short)0);
            return new WidgetCatalogDto(
                w.Id,
                w.Code,
                w.Name,
                w.WidgetKey,
                w.WidgetType,
                w.HasManageAction,
                w.SortOrder,
                canView,
                canManage
            );
        }

        SubmoduleCatalogDto BuildSubmodule(MstSubmodule s, List<MstSubmodule> allSubs, List<MstWidget> allWidgets)
        {
            var childSubs = allSubs
                .Where(cs => cs.ParentSubmoduleId == s.Id)
                .OrderBy(cs => cs.SortOrder)
                .Select(cs => BuildSubmodule(cs, allSubs, allWidgets))
                .ToList();

            var subWidgets = allWidgets
                .Where(w => w.SubmoduleId == s.Id)
                .OrderBy(w => w.SortOrder)
                .Select(ToWidgetDto)
                .ToList();

            return new SubmoduleCatalogDto(
                s.Id,
                s.Code,
                s.Name,
                s.RoutePrefix,
                s.SortOrder,
                subWidgets,
                childSubs
            );
        }

        var result = new List<ModuleCatalogDto>();
        foreach (var mod in modules)
        {
            var topLevelSubs = submodules
                .Where(s => s.ModuleId == mod.Id && s.ParentSubmoduleId == null)
                .OrderBy(s => s.SortOrder)
                .Select(s => BuildSubmodule(s, submodules, widgets))
                .ToList();

            var directWidgets = widgets
                .Where(w => w.ModuleId == mod.Id && w.SubmoduleId == null)
                .OrderBy(w => w.SortOrder)
                .Select(ToWidgetDto)
                .ToList();

            result.Add(new ModuleCatalogDto(
                mod.Id,
                mod.Code,
                mod.Name,
                mod.Icon,
                mod.SortOrder,
                topLevelSubs,
                directWidgets
            ));
        }

        return result;
    }

    public async Task<Dictionary<string, (short CanView, short CanManage)>> GetEffectiveUserPermissionsAsync(string roleName, CancellationToken ct = default)
    {
        var norm = (roleName ?? "").Trim();
        var allWidgets = await db.MstWidgets
            .AsNoTracking()
            .Where(w => w.IsActive)
            .ToListAsync(ct);

        // Super-admin bypass
        if (norm is "Admin" or "Dhanshree")
        {
            return allWidgets.ToDictionary(
                w => w.WidgetKey,
                w => ((short)1, (short)(w.HasManageAction ? 1 : 0)),
                StringComparer.OrdinalIgnoreCase
            );
        }

        var role = await db.Roles
            .AsNoTracking()
            .FirstOrDefaultAsync(r => r.Name.ToLower() == norm.ToLower(), ct);

        if (role == null)
        {
            // Fallback to baseline dictionary if role record is not loaded yet
            if (RbacWidgetBaselines.Map.TryGetValue(norm, out var baseline))
            {
                return new Dictionary<string, (short CanView, short CanManage)>(baseline, StringComparer.OrdinalIgnoreCase);
            }
            return allWidgets.ToDictionary(
                w => w.WidgetKey,
                _ => ((short)0, (short)0),
                StringComparer.OrdinalIgnoreCase
            );
        }

        var permissions = await db.RoleWidgetPermissions
            .AsNoTracking()
            .Where(p => p.RoleId == role.Id)
            .Include(p => p.Widget)
            .ToListAsync(ct);

        var result = new Dictionary<string, (short CanView, short CanManage)>(StringComparer.OrdinalIgnoreCase);

        // First populate from DB
        foreach (var p in permissions)
        {
            result[p.Widget.WidgetKey] = (p.CanView, p.CanManage);
        }

        // For any widget not explicitly in DB, check baseline fallback or 0
        if (RbacWidgetBaselines.Map.TryGetValue(norm, out var roleBaseline))
        {
            foreach (var w in allWidgets)
            {
                if (!result.ContainsKey(w.WidgetKey))
                {
                    result[w.WidgetKey] = roleBaseline.GetValueOrDefault(w.WidgetKey, ((short)0, (short)0));
                }
            }
        }
        else
        {
            foreach (var w in allWidgets)
            {
                if (!result.ContainsKey(w.WidgetKey))
                {
                    result[w.WidgetKey] = (0, 0);
                }
            }
        }

        return result;
    }

    public async Task<List<RoleWidgetPermissionDto>> GetRolePermissionsAsync(Guid roleId, CancellationToken ct = default)
    {
        var role = await db.Roles.AsNoTracking().FirstOrDefaultAsync(r => r.Id == roleId, ct)
            ?? throw new NotFoundException($"Role with ID '{roleId}' not found.");

        var permissions = await db.RoleWidgetPermissions
            .AsNoTracking()
            .Where(p => p.RoleId == roleId)
            .Include(p => p.Widget)
            .ToListAsync(ct);

        return permissions.Select(p => new RoleWidgetPermissionDto(
            p.RoleId,
            role.Name,
            p.WidgetId,
            p.Widget.WidgetKey,
            p.Widget.Name,
            p.CanView,
            p.CanManage
        )).ToList();
    }

    public async Task UpdateRolePermissionsAsync(Guid roleId, UpdateRoleWidgetPermissionsDto dto, Guid? updatedBy, CancellationToken ct = default)
    {
        var role = await db.Roles.FirstOrDefaultAsync(r => r.Id == roleId, ct)
            ?? throw new NotFoundException($"Role with ID '{roleId}' not found.");

        var existing = await db.RoleWidgetPermissions
            .Where(p => p.RoleId == roleId)
            .ToListAsync(ct);

        var existingMap = existing.ToDictionary(p => p.WidgetId);

        foreach (var item in dto.Permissions)
        {
            // Business rule: Manage strictly requires View
            var canView = item.CanView == 1 ? (short)1 : (short)0;
            var canManage = (item.CanManage == 1 && canView == 1) ? (short)1 : (short)0;

            if (existingMap.TryGetValue(item.WidgetId, out var perm))
            {
                perm.CanView = canView;
                perm.CanManage = canManage;
                perm.UpdatedBy = updatedBy;
                perm.UpdatedAtUtc = DateTime.UtcNow;
            }
            else
            {
                db.RoleWidgetPermissions.Add(new RoleWidgetPermission
                {
                    RoleId = roleId,
                    WidgetId = item.WidgetId,
                    CanView = canView,
                    CanManage = canManage,
                    CreatedBy = updatedBy,
                    CreatedAtUtc = DateTime.UtcNow
                });
            }
        }

        await db.SaveChangesAsync(ct);
    }

    public async Task ResetRoleBaselineAsync(Guid roleId, Guid? updatedBy, CancellationToken ct = default)
    {
        var role = await db.Roles.FirstOrDefaultAsync(r => r.Id == roleId, ct)
            ?? throw new NotFoundException($"Role with ID '{roleId}' not found.");

        if (!RbacWidgetBaselines.Map.TryGetValue(role.Name, out var baseline))
        {
            throw new BadRequestException($"No baseline permissions defined for role '{role.Name}'.");
        }

        var widgets = await db.MstWidgets.ToListAsync(ct);
        var existing = await db.RoleWidgetPermissions
            .Where(p => p.RoleId == roleId)
            .ToListAsync(ct);

        var existingMap = existing.ToDictionary(p => p.WidgetId);

        foreach (var w in widgets)
        {
            var (canView, canManage) = baseline.TryGetValue(w.WidgetKey, out var bVal) ? bVal : ((short)0, (short)0);

            if (existingMap.TryGetValue(w.Id, out var perm))
            {
                perm.CanView = canView;
                perm.CanManage = canManage;
                perm.UpdatedBy = updatedBy;
                perm.UpdatedAtUtc = DateTime.UtcNow;
            }
            else
            {
                db.RoleWidgetPermissions.Add(new RoleWidgetPermission
                {
                    RoleId = roleId,
                    WidgetId = w.Id,
                    CanView = canView,
                    CanManage = canManage,
                    CreatedBy = updatedBy,
                    CreatedAtUtc = DateTime.UtcNow
                });
            }
        }

        await db.SaveChangesAsync(ct);
    }
}
