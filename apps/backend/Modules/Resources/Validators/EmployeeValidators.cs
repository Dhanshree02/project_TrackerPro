using FluentValidation;
using PMS.API.Modules.Resources.DTOs;
using PMS.API.Shared.Validation;

namespace PMS.API.Modules.Resources.Validators;

public sealed class CreateEmployeeRequestValidator : AbstractValidator<CreateEmployeeRequest>
{
    public CreateEmployeeRequestValidator()
    {
        RuleFor(x => x.EmployeeCode).NotEmpty().MaximumLength(20);
        RuleFor(x => x.FirstName)
            .NotEmpty()
            .MaximumLength(120)
            .Matches(@"^[A-Za-z]+(?:['\s\-][A-Za-z]+)*$")
            .WithMessage("Only letters, spaces, hyphens, and apostrophes are allowed");
        RuleFor(x => x.LastName)
            .NotEmpty()
            .MaximumLength(120)
            .Matches(@"^[A-Za-z]+(?:['\s\-][A-Za-z]+)*$")
            .WithMessage("Only letters, spaces, hyphens, and apostrophes are allowed");
        RuleFor(x => x.WorkEmail)
            .Cascade(CascadeMode.Stop)
            .NotEmpty()
            .MustBeValidEmail()
            .MaximumLength(EmailRules.MaxLength);
        RuleFor(x => x.PersonalEmail)
            .MustBeValidEmail()
            .When(x => !string.IsNullOrWhiteSpace(x.PersonalEmail))
            .MaximumLength(EmailRules.MaxLength);
        RuleFor(x => x.Phone)
            .MustBeValidIndianPhone()
            .When(x => !string.IsNullOrWhiteSpace(x.Phone));
        RuleFor(x => x.AltPhone)
            .MustBeValidIndianPhone()
            .When(x => !string.IsNullOrWhiteSpace(x.AltPhone));
        RuleFor(x => x.DateOfBirth)
            .Must(d => !d.HasValue || d.Value <= DateOnly.FromDateTime(DateTime.UtcNow.Date.AddYears(-18)))
            .WithMessage("Employee must be at least 18 years old");
        RuleFor(x => x.JoiningDate)
            .Must(d => !d.HasValue || d.Value >= TodayInIst())
            .WithMessage("Date of joining must be today or a future date");
        RuleForEach(x => x.Skills).MaximumLength(120);
        RuleForEach(x => x.Certifications).MaximumLength(120);
        RuleForEach(x => x.Languages).MaximumLength(120);
        RuleFor(x => x.Aadhaar)
            .Matches(@"^\d{12}$")
            .When(x => !string.IsNullOrWhiteSpace(x.Aadhaar))
            .WithMessage("Aadhaar must be a 12-digit number");
        RuleFor(x => x.PfUan)
            .Matches(@"^\d{12}$")
            .When(x => !string.IsNullOrWhiteSpace(x.PfUan))
            .WithMessage("UAN must be a 12-digit number");
    }

    private static DateOnly TodayInIst()
    {
        TimeZoneInfo tz;
        try
        {
            tz = TimeZoneInfo.FindSystemTimeZoneById("India Standard Time");
        }
        catch (TimeZoneNotFoundException)
        {
            tz = TimeZoneInfo.FindSystemTimeZoneById("Asia/Kolkata");
        }

        return DateOnly.FromDateTime(TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, tz));
    }
}

public sealed class UpdateEmployeeRequestValidator : AbstractValidator<UpdateEmployeeRequest>
{
    public UpdateEmployeeRequestValidator()
    {
        RuleFor(x => x.FirstName)
            .NotEmpty()
            .When(x => x.FirstName is not null)
            .MaximumLength(120)
            .Matches(@"^[A-Za-z]+(?:['\s\-][A-Za-z]+)*$")
            .When(x => !string.IsNullOrWhiteSpace(x.FirstName))
            .WithMessage("Only letters, spaces, hyphens, and apostrophes are allowed");
        RuleFor(x => x.LastName)
            .NotEmpty()
            .When(x => x.LastName is not null)
            .MaximumLength(120)
            .Matches(@"^[A-Za-z]+(?:['\s\-][A-Za-z]+)*$")
            .When(x => !string.IsNullOrWhiteSpace(x.LastName))
            .WithMessage("Only letters, spaces, hyphens, and apostrophes are allowed");
        RuleFor(x => x.WorkEmail)
            .MustBeValidEmail()
            .When(x => !string.IsNullOrWhiteSpace(x.WorkEmail))
            .MaximumLength(EmailRules.MaxLength);
        RuleFor(x => x.PersonalEmail)
            .MustBeValidEmail()
            .When(x => !string.IsNullOrWhiteSpace(x.PersonalEmail))
            .MaximumLength(EmailRules.MaxLength);
        RuleFor(x => x.Phone)
            .MustBeValidIndianPhone()
            .When(x => !string.IsNullOrWhiteSpace(x.Phone));
        RuleFor(x => x.AltPhone)
            .MustBeValidIndianPhone()
            .When(x => !string.IsNullOrWhiteSpace(x.AltPhone));
        RuleFor(x => x.DateOfBirth)
            .Must(d => !d.HasValue || d.Value <= DateOnly.FromDateTime(DateTime.UtcNow.Date.AddYears(-18)))
            .WithMessage("Employee must be at least 18 years old");
        RuleForEach(x => x.Skills).MaximumLength(120);
        RuleForEach(x => x.Certifications).MaximumLength(120);
        RuleForEach(x => x.Languages).MaximumLength(120);
        RuleFor(x => x.Aadhaar)
            .Matches(@"^\d{12}$")
            .When(x => !string.IsNullOrWhiteSpace(x.Aadhaar))
            .WithMessage("Aadhaar must be a 12-digit number");
        RuleFor(x => x.PfUan)
            .Matches(@"^\d{12}$")
            .When(x => !string.IsNullOrWhiteSpace(x.PfUan))
            .WithMessage("UAN must be a 12-digit number");
    }
}

public sealed class OffboardEmployeeRequestValidator : AbstractValidator<OffboardEmployeeRequest>
{
    public OffboardEmployeeRequestValidator()
    {
        RuleFor(x => x.LastWorkingDay).NotNull();
        RuleFor(x => x.ReasonForLeaving).MaximumLength(500);
        RuleFor(x => x.NoticePeriodServed).MaximumLength(80);
        RuleFor(x => x.ExitType).MaximumLength(80);
        RuleFor(x => x.ExitReason).MaximumLength(500);
    }
}

public sealed class CreateCatalogItemRequestValidator : AbstractValidator<CreateCatalogItemRequest>
{
    public CreateCatalogItemRequestValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(150);
    }
}
