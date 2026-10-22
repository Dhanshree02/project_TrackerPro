using Microsoft.EntityFrameworkCore;
using PMS.API.Modules.Catalogs.Models;

namespace PMS.API.Infrastructure.Persistence.Seeding;

/// <summary>Keeps the sidebar module catalog on <c>master.mst_modules</c>.</summary>
public static class ModuleCatalogSync
{
    private static readonly (string Code, string Name, string? Route, string IconKey, int SortOrder)[] Seeds =
    [
        ("dashboard", "Dashboard", "/", "layout-dashboard", 10),
        ("action-centre", "Action Center", "/action-centre", "list-checks", 20),
        ("projects", "Projects", "/projects", "folder-kanban", 30),
        ("resources", "Resources", "/resources", "users", 40),
        ("customers", "Customer", "/customers", "building-2", 50),
        ("repository", "Repository", "/repository", "building", 60),
        ("my-team", "My Team", null, "users", 70),
        ("settings", "Settings", null, "settings", 80),
    ];

    public static async Task EnsureAsync(AppDbContext db, CancellationToken ct = default)
    {
        var rows = await db.Modules.IgnoreQueryFilters().ToListAsync(ct);
        var byCode = rows.ToDictionary(r => r.Code, StringComparer.OrdinalIgnoreCase);

        foreach (var seed in Seeds)
        {
            if (byCode.ContainsKey(seed.Code)) continue;
            db.Modules.Add(new MstModule
            {
                Code = seed.Code,
                Name = seed.Name,
                Route = seed.Route,
                IconKey = seed.IconKey,
                SortOrder = seed.SortOrder,
                IsActive = true,
            });
        }

        await db.SaveChangesAsync(ct);
        await EnsureSubModulesAsync(db, ct);
        await EnsureWidgetsAsync(db, ct);
        await EnsureTabsAsync(db, ct);
    }

    /// <summary>
    /// Direct children set ModuleId. A later sub-submodule sets ParentCode and leaves ModuleCode empty,
    /// so ParentId points at another row in this table.
    /// </summary>
    private static readonly (string Code, string Name, string? Route, int SortOrder, string? ModuleCode, string? ParentCode)[] SubSeeds =
    [
        ("employee-directory", "Employee Directory", "/employee-directory", 10, "resources", null),
        ("exit-summary", "Exit Summary", "/exit-summary", 20, "resources", null),
        ("team-dashboard", "Team Dashboard", "/my-team/", 10, "my-team", null),
        ("timesheets", "Timesheets", "/my-team/timesheets", 20, "my-team", null),
        ("roles-permissions", "Roles & Permissions", "/settings-security-roles", 10, "settings", null),
        ("master", "Master", "/settings-masters", 20, "settings", null),
    ];

    private static async Task EnsureSubModulesAsync(AppDbContext db, CancellationToken ct)
    {
        var modules = await db.Modules.IgnoreQueryFilters().ToListAsync(ct);
        var moduleByCode = modules.ToDictionary(m => m.Code, StringComparer.OrdinalIgnoreCase);
        var rows = await db.SubModules.IgnoreQueryFilters().ToListAsync(ct);
        var byCode = rows.ToDictionary(r => r.Code, StringComparer.OrdinalIgnoreCase);

        foreach (var seed in SubSeeds)
        {
            if (byCode.ContainsKey(seed.Code)) continue;

            Guid? moduleId = null;
            Guid? parentId = null;
            if (string.IsNullOrWhiteSpace(seed.ParentCode))
            {
                if (seed.ModuleCode is null || !moduleByCode.TryGetValue(seed.ModuleCode, out var module)) continue;
                moduleId = module.Id;
            }
            else
            {
                if (!byCode.TryGetValue(seed.ParentCode, out var parent)) continue;
                parentId = parent.Id;
            }

            var row = new MstSubModule
            {
                Code = seed.Code,
                Name = seed.Name,
                Route = seed.Route,
                SortOrder = seed.SortOrder,
                IsActive = true,
                ModuleId = moduleId,
                ParentId = parentId,
            };
            db.SubModules.Add(row);
            byCode[seed.Code] = row;
        }

        await db.SaveChangesAsync(ct);
    }

    /// <summary>ParentCode is the module code stored on <c>ParentId</c>.</summary>
    private static readonly (string Code, string Name, int SortOrder, string ParentCode)[] WidgetSeeds =
    [
        ("total-team-size", "Total Team Size", 10, "dashboard"),
        ("resource-boarding-details", "Resource Boarding Details", 20, "dashboard"),
        ("team-utilization-onsite", "Team Utilization - Onsite (Last 3 Months)", 30, "dashboard"),
        ("team-utilization-offsite", "Team Utilization \u2013 Offsite", 40, "dashboard"),
        ("team-utilization-onsite-projects", "Team Utilization \u2013 Onsite: Project-wise Resource Count", 50, "dashboard"),
        ("team-allocation-onsite-offsite", "Team Allocation Onsite/Offsite (Last 3 Months)", 60, "dashboard"),
        ("team-resignation-count", "Team Resignation Count \u2013 Onsite/Offsite (Last 3 Months)", 70, "dashboard"),
        ("team-capacity-offsite", "Team Capacity \u2013 Offsite (Last 3 Months)", 80, "dashboard"),
    ];

    private static async Task EnsureWidgetsAsync(AppDbContext db, CancellationToken ct)
    {
        var modules = await db.Modules.IgnoreQueryFilters().ToListAsync(ct);
        var moduleByCode = modules.ToDictionary(m => m.Code, StringComparer.OrdinalIgnoreCase);
        var rows = await db.Widgets.IgnoreQueryFilters().ToListAsync(ct);
        var byCode = rows.ToDictionary(r => r.Code, StringComparer.OrdinalIgnoreCase);

        foreach (var seed in WidgetSeeds)
        {
            if (byCode.ContainsKey(seed.Code)) continue;
            if (!moduleByCode.TryGetValue(seed.ParentCode, out var module)) continue;
            db.Widgets.Add(new MstWidget
            {
                Code = seed.Code,
                Name = seed.Name,
                SortOrder = seed.SortOrder,
                IsActive = true,
                ParentId = module.Id,
            });
        }

        await db.SaveChangesAsync(ct);
    }

    /// <summary>
    /// A tab sets exactly one of ModuleCode, SubModuleCode, or ParentCode.
    /// ParentCode stores TabId for a nested tab.
    /// </summary>
    private static readonly (string Code, string Name, int SortOrder, string? ModuleCode, string? SubModuleCode, string? ParentCode)[] TabSeeds =
    [
        ("bucket-list", "Bucket List", 10, "action-centre", null, null),
        ("approvals", "Approvals", 20, "action-centre", null, null),
        ("alerts", "Alerts", 30, "action-centre", null, null),
        ("notifications", "Notifications", 40, "action-centre", null, null),
        ("my-reportees", "My Reportees", 10, null, "team-dashboard", null),
        ("all-employees", "All Employees", 20, null, "team-dashboard", null),
    ];

    private static async Task EnsureTabsAsync(AppDbContext db, CancellationToken ct)
    {
        var modules = await db.Modules.IgnoreQueryFilters().ToListAsync(ct);
        var moduleByCode = modules.ToDictionary(m => m.Code, StringComparer.OrdinalIgnoreCase);
        var subModules = await db.SubModules.IgnoreQueryFilters().ToListAsync(ct);
        var subModuleByCode = subModules.ToDictionary(s => s.Code, StringComparer.OrdinalIgnoreCase);
        var rows = await db.Tabs.IgnoreQueryFilters().ToListAsync(ct);
        var byCode = rows.ToDictionary(r => r.Code, StringComparer.OrdinalIgnoreCase);

        foreach (var seed in TabSeeds)
        {
            if (byCode.ContainsKey(seed.Code)) continue;

            Guid? moduleId = null;
            Guid? subModuleId = null;
            Guid? tabId = null;
            if (!string.IsNullOrWhiteSpace(seed.ParentCode))
            {
                if (!byCode.TryGetValue(seed.ParentCode, out var parent)) continue;
                tabId = parent.Id;
            }
            else if (!string.IsNullOrWhiteSpace(seed.SubModuleCode))
            {
                if (!subModuleByCode.TryGetValue(seed.SubModuleCode, out var subModule)) continue;
                subModuleId = subModule.Id;
            }
            else
            {
                if (seed.ModuleCode is null || !moduleByCode.TryGetValue(seed.ModuleCode, out var module)) continue;
                moduleId = module.Id;
            }

            var row = new MstTab
            {
                Code = seed.Code,
                Name = seed.Name,
                SortOrder = seed.SortOrder,
                IsActive = true,
                ModuleId = moduleId,
                SubModuleId = subModuleId,
                TabId = tabId,
            };
            db.Tabs.Add(row);
            byCode[seed.Code] = row;
        }

        await db.SaveChangesAsync(ct);
    }
}
