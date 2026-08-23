using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Repository.Models;

public class RepositoryActivityLog : BaseEntity
{
    public string Action { get; set; } = string.Empty; // "Uploaded", "Deleted", "Downloaded"

    public Guid? DocumentId { get; set; }

    public string FileName { get; set; } = string.Empty;

    public string Category { get; set; } = string.Empty;

    public string PerformedBy { get; set; } = string.Empty;

    public string? Details { get; set; }
}
