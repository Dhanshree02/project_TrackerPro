using FluentValidation;
using PMS.API.Modules.Customers.DTOs;
using PMS.API.Shared.Validation;

namespace PMS.API.Modules.Customers.Validators;

public sealed class CreateClientRequestValidator : AbstractValidator<CreateClientRequest>
{
    public CreateClientRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Client name is required")
            .MaximumLength(255);

        RuleFor(x => x.Industry)
            .NotEmpty().WithMessage("Industry is required")
            .MaximumLength(100);

        RuleFor(x => x.ContactEmail)
            .MustBeValidEmail()
            .When(x => !string.IsNullOrWhiteSpace(x.ContactEmail))
            .MaximumLength(EmailRules.MaxLength);

        RuleFor(x => x.EngagementManager).MaximumLength(120);

        RuleFor(x => x.ClientType)
            .Must(t => t is null || t is "NEW" or "OLD")
            .WithMessage("ClientType must be NEW or OLD");

        RuleFor(x => x.SubVentures).Must(s => s is null || s.Count <= 20)
            .WithMessage("At most 20 sub-ventures per client");

        RuleForEach(x => x.SubVentures).ChildRules(sv =>
        {
            sv.RuleFor(s => s.Name).NotEmpty().MaximumLength(255);
            sv.RuleForEach(s => s.Contacts).ChildRules(contact =>
            {
                contact.RuleFor(c => c.Email)
                    .MustBeValidEmail()
                    .When(c => !string.IsNullOrWhiteSpace(c.Email))
                    .MaximumLength(EmailRules.MaxLength);
                contact.RuleFor(c => c.Name).MaximumLength(150);
            });
        });

        RuleForEach(x => x.Contacts).ChildRules(contact =>
        {
            contact.RuleFor(c => c.Email)
                .MustBeValidEmail()
                .When(c => !string.IsNullOrWhiteSpace(c.Email))
                .MaximumLength(EmailRules.MaxLength);
            contact.RuleFor(c => c.Name).MaximumLength(150);
        });
    }
}

public sealed class UpdateClientRequestValidator : AbstractValidator<UpdateClientRequest>
{
    public UpdateClientRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().When(x => x.Name is not null)
            .MaximumLength(255);
        RuleFor(x => x.Industry)
            .NotEmpty().When(x => x.Industry is not null)
            .MaximumLength(100);
        RuleFor(x => x.ContactEmail)
            .MustBeValidEmail()
            .When(x => !string.IsNullOrWhiteSpace(x.ContactEmail));
        RuleFor(x => x.Status)
            .Must(s => s is null or "Active" or "Inactive" or "Onboarding")
            .WithMessage("Status must be Active, Inactive or Onboarding");
    }
}
