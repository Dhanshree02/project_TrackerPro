namespace PMS.API.Infrastructure.Authentication;

/// <summary>
/// Custom JWT claim type names, shared between token issuance (JwtTokenService),
/// guards (RequirePermissionAttribute) and claim resolution (CurrentUserService).
/// </summary>
public static class AuthClaimTypes
{
    public const string Permission = "permission";
}
