namespace PMS.API.Modules.Projects.DTOs;

public record ProjectAdditionalRequirementDto(
    Guid Id,
    string RequirementId,
    Guid ProjectId,
    string? ClientName,
    string? ProjectName,
    string RequirementType,
    string Title,
    string Description,
    string Priority,
    Guid? RequestedByEmployeeId,
    string RequestedByName,
    string RequestedDate,
    string? AttachmentFileName,
    string? AttachmentPath,
    string? ScopeCancellationService,
    string Status,
    DateTime? ApprovedAtUtc,
    Guid? ApprovedByEmployeeId,
    string? ApprovedByName,
    string? ApprovalComments,
    string CommentsJson,
    string HistoryJson,
    DateTime CreatedAtUtc
);

public class CreateProjectAdditionalRequirementRequest
{
    public string RequirementType { get; set; } = "Add Service"; // "Add Service" or "Scope Cancellation"

    public string Title { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;

    public string Priority { get; set; } = "Medium";

    public string? RequestedDate { get; set; }

    public string? ScopeCancellationService { get; set; }

    public IFormFile? AttachmentFile { get; set; }
}

public class ApproveAdditionalRequirementRequest
{
    public string Comment { get; set; } = string.Empty;
}

public class RejectAdditionalRequirementRequest
{
    public string Comment { get; set; } = string.Empty;
}
