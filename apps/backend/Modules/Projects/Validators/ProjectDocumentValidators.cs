using FluentValidation;
using PMS.API.Modules.Projects.DTOs;

namespace PMS.API.Modules.Projects.Validators;

public static class DocumentValidationRules
{
    public static readonly string[] ValidDocumentTypes =
    [
        "PO",
        "SOW",
        "Proposal",
        "Signed Contract",
        "NDA",
        "Other"
    ];
}

public sealed class UploadProjectDocumentValidator : AbstractValidator<UploadProjectDocumentRequest>
{
    public UploadProjectDocumentValidator()
    {
        RuleFor(x => x.DocumentType)
            .Must(t => string.IsNullOrEmpty(t) || DocumentValidationRules.ValidDocumentTypes.Contains(t))
            .WithMessage($"DocumentType must be one of: {string.Join(", ", DocumentValidationRules.ValidDocumentTypes)}");

        RuleFor(x => x.Description)
            .MaximumLength(1000).When(x => x.Description != null);
    }
}
