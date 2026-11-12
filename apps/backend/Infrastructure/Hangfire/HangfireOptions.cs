namespace PMS.API.Infrastructure.Hangfire;

/// <summary>
/// Configuration options for Hangfire server, dashboard security, and background job processing.
/// Configured under the "Hangfire" section in appsettings.json / appsettings.Development.json.
/// </summary>
public sealed class HangfireOptions
{
    public const string SectionName = "Hangfire";

    /// <summary>
    /// Number of concurrent background job workers.
    /// Default is a conservative 2 workers to avoid database connection pool and CPU saturation.
    /// </summary>
    public int WorkerCount { get; set; } = 2;

    /// <summary>
    /// Job queues processed by this server instance.
    /// </summary>
    public string[] Queues { get; set; } = ["default"];

    /// <summary>
    /// Interval in seconds for polling queued background jobs.
    /// </summary>
    public int PollIntervalSeconds { get; set; } = 15;

    /// <summary>
    /// Whether temporary diagnostic endpoints (/api/v1/diagnostics/hangfire/*) are enabled.
    /// Should be false in production, true in development only.
    /// </summary>
    public bool EnableDiagnosticEndpoints { get; set; } = false;

    /// <summary>
    /// Authorized RBAC roles permitted to access the Hangfire Dashboard.
    /// Configurable per environment.
    /// </summary>
    public string[] AuthorizedRoles { get; set; } =
    [
        "Admin",
        "CEO",
        "CTO",
        "COO",
        "PMO",
        "IT Admin"
    ];

    /// <summary>
    /// Optional specific email addresses permitted administrative access to the Hangfire Dashboard.
    /// Configured via appsettings or environment variables; no hardcoded credentials.
    /// </summary>
    public string[] AuthorizedEmails { get; set; } = [];
}
