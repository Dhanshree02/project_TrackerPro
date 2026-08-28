using Microsoft.AspNetCore.Mvc;
using PMS.API.Infrastructure.Storage;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.Resources.Controllers;

public sealed class UploadMultipleDocumentsRequest
{
    public string Category { get; set; } = string.Empty;
    public List<IFormFile> Files { get; set; } = [];
}

public sealed class UploadSingleDocumentRequest
{
    public string Category { get; set; } = string.Empty;
    public IFormFile File { get; set; } = null!;
}

[ApiController]
[Route("api/v1/storage")]
public class StorageController(IFileStorageService storage) : ControllerBase
{
    [HttpPost("employees/{employeeCode}/documents")]
    [Consumes("multipart/form-data")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<StoredFileInfo>>>> UploadEmployeeDocuments(
        string employeeCode,
        [FromForm] UploadMultipleDocumentsRequest request,
        CancellationToken ct)
    {
        var files = request?.Files;
        var category = request?.Category ?? string.Empty;

        if (files == null || files.Count == 0)
        {
            return BadRequest(ApiResponse<IReadOnlyList<StoredFileInfo>>.Fail("NO_FILES", "No files were uploaded."));
        }

        var results = await storage.SaveEmployeeDocumentsAsync(employeeCode, category, files, ct);
        return Ok(ApiResponse<IReadOnlyList<StoredFileInfo>>.Ok(results));
    }

    [HttpGet("employees/{employeeCode}/documents")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<StoredFileInfo>>>> GetEmployeeDocuments(
        string employeeCode,
        [FromQuery] string? category,
        CancellationToken ct)
    {
        var docs = await storage.GetEmployeeDocumentsAsync(employeeCode, category, ct);
        return Ok(ApiResponse<IReadOnlyList<StoredFileInfo>>.Ok(docs));
    }

    [HttpPost("customers/{clientCode}/documents")]
    [Consumes("multipart/form-data")]
    public async Task<ActionResult<ApiResponse<StoredFileInfo>>> UploadCustomerDocument(
        string clientCode,
        [FromForm] UploadSingleDocumentRequest request,
        CancellationToken ct)
    {
        var file = request?.File;
        var category = request?.Category ?? string.Empty;

        if (file == null || file.Length == 0)
        {
            return BadRequest(ApiResponse<StoredFileInfo>.Fail("NO_FILES", "No file was uploaded."));
        }

        var result = await storage.SaveCustomerDocumentAsync(clientCode, category, file, ct);
        return Ok(ApiResponse<StoredFileInfo>.Ok(result));
    }

    [HttpPost("projects/{projectCode}/documents")]
    [Consumes("multipart/form-data")]
    public async Task<ActionResult<ApiResponse<StoredFileInfo>>> UploadProjectDocument(
        string projectCode,
        [FromForm] UploadSingleDocumentRequest request,
        CancellationToken ct)
    {
        var file = request?.File;
        var category = request?.Category ?? string.Empty;

        if (file == null || file.Length == 0)
        {
            return BadRequest(ApiResponse<StoredFileInfo>.Fail("NO_FILES", "No file was uploaded."));
        }

        var result = await storage.SaveProjectDocumentAsync(projectCode, category, file, ct);
        return Ok(ApiResponse<StoredFileInfo>.Ok(result));
    }
}
