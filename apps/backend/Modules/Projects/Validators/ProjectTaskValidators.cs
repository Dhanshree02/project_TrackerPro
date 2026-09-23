using FluentValidation;
using PMS.API.Modules.Projects.DTOs;

namespace PMS.API.Modules.Projects.Validators;

public static class TaskValidationRules
{
    public static readonly string[] ValidStages =
    [
        "Ready to Start",
        "Ongoing",
        "Completed",
        "On Hold (Internal)",
        "On Hold (Client End)",
        "After Release"
    ];

    public static readonly string[] ValidPriorities =
    [
        "low",
        "medium",
        "high",
        "critical"
    ];
}

public sealed class CreateProjectTaskValidator : AbstractValidator<CreateProjectTaskRequest>
{
    public CreateProjectTaskValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Task title is required")
            .MaximumLength(255).WithMessage("Task title cannot exceed 255 characters");

        RuleFor(x => x.Period)
            .MaximumLength(40);

        RuleFor(x => x.Phase)
            .MaximumLength(80);

        RuleFor(x => x.Stage)
            .Must(s => string.IsNullOrEmpty(s) || TaskValidationRules.ValidStages.Contains(s))
            .WithMessage($"Stage must be one of: {string.Join(", ", TaskValidationRules.ValidStages)}");

        RuleFor(x => x.Priority)
            .Must(p => string.IsNullOrEmpty(p) || TaskValidationRules.ValidPriorities.Contains(p.ToLowerInvariant()))
            .WithMessage($"Priority must be one of: {string.Join(", ", TaskValidationRules.ValidPriorities)}");

        RuleFor(x => x.EstimatedHours)
            .GreaterThanOrEqualTo(0).When(x => x.EstimatedHours.HasValue)
            .WithMessage("Estimated hours cannot be negative");
    }
}

public sealed class UpdateProjectTaskValidator : AbstractValidator<UpdateProjectTaskRequest>
{
    public UpdateProjectTaskValidator()
    {
        RuleFor(x => x.Title)
            .MaximumLength(255).When(x => x.Title != null);

        RuleFor(x => x.Period)
            .MaximumLength(40).When(x => x.Period != null);

        RuleFor(x => x.Phase)
            .MaximumLength(80).When(x => x.Phase != null);

        RuleFor(x => x.Stage)
            .Must(s => s == null || TaskValidationRules.ValidStages.Contains(s))
            .WithMessage($"Stage must be one of: {string.Join(", ", TaskValidationRules.ValidStages)}");

        RuleFor(x => x.Priority)
            .Must(p => p == null || TaskValidationRules.ValidPriorities.Contains(p.ToLowerInvariant()))
            .WithMessage($"Priority must be one of: {string.Join(", ", TaskValidationRules.ValidPriorities)}");

        RuleFor(x => x.EstimatedHours)
            .GreaterThanOrEqualTo(0).When(x => x.EstimatedHours.HasValue)
            .WithMessage("Estimated hours cannot be negative");

        RuleFor(x => x.UtilizedHours)
            .GreaterThanOrEqualTo(0).When(x => x.UtilizedHours.HasValue)
            .WithMessage("Utilized hours cannot be negative");

        RuleFor(x => x.Progress)
            .InclusiveBetween(0, 100).When(x => x.Progress.HasValue)
            .WithMessage("Progress must be between 0 and 100");
    }
}

public sealed class UpdateTaskStageValidator : AbstractValidator<UpdateTaskStageRequest>
{
    public UpdateTaskStageValidator()
    {
        RuleFor(x => x.Stage)
            .NotEmpty().WithMessage("Stage is required")
            .Must(s => TaskValidationRules.ValidStages.Contains(s))
            .WithMessage($"Stage must be one of: {string.Join(", ", TaskValidationRules.ValidStages)}");
    }
}
