using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Resources.Models;

/// <summary>Master city catalog. Always belongs to a <see cref="MstCountry"/>.</summary>
public class MstCity : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;

    public Guid CountryId { get; set; }

    public MstCountry Country { get; set; } = null!;
}
