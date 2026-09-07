using PMS.API.Modules.Resources.DTOs;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.Resources.Services;

public interface IEmployeeService
{
    Task<PagedResult<EmployeeListItemDto>> GetEmployeesAsync(
        int page,
        int perPage,
        string? search,
        Guid? departmentId,
        Guid? designationId,
        string? status,
        CancellationToken ct = default);

    Task<EmployeeDetailDto?> GetEmployeeAsync(string idOrCode, CancellationToken ct = default);

    Task<EmployeeDetailDto> CreateEmployeeAsync(CreateEmployeeRequest request, CancellationToken ct = default);

    Task<string> GetNextEmployeeCodeAsync(bool isIntern, CancellationToken ct = default);

    Task<EmployeeDetailDto?> UpdateEmployeeAsync(string idOrCode, UpdateEmployeeRequest request, CancellationToken ct = default);

    byte[] GetBulkSampleExcel();

    Task<EmployeeBulkUploadResult> BulkUploadAsync(Stream stream, CancellationToken ct = default);

    Task<ExitedEmployeeDto?> OffboardEmployeeAsync(string idOrCode, OffboardEmployeeRequest request, CancellationToken ct = default);

    Task<PagedResult<ExitedEmployeeDto>> GetExitedEmployeesAsync(int page, int perPage, string? search, CancellationToken ct = default);

    Task<IReadOnlyList<MetaOptionDto>> GetDepartmentsAsync(CancellationToken ct = default);

    Task<IReadOnlyList<MetaOptionDto>> GetDesignationsAsync(Guid? departmentId, CancellationToken ct = default);

    Task<IReadOnlyList<MetaOptionDto>> GetNationalitiesAsync(CancellationToken ct = default);

    Task<IReadOnlyList<MetaOptionDto>> GetJobRolesAsync(Guid? designationId, CancellationToken ct = default);

    Task<IReadOnlyList<MetaOptionDto>> GetSalaryBandsAsync(CancellationToken ct = default);

    Task<IReadOnlyList<MetaOptionDto>> GetEmailDomainsAsync(CancellationToken ct = default);

    Task<IReadOnlyList<MetaOptionDto>> GetReportingManagersAsync(CancellationToken ct = default);

    Task<IReadOnlyList<MetaOptionDto>> GetBusinessUnitsAsync(CancellationToken ct = default);

    Task<IReadOnlyList<MetaOptionDto>> GetWorkLocationsAsync(CancellationToken ct = default);

    Task<IReadOnlyList<MetaOptionDto>> GetOfficesAsync(Guid? workLocationId = null, CancellationToken ct = default);

    Task<IReadOnlyList<MetaOptionDto>> GetEmployeeStatusesAsync(bool onboardingOnly = false, CancellationToken ct = default);

    Task<MetaOptionDto> CreateDepartmentAsync(string name, CancellationToken ct = default);

    Task<MetaOptionDto> CreateDesignationAsync(string name, Guid departmentId, CancellationToken ct = default);

    Task<MetaOptionDto> CreateJobRoleAsync(string name, Guid designationId, CancellationToken ct = default);

    Task<MetaOptionDto> CreateReportingManagerAsync(string name, string? designation = null, CancellationToken ct = default);

    Task<MetaOptionDto> CreateBusinessUnitAsync(string name, CancellationToken ct = default);

    Task<MetaOptionDto> CreateWorkLocationAsync(string name, CancellationToken ct = default);

    Task<MetaOptionDto> CreateOfficeAsync(string name, Guid? workLocationId = null, CancellationToken ct = default);

    Task<IReadOnlyList<EmployeeLookupDto>> LookupEmployeesAsync(IReadOnlyList<Guid> ids, CancellationToken ct = default);

    Task<EmployeeLookupDto?> GetEmployeeSummaryAsync(string idOrCode, CancellationToken ct = default);
}
