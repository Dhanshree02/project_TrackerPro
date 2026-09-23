using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// Master service catalog template (e.g. "PT001 - External Network Penetration Testing").
/// Contains default pricing, tools, and duration that populate new project service line items.
/// </summary>
public class MstServiceCatalog : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public Guid SubDepartmentId { get; set; }

    public MstServiceSubDepartment? SubDepartment { get; set; }

    public string? DefaultTools { get; set; }

    public decimal? DefaultUnitPrice { get; set; }

    public int? DefaultDurationDays { get; set; }

    public string? Description { get; set; }

    public bool IsActive { get; set; } = true;

    public int SortOrder { get; set; }
}
