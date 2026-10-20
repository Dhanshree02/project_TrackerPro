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
}
