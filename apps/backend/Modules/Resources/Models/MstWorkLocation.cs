using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Resources.Models;

public class MstWorkLocation : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;

    public int SortOrder { get; set; } = 0;

    public ICollection<MstOffice> Offices { get; set; } = [];
}
