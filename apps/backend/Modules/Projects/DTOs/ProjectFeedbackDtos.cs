namespace PMS.API.Modules.Projects.DTOs;

public sealed record ProjectFeedbackDto(
    Guid Id,
    Guid ProjectId,
    string? ProjectName,
    Guid EmployeeId,
    string EmployeeName,
    string? EmployeeCode,
    Guid? ReportingManagerId,
    string? ReportingManagerName,
    Guid? SubmittedByEmployeeId,
    string SubmittedByName,
    string FeedbackType,
    string? Strengths,
    string? AreasOfImprovement,
    string? Comments,
    int? Rating,
    string? RequestNote,
    string Status,
    string? CommentsJson,
    string? HistoryJson,
    DateTime CreatedAtUtc
);

public sealed record CreateProjectFeedbackRequest(
    Guid EmployeeId,
    string? Strengths = null,
    string? AreasOfImprovement = null,
    string? Comments = null,
    int? Rating = null,
    string? FeedbackType = "DirectFeedback",
    string? RequestNote = null
);

public sealed record FeedbackApprovalActionRequest(
    string Status,
    string? Comment = null
);
