using Microsoft.EntityFrameworkCore;
using PMS.API.Shared.Constants;
using PMS.API.Shared.Exceptions;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Modules.Users.Services;
using PMS.API.Modules.Users.DTOs;
using PMS.API.Shared.Common.Wrappers;
using PMS.API.Modules.Users.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Shared.Validation;
using PMS.API.Infrastructure.Authentication;

namespace PMS.API.Modules.Users.Services;

public sealed class UserService(
    AppDbContext db,
    IPasswordHasher hasher,
    ICurrentUserService currentUser,
    IRbacAuthorizationService rbacAuthService) : IUserService
{
    /// <summary>Temporary password handed to new/reset users — must be changed on first login.</summary>
    public const string TempPassword = "Temp@12345";

    public async Task<PagedResult<UserDto>> GetUsersAsync(
        int page,
        int perPage,
        string? search,
        string? role,
        CancellationToken ct = default)
    {
        var query = db.Users.Include(u => u.Role).AsQueryable();

        if (!string.IsNullOrWhiteSpace(search))
        {
            var needle = search.Trim().ToLower();
            query = query.Where(u =>
                u.Name.ToLower().Contains(needle) ||
                u.Email.ToLower().Contains(needle) ||
                u.EmployeeId.ToLower().Contains(needle));
        }

        if (!string.IsNullOrWhiteSpace(role))
        {
            var roleKey = role.Trim();
            query = query.Where(u => u.Role != null && u.Role.Name == roleKey);
        }

        var total = await query.CountAsync(ct);

        var users = await query
            .OrderBy(u => u.Name)
            .Skip((page - 1) * perPage)
            .Take(perPage)
            .ToListAsync(ct);

        return new PagedResult<UserDto>(users.Select(MapToDto).ToList(), page, perPage, total);
    }

    public async Task<UserDto?> GetUserAsync(Guid id, CancellationToken ct = default)
    {
        var user = await db.Users.Include(u => u.Role).FirstOrDefaultAsync(u => u.Id == id, ct);
        return user is null ? null : MapToDto(user);
    }

    public async Task<UserDto> CreateUserAsync(CreateUserRequest request, CancellationToken ct = default)
    {
        if (await db.Users.AnyAsync(u => u.Email == EmailRules.Normalize(request.Email).ToLowerInvariant(), ct))
            throw new ConflictException("A user with this email already exists.");

        if (await db.Users.AnyAsync(u => u.EmployeeId == request.EmployeeId, ct))
            throw new ConflictException("A user with this employee id already exists.");

        var role = await GetRoleByKeyAsync(request.Role, ct);

        var user = new User
        {
            Email = EmailRules.Normalize(request.Email).ToLowerInvariant(),
            Name = request.Name.Trim(),
            EmployeeId = request.EmployeeId.Trim(),
            Avatar = request.Avatar,
            Department = request.Department,
            SubDepartment = request.SubDepartment,
            Designation = request.Designation,
            RoleId = role.Id,
            PasswordHash = hasher.Hash(TempPassword),
            MustChangePassword = true,
        };

        db.Users.Add(user);
        await db.SaveChangesAsync(ct);

        return MapToDto(user);
    }

    public async Task<UserDto?> UpdateUserAsync(Guid id, UpdateUserRequest request, CancellationToken ct = default)
    {
        var user = await db.Users.Include(u => u.Role).FirstOrDefaultAsync(u => u.Id == id, ct);
        if (user is null) return null;

        var targetRole = request.Role is not null ? await GetRoleByKeyAsync(request.Role, ct) : null;

        // Self-guard: an admin must not be able to deactivate or demote their own
        // account — with no self-service recovery path that would be a permanent
        // lockout of the last admin.
        if (currentUser.UserId == user.Id)
        {
            if (request.IsActive == false)
                throw new ForbiddenException("You cannot deactivate your own account.");
            if (targetRole is not null && user.RoleId != targetRole.Id)
                throw new ForbiddenException("You cannot change your own role.");
        }

        var isAdmin = user.Role != null && string.Equals(user.Role.Name, "Admin", StringComparison.OrdinalIgnoreCase);
        var losesAdmin =
            (request.IsActive == false && isAdmin) ||
            (targetRole is not null && isAdmin && !string.Equals(targetRole.Name, "Admin", StringComparison.OrdinalIgnoreCase));
        if (losesAdmin && await IsLastAdminAsync(user.Id, ct))
            throw new ForbiddenException("Cannot remove the last Admin.");

        if (request.Name is not null) user.Name = request.Name.Trim();
        if (request.Avatar is not null) user.Avatar = request.Avatar;
        if (request.Department is not null) user.Department = request.Department;
        if (request.SubDepartment is not null) user.SubDepartment = request.SubDepartment;
        if (request.Designation is not null) user.Designation = request.Designation;
        if (request.IsActive is { } isActive) user.IsActive = isActive;

        if (targetRole is not null && user.RoleId != targetRole.Id)
        {
            if (!targetRole.IsActive)
                throw new ForbiddenException("Cannot assign an inactive role.");

            user.RoleId = targetRole.Id;
            // Role change revokes sessions so the new permissions take effect immediately.
            var tokens = await db.RefreshTokens.Where(t => t.UserId == user.Id && t.RevokedAtUtc == null).ToListAsync(ct);
            foreach (var t in tokens) t.RevokedAtUtc = DateTime.UtcNow;
        }

        await db.SaveChangesAsync(ct);
        return MapToDto(user);
    }

    public async Task<bool> ResetPasswordAsync(Guid id, ResetPasswordRequest request, CancellationToken ct = default)
    {
        var user = await db.Users.FirstOrDefaultAsync(u => u.Id == id, ct);
        if (user is null) return false;

        user.PasswordHash = hasher.Hash(request.NewPassword);
        user.MustChangePassword = true;
        user.FailedLoginAttempts = 0;
        user.LockedUntilUtc = null;

        var tokens = await db.RefreshTokens.Where(t => t.UserId == user.Id && t.RevokedAtUtc == null).ToListAsync(ct);
        foreach (var t in tokens) t.RevokedAtUtc = DateTime.UtcNow;

        await db.SaveChangesAsync(ct);
        return true;
    }

    // ---------- Roles ----------

    public async Task<IReadOnlyList<RoleDto>> GetRolesAsync(CancellationToken ct = default) =>
        await db.Roles
            .OrderBy(r => r.DisplayName)
            .Select(r => new RoleDto(
                r.Id,
                r.Name,
                r.DisplayName,
                r.Description,
                r.IsSystemRole,
                r.IsActive,
                r.Users.Count())) // count all users (soft-deleted excluded by global filter)
            .ToListAsync(ct);

    public async Task<RoleDto?> GetRoleAsync(Guid id, CancellationToken ct = default)
    {
        var role = await db.Roles.FirstOrDefaultAsync(r => r.Id == id, ct);
        return role is null ? null : MapToRoleDto(role, await db.Users.CountAsync(u => u.RoleId == role.Id, ct));
    }

    public async Task<RoleDto> CreateRoleAsync(CreateRoleRequest request, CancellationToken ct = default)
    {
        var key = NormalizeRoleKey(request.Name);
        if (await db.Roles.AnyAsync(r => r.Name == key, ct))
            throw new ConflictException($"A role with key '{key}' already exists.");

        if (request.CloneFromRoleId is { } sourceId)
        {
            var source = await db.Roles.FirstOrDefaultAsync(r => r.Id == sourceId, ct)
                ?? throw new NotFoundException("Source role not found.");
            if (string.IsNullOrWhiteSpace(request.Description))
                request = request with { Description = source.Description };
        }

        var role = new Role
        {
            Name = key,
            DisplayName = request.DisplayName?.Trim() ?? key,
            Description = request.Description,
            IsSystemRole = false,
            IsActive = true,
        };

        db.Roles.Add(role);
        await db.SaveChangesAsync(ct);
        return MapToRoleDto(role, 0);
    }

    public async Task<RoleDto?> UpdateRoleAsync(Guid id, UpdateRoleRequest request, CancellationToken ct = default)
    {
        var role = await db.Roles.FirstOrDefaultAsync(r => r.Id == id, ct);
        if (role is null) return null;

        // System roles (Admin, Dhanshree, ...) cannot be deactivated — that would
        // be a permanent lockout with no recovery path.
        if (request.IsActive == false && role.IsSystemRole)
            throw new ForbiddenException("System roles cannot be deactivated.");

        if (request.DisplayName is not null) role.DisplayName = request.DisplayName.Trim();
        if (request.Description is not null) role.Description = request.Description;
        if (request.IsActive is { } isActive) role.IsActive = isActive;

        await db.SaveChangesAsync(ct);
        return MapToRoleDto(role, await db.Users.CountAsync(u => u.RoleId == role.Id, ct));
    }

    public async Task<RoleDto> CloneRoleAsync(Guid id, CloneRoleRequest request, CancellationToken ct = default)
    {
        var source = await db.Roles.FirstOrDefaultAsync(r => r.Id == id, ct)
            ?? throw new NotFoundException("Source role not found.");

        var key = NormalizeRoleKey(request.Name);
        if (await db.Roles.AnyAsync(r => r.Name == key, ct))
            throw new ConflictException($"A role with key '{key}' already exists.");

        var role = new Role
        {
            Name = key,
            DisplayName = request.DisplayName?.Trim() ?? $"{source.DisplayName} (Copy)",
            Description = request.Description ?? $"Cloned from {source.DisplayName}",
            IsSystemRole = false,
            IsActive = true,
        };

        db.Roles.Add(role);
        await db.SaveChangesAsync(ct);
        return MapToRoleDto(role, 0);
    }

    public async Task<IReadOnlyList<RolePermissionDto>> GetRolePermissionsAsync(Guid roleId, CancellationToken ct = default)
    {
        return await db.RolePermissions
            .AsNoTracking()
            .Where(p => p.RoleId == roleId && (p.CanView == 1 || p.CanManage == 1 || p.DefaultCanView == 1 || p.DefaultCanManage == 1))
            .Select(p => new RolePermissionDto(p.ItemId, p.ItemType, p.CanView, p.CanManage, p.DefaultCanView, p.DefaultCanManage))
            .ToListAsync(ct);
    }

    public async Task<bool> UpdateRolePermissionsAsync(Guid roleId, IReadOnlyList<RolePermissionDto> permissions, CancellationToken ct = default)
    {
        var roleExists = await db.Roles.AnyAsync(r => r.Id == roleId, ct);
        if (!roleExists) return false;

        var existing = await db.RolePermissions
            .IgnoreQueryFilters()
            .Where(p => p.RoleId == roleId)
            .ToDictionaryAsync(p => p.ItemId, ct);

        var incomingMap = permissions.ToDictionary(p => p.ItemId, p => p);

        // Update existing rows or revoke access
        foreach (var (itemId, row) in existing)
        {
            if (incomingMap.TryGetValue(itemId, out var p))
            {
                row.CanView = p.CanView;
                row.CanManage = p.CanManage;
                if (p.DefaultCanView != 0 || p.DefaultCanManage != 0)
                {
                    row.DefaultCanView = p.DefaultCanView;
                    row.DefaultCanManage = p.DefaultCanManage;
                }
                row.UpdatedAtUtc = DateTime.UtcNow;
            }
            else
            {
                // Item omitted from save payload -> revoke active access while preserving defaults
                row.CanView = 0;
                row.CanManage = 0;
                row.UpdatedAtUtc = DateTime.UtcNow;
            }
        }

        // Add new rows for items not previously in DB
        foreach (var (itemId, p) in incomingMap)
        {
            if (!existing.ContainsKey(itemId) && (p.CanView == 1 || p.CanManage == 1 || p.DefaultCanView == 1 || p.DefaultCanManage == 1))
            {
                db.RolePermissions.Add(new RolePermission
                {
                    RoleId = roleId,
                    ItemId = p.ItemId,
                    ItemType = p.ItemType,
                    CanView = p.CanView,
                    CanManage = p.CanManage,
                    DefaultCanView = p.DefaultCanView,
                    DefaultCanManage = p.DefaultCanManage,
                    CreatedAtUtc = DateTime.UtcNow,
                });
            }
        }

        await db.SaveChangesAsync(ct);
        rbacAuthService.InvalidateRoleCache(roleId);
        return true;
    }

    public async Task<bool> ResetRolePermissionsToDefaultAsync(Guid roleId, CancellationToken ct = default)
    {
        var roleExists = await db.Roles.AnyAsync(r => r.Id == roleId, ct);
        if (!roleExists) return false;

        var perms = await db.RolePermissions
            .IgnoreQueryFilters()
            .Where(p => p.RoleId == roleId)
            .ToListAsync(ct);

        foreach (var p in perms)
        {
            p.CanView = p.DefaultCanView;
            p.CanManage = p.DefaultCanManage;
            p.UpdatedAtUtc = DateTime.UtcNow;
        }

        await db.SaveChangesAsync(ct);
        rbacAuthService.InvalidateRoleCache(roleId);
        return true;
    }

    // ---------- internals ----------

    /// <summary>True when this user is the only active user on the Admin role.</summary>
    private async Task<bool> IsLastAdminAsync(Guid id, CancellationToken ct)
    {
        return !await db.Users.AnyAsync(
            u => u.Id != id && u.IsActive && u.Role != null && u.Role.Name == "Admin",
            ct);
    }

    private async Task<Role> GetRoleByKeyAsync(string roleKey, CancellationToken ct)
    {
        var key = NormalizeRoleKey(roleKey);
        return await db.Roles.FirstOrDefaultAsync(r => r.Name == key, ct)
            ?? throw new NotFoundException($"Role '{roleKey}' does not exist.");
    }

    private static string NormalizeRoleKey(string key)
    {
        var trimmed = key?.Trim() ?? string.Empty;
        if (trimmed.Length == 0)
            throw new ConflictException("Role key is required.");
        if (trimmed.Length > 50)
            throw new ConflictException("Role key must be 50 characters or fewer.");
        return trimmed;
    }

    private static RoleDto MapToRoleDto(Role role, int userCount) => new(
        role.Id,
        role.Name,
        role.DisplayName,
        role.Description,
        role.IsSystemRole,
        role.IsActive,
        userCount);

    private static UserDto MapToDto(User u) => new(
        u.Id,
        u.Email,
        u.Name,
        u.EmployeeId,
        u.Avatar,
        u.Department,
        u.SubDepartment,
        u.Designation,
        u.Role?.Name,
        u.IsActive,
        u.MustChangePassword,
        u.LastLoginAtUtc,
        u.CreatedAtUtc);

    // ---- Userwise Role Access Management ----

    private static readonly Dictionary<string, string[]> CanonicalDepartmentRoles = new(StringComparer.OrdinalIgnoreCase)
    {
        ["Services - Testing"] = [
            "Testing HOD",
            "Testing Senior Manager",
            "Testing-Manager",
            "Testing-Team Leader",
            "Testing-Team Member",
        ],
        ["Services - Consulting"] = [
            "Consulting-HOD",
            "Consulting-Senior Manager",
            "Consulting-Manager",
            "Consulting-Team Leader",
            "Consulting-Team member",
        ],
        ["Services - Operations"] = [
            "SOC-HOD",
            "SOC-Senior Manager",
            "SOC-Manager",
            "SOC-Team Leader",
            "SOC-Team Member",
        ],
        ["Functional - Project Management"] = [
            "PMO",
            "EngagementManager",
            "PM - Team Member",
        ],
        ["Functional - Sales"] = [
            "Sales Manager",
            "Sales team member",
        ],
        ["Functional - Accounts"] = [
            "Accounts",
        ],
        ["Functional - HR"] = [
            "HR",
        ],
        ["Functional - IT Administration"] = [
            "IT Admin",
        ],
        ["R&D (Research & Development)"] = [
            "R&D - Team member",
        ],
        ["Core"] = [
            "CEO",
            "COO",
            "CTO",
            "Intern",
        ],
    };

    private static string NormalizeDepartment(string? dept)
    {
        if (string.IsNullOrWhiteSpace(dept)) return "Other";
        var raw = dept.Trim();
        if (CanonicalDepartmentRoles.ContainsKey(raw)) return raw;

        var lower = raw.ToLowerInvariant();
        if (lower.Contains("testing")) return "Services - Testing";
        if (lower.Contains("consulting")) return "Services - Consulting";
        if (lower.Contains("operation") || lower.Contains("soc")) return "Services - Operations";
        if (lower.Contains("project management") || lower.Contains("pmo")) return "Functional - Project Management";
        if (lower.Contains("sales")) return "Functional - Sales";
        if (lower.Contains("account")) return "Functional - Accounts";
        if (lower.Contains("hr") || lower.Contains("human resource")) return "Functional - HR";
        if (lower.Contains("it admin") || lower.Contains("information technology") || lower.Contains("administration")) return "Functional - IT Administration";
        if (lower.Contains("r&d") || lower.Contains("research")) return "R&D (Research & Development)";
        if (lower.Contains("core")) return "Core";

        return raw;
    }

    public async Task<PagedResult<UserRoleAccessDto>> GetUserRoleAccessListAsync(
        int page,
        int perPage,
        string? search,
        string? department,
        CancellationToken ct = default)
    {
        var allRoles = await db.Roles.AsNoTracking().ToListAsync(ct);
        var roleByName = allRoles.ToDictionary(r => r.Name, StringComparer.OrdinalIgnoreCase);
        var roleById = allRoles.ToDictionary(r => r.Id);

        var query = db.Employees
            .AsNoTracking()
            .Include(e => e.Department)
            .Include(e => e.Designation)
            .Where(e => e.DeletedAtUtc == null);

        if (!string.IsNullOrWhiteSpace(search))
        {
            var needle = search.Trim().ToLower();
            query = query.Where(e =>
                e.EmployeeCode.ToLower().Contains(needle) ||
                (e.FirstName + " " + e.LastName).ToLower().Contains(needle) ||
                e.WorkEmail.ToLower().Contains(needle) ||
                (e.Department != null && e.Department.Name.ToLower().Contains(needle)) ||
                (e.Designation != null && e.Designation.Name.ToLower().Contains(needle)) ||
                (e.Role != null && e.Role.ToLower().Contains(needle)));
        }

        if (!string.IsNullOrWhiteSpace(department) && !department.Equals("All", StringComparison.OrdinalIgnoreCase))
        {
            var deptNeedle = department.Trim().ToLower();
            query = query.Where(e => e.Department != null && e.Department.Name.ToLower() == deptNeedle);
        }

        var total = await query.CountAsync(ct);

        var items = await query
            .OrderBy(e => e.EmployeeCode)
            .Skip((page - 1) * perPage)
            .Take(perPage)
            .ToListAsync(ct);

        var dtos = items.Select(e => BuildUserRoleAccessDto(e, allRoles, roleByName, roleById)).ToList();

        return new PagedResult<UserRoleAccessDto>(dtos, page, perPage, total);
    }

    public async Task<UserRoleAccessDto?> UpdateUserRoleAccessAsync(Guid employeeId, Guid roleId, CancellationToken ct = default)
    {
        var employee = await db.Employees
            .Include(e => e.Department)
            .Include(e => e.Designation)
            .FirstOrDefaultAsync(e => e.Id == employeeId, ct);

        if (employee is null) return null;

        var allRoles = await db.Roles.ToListAsync(ct);
        var targetRole = allRoles.FirstOrDefault(r => r.Id == roleId);
        if (targetRole is null) throw new NotFoundException("Role not found.");

        var deptName = employee.Department?.Name ?? "Other";
        var normDept = NormalizeDepartment(deptName);
        var isSuperAdmin = OrgRoleMatrix.IsSuperAdmin(employee.EmployeeCode, employee.WorkEmail);

        var allowedNames = CanonicalDepartmentRoles.TryGetValue(normDept, out var names) ? names : [];
        var allowed = allowedNames.Contains(targetRole.Name, StringComparer.OrdinalIgnoreCase)
            || (isSuperAdmin && targetRole.Name == "Admin");

        if (!allowed)
        {
            throw new ConflictException($"Role '{targetRole.DisplayName}' does not belong to department '{deptName}'.");
        }

        if (string.IsNullOrWhiteSpace(employee.OriginalRole))
        {
            employee.OriginalRole = employee.Role;
        }

        employee.Role = targetRole.Name;
        employee.UpdatedAtUtc = DateTime.UtcNow;

        var user = await db.Users.FirstOrDefaultAsync(
            u => u.EmployeeId == employee.EmployeeCode || u.Email.ToLower() == employee.WorkEmail.ToLower(), ct);
        if (user is not null)
        {
            user.RoleId = targetRole.Id;
            user.UpdatedAtUtc = DateTime.UtcNow;
        }
        else
        {
            user = new User
            {
                Id = Guid.NewGuid(),
                Email = employee.WorkEmail.Trim().ToLowerInvariant(),
                Name = $"{employee.FirstName} {employee.LastName}".Trim(),
                EmployeeId = employee.EmployeeCode.Trim(),
                Department = employee.Department?.Name,
                Designation = employee.Designation?.Name,
                RoleId = targetRole.Id,
                IsActive = true,
                MustChangePassword = false,
                CreatedAtUtc = DateTime.UtcNow,
            };
            db.Users.Add(user);
            employee.UserId = user.Id;
        }

        await db.SaveChangesAsync(ct);

        var roleByName = allRoles.ToDictionary(r => r.Name, StringComparer.OrdinalIgnoreCase);
        var roleById = allRoles.ToDictionary(r => r.Id);
        return BuildUserRoleAccessDto(employee, allRoles, roleByName, roleById);
    }

    public async Task<UserRoleAccessDto?> ResetUserRoleAccessAsync(Guid employeeId, CancellationToken ct = default)
    {
        var employee = await db.Employees
            .Include(e => e.Department)
            .Include(e => e.Designation)
            .FirstOrDefaultAsync(e => e.Id == employeeId, ct);

        if (employee is null) return null;

        var allRoles = await db.Roles.ToListAsync(ct);
        var isSuperAdmin = OrgRoleMatrix.IsSuperAdmin(employee.EmployeeCode, employee.WorkEmail);

        var originalRoleName = !string.IsNullOrWhiteSpace(employee.OriginalRole)
            ? employee.OriginalRole
            : (isSuperAdmin ? "Admin" : employee.Role);

        if (string.IsNullOrWhiteSpace(originalRoleName))
            throw new ConflictException("Original role is not defined for this employee.");

        var originalRole = allRoles.FirstOrDefault(r =>
            r.Name.Equals(originalRoleName, StringComparison.OrdinalIgnoreCase) ||
            r.DisplayName.Equals(originalRoleName, StringComparison.OrdinalIgnoreCase));

        if (originalRole is null)
            throw new NotFoundException($"Role '{originalRoleName}' does not exist in role catalog.");

        employee.Role = originalRole.Name;
        employee.UpdatedAtUtc = DateTime.UtcNow;

        var user = await db.Users.FirstOrDefaultAsync(
            u => u.EmployeeId == employee.EmployeeCode || u.Email.ToLower() == employee.WorkEmail.ToLower(), ct);
        if (user is not null)
        {
            user.RoleId = originalRole.Id;
            user.UpdatedAtUtc = DateTime.UtcNow;
        }

        await db.SaveChangesAsync(ct);

        var roleByName = allRoles.ToDictionary(r => r.Name, StringComparer.OrdinalIgnoreCase);
        var roleById = allRoles.ToDictionary(r => r.Id);
        return BuildUserRoleAccessDto(employee, allRoles, roleByName, roleById);
    }

    public async Task<IReadOnlyDictionary<string, IReadOnlyList<RoleDto>>> GetDepartmentRolesAsync(CancellationToken ct = default)
    {
        var allRoles = await db.Roles.AsNoTracking().ToListAsync(ct);
        var result = new Dictionary<string, IReadOnlyList<RoleDto>>(StringComparer.OrdinalIgnoreCase);

        foreach (var (dept, roleNames) in CanonicalDepartmentRoles)
        {
            var dtos = allRoles
                .Where(r => roleNames.Contains(r.Name, StringComparer.OrdinalIgnoreCase))
                .OrderBy(r => Array.IndexOf(roleNames, r.Name))
                .Select(r => MapToRoleDto(r, 0))
                .ToList();
            result[dept] = dtos;
        }

        return result;
    }

    private static UserRoleAccessDto BuildUserRoleAccessDto(
        Employee employee,
        IReadOnlyList<Role> allRoles,
        Dictionary<string, Role> roleByName,
        Dictionary<Guid, Role> roleById)
    {
        var deptName = employee.Department?.Name ?? "Other";
        var normDept = NormalizeDepartment(deptName);
        var isSuperAdmin = OrgRoleMatrix.IsSuperAdmin(employee.EmployeeCode, employee.WorkEmail);

        var originalRoleName = !string.IsNullOrWhiteSpace(employee.OriginalRole)
            ? employee.OriginalRole
            : (!string.IsNullOrWhiteSpace(employee.Role) ? employee.Role : (isSuperAdmin ? "Admin" : "Testing-Team Member"));

        var currentRoleName = !string.IsNullOrWhiteSpace(employee.Role)
            ? employee.Role
            : originalRoleName;

        roleByName.TryGetValue(originalRoleName, out var origRole);
        roleByName.TryGetValue(currentRoleName, out var currRole);

        var allowedNames = CanonicalDepartmentRoles.TryGetValue(normDept, out var names) ? names : [];
        var deptRoleDtos = allRoles
            .Where(r => allowedNames.Contains(r.Name, StringComparer.OrdinalIgnoreCase) || (isSuperAdmin && r.Name == "Admin"))
            .OrderBy(r => Array.IndexOf(allowedNames, r.Name))
            .Select(r => MapToRoleDto(r, 0))
            .ToList();

        var origRoleId = origRole?.Id;
        var currRoleId = currRole?.Id;
        var isSwitched = origRoleId.HasValue && currRoleId.HasValue && origRoleId.Value != currRoleId.Value;

        var fullName = $"{employee.FirstName} {employee.LastName}".Trim();
        var initials = string.Join("", fullName.Split(' ', StringSplitOptions.RemoveEmptyEntries).Take(2).Select(s => s[0])).ToUpperInvariant();

        return new UserRoleAccessDto(
            employee.Id,
            employee.EmployeeCode,
            fullName,
            employee.WorkEmail,
            initials,
            employee.DepartmentId,
            deptName,
            employee.Designation?.Name,
            origRoleId,
            origRole?.Name ?? originalRoleName,
            origRole?.DisplayName ?? originalRoleName,
            currRoleId,
            currRole?.Name ?? currentRoleName,
            currRole?.DisplayName ?? currentRoleName,
            isSwitched,
            isSuperAdmin,
            deptRoleDtos);
    }
}
