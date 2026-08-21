using FluentValidation;

namespace PMS.API.Shared.Validation;

public static class EmailValidationExtensions
{
    /// <summary>
    /// Optional emails: empty/whitespace is allowed. Pair with <c>NotEmpty()</c> when required.
    /// </summary>
    public static IRuleBuilderOptions<T, string?> MustBeValidEmail<T>(
        this IRuleBuilder<T, string?> ruleBuilder)
    {
        return ruleBuilder
            .Must(v => string.IsNullOrWhiteSpace(v) || EmailRules.IsValid(v))
            .WithMessage(EmailRules.InvalidMessage);
    }
}
