using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Resources.Models;

public class MstEmailDomain : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string DomainName { get; set; } = string.Empty;

    public string DisplayName { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;

    public int SortOrder { get; set; } = 0;
}
