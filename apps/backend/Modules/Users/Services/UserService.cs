using Microsoft.EntityFrameworkCore;
using PMS.API.Shared.Constants;
using PMS.API.Shared.Exceptions;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Modules.Users.Services;
using PMS.API.Modules.Users.DTOs;
using PMS.API.Shared.Common.Wrappers;
using PMS.API.Modules.Users.Models;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Shared.Validation;
using PMS.API.Infrastructure.Authentication;

namespace PMS.API.Modules.Users.Services;

public sealed class UserService(AppDbContext db, IPasswordHasher hasher, ICurrentUserService currentUser) : IUserService
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

        // Last-admin guard: never let the users:manage capability drop to zero
        // (deactivating or demoting the only active user who holds it would lock
        // the whole company out with no recovery path).
        var managesUsers = user.Role != null && user.Role.Permissions.Contains(Permissions.UsersManage);
        var losesCapability =
            (request.IsActive == false && managesUsers) ||
            (targetRole is not null && managesUsers && !targetRole.Permissions.Contains(Permissions.UsersManage));
        if (losesCapability && await IsLastUserManagerAsync(user.Id, ct))
            throw new ForbiddenException("Cannot remove the last user who can manage users.");

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
                r.Permissions,
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

        var permissions = new List<string>();
        if (request.CloneFromRoleId is { } sourceId)
        {
            var source = await db.Roles.FirstOrDefaultAsync(r => r.Id == sourceId, ct)
                ?? throw new NotFoundException("Source role not found.");
            permissions = [.. source.Permissions];
        }

        var role = new Role
        {
            Name = key,
            DisplayName = request.DisplayName?.Trim() ?? key,
            Description = request.Description,
            Permissions = permissions,
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
            Permissions = [.. source.Permissions],
            IsSystemRole = false,
            IsActive = true,
        };

        db.Roles.Add(role);
        await db.SaveChangesAsync(ct);
        return MapToRoleDto(role, 0);
    }

    public async Task<RoleDto?> UpdateRolePermissionsAsync(
        Guid id,
        UpdateRolePermissionsRequest request,
        CancellationToken ct = default)
    {
        var role = await db.Roles.FirstOrDefaultAsync(r => r.Id == id, ct);
        if (role is null) return null;

        var previous = role.Permissions;
        var next = (request.Permissions ?? []).Distinct().OrderBy(p => p).ToList();

        // Last-manager guard — never let the users:manage capability drop to zero
        // while active users still depend on this role; that would lock the
        // company out of user administration with no recovery path.
        var hadManage = previous.Contains(Permissions.UsersManage);
        var willHaveManage = next.Contains(Permissions.UsersManage);
        if (hadManage && !willHaveManage &&
            await db.Users.AnyAsync(u => u.RoleId == role.Id && u.IsActive, ct))
        {
            // Materialize first — Permissions is a JSONB column whose array search
            // does not translate to SQL; filter in memory (the table is small).
            var others = await db.Roles.Where(r => r.Id != role.Id).ToListAsync(ct);
            if (!others.Any(r => r.Permissions.Contains(Permissions.UsersManage)))
                throw new ForbiddenException("Cannot remove users:manage — this is the last role that can manage users.");
        }

        role.Permissions = next;
        await db.SaveChangesAsync(ct);

        // Audit every grant/revoke of a catalogue permission.
        var granted = next.Except(previous).ToHashSet();
        var revoked = previous.Except(next).ToHashSet();
        await RecordPermissionAuditsAsync(role, granted, revoked, ct);

        return new RoleDto(
            role.Id,
            role.Name,
            role.DisplayName,
            role.Permissions,
            role.Description,
            role.IsSystemRole,
            role.IsActive,
            await db.Users.CountAsync(u => u.RoleId == role.Id, ct));
    }

    public async Task<RoleDto?> ResetRolePermissionsAsync(Guid id, CancellationToken ct = default)
    {
        var role = await db.Roles.FirstOrDefaultAsync(r => r.Id == id, ct);
        if (role is null) return null;

        if (!RoleBaselines.HasBaseline(role.Name))
            throw new ForbiddenException("This role has no baseline to reset to.");

        var previous = role.Permissions;
        List<string> next = [.. RoleBaselines.For(role.Name)];
        role.Permissions = next;
        await db.SaveChangesAsync(ct);

        var granted = next.Except(previous).ToHashSet();
        var revoked = previous.Except(next).ToHashSet();
        await RecordPermissionAuditsAsync(role, granted, revoked, ct);

        return new RoleDto(
            role.Id,
            role.Name,
            role.DisplayName,
            role.Permissions,
            role.Description,
            role.IsSystemRole,
            role.IsActive,
            await db.Users.CountAsync(u => u.RoleId == role.Id, ct));
    }

    // ---------- Audit log ----------

    public async Task<PagedResult<PermissionAuditDto>> GetPermissionAuditsAsync(
        int page,
        int perPage,
        Guid? roleId = null,
        CancellationToken ct = default)
    {
        var query = db.RolePermissionAudits.AsQueryable();
        if (roleId is { } id)
            query = query.Where(a => a.RoleId == id);

        var total = await query.CountAsync(ct);
        var items = await query
            .OrderByDescending(a => a.CreatedAtUtc)
            .Skip((page - 1) * perPage)
            .Take(perPage)
            .ToListAsync(ct);

        return new PagedResult<PermissionAuditDto>(
            items.Select(a => new PermissionAuditDto(
                a.Id,
                a.RoleId,
                a.RoleName,
                a.ModuleLabel,
                a.SubmoduleLabel,
                a.PermissionKey,
                a.ActionLabel,
                a.ChangeType,
                a.PreviousValue,
                a.NewValue,
                a.ChangedByName,
                a.CreatedAtUtc)).ToList(),
            page,
            perPage,
            total);
    }

    // ---------- internals ----------

    private async Task RecordPermissionAuditsAsync(
        Role role,
        HashSet<string> granted,
        HashSet<string> revoked,
        CancellationToken ct)
    {
        var actorName = currentUser.Name;
        var actorId = currentUser.UserId;
        var now = DateTime.UtcNow;

        foreach (var key in granted)
        {
            var desc = PermissionCatalog.DescribeKey(key);
            if (desc is null) continue; // unknown/custom keys are preserved but not audited with labels

            db.RolePermissionAudits.Add(new RolePermissionAudit
            {
                RoleId = role.Id,
                RoleName = role.DisplayName,
                ModuleKey = PermissionModuleKey(key),
                ModuleLabel = desc.Value.Module,
                SubmoduleKey = key.Split('.').Length >= 3 ? key.Split('.')[1] : null,
                SubmoduleLabel = desc.Value.Submodule,
                PermissionKey = key,
                ActionLabel = desc.Value.Action,
                ChangeType = "granted",
                PreviousValue = "Denied",
                NewValue = "Allowed",
                ChangedById = actorId,
                ChangedByName = actorName,
                CreatedAtUtc = now,
            });
        }

        foreach (var key in revoked)
        {
            var desc = PermissionCatalog.DescribeKey(key);
            if (desc is null) continue;

            db.RolePermissionAudits.Add(new RolePermissionAudit
            {
                RoleId = role.Id,
                RoleName = role.DisplayName,
                ModuleKey = PermissionModuleKey(key),
                ModuleLabel = desc.Value.Module,
                SubmoduleKey = key.Split('.').Length >= 3 ? key.Split('.')[1] : null,
                SubmoduleLabel = desc.Value.Submodule,
                PermissionKey = key,
                ActionLabel = desc.Value.Action,
                ChangeType = "revoked",
                PreviousValue = "Allowed",
                NewValue = "Denied",
                ChangedById = actorId,
                ChangedByName = actorName,
                CreatedAtUtc = now,
            });
        }

        if (granted.Count + revoked.Count > 0)
            await db.SaveChangesAsync(ct);
    }

    private static string PermissionModuleKey(string key) => key.Split(':')[0].Split('.')[0];

    /// <summary>True when this user is the only active user whose role holds the users:manage permission.</summary>
    private async Task<bool> IsLastUserManagerAsync(Guid id, CancellationToken ct)
    {
        // Materialize first — Permissions is a JSONB column whose array search does
        // not translate to SQL; filter in memory (the table is small).
        var others = await db.Users
            .Include(u => u.Role)
            .Where(u => u.Id != id && u.IsActive)
            .ToListAsync(ct);

        return !others.Any(u =>
            u.Role != null && u.Role.Permissions.Contains(Permissions.UsersManage));
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
        role.Permissions,
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
}
