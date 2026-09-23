using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// Normalized resource level distribution row under a ProjectService (e.g. Level="L1", Count=2).
/// Enforces relational querying and extensibility for future resource tiers.
/// </summary>
public class ProjectServiceResourceLevel : BaseEntity
{
    public Guid ProjectServiceId { get; set; }

    public ProjectServiceEntity? ProjectService { get; set; }

    /// <summary>Resource level tier: "L1", "L2", "Senior", etc.</summary>
    public string Level { get; set; } = string.Empty;

    /// <summary>Number of allocated resources at this level.</summary>
    public int Count { get; set; }
}
