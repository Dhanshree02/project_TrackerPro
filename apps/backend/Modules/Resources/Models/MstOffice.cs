using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Resources.Models;

public class MstOffice : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public Guid? WorkLocationId { get; set; }

    public MstWorkLocation? WorkLocation { get; set; }

    public bool IsActive { get; set; } = true;

    public int SortOrder { get; set; } = 0;
}
