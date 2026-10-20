namespace PMS.API.Modules.Catalogs.DTOs;

public sealed record NamedMasterDto(Guid Id, string Code, string Name);

public sealed record UpsertNamedMasterRequest(string Name);

public sealed record UpsertAddressCityRequest(string Name, string? Line);

public sealed record RbacRoleOptionDto(Guid Id, string Name, string DisplayName);

public sealed record HierarchyDesignationOptionDto(
    Guid Id,
    string Name,
    Guid? DepartmentId,
    string Department,
    string? SubDepartment);

public sealed record DepartmentHierarchyRowDto(
    Guid Id,
    Guid? DepartmentId,
    string Department,
    Guid DesignationId,
    string Designation,
    string? SubDepartment,
    Guid? OnFloorRoleId,
    string? OnFloorRole,
    Guid? RbacRoleId,
    string? RbacRoleName,
    string? RbacRoleDisplayName);

public sealed record UpsertDepartmentHierarchyRequest(
    string Department,
    string Designation,
    string SubDepartment,
    string OnFloorRole,
    Guid RbacRoleId);

public sealed record DepartmentHierarchyBundleDto(
    IReadOnlyList<DepartmentHierarchyRowDto> Rows,
    IReadOnlyList<NamedMasterDto> Departments,
    IReadOnlyList<HierarchyDesignationOptionDto> Designations,
    IReadOnlyList<NamedMasterDto> OnFloorRoles,
    IReadOnlyList<RbacRoleOptionDto> RbacRoles);

public sealed record ResourceMastersSnapshotDto(
    DepartmentHierarchyBundleDto Hierarchy,
    IReadOnlyList<NamedMasterDto> EmailDomains,
    IReadOnlyList<NamedMasterDto> BusinessUnits,
    IReadOnlyList<NamedMasterDto> WorkLocations,
    IReadOnlyList<NamedMasterDto> GraduationDegrees,
    IReadOnlyList<NamedMasterDto> PostGraduationDegrees,
    IReadOnlyList<NamedMasterDto> Certifications,
    IReadOnlyList<AddressCityDto> AddressCities);
