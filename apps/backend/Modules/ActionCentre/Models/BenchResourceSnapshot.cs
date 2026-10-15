namespace PMS.API.Modules.ActionCentre.Models;

/// <summary>
/// Stores historical snapshots of daily on-bench resources at 10:30 AM, 2:30 PM, and 6:30 PM
/// per TK PMS Tool BRD V05 Page 5 & 8.
/// </summary>
public class BenchResourceSnapshot
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public DateOnly SnapshotDate { get; set; }

    /// <summary>
    /// Time slot label: "10:30 AM", "02:30 PM", "06:30 PM"
    /// </summary>
    public string TimeSlot { get; set; } = string.Empty;

    public int TotalBenchCount { get; set; }

    public int BillableCount { get; set; }

    public int NonBillableCount { get; set; }

    /// <summary>
    /// JSON serialized department-wise breakdown: { "Development": 5, "QA": 2, ... }
    /// </summary>
    public string DepartmentBreakdownJson { get; set; } = "{}";

    /// <summary>
    /// JSON serialized list of on-bench employee items: [ { "id": "...", "name": "...", "role": "..." } ]
    /// </summary>
    public string EmployeeListJson { get; set; } = "[]";

    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
}
