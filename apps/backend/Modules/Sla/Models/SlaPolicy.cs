using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Sla.Models;

/// <summary>
/// Defines TAT and SLA deadline policies, reminder cadences, and escalation paths
/// per module, activity type, and activity stage.
/// </summary>
public class SlaPolicy : BaseEntity
{
    public string Module { get; set; } = string.Empty;

    public string ActivityType { get; set; } = string.Empty;

    /// <summary>
    /// Specific workflow stage (e.g. "PendingApproval", "InProgress", "Review") or "Default".
    /// </summary>
    public string Stage { get; set; } = "Default";

    public string Name { get; set; } = string.Empty;

    public string? Description { get; set; }

    /// <summary>
    /// Target Turnaround Time (TAT) duration in minutes.
    /// </summary>
    public int TatDurationMinutes { get; set; }

    public SlaCalculationMode CalculationMode { get; set; } = SlaCalculationMode.WorkingHours;

    public TimeSpan? WorkingHoursStart { get; set; } = new TimeSpan(9, 0, 0);

    public TimeSpan? WorkingHoursEnd { get; set; } = new TimeSpan(18, 0, 0);

    public bool ExcludeWeekends { get; set; } = true;

    public bool ExcludeHolidays { get; set; } = true;

    /// <summary>
    /// Serialized JSON array of minutes before deadline when reminders fire, e.g. [120, 60, 15].
    /// </summary>
    public string ReminderIntervalsMinutesJson { get; set; } = "[]";

    /// <summary>
    /// Minutes after target deadline to trigger Level 1 escalation.
    /// </summary>
    public int? FirstEscalationAfterMinutes { get; set; } = 60;

    /// <summary>
    /// Minutes after target deadline to trigger Level 2 escalation.
    /// </summary>
    public int? SecondEscalationAfterMinutes { get; set; } = 180;

    /// <summary>
    /// Roles responsible for actioning the activity before breach (JSON array).
    /// </summary>
    public string ResponsibleRolesJson { get; set; } = "[]";

    /// <summary>
    /// Roles notified upon Level 1 escalation (JSON array).
    /// </summary>
    public string FirstEscalationRolesJson { get; set; } = "[]";

    /// <summary>
    /// Roles notified upon Level 2 escalation (JSON array).
    /// </summary>
    public string SecondEscalationRolesJson { get; set; } = "[]";

    public bool IsActive { get; set; } = true;

    public string MetadataJson { get; set; } = "{}";

    public virtual ICollection<SlaInstance> Instances { get; set; } = new List<SlaInstance>();

    // Helper accessors for JSON collections
    [NotMapped]
    public IReadOnlyList<int> ReminderIntervals
    {
        get => DeserializeList<int>(ReminderIntervalsMinutesJson);
        set => ReminderIntervalsMinutesJson = JsonSerializer.Serialize(value ?? []);
    }

    [NotMapped]
    public IReadOnlyList<string> ResponsibleRoles
    {
        get => DeserializeList<string>(ResponsibleRolesJson);
        set => ResponsibleRolesJson = JsonSerializer.Serialize(value ?? []);
    }

    [NotMapped]
    public IReadOnlyList<string> FirstEscalationRoles
    {
        get => DeserializeList<string>(FirstEscalationRolesJson);
        set => FirstEscalationRolesJson = JsonSerializer.Serialize(value ?? []);
    }

    [NotMapped]
    public IReadOnlyList<string> SecondEscalationRoles
    {
        get => DeserializeList<string>(SecondEscalationRolesJson);
        set => SecondEscalationRolesJson = JsonSerializer.Serialize(value ?? []);
    }

    private static List<T> DeserializeList<T>(string json)
    {
        if (string.IsNullOrWhiteSpace(json)) return [];
        try
        {
            return JsonSerializer.Deserialize<List<T>>(json) ?? [];
        }
        catch
        {
            return [];
        }
    }
}
