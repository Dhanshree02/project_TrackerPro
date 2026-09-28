using FluentValidation;
using PMS.API.Modules.Projects.DTOs;

namespace PMS.API.Modules.Projects.Validators;

public static class TeamMemberValidationRules
{
    public static readonly string[] ValidBillabilities = ["Billable", "Non-Billable"];
    public static readonly string[] ValidResourceTypes = ["Dedicated", "Shared Resource"];
}

public sealed class CreateProjectTeamMemberValidator : AbstractValidator<CreateProjectTeamMemberRequest>
{
    public CreateProjectTeamMemberValidator()
    {
        RuleFor(x => x.EmployeeId).NotEmpty();
        RuleFor(x => x.AllocationEndDate)
            .GreaterThanOrEqualTo(x => x.AllocationStartDate)
            .WithMessage("Allocation end date must not be before start date.");
        RuleFor(x => x.Billability)
            .Must(b => TeamMemberValidationRules.ValidBillabilities.Contains(b))
            .WithMessage($"Billability must be one of: {string.Join(", ", TeamMemberValidationRules.ValidBillabilities)}");
        RuleFor(x => x.ResourceType)
            .Must(r => TeamMemberValidationRules.ValidResourceTypes.Contains(r))
            .WithMessage($"ResourceType must be one of: {string.Join(", ", TeamMemberValidationRules.ValidResourceTypes)}");
    }
}

public sealed class UpdateProjectTeamMemberValidator : AbstractValidator<UpdateProjectTeamMemberRequest>
{
    public UpdateProjectTeamMemberValidator()
    {
        RuleFor(x => x.Billability)
            .Must(b => b is null || TeamMemberValidationRules.ValidBillabilities.Contains(b))
            .WithMessage($"Billability must be one of: {string.Join(", ", TeamMemberValidationRules.ValidBillabilities)}");
        RuleFor(x => x.ResourceType)
            .Must(r => r is null || TeamMemberValidationRules.ValidResourceTypes.Contains(r))
            .WithMessage($"ResourceType must be one of: {string.Join(", ", TeamMemberValidationRules.ValidResourceTypes)}");
        RuleFor(x => x)
            .Must(x =>
            {
                if (x.AllocationStartDate is null || x.AllocationEndDate is null) return true;
                return x.AllocationEndDate >= x.AllocationStartDate;
            })
            .WithMessage("Allocation end date must not be before start date.");
    }
}
