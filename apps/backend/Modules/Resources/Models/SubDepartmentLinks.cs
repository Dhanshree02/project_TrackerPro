namespace PMS.API.Modules.Resources.Models;

/// <summary>Designation → one or more sub-department ids.</summary>
public class MstDesignationSubDepartment
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid DesignationId { get; set; }

    public MstDesignation? Designation { get; set; }

    public Guid SubDepartmentId { get; set; }

    public MstSubDepartment? SubDepartment { get; set; }
}

/// <summary>Org role map → sub-department ids.</summary>
public class MstOrgRoleSubDepartment
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid OrgRoleMapId { get; set; }

    public MstOrgRoleMap? OrgRoleMap { get; set; }

    public Guid SubDepartmentId { get; set; }

    public MstSubDepartment? SubDepartment { get; set; }
}

/// <summary>On-floor role row → sub-department ids.</summary>
public class OnFloorRoleSubDepartment
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid OnFloorRoleId { get; set; }

    public OnFloorRole? OnFloorRole { get; set; }

    public Guid SubDepartmentId { get; set; }

    public MstSubDepartment? SubDepartment { get; set; }
}
