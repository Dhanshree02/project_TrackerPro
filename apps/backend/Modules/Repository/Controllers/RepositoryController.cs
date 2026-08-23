using Microsoft.AspNetCore.Mvc;
using PMS.API.Infrastructure.Storage;
using PMS.API.Modules.Repository.DTOs;
using PMS.API.Modules.Repository.Services;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.Repository.Controllers;

[ApiController]
[Route("api/v1/repository")]
public class RepositoryController(
    IRepositoryService repositoryService,
    IFileStorageService storageService,
    ILogger<RepositoryController> logger) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<ApiResponse<PagedResult<RepositoryItemDto>>>> GetDocuments(
        [FromQuery] int page = 1,
        [FromQuery] int perPage = 10,
        [FromQuery] string? category = null,
        [FromQuery] string? search = null,
        CancellationToken ct = default)
    {
        page = Math.Max(1, page);
        perPage = Math.Clamp(perPage, 1, 100);

        var result = await repositoryService.GetDocumentsAsync(page, perPage, category, search, ct);

        return Ok(ApiResponse<PagedResult<RepositoryItemDto>>.Ok(result, new ApiMeta
        {
            Total = result.Total,
            Page = result.Page,
            PerPage = result.PerPage,
            TotalPages = result.TotalPages,
        }));
    }

    [HttpPost("upload")]
    [Consumes("multipart/form-data")]
    public async Task<ActionResult<ApiResponse<RepositoryItemDto>>> UploadDocument(
        [FromForm] string category,
        [FromForm] IFormFile file,
        [FromForm] string? uploadedBy,
        CancellationToken ct = default)
    {
        if (file == null || file.Length == 0)
        {
            return BadRequest(ApiResponse<RepositoryItemDto>.Fail("NO_FILE", "Please select a file to upload."));
        }

        var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (ext != ".pdf" && ext != ".docx")
        {
            return BadRequest(ApiResponse<RepositoryItemDto>.Fail("INVALID_FORMAT", "Only .pdf and .docx file formats are allowed. Rejecting all other file types."));
        }

        if (string.IsNullOrWhiteSpace(category))
        {
            return BadRequest(ApiResponse<RepositoryItemDto>.Fail("CATEGORY_REQUIRED", "Category is required (Tech, PMS, or IMP)."));
        }

        try
        {
            var item = await repositoryService.UploadDocumentAsync(category, file, uploadedBy, ct);
            return Ok(ApiResponse<RepositoryItemDto>.Ok(item));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ApiResponse<RepositoryItemDto>.Fail("UPLOAD_ERROR", ex.Message));
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error uploading repository document");
            return StatusCode(500, ApiResponse<RepositoryItemDto>.Fail("SERVER_ERROR", "Failed to upload document. Please try again."));
        }
    }

    [HttpGet("{id:guid}/download")]
    public async Task<IActionResult> Download(Guid id, [FromQuery] string? viewer = null, CancellationToken ct = default)
    {
        var doc = await repositoryService.GetDocumentByIdAsync(id, ct);
        if (doc == null)
        {
            return NotFound(ApiResponse<object>.Fail("NOT_FOUND", "Document not found."));
        }

        var fileResult = storageService.GetRepositoryFileStream(doc.FilePath);
        if (fileResult == null)
        {
            return NotFound(ApiResponse<object>.Fail("FILE_NOT_FOUND", "Physical document file not found on server."));
        }

        // Record that this employee viewed/downloaded the document
        await repositoryService.RecordViewAsync(id, viewer, "Downloaded", ct);

        var (stream, contentType, downloadName) = fileResult.Value;
        return File(stream, contentType, string.IsNullOrWhiteSpace(doc.FileName) ? downloadName : doc.FileName);
    }

    [HttpPost("{id:guid}/view")]
    public async Task<ActionResult<ApiResponse<bool>>> RecordView(
        Guid id,
        [FromQuery] string? viewer,
        CancellationToken ct = default)
    {
        await repositoryService.RecordViewAsync(id, viewer, "Viewed", ct);
        return Ok(ApiResponse<bool>.Ok(true));
    }

    [HttpDelete("{id:guid}")]
    public async Task<ActionResult<ApiResponse<bool>>> Delete(
        Guid id,
        [FromQuery] string? deletedBy,
        CancellationToken ct = default)
    {
        var success = await repositoryService.DeleteDocumentAsync(id, deletedBy, ct);
        if (!success)
        {
            return NotFound(ApiResponse<bool>.Fail("NOT_FOUND", "Document not found or already deleted."));
        }

        return Ok(ApiResponse<bool>.Ok(true));
    }

    [HttpGet("logs")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<RepositoryActivityLogDto>>>> GetActivityLogs(
        [FromQuery] int limit = 100,
        CancellationToken ct = default)
    {
        var logs = await repositoryService.GetActivityLogsAsync(limit, ct);
        return Ok(ApiResponse<IReadOnlyList<RepositoryActivityLogDto>>.Ok(logs));
    }

    [HttpGet("access-summaries")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<DocumentAccessSummaryDto>>>> GetAccessSummaries(
        [FromQuery] string? category,
        [FromQuery] string? search,
        CancellationToken ct = default)
    {
        var summaries = await repositoryService.GetDocumentAccessSummariesAsync(category, search, ct);
        return Ok(ApiResponse<IReadOnlyList<DocumentAccessSummaryDto>>.Ok(summaries));
    }

    [HttpGet("categories")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<RepositoryCategoryCountDto>>>> GetCategories(
        CancellationToken ct = default)
    {
        var categories = await repositoryService.GetCategoryCountsAsync(ct);
        return Ok(ApiResponse<IReadOnlyList<RepositoryCategoryCountDto>>.Ok(categories));
    }
}
