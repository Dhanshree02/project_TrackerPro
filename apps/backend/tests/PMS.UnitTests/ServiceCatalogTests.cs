using PMS.API.Modules.Catalogs.DTOs;
using PMS.API.Modules.Projects.Models;

namespace PMS.UnitTests;

public class ServiceCatalogTests
{
    [Fact]
    public void ServiceHierarchy_DtoStructure_CanBeConstructed()
    {
        var service = new ServiceHierarchyItemDto(
            Id: Guid.NewGuid(),
            Code: "PT001",
            Name: "External Network Penetration Testing",
            DefaultTools: "Nessus, Metasploit",
            DefaultUnitPrice: 60000m,
            DefaultDurationDays: 5,
            Description: "Testing network perimeter",
            SortOrder: 1);

        var subDept = new ServiceHierarchySubDeptDto(
            Id: Guid.NewGuid(),
            Code: "SUB_NET_PT",
            Name: "Network Penetration Testing",
            SortOrder: 1,
            Services: [service]);

        var dept = new ServiceHierarchyDeptDto(
            Id: Guid.NewGuid(),
            Code: "PEN_TESTING",
            Name: "Penetration Testing",
            GroupCode: "SCOPE",
            GroupName: "Scope",
            SortOrder: 1,
            SubDepartments: [subDept]);

        var group = new ServiceHierarchyGroupDto(
            Id: Guid.NewGuid(),
            Code: "SCOPE",
            Name: "Scope",
            SortOrder: 1,
            Departments: [dept]);

        Assert.Equal("SCOPE", group.Code);
        Assert.Single(group.Departments);
        Assert.Equal("PEN_TESTING", group.Departments[0].Code);
        Assert.Single(group.Departments[0].SubDepartments);
        Assert.Equal("SUB_NET_PT", group.Departments[0].SubDepartments[0].Code);
        Assert.Single(group.Departments[0].SubDepartments[0].Services);
        Assert.Equal("PT001", group.Departments[0].SubDepartments[0].Services[0].Code);
    }

    [Fact]
    public void MstServiceGroup_Initializes_EmptyDepartments()
    {
        var group = new MstServiceGroup
        {
            Code = "RESOURCE",
            Name = "Resource",
            IsActive = true
        };

        Assert.NotNull(group.Departments);
        Assert.Empty(group.Departments);
        Assert.NotEqual(Guid.Empty, group.Id);
    }
}
