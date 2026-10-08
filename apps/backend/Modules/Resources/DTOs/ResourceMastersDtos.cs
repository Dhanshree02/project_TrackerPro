namespace PMS.API.Modules.Resources.DTOs;

public record ResourceHierarchyDto(
    Guid Id,
    Guid? DepartmentId,
    string DepartmentName,
    string? DepartmentCode,
    Guid? DesignationId,
    string DesignationName,
    string? DesignationCode,
    Guid? OnFloorRoleId,
    string OnFloorRoleName,
    string? OnFloorRoleCode,
    Guid? AssignedRbacRoleId,
    string AssignedRbacRoleName,
    string? AssignedRbacRoleCode,
    bool IsActive,
    DateTime CreatedAtUtc
);

public record CreateResourceHierarchyRequest(
    string DepartmentName,
    string? DepartmentCode,
    string DesignationName,
    string? DesignationCode,
    string? OnFloorRoleName,
    string? OnFloorRoleCode,
    Guid? AssignedRbacRoleId,
    string? AssignedRbacRoleName,
    string? AssignedRbacRoleCode
);

public record UpdateResourceHierarchyRequest(
    string? DepartmentName,
    string? DepartmentCode,
    string? DesignationName,
    string? DesignationCode,
    string? OnFloorRoleName,
    string? OnFloorRoleCode,
    Guid? AssignedRbacRoleId,
    string? AssignedRbacRoleName,
    string? AssignedRbacRoleCode,
    bool? IsActive
);

public record ResourceEmailDomainDto(
    Guid Id,
    string DomainName,
    string DisplayName,
    string Code,
    bool IsActive,
    int SortOrder,
    DateTime CreatedAtUtc
);

public record CreateEmailDomainRequest(
    string DomainName,
    string? DisplayName,
    string? Code
);

public record UpdateEmailDomainRequest(
    string? DomainName,
    string? DisplayName,
    string? Code,
    bool? IsActive
);

public record ResourceCityDto(
    Guid Id,
    string Name,
    string Code,
    string? Line,
    string? SubLabel,
    string? StationName,
    bool IsActive,
    DateTime CreatedAtUtc
);

public record CreateCityRequest(
    string Name,
    string? Code,
    string? Line,
    string? StationName
);

public record UpdateCityRequest(
    string? Name,
    string? Code,
    string? Line,
    string? StationName,
    bool? IsActive
);

public record SimpleMasterDto(
    Guid Id,
    string Name,
    string Code,
    string? Description,
    bool IsActive,
    DateTime CreatedAtUtc
);

public record CreateSimpleMasterRequest(
    string Name,
    string? Code,
    string? Description
);

public record UpdateSimpleMasterRequest(
    string? Name,
    string? Code,
    string? Description,
    bool? IsActive
);

public record RbacRoleOptionDto(
    Guid Id,
    string Name,
    string DisplayName,
    string? Description,
    bool IsActive
);
