using PMS.API.Modules.Catalogs.DTOs;

namespace PMS.API.Modules.Catalogs.Services;

public interface IResourceMastersService
{
    Task<ResourceMastersSnapshotDto> GetSnapshotAsync(CancellationToken ct = default);

    Task<DepartmentHierarchyRowDto> CreateHierarchyAsync(UpsertDepartmentHierarchyRequest request, CancellationToken ct = default);

    Task<DepartmentHierarchyRowDto> UpdateHierarchyAsync(Guid designationId, UpsertDepartmentHierarchyRequest request, CancellationToken ct = default);

    Task DeleteHierarchyAsync(Guid designationId, CancellationToken ct = default);

    Task<NamedMasterDto> CreateEmailDomainAsync(string name, CancellationToken ct = default);

    Task<NamedMasterDto> UpdateEmailDomainAsync(Guid id, string name, CancellationToken ct = default);

    Task DeleteEmailDomainAsync(Guid id, CancellationToken ct = default);

    Task<NamedMasterDto> CreateBusinessUnitAsync(string name, CancellationToken ct = default);

    Task<NamedMasterDto> UpdateBusinessUnitAsync(Guid id, string name, CancellationToken ct = default);

    Task DeleteBusinessUnitAsync(Guid id, CancellationToken ct = default);

    Task<NamedMasterDto> CreateWorkLocationAsync(string name, CancellationToken ct = default);

    Task<NamedMasterDto> UpdateWorkLocationAsync(Guid id, string name, CancellationToken ct = default);

    Task DeleteWorkLocationAsync(Guid id, CancellationToken ct = default);

    Task<NamedMasterDto> CreateGraduationDegreeAsync(string name, CancellationToken ct = default);

    Task<NamedMasterDto> UpdateGraduationDegreeAsync(Guid id, string name, CancellationToken ct = default);

    Task DeleteGraduationDegreeAsync(Guid id, CancellationToken ct = default);

    Task<NamedMasterDto> CreatePostGraduationDegreeAsync(string name, CancellationToken ct = default);

    Task<NamedMasterDto> UpdatePostGraduationDegreeAsync(Guid id, string name, CancellationToken ct = default);

    Task DeletePostGraduationDegreeAsync(Guid id, CancellationToken ct = default);

    Task<NamedMasterDto> CreateCertificationAsync(string name, CancellationToken ct = default);

    Task<NamedMasterDto> UpdateCertificationAsync(Guid id, string name, CancellationToken ct = default);

    Task DeleteCertificationAsync(Guid id, CancellationToken ct = default);

    Task<AddressCityDto> CreateAddressCityAsync(string name, string? line, CancellationToken ct = default);

    Task<AddressCityDto> UpdateAddressCityAsync(Guid id, string name, string? line, CancellationToken ct = default);

    Task DeleteAddressCityAsync(Guid id, CancellationToken ct = default);
}
