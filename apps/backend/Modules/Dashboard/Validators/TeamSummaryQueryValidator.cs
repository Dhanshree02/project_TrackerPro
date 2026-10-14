using FluentValidation;
using PMS.API.Modules.Dashboard.DTOs;
using PMS.API.Modules.Dashboard.Services;

namespace PMS.API.Modules.Dashboard.Validators;

public sealed class TeamSummaryQueryValidator : AbstractValidator<TeamSummaryQuery>
{
    public TeamSummaryQueryValidator()
    {
        RuleFor(x => x.Quarter)
            .Must(q => string.IsNullOrWhiteSpace(q) || FinancialQuarter.IsValid(q))
            .WithMessage("Quarter must be Q1, Q2, Q3, or Q4.");

        RuleFor(x => x.FinancialYear)
            .Must(y => y is null or >= 2000 and <= 2100)
            .WithMessage("Financial year must be between 2000 and 2100.");
    }
}
