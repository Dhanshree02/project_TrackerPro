using Microsoft.AspNetCore.Http;

namespace PMS.API.Modules.Projects.DTOs;

public sealed record ProjectDocumentDto(
    Guid Id,
    Guid ProjectId,
    string DocumentType,
    string FileName,
    string OriginalFileName,
    string FilePath,
    string ContentType,
    long SizeBytes,
    string? Description,
    DateTime CreatedAtUtc,
    DateTime? UpdatedAtUtc);

public sealed class UploadProjectDocumentRequest
{
    public IFormFile File { get; set; } = null!;
    public string? DocumentType { get; set; } = "PO";
    public string? Category { get; set; }
    public string? Description { get; set; }

    public UploadProjectDocumentRequest() { }

    public UploadProjectDocumentRequest(
        string? DocumentType = "PO",
        string? Description = null,
        IFormFile? File = null,
        string? Category = null)
    {
        this.DocumentType = DocumentType;
        this.Description = Description;
        this.Category = Category;
        if (File != null) this.File = File;
    }
}
