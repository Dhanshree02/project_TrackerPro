using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// Project attachment, Purchase Order (PO), SOW, or proposal document.
/// </summary>
public class ProjectDocument : BaseEntity
{
    public Guid ProjectId { get; set; }

    public Project? Project { get; set; }

    /// <summary>
    /// Document category: "PO", "SOW", "Proposal", "Signed Contract", "NDA", "Other".
    /// </summary>
    public string DocumentType { get; set; } = "PO";

    public string FileName { get; set; } = string.Empty;

    public string OriginalFileName { get; set; } = string.Empty;

    public string FilePath { get; set; } = string.Empty;

    public string ContentType { get; set; } = "application/octet-stream";

    public long SizeBytes { get; set; }

    public string? Description { get; set; }
}
