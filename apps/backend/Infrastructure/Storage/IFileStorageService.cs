namespace PMS.API.Infrastructure.Storage;

public sealed record StoredFileInfo(
    string FileName,
    string OriginalFileName,
    string ContentType,
    long SizeBytes,
    string RelativePath,
    string Category,
    DateTime UploadedAtUtc);

public sealed record StoredRepositoryFileInfo(
    string FileName,
    string OriginalFileName,
    string ContentType,
    long SizeBytes,
    string RelativePath,
    string CompleteFilePath,
    string Category,
    DateTime UploadedAtUtc);

public interface IFileStorageService
{
    Task<StoredFileInfo> SaveEmployeeDocumentAsync(
        string employeeCode,
        string category,
        IFormFile file,
        CancellationToken ct = default);

    Task<IReadOnlyList<StoredFileInfo>> SaveEmployeeDocumentsAsync(
        string employeeCode,
        string category,
        IReadOnlyList<IFormFile> files,
        CancellationToken ct = default);

    Task<StoredFileInfo> SaveCustomerDocumentAsync(
        string clientCode,
        string category,
        IFormFile file,
        CancellationToken ct = default);

    Task<StoredFileInfo> SaveProjectDocumentAsync(
        string projectCode,
        string category,
        IFormFile file,
        CancellationToken ct = default);

    Task<IReadOnlyList<StoredFileInfo>> GetEmployeeDocumentsAsync(
        string employeeCode,
        string? category = null,
        CancellationToken ct = default);

    Task<StoredRepositoryFileInfo> SaveRepositoryDocumentAsync(
        string category,
        IFormFile file,
        CancellationToken ct = default);

    (Stream Stream, string ContentType, string DownloadFileName)? GetRepositoryFileStream(string category, string fileName);

    (Stream Stream, string ContentType, string DownloadFileName)? GetRepositoryFileStream(string filePath);

    bool DeleteRepositoryFile(string category, string fileName);

    bool DeleteRepositoryFile(string filePath);

    string GetStorageRootPath();
}
