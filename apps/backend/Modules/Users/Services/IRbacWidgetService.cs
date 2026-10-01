using PMS.API.Modules.Users.DTOs;

namespace PMS.API.Modules.Users.Services;

public interface IRbacWidgetService
{
    Task<List<ModuleNodeDto>> GetCatalogTreeAsync(Guid? roleId = null, CancellationToken ct = default);

    Task<List<RoleWidgetPermissionDto>> GetRoleWidgetPermissionsAsync(Guid roleId, CancellationToken ct = default);

    Task<Dictionary<string, (short v, short m)>> GetRoleWidgetMapAsync(Guid roleId, CancellationToken ct = default);

    Task UpdateRoleWidgetPermissionsAsync(
        Guid roleId,
        UpdateRoleWidgetPermissionsRequest request,
        Guid? modifiedById = null,
        CancellationToken ct = default);

    Task ResetRoleToBaselineAsync(
        Guid roleId,
        Guid? modifiedById = null,
        CancellationToken ct = default);
}
