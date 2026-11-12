namespace PMS.API.Modules.Sla.Models;

/// <summary>
/// Mode used to calculate deadlines and TAT intervals.
/// </summary>
public enum SlaCalculationMode
{
    /// <summary>Continuous calendar time (24x7).</summary>
    CalendarHours,

    /// <summary>Operating business hours only (e.g. 09:00 - 18:00, excluding non-working days).</summary>
    WorkingHours,

    /// <summary>End-Of-Day deadline on the target working day (e.g. 18:00:00 or 23:59:59).</summary>
    EndOfDay
}

/// <summary>
/// Lifecycle status of an SLA tracking instance.
/// </summary>
public enum SlaInstanceStatus
{
    /// <summary>Active and counting towards target deadline.</summary>
    Tracking,

    /// <summary>Temporarily paused (e.g. awaiting customer info or dependency).</summary>
    Paused,

    /// <summary>Activity successfully finished within or after deadline.</summary>
    Completed,

    /// <summary>Deadline passed without completion; active escalation in progress.</summary>
    Breached,

    /// <summary>Activity or request cancelled/discarded; tracking aborted.</summary>
    Cancelled
}

/// <summary>
/// Type of event or scheduled milestone within an SLA instance.
/// </summary>
public enum SlaEventType
{
    Reminder,
    Warning,
    BreachCheck,
    EscalationL1,
    EscalationL2,
    StageTransition,
    Paused,
    Resumed,
    Completed,
    Cancelled
}

/// <summary>
/// Status of an SLA event execution.
/// </summary>
public enum SlaEventStatus
{
    Scheduled,
    Executing,
    Executed,
    Skipped,
    Cancelled,
    Failed
}

/// <summary>
/// SLA Priority levels.
/// </summary>
public enum SlaPriority
{
    Low,
    Medium,
    High,
    Critical
}
