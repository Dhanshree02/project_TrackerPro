namespace PMS.API.Modules.Users.DTOs;

public sealed record WidgetNodeDto(
    Guid Id,
    string Code,
    string Name,
    string WidgetKey,
    string WidgetType,
    bool HasManageAction,
    int SortOrder,
    short CanView = 0,
    short CanManage = 0);

public sealed record SubmoduleNodeDto(
    Guid Id,
    string Code,
    string Name,
    string? RoutePrefix,
    int SortOrder,
    List<SubmoduleNodeDto> ChildSubmodules,
    List<WidgetNodeDto> Widgets);

public sealed record ModuleNodeDto(
    Guid Id,
    string Code,
    string Name,
    string? Icon,
    int SortOrder,
    List<SubmoduleNodeDto> Submodules,
    List<WidgetNodeDto> DirectWidgets);

public sealed record RoleWidgetPermissionDto(
    Guid WidgetId,
    string WidgetKey,
    short CanView,
    short CanManage);

public sealed record RoleWidgetPermissionItem(
    Guid WidgetId,
    short CanView,
    short CanManage);

public sealed record UpdateRoleWidgetPermissionsRequest(
    List<RoleWidgetPermissionItem> Permissions);
