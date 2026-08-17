using System.Security.Claims;

namespace PMS.API.Infrastructure.Authorization;

/// <summary>
/// Abstraction over the authenticated user for the current HTTP request.
/// Implemented in the API layer; consumed by application services so business
/// logic never touches HttpContext directly (testable).
/// </summary>
public interface ICurrentUserService
{
    Guid? UserId { get; }

    string? Email { get; }

    string? Name { get; }

    string? Role { get; }

    IReadOnlyList<string> Permissions { get; }

    bool HasPermission(string permission);

    ClaimsPrincipal? Principal { get; }
}
