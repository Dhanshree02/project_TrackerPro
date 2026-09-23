using FluentValidation;
using PMS.API.Modules.Projects.DTOs;

namespace PMS.API.Modules.Projects.Validators;

public static class InvoiceValidationRules
{
    public static readonly string[] ValidStatuses =
    [
        "Pending",
        "Raised",
        "Paid",
        "Overdue",
        "Cancelled"
    ];
}

public sealed class CreateProjectInvoiceValidator : AbstractValidator<CreateProjectInvoiceRequest>
{
    public CreateProjectInvoiceValidator()
    {
        RuleFor(x => x.MilestoneName)
            .NotEmpty().WithMessage("Milestone name is required")
            .MaximumLength(255).WithMessage("Milestone name cannot exceed 255 characters");

        RuleFor(x => x.Percentage)
            .InclusiveBetween(0, 100).When(x => x.Percentage.HasValue)
            .WithMessage("Percentage must be between 0 and 100");

        RuleFor(x => x.Amount)
            .GreaterThanOrEqualTo(0).WithMessage("Amount cannot be negative");

        RuleFor(x => x.Status)
            .Must(s => string.IsNullOrEmpty(s) || InvoiceValidationRules.ValidStatuses.Contains(s))
            .WithMessage($"Status must be one of: {string.Join(", ", InvoiceValidationRules.ValidStatuses)}");

        RuleFor(x => x.InvoiceNumber)
            .MaximumLength(80);
    }
}

public sealed class UpdateProjectInvoiceValidator : AbstractValidator<UpdateProjectInvoiceRequest>
{
    public UpdateProjectInvoiceValidator()
    {
        RuleFor(x => x.MilestoneName)
            .MaximumLength(255).When(x => x.MilestoneName != null);

        RuleFor(x => x.Percentage)
            .InclusiveBetween(0, 100).When(x => x.Percentage.HasValue)
            .WithMessage("Percentage must be between 0 and 100");

        RuleFor(x => x.Amount)
            .GreaterThanOrEqualTo(0).When(x => x.Amount.HasValue)
            .WithMessage("Amount cannot be negative");

        RuleFor(x => x.Status)
            .Must(s => s == null || InvoiceValidationRules.ValidStatuses.Contains(s))
            .WithMessage($"Status must be one of: {string.Join(", ", InvoiceValidationRules.ValidStatuses)}");

        RuleFor(x => x.InvoiceNumber)
            .MaximumLength(80).When(x => x.InvoiceNumber != null);
    }
}
