namespace PMS.API.Infrastructure.Authentication;

public sealed class MicrosoftAuthOptions
{
    public const string SectionName = "MicrosoftAuth";

    public string ClientId { get; set; } = "82de9f23-83ca-4719-99e9-1ce2d10aed22";

    public string TenantId { get; set; } = "fa511855-b479-4cc1-81d1-dddefa531df2";
}
