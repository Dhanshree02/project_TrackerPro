using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Users.Models;
using PMS.API.Shared.Common.Models;
using PMS.API.Shared.Constants;

namespace PMS.API.Infrastructure.Persistence.Seeding;

/// <summary>
/// Aligns catalogs with <c>docs/rbac.xlsx</c> and stores the link in
/// <c>master.mst_org_role_map</c> (DepartmentId + DesignationId → SubDepartment,
/// RbacRoleId).
/// </summary>
public static class OrgRoleMatrixSync
{
    public static async Task ApplyAsync(AppDbContext db, CancellationToken ct = default)
    {
        await EnsureSchemaAsync(db, ct);
        await AlignRbacDisplayNamesAsync(db, ct);
        await UpsertMapsAsync(db, ct);
        await UpsertOnFloorRolesAsync(db, ct);
        await ApplyEmployeeMappingAsync(db, ct);
        await SyncSubDepartmentLinksAsync(db, ct);
        await db.SaveChangesAsync(ct);
    }

    public static async Task<Dictionary<Guid, MstOrgRoleMap>> LoadByDesignationAsync(
        AppDbContext db,
        CancellationToken ct = default)
    {
        var maps = await db.OrgRoleMaps
            .AsNoTracking()
            .Include(m => m.RbacRole)
            .ToListAsync(ct);
        return maps
            .GroupBy(m => m.DesignationId)
            .ToDictionary(g => g.Key, g => g.First());
    }

    private static async Task EnsureSchemaAsync(AppDbContext db, CancellationToken ct)
    {
        var designations = db.TableName<MstDesignation>();
        var departments = db.TableName<MstDepartment>();
        var rbacRoles = db.TableName<Role>();
        var maps = db.TableName<MstOrgRoleMap>();

        await db.Database.ExecuteSqlRawAsync(
            $"""
            CREATE TABLE IF NOT EXISTS {maps} (
                "Id" uuid NOT NULL,
                "DepartmentId" uuid,
                "DesignationId" uuid NOT NULL,
                "SubDepartment" character varying(250),
                "RbacRoleId" uuid,
                "CreatedAtUtc" timestamp with time zone NOT NULL,
                "UpdatedAtUtc" timestamp with time zone,
                "CreatedBy" uuid,
                "UpdatedBy" uuid,
                "DeletedAtUtc" timestamp with time zone,
                CONSTRAINT "PK_mst_org_role_map" PRIMARY KEY ("Id")
            );
            """,
            ct);
        await db.Database.ExecuteSqlRawAsync(
            $"""CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_org_role_map_DesignationId" ON {maps} ("DesignationId");""",
            ct);
        await db.Database.ExecuteSqlRawAsync(
            $"""CREATE INDEX IF NOT EXISTS "IX_mst_org_role_map_DepartmentId" ON {maps} ("DepartmentId");""",
            ct);
        await db.Database.ExecuteSqlRawAsync(
            $"""
            DO $$
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'FK_mst_org_role_map_DepartmentId') THEN
                    ALTER TABLE {maps}
                        ADD CONSTRAINT "FK_mst_org_role_map_DepartmentId"
                        FOREIGN KEY ("DepartmentId") REFERENCES {departments} ("Id") ON DELETE SET NULL;
                END IF;
                IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'FK_mst_org_role_map_DesignationId') THEN
                    ALTER TABLE {maps}
                        ADD CONSTRAINT "FK_mst_org_role_map_DesignationId"
                        FOREIGN KEY ("DesignationId") REFERENCES {designations} ("Id") ON DELETE CASCADE;
                END IF;
                IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'FK_mst_org_role_map_RbacRoleId') THEN
                    ALTER TABLE {maps}
                        ADD CONSTRAINT "FK_mst_org_role_map_RbacRoleId"
                        FOREIGN KEY ("RbacRoleId") REFERENCES {rbacRoles} ("Id") ON DELETE SET NULL;
                END IF;
            END $$;
            """,
            ct);
    }

    private static async Task AlignRbacDisplayNamesAsync(AppDbContext db, CancellationToken ct)
    {
        var roles = await db.Roles.ToListAsync(ct);
        foreach (var role in roles)
        {
            if (OrgRoleMatrix.RbacDisplayNames.TryGetValue(role.Name, out var display))
            {
                role.DisplayName = display;
                role.IsActive = true;
            }
        }
    }

    private static async Task UpsertMapsAsync(
        AppDbContext db,
        CancellationToken ct)
    {
        var designations = await db.Designations
            .IgnoreQueryFilters()
            .Include(d => d.Department)
            .ToListAsync(ct);
        var rbacByName = await db.Roles.ToDictionaryAsync(r => r.Name, StringComparer.OrdinalIgnoreCase, ct);
        var maps = await db.OrgRoleMaps.IgnoreQueryFilters().ToListAsync(ct);
        var byDesignation = maps
            .Where(m => m.DeletedAtUtc == null)
            .GroupBy(m => m.DesignationId)
            .ToDictionary(g => g.Key, g => g.First());

        foreach (var desig in designations)
        {
            if (desig.DeletedAtUtc is not null) continue;
            if (!OrgRoleMatrix.TryFind(desig.Department?.Name, desig.Name, out var row)) continue;

            Guid? rbacId = null;
            var rbacKey = OrgRoleMatrix.RbacKey(row.RbacRole);
            if (rbacByName.TryGetValue(rbacKey, out var rbac))
            {
                rbacId = rbac.Id;
            }

            if (byDesignation.TryGetValue(desig.Id, out var map))
            {
                // Settings → Resource Masters owns an existing row. Fill blanks only.
                map.DepartmentId = desig.DepartmentId;
                if (string.IsNullOrWhiteSpace(map.SubDepartment))
                    map.SubDepartment = row.SubDepartment;
                if (map.RbacRoleId is null)
                    map.RbacRoleId = rbacId;
                map.DeletedAtUtc = null;
            }
            else
            {
                map = new MstOrgRoleMap
                {
                    DepartmentId = desig.DepartmentId,
                    DesignationId = desig.Id,
                    SubDepartment = row.SubDepartment,
                    RbacRoleId = rbacId,
                };
                db.OrgRoleMaps.Add(map);
                byDesignation[desig.Id] = map;
            }

            if (string.IsNullOrWhiteSpace(desig.SubDepartment))
                desig.SubDepartment = row.SubDepartment;
            if (desig.DefaultRoleId is null && rbacId.HasValue) desig.DefaultRoleId = rbacId;
        }
    }

    private static async Task UpsertOnFloorRolesAsync(AppDbContext db, CancellationToken ct)
    {
        var designations = await db.Designations
            .IgnoreQueryFilters()
            .Include(d => d.Department)
            .ToListAsync(ct);
        var rbacByName = await db.Roles.ToDictionaryAsync(r => r.Name, StringComparer.OrdinalIgnoreCase, ct);
        var maps = await db.OrgRoleMaps.AsNoTracking().ToListAsync(ct);
        var mapByDesignation = maps
            .GroupBy(m => m.DesignationId)
            .ToDictionary(g => g.Key, g => g.First());
        var existing = await db.OnFloorRoles.IgnoreQueryFilters().ToListAsync(ct);
        var byDesignation = existing
            .Where(r => r.DeletedAtUtc == null)
            .GroupBy(r => r.DesignationId)
            .ToDictionary(g => g.Key, g => g.First());

        foreach (var desig in designations)
        {
            if (desig.DeletedAtUtc is not null) continue;
            if (!OrgRoleMatrix.TryFind(desig.Department?.Name, desig.Name, out var row)) continue;

            mapByDesignation.TryGetValue(desig.Id, out var map);
            Guid? rbacId = map?.RbacRoleId;
            if (rbacId is null && rbacByName.TryGetValue(OrgRoleMatrix.RbacKey(row.RbacRole), out var rbac))
                rbacId = rbac.Id;

            var subDepartment = map?.SubDepartment;
            if (string.IsNullOrWhiteSpace(subDepartment))
                subDepartment = string.IsNullOrWhiteSpace(desig.SubDepartment) ? row.SubDepartment : desig.SubDepartment;

            if (byDesignation.TryGetValue(desig.Id, out var floor))
            {
                floor.Name = row.OnFloorRole;
                floor.DepartmentId = desig.DepartmentId;
                floor.SubDepartment = subDepartment;
                floor.RbacRoleId = rbacId;
                floor.DeletedAtUtc = null;
                continue;
            }

            floor = new OnFloorRole
            {
                Name = row.OnFloorRole,
                DepartmentId = desig.DepartmentId,
                DesignationId = desig.Id,
                SubDepartment = subDepartment,
                RbacRoleId = rbacId,
            };
            db.OnFloorRoles.Add(floor);
            byDesignation[desig.Id] = floor;
        }
    }

    private static async Task ApplyEmployeeMappingAsync(AppDbContext db, CancellationToken ct)
    {
        var employees = await db.Employees
            .IgnoreQueryFilters()
            .ToListAsync(ct);
        var users = await db.Users.ToListAsync(ct);
        var rbacByName = await db.Roles.ToDictionaryAsync(r => r.Name, StringComparer.OrdinalIgnoreCase, ct);
        var maps = await db.OrgRoleMaps
            .Include(m => m.RbacRole)
            .ToListAsync(ct);
        var byDesignation = maps
            .GroupBy(m => m.DesignationId)
            .ToDictionary(g => g.Key, g => g.First());

        foreach (var employee in employees)
        {
            if (employee.DeletedAtUtc is not null) continue;
            if (employee.DesignationId is not Guid desigId) continue;
            if (!byDesignation.TryGetValue(desigId, out var map)) continue;

            if (!string.IsNullOrWhiteSpace(map.SubDepartment))
            {
                employee.SubDepartment ??= map.SubDepartment;
            }

            if (OrgRoleMatrix.IsSuperAdmin(employee.EmployeeCode, employee.WorkEmail))
            {
                employee.Role = OrgRoleMatrix.SuperAdminRbac;
                SyncUserRole(users, employee, rbacByName, OrgRoleMatrix.SuperAdminRbac);
                continue;
            }

            if (map.RbacRole is not null)
            {
                employee.Role = map.RbacRole.Name;
                SyncUserRole(users, employee, rbacByName, map.RbacRole.Name);
            }
        }
    }

    public static async Task SyncSubDepartmentLinksAsync(AppDbContext db, CancellationToken ct = default)
    {
        var designations = await LoadIncludingAddedAsync(db.Designations.IgnoreQueryFilters(), db, ct);
        var maps = await LoadIncludingAddedAsync(db.OrgRoleMaps.IgnoreQueryFilters(), db, ct);
        var floors = await LoadIncludingAddedAsync(db.OnFloorRoles.IgnoreQueryFilters(), db, ct);
        var employees = await LoadIncludingAddedAsync(db.Employees.IgnoreQueryFilters(), db, ct);

        var departmentIdsByName = new Dictionary<string, HashSet<Guid>>(StringComparer.OrdinalIgnoreCase);
        void Note(string? raw, Guid? departmentId)
        {
            foreach (var name in SplitSubDepartmentNames(raw))
            {
                if (!departmentIdsByName.TryGetValue(name, out var set))
                {
                    set = [];
                    departmentIdsByName[name] = set;
                }
                if (departmentId is Guid id) set.Add(id);
            }
        }

        foreach (var desig in designations.Where(d => d.DeletedAtUtc is null))
            Note(desig.SubDepartment, desig.DepartmentId);
        foreach (var map in maps.Where(m => m.DeletedAtUtc is null))
            Note(map.SubDepartment, map.DepartmentId);
        foreach (var floor in floors.Where(f => f.DeletedAtUtc is null))
            Note(floor.SubDepartment, floor.DepartmentId);
        foreach (var employee in employees.Where(e => e.DeletedAtUtc is null))
            Note(employee.SubDepartment, employee.DepartmentId);

        var catalog = await db.SubDepartments.IgnoreQueryFilters().ToListAsync(ct);
        var byName = catalog
            .Where(s => s.DeletedAtUtc == null)
            .GroupBy(s => NormalizeSubDepartmentName(s.Name), StringComparer.OrdinalIgnoreCase)
            .ToDictionary(g => g.Key, g => g.First(), StringComparer.OrdinalIgnoreCase);
        var usedCodes = catalog.Select(s => s.Code).ToHashSet(StringComparer.OrdinalIgnoreCase);

        foreach (var (name, departmentIds) in departmentIdsByName)
        {
            Guid? departmentId = departmentIds.Count == 1 ? departmentIds.First() : null;
            if (!byName.TryGetValue(name, out var row))
            {
                var code = NextSubDepartmentCode(name, usedCodes);
                row = new MstSubDepartment
                {
                    Code = code,
                    Name = name,
                    IsActive = true,
                    DepartmentId = departmentId,
                };
                db.SubDepartments.Add(row);
                byName[name] = row;
                continue;
            }

            row.Name = name;
            row.IsActive = true;
            row.DeletedAtUtc = null;
            row.DepartmentId = departmentId;
        }

        await db.SaveChangesAsync(ct);

        await ReplaceDesignationLinksAsync(db, designations, byName, ct);
        await ReplaceOrgRoleLinksAsync(db, maps, byName, ct);
        await ReplaceOnFloorLinksAsync(db, floors, byName, ct);

        foreach (var employee in employees.Where(e => e.DeletedAtUtc is null))
        {
            var names = SplitSubDepartmentNames(employee.SubDepartment);
            if (names.Count != 1 || !byName.TryGetValue(names[0], out var match))
            {
                if (names.Count != 1) employee.SubDepartmentId = null;
                continue;
            }

            employee.SubDepartmentId = match.Id;
            employee.SubDepartment = match.Name;
        }
    }

    public static async Task AssignEmployeeSubDepartmentAsync(AppDbContext db, Employee employee, CancellationToken ct = default)
    {
        var names = SplitSubDepartmentNames(employee.SubDepartment);
        if (names.Count != 1)
        {
            employee.SubDepartmentId = null;
            return;
        }

        var name = names[0];
        var match = await db.SubDepartments
            .FirstOrDefaultAsync(s => s.Name.ToLower() == name.ToLower(), ct);
        if (match is null)
        {
            var used = (await db.SubDepartments.IgnoreQueryFilters().Select(s => s.Code).ToListAsync(ct))
                .ToHashSet(StringComparer.OrdinalIgnoreCase);
            match = new MstSubDepartment
            {
                Code = NextSubDepartmentCode(name, used),
                Name = name,
                IsActive = true,
                DepartmentId = employee.DepartmentId,
            };
            db.SubDepartments.Add(match);
        }

        employee.SubDepartmentId = match.Id;
        employee.SubDepartment = match.Name;
    }

    private static async Task<List<T>> LoadIncludingAddedAsync<T>(
        IQueryable<T> query,
        AppDbContext db,
        CancellationToken ct)
        where T : BaseEntity
    {
        var loaded = await query.ToListAsync(ct);
        var known = loaded.Select(row => row.Id).ToHashSet();
        foreach (var entry in db.ChangeTracker.Entries<T>())
        {
            if (entry.State == EntityState.Added && known.Add(entry.Entity.Id))
                loaded.Add(entry.Entity);
        }

        return loaded;
    }

    public static string NormalizeSubDepartmentName(string name)
    {
        var trimmed = Regex.Replace(name.Replace('\u00a0', ' '), @"\s+", " ").Trim();
        return trimmed.Replace(" Dept.", " Department", StringComparison.Ordinal);
    }

    public static List<string> SplitSubDepartmentNames(string? value)
    {
        if (string.IsNullOrWhiteSpace(value)) return [];
        return value.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
            .Select(NormalizeSubDepartmentName)
            .Where(name => name.Length > 0)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();
    }

    private static async Task ReplaceDesignationLinksAsync(
        AppDbContext db,
        List<MstDesignation> designations,
        Dictionary<string, MstSubDepartment> byName,
        CancellationToken ct)
    {
        var existing = await db.DesignationSubDepartments.ToListAsync(ct);
        if (existing.Count > 0) db.DesignationSubDepartments.RemoveRange(existing);

        foreach (var desig in designations.Where(d => d.DeletedAtUtc is null))
        {
            var names = SplitSubDepartmentNames(desig.SubDepartment);
            var linked = names.Where(byName.ContainsKey).Select(name => byName[name]).ToList();
            if (linked.Count == 0) continue;
            desig.SubDepartment = string.Join(", ", linked.Select(row => row.Name));
            foreach (var row in linked)
            {
                db.DesignationSubDepartments.Add(new MstDesignationSubDepartment
                {
                    DesignationId = desig.Id,
                    SubDepartmentId = row.Id,
                });
            }
        }
    }

    private static async Task ReplaceOrgRoleLinksAsync(
        AppDbContext db,
        List<MstOrgRoleMap> maps,
        Dictionary<string, MstSubDepartment> byName,
        CancellationToken ct)
    {
        var existing = await db.OrgRoleSubDepartments.ToListAsync(ct);
        if (existing.Count > 0) db.OrgRoleSubDepartments.RemoveRange(existing);

        foreach (var map in maps.Where(m => m.DeletedAtUtc is null))
        {
            var names = SplitSubDepartmentNames(map.SubDepartment);
            var linked = names.Where(byName.ContainsKey).Select(name => byName[name]).ToList();
            if (linked.Count == 0) continue;
            map.SubDepartment = string.Join(", ", linked.Select(row => row.Name));
            foreach (var row in linked)
            {
                db.OrgRoleSubDepartments.Add(new MstOrgRoleSubDepartment
                {
                    OrgRoleMapId = map.Id,
                    SubDepartmentId = row.Id,
                });
            }
        }
    }

    private static async Task ReplaceOnFloorLinksAsync(
        AppDbContext db,
        List<OnFloorRole> floors,
        Dictionary<string, MstSubDepartment> byName,
        CancellationToken ct)
    {
        var existing = await db.OnFloorRoleSubDepartments.ToListAsync(ct);
        if (existing.Count > 0) db.OnFloorRoleSubDepartments.RemoveRange(existing);

        foreach (var floor in floors.Where(f => f.DeletedAtUtc is null))
        {
            var names = SplitSubDepartmentNames(floor.SubDepartment);
            var linked = names.Where(byName.ContainsKey).Select(name => byName[name]).ToList();
            if (linked.Count == 0) continue;
            floor.SubDepartment = string.Join(", ", linked.Select(row => row.Name));
            foreach (var row in linked)
            {
                db.OnFloorRoleSubDepartments.Add(new OnFloorRoleSubDepartment
                {
                    OnFloorRoleId = floor.Id,
                    SubDepartmentId = row.Id,
                });
            }
        }
    }

    private static string NextSubDepartmentCode(string name, HashSet<string> usedCodes)
    {
        var slug = Regex.Replace(name.ToLowerInvariant(), @"[^a-z0-9]+", "_").Trim('_');
        if (slug.Length == 0) slug = "sub_department";
        if (slug.Length > 70) slug = slug[..70];
        var code = slug;
        var n = 2;
        while (!usedCodes.Add(code))
        {
            var suffix = $"_{n}";
            code = slug.Length + suffix.Length > 80 ? slug[..(80 - suffix.Length)] + suffix : slug + suffix;
            n++;
        }
        return code;
    }

    private static void SyncUserRole(
        IEnumerable<User> users,
        Employee employee,
        IReadOnlyDictionary<string, Role> rbacByName,
        string rbacKey)
    {
        if (!rbacByName.TryGetValue(rbacKey, out var rbac)) return;
        var user = users.FirstOrDefault(u =>
            string.Equals(u.Email, employee.WorkEmail, StringComparison.OrdinalIgnoreCase)
            || string.Equals(u.EmployeeId, employee.EmployeeCode, StringComparison.OrdinalIgnoreCase));
        if (user is null) return;
        user.RoleId = rbac.Id;
    }
}
