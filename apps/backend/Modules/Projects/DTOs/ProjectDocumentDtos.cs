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

public sealed record UploadProjectDocumentRequest(
    string? DocumentType = "PO",
    string? Description = null);
