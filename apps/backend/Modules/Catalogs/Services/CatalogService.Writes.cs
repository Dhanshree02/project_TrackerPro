using Microsoft.EntityFrameworkCore;
using PMS.API.Modules.Catalogs.DTOs;
using PMS.API.Modules.Catalogs.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Common.Models;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.Catalogs.Services;

public sealed partial class CatalogService
{
    public Task<CatalogOptionDto> CreateIndustryAsync(UpsertCatalogItemRequest request, CancellationToken ct = default) =>
        SaveIndustryAsync(null, request, ct);

    public Task<CatalogOptionDto> UpdateIndustryAsync(Guid id, UpsertCatalogItemRequest request, CancellationToken ct = default) =>
        SaveIndustryAsync(id, request, ct);

    public async Task DeleteIndustryAsync(Guid id, CancellationToken ct = default)
    {
        var row = await db.Industries.FirstOrDefaultAsync(item => item.Id == id, ct)
            ?? throw new NotFoundException("Industry was not found.");
        Park(row.Id, row.Name, row.Code, 150, 80, (name, code) =>
        {
            row.Name = name;
            row.Code = code;
        });
        row.IsActive = false;
        db.Industries.Remove(row);
        await db.SaveChangesAsync(ct);
    }

    public Task<CatalogOptionDto> CreateCountryAsync(UpsertCatalogItemRequest request, CancellationToken ct = default) =>
        SaveCountryAsync(null, request, ct);

    public Task<CatalogOptionDto> UpdateCountryAsync(Guid id, UpsertCatalogItemRequest request, CancellationToken ct = default) =>
        SaveCountryAsync(id, request, ct);

    public async Task DeleteCountryAsync(Guid id, CancellationToken ct = default)
    {
        var inUse = await db.Cities.AnyAsync(city => city.CountryId == id, ct);
        if (inUse) throw new ConflictException("This country still has cities. Remove those cities first.");

        var row = await db.Countries.FirstOrDefaultAsync(item => item.Id == id, ct)
            ?? throw new NotFoundException("Country was not found.");
        Park(row.Id, row.Name, row.Code, 120, 8, (name, code) =>
        {
            row.Name = name;
            row.Code = code;
        });
        row.IsActive = false;
        db.Countries.Remove(row);
        await db.SaveChangesAsync(ct);
    }

    public Task<CityCatalogOptionDto> CreateCityAsync(UpsertCityRequest request, CancellationToken ct = default) =>
        SaveCityAsync(null, request, ct);

    public Task<CityCatalogOptionDto> UpdateCityAsync(Guid id, UpsertCityRequest request, CancellationToken ct = default) =>
        SaveCityAsync(id, request, ct);

    public async Task DeleteCityAsync(Guid id, CancellationToken ct = default)
    {
        var row = await db.Cities.FirstOrDefaultAsync(item => item.Id == id, ct)
            ?? throw new NotFoundException("City was not found.");
        Park(row.Id, row.Name, row.Code, 120, 80, (name, code) =>
        {
            row.Name = name;
            row.Code = code;
        });
        row.IsActive = false;
        db.Cities.Remove(row);
        await db.SaveChangesAsync(ct);
    }

    public Task<CatalogOptionDto> CreateContactDesignationAsync(UpsertCatalogItemRequest request, CancellationToken ct = default) =>
        SaveContactDesignationAsync(null, request, ct);

    public Task<CatalogOptionDto> UpdateContactDesignationAsync(Guid id, UpsertCatalogItemRequest request, CancellationToken ct = default) =>
        SaveContactDesignationAsync(id, request, ct);

    public async Task DeleteContactDesignationAsync(Guid id, CancellationToken ct = default)
    {
        var row = await db.ContactDesignations.FirstOrDefaultAsync(item => item.Id == id, ct)
            ?? throw new NotFoundException("Contact designation was not found.");
        Park(row.Id, row.Name, row.Code, 150, 80, (name, code) =>
        {
            row.Name = name;
            row.Code = code;
        });
        row.IsActive = false;
        db.ContactDesignations.Remove(row);
        await db.SaveChangesAsync(ct);
    }

    public Task<CatalogOptionDto> CreateContactTypeAsync(UpsertCatalogItemRequest request, CancellationToken ct = default) =>
        SaveContactTypeAsync(null, request, ct);

    public Task<CatalogOptionDto> UpdateContactTypeAsync(Guid id, UpsertCatalogItemRequest request, CancellationToken ct = default) =>
        SaveContactTypeAsync(id, request, ct);

    public async Task DeleteContactTypeAsync(Guid id, CancellationToken ct = default)
    {
        var row = await db.ContactTypes.FirstOrDefaultAsync(item => item.Id == id, ct)
            ?? throw new NotFoundException("Contact type was not found.");
        Park(row.Id, row.Name, row.Code, 150, 80, (name, code) =>
        {
            row.Name = name;
            row.Code = code;
        });
        row.IsActive = false;
        db.ContactTypes.Remove(row);
        await db.SaveChangesAsync(ct);
    }

    public async Task<IReadOnlyList<ScreenOptionDto>> GetScreenOptionsAsync(string? category, CancellationToken ct = default)
    {
        var query = db.ScreenOptions.Where(row => row.IsActive);
        if (!string.IsNullOrWhiteSpace(category))
        {
            var key = category.Trim();
            query = query.Where(row => row.Category == key);
        }

        return await query
            .OrderBy(row => row.Category)
            .ThenBy(row => row.SortOrder)
            .ThenBy(row => row.Name)
            .Select(row => new ScreenOptionDto(row.Id, row.Category, row.Name, row.ParentName, row.SortOrder))
            .ToListAsync(ct);
    }

    public async Task<ScreenOptionDto> CreateScreenOptionAsync(UpsertScreenOptionRequest request, CancellationToken ct = default)
    {
        var (category, name, parent) = await NormalizeScreenOptionAsync(null, request, ct);
        var sort = await db.ScreenOptions
            .Where(row => row.Category == category && row.ParentName == parent)
            .MaxAsync(row => (int?)row.SortOrder, ct) ?? 0;
        var created = new MstScreenOption
        {
            Category = category,
            Name = name,
            ParentName = parent,
            SortOrder = sort + 1,
            IsActive = true,
        };
        db.ScreenOptions.Add(created);
        await db.SaveChangesAsync(ct);
        return MapScreen(created);
    }

    public async Task<ScreenOptionDto> UpdateScreenOptionAsync(Guid id, UpsertScreenOptionRequest request, CancellationToken ct = default)
    {
        var row = await db.ScreenOptions.FirstOrDefaultAsync(item => item.Id == id, ct)
            ?? throw new NotFoundException("Choice was not found.");
        var (category, name, parent) = await NormalizeScreenOptionAsync(id, request, ct);
        row.Category = category;
        row.Name = name;
        row.ParentName = parent;
        row.IsActive = true;
        await db.SaveChangesAsync(ct);
        return MapScreen(row);
    }

    public async Task DeleteScreenOptionAsync(Guid id, CancellationToken ct = default)
    {
        var row = await db.ScreenOptions.FirstOrDefaultAsync(item => item.Id == id, ct)
            ?? throw new NotFoundException("Choice was not found.");
        row.IsActive = false;
        db.ScreenOptions.Remove(row);
        await db.SaveChangesAsync(ct);
    }

    private async Task<CatalogOptionDto> SaveIndustryAsync(Guid? id, UpsertCatalogItemRequest request, CancellationToken ct)
    {
        var name = RequiredName(request.Name, "Industry");
        await EnsureUniqueNameAsync(db.Industries.Where(item => item.Name.ToLower() == name.ToLower() && item.Id != id), "Industry", name, ct);
        MstIndustry row;
        if (id is Guid existing)
        {
            row = await db.Industries.FirstOrDefaultAsync(item => item.Id == existing, ct)
                ?? throw new NotFoundException("Industry was not found.");
            row.Name = name;
            if (!string.IsNullOrWhiteSpace(request.Code))
                row.Code = await UniqueCodeAsync(request.Code.Trim(), 80, code => db.Industries.IgnoreQueryFilters().AnyAsync(item => item.Code == code && item.Id != row.Id, ct), ct);
        }
        else
        {
            row = new MstIndustry
            {
                Name = name,
                Code = await UniqueCodeAsync(request.Code, 80, code => db.Industries.IgnoreQueryFilters().AnyAsync(item => item.Code == code, ct), ct),
                IsActive = true,
            };
            db.Industries.Add(row);
        }

        await db.SaveChangesAsync(ct);
        return new CatalogOptionDto(row.Id, row.Code, row.Name, null, null);
    }

    private async Task<CatalogOptionDto> SaveCountryAsync(Guid? id, UpsertCatalogItemRequest request, CancellationToken ct)
    {
        var name = RequiredName(request.Name, "Country");
        await EnsureUniqueNameAsync(db.Countries.Where(item => item.Name.ToLower() == name.ToLower() && item.Id != id), "Country", name, ct);
        MstCountry row;
        if (id is Guid existing)
        {
            row = await db.Countries.FirstOrDefaultAsync(item => item.Id == existing, ct)
                ?? throw new NotFoundException("Country was not found.");
            row.Name = name;
            if (!string.IsNullOrWhiteSpace(request.Code))
                row.Code = await UniqueCodeAsync(request.Code.Trim().ToUpperInvariant(), 8, code => db.Countries.IgnoreQueryFilters().AnyAsync(item => item.Code == code && item.Id != row.Id, ct), ct);
        }
        else
        {
            row = new MstCountry
            {
                Name = name,
                Code = await UniqueCodeAsync(request.Code?.Trim().ToUpperInvariant(), 8, code => db.Countries.IgnoreQueryFilters().AnyAsync(item => item.Code == code, ct), ct),
                PhoneCode = "+91",
                PhoneDigits = 10,
                IsActive = true,
            };
            db.Countries.Add(row);
        }

        await db.SaveChangesAsync(ct);
        return new CatalogOptionDto(row.Id, row.Code, row.Name, row.PhoneCode, row.PhoneDigits);
    }

    private async Task<CityCatalogOptionDto> SaveCityAsync(Guid? id, UpsertCityRequest request, CancellationToken ct)
    {
        var name = RequiredName(request.Name, "City");
        var country = await db.Countries.FirstOrDefaultAsync(item => item.Id == request.CountryId && item.IsActive, ct)
            ?? throw new BadRequestException("Select a country for this city.");
        var nameTaken = await db.Cities.AnyAsync(
            item => item.CountryId == country.Id && item.Name.ToLower() == name.ToLower() && item.Id != id,
            ct);
        if (nameTaken) throw new ConflictException($"\"{name}\" already exists for this country.");

        MstCity row;
        if (id is Guid existing)
        {
            row = await db.Cities.FirstOrDefaultAsync(item => item.Id == existing, ct)
                ?? throw new NotFoundException("City was not found.");
            row.Name = name;
            row.CountryId = country.Id;
            if (!string.IsNullOrWhiteSpace(request.Code))
                row.Code = await UniqueCodeAsync(request.Code.Trim(), 80, code => db.Cities.IgnoreQueryFilters().AnyAsync(item => item.Code == code && item.Id != row.Id, ct), ct);
        }
        else
        {
            row = new MstCity
            {
                Name = name,
                CountryId = country.Id,
                Code = await UniqueCodeAsync(request.Code, 80, code => db.Cities.IgnoreQueryFilters().AnyAsync(item => item.Code == code, ct), ct),
                IsActive = true,
            };
            db.Cities.Add(row);
        }

        await db.SaveChangesAsync(ct);
        return new CityCatalogOptionDto(row.Id, row.Code, row.Name, row.CountryId);
    }

    private async Task<CatalogOptionDto> SaveContactDesignationAsync(Guid? id, UpsertCatalogItemRequest request, CancellationToken ct)
    {
        var name = RequiredName(request.Name, "Contact designation");
        await EnsureUniqueNameAsync(
            db.ContactDesignations.Where(item => item.Name.ToLower() == name.ToLower() && item.Id != id),
            "Contact designation",
            name,
            ct);
        MstContactDesignation row;
        if (id is Guid existing)
        {
            row = await db.ContactDesignations.FirstOrDefaultAsync(item => item.Id == existing, ct)
                ?? throw new NotFoundException("Contact designation was not found.");
            row.Name = name;
            if (!string.IsNullOrWhiteSpace(request.Code))
                row.Code = await UniqueCodeAsync(request.Code.Trim(), 80, code => db.ContactDesignations.IgnoreQueryFilters().AnyAsync(item => item.Code == code && item.Id != row.Id, ct), ct);
        }
        else
        {
            var sort = await db.ContactDesignations.MaxAsync(item => (int?)item.SortOrder, ct) ?? 0;
            row = new MstContactDesignation
            {
                Name = name,
                Code = await UniqueCodeAsync(request.Code, 80, code => db.ContactDesignations.IgnoreQueryFilters().AnyAsync(item => item.Code == code, ct), ct),
                SortOrder = sort + 1,
                IsActive = true,
            };
            db.ContactDesignations.Add(row);
        }

        await db.SaveChangesAsync(ct);
        return new CatalogOptionDto(row.Id, row.Code, row.Name, null, null);
    }

    private async Task<CatalogOptionDto> SaveContactTypeAsync(Guid? id, UpsertCatalogItemRequest request, CancellationToken ct)
    {
        var name = RequiredName(request.Name, "Contact type");
        await EnsureUniqueNameAsync(
            db.ContactTypes.Where(item => item.Name.ToLower() == name.ToLower() && item.Id != id),
            "Contact type",
            name,
            ct);
        var description = string.IsNullOrWhiteSpace(request.Description) ? null : request.Description.Trim();
        if (description is { Length: > 300 }) description = description[..300];

        MstContactType row;
        if (id is Guid existing)
        {
            row = await db.ContactTypes.FirstOrDefaultAsync(item => item.Id == existing, ct)
                ?? throw new NotFoundException("Contact type was not found.");
            row.Name = name;
            row.Description = description;
            if (!string.IsNullOrWhiteSpace(request.Code))
                row.Code = await UniqueCodeAsync(request.Code.Trim(), 80, code => db.ContactTypes.IgnoreQueryFilters().AnyAsync(item => item.Code == code && item.Id != row.Id, ct), ct);
        }
        else
        {
            var sort = await db.ContactTypes.MaxAsync(item => (int?)item.SortOrder, ct) ?? 0;
            row = new MstContactType
            {
                Name = name,
                Description = description,
                Code = await UniqueCodeAsync(request.Code, 80, code => db.ContactTypes.IgnoreQueryFilters().AnyAsync(item => item.Code == code, ct), ct),
                SortOrder = sort + 1,
                IsActive = true,
            };
            db.ContactTypes.Add(row);
        }

        await db.SaveChangesAsync(ct);
        return new CatalogOptionDto(row.Id, row.Code, row.Name, null, null, row.Description);
    }

    private async Task<(string Category, string Name, string Parent)> NormalizeScreenOptionAsync(
        Guid? id,
        UpsertScreenOptionRequest request,
        CancellationToken ct)
    {
        var category = request.Category?.Trim() ?? "";
        if (!ScreenOptionCategory.All.Contains(category))
            throw new BadRequestException("That choice list is not one of the master lists.");

        var name = RequiredName(request.Name, "Choice");
        var parent = (request.ParentName ?? "").Trim();
        if (!ScreenOptionCategory.RequiresParent(category))
        {
            parent = "";
        }
        else if (string.IsNullOrWhiteSpace(parent))
        {
            throw new BadRequestException("Select the list this choice belongs to.");
        }
        else if (category == ScreenOptionCategory.WbsProjectType && parent is not ("Resource" or "Scope"))
        {
            throw new BadRequestException("Project type belongs to Resource or Scope.");
        }
        else if (category == ScreenOptionCategory.BillingModel)
        {
            var known = await db.ScreenOptions.AnyAsync(
                row => row.IsActive && row.Category == ScreenOptionCategory.WbsProjectType && row.Name == parent,
                ct);
            if (!known) throw new BadRequestException("Select a project type for this billing model.");
        }
        else if (category == ScreenOptionCategory.PaymentTerm)
        {
            var known = await db.ScreenOptions.AnyAsync(
                row => row.IsActive && row.Category == ScreenOptionCategory.BillingModel && row.Name == parent,
                ct);
            if (!known) throw new BadRequestException("Select a billing model for this payment term.");
        }

        var duplicate = await db.ScreenOptions.AnyAsync(
            row => row.IsActive
                && row.Id != id
                && row.Category == category
                && row.ParentName == parent
                && row.Name.ToLower() == name.ToLower(),
            ct);
        if (duplicate) throw new ConflictException($"\"{name}\" already exists in this list.");
        return (category, name, parent);
    }

    private static ScreenOptionDto MapScreen(MstScreenOption row) =>
        new(row.Id, row.Category, row.Name, row.ParentName, row.SortOrder);

    private static string RequiredName(string? value, string label)
    {
        var name = value?.Trim() ?? "";
        if (name.Length == 0) throw new BadRequestException($"{label} name is required.");
        if (name.Length > 200) name = name[..200];
        return name;
    }

    private static async Task EnsureUniqueNameAsync(IQueryable<BaseEntity> matches, string label, string name, CancellationToken ct)
    {
        if (await matches.AnyAsync(ct))
            throw new ConflictException($"\"{name}\" already exists.");
    }

    private static void Park(Guid id, string name, string code, int nameMax, int codeMax, Action<string, string> write)
    {
        var token = id.ToString("N")[..8];
        write(Truncate($"retired {token} {name}", nameMax), Truncate($"x{token}{code}", codeMax));
    }

    private async Task<string> UniqueCodeAsync(string? requested, int maxLength, Func<string, Task<bool>> exists, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        var seed = string.IsNullOrWhiteSpace(requested) ? "item" : Slug(requested);
        seed = Truncate(seed, maxLength);
        if (string.IsNullOrEmpty(seed)) seed = "item";
        var code = seed;
        var n = 2;
        while (await exists(code))
        {
            var suffix = n.ToString();
            var room = Math.Max(1, maxLength - suffix.Length);
            code = Truncate(seed, room) + suffix;
            n++;
            if (n > 99) throw new ConflictException("Could not assign a unique code.");
        }

        return code;
    }

    private static string Slug(string value)
    {
        var chars = value.Trim().ToUpperInvariant().Select(c => char.IsLetterOrDigit(c) ? c : '_').ToArray();
        var slug = new string(chars);
        while (slug.Contains("__", StringComparison.Ordinal))
            slug = slug.Replace("__", "_", StringComparison.Ordinal);
        return slug.Trim('_');
    }

    private static string Truncate(string value, int max) =>
        value.Length <= max ? value : value[..max].Trim('_', '-', ' ');
}
