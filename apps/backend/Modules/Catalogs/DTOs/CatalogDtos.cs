namespace PMS.API.Modules.Catalogs.DTOs;

public sealed record CatalogOptionDto(Guid Id, string Code, string Name, string? PhoneCode = null, int? PhoneDigits = null);

public sealed record AddressCityDto(Guid Id, string Code, string Name, string? Line, int SortOrder);

public sealed record CreateAddressCityRequest(string Name, string? Line);

public sealed record UpsertNamedCatalogRequest(string Name, string? Code);

public sealed record UpsertCityRequest(string Name, string? Code, Guid CountryId);

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

public sealed record CreateServiceGroupRequest(string Name);

public sealed record CreateServiceDepartmentRequest(Guid GroupId, string Name);

public sealed record CreateServiceSubDepartmentRequest(Guid DepartmentId, string Name);

public sealed record CreateServiceCatalogRequest(
    Guid SubDepartmentId,
    string Name,
    string? DefaultTools,
    decimal? DefaultUnitPrice,
    int? DefaultDurationDays);

public sealed record UpdateServiceCatalogRequest(
    string? Name,
    Guid? SubDepartmentId,
    string DefaultTools,
    decimal DefaultUnitPrice,
    int DefaultDurationDays);
