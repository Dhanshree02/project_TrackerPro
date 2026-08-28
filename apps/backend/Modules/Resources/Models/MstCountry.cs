using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Resources.Models;

/// <summary>Master country catalog (ISO 3166-1 alpha-2 <see cref="Code"/>).</summary>
public class MstCountry : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public string PhoneCode { get; set; } = "+91";

    public int PhoneDigits { get; set; } = 10;

    public bool IsActive { get; set; } = true;

    public ICollection<MstCity> Cities { get; set; } = [];
}
