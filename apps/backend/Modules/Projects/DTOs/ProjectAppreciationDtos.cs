namespace PMS.API.Modules.Projects.DTOs;

public record ProjectAppreciationDto(
    Guid Id,
    Guid ProjectId,
    Guid RecipientEmployeeId,
    string RecipientName,
    string? RecipientEmail,
    string? RecipientRole,
    string Badge,
    string Message,
    Guid? GivenByEmployeeId,
    string GivenByName,
    DateTime CreatedAtUtc);

public record CreateProjectAppreciationRequest(
    Guid RecipientEmployeeId,
    string Badge,
    string Message);
