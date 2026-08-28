namespace PMS.API.Modules.Catalogs.DTOs;

public sealed record CatalogOptionDto(Guid Id, string Code, string Name, string? PhoneCode = null, int? PhoneDigits = null);

public sealed record CityCatalogOptionDto(Guid Id, string Code, string Name, Guid CountryId);
