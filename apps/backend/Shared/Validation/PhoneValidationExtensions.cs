using FluentValidation;

namespace PMS.API.Shared.Validation;

public static class PhoneValidationExtensions
{
    /// <summary>
    /// Optional phone: empty/whitespace is allowed. Pair with <c>NotEmpty()</c> when required.
    /// </summary>
    public static IRuleBuilderOptions<T, string?> MustBeValidIndianPhone<T>(
        this IRuleBuilder<T, string?> ruleBuilder)
    {
        return ruleBuilder
            .Must(v => string.IsNullOrWhiteSpace(v) || PhoneRules.IsValid(v))
            .WithMessage(PhoneRules.InvalidMessage);
    }
}
