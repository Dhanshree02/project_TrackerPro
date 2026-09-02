using System.Text.RegularExpressions;

namespace PMS.API.Infrastructure.Storage;

public sealed partial class FileStorageService : IFileStorageService
{
    private readonly string _storageRoot;
    private readonly string _documentsRoot;
    private readonly ILogger<FileStorageService> _logger;

    // Human-readable document folders under the repo-root Documents/ tree.
    public const string KycFolder = "KYC";
    public const string TechFolder = "Tech. SOPs";
    public const string PmsFolder = "PMS. SOPs";
    public const string ImpFolder = "IMP Templates";

    public FileStorageService(IConfiguration configuration, IWebHostEnvironment env, ILogger<FileStorageService> logger)
    {
        _logger = logger;
        // Check configuration or fallback to project-level storage folder
        var configPath = configuration["Storage:RootPath"];
        if (!string.IsNullOrWhiteSpace(configPath) && (!configPath.Contains(":\\") || OperatingSystem.IsWindows()))
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

        // Repo-root Documents/ tree (sits alongside apps/backend + apps/frontend).
        // Holds human-readable KYC + repository (SOP/template) folders.
        var documentsConfig = configuration["Storage:DocumentsPath"];
        if (!string.IsNullOrWhiteSpace(documentsConfig) && (!documentsConfig.Contains(":\\") || OperatingSystem.IsWindows()))
        {
            _documentsRoot = Path.IsPathRooted(documentsConfig)
                ? documentsConfig
                : Path.Combine(env.ContentRootPath, documentsConfig);
        }
        else
        {
            var repoRoot = Directory.GetParent(env.ContentRootPath)?.Parent?.FullName ?? env.ContentRootPath;
            _documentsRoot = Path.Combine(repoRoot, "Documents");
        }

        Directory.CreateDirectory(_storageRoot);
        Directory.CreateDirectory(Path.Combine(_storageRoot, "employees"));
        Directory.CreateDirectory(Path.Combine(_storageRoot, "customers"));
        Directory.CreateDirectory(Path.Combine(_storageRoot, "projects"));
        Directory.CreateDirectory(Path.Combine(_storageRoot, "general"));

        Directory.CreateDirectory(_documentsRoot);
        Directory.CreateDirectory(Path.Combine(_documentsRoot, KycFolder));
        Directory.CreateDirectory(Path.Combine(_documentsRoot, TechFolder));
        Directory.CreateDirectory(Path.Combine(_documentsRoot, PmsFolder));
        Directory.CreateDirectory(Path.Combine(_documentsRoot, ImpFolder));

        _logger.LogInformation("FileStorageService initialized. Storage root: {StorageRoot}; Documents root: {DocumentsRoot}", _storageRoot, _documentsRoot);
    }

    public string GetStorageRootPath() => _storageRoot;

    public string GetDocumentsRootPath() => _documentsRoot;

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

        // Allowed file extensions: PDF, Word (.doc, .docx), Excel (.xls, .xlsx, .xlsm, .xlsb, .csv), PowerPoint (.ppt, .pptx), Text (.txt)
        if (!IsAllowedRepositoryExtension(ext))
        {
            throw new InvalidOperationException($"Invalid file format '{ext}'. Allowed file formats: PDF (.pdf), Word (.doc, .docx), Excel (.xls, .xlsx, .xlsm, .csv), and PowerPoint (.ppt, .pptx).");
        }

        // Map category to its human-readable folder under Documents/ and its DB display value.
        var folderCategory = NormalizeRepositoryCategoryFolder(category);
        var displayCategory = NormalizeRepositoryCategoryDisplay(category);

        var targetDir = Path.Combine(_documentsRoot, folderCategory);
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

        // RelativePath is relative to the Documents/ root, e.g. "Tech. SOPs/2026..._file.pdf".
        var relativePath = Path.Combine(folderCategory, savedFileName).Replace('\\', '/');
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

    public async Task<StoredRepositoryFileInfo> SaveKycDocumentAsync(
        string clientName,
        IFormFile file,
        CancellationToken ct = default)
    {
        var rawOriginalName = Path.GetFileName(file.FileName);
        var ext = Path.GetExtension(rawOriginalName).ToLowerInvariant();

        var targetDir = Path.Combine(_documentsRoot, KycFolder);
        Directory.CreateDirectory(targetDir);

        var clientPart = SafeFileNameRegex().Replace(clientName ?? "", "_").Trim('_');
        if (string.IsNullOrWhiteSpace(clientPart)) clientPart = "client";
        if (clientPart.Length > 60) clientPart = clientPart[..60];

        var baseName = Path.GetFileNameWithoutExtension(rawOriginalName);
        var cleanBaseName = SafeFileNameRegex().Replace(baseName, "_").Trim('_');
        if (string.IsNullOrWhiteSpace(cleanBaseName)) cleanBaseName = "kyc";
        if (cleanBaseName.Length > 60) cleanBaseName = cleanBaseName[..60];

        var timestamp = DateTime.UtcNow.ToString("yyyyMMdd_HHmmss_fff");
        var savedFileName = $"{timestamp}_{clientPart}_{cleanBaseName}{ext}";
        var fullPath = Path.Combine(targetDir, savedFileName);

        await using (var stream = new FileStream(fullPath, FileMode.Create, FileAccess.Write, FileShare.None))
        {
            await file.CopyToAsync(stream, ct);
        }

        var relativePath = Path.Combine(KycFolder, savedFileName).Replace('\\', '/');

        return new StoredRepositoryFileInfo(
            FileName: rawOriginalName,
            OriginalFileName: rawOriginalName,
            ContentType: file.ContentType ?? GetContentType(ext),
            SizeBytes: file.Length,
            RelativePath: relativePath,
            CompleteFilePath: fullPath.Replace('\\', '/'),
            Category: KycFolder,
            UploadedAtUtc: DateTime.UtcNow
        );
    }

    public (Stream Stream, string ContentType, string DownloadFileName)? GetKycFileStream(string relativePathOrFileName)
    {
        if (string.IsNullOrWhiteSpace(relativePathOrFileName)) return null;

        // Absolute or Documents-relative path.
        var candidate = Path.IsPathRooted(relativePathOrFileName)
            ? relativePathOrFileName
            : Path.Combine(_documentsRoot, relativePathOrFileName);
        if (File.Exists(candidate))
        {
            var ext = Path.GetExtension(candidate);
            return (OpenReadStream(candidate), GetContentType(ext), ExtractOriginalName(Path.GetFileName(candidate)));
        }

        // Filename lookup inside the KYC folder.
        var kycDir = Path.Combine(_documentsRoot, KycFolder);
        var fileName = Path.GetFileName(relativePathOrFileName);
        var directPath = Path.Combine(kycDir, fileName);
        if (File.Exists(directPath))
        {
            var ext = Path.GetExtension(directPath);
            return (OpenReadStream(directPath), GetContentType(ext), ExtractOriginalName(fileName));
        }

        return null;
    }

    private static FileStream OpenReadStream(string path) =>
        new(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite | FileShare.Delete);

    public (Stream Stream, string ContentType, string DownloadFileName)? GetRepositoryFileStream(string category, string fileName)
    {
        if (string.IsNullOrWhiteSpace(fileName)) return null;

        // 1. New location: Documents/<display folder> (e.g. "Tech. SOPs").
        var folderCategory = NormalizeRepositoryCategoryFolder(category);
        var found = FindInDirectory(Path.Combine(_documentsRoot, folderCategory), fileName);
        if (found != null) return found;

        // 2. New location — search across all Documents repository folders.
        foreach (var subDir in new[] { TechFolder, PmsFolder, ImpFolder })
        {
            found = FindInDirectory(Path.Combine(_documentsRoot, subDir), fileName);
            if (found != null) return found;
        }

        // 3. Back-compat: legacy storage/repository/{tech|pms|imp} folders.
        foreach (var subDir in new[] { "tech", "pms", "imp" })
        {
            found = FindInDirectory(Path.Combine(_storageRoot, "repository", subDir), fileName);
            if (found != null) return found;
        }

        return null;
    }

    private (Stream Stream, string ContentType, string DownloadFileName)? FindInDirectory(string targetDir, string fileName)
    {
        if (!Directory.Exists(targetDir)) return null;

        // 1. Direct match with fileName or sanitized filename
        var directPath = Path.Combine(targetDir, fileName);
        if (File.Exists(directPath))
        {
            return (OpenReadStream(directPath), GetContentType(Path.GetExtension(directPath)), fileName);
        }

        var underscorePath = Path.Combine(targetDir, fileName.Replace(' ', '_'));
        if (File.Exists(underscorePath))
        {
            return (OpenReadStream(underscorePath), GetContentType(Path.GetExtension(underscorePath)), fileName);
        }

        // 2. Timestamp prefix match (*_cleanBaseName.ext)
        var baseName = Path.GetFileNameWithoutExtension(fileName);
        var cleanBaseName = SafeFileNameRegex().Replace(baseName, "_").Trim('_');
        var extPattern = Path.GetExtension(fileName);
        var matchingFiles = Directory.GetFiles(targetDir, $"*{cleanBaseName}*{extPattern}");
        if (matchingFiles.Length > 0)
        {
            var foundPath = matchingFiles[0];
            return (OpenReadStream(foundPath), GetContentType(Path.GetExtension(foundPath)), fileName);
        }

        return null;
    }

    public (Stream Stream, string ContentType, string DownloadFileName)? GetRepositoryFileStream(string filePath)
    {
        if (string.IsNullOrWhiteSpace(filePath)) return null;

        if (Path.IsPathRooted(filePath) && File.Exists(filePath))
        {
            var ext = Path.GetExtension(filePath);
            return (OpenReadStream(filePath), GetContentType(ext), ExtractOriginalName(Path.GetFileName(filePath)));
        }

        // New relative paths are relative to Documents/ (e.g. "Tech. SOPs/xxx.pdf");
        // legacy relative paths are relative to storage/ (e.g. "repository/tech/xxx.pdf").
        foreach (var root in new[] { _documentsRoot, _storageRoot })
        {
            var fullPath = Path.Combine(root, filePath);
            if (File.Exists(fullPath))
            {
                var ext = Path.GetExtension(fullPath);
                return (OpenReadStream(fullPath), GetContentType(ext), ExtractOriginalName(Path.GetFileName(fullPath)));
            }
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

            // New Documents/ folder for this category, plus legacy storage/repository slug.
            var candidateDirs = new List<string>
            {
                Path.Combine(_documentsRoot, folderCategory),
            };
            foreach (var subDir in new[] { TechFolder, PmsFolder, ImpFolder })
            {
                candidateDirs.Add(Path.Combine(_documentsRoot, subDir));
            }
            foreach (var subDir in new[] { "tech", "pms", "imp" })
            {
                candidateDirs.Add(Path.Combine(_storageRoot, "repository", subDir));
            }

            foreach (var targetDir in candidateDirs.Distinct())
            {
                if (DeleteFromDirectory(targetDir, fileName)) return true;
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to delete physical repository file: {Category} / {FileName}", category, fileName);
        }

        return false;
    }

    private bool DeleteFromDirectory(string targetDir, string fileName)
    {
        if (!Directory.Exists(targetDir)) return false;

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

    public bool DeleteRepositoryFile(string filePath)
    {
        if (string.IsNullOrWhiteSpace(filePath)) return false;

        try
        {
            if (Path.IsPathRooted(filePath) && File.Exists(filePath))
            {
                File.Delete(filePath);
                return true;
            }

            foreach (var root in new[] { _documentsRoot, _storageRoot })
            {
                var fullPath = Path.Combine(root, filePath);
                if (File.Exists(fullPath))
                {
                    File.Delete(fullPath);
                    return true;
                }
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

    /// <summary>Maps a category (Tech/PMS/IMP or free text) to its human-readable Documents/ folder name.</summary>
    public static string NormalizeRepositoryCategoryFolder(string category)
    {
        var clean = (category ?? "").Trim().ToLowerInvariant();
        if (clean.Contains("tech")) return TechFolder;
        if (clean.Contains("pms")) return PmsFolder;
        if (clean.Contains("imp") || clean.Contains("policy") || clean.Contains("template")) return ImpFolder;
        return TechFolder; // default fallback to Tech. SOPs
    }

    /// <summary>Maps a category (Tech/PMS/IMP, a Documents folder name, or free text) to its DB display value.</summary>
    public static string NormalizeRepositoryCategoryDisplay(string category)
    {
        var clean = (category ?? "").Trim().ToLowerInvariant();
        if (clean.Contains("tech")) return "Tech";
        if (clean.Contains("pms")) return "PMS";
        if (clean.Contains("imp") || clean.Contains("policy") || clean.Contains("template")) return "IMP";
        return "Tech";
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

    private static readonly HashSet<string> AllowedRepositoryExtensions = new(StringComparer.OrdinalIgnoreCase)
    {
        ".pdf",
        ".doc", ".docx", ".docm",
        ".xls", ".xlsx", ".xlsm", ".xlsb", ".csv",
        ".ppt", ".pptx", ".pptm",
        ".txt",
        ".png", ".jpg", ".jpeg"
    };

    public static bool IsAllowedRepositoryExtension(string? ext)
    {
        if (string.IsNullOrWhiteSpace(ext)) return false;
        var normalized = ext.StartsWith('.') ? ext : $".{ext}";
        return AllowedRepositoryExtensions.Contains(normalized);
    }

    private static string GetContentType(string ext) => ext.ToLowerInvariant() switch
    {
        ".pdf" => "application/pdf",
        ".jpg" or ".jpeg" => "image/jpeg",
        ".png" => "image/png",
        ".gif" => "image/gif",
        ".webp" => "image/webp",
        ".svg" => "image/svg+xml",
        ".doc" => "application/msword",
        ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        ".docm" => "application/vnd.ms-word.document.macroEnabled.12",
        ".xls" => "application/vnd.ms-excel",
        ".xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        ".xlsm" => "application/vnd.ms-excel.sheet.macroEnabled.12",
        ".xlsb" => "application/vnd.ms-excel.sheet.binary.macroEnabled.12",
        ".csv" => "text/csv",
        ".ppt" => "application/vnd.ms-powerpoint",
        ".pptx" => "application/vnd.openxmlformats-officedocument.presentationml.presentation",
        ".pptm" => "application/vnd.ms-powerpoint.presentation.macroEnabled.12",
        ".txt" => "text/plain",
        _ => "application/octet-stream"
    };

    [GeneratedRegex(@"[^a-zA-Z0-9_\-\.]")]
    private static partial Regex SafeFileNameRegex();

    [GeneratedRegex(@"[^a-zA-Z0-9_\-]")]
    private static partial Regex SafeIdentifierRegex();

    [GeneratedRegex(@"^\d{8}_\d{6}_\d{3}_")]
    private static partial Regex TimeStampPrefixRegex();
}
