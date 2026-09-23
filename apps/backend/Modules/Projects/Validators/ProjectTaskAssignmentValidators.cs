using FluentValidation;
using PMS.API.Modules.Projects.DTOs;

namespace PMS.API.Modules.Projects.Validators;

public sealed class AssignTaskResourceValidator : AbstractValidator<AssignTaskResourceRequest>
{
    public AssignTaskResourceValidator()
    {
        RuleFor(x => x.EmployeeId)
            .NotEmpty().WithMessage("Employee ID is required");

        RuleFor(x => x.Role)
            .MaximumLength(50).WithMessage("Role cannot exceed 50 characters");

        RuleFor(x => x.AllocatedHours)
            .GreaterThanOrEqualTo(0).When(x => x.AllocatedHours.HasValue)
            .WithMessage("Allocated hours cannot be negative");
    }
}

public sealed class UpdateTaskAssignmentValidator : AbstractValidator<UpdateTaskAssignmentRequest>
{
    public UpdateTaskAssignmentValidator()
    {
        RuleFor(x => x.Role)
            .MaximumLength(50).When(x => x.Role != null)
            .WithMessage("Role cannot exceed 50 characters");

        RuleFor(x => x.AllocatedHours)
            .GreaterThanOrEqualTo(0).When(x => x.AllocatedHours.HasValue)
            .WithMessage("Allocated hours cannot be negative");

        RuleFor(x => x.UtilizedHours)
            .GreaterThanOrEqualTo(0).When(x => x.UtilizedHours.HasValue)
            .WithMessage("Utilized hours cannot be negative");
    }
}
