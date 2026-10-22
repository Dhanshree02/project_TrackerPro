using FluentValidation;
using PMS.API.Modules.Projects.DTOs;

namespace PMS.API.Modules.Projects.Validators;

public sealed class CreateProjectExtensionRequestValidator : AbstractValidator<CreateProjectExtensionRequest>
{
    public CreateProjectExtensionRequestValidator()
    {
        RuleFor(x => x.RequestedEndDate).NotEmpty().WithMessage("Requested new end date is required");
        RuleFor(x => x.Reason).NotEmpty().WithMessage("Reason for extension is required");
        RuleFor(x => x.Reason).MaximumLength(2000).WithMessage("Reason cannot exceed 2000 characters");
        RuleFor(x => x.ApproverEmployeeIds)
            .NotEmpty()
            .WithMessage("Tag at least one approver");
    }
}
