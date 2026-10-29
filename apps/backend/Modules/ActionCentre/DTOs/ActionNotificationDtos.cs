using System.Text.Json.Serialization;

namespace PMS.API.Modules.ActionCentre.DTOs;

public class NotificationHistoryItemDto
{
    [JsonPropertyName("action")]
    public string Action { get; set; } = string.Empty;

    [JsonPropertyName("date")]
    public string Date { get; set; } = string.Empty;

    [JsonPropertyName("time")]
    public string Time { get; set; } = string.Empty;

    [JsonPropertyName("by")]
    public string By { get; set; } = string.Empty;
}

public class ActionNotificationDto
{
    public string Id { get; set; } = string.Empty;

    public string Title { get; set; } = string.Empty;

    public string Type { get; set; } = string.Empty;

    public string RelatedProject { get; set; } = string.Empty;

    public string? RelatedTask { get; set; }

    public string RaisedBy { get; set; } = string.Empty;

    public string CreatedAt { get; set; } = string.Empty;

    public string Status { get; set; } = "Pending";

    public string Priority { get; set; } = "Medium";

    public bool Unread { get; set; }

    public string? AcknowledgedBy { get; set; }

    public string? AcknowledgedDate { get; set; }

    public string? AcknowledgedTime { get; set; }

    public string CreatedBy { get; set; } = string.Empty;

    public string CreatedDate { get; set; } = string.Empty;

    public List<NotificationHistoryItemDto> History { get; set; } = [];

    public Guid ProjectId { get; set; }

    public Guid? IssueId { get; set; }
}

public class AcknowledgeNotificationRequest
{
    public string Comment { get; set; } = string.Empty;
}

public class NotificationQueryParameters
{
    public string? Status { get; set; }
    public string? Search { get; set; }
    public Guid? ProjectId { get; set; }
}

public class ActionAlertDto
{
    public string Id { get; set; } = string.Empty;

    public string AlertId { get; set; } = string.Empty;

    public string Title { get; set; } = string.Empty;

    public string? Description { get; set; }

    public string? ProjectId { get; set; }

    public string? ProjectName { get; set; }

    public string? CustomerId { get; set; }

    public string? CustomerName { get; set; }

    public string AlertType { get; set; } = "Issue";

    public string Priority { get; set; } = "Medium";

    public string Status { get; set; } = "Open";

    public Guid? RaisedByEmployeeId { get; set; }

    public string RaisedByName { get; set; } = string.Empty;

    public List<string> AudienceUserIds { get; set; } = [];

    public string CreatedAt { get; set; } = string.Empty;

    public string? Owner { get; set; }

    public string? ResolutionOwner { get; set; }

    public string? EscalationOwner { get; set; }

    public string? ResolutionDetails { get; set; }

    public List<NotificationHistoryItemDto> History { get; set; } = [];
}

public class UpdateAlertGovernanceRequest
{
    public string Status { get; set; } = "Open";

    public string? Owner { get; set; }

    public string? ResolutionOwner { get; set; }

    public string? EscalationOwner { get; set; }

    public string? ResolutionDetails { get; set; }

    public string? Comment { get; set; }
}
