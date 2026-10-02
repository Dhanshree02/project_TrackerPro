namespace PMS.API.Modules.Users.DTOs;

public record WidgetCatalogDto(
    Guid Id,
    string Code,
    string Name,
    string WidgetKey,
    string WidgetType,
    bool HasManageAction,
    int SortOrder,
    short CanView,
    short CanManage
);

public record SubmoduleCatalogDto(
    Guid Id,
    string Code,
    string Name,
    string? RoutePrefix,
    int SortOrder,
    List<WidgetCatalogDto> Widgets,
    List<SubmoduleCatalogDto> ChildSubmodules
);

public record ModuleCatalogDto(
    Guid Id,
    string Code,
    string Name,
    string? Icon,
    int SortOrder,
    List<SubmoduleCatalogDto> Submodules,
    List<WidgetCatalogDto> DirectWidgets
);

public record UpdateRoleWidgetPermissionItemDto(
    Guid WidgetId,
    short CanView,
    short CanManage
);

public record UpdateRoleWidgetPermissionsDto(
    List<UpdateRoleWidgetPermissionItemDto> Permissions
);

public record RoleWidgetPermissionDto(
    Guid RoleId,
    string RoleName,
    Guid WidgetId,
    string WidgetKey,
    string WidgetName,
    short CanView,
    short CanManage
);
