using FluentValidation;
using PMS.API.Modules.Projects.DTOs;

namespace PMS.API.Modules.Projects.Validators;

public sealed class CreateProjectServiceValidator : AbstractValidator<CreateProjectServiceRequest>
{
    public CreateProjectServiceValidator()
    {
        RuleFor(x => x.Qty)
            .GreaterThan(0).WithMessage("Quantity must be at least 1");

        RuleFor(x => x.Department)
            .MaximumLength(150);

        RuleFor(x => x.ServiceName)
            .MaximumLength(255);

        RuleFor(x => x.ResourceLevel)
            .MaximumLength(80);

        RuleFor(x => x.Frequency)
            .MaximumLength(40);

        RuleFor(x => x.Location)
            .MaximumLength(40);

        RuleFor(x => x.ServiceModel)
            .MaximumLength(40);

        RuleFor(x => x.DeliveryModel)
            .MaximumLength(80);

        RuleFor(x => x.Tools)
            .MaximumLength(500);
    }
}
