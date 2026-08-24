using System.Text.RegularExpressions;

namespace PMS.API.Infrastructure.Storage;

public sealed partial class FileStorageService : IFileStorageService
{
    private readonly string _storageRoot;
    private readonly ILogger<FileStorageService> _logger;

    public FileStorageService(IConfiguration configuration, IWebHostEnvironment env, ILogger<FileStorageService> logger)
    {
        _logger = logger;
        // Check configuration or fallback to project-level storage folder
        var configPath = configuration["Storage:RootPath"];
        if (!string.IsNullOrWhiteSpace(configPath))
        {
            _storageRoot = Path.IsPathRooted(configPath)
                ? configPath
                : Path.Combine(env.ContentRootPath, configPath);
        }
        else
        {
            // Default to ../../storage from apps/backend (i.e. solution root storage)
            var solutionDir = Directory.GetParent(env.ContentRootPath)?.Parent?.FullName ?? env.ContentRootPath;
            _storageRoot = Path.Combine(solutionDir, "storage");
        }

        Directory.CreateDirectory(_storageRoot);
        Directory.CreateDirectory(Path.Combine(_storageRoot, "employees"));
        Directory.CreateDirectory(Path.Combine(_storageRoot, "customers"));
        Directory.CreateDirectory(Path.Combine(_storageRoot, "projects"));
        Directory.CreateDirectory(Path.Combine(_storageRoot, "general"));
        Directory.CreateDirectory(Path.Combine(_storageRoot, "repository", "tech"));
        Directory.CreateDirectory(Path.Combine(_storageRoot, "repository", "pms"));
        Directory.CreateDirectory(Path.Combine(_storageRoot, "repository", "imp"));

        _logger.LogInformation("FileStorageService initialized with root directory: {StorageRoot}", _storageRoot);
    }

    public string GetStorageRootPath() => _storageRoot;

    public async Task<StoredFileInfo> SaveEmployeeDocumentAsync(
        string employeeCode,
        string category,
        IFormFile file,
        CancellationToken ct = default)
    {
        var sanitizedCode = SanitizeIdentifier(employeeCode);
        var sanitizedCategory = SanitizeCategory(category);
        var targetDir = Path.Combine(_storageRoot, "employees", sanitizedCode, sanitizedCategory);
        Directory.CreateDirectory(targetDir);

        return await SaveFileInternalAsync(targetDir, file, Path.Combine("employees", sanitizedCode, sanitizedCategory), sanitizedCategory, ct);
    }

    public async Task<IReadOnlyList<StoredFileInfo>> SaveEmployeeDocumentsAsync(
        string employeeCode,
        string category,
        IReadOnlyList<IFormFile> files,
        CancellationToken ct = default)
    {
        var results = new List<StoredFileInfo>();
        foreach (var file in files)
        {
            if (file.Length > 0)
            {
                var stored = await SaveEmployeeDocumentAsync(employeeCode, category, file, ct);
                results.Add(stored);
            }
        }
        return results;
    }

    public async Task<StoredFileInfo> SaveCustomerDocumentAsync(
        string clientCode,
        string category,
        IFormFile file,
        CancellationToken ct = default)
    {
        var sanitizedCode = SanitizeIdentifier(clientCode);
        var sanitizedCategory = SanitizeCategory(category);
        var targetDir = Path.Combine(_storageRoot, "customers", sanitizedCode, sanitizedCategory);
        Directory.CreateDirectory(targetDir);

        return await SaveFileInternalAsync(targetDir, file, Path.Combine("customers", sanitizedCode, sanitizedCategory), sanitizedCategory, ct);
    }

    public async Task<StoredFileInfo> SaveProjectDocumentAsync(
        string projectCode,
        string category,
        IFormFile file,
        CancellationToken ct = default)
    {
        var sanitizedCode = SanitizeIdentifier(projectCode);
        var sanitizedCategory = SanitizeCategory(category);
        var targetDir = Path.Combine(_storageRoot, "projects", sanitizedCode, sanitizedCategory);
        Directory.CreateDirectory(targetDir);

        return await SaveFileInternalAsync(targetDir, file, Path.Combine("projects", sanitizedCode, sanitizedCategory), sanitizedCategory, ct);
    }

    public Task<IReadOnlyList<StoredFileInfo>> GetEmployeeDocumentsAsync(
        string employeeCode,
        string? category = null,
        CancellationToken ct = default)
    {
        var sanitizedCode = SanitizeIdentifier(employeeCode);
        var empDir = Path.Combine(_storageRoot, "employees", sanitizedCode);
        if (!Directory.Exists(empDir))
        {
            return Task.FromResult<IReadOnlyList<StoredFileInfo>>([]);
        }

        var results = new List<StoredFileInfo>();
        var searchPattern = "*.*";
        var directories = string.IsNullOrWhiteSpace(category)
            ? Directory.GetDirectories(empDir)
            : Directory.Exists(Path.Combine(empDir, SanitizeCategory(category)))
                ? [Path.Combine(empDir, SanitizeCategory(category))]
                : Array.Empty<string>();

        foreach (var dir in directories)
        {
            var catName = Path.GetFileName(dir);
            foreach (var filePath in Directory.GetFiles(dir, searchPattern))
            {
                var fileInfo = new FileInfo(filePath);
                var relPath = Path.GetRelativePath(_storageRoot, filePath);
                results.Add(new StoredFileInfo(
                    FileName: fileInfo.Name,
                    OriginalFileName: ExtractOriginalName(fileInfo.Name),
                    ContentType: GetContentType(fileInfo.Extension),
                    SizeBytes: fileInfo.Length,
                    RelativePath: relPath.Replace('\\', '/'),
                    Category: catName,
                    UploadedAtUtc: fileInfo.CreationTimeUtc
                ));
            }
        }

        return Task.FromResult<IReadOnlyList<StoredFileInfo>>(results.OrderByDescending(r => r.UploadedAtUtc).ToList());
    }

    public async Task<StoredRepositoryFileInfo> SaveRepositoryDocumentAsync(
        string category,
        IFormFile file,
        CancellationToken ct = default)
    {
        var rawOriginalName = Path.GetFileName(file.FileName);
        var ext = Path.GetExtension(rawOriginalName).ToLowerInvariant();

        // STRICT FILE EXTENSION VALIDATION: Only .pdf and .docx allowed
        if (ext != ".pdf" && ext != ".docx")
        {
            throw new InvalidOperationException($"Invalid file format '{ext}'. Only .pdf and .docx file formats are allowed.");
        }

        // Map and validate category to tech, pms, imp
        var folderCategory = NormalizeRepositoryCategoryFolder(category);
        var displayCategory = NormalizeRepositoryCategoryDisplay(category);

        var targetDir = Path.Combine(_storageRoot, "repository", folderCategory);
        Directory.CreateDirectory(targetDir);

        var baseName = Path.GetFileNameWithoutExtension(rawOriginalName);
        var cleanBaseName = SafeFileNameRegex().Replace(baseName, "_").Trim('_');
        if (string.IsNullOrWhiteSpace(cleanBaseName)) cleanBaseName = "document";
        if (cleanBaseName.Length > 80) cleanBaseName = cleanBaseName[..80];

        var timestamp = DateTime.UtcNow.ToString("yyyyMMdd_HHmmss_fff");
        var savedFileName = $"{timestamp}_{cleanBaseName}{ext}";
        var fullPath = Path.Combine(targetDir, savedFileName);

        await using (var stream = new FileStream(fullPath, FileMode.Create, FileAccess.Write, FileShare.None))
        {
            await file.CopyToAsync(stream, ct);
        }

        var relativePath = Path.Combine("repository", folderCategory, savedFileName).Replace('\\', '/');
        var completePath = fullPath.Replace('\\', '/');

        return new StoredRepositoryFileInfo(
            FileName: rawOriginalName,
            OriginalFileName: rawOriginalName,
            ContentType: file.ContentType ?? GetContentType(ext),
            SizeBytes: file.Length,
            RelativePath: relativePath,
            CompleteFilePath: completePath,
            Category: displayCategory,
            UploadedAtUtc: DateTime.UtcNow
        );
    }

    public (Stream Stream, string ContentType, string DownloadFileName)? GetRepositoryFileStream(string category, string fileName)
    {
        if (string.IsNullOrWhiteSpace(fileName)) return null;

        var folderCategory = NormalizeRepositoryCategoryFolder(category);
        var targetDir = Path.Combine(_storageRoot, "repository", folderCategory);

        if (Directory.Exists(targetDir))
        {
            // 1. Direct match with fileName or sanitized filename
            var directPath = Path.Combine(targetDir, fileName);
            if (File.Exists(directPath))
            {
                var ext = Path.GetExtension(directPath);
                var stream = new FileStream(directPath, FileMode.Open, FileAccess.Read, FileShare.Read);
                return (stream, GetContentType(ext), fileName);
            }

            var underscoreName = fileName.Replace(' ', '_');
            var underscorePath = Path.Combine(targetDir, underscoreName);
            if (File.Exists(underscorePath))
            {
                var ext = Path.GetExtension(underscorePath);
                var stream = new FileStream(underscorePath, FileMode.Open, FileAccess.Read, FileShare.Read);
                return (stream, GetContentType(ext), fileName);
            }

            // 2. Timestamp prefix match (*_cleanBaseName.ext)
            var baseName = Path.GetFileNameWithoutExtension(fileName);
            var cleanBaseName = SafeFileNameRegex().Replace(baseName, "_").Trim('_');
            var extPattern = Path.GetExtension(fileName);
            var matchingFiles = Directory.GetFiles(targetDir, $"*{cleanBaseName}*{extPattern}");
            if (matchingFiles.Length > 0)
            {
                var foundPath = matchingFiles[0];
                var ext = Path.GetExtension(foundPath);
                var stream = new FileStream(foundPath, FileMode.Open, FileAccess.Read, FileShare.Read);
                return (stream, GetContentType(ext), fileName);
            }
        }

        // 3. Fallback search in all repository folders
        foreach (var subDir in new[] { "tech", "pms", "imp" })
        {
            var fallbackDir = Path.Combine(_storageRoot, "repository", subDir);
            if (!Directory.Exists(fallbackDir)) continue;

            var directMatch = Path.Combine(fallbackDir, fileName);
            if (File.Exists(directMatch))
            {
                var ext = Path.GetExtension(directMatch);
                var stream = new FileStream(directMatch, FileMode.Open, FileAccess.Read, FileShare.Read);
                return (stream, GetContentType(ext), fileName);
            }

            var underscoreMatch = Path.Combine(fallbackDir, fileName.Replace(' ', '_'));
            if (File.Exists(underscoreMatch))
            {
                var ext = Path.GetExtension(underscoreMatch);
                var stream = new FileStream(underscoreMatch, FileMode.Open, FileAccess.Read, FileShare.Read);
                return (stream, GetContentType(ext), fileName);
            }
        }

        return null;
    }

    public (Stream Stream, string ContentType, string DownloadFileName)? GetRepositoryFileStream(string filePath)
    {
        if (string.IsNullOrWhiteSpace(filePath)) return null;

        var fullPath = Path.IsPathRooted(filePath)
            ? filePath
            : Path.Combine(_storageRoot, filePath);

        if (File.Exists(fullPath))
        {
            var ext = Path.GetExtension(fullPath);
            var stream = new FileStream(fullPath, FileMode.Open, FileAccess.Read, FileShare.Read);
            var downloadName = ExtractOriginalName(Path.GetFileName(fullPath));
            return (stream, GetContentType(ext), downloadName);
        }

        // Try searching by filename across categories
        var fileName = Path.GetFileName(filePath);
        return GetRepositoryFileStream("", fileName);
    }

    public bool DeleteRepositoryFile(string category, string fileName)
    {
        if (string.IsNullOrWhiteSpace(fileName)) return false;

        try
        {
            var folderCategory = NormalizeRepositoryCategoryFolder(category);
            var targetDir = Path.Combine(_storageRoot, "repository", folderCategory);

            if (Directory.Exists(targetDir))
            {
                var directPath = Path.Combine(targetDir, fileName);
                if (File.Exists(directPath))
                {
                    File.Delete(directPath);
                    return true;
                }

                var underscorePath = Path.Combine(targetDir, fileName.Replace(' ', '_'));
                if (File.Exists(underscorePath))
                {
                    File.Delete(underscorePath);
                    return true;
                }

                var baseName = Path.GetFileNameWithoutExtension(fileName);
                var cleanBaseName = SafeFileNameRegex().Replace(baseName, "_").Trim('_');
                var extPattern = Path.GetExtension(fileName);
                var matchingFiles = Directory.GetFiles(targetDir, $"*{cleanBaseName}*{extPattern}");
                foreach (var match in matchingFiles)
                {
                    if (File.Exists(match)) File.Delete(match);
                }
                return matchingFiles.Length > 0;
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to delete physical repository file: {Category} / {FileName}", category, fileName);
        }

        return false;
    }

    public bool DeleteRepositoryFile(string filePath)
    {
        if (string.IsNullOrWhiteSpace(filePath)) return false;

        try
        {
            var fullPath = Path.IsPathRooted(filePath)
                ? filePath
                : Path.Combine(_storageRoot, filePath);

            if (File.Exists(fullPath))
            {
                File.Delete(fullPath);
                return true;
            }

            var fileName = Path.GetFileName(filePath);
            return DeleteRepositoryFile("", fileName);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to delete physical repository file: {FilePath}", filePath);
        }

        return false;
    }

    public static string NormalizeRepositoryCategoryFolder(string category)
    {
        var clean = (category ?? "").Trim().ToLowerInvariant();
        if (clean.Contains("tech")) return "tech";
        if (clean.Contains("pms")) return "pms";
        if (clean.Contains("imp") || clean.Contains("policy") || clean.Contains("template")) return "imp";
        return "tech"; // default fallback to tech
    }

    public static string NormalizeRepositoryCategoryDisplay(string category)
    {
        var folder = NormalizeRepositoryCategoryFolder(category);
        return folder switch
        {
            "tech" => "Tech",
            "pms" => "PMS",
            "imp" => "IMP",
            _ => "Tech"
        };
    }

    private static async Task<StoredFileInfo> SaveFileInternalAsync(
        string targetDir,
        IFormFile file,
        string relativeDir,
        string category,
        CancellationToken ct)
    {
        var rawOriginalName = Path.GetFileName(file.FileName);
        var ext = Path.GetExtension(rawOriginalName).ToLowerInvariant();
        var baseName = Path.GetFileNameWithoutExtension(rawOriginalName);
        var cleanBaseName = SafeFileNameRegex().Replace(baseName, "_").Trim('_');
        if (string.IsNullOrWhiteSpace(cleanBaseName)) cleanBaseName = "doc";
        if (cleanBaseName.Length > 50) cleanBaseName = cleanBaseName[..50];

        var timestamp = DateTime.UtcNow.ToString("yyyyMMdd_HHmmss_fff");
        var savedFileName = $"{timestamp}_{cleanBaseName}{ext}";
        var fullPath = Path.Combine(targetDir, savedFileName);

        await using (var stream = new FileStream(fullPath, FileMode.Create, FileAccess.Write, FileShare.None))
        {
            await file.CopyToAsync(stream, ct);
        }

        var relativePath = Path.Combine(relativeDir, savedFileName).Replace('\\', '/');

        return new StoredFileInfo(
            FileName: savedFileName,
            OriginalFileName: rawOriginalName,
            ContentType: file.ContentType ?? GetContentType(ext),
            SizeBytes: file.Length,
            RelativePath: relativePath,
            Category: category,
            UploadedAtUtc: DateTime.UtcNow
        );
    }

    private static string SanitizeIdentifier(string input)
    {
        if (string.IsNullOrWhiteSpace(input)) return "unassigned";
        var clean = SafeIdentifierRegex().Replace(input.Trim(), "-");
        return string.IsNullOrWhiteSpace(clean) ? "unassigned" : clean.ToLowerInvariant();
    }

    private static string SanitizeCategory(string input)
    {
        if (string.IsNullOrWhiteSpace(input)) return "general";
        var clean = SafeIdentifierRegex().Replace(input.Trim(), "-").ToLowerInvariant();
        return clean switch
        {
            "resume" or "cv" => "resume",
            "pan" or "pan-card" => "pan",
            "aadhaar" or "aadhaar-card" => "aadhaar",
            "offer" or "offer-letter" => "offer-letter",
            "education" or "education-certs" or "certificates" => "certificates",
            "experience" or "experience-letters" => "experience-letters",
            "kyc" or "kyc-document" => "kyc",
            _ => clean
        };
    }

    private static string ExtractOriginalName(string savedName)
    {
        // Name format is yyyyMMdd_HHmmss_fff_original.ext
        var match = TimeStampPrefixRegex().Match(savedName);
        return match.Success ? savedName[match.Length..] : savedName;
    }

    private static string GetContentType(string ext) => ext.ToLowerInvariant() switch
    {
        ".pdf" => "application/pdf",
        ".jpg" or ".jpeg" => "image/jpeg",
        ".png" => "image/png",
        ".doc" => "application/msword",
        ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        ".xls" or ".xlsx" => "application/vnd.ms-excel",
        _ => "application/octet-stream"
    };

    [GeneratedRegex(@"[^a-zA-Z0-9_\-\.]")]
    private static partial Regex SafeFileNameRegex();

    [GeneratedRegex(@"[^a-zA-Z0-9_\-]")]
    private static partial Regex SafeIdentifierRegex();

    [GeneratedRegex(@"^\d{8}_\d{6}_\d{3}_")]
    private static partial Regex TimeStampPrefixRegex();
}
