using FluentValidation;
using PMS.API.Modules.Projects.DTOs;

namespace PMS.API.Modules.Projects.Validators;

public sealed class CreateProjectDraftRequestValidator : AbstractValidator<CreateProjectDraftRequest>
{
    public CreateProjectDraftRequestValidator()
    {
        RuleFor(x => x.ProjectName)
            .NotEmpty().WithMessage("Project name is required")
            .MaximumLength(255);

        RuleFor(x => x.SavedByName)
            .NotEmpty().WithMessage("Saved by name is required")
            .MaximumLength(150);

        RuleFor(x => x.FormSnapshotJson)
            .NotEmpty().WithMessage("Form snapshot is required");
    }
}

public sealed class UpdateProjectDraftRequestValidator : AbstractValidator<UpdateProjectDraftRequest>
{
    public UpdateProjectDraftRequestValidator()
    {
        RuleFor(x => x.ProjectName)
            .NotEmpty().WithMessage("Project name is required")
            .MaximumLength(255);

        RuleFor(x => x.SavedByName)
            .NotEmpty().WithMessage("Saved by name is required")
            .MaximumLength(150);

        RuleFor(x => x.FormSnapshotJson)
            .NotEmpty().WithMessage("Form snapshot is required");
    }
}
