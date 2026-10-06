using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Shared.Constants;

namespace PMS.API.Modules.Rbac;

public interface IRbacAccessService
{
    Task EnsureBaselineAsync(CancellationToken ct = default);
    Task<IReadOnlyList<RbacRoleOption>> ListRolesAsync(CancellationToken ct = default);
    Task<IReadOnlyList<UserAccessRow>> ListUserAccessAsync(CancellationToken ct = default);
    Task SetUserAccessAsync(Guid userId, string roleName, CancellationToken ct = default);
    Task ResetToDefaultAsync(string roleName, CancellationToken ct = default);
    Task<RbacMatrix> GetMatrixAsync(string roleName, CancellationToken ct = default);
    Task SaveAsync(string roleName, IReadOnlyList<RbacGrantUpdate> updates, CancellationToken ct = default);
    Task<IReadOnlyList<string>> GetClaimsAsync(string roleName, CancellationToken ct = default);
}

public sealed record RbacGrantUpdate(Guid Id, int CanView, int CanManage);

public sealed class RbacRoleOption
{
    public Guid Id { get; set; }
    public string Name { get; set; } = "";
    public string DisplayName { get; set; } = "";
}

public sealed class UserAccessRow
{
    public Guid? Id { get; set; }
    public string EmployeeCode { get; set; } = "";
    public string Name { get; set; } = "";
    public string Email { get; set; } = "";
    public string Department { get; set; } = "";
    public string Designation { get; set; } = "";
    public string ProfileRole { get; set; } = "";
    public string AccessRole { get; set; } = "";
}

public sealed class RbacMatrix
{
    public Guid RoleId { get; init; }
    public string RoleName { get; init; } = "";
    public List<RbacNode> Nodes { get; init; } = [];
}

public sealed class RbacNode
{
    public string Level { get; init; } = "";
    public string Name { get; init; } = "";
    public Guid? PermissionId { get; set; }
    public int? CanView { get; set; }
    public int? CanManage { get; set; }
    public List<RbacNode> Children { get; init; } = [];
}

public sealed class RbacAccessService(AppDbContext db, IWebHostEnvironment environment) : IRbacAccessService
{
    public const string BaselineVersion = "excel-v03";

    public async Task EnsureBaselineAsync(CancellationToken ct = default)
    {
        var baseline = await LoadBaselineAsync(ct);
        await db.Database.ExecuteSqlRawAsync(
            """
            CREATE TABLE IF NOT EXISTS master.mst_rbac_baseline (
                "Version" character varying(40) PRIMARY KEY,
                "AppliedAtUtc" timestamp with time zone NOT NULL
            );
            ALTER TABLE master.mst_widgets ADD COLUMN IF NOT EXISTS "ParentWidgetId" uuid;
            ALTER TABLE master.mst_widgets DROP CONSTRAINT IF EXISTS "mst_widgets_ParentWidgetId_fkey";
            """,
            ct);

        var applied = await db.Database.SqlQueryRaw<string>(
            """SELECT "Version" AS "Value" FROM master.mst_rbac_baseline""").ToListAsync(ct);
        if (applied.Contains(BaselineVersion))
        {
            await EnsureParentWidgetConstraintAsync(ct);
            return;
        }

        await ReplaceCatalogAsync(baseline, ct);
        await EnsureParentWidgetConstraintAsync(ct);
    }

    public async Task<IReadOnlyList<RbacRoleOption>> ListRolesAsync(CancellationToken ct = default)
    {
        return await db.Database.SqlQueryRaw<RbacRoleOption>(
            """
            SELECT "Id", "Name", "DisplayName"
            FROM auth.tbl_roles
            WHERE "DeletedAtUtc" IS NULL AND "IsActive" = TRUE
            ORDER BY "DisplayName", "Name"
            """).ToListAsync(ct);
    }

    public async Task<IReadOnlyList<UserAccessRow>> ListUserAccessAsync(CancellationToken ct = default)
    {
        var employees = await db.Employees.AsNoTracking()
            .Include(e => e.Designation)
            .Include(e => e.Department)
            .Include(e => e.JobRole)
            .Where(e => e.DeletedAtUtc == null)
            .OrderBy(e => e.FirstName)
            .ThenBy(e => e.LastName)
            .ToListAsync(ct);
        var users = await db.Users.AsNoTracking().Include(u => u.Role).ToListAsync(ct);
        var byCode = users
            .Where(u => !string.IsNullOrWhiteSpace(u.EmployeeId))
            .GroupBy(u => u.EmployeeId, StringComparer.OrdinalIgnoreCase)
            .ToDictionary(g => g.Key, g => g.First(), StringComparer.OrdinalIgnoreCase);
        var byEmail = users
            .Where(u => !string.IsNullOrWhiteSpace(u.Email))
            .GroupBy(u => u.Email, StringComparer.OrdinalIgnoreCase)
            .ToDictionary(g => g.Key, g => g.First(), StringComparer.OrdinalIgnoreCase);

        return employees.Select(employee =>
        {
            byCode.TryGetValue(employee.EmployeeCode, out var byEmployeeCode);
            byEmail.TryGetValue(employee.WorkEmail ?? "", out var byWorkEmail);
            var account = byEmployeeCode ?? byWorkEmail;
            return new UserAccessRow
            {
                Id = account?.Id,
                EmployeeCode = employee.EmployeeCode,
                Name = $"{employee.FirstName} {employee.LastName}".Trim(),
                Email = employee.WorkEmail ?? "",
                Department = employee.Department?.Name ?? "",
                Designation = employee.Designation?.Name ?? "",
                ProfileRole = employee.JobRole?.Name ?? "",
                AccessRole = account?.Role?.Name ?? "",
            };
        }).ToList();
    }

    public async Task SetUserAccessAsync(Guid userId, string roleName, CancellationToken ct = default)
    {
        var user = await db.Users.FirstOrDefaultAsync(u => u.Id == userId, ct)
            ?? throw new InvalidOperationException("User not found.");
        var role = await db.Roles.FirstOrDefaultAsync(
            r => r.Name == roleName && r.DeletedAtUtc == null && r.IsActive, ct)
            ?? throw new InvalidOperationException("Role not found.");
        if (user.RoleId == role.Id) return;
        user.RoleId = role.Id;
        await db.SaveChangesAsync(ct);
    }

    public async Task ResetToDefaultAsync(string roleName, CancellationToken ct = default)
    {
        var baseline = await LoadBaselineAsync(ct);
        var roleId = await RoleIdAsync(roleName, ct);
        var grants = DefaultGrants(baseline, roleName);
        var widgets = await db.Database.SqlQueryRaw<WidgetKeyRow>(
            """
            SELECT "Id", "WidgetKey"
            FROM master.mst_widgets
            WHERE "DeletedAtUtc" IS NULL
            """).ToListAsync(ct);

        await using var tx = await db.Database.BeginTransactionAsync(ct);
        await db.Database.ExecuteSqlInterpolatedAsync(
            $"""DELETE FROM auth.tbl_role_widget_permissions WHERE "RoleId" = {roleId}""",
            ct);

        var now = DateTime.UtcNow;
        var isAdmin = roleName.Equals("Admin", StringComparison.OrdinalIgnoreCase);
        foreach (var widget in widgets)
        {
            int view;
            int manage;
            if (grants.TryGetValue(widget.WidgetKey, out var pair))
            {
                view = pair.View;
                manage = pair.Manage;
            }
            else if (isAdmin)
            {
                view = 1;
                manage = 1;
            }
            else
            {
                view = 0;
                manage = 0;
            }

            await db.Database.ExecuteSqlInterpolatedAsync(
                $"""
                INSERT INTO auth.tbl_role_widget_permissions
                    ("Id", "RoleId", "WidgetId", "CanView", "CanManage", "CreatedAtUtc")
                VALUES ({Guid.NewGuid()}, {roleId}, {widget.Id}, {view}, {manage}, {now})
                """,
                ct);
        }

        await tx.CommitAsync(ct);
    }

    public async Task<RbacMatrix> GetMatrixAsync(string roleName, CancellationToken ct = default)
    {
        var roleId = await RoleIdAsync(roleName, ct);
        var modules = await db.Database.SqlQueryRaw<ModuleRow>(
            """
            SELECT "Id", "Name", "SortOrder"
            FROM master.mst_modules
            WHERE "DeletedAtUtc" IS NULL
            ORDER BY "SortOrder"
            """).ToListAsync(ct);
        var submodules = await db.Database.SqlQueryRaw<SubmoduleRow>(
            """
            SELECT "Id", "ModuleId", "ParentSubmoduleId", "Name", "SortOrder"
            FROM master.mst_submodules
            WHERE "DeletedAtUtc" IS NULL
            ORDER BY "SortOrder"
            """).ToListAsync(ct);
        var widgets = await db.Database.SqlQueryRaw<WidgetRow>(
            """
            SELECT "Id", "ModuleId", "SubmoduleId", "ParentWidgetId", "Name", "WidgetType", "SortOrder"
            FROM master.mst_widgets
            WHERE "DeletedAtUtc" IS NULL
            ORDER BY "SortOrder"
            """).ToListAsync(ct);
        var grants = await db.Database.SqlQueryRaw<GrantRow>(
            """
            SELECT "WidgetId", "CanView", "CanManage"
            FROM auth.tbl_role_widget_permissions
            WHERE "RoleId" = {0} AND "DeletedAtUtc" IS NULL
            """,
            roleId).ToListAsync(ct);

        var grantByWidget = grants.ToDictionary(g => g.WidgetId);
        var nodes = new Dictionary<Guid, RbacNode>();
        var roots = new List<RbacNode>();

        foreach (var module in modules)
        {
            var node = new RbacNode { Level = "module", Name = module.Name };
            nodes[module.Id] = node;
            roots.Add(node);
        }

        foreach (var submodule in submodules.Where(s => s.ParentSubmoduleId is null))
        {
            var node = new RbacNode { Level = "submodule", Name = submodule.Name };
            nodes[submodule.Id] = node;
            if (nodes.TryGetValue(submodule.ModuleId, out var parent))
                parent.Children.Add(node);
        }

        foreach (var submodule in submodules.Where(s => s.ParentSubmoduleId is not null))
        {
            var node = new RbacNode { Level = "sub-submodule", Name = submodule.Name };
            nodes[submodule.Id] = node;
            if (nodes.TryGetValue(submodule.ParentSubmoduleId!.Value, out var parent))
                parent.Children.Add(node);
        }

        var widgetNodes = new Dictionary<Guid, RbacNode>();
        foreach (var widget in widgets.Where(w => w.WidgetType is "widget" or "module" or "submodule" or "sub-submodule"))
        {
            var node = NodeForWidget(widget, nodes, widgetNodes);
            ApplyGrant(node, widget.Id, grantByWidget);
        }

        foreach (var tab in widgets.Where(w => w.WidgetType == "tab"))
        {
            var node = new RbacNode { Level = "tab", Name = tab.Name };
            ApplyGrant(node, tab.Id, grantByWidget);
            if (tab.ParentWidgetId is Guid parentId && widgetNodes.TryGetValue(parentId, out var parent))
                parent.Children.Add(node);
        }

        return new RbacMatrix { RoleId = roleId, RoleName = roleName, Nodes = roots };
    }

    public async Task SaveAsync(string roleName, IReadOnlyList<RbacGrantUpdate> updates, CancellationToken ct = default)
    {
        var roleId = await RoleIdAsync(roleName, ct);
        foreach (var update in updates)
        {
            var canView = update.CanView == 0 ? 0 : 1;
            var canManage = update.CanManage == 1 && canView == 1 ? 1 : 0;
            var updated = await db.Database.ExecuteSqlInterpolatedAsync(
                $"""
                UPDATE auth.tbl_role_widget_permissions
                SET "CanView" = {canView}, "CanManage" = {canManage}, "UpdatedAtUtc" = {DateTime.UtcNow}
                WHERE "RoleId" = {roleId} AND "WidgetId" = {update.Id} AND "DeletedAtUtc" IS NULL
                """,
                ct);
            if (updated == 0)
            {
                await db.Database.ExecuteSqlInterpolatedAsync(
                    $"""
                    INSERT INTO auth.tbl_role_widget_permissions
                        ("Id", "RoleId", "WidgetId", "CanView", "CanManage", "CreatedAtUtc")
                    VALUES ({Guid.NewGuid()}, {roleId}, {update.Id}, {canView}, {canManage}, {DateTime.UtcNow})
                    """,
                    ct);
            }
        }
    }

    public async Task<IReadOnlyList<string>> GetClaimsAsync(string roleName, CancellationToken ct = default)
    {
        if (roleName.Equals("Admin", StringComparison.OrdinalIgnoreCase))
            return RoleBaselines.For("Admin");

        List<ClaimRow> rows;
        try
        {
            rows = await db.Database.SqlQueryRaw<ClaimRow>(
                """
                SELECT w."WidgetKey", w."Name" AS "Leaf", p."CanView", p."CanManage"
                FROM auth.tbl_role_widget_permissions AS p
                JOIN auth.tbl_roles AS r ON r."Id" = p."RoleId"
                JOIN master.mst_widgets AS w ON w."Id" = p."WidgetId"
                WHERE lower(r."Name") = lower({0}) AND p."DeletedAtUtc" IS NULL
                """,
                roleName).ToListAsync(ct);
        }
        catch (Exception)
        {
            return RoleBaselines.For(roleName);
        }

        if (rows.Count == 0)
            return RoleBaselines.For(roleName);

        var claims = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var row in rows)
        {
            var parts = row.WidgetKey.Split('|', StringSplitOptions.RemoveEmptyEntries);
            var module = parts.Length > 0 ? parts[0] : "";
            if (row.CanView == 1)
                claims.Add(row.WidgetKey + ":view");
            if (row.CanManage == 1)
                claims.Add(row.WidgetKey + ":manage");
            Bridge(claims, module, row.Leaf, row.CanView, row.CanManage);
        }

        return claims.ToList();
    }

    private async Task ReplaceCatalogAsync(BaselineFile baseline, CancellationToken ct)
    {
        await using var tx = await db.Database.BeginTransactionAsync(ct);
        await db.Database.ExecuteSqlRawAsync(
            """
            DELETE FROM auth.tbl_role_widget_permissions;
            DELETE FROM master.mst_widgets;
            DELETE FROM master.mst_submodules;
            DELETE FROM master.mst_modules;
            """,
            ct);

        var now = DateTime.UtcNow;
        var moduleIds = new Dictionary<string, Guid>(StringComparer.OrdinalIgnoreCase);
        var submoduleIds = new Dictionary<string, Guid>(StringComparer.OrdinalIgnoreCase);
        var widgetIds = new Dictionary<string, Guid>(StringComparer.OrdinalIgnoreCase);
        var permissionIds = new Dictionary<string, Guid>(StringComparer.OrdinalIgnoreCase);
        var grants = new Dictionary<string, Dictionary<string, (int View, int Manage)>>(StringComparer.OrdinalIgnoreCase);
        var sort = 0;

        foreach (var leaf in baseline.Leaves)
        {
            sort++;
            if (string.IsNullOrWhiteSpace(leaf.Module)) continue;
            if (!moduleIds.ContainsKey(leaf.Module))
            {
                var id = Guid.NewGuid();
                moduleIds[leaf.Module] = id;
                await InsertModuleAsync(id, Slug(leaf.Module), leaf.Module, moduleIds.Count, now, ct);
            }

            Guid? parentSubmodule = null;
            if (!string.IsNullOrWhiteSpace(leaf.Submodule))
            {
                var key = leaf.Module + "/" + leaf.Submodule;
                if (!submoduleIds.TryGetValue(key, out var submoduleId))
                {
                    submoduleId = Guid.NewGuid();
                    submoduleIds[key] = submoduleId;
                    await InsertSubmoduleAsync(submoduleId, moduleIds[leaf.Module], null, Slug(leaf.Submodule), leaf.Submodule, sort, now, ct);
                }
                parentSubmodule = submoduleId;
            }

            Guid? subSubmodule = null;
            if (!string.IsNullOrWhiteSpace(leaf.SubSubmodule) && parentSubmodule is Guid parentId)
            {
                var key = leaf.Module + "/" + leaf.Submodule + "/" + leaf.SubSubmodule;
                if (!submoduleIds.TryGetValue(key, out var subId))
                {
                    subId = Guid.NewGuid();
                    submoduleIds[key] = subId;
                    await InsertSubmoduleAsync(subId, moduleIds[leaf.Module], parentId, Slug(leaf.Module + "-" + leaf.SubSubmodule), leaf.SubSubmodule, sort, now, ct);
                }
                subSubmodule = subId;
            }

            var moduleId = moduleIds[leaf.Module];
            var attachSubmodule = subSubmodule ?? parentSubmodule;
            var moduleKey = "module:" + leaf.Module;
            await EnsurePermissionNodeAsync(permissionIds, moduleKey, moduleId, null, null, "module", leaf.Module, leaf.Module, sort, now, ct);

            string? submoduleKey = null;
            if (parentSubmodule is Guid submoduleNodeId && !string.IsNullOrWhiteSpace(leaf.Submodule))
            {
                submoduleKey = "submodule:" + leaf.Module + "/" + leaf.Submodule;
                await EnsurePermissionNodeAsync(permissionIds, submoduleKey, moduleId, submoduleNodeId, null, "submodule", leaf.Module + "|" + leaf.Submodule, leaf.Submodule, sort, now, ct);
            }

            string? subSubKey = null;
            if (subSubmodule is Guid subSubId && !string.IsNullOrWhiteSpace(leaf.SubSubmodule))
            {
                subSubKey = "sub-submodule:" + leaf.Module + "/" + leaf.Submodule + "/" + leaf.SubSubmodule;
                await EnsurePermissionNodeAsync(permissionIds, subSubKey, moduleId, subSubId, null, "sub-submodule", leaf.Module + "|" + leaf.Submodule + "|" + leaf.SubSubmodule, leaf.SubSubmodule, sort, now, ct);
            }

            string? widgetKey = null;
            Guid? parentWidget = null;
            if (!string.IsNullOrWhiteSpace(leaf.Widget))
            {
                widgetKey = "widget:" + string.Join("/", new[] { leaf.Module, leaf.Submodule, leaf.SubSubmodule, leaf.Widget }.Where(s => !string.IsNullOrWhiteSpace(s)));
                var storedKey = string.Join("|", new[] { leaf.Module, leaf.Submodule, leaf.SubSubmodule, leaf.Widget }.Where(s => !string.IsNullOrWhiteSpace(s)));
                if (!widgetIds.TryGetValue(widgetKey, out var widgetId))
                {
                    widgetId = Guid.NewGuid();
                    widgetIds[widgetKey] = widgetId;
                    permissionIds[widgetKey] = widgetId;
                    await InsertWidgetAsync(widgetId, moduleId, attachSubmodule, null, "widget", storedKey, leaf.Widget, sort, now, ct);
                }
                parentWidget = widgetIds[widgetKey];
            }

            string? tabKey = null;
            if (!string.IsNullOrWhiteSpace(leaf.Tab))
            {
                tabKey = "tab:" + string.Join("|", new[] { leaf.Module, leaf.Submodule, leaf.SubSubmodule, leaf.Widget, leaf.Tab }.Where(s => !string.IsNullOrWhiteSpace(s)));
                var tabId = Guid.NewGuid();
                permissionIds[tabKey] = tabId;
                await InsertWidgetAsync(tabId, moduleId, attachSubmodule, parentWidget, "tab", tabKey["tab:".Length..], leaf.Tab, sort, now, ct);
            }

            foreach (var (roleName, pair) in leaf.Grants)
            {
                var view = pair.Length > 0 && pair[0] != 0 ? 1 : 0;
                var manage = pair.Length > 1 && pair[1] != 0 && view == 1 ? 1 : 0;
                foreach (var key in new[] { moduleKey, submoduleKey, subSubKey, widgetKey, tabKey })
                {
                    if (key is null) continue;
                    if (!grants.TryGetValue(key, out var byRole))
                    {
                        byRole = new Dictionary<string, (int View, int Manage)>(StringComparer.OrdinalIgnoreCase);
                        grants[key] = byRole;
                    }

                    byRole.TryGetValue(roleName, out var current);
                    byRole[roleName] = (Math.Max(current.View, view), Math.Max(current.Manage, manage));
                }
            }
        }

        foreach (var (key, byRole) in grants)
        {
            if (!permissionIds.TryGetValue(key, out var permissionId)) continue;
            foreach (var (roleName, pair) in byRole)
            {
                await db.Database.ExecuteSqlInterpolatedAsync(
                    $"""
                    INSERT INTO auth.tbl_role_widget_permissions
                        ("Id", "RoleId", "WidgetId", "CanView", "CanManage", "CreatedAtUtc")
                    SELECT {Guid.NewGuid()}, r."Id", {permissionId}, {pair.View}, {pair.Manage}, {now}
                    FROM auth.tbl_roles AS r
                    WHERE lower(r."Name") = lower({roleName}) AND r."DeletedAtUtc" IS NULL
                    """,
                    ct);
            }
        }

        await db.Database.ExecuteSqlInterpolatedAsync(
            $"""
            INSERT INTO master.mst_rbac_baseline ("Version", "AppliedAtUtc")
            VALUES ({BaselineVersion}, {now})
            ON CONFLICT ("Version") DO UPDATE SET "AppliedAtUtc" = EXCLUDED."AppliedAtUtc"
            """,
            ct);
        await tx.CommitAsync(ct);
    }

    private async Task EnsureParentWidgetConstraintAsync(CancellationToken ct)
    {
        await db.Database.ExecuteSqlRawAsync(
            """
            DO $$
            BEGIN
                IF NOT EXISTS (
                    SELECT 1 FROM pg_constraint WHERE conname = 'mst_widgets_ParentWidgetId_fkey'
                ) THEN
                    ALTER TABLE master.mst_widgets
                        ADD CONSTRAINT "mst_widgets_ParentWidgetId_fkey"
                        FOREIGN KEY ("ParentWidgetId") REFERENCES master.mst_widgets ("Id") ON DELETE CASCADE;
                END IF;
            END $$;
            """,
            ct);
    }

    private static RbacNode NodeForWidget(WidgetRow widget, Dictionary<Guid, RbacNode> nodes, Dictionary<Guid, RbacNode> widgetNodes)
    {
        if (widget.WidgetType == "module" && widget.ModuleId is Guid moduleId && nodes.TryGetValue(moduleId, out var moduleNode))
        {
            widgetNodes[widget.Id] = moduleNode;
            return moduleNode;
        }

        if (widget.WidgetType is "submodule" or "sub-submodule" && widget.SubmoduleId is Guid submoduleId && nodes.TryGetValue(submoduleId, out var subNode))
        {
            widgetNodes[widget.Id] = subNode;
            return subNode;
        }

        var node = new RbacNode { Level = "widget", Name = widget.Name };
        widgetNodes[widget.Id] = node;
        var parentKey = widget.SubmoduleId ?? widget.ModuleId;
        if (parentKey is Guid parentId && nodes.TryGetValue(parentId, out var parent))
            parent.Children.Add(node);
        return node;
    }

    private static void ApplyGrant(RbacNode node, Guid widgetId, Dictionary<Guid, GrantRow> grants)
    {
        node.PermissionId = widgetId;
        if (grants.TryGetValue(widgetId, out var grant))
        {
            node.CanView = grant.CanView;
            node.CanManage = grant.CanManage;
        }
        else
        {
            node.CanView = 0;
            node.CanManage = 0;
        }
    }

    private static Dictionary<string, (int View, int Manage)> DefaultGrants(BaselineFile baseline, string roleName)
    {
        var grants = new Dictionary<string, (int View, int Manage)>(StringComparer.OrdinalIgnoreCase);
        foreach (var leaf in baseline.Leaves)
        {
            if (string.IsNullOrWhiteSpace(leaf.Module) || !leaf.Grants.TryGetValue(roleName, out var pair))
                continue;

            var view = pair.Length > 0 && pair[0] != 0 ? 1 : 0;
            var manage = pair.Length > 1 && pair[1] != 0 && view == 1 ? 1 : 0;
            void Acc(string key)
            {
                grants.TryGetValue(key, out var current);
                grants[key] = (Math.Max(current.View, view), Math.Max(current.Manage, manage));
            }

            Acc(leaf.Module);
            if (!string.IsNullOrWhiteSpace(leaf.Submodule))
                Acc(leaf.Module + "|" + leaf.Submodule);
            if (!string.IsNullOrWhiteSpace(leaf.SubSubmodule))
                Acc(leaf.Module + "|" + leaf.Submodule + "|" + leaf.SubSubmodule);
            if (!string.IsNullOrWhiteSpace(leaf.Widget))
                Acc(string.Join("|", new[] { leaf.Module, leaf.Submodule, leaf.SubSubmodule, leaf.Widget }.Where(s => !string.IsNullOrWhiteSpace(s))));
            if (!string.IsNullOrWhiteSpace(leaf.Tab))
                Acc(string.Join("|", new[] { leaf.Module, leaf.Submodule, leaf.SubSubmodule, leaf.Widget, leaf.Tab }.Where(s => !string.IsNullOrWhiteSpace(s))));
        }

        return grants;
    }

    private static string LeafType(BaselineLeaf leaf)
    {
        if (!string.IsNullOrWhiteSpace(leaf.Tab)) return "tab";
        if (!string.IsNullOrWhiteSpace(leaf.Widget)) return "widget";
        if (!string.IsNullOrWhiteSpace(leaf.SubSubmodule)) return "sub-submodule";
        if (!string.IsNullOrWhiteSpace(leaf.Submodule)) return "submodule";
        return "module";
    }

    private static void Bridge(HashSet<string> claims, string module, string leaf, int view, int manage)
    {
        if (view == 1)
        {
            switch (module)
            {
                case "Dashboard": claims.Add("dashboard.view"); break;
                case "Action Center": claims.Add("action-center.view"); break;
                case "Projects":
                    claims.Add("projects.view");
                    claims.Add(Permissions.ProjectsRead);
                    claims.Add(Permissions.WbsRead);
                    break;
                case "Reports":
                    claims.Add("reports.view");
                    claims.Add(Permissions.ReportsRead);
                    break;
                case "Resource":
                    claims.Add("resources.view");
                    claims.Add(Permissions.ResourcesRead);
                    break;
                case "Customers":
                    claims.Add("customers.view");
                    claims.Add(Permissions.ClientsRead);
                    break;
                case "Repository": claims.Add("repository.view"); break;
                case "My team": claims.Add(Permissions.MyTeamDashboardView); break;
                case "Settings": claims.Add("settings.view"); break;
            }

            if (leaf.Contains("Approval", StringComparison.OrdinalIgnoreCase))
                claims.Add(Permissions.TimesheetsMonitor);
            if (leaf.Contains("timesheet", StringComparison.OrdinalIgnoreCase) || leaf.Contains("timsheet", StringComparison.OrdinalIgnoreCase))
                claims.Add(Permissions.TimesheetsSubmit);
            if (leaf.Equals("Approvals", StringComparison.OrdinalIgnoreCase))
                claims.Add("approvals.view");

            if (leaf.Equals("Project Masters", StringComparison.OrdinalIgnoreCase))
            {
                claims.Add("settings.masters.view");
                claims.Add("settings.masters.projects.view");
                claims.Add("settings.masters.projects:view");
                claims.Add("settings.masters.project:view");
            }
            else if (leaf.Equals("Customer Masters", StringComparison.OrdinalIgnoreCase))
            {
                claims.Add("settings.masters.view");
                claims.Add("settings.masters.customers.view");
                claims.Add("settings.masters.customers:view");
                claims.Add("settings.masters.customer:view");
            }
            else if (leaf.Equals("Resource Master", StringComparison.OrdinalIgnoreCase))
            {
                claims.Add("settings.masters.view");
                claims.Add("settings.masters.resources.view");
                claims.Add("settings.masters.resources:view");
                claims.Add("settings.masters.resource:view");
            }
            else if (leaf.Equals("Masters", StringComparison.OrdinalIgnoreCase))
            {
                claims.Add("settings.masters.view");
            }
            else if (leaf.Contains("Role", StringComparison.OrdinalIgnoreCase) || leaf.Contains("Moduleswise", StringComparison.OrdinalIgnoreCase))
            {
                claims.Add("settings.roles.view");
                claims.Add("roles.view");
            }
        }

        if (manage == 1)
        {
            switch (module)
            {
                case "Projects":
                    if (leaf.Equals("projects Cards", StringComparison.OrdinalIgnoreCase) ||
                        leaf.Equals("Projects", StringComparison.OrdinalIgnoreCase))
                    {
                        claims.Add(Permissions.ProjectsWrite);
                        claims.Add(Permissions.WbsAllocate);
                        claims.Add("projects.create");
                        claims.Add("projects.manage");
                        claims.Add("projects.drafts");
                    }
                    else if (leaf.Equals("WBS", StringComparison.OrdinalIgnoreCase))
                    {
                        claims.Add(Permissions.WbsAllocate);
                    }
                    break;
                case "Resource": claims.Add(Permissions.ResourcesManage); break;
                case "Customers":
                    if (leaf.Equals("Customers Card", StringComparison.OrdinalIgnoreCase) ||
                        leaf.Equals("Customers", StringComparison.OrdinalIgnoreCase) ||
                        leaf.Equals("Customer profile", StringComparison.OrdinalIgnoreCase))
                    {
                        claims.Add(Permissions.ClientsWrite);
                        claims.Add("customers.create");
                        claims.Add("customers.manage");
                    }
                    break;
                case "Repository":
                    claims.Add("repository.upload");
                    claims.Add("repository.download");
                    break;
                case "Settings":
                    if (leaf.Contains("Role", StringComparison.OrdinalIgnoreCase) || leaf.Contains("Moduleswise", StringComparison.OrdinalIgnoreCase))
                    {
                        claims.Add(Permissions.RolesManage);
                        claims.Add(Permissions.UsersManage);
                        claims.Add("settings.manage_roles");
                        claims.Add("roles:manage");
                    }
                    break;
            }

            if (leaf.Contains("Invoice", StringComparison.OrdinalIgnoreCase) || leaf.Contains("Billing", StringComparison.OrdinalIgnoreCase))
            {
                claims.Add(Permissions.InvoicesRaise);
                claims.Add(Permissions.InvoicesPayment);
            }

            if (leaf.Contains("Approval", StringComparison.OrdinalIgnoreCase))
            {
                claims.Add(Permissions.TimesheetsApprove);
                claims.Add(Permissions.ApprovalsManage);
            }

            if (leaf.Equals("Project Masters", StringComparison.OrdinalIgnoreCase))
            {
                claims.Add("settings.masters.projects.manage");
                claims.Add("settings.masters.projects:manage");
                claims.Add("settings.masters.project:manage");
            }
            else if (leaf.Equals("Customer Masters", StringComparison.OrdinalIgnoreCase))
            {
                claims.Add("settings.masters.customers.manage");
                claims.Add("settings.masters.customers:manage");
                claims.Add("settings.masters.customer:manage");
            }
            else if (leaf.Equals("Resource Master", StringComparison.OrdinalIgnoreCase))
            {
                claims.Add("settings.masters.resources.manage");
                claims.Add("settings.masters.resources:manage");
                claims.Add("settings.masters.resource:manage");
            }
        }
    }

    private async Task<Guid> RoleIdAsync(string roleName, CancellationToken ct)
    {
        var ids = await db.Database.SqlQueryRaw<Guid>(
            """SELECT "Id" AS "Value" FROM auth.tbl_roles WHERE lower("Name") = lower({0}) AND "DeletedAtUtc" IS NULL""",
            roleName).ToListAsync(ct);
        if (ids.Count == 0)
            throw new InvalidOperationException($"Role '{roleName}' was not found.");
        return ids[0];
    }

    private async Task EnsurePermissionNodeAsync(
        Dictionary<string, Guid> permissionIds,
        string dictKey,
        Guid moduleId,
        Guid? submoduleId,
        Guid? parentWidgetId,
        string type,
        string widgetKey,
        string name,
        int sort,
        DateTime now,
        CancellationToken ct)
    {
        if (permissionIds.ContainsKey(dictKey)) return;
        var id = Guid.NewGuid();
        permissionIds[dictKey] = id;
        await InsertWidgetAsync(id, moduleId, submoduleId, parentWidgetId, type, widgetKey, name, sort, now, ct);
    }

    private async Task InsertModuleAsync(Guid id, string code, string name, int sort, DateTime now, CancellationToken ct) =>
        await db.Database.ExecuteSqlInterpolatedAsync(
            $"""
            INSERT INTO master.mst_modules ("Id", "Code", "Name", "SortOrder", "IsActive", "CreatedAtUtc")
            VALUES ({id}, {code}, {name}, {sort}, TRUE, {now})
            """,
            ct);

    private async Task InsertSubmoduleAsync(Guid id, Guid moduleId, Guid? parentId, string code, string name, int sort, DateTime now, CancellationToken ct) =>
        await db.Database.ExecuteSqlInterpolatedAsync(
            $"""
            INSERT INTO master.mst_submodules
                ("Id", "ModuleId", "ParentSubmoduleId", "Code", "Name", "SortOrder", "IsActive", "CreatedAtUtc")
            VALUES ({id}, {moduleId}, {parentId}, {code}, {name}, {sort}, TRUE, {now})
            """,
            ct);

    private async Task InsertWidgetAsync(
        Guid id, Guid moduleId, Guid? submoduleId, Guid? parentWidgetId, string type, string key, string name, int sort, DateTime now, CancellationToken ct) =>
        await db.Database.ExecuteSqlInterpolatedAsync(
            $"""
            INSERT INTO master.mst_widgets
                ("Id", "ModuleId", "SubmoduleId", "ParentWidgetId", "Code", "Name", "WidgetKey", "WidgetType", "HasManageAction", "SortOrder", "IsActive", "CreatedAtUtc")
            VALUES ({id}, {moduleId}, {submoduleId}, {parentWidgetId}, {Slug(key)}, {name}, {key}, {type}, TRUE, {sort}, TRUE, {now})
            """,
            ct);

    private async Task<BaselineFile> LoadBaselineAsync(CancellationToken ct)
    {
        var path = Path.Combine(environment.ContentRootPath, "Modules", "Rbac", "rbac-baseline.json");
        if (!File.Exists(path))
            path = Path.Combine(AppContext.BaseDirectory, "Modules", "Rbac", "rbac-baseline.json");
        await using var stream = File.OpenRead(path);
        return (await JsonSerializer.DeserializeAsync<BaselineFile>(stream, JsonOptions, ct))
            ?? throw new InvalidOperationException("RBAC baseline file is empty.");
    }

    private static string Slug(string value)
    {
        var chars = value.Trim().ToLowerInvariant().Select(ch => char.IsLetterOrDigit(ch) ? ch : '-').ToArray();
        var text = new string(chars);
        while (text.Contains("--", StringComparison.Ordinal))
            text = text.Replace("--", "-", StringComparison.Ordinal);
        text = text.Trim('-');
        return text.Length > 80 ? text[..80] : text;
    }

    private static readonly JsonSerializerOptions JsonOptions = new() { PropertyNameCaseInsensitive = true };

    private sealed class BaselineFile
    {
        public string Version { get; set; } = "";
        public List<BaselineLeaf> Leaves { get; set; } = [];
    }

    private sealed class BaselineLeaf
    {
        public string? Module { get; set; }
        public string? Submodule { get; set; }
        public string? SubSubmodule { get; set; }
        public string? Widget { get; set; }
        public string? Tab { get; set; }
        public Dictionary<string, int[]> Grants { get; set; } = [];
    }

    private sealed class ModuleRow
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = "";
        public int SortOrder { get; set; }
    }

    private sealed class SubmoduleRow
    {
        public Guid Id { get; set; }
        public Guid ModuleId { get; set; }
        public Guid? ParentSubmoduleId { get; set; }
        public string Name { get; set; } = "";
        public int SortOrder { get; set; }
    }

    private sealed class WidgetRow
    {
        public Guid Id { get; set; }
        public Guid? ModuleId { get; set; }
        public Guid? SubmoduleId { get; set; }
        public Guid? ParentWidgetId { get; set; }
        public string Name { get; set; } = "";
        public string WidgetType { get; set; } = "";
        public int SortOrder { get; set; }
    }

    private sealed class GrantRow
    {
        public Guid WidgetId { get; set; }
        public int CanView { get; set; }
        public int CanManage { get; set; }
    }

    private sealed class WidgetKeyRow
    {
        public Guid Id { get; set; }
        public string WidgetKey { get; set; } = "";
    }

    private sealed class ClaimRow
    {
        public string WidgetKey { get; set; } = "";
        public string Leaf { get; set; } = "";
        public int CanView { get; set; }
        public int CanManage { get; set; }
    }
}
