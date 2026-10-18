using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Catalogs.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Resources;
using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Common.Models;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.Catalogs.Services;

public sealed class CatalogService(AppDbContext db) : ICatalogService
{
    public async Task<IReadOnlyList<CatalogOptionDto>> GetCountriesAsync(CancellationToken ct = default)
    {
        return await db.Countries
            .Where(c => c.IsActive)
            .OrderBy(c => c.Name)
            .Select(c => new CatalogOptionDto(c.Id, c.Code, c.Name, c.PhoneCode, c.PhoneDigits))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<CatalogOptionDto>> GetNationalitiesAsync(CancellationToken ct = default)
    {
        return await db.Nationalities
            .Where(n => n.IsActive)
            .OrderBy(n => n.Name)
            .Select(n => new CatalogOptionDto(n.Id, n.Code, n.Name, null, null))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<CityCatalogOptionDto>> GetCitiesAsync(
        Guid? countryId,
        CancellationToken ct = default)
    {
        var query = db.Cities.Where(c => c.IsActive);
        if (countryId is not null)
        {
            query = query.Where(c => c.CountryId == countryId);
        }

        return await query
            .OrderBy(c => c.Name)
            .Select(c => new CityCatalogOptionDto(c.Id, c.Code, c.Name, c.CountryId))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<CatalogOptionDto>> GetIndustriesAsync(CancellationToken ct = default)
    {
        return await db.Industries
            .Where(i => i.IsActive)
            .OrderBy(i => i.Name)
            .Select(i => new CatalogOptionDto(i.Id, i.Code, i.Name, null, null))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<CatalogOptionDto>> GetContactDesignationsAsync(CancellationToken ct = default)
    {
        return await db.ContactDesignations
            .Where(d => d.IsActive)
            .OrderBy(d => d.SortOrder)
            .ThenBy(d => d.Name)
            .Select(d => new CatalogOptionDto(d.Id, d.Code, d.Name, null, null))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<CatalogOptionDto>> GetContactTypesAsync(CancellationToken ct = default)
    {
        return await db.ContactTypes
            .Where(t => t.IsActive)
            .OrderBy(t => t.SortOrder)
            .ThenBy(t => t.Name)
            .Select(t => new CatalogOptionDto(t.Id, t.Code, t.Name, null, null))
            .ToListAsync(ct);
    }

    public Task<CatalogOptionDto> CreateIndustryAsync(string name, string? code, CancellationToken ct = default) =>
        CreateNamedCatalogAsync(db.Industries, name, code, 150, 80, "Industry", null, ct);

    public async Task<CatalogOptionDto> UpdateIndustryAsync(Guid id, string name, string? code, CancellationToken ct = default)
    {
        var entity = await db.Industries.FirstOrDefaultAsync(i => i.Id == id && i.IsActive, ct)
            ?? throw new NotFoundException("Industry not found.");
        var previous = entity.Name;
        await ApplyNamedCatalogAsync(db.Industries, entity, name, code, 150, 80, "Industry", ct);
        if (!string.Equals(previous, entity.Name, StringComparison.Ordinal))
        {
            await db.Clients
                .Where(c => c.IndustryId == id || c.Industry == previous)
                .ExecuteUpdateAsync(s => s.SetProperty(c => c.Industry, entity.Name), ct);
        }

        return new CatalogOptionDto(entity.Id, entity.Code, entity.Name, null, null);
    }

    public async Task DeleteIndustryAsync(Guid id, CancellationToken ct = default)
    {
        var entity = await db.Industries.FirstOrDefaultAsync(i => i.Id == id && i.IsActive, ct)
            ?? throw new NotFoundException("Industry not found.");
        entity.IsActive = false;
        db.Industries.Remove(entity);
        await db.SaveChangesAsync(ct);
    }

    public async Task<CatalogOptionDto> CreateContactDesignationAsync(string name, string? code, CancellationToken ct = default)
    {
        var sort = await db.ContactDesignations.IgnoreQueryFilters().MaxAsync(d => (int?)d.SortOrder, ct) ?? 0;
        return await CreateNamedCatalogAsync(db.ContactDesignations, name, code, 150, 80, "Contact designation", entity =>
        {
            entity.SortOrder = sort + 1;
        }, ct);
    }

    public async Task<CatalogOptionDto> UpdateContactDesignationAsync(Guid id, string name, string? code, CancellationToken ct = default)
    {
        var entity = await db.ContactDesignations.FirstOrDefaultAsync(d => d.Id == id && d.IsActive, ct)
            ?? throw new NotFoundException("Contact designation not found.");
        var previous = entity.Name;
        await ApplyNamedCatalogAsync(db.ContactDesignations, entity, name, code, 150, 80, "Contact designation", ct);
        if (!string.Equals(previous, entity.Name, StringComparison.Ordinal))
        {
            await db.Clients.Where(c => c.ContactDesignation == previous)
                .ExecuteUpdateAsync(s => s.SetProperty(c => c.ContactDesignation, entity.Name), ct);
            await db.ClientContacts.Where(c => c.Designation == previous)
                .ExecuteUpdateAsync(s => s.SetProperty(c => c.Designation, entity.Name), ct);
        }

        return new CatalogOptionDto(entity.Id, entity.Code, entity.Name, null, null);
    }

    public async Task DeleteContactDesignationAsync(Guid id, CancellationToken ct = default)
    {
        var entity = await db.ContactDesignations.FirstOrDefaultAsync(d => d.Id == id && d.IsActive, ct)
            ?? throw new NotFoundException("Contact designation not found.");
        entity.IsActive = false;
        db.ContactDesignations.Remove(entity);
        await db.SaveChangesAsync(ct);
    }

    public async Task<CatalogOptionDto> CreateContactTypeAsync(string name, string? code, CancellationToken ct = default)
    {
        var sort = await db.ContactTypes.IgnoreQueryFilters().MaxAsync(t => (int?)t.SortOrder, ct) ?? 0;
        return await CreateNamedCatalogAsync(db.ContactTypes, name, code, 150, 80, "Contact type", entity =>
        {
            entity.SortOrder = sort + 1;
        }, ct);
    }

    public async Task<CatalogOptionDto> UpdateContactTypeAsync(Guid id, string name, string? code, CancellationToken ct = default)
    {
        var entity = await db.ContactTypes.FirstOrDefaultAsync(t => t.Id == id && t.IsActive, ct)
            ?? throw new NotFoundException("Contact type not found.");
        var previous = entity.Name;
        await ApplyNamedCatalogAsync(db.ContactTypes, entity, name, code, 150, 80, "Contact type", ct);
        if (!string.Equals(previous, entity.Name, StringComparison.Ordinal))
        {
            await db.Clients.Where(c => c.ContactType == previous)
                .ExecuteUpdateAsync(s => s.SetProperty(c => c.ContactType, entity.Name), ct);
            await db.ClientContacts.Where(c => c.ContactType == previous)
                .ExecuteUpdateAsync(s => s.SetProperty(c => c.ContactType, entity.Name), ct);
        }

        return new CatalogOptionDto(entity.Id, entity.Code, entity.Name, null, null);
    }

    public async Task DeleteContactTypeAsync(Guid id, CancellationToken ct = default)
    {
        var entity = await db.ContactTypes.FirstOrDefaultAsync(t => t.Id == id && t.IsActive, ct)
            ?? throw new NotFoundException("Contact type not found.");
        entity.IsActive = false;
        db.ContactTypes.Remove(entity);
        await db.SaveChangesAsync(ct);
    }

    public async Task<CatalogOptionDto> CreateCountryAsync(string name, string? code, CancellationToken ct = default)
    {
        var trimmed = RequireName(name, "Country", 120);
        var existing = await db.Countries.IgnoreQueryFilters()
            .FirstOrDefaultAsync(c => c.Name.ToLower() == trimmed.ToLower(), ct);
        if (existing is not null)
        {
            if (existing.DeletedAtUtc is null && existing.IsActive)
                throw new ConflictException($"Country \"{trimmed}\" already exists.");
            existing.DeletedAtUtc = null;
            existing.IsActive = true;
            if (!string.IsNullOrWhiteSpace(code))
                existing.Code = await UniqueCatalogCodeAsync(db.Countries, code, existing.Code, 8, "Country", ct);
            await db.SaveChangesAsync(ct);
            return new CatalogOptionDto(existing.Id, existing.Code, existing.Name, existing.PhoneCode, existing.PhoneDigits);
        }

        var entity = new MstCountry
        {
            Name = trimmed,
            Code = await UniqueCatalogCodeAsync(db.Countries, code, null, 8, "Country", ct, trimmed),
            IsActive = true,
        };
        db.Countries.Add(entity);
        await db.SaveChangesAsync(ct);
        return new CatalogOptionDto(entity.Id, entity.Code, entity.Name, entity.PhoneCode, entity.PhoneDigits);
    }

    public async Task<CatalogOptionDto> UpdateCountryAsync(Guid id, string name, string? code, CancellationToken ct = default)
    {
        var entity = await db.Countries.FirstOrDefaultAsync(c => c.Id == id && c.IsActive, ct)
            ?? throw new NotFoundException("Country not found.");
        var previous = entity.Name;
        var trimmed = RequireName(name, "Country", 120);
        var duplicate = await db.Countries.AnyAsync(c => c.Id != id && c.IsActive && c.Name.ToLower() == trimmed.ToLower(), ct);
        if (duplicate)
            throw new ConflictException($"Country \"{trimmed}\" already exists.");
        entity.Name = trimmed;
        entity.Code = await UniqueCatalogCodeAsync(db.Countries, code, entity.Code, 8, "Country", ct);
        await db.SaveChangesAsync(ct);
        if (!string.Equals(previous, entity.Name, StringComparison.Ordinal))
        {
            await db.Clients.Where(c => c.CountryId == id || c.Country == previous)
                .ExecuteUpdateAsync(s => s.SetProperty(c => c.Country, entity.Name), ct);
            await db.ClientContacts.Where(c => c.Country == previous)
                .ExecuteUpdateAsync(s => s.SetProperty(c => c.Country, entity.Name), ct);
        }

        return new CatalogOptionDto(entity.Id, entity.Code, entity.Name, entity.PhoneCode, entity.PhoneDigits);
    }

    public async Task DeleteCountryAsync(Guid id, CancellationToken ct = default)
    {
        var used = await db.Cities.AnyAsync(c => c.CountryId == id && c.IsActive, ct)
            || await db.Clients.AnyAsync(c => c.CountryId == id, ct);
        if (used)
            throw new ConflictException("This country is used by a city or customer and cannot be removed.");
        var entity = await db.Countries.FirstOrDefaultAsync(c => c.Id == id && c.IsActive, ct)
            ?? throw new NotFoundException("Country not found.");
        entity.IsActive = false;
        db.Countries.Remove(entity);
        await db.SaveChangesAsync(ct);
    }

    public async Task<CityCatalogOptionDto> CreateCityAsync(string name, string? code, Guid countryId, CancellationToken ct = default)
    {
        var trimmed = RequireName(name, "City", 120);
        var country = await db.Countries.FirstOrDefaultAsync(c => c.Id == countryId && c.IsActive, ct)
            ?? throw new NotFoundException("Country not found.");
        var existing = await db.Cities.IgnoreQueryFilters()
            .FirstOrDefaultAsync(c => c.CountryId == countryId && c.Name.ToLower() == trimmed.ToLower(), ct);
        if (existing is not null)
        {
            if (existing.DeletedAtUtc is null && existing.IsActive)
                throw new ConflictException($"City \"{trimmed}\" already exists for {country.Name}.");
            existing.DeletedAtUtc = null;
            existing.IsActive = true;
            if (!string.IsNullOrWhiteSpace(code))
                existing.Code = await UniqueCatalogCodeAsync(db.Cities, code, existing.Code, 80, "City", ct);
            await db.SaveChangesAsync(ct);
            return new CityCatalogOptionDto(existing.Id, existing.Code, existing.Name, existing.CountryId);
        }

        var entity = new MstCity
        {
            Name = trimmed,
            CountryId = country.Id,
            Code = await UniqueCatalogCodeAsync(db.Cities, code, null, 80, "City", ct, trimmed),
            IsActive = true,
        };
        db.Cities.Add(entity);
        await db.SaveChangesAsync(ct);
        return new CityCatalogOptionDto(entity.Id, entity.Code, entity.Name, entity.CountryId);
    }

    public async Task<CityCatalogOptionDto> UpdateCityAsync(Guid id, string name, string? code, Guid countryId, CancellationToken ct = default)
    {
        var entity = await db.Cities.FirstOrDefaultAsync(c => c.Id == id && c.IsActive, ct)
            ?? throw new NotFoundException("City not found.");
        var previous = entity.Name;
        var trimmed = RequireName(name, "City", 120);
        var country = await db.Countries.FirstOrDefaultAsync(c => c.Id == countryId && c.IsActive, ct)
            ?? throw new NotFoundException("Country not found.");
        var duplicate = await db.Cities.AnyAsync(
            c => c.Id != id && c.IsActive && c.CountryId == country.Id && c.Name.ToLower() == trimmed.ToLower(),
            ct);
        if (duplicate)
            throw new ConflictException($"City \"{trimmed}\" already exists for {country.Name}.");
        entity.Name = trimmed;
        entity.CountryId = country.Id;
        entity.Code = await UniqueCatalogCodeAsync(db.Cities, code, entity.Code, 80, "City", ct);
        await db.SaveChangesAsync(ct);
        if (!string.Equals(previous, entity.Name, StringComparison.Ordinal))
        {
            await db.Clients.Where(c => c.CityId == id || c.City == previous)
                .ExecuteUpdateAsync(s => s.SetProperty(c => c.City, entity.Name), ct);
        }

        return new CityCatalogOptionDto(entity.Id, entity.Code, entity.Name, entity.CountryId);
    }

    public async Task DeleteCityAsync(Guid id, CancellationToken ct = default)
    {
        var used = await db.Clients.AnyAsync(c => c.CityId == id, ct);
        if (used)
            throw new ConflictException("This city is used by a customer and cannot be removed.");
        var entity = await db.Cities.FirstOrDefaultAsync(c => c.Id == id && c.IsActive, ct)
            ?? throw new NotFoundException("City not found.");
        entity.IsActive = false;
        db.Cities.Remove(entity);
        await db.SaveChangesAsync(ct);
    }

    public async Task<IReadOnlyList<AddressCityDto>> GetAddressCitiesAsync(CancellationToken ct = default)
    {
        return await db.AddressCities
            .Where(c => c.IsActive)
            .OrderBy(c => c.SortOrder)
            .ThenBy(c => c.Name)
            .Select(c => new AddressCityDto(c.Id, c.Code, c.Name, c.Line, c.SortOrder))
            .ToListAsync(ct);
    }

    public async Task<AddressCityDto> CreateAddressCityAsync(
        string name,
        string? line,
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ConflictException("City name is required.");

        var (storedName, storedLine) = AddressCityCatalog.Compose(name, line);
        if (storedName.Length > 200)
            throw new ConflictException("City name must be 200 characters or less.");

        var existing = await db.AddressCities
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(c => c.Name.ToLower() == storedName.ToLower(), ct);
        if (existing is not null)
        {
            if (existing.DeletedAtUtc is null && existing.IsActive)
                throw new ConflictException($"\"{existing.Name}\" is already in Current Address - City.");

            existing.DeletedAtUtc = null;
            existing.IsActive = true;
            existing.Line = storedLine;
            existing.UpdatedAtUtc = DateTime.UtcNow;
            await db.SaveChangesAsync(ct);
            return new AddressCityDto(existing.Id, existing.Code, existing.Name, existing.Line, existing.SortOrder);
        }

        var used = await db.AddressCities
            .IgnoreQueryFilters()
            .Select(c => c.Code)
            .ToListAsync(ct);
        var codes = new HashSet<string>(used, StringComparer.OrdinalIgnoreCase);
        var sort = await db.AddressCities.IgnoreQueryFilters().MaxAsync(c => (int?)c.SortOrder, ct) ?? 0;

        var entity = new MstAddressCity
        {
            Code = AddressCityCatalog.CodeFor(storedName, codes),
            Name = storedName,
            Line = storedLine,
            IsActive = true,
            SortOrder = sort + 1,
        };
        db.AddressCities.Add(entity);
        await db.SaveChangesAsync(ct);
        return new AddressCityDto(entity.Id, entity.Code, entity.Name, entity.Line, entity.SortOrder);
    }

    public async Task DeleteAddressCityAsync(Guid id, CancellationToken ct = default)
    {
        var row = await db.AddressCities.FirstOrDefaultAsync(c => c.Id == id, ct)
            ?? throw new NotFoundException("Address city not found.");
        row.IsActive = false;
        db.AddressCities.Remove(row);
        await db.SaveChangesAsync(ct);
    }

    public async Task<IReadOnlyList<ServiceGroupDto>> GetServiceGroupsAsync(CancellationToken ct = default)
    {
        return await db.ServiceGroups
            .Where(g => g.IsActive)
            .OrderBy(g => g.SortOrder)
            .ThenBy(g => g.Name)
            .Select(g => new ServiceGroupDto(g.Id, g.Code, g.Name, g.SortOrder))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<ServiceDepartmentDto>> GetServiceDepartmentsAsync(
        Guid? groupId = null,
        CancellationToken ct = default)
    {
        var query = db.ServiceDepartments
            .Include(d => d.Group)
            .Where(d => d.IsActive);

        if (groupId.HasValue)
        {
            query = query.Where(d => d.GroupId == groupId.Value);
        }

        return await query
            .OrderBy(d => d.SortOrder)
            .ThenBy(d => d.Name)
            .Select(d => new ServiceDepartmentDto(
                d.Id,
                d.Code,
                d.Name,
                d.GroupId,
                d.Group != null ? d.Group.Name : string.Empty,
                d.SortOrder))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<ServiceSubDepartmentDto>> GetServiceSubDepartmentsAsync(
        Guid? departmentId = null,
        CancellationToken ct = default)
    {
        var query = db.ServiceSubDepartments
            .Include(s => s.Department)
            .Where(s => s.IsActive);

        if (departmentId.HasValue)
        {
            query = query.Where(s => s.DepartmentId == departmentId.Value);
        }

        return await query
            .OrderBy(s => s.SortOrder)
            .ThenBy(s => s.Name)
            .Select(s => new ServiceSubDepartmentDto(
                s.Id,
                s.Code,
                s.Name,
                s.DepartmentId,
                s.Department != null ? s.Department.Name : string.Empty,
                s.SortOrder))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<ServiceCatalogOptionDto>> GetServiceCatalogAsync(
        Guid? subDepartmentId = null,
        CancellationToken ct = default)
    {
        var query = db.ServiceCatalogs
            .Include(c => c.SubDepartment)
            .Where(c => c.IsActive);

        if (subDepartmentId.HasValue)
        {
            query = query.Where(c => c.SubDepartmentId == subDepartmentId.Value);
        }

        return await query
            .OrderBy(c => c.SortOrder)
            .ThenBy(c => c.Name)
            .Select(c => new ServiceCatalogOptionDto(
                c.Id,
                c.Code,
                c.Name,
                c.SubDepartmentId,
                c.SubDepartment != null ? c.SubDepartment.Name : string.Empty,
                c.DefaultTools,
                c.DefaultUnitPrice,
                c.DefaultDurationDays,
                c.Description,
                c.SortOrder))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<ServiceHierarchyGroupDto>> GetServiceHierarchyAsync(CancellationToken ct = default)
    {
        var groups = await db.ServiceGroups
            .Where(g => g.IsActive)
            .OrderBy(g => g.SortOrder)
            .ThenBy(g => g.Name)
            .Include(g => g.Departments.Where(d => d.IsActive))
                .ThenInclude(d => d.SubDepartments.Where(s => s.IsActive))
                    .ThenInclude(s => s.Services.Where(c => c.IsActive))
            .ToListAsync(ct);

        return groups.Select(g => new ServiceHierarchyGroupDto(
            g.Id,
            g.Code,
            g.Name,
            g.SortOrder,
            g.Departments
                .OrderBy(d => d.SortOrder)
                .ThenBy(d => d.Name)
                .Select(d => new ServiceHierarchyDeptDto(
                    d.Id,
                    d.Code,
                    d.Name,
                    g.Code,
                    g.Name,
                    d.SortOrder,
                    d.SubDepartments
                        .OrderBy(s => s.SortOrder)
                        .ThenBy(s => s.Name)
                        .Select(s => new ServiceHierarchySubDeptDto(
                            s.Id,
                            s.Code,
                            s.Name,
                            s.SortOrder,
                            s.Services
                                .OrderBy(c => c.SortOrder)
                                .ThenBy(c => c.Name)
                                .Select(c => new ServiceHierarchyItemDto(
                                    c.Id,
                                    c.Code,
                                    c.Name,
                                    c.DefaultTools,
                                    c.DefaultUnitPrice,
                                    c.DefaultDurationDays,
                                    c.Description,
                                    c.SortOrder))
                                .ToList()))
                        .ToList()))
                .ToList()))
            .ToList();
    }

    public async Task<ServiceGroupDto> CreateServiceGroupAsync(string name, CancellationToken ct = default)
    {
        var trimmed = RequireName(name, "Contract type", 100);
        var existing = await db.ServiceGroups
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(g => g.Name.ToLower() == trimmed.ToLower(), ct);
        if (existing is not null)
        {
            if (existing.DeletedAtUtc is null && existing.IsActive)
                throw new ConflictException($"Contract type \"{trimmed}\" already exists.");

            existing.DeletedAtUtc = null;
            existing.IsActive = true;
            await db.SaveChangesAsync(ct);
            return new ServiceGroupDto(existing.Id, existing.Code, existing.Name, existing.SortOrder);
        }

        var code = await NextCodeAsync(
            trimmed,
            40,
            candidate => db.ServiceGroups.IgnoreQueryFilters().AnyAsync(g => g.Code.ToLower() == candidate.ToLower(), ct),
            ct);
        var sort = await db.ServiceGroups.IgnoreQueryFilters().MaxAsync(g => (int?)g.SortOrder, ct) ?? 0;
        var entity = new MstServiceGroup
        {
            Code = code,
            Name = trimmed,
            IsActive = true,
            SortOrder = sort + 1,
        };
        db.ServiceGroups.Add(entity);
        await db.SaveChangesAsync(ct);
        return new ServiceGroupDto(entity.Id, entity.Code, entity.Name, entity.SortOrder);
    }

    public async Task<ServiceDepartmentDto> CreateServiceDepartmentAsync(
        Guid groupId,
        string name,
        CancellationToken ct = default)
    {
        var trimmed = RequireName(name, "Department", 150);
        var group = await db.ServiceGroups.FirstOrDefaultAsync(g => g.Id == groupId && g.IsActive, ct)
            ?? throw new NotFoundException("Contract type not found.");
        var existing = await db.ServiceDepartments
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(d => d.GroupId == groupId && d.Name.ToLower() == trimmed.ToLower(), ct);
        if (existing is not null)
        {
            if (existing.DeletedAtUtc is null && existing.IsActive)
                throw new ConflictException($"Department \"{trimmed}\" already exists for {group.Name}.");

            existing.DeletedAtUtc = null;
            existing.IsActive = true;
            await db.SaveChangesAsync(ct);
            return new ServiceDepartmentDto(existing.Id, existing.Code, existing.Name, group.Id, group.Name, existing.SortOrder);
        }

        var code = await NextCodeAsync(
            trimmed,
            80,
            candidate => db.ServiceDepartments.IgnoreQueryFilters().AnyAsync(d => d.Code.ToLower() == candidate.ToLower(), ct),
            ct);
        var sort = await db.ServiceDepartments.IgnoreQueryFilters()
            .Where(d => d.GroupId == groupId)
            .MaxAsync(d => (int?)d.SortOrder, ct) ?? 0;
        var entity = new MstServiceDepartment
        {
            Code = code,
            Name = trimmed,
            GroupId = groupId,
            IsActive = true,
            SortOrder = sort + 1,
        };
        db.ServiceDepartments.Add(entity);
        await db.SaveChangesAsync(ct);
        return new ServiceDepartmentDto(entity.Id, entity.Code, entity.Name, group.Id, group.Name, entity.SortOrder);
    }

    public async Task<ServiceSubDepartmentDto> CreateServiceSubDepartmentAsync(
        Guid departmentId,
        string name,
        CancellationToken ct = default)
    {
        var trimmed = RequireName(name, "Sub-department", 200);
        var department = await db.ServiceDepartments.FirstOrDefaultAsync(d => d.Id == departmentId && d.IsActive, ct)
            ?? throw new NotFoundException("Department not found.");
        var existing = await db.ServiceSubDepartments
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(s => s.DepartmentId == departmentId && s.Name.ToLower() == trimmed.ToLower(), ct);
        if (existing is not null)
        {
            if (existing.DeletedAtUtc is null && existing.IsActive)
                throw new ConflictException($"Sub-department \"{trimmed}\" already exists for {department.Name}.");

            existing.DeletedAtUtc = null;
            existing.IsActive = true;
            await db.SaveChangesAsync(ct);
            return new ServiceSubDepartmentDto(existing.Id, existing.Code, existing.Name, department.Id, department.Name, existing.SortOrder);
        }

        var code = await NextCodeAsync(
            trimmed,
            120,
            candidate => db.ServiceSubDepartments.IgnoreQueryFilters().AnyAsync(s => s.Code.ToLower() == candidate.ToLower(), ct),
            ct);
        var sort = await db.ServiceSubDepartments.IgnoreQueryFilters()
            .Where(s => s.DepartmentId == departmentId)
            .MaxAsync(s => (int?)s.SortOrder, ct) ?? 0;
        var entity = new MstServiceSubDepartment
        {
            Code = code,
            Name = trimmed,
            DepartmentId = departmentId,
            IsActive = true,
            SortOrder = sort + 1,
        };
        db.ServiceSubDepartments.Add(entity);
        await db.SaveChangesAsync(ct);
        return new ServiceSubDepartmentDto(entity.Id, entity.Code, entity.Name, department.Id, department.Name, entity.SortOrder);
    }

    public async Task<ServiceHierarchyItemDto> CreateServiceCatalogAsync(
        CreateServiceCatalogRequest request,
        CancellationToken ct = default)
    {
        var trimmed = RequireName(request.Name, "Service", 255);
        var tools = NormalizeTools(request.DefaultTools);
        var price = NormalizePrice(request.DefaultUnitPrice, required: false);
        var days = NormalizeDays(request.DefaultDurationDays, required: false);
        var sub = await db.ServiceSubDepartments.FirstOrDefaultAsync(s => s.Id == request.SubDepartmentId && s.IsActive, ct)
            ?? throw new NotFoundException("Sub-department not found.");
        var existing = await db.ServiceCatalogs
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(c => c.SubDepartmentId == sub.Id && c.Name.ToLower() == trimmed.ToLower(), ct);
        if (existing is not null)
        {
            if (existing.DeletedAtUtc is null && existing.IsActive)
                throw new ConflictException($"Service \"{trimmed}\" already exists in {sub.Name}.");

            existing.DeletedAtUtc = null;
            existing.IsActive = true;
            existing.DefaultTools = tools;
            existing.DefaultUnitPrice = price;
            existing.DefaultDurationDays = days;
            await db.SaveChangesAsync(ct);
            return ToCatalogItem(existing);
        }

        var code = await NextCodeAsync(
            trimmed,
            50,
            candidate => db.ServiceCatalogs.IgnoreQueryFilters().AnyAsync(c => c.Code.ToLower() == candidate.ToLower(), ct),
            ct);
        var sort = await db.ServiceCatalogs.IgnoreQueryFilters()
            .Where(c => c.SubDepartmentId == sub.Id)
            .MaxAsync(c => (int?)c.SortOrder, ct) ?? 0;
        var entity = new MstServiceCatalog
        {
            Code = code,
            Name = trimmed,
            SubDepartmentId = sub.Id,
            DefaultTools = tools,
            DefaultUnitPrice = price,
            DefaultDurationDays = days,
            IsActive = true,
            SortOrder = sort + 1,
        };
        db.ServiceCatalogs.Add(entity);
        await db.SaveChangesAsync(ct);
        return ToCatalogItem(entity);
    }

    public async Task<ServiceHierarchyItemDto> UpdateServiceCatalogAsync(
        Guid id,
        UpdateServiceCatalogRequest request,
        CancellationToken ct = default)
    {
        var entity = await db.ServiceCatalogs.FirstOrDefaultAsync(c => c.Id == id && c.IsActive, ct)
            ?? throw new NotFoundException("Service not found.");

        var tools = NormalizeTools(request.DefaultTools);
        if (string.IsNullOrWhiteSpace(tools))
            throw new ConflictException("Tools are required.");
        var price = NormalizePrice(request.DefaultUnitPrice, required: true)
            ?? throw new ConflictException("Unit price must be greater than 0.");
        var days = NormalizeDays(request.DefaultDurationDays, required: true)
            ?? throw new ConflictException("Duration must be a number of days greater than 0.");

        var targetSubId = request.SubDepartmentId ?? entity.SubDepartmentId;
        if (request.SubDepartmentId is Guid subId)
        {
            var subExists = await db.ServiceSubDepartments.AnyAsync(s => s.Id == subId && s.IsActive, ct);
            if (!subExists)
                throw new NotFoundException("Sub-department not found.");
        }

        var targetName = string.IsNullOrWhiteSpace(request.Name) ? entity.Name : RequireName(request.Name, "Service", 255);
        var duplicate = await db.ServiceCatalogs.AnyAsync(
            c => c.Id != id && c.IsActive && c.SubDepartmentId == targetSubId && c.Name.ToLower() == targetName.ToLower(),
            ct);
        if (duplicate)
            throw new ConflictException($"Service \"{targetName}\" already exists in that sub-department.");

        entity.Name = targetName;
        entity.SubDepartmentId = targetSubId;
        entity.DefaultTools = tools;
        entity.DefaultUnitPrice = price;
        entity.DefaultDurationDays = days;
        await db.SaveChangesAsync(ct);
        return ToCatalogItem(entity);
    }

    public async Task DeleteServiceCatalogAsync(Guid id, CancellationToken ct = default)
    {
        var entity = await db.ServiceCatalogs.FirstOrDefaultAsync(c => c.Id == id && c.IsActive, ct)
            ?? throw new NotFoundException("Service not found.");
        entity.IsActive = false;
        db.ServiceCatalogs.Remove(entity);
        await db.SaveChangesAsync(ct);
    }

    private static ServiceHierarchyItemDto ToCatalogItem(MstServiceCatalog entity) =>
        new(
            entity.Id,
            entity.Code,
            entity.Name,
            entity.DefaultTools,
            entity.DefaultUnitPrice,
            entity.DefaultDurationDays,
            entity.Description,
            entity.SortOrder);

    private static string RequireName(string? name, string label, int maxLength)
    {
        var trimmed = (name ?? string.Empty).Trim();
        if (trimmed.Length == 0)
            throw new ConflictException($"{label} name is required.");
        if (trimmed.Length > maxLength)
            throw new ConflictException($"{label} name must be {maxLength} characters or less.");
        return trimmed;
    }

    private async Task<CatalogOptionDto> CreateNamedCatalogAsync<T>(
        DbSet<T> set,
        string name,
        string? code,
        int nameMax,
        int codeMax,
        string label,
        Action<T>? configure,
        CancellationToken ct)
        where T : BaseEntity, INamedCatalogRow, new()
    {
        var trimmed = RequireName(name, label, nameMax);
        var existing = await set.IgnoreQueryFilters()
            .FirstOrDefaultAsync(x => x.Name.ToLower() == trimmed.ToLower(), ct);
        if (existing is not null)
        {
            if (existing.DeletedAtUtc is null && existing.IsActive)
                throw new ConflictException($"{label} \"{trimmed}\" already exists.");

            existing.DeletedAtUtc = null;
            existing.IsActive = true;
            if (!string.IsNullOrWhiteSpace(code))
                existing.Code = await UniqueCatalogCodeAsync(set, code, existing.Code, codeMax, label, ct);
            configure?.Invoke(existing);
            await db.SaveChangesAsync(ct);
            return new CatalogOptionDto(existing.Id, existing.Code, existing.Name, null, null);
        }

        var entity = new T
        {
            Name = trimmed,
            IsActive = true,
            Code = await UniqueCatalogCodeAsync(set, code, null, codeMax, label, ct, trimmed),
        };
        configure?.Invoke(entity);
        set.Add(entity);
        await db.SaveChangesAsync(ct);
        return new CatalogOptionDto(entity.Id, entity.Code, entity.Name, null, null);
    }

    private async Task ApplyNamedCatalogAsync<T>(
        DbSet<T> set,
        T entity,
        string name,
        string? code,
        int nameMax,
        int codeMax,
        string label,
        CancellationToken ct)
        where T : BaseEntity, INamedCatalogRow
    {
        var trimmed = RequireName(name, label, nameMax);
        var duplicate = await set.AnyAsync(
            x => x.Id != entity.Id && x.IsActive && x.Name.ToLower() == trimmed.ToLower(),
            ct);
        if (duplicate)
            throw new ConflictException($"{label} \"{trimmed}\" already exists.");

        entity.Name = trimmed;
        entity.Code = await UniqueCatalogCodeAsync(set, code, entity.Code, codeMax, label, ct);
        await db.SaveChangesAsync(ct);
    }

    private async Task<string> UniqueCatalogCodeAsync<T>(
        DbSet<T> set,
        string? requested,
        string? current,
        int maxLength,
        string label,
        CancellationToken ct,
        string? nameForGenerated = null)
        where T : BaseEntity, INamedCatalogRow
    {
        if (string.IsNullOrWhiteSpace(requested))
        {
            if (!string.IsNullOrWhiteSpace(current))
                return current;
            return await NextCodeAsync(
                nameForGenerated ?? "ITEM",
                maxLength,
                candidate => set.IgnoreQueryFilters().AnyAsync(x => x.Code.ToLower() == candidate.ToLower(), ct),
                ct);
        }

        var seed = requested.Trim().ToUpperInvariant();
        if (seed.Length > maxLength)
            throw new ConflictException($"{label} code must be {maxLength} characters or less.");

        var taken = await set.IgnoreQueryFilters().AnyAsync(
            x => x.Code.ToLower() == seed.ToLower() && (current == null || x.Code.ToLower() != current.ToLower()),
            ct);
        if (taken)
            throw new ConflictException($"{label} code \"{seed}\" already exists.");
        return seed;
    }

    private static string? NormalizeTools(string? tools)
    {
        var trimmed = tools?.Trim();
        if (string.IsNullOrEmpty(trimmed))
            return null;
        if (trimmed.Length > 500)
            throw new ConflictException("Tools must be 500 characters or less.");
        return trimmed;
    }

    private static decimal? NormalizePrice(decimal? price, bool required)
    {
        if (price is null)
        {
            if (required)
                throw new ConflictException("Unit price is required.");
            return null;
        }

        if (price <= 0)
            throw new ConflictException("Unit price must be greater than 0.");
        return decimal.Round(price.Value, 2);
    }

    private static int? NormalizeDays(int? days, bool required)
    {
        if (days is null)
        {
            if (required)
                throw new ConflictException("Duration is required.");
            return null;
        }

        if (days <= 0 || days > 3650)
            throw new ConflictException("Duration must be between 1 and 3650 days.");
        return days;
    }

    private static async Task<string> NextCodeAsync(
        string name,
        int maxLength,
        Func<string, Task<bool>> taken,
        CancellationToken ct)
    {
        var letters = new string(name.Where(char.IsLetterOrDigit).ToArray()).ToUpperInvariant();
        if (letters.Length == 0)
            letters = "ITEM";
        var room = Math.Max(1, maxLength - 3);
        var seed = letters.Length <= room ? letters : letters[..room];
        for (var n = 0; n < 1000; n++)
        {
            ct.ThrowIfCancellationRequested();
            var suffix = n == 0 ? string.Empty : n.ToString();
            var stem = seed.Length + suffix.Length > maxLength
                ? seed[..Math.Max(1, maxLength - suffix.Length)]
                : seed;
            var code = stem + suffix;
            if (!await taken(code))
                return code;
        }

        throw new ConflictException("Could not assign a unique code.");
    }
}
