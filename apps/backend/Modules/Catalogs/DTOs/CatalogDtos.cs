namespace PMS.API.Modules.Catalogs.DTOs;

public sealed record CatalogOptionDto(Guid Id, string Code, string Name);

public sealed record CityCatalogOptionDto(Guid Id, string Code, string Name, Guid CountryId);
