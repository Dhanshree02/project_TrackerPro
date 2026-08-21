using FluentValidation;

namespace PMS.API.Shared.Validation;

public static class EmailValidationExtensions
{
    public static IRuleBuilderOptions<T, string> MustBeValidEmail<T>(
        this IRuleBuilder<T, string> ruleBuilder)
    {
        return ruleBuilder
            .Must(EmailRules.IsValid)
            .WithMessage(EmailRules.InvalidMessage);
    }

    public static IRuleBuilderOptions<T, string?> MustBeValidEmail<T>(
        this IRuleBuilder<T, string?> ruleBuilder)
    {
        return ruleBuilder
            .Must(v => string.IsNullOrWhiteSpace(v) || EmailRules.IsValid(v))
            .WithMessage(EmailRules.InvalidMessage);
    }
}
