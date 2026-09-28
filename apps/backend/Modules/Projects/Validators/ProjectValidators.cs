using FluentValidation;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Shared.Validation;

namespace PMS.API.Modules.Projects.Validators;

public sealed class CreateProjectRequestValidator : AbstractValidator<CreateProjectRequest>
{
    public CreateProjectRequestValidator()
    {
        RuleFor(x => x.ClientId)
            .NotEmpty().WithMessage("ClientId is required");

        RuleFor(x => x.Name)
            .MaximumLength(255);

        RuleFor(x => x.Currency)
            .MaximumLength(10);

        RuleFor(x => x.ContractType)
            .MaximumLength(80);

        RuleFor(x => x.ProjectType)
            .MaximumLength(80);

        RuleFor(x => x.Status)
            .Must(s => string.IsNullOrWhiteSpace(s) || s is "ongoing" or "completed" or "on_hold" or "archived" or "Draft")
            .WithMessage("Status must be ongoing, completed, on_hold, archived, or Draft");

        RuleFor(x => x.Health)
            .Must(h => string.IsNullOrWhiteSpace(h) || h is "green" or "amber" or "red")
            .WithMessage("Health must be green, amber, or red");

        RuleFor(x => x.WbsStatus)
            .Must(w => string.IsNullOrWhiteSpace(w) || w is "draft" or "approval_pending" or "ph_approved" or "accounts_approved" or "approved" or "started" or "assigned")
            .WithMessage("WbsStatus must be draft, approval_pending, ph_approved, accounts_approved, approved, started, or assigned");

        RuleFor(x => x.AccountContactEmail)
            .MustBeValidEmail()
            .When(x => !string.IsNullOrWhiteSpace(x.AccountContactEmail));

        RuleFor(x => x.AccountContactPhone)
            .MustBeValidIndianPhone()
            .When(x => !string.IsNullOrWhiteSpace(x.AccountContactPhone));
    }
}

public sealed class UpdateProjectRequestValidator : AbstractValidator<UpdateProjectRequest>
{
    public UpdateProjectRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Name cannot be empty")
            .MaximumLength(255);

        RuleFor(x => x.Status)
            .Must(s => string.IsNullOrWhiteSpace(s) || s is "ongoing" or "completed" or "on_hold" or "archived" or "Draft")
            .WithMessage("Status must be ongoing, completed, on_hold, archived, or Draft");

        RuleFor(x => x.Health)
            .Must(h => string.IsNullOrWhiteSpace(h) || h is "green" or "amber" or "red")
            .WithMessage("Health must be green, amber, or red");

        RuleFor(x => x.Progress)
            .InclusiveBetween(0, 100)
            .When(x => x.Progress.HasValue);

        RuleFor(x => x.AccountContactEmail)
            .MustBeValidEmail()
            .When(x => !string.IsNullOrWhiteSpace(x.AccountContactEmail));

        RuleFor(x => x.AccountContactPhone)
            .MustBeValidIndianPhone()
            .When(x => !string.IsNullOrWhiteSpace(x.AccountContactPhone));
    }
}
