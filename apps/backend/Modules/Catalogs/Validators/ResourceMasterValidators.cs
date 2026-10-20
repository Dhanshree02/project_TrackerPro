using FluentValidation;
using PMS.API.Modules.Catalogs.DTOs;

namespace PMS.API.Modules.Catalogs.Validators;

public sealed class UpsertNamedMasterRequestValidator : AbstractValidator<UpsertNamedMasterRequest>
{
    public UpsertNamedMasterRequestValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(200);
    }
}

public sealed class UpsertAddressCityRequestValidator : AbstractValidator<UpsertAddressCityRequest>
{
    public UpsertAddressCityRequestValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(200);
        RuleFor(x => x.Line).MaximumLength(80);
    }
}

public sealed class UpsertDepartmentHierarchyRequestValidator : AbstractValidator<UpsertDepartmentHierarchyRequest>
{
    public UpsertDepartmentHierarchyRequestValidator()
    {
        RuleFor(x => x.Department).NotEmpty().MaximumLength(150);
        RuleFor(x => x.Designation).NotEmpty().MaximumLength(150);
        RuleFor(x => x.SubDepartment).NotEmpty().MaximumLength(250);
        RuleFor(x => x.OnFloorRole).NotEmpty().MaximumLength(150);
        RuleFor(x => x.RbacRoleId).NotEmpty();
    }
}
