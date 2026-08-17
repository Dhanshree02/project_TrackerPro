using FluentValidation;
using PMS.API.Modules.Auth.DTOs;

namespace PMS.API.Modules.Auth.Validators;

public sealed class ChangePasswordRequestValidator : AbstractValidator<ChangePasswordRequest>
{
    public ChangePasswordRequestValidator()
    {
        RuleFor(x => x.CurrentPassword).NotEmpty();
        RuleFor(x => x.NewPassword)
            .NotEmpty()
            .MinimumLength(8)
            .MaximumLength(128)
            .Matches("[A-Z]").WithMessage("New password must contain an uppercase letter.")
            .Matches("[a-z]").WithMessage("New password must contain a lowercase letter.")
            .Matches("[0-9]").WithMessage("New password must contain a digit.")
            .NotEqual(x => x.CurrentPassword).WithMessage("New password must differ from the current password.");
    }
}
