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

        RuleForEach(x => x.ResourceLevels).ChildRules(level =>
        {
            level.RuleFor(l => l.Level).NotEmpty().MaximumLength(20);
            level.RuleFor(l => l.Count).GreaterThanOrEqualTo(0);
        });

        RuleFor(x => x)
            .Must(x => x.ResourceLevels == null || x.ResourceLevels.Count == 0 || x.ResourceLevels.Sum(l => l.Count) == x.Qty)
            .WithMessage("Sum of resource level distribution counts must equal the service Quantity");
    }
}

public sealed class SetResourceLevelsValidator : AbstractValidator<SetResourceLevelsRequest>
{
    public SetResourceLevelsValidator()
    {
        RuleFor(x => x.Levels)
            .NotNull().WithMessage("Resource levels list cannot be null");

        RuleForEach(x => x.Levels).ChildRules(level =>
        {
            level.RuleFor(l => l.Level).NotEmpty().MaximumLength(20);
            level.RuleFor(l => l.Count).GreaterThanOrEqualTo(0);
        });
    }
}
