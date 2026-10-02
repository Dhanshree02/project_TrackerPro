using PMS.API.Modules.Users.DTOs;

namespace PMS.API.Modules.Users.Services;

public interface IRbacWidgetService
{
    Task<List<ModuleCatalogDto>> GetCatalogTreeAsync(Guid? roleId = null, CancellationToken ct = default);
    Task<Dictionary<string, (short CanView, short CanManage)>> GetEffectiveUserPermissionsAsync(string roleName, CancellationToken ct = default);
    Task<List<RoleWidgetPermissionDto>> GetRolePermissionsAsync(Guid roleId, CancellationToken ct = default);
    Task UpdateRolePermissionsAsync(Guid roleId, UpdateRoleWidgetPermissionsDto dto, Guid? updatedBy, CancellationToken ct = default);
    Task ResetRoleBaselineAsync(Guid roleId, Guid? updatedBy, CancellationToken ct = default);
}
