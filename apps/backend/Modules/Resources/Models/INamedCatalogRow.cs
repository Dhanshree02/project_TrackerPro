namespace PMS.API.Modules.Resources.Models;

/// <summary>Name and code columns shared by the customer master catalogs.</summary>
public interface INamedCatalogRow
{
    string Name { get; set; }

    string Code { get; set; }

    bool IsActive { get; set; }
}
