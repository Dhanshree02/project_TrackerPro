using FluentValidation;
using PMS.API.Modules.Projects.DTOs;

namespace PMS.API.Modules.Projects.Validators;

public static class InterviewValidationRules
{
    public static readonly string[] Results = ["Pending", "Selected", "Rejected", "Postponed"];
}

public sealed class CreateProjectInterviewValidator : AbstractValidator<CreateProjectInterviewRequest>
{
    public CreateProjectInterviewValidator()
    {
        RuleFor(x => x.EmployeeId).NotEmpty().WithMessage("Resource name is required");
        RuleFor(x => x.InterviewDate).NotEmpty().WithMessage("Interview date is required");
    }
}

public sealed class UpdateProjectInterviewValidator : AbstractValidator<UpdateProjectInterviewRequest>
{
    public UpdateProjectInterviewValidator()
    {
        RuleFor(x => x.Result)
            .Must(r => r is null || InterviewValidationRules.Results.Contains(r))
            .WithMessage("Interview result must be Pending, Selected, Rejected, or Postponed");

        RuleFor(x => x.Comments)
            .MaximumLength(2000)
            .WithMessage("Comments cannot exceed 2000 characters");

        RuleFor(x => x)
            .Must(x => x.Result is not "Postponed" || !string.IsNullOrWhiteSpace(x.Comments))
            .When(x => x.Result is not null)
            .WithMessage("Add a comment when the interview is postponed");
    }
}
