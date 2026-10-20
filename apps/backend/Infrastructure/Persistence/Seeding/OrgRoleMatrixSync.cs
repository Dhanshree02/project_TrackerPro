using Microsoft.EntityFrameworkCore;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Users.Models;
using PMS.API.Shared.Constants;

namespace PMS.API.Infrastructure.Persistence.Seeding;

/// <summary>
/// Aligns catalogs with <c>docs/rbac.xlsx</c> and stores the link in
/// <c>master.mst_org_role_map</c> (DepartmentId + DesignationId → SubDepartment,
/// OnFloorRoleId, RbacRoleId). Designation FKs stay as copies so existing APIs
/// keep working.
/// </summary>
public static class OrgRoleMatrixSync
{
    public static async Task ApplyAsync(AppDbContext db, CancellationToken ct = default)
    {
        await EnsureSchemaAsync(db, ct);
        var onFloorByName = await EnsureOnFloorCatalogAsync(db, ct);
        await AlignRbacDisplayNamesAsync(db, ct);
        await UpsertMapsAsync(db, onFloorByName, ct);
        await ApplyEmployeeMappingAsync(db, ct);
        await RetireDuplicateOnFloorRolesAsync(db, onFloorByName, ct);
        await db.SaveChangesAsync(ct);
    }

    public static async Task<Dictionary<Guid, MstOrgRoleMap>> LoadByDesignationAsync(
        AppDbContext db,
        CancellationToken ct = default)
    {
        var maps = await db.OrgRoleMaps
            .AsNoTracking()
            .Include(m => m.OnFloorRole)
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
        var jobRoles = db.TableName<MstRole>();
        var rbacRoles = db.TableName<Role>();
        var maps = db.TableName<MstOrgRoleMap>();

        await db.Database.ExecuteSqlRawAsync(
            $"""ALTER TABLE {jobRoles} ALTER COLUMN "DesignationId" DROP NOT NULL;""",
            ct);
        await db.Database.ExecuteSqlRawAsync(
            $"""ALTER TABLE {designations} ADD COLUMN IF NOT EXISTS "JobRoleId" uuid;""",
            ct);
        await db.Database.ExecuteSqlRawAsync(
            $"""CREATE INDEX IF NOT EXISTS "IX_mst_designations_JobRoleId" ON {designations} ("JobRoleId");""",
            ct);
        await db.Database.ExecuteSqlRawAsync(
            $"""
            DO $$
            BEGIN
                IF NOT EXISTS (
                    SELECT 1 FROM pg_constraint WHERE conname = 'FK_mst_designations_mst_roles_JobRoleId'
                ) THEN
                    ALTER TABLE {designations}
                        ADD CONSTRAINT "FK_mst_designations_mst_roles_JobRoleId"
                        FOREIGN KEY ("JobRoleId") REFERENCES {jobRoles} ("Id") ON DELETE SET NULL;
                END IF;
            END $$;
            """,
            ct);

        await db.Database.ExecuteSqlRawAsync(
            $"""
            CREATE TABLE IF NOT EXISTS {maps} (
                "Id" uuid NOT NULL,
                "DepartmentId" uuid,
                "DesignationId" uuid NOT NULL,
                "SubDepartment" character varying(250),
                "OnFloorRoleId" uuid,
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
                IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'FK_mst_org_role_map_OnFloorRoleId') THEN
                    ALTER TABLE {maps}
                        ADD CONSTRAINT "FK_mst_org_role_map_OnFloorRoleId"
                        FOREIGN KEY ("OnFloorRoleId") REFERENCES {jobRoles} ("Id") ON DELETE SET NULL;
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

    public static async Task<Dictionary<string, MstRole>> EnsureOnFloorCatalogAsync(
        AppDbContext db,
        CancellationToken ct)
    {
        var existing = await db.JobRoles.IgnoreQueryFilters().ToListAsync(ct);
        var byName = existing
            .Where(r => r.DeletedAtUtc == null)
            .GroupBy(r => r.Name.Trim(), StringComparer.OrdinalIgnoreCase)
            .ToDictionary(g => g.Key, g => g.OrderBy(r => r.DesignationId.HasValue).ThenBy(r => r.CreatedAtUtc).First(), StringComparer.OrdinalIgnoreCase);

        var usedCodes = existing.Select(r => r.Code).ToHashSet(StringComparer.OrdinalIgnoreCase);

        foreach (var name in OrgRoleMatrix.OnFloorRoles)
        {
            if (byName.TryGetValue(name, out var found))
            {
                found.Name = name;
                found.IsActive = true;
                found.DeletedAtUtc = null;
                found.DesignationId = null;
                continue;
            }

            var code = OrgRoleMatrix.OnFloorCode(name);
            var n = 2;
            while (usedCodes.Contains(code))
            {
                code = $"{OrgRoleMatrix.OnFloorCode(name)}_{n}";
                n++;
            }

            var row = new MstRole
            {
                Code = code,
                Name = name,
                IsActive = true,
                DesignationId = null,
            };
            db.JobRoles.Add(row);
            usedCodes.Add(code);
            byName[name] = row;
        }

        await db.SaveChangesAsync(ct);
        return byName;
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
        IReadOnlyDictionary<string, MstRole> onFloorByName,
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

            Guid? onFloorId = onFloorByName.TryGetValue(row.OnFloorRole, out var floor) ? floor.Id : null;
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
                if (map.OnFloorRoleId is null)
                    map.OnFloorRoleId = onFloorId;
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
                    OnFloorRoleId = onFloorId,
                    RbacRoleId = rbacId,
                };
                db.OrgRoleMaps.Add(map);
                byDesignation[desig.Id] = map;
            }

            if (string.IsNullOrWhiteSpace(desig.SubDepartment))
                desig.SubDepartment = row.SubDepartment;
            if (desig.JobRoleId is null && onFloorId.HasValue) desig.JobRoleId = onFloorId;
            if (desig.DefaultRoleId is null && rbacId.HasValue) desig.DefaultRoleId = rbacId;
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

            if (map.OnFloorRoleId.HasValue)
            {
                employee.JobRoleId = map.OnFloorRoleId;
            }

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

    private static async Task RetireDuplicateOnFloorRolesAsync(
        AppDbContext db,
        IReadOnlyDictionary<string, MstRole> keepByName,
        CancellationToken ct)
    {
        var canonical = new HashSet<string>(OrgRoleMatrix.OnFloorRoles, StringComparer.OrdinalIgnoreCase);
        var keepIds = keepByName.Values.Select(r => r.Id).ToHashSet();
        var extras = await db.JobRoles
            .IgnoreQueryFilters()
            .Where(r => r.DeletedAtUtc == null && !keepIds.Contains(r.Id))
            .ToListAsync(ct);
        if (extras.Count == 0) return;

        var now = DateTime.UtcNow;
        foreach (var extra in extras)
        {
            // Keep on-floor roles added from Resource Masters. Only retire a second copy of a canonical name.
            if (!canonical.Contains(extra.Name.Trim()))
                continue;
            extra.IsActive = false;
            extra.DeletedAtUtc = now;
            extra.Code = Truncate($"retired_{extra.Code}_{extra.Id.ToString("N")[..8]}", 80);
            extra.Name = Truncate($"retired_{extra.Name}_{extra.Id.ToString("N")[..8]}", 150);
        }
    }

    private static string Truncate(string value, int max) =>
        value.Length <= max ? value : value[..max];
}
