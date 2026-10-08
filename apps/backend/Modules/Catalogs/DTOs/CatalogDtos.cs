namespace PMS.API.Modules.Catalogs.DTOs;

public sealed record CatalogOptionDto(Guid Id, string Code, string Name, string? PhoneCode = null, int? PhoneDigits = null);

public sealed record CityCatalogOptionDto(Guid Id, string Code, string Name, Guid CountryId, string? CountryName = null);

public sealed record CreateCountryRequest(string Name, string? Code = null, string? PhoneCode = null, int? PhoneDigits = null);
public sealed record UpdateCountryRequest(string? Name = null, string? Code = null, string? PhoneCode = null, int? PhoneDigits = null);

public sealed record CreateCustomerCityRequest(string Name, Guid CountryId, string? Code = null);
public sealed record UpdateCustomerCityRequest(string? Name = null, Guid? CountryId = null, string? Code = null);

public sealed record CreateCatalogItemRequest(string Name, string? Code = null);
public sealed record UpdateCatalogItemRequest(string? Name = null, string? Code = null);

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

public sealed record CreateServiceDepartmentRequest(
    string Name,
    string? Group = null,
    Guid? GroupId = null,
    string? Code = null);

public sealed record CreateServiceSubDepartmentRequest(
    string Name,
    string? DepartmentName = null,
    Guid? DepartmentId = null,
    string? Code = null);

public sealed record CreateServiceCatalogRequest(
    string Name,
    string? DepartmentName = null,
    string? SubDepartmentName = null,
    Guid? SubDepartmentId = null,
    string? Code = null,
    string? DefaultTools = null,
    decimal? DefaultUnitPrice = null,
    int? DefaultDurationDays = null,
    string? Description = null);

public sealed record CreateServiceGroupRequest(
    string Name,
    string? Code = null);

public sealed record CreateProjectMasterRequest(
    string ContractType,
    string Department,
    string? SubDepartment,
    string Service,
    string Tools,
    string Duration,
    decimal UnitPrice);

public sealed record UpdateProjectMasterRequest(
    string? ContractType,
    string? Department,
    string? SubDepartment,
    string? Service,
    string? Tools,
    string? Duration,
    decimal? UnitPrice);

public sealed record ProjectMasterDto(
    Guid Id,
    string ContractType,
    string Group,
    string Department,
    string? SubDepartment,
    string Service,
    string Tools,
    string Duration,
    decimal UnitPrice,
    DateTime CreatedAtUtc);

