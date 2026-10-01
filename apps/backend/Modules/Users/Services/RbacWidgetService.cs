using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Users.DTOs;
using PMS.API.Modules.Users.Models;

namespace PMS.API.Modules.Users.Services;

public class RbacWidgetService(AppDbContext db) : IRbacWidgetService
{
    public async Task<List<ModuleNodeDto>> GetCatalogTreeAsync(Guid? roleId = null, CancellationToken ct = default)
    {
        var modules = await db.Modules
            .AsNoTracking()
            .OrderBy(m => m.SortOrder)
            .ToListAsync(ct);

        var submodules = await db.Submodules
            .AsNoTracking()
            .OrderBy(s => s.SortOrder)
            .ToListAsync(ct);

        var widgets = await db.Widgets
            .AsNoTracking()
            .OrderBy(w => w.SortOrder)
            .ToListAsync(ct);

        Dictionary<Guid, (short v, short m)> permsMap = [];
        if (roleId.HasValue)
        {
            var perms = await db.RoleWidgetPermissions
                .AsNoTracking()
                .Where(p => p.RoleId == roleId.Value)
                .ToListAsync(ct);

            foreach (var p in perms)
            {
                permsMap[p.WidgetId] = (p.CanView, p.CanManage);
            }
        }

        var result = new List<ModuleNodeDto>();

        foreach (var mod in modules)
        {
            var modWidgets = widgets
                .Where(w => w.ModuleId == mod.Id && w.SubmoduleId == null)
                .Select(w =>
                {
                    var (v, m) = permsMap.GetValueOrDefault(w.Id, ((short)0, (short)0));
                    return new WidgetNodeDto(
                        w.Id,
                        w.Code,
                        w.Name,
                        w.WidgetKey,
                        w.WidgetType,
                        w.HasManageAction,
                        w.SortOrder,
                        v,
                        m);
                })
                .ToList();

            var topSubmodules = submodules
                .Where(s => s.ModuleId == mod.Id && s.ParentSubmoduleId == null)
                .Select(s => BuildSubmoduleTree(s, submodules, widgets, permsMap))
                .ToList();

            result.Add(new ModuleNodeDto(
                mod.Id,
                mod.Code,
                mod.Name,
                mod.Icon,
                mod.SortOrder,
                topSubmodules,
                modWidgets));
        }

        return result;
    }

    private static SubmoduleNodeDto BuildSubmoduleTree(
        MstSubmodule sub,
        List<MstSubmodule> allSubs,
        List<MstWidget> allWidgets,
        Dictionary<Guid, (short v, short m)> permsMap)
    {
        var subWidgets = allWidgets
            .Where(w => w.SubmoduleId == sub.Id)
            .Select(w =>
            {
                var (v, m) = permsMap.GetValueOrDefault(w.Id, ((short)0, (short)0));
                return new WidgetNodeDto(
                    w.Id,
                    w.Code,
                    w.Name,
                    w.WidgetKey,
                    w.WidgetType,
                    w.HasManageAction,
                    w.SortOrder,
                    v,
                    m);
            })
            .ToList();

        var children = allSubs
            .Where(s => s.ParentSubmoduleId == sub.Id)
            .Select(s => BuildSubmoduleTree(s, allSubs, allWidgets, permsMap))
            .ToList();

        return new SubmoduleNodeDto(
            sub.Id,
            sub.Code,
            sub.Name,
            sub.RoutePrefix,
            sub.SortOrder,
            children,
            subWidgets);
    }

    public async Task<List<RoleWidgetPermissionDto>> GetRoleWidgetPermissionsAsync(Guid roleId, CancellationToken ct = default)
    {
        var perms = await db.RoleWidgetPermissions
            .AsNoTracking()
            .Include(p => p.Widget)
            .Where(p => p.RoleId == roleId)
            .ToListAsync(ct);

        return perms.Select(p => new RoleWidgetPermissionDto(
            p.WidgetId,
            p.Widget?.WidgetKey ?? string.Empty,
            p.CanView,
            p.CanManage)).ToList();
    }

    public async Task<Dictionary<string, (short v, short m)>> GetRoleWidgetMapAsync(Guid roleId, CancellationToken ct = default)
    {
        var perms = await db.RoleWidgetPermissions
            .AsNoTracking()
            .Include(p => p.Widget)
            .Where(p => p.RoleId == roleId)
            .ToListAsync(ct);

        var map = new Dictionary<string, (short v, short m)>(StringComparer.OrdinalIgnoreCase);
        foreach (var p in perms)
        {
            if (p.Widget != null && !string.IsNullOrEmpty(p.Widget.WidgetKey))
            {
                map[p.Widget.WidgetKey] = (p.CanView, p.CanManage);
            }
        }

        return map;
    }

    public async Task UpdateRoleWidgetPermissionsAsync(
        Guid roleId,
        UpdateRoleWidgetPermissionsRequest request,
        Guid? modifiedById = null,
        CancellationToken ct = default)
    {
        var existing = await db.RoleWidgetPermissions
            .Where(p => p.RoleId == roleId)
            .ToListAsync(ct);

        var existingMap = existing.ToDictionary(p => p.WidgetId);

        foreach (var item in request.Permissions)
        {
            // Enforce invariant: View=0 requires Manage=0; Manage=1 requires View=1
            short view = item.CanView;
            short manage = item.CanManage;
            if (view == 0)
            {
                manage = 0;
            }
            else if (manage == 1)
            {
                view = 1;
            }

            if (existingMap.TryGetValue(item.WidgetId, out var perm))
            {
                perm.CanView = view;
                perm.CanManage = manage;
            }
            else
            {
                db.RoleWidgetPermissions.Add(new RoleWidgetPermission
                {
                    RoleId = roleId,
                    WidgetId = item.WidgetId,
                    CanView = view,
                    CanManage = manage,
                });
            }
        }

        var role = await db.Roles.FindAsync([roleId], ct);
        if (role != null)
        {
            db.RolePermissionAudits.Add(new RolePermissionAudit
            {
                RoleId = roleId,
                RoleName = role.Name,
                ChangeType = "UPDATED_WIDGETS",
                ActionLabel = "Updated Module & Widget Permissions",
                ChangedById = modifiedById,
                ChangedByName = "Admin",
            });
        }

        await db.SaveChangesAsync(ct);
    }

    public async Task ResetRoleToBaselineAsync(
        Guid roleId,
        Guid? modifiedById = null,
        CancellationToken ct = default)
    {
        var role = await db.Roles.FindAsync([roleId], ct);
        if (role == null) return;

        var allWidgets = await db.Widgets.AsNoTracking().ToListAsync(ct);
        var existing = await db.RoleWidgetPermissions.Where(p => p.RoleId == roleId).ToListAsync(ct);
        var existingMap = existing.ToDictionary(p => p.WidgetId);

        var rName = role.Name.Trim();
        bool isSuperAdmin = rName is "Admin" or "CEO" or "COO" or "Dhanshree";
        bool isPmo = rName is "PMO";
        bool isPmFamily = rName.Contains("Manager") || rName.Contains("Leader") || rName is "EngagementManager";
        bool isHr = rName is "HR";
        bool isAccounts = rName is "Accounts";
        bool isSales = rName.Contains("Sales");
        bool isItAdmin = rName is "IT Admin";

        foreach (var w in allWidgets)
        {
            short v = 0;
            short m = 0;

            if (isSuperAdmin)
            {
                v = 1;
                m = (short)(w.HasManageAction ? 1 : 0);
            }
            else if (isPmo)
            {
                v = 1;
                m = (short)(w.HasManageAction && (w.WidgetKey.Contains("pmo") || w.WidgetKey.Contains("wbs") || w.WidgetKey.Contains("approvals") || w.WidgetKey.Contains("timesheet_approval")) ? 1 : 0);
            }
            else if (isHr)
            {
                if (w.WidgetKey.StartsWith("resources.") || w.WidgetKey == "dashboard.kpis" || w.WidgetKey.StartsWith("action_center."))
                {
                    v = 1;
                    m = (short)(w.HasManageAction && w.WidgetKey.StartsWith("resources.") ? 1 : 0);
                }
            }
            else if (isAccounts)
            {
                if (w.WidgetKey.Contains("invoice") || w.WidgetKey.Contains("budget") || w.WidgetKey.Contains("billing") || w.WidgetKey.StartsWith("reports.") || w.WidgetKey == "dashboard.kpis")
                {
                    v = 1;
                    m = (short)(w.HasManageAction && (w.WidgetKey.Contains("invoice") || w.WidgetKey.Contains("billing")) ? 1 : 0);
                }
            }
            else if (isSales)
            {
                if (w.WidgetKey.StartsWith("customers.") || w.WidgetKey.Contains("sales") || w.WidgetKey == "dashboard.kpis")
                {
                    v = 1;
                    m = (short)(w.HasManageAction && w.WidgetKey.StartsWith("customers.") ? 1 : 0);
                }
            }
            else if (isItAdmin)
            {
                if (w.WidgetKey.StartsWith("settings.masters.") || w.WidgetKey.StartsWith("resources.directory.") || w.WidgetKey == "repository.documents")
                {
                    v = 1;
                    m = (short)(w.HasManageAction ? 1 : 0);
                }
            }
            else if (isPmFamily)
            {
                if (w.WidgetKey.StartsWith("projects.") || w.WidgetKey.StartsWith("action_center.") || w.WidgetKey.StartsWith("my_team.") || w.WidgetKey.StartsWith("dashboard."))
                {
                    v = 1;
                    m = (short)(w.HasManageAction && !(w.WidgetKey.Contains("budget") && rName.Contains("Testing")) ? 1 : 0);
                }
            }
            else
            {
                // Team member / Intern
                if (w.WidgetKey is "my_team.my_timesheet" or "dashboard.kpis" or "dashboard.assigned_projects" or "projects.task.management" or "action_center.bucket_list.start_timer")
                {
                    v = 1;
                    m = (short)(w.WidgetKey is "my_team.my_timesheet" or "action_center.bucket_list.start_timer" ? 1 : 0);
                }
                else if (w.WidgetKey.StartsWith("projects.health."))
                {
                    v = 1;
                    m = (short)(w.WidgetKey == "projects.health.issues" && w.HasManageAction ? 1 : 0);
                }
            }

            if (existingMap.TryGetValue(w.Id, out var perm))
            {
                perm.CanView = v;
                perm.CanManage = m;
            }
            else
            {
                db.RoleWidgetPermissions.Add(new RoleWidgetPermission
                {
                    RoleId = roleId,
                    WidgetId = w.Id,
                    CanView = v,
                    CanManage = m,
                });
            }
        }

        db.RolePermissionAudits.Add(new RolePermissionAudit
        {
            RoleId = roleId,
            RoleName = role.Name,
            ChangeType = "RESET_BASELINE",
            ActionLabel = "Reset to Default Baseline",
            ChangedById = modifiedById,
            ChangedByName = "Admin",
        });

        await db.SaveChangesAsync(ct);
    }
}
