using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Repository.Models;

public class RepositoryItem : BaseEntity
{
    public string FileName { get; set; } = string.Empty;

    public string Category { get; set; } = string.Empty;

    public long Size { get; set; }

    public DateTime LastUpdated { get; set; } = DateTime.UtcNow;

    public string UploadedBy { get; set; } = string.Empty;

    public string FilePath { get; set; } = string.Empty;

    /// <summary>Departments whose employees may view this document.</summary>
    public ICollection<RepositoryDepartment> Departments { get; set; } = [];
}
