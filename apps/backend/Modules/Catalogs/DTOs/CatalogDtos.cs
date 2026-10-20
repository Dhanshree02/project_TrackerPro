namespace PMS.API.Modules.Catalogs.DTOs;

public sealed record CatalogOptionDto(Guid Id, string Code, string Name, string? PhoneCode = null, int? PhoneDigits = null);

public sealed record AddressCityDto(Guid Id, string Code, string Name, string? Line, int SortOrder);

public sealed record CityCatalogOptionDto(Guid Id, string Code, string Name, Guid CountryId);

public sealed record ServiceGroupDto(Guid Id, string Code, string Name, int SortOrder);

public sealed record ServiceDepartmentDto(Guid Id, string Code, string Name, Guid GroupId, string GroupName, int SortOrder);

public sealed record ServiceSubDepartmentDto(Guid Id, string Code, string Name, Guid DepartmentId, string DepartmentName, int SortOrder);

public sealed record ServiceCatalogOptionDto(
    Guid Id,
    string Code,
    string Name,
    Guid SubDepartmentId,
    string SubDepartmentName,
    string? DefaultTools,
    decimal? DefaultUnitPrice,
    int? DefaultDurationDays,
    string? Description,
    int SortOrder);

public sealed record ServiceHierarchyItemDto(
    Guid Id,
    string Code,
    string Name,
    string? DefaultTools,
    decimal? DefaultUnitPrice,
    int? DefaultDurationDays,
    string? Description,
    int SortOrder);

public sealed record ServiceHierarchySubDeptDto(
    Guid Id,
    string Code,
    string Name,
    int SortOrder,
    IReadOnlyList<ServiceHierarchyItemDto> Services);

public sealed record ServiceHierarchyDeptDto(
    Guid Id,
    string Code,
    string Name,
    string GroupCode,
    string GroupName,
    int SortOrder,
    IReadOnlyList<ServiceHierarchySubDeptDto> SubDepartments);

public sealed record ServiceHierarchyGroupDto(
    Guid Id,
    string Code,
    string Name,
    int SortOrder,
    IReadOnlyList<ServiceHierarchyDeptDto> Departments);

public sealed record ProjectMasterRowDto(
    Guid Id,
    Guid GroupId,
    string ContractType,
    Guid DepartmentId,
    string Department,
    Guid SubDepartmentId,
    string SubDepartment,
    string Service,
    string Code,
    string? Tools,
    int? DurationDays,
    decimal? UnitPrice,
    DateTime CreatedAtUtc);

public sealed record CreateProjectMasterRequest(
    string ContractType,
    string Department,
    string Service,
    string Tools,
    int DurationDays,
    decimal UnitPrice,
    string? SubDepartment = null);

public sealed record UpdateProjectMasterRequest(
    string ContractType,
    string Department,
    string Service,
    string Tools,
    int DurationDays,
    decimal UnitPrice,
    string? SubDepartment = null);

public sealed record CreateServiceGroupRequest(string Name);

public sealed record CreateServiceDepartmentRequest(
    string ContractType,
    string Name);

public sealed record CreateServiceOnlyRequest(
    string ContractType,
    string Department,
    string Service,
    string? Tools = null,
    int? DurationDays = null,
    decimal? UnitPrice = null,
    string? SubDepartment = null);
