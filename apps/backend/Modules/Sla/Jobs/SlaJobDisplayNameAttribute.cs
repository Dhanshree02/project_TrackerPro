using Hangfire;
using Hangfire.Common;
using Hangfire.Dashboard;

namespace PMS.API.Modules.Sla.Jobs;

/// <summary>
/// Custom Hangfire JobDisplayName attribute for SLA background worker methods.
/// Overrides the standard Hangfire Dashboard formatting to render clean, human-readable
/// business descriptions (workflow, task/project, escalation level, recipient role, action).
/// Preserves serialization compatibility and original method arguments.
/// </summary>
[AttributeUsage(AttributeTargets.Method)]
public sealed class SlaJobDisplayNameAttribute : JobDisplayNameAttribute
{
    public SlaJobDisplayNameAttribute(string defaultFormat) : base(defaultFormat)
    {
    }

    public override string Format(DashboardContext context, Job job)
    {
        try
        {
            var defaultName = base.Format(context, job);
            return SlaJobDisplayNameFormatter.FormatJobName(context, job, defaultName);
        }
        catch
        {
            return base.Format(context, job);
        }
    }
}
