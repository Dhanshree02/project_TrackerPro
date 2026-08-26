using Microsoft.AspNetCore.Mvc;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Modules.Resources.DTOs;
using PMS.API.Modules.Resources.Services;
using PMS.API.Shared.Common.Wrappers;
using PMS.API.Shared.Constants;

namespace PMS.API.Modules.Resources.Controllers;

[ApiController]
[Route("api/v1/employees")]
public class EmployeesController(IEmployeeService employees) : ControllerBase
{
    [HttpGet]
    [RequirePermission(Permissions.ResourcesRead)]
    public async Task<ActionResult<ApiResponse<PagedResult<EmployeeListItemDto>>>> List(
        [FromQuery] int page = 1,
        [FromQuery] int perPage = 20,
        [FromQuery] string? search = null,
        [FromQuery] Guid? departmentId = null,
        [FromQuery] Guid? designationId = null,
        [FromQuery] string? status = null,
        CancellationToken ct = default)
    {
        page = Math.Max(1, page);
        perPage = Math.Clamp(perPage, 1, 100);
        var result = await employees.GetEmployeesAsync(page, perPage, search, departmentId, designationId, status, ct);
        return Ok(ApiResponse<PagedResult<EmployeeListItemDto>>.Ok(result, new ApiMeta
        {
            Total = result.Total,
            Page = result.Page,
            PerPage = result.PerPage,
            TotalPages = result.TotalPages,
        }));
    }

    [HttpGet("exited")]
    [RequirePermission(Permissions.ResourcesRead)]
    public async Task<ActionResult<ApiResponse<PagedResult<ExitedEmployeeDto>>>> Exited(
        [FromQuery] int page = 1,
        [FromQuery] int perPage = 20,
        [FromQuery] string? search = null,
        CancellationToken ct = default)
    {
        page = Math.Max(1, page);
        perPage = Math.Clamp(perPage, 1, 100);
        var result = await employees.GetExitedEmployeesAsync(page, perPage, search, ct);
        return Ok(ApiResponse<PagedResult<ExitedEmployeeDto>>.Ok(result, new ApiMeta
        {
            Total = result.Total,
            Page = result.Page,
            PerPage = result.PerPage,
            TotalPages = result.TotalPages,
        }));
    }

    [HttpGet("lookup")]
    [RequirePermission(Permissions.ResourcesRead)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<EmployeeLookupDto>>>> Lookup(
        [FromQuery] Guid[] ids,
        CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<EmployeeLookupDto>>.Ok(
            await employees.LookupEmployeesAsync(ids, ct)));
    }

    [HttpGet("meta/departments")]
    [RequirePermission(Permissions.ResourcesRead)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<MetaOptionDto>>>> Departments(CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<MetaOptionDto>>.Ok(await employees.GetDepartmentsAsync(ct)));
    }

    [HttpPost("meta/departments")]
    [RequirePermission(Permissions.ResourcesManage)]
    public async Task<ActionResult<ApiResponse<MetaOptionDto>>> CreateDepartment(
        CreateCatalogItemRequest request,
        CancellationToken ct)
    {
        var created = await employees.CreateDepartmentAsync(request.Name, ct);
        return Ok(ApiResponse<MetaOptionDto>.Ok(created));
    }

    [HttpGet("meta/designations")]
    [RequirePermission(Permissions.ResourcesRead)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<MetaOptionDto>>>> Designations(
        [FromQuery] Guid? departmentId,
        CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<MetaOptionDto>>.Ok(
            await employees.GetDesignationsAsync(departmentId, ct)));
    }

    [HttpPost("meta/designations")]
    [RequirePermission(Permissions.ResourcesManage)]
    public async Task<ActionResult<ApiResponse<MetaOptionDto>>> CreateDesignation(
        CreateCatalogItemRequest request,
        CancellationToken ct)
    {
        if (request.ParentId is not Guid departmentId)
            return BadRequest(ApiResponse<MetaOptionDto>.Fail("VALIDATION_ERROR", "Department is required."));
        var created = await employees.CreateDesignationAsync(request.Name, departmentId, ct);
        return Ok(ApiResponse<MetaOptionDto>.Ok(created));
    }

    [HttpGet("meta/nationalities")]
    [RequirePermission(Permissions.ResourcesRead)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<MetaOptionDto>>>> Nationalities(CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<MetaOptionDto>>.Ok(await employees.GetNationalitiesAsync(ct)));
    }

    [HttpGet("meta/roles")]
    [RequirePermission(Permissions.ResourcesRead)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<MetaOptionDto>>>> Roles(
        [FromQuery] Guid? designationId,
        CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<MetaOptionDto>>.Ok(
            await employees.GetJobRolesAsync(designationId, ct)));
    }

    [HttpPost("meta/roles")]
    [RequirePermission(Permissions.ResourcesManage)]
    public async Task<ActionResult<ApiResponse<MetaOptionDto>>> CreateRole(
        CreateCatalogItemRequest request,
        CancellationToken ct)
    {
        if (request.ParentId is not Guid designationId)
            return BadRequest(ApiResponse<MetaOptionDto>.Fail("VALIDATION_ERROR", "Designation is required."));
        var created = await employees.CreateJobRoleAsync(request.Name, designationId, ct);
        return Ok(ApiResponse<MetaOptionDto>.Ok(created));
    }

    [HttpGet("meta/salary-bands")]
    [RequirePermission(Permissions.ResourcesRead)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<MetaOptionDto>>>> SalaryBands(CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<MetaOptionDto>>.Ok(await employees.GetSalaryBandsAsync(ct)));
    }

    [HttpGet("meta/email-domains")]
    [RequirePermission(Permissions.ResourcesRead)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<MetaOptionDto>>>> EmailDomains(CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<MetaOptionDto>>.Ok(await employees.GetEmailDomainsAsync(ct)));
    }

    [HttpGet("meta/reporting-managers")]
    [RequirePermission(Permissions.ResourcesRead)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<MetaOptionDto>>>> ReportingManagers(CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<MetaOptionDto>>.Ok(await employees.GetReportingManagersAsync(ct)));
    }

    [HttpPost("meta/reporting-managers")]
    [RequirePermission(Permissions.ResourcesManage)]
    public async Task<ActionResult<ApiResponse<MetaOptionDto>>> CreateReportingManager(
        CreateCatalogItemRequest request,
        CancellationToken ct)
    {
        var created = await employees.CreateReportingManagerAsync(request.Name, null, ct);
        return Ok(ApiResponse<MetaOptionDto>.Ok(created));
    }

    [HttpGet("meta/business-units")]
    [RequirePermission(Permissions.ResourcesRead)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<MetaOptionDto>>>> BusinessUnits(CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<MetaOptionDto>>.Ok(await employees.GetBusinessUnitsAsync(ct)));
    }

    [HttpPost("meta/business-units")]
    [RequirePermission(Permissions.ResourcesManage)]
    public async Task<ActionResult<ApiResponse<MetaOptionDto>>> CreateBusinessUnit(
        CreateCatalogItemRequest request,
        CancellationToken ct)
    {
        var created = await employees.CreateBusinessUnitAsync(request.Name, ct);
        return Ok(ApiResponse<MetaOptionDto>.Ok(created));
    }

    [HttpGet("meta/work-locations")]
    [RequirePermission(Permissions.ResourcesRead)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<MetaOptionDto>>>> WorkLocations(CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<MetaOptionDto>>.Ok(await employees.GetWorkLocationsAsync(ct)));
    }

    [HttpPost("meta/work-locations")]
    [RequirePermission(Permissions.ResourcesManage)]
    public async Task<ActionResult<ApiResponse<MetaOptionDto>>> CreateWorkLocation(
        CreateCatalogItemRequest request,
        CancellationToken ct)
    {
        var created = await employees.CreateWorkLocationAsync(request.Name, ct);
        return Ok(ApiResponse<MetaOptionDto>.Ok(created));
    }

    [HttpGet("meta/offices")]
    [RequirePermission(Permissions.ResourcesRead)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<MetaOptionDto>>>> Offices(
        [FromQuery] Guid? workLocationId,
        CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<MetaOptionDto>>.Ok(await employees.GetOfficesAsync(workLocationId, ct)));
    }

    [HttpPost("meta/offices")]
    [RequirePermission(Permissions.ResourcesManage)]
    public async Task<ActionResult<ApiResponse<MetaOptionDto>>> CreateOffice(
        CreateCatalogItemRequest request,
        CancellationToken ct)
    {
        var created = await employees.CreateOfficeAsync(request.Name, request.ParentId, ct);
        return Ok(ApiResponse<MetaOptionDto>.Ok(created));
    }

    [HttpGet("bulk/sample")]
    [RequirePermission(Permissions.ResourcesManage)]
    public IActionResult BulkSample()
    {
        var bytes = employees.GetBulkSampleExcel();
        return File(
            bytes,
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            "employee-bulk-upload-sample.xlsx");
    }

    [HttpPost("bulk")]
    [RequirePermission(Permissions.ResourcesManage)]
    [Consumes("multipart/form-data")]
    [RequestSizeLimit(5 * 1024 * 1024)]
    public async Task<ActionResult<ApiResponse<EmployeeBulkUploadResult>>> BulkUpload(
        [FromForm] IFormFile file,
        CancellationToken ct)
    {
        if (file is null || file.Length == 0)
            return BadRequest(ApiResponse<EmployeeBulkUploadResult>.Fail(
                "VALIDATION_ERROR", "Please upload an Excel file (.xlsx)."));

        var ext = Path.GetExtension(file.FileName);
        if (!string.Equals(ext, ".xlsx", StringComparison.OrdinalIgnoreCase))
            return BadRequest(ApiResponse<EmployeeBulkUploadResult>.Fail(
                "VALIDATION_ERROR", "Only Excel (.xlsx) files are allowed."));

        if (file.Length > EmployeeBulkWorkbook.MaxBytes)
            return BadRequest(ApiResponse<EmployeeBulkUploadResult>.Fail(
                "VALIDATION_ERROR", "The Excel file must be 5 MB or smaller."));

        await using var stream = file.OpenReadStream();
        var result = await employees.BulkUploadAsync(stream, ct);
        return Ok(ApiResponse<EmployeeBulkUploadResult>.Ok(result));
    }

    [HttpPost]
    [RequirePermission(Permissions.ResourcesManage)]
    public async Task<ActionResult<ApiResponse<EmployeeDetailDto>>> Create(CreateEmployeeRequest request, CancellationToken ct)
    {
        var employee = await employees.CreateEmployeeAsync(request, ct);
        return CreatedAtAction(nameof(Get), new { idOrCode = employee.Id }, ApiResponse<EmployeeDetailDto>.Ok(employee));
    }

    [HttpGet("{idOrCode}")]
    [RequirePermission(Permissions.ResourcesRead)]
    public async Task<ActionResult<ApiResponse<EmployeeDetailDto>>> Get(string idOrCode, CancellationToken ct)
    {
        var employee = await employees.GetEmployeeAsync(idOrCode, ct);
        return employee is null
            ? NotFound(ApiResponse<EmployeeDetailDto>.Fail("NOT_FOUND", "Employee not found."))
            : Ok(ApiResponse<EmployeeDetailDto>.Ok(employee));
    }

    [HttpPut("{idOrCode}")]
    [RequirePermission(Permissions.ResourcesManage)]
    public async Task<ActionResult<ApiResponse<EmployeeDetailDto>>> Update(string idOrCode, UpdateEmployeeRequest request, CancellationToken ct)
    {
        var employee = await employees.UpdateEmployeeAsync(idOrCode, request, ct);
        return employee is null
            ? NotFound(ApiResponse<EmployeeDetailDto>.Fail("NOT_FOUND", "Employee not found."))
            : Ok(ApiResponse<EmployeeDetailDto>.Ok(employee));
    }

    [HttpPost("{idOrCode}/offboard")]
    [RequirePermission(Permissions.ResourcesManage)]
    public async Task<ActionResult<ApiResponse<ExitedEmployeeDto>>> Offboard(string idOrCode, OffboardEmployeeRequest request, CancellationToken ct)
    {
        var exited = await employees.OffboardEmployeeAsync(idOrCode, request, ct);
        return exited is null
            ? NotFound(ApiResponse<ExitedEmployeeDto>.Fail("NOT_FOUND", "Employee not found."))
            : Ok(ApiResponse<ExitedEmployeeDto>.Ok(exited));
    }

    [HttpGet("{idOrCode}/summary")]
    [RequirePermission(Permissions.ResourcesRead)]
    public async Task<ActionResult<ApiResponse<EmployeeLookupDto>>> Summary(string idOrCode, CancellationToken ct)
    {
        var summary = await employees.GetEmployeeSummaryAsync(idOrCode, ct);
        return summary is null
            ? NotFound(ApiResponse<EmployeeLookupDto>.Fail("NOT_FOUND", "Employee not found."))
            : Ok(ApiResponse<EmployeeLookupDto>.Ok(summary));
    }
}

