using FluentValidation;
using PMS.API.Modules.Auth.DTOs;
using PMS.API.Shared.Validation;

namespace PMS.API.Modules.Auth.Validators;

public sealed class LoginRequestValidator : AbstractValidator<LoginRequest>
{
    public LoginRequestValidator()
    {
        RuleFor(x => x.Email)
            .Cascade(CascadeMode.Stop)
            .NotEmpty()
            .MustBeValidEmail()
            .MaximumLength(EmailRules.MaxLength);
        RuleFor(x => x.Password).NotEmpty().MaximumLength(128);
    }
}
