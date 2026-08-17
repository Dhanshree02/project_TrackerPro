namespace PMS.API.Shared.Common.Models;

/// <summary>
/// Base class for all auditable entities. Follows the company's data conventions:
/// UUID primary keys, audit columns on every table, soft deletes where applicable.
/// </summary>
public abstract class BaseEntity
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAtUtc { get; set; }

    public Guid? CreatedBy { get; set; }

    public Guid? UpdatedBy { get; set; }

    /// <summary>
    /// Soft delete marker — rows are never physically removed.
    /// </summary>
    public DateTime? DeletedAtUtc { get; set; }
}
