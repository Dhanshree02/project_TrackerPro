using PMS.API.Modules.Sla.Models;

namespace PMS.API.Modules.Sla.Services;

/// <summary>
/// Dynamically resolves escalation and notification recipient employee IDs based on
/// PMS organizational roles, reporting relationships, and project leadership.
/// </summary>
public interface ISlaRecipientResolver
{
    /// <summary>
    /// Resolves target employee IDs for the specified roles in the context of an SLA instance.
    /// </summary>
    Task<IReadOnlyList<Guid>> ResolveRecipientsAsync(
        SlaInstance instance,
        IReadOnlyList<string> targetRoles,
        CancellationToken ct = default);

    /// <summary>
    /// Resolves project leadership employee IDs (Engagement Manager, Project Manager, Team Leader) for a given project.
    /// </summary>
    Task<IReadOnlyList<Guid>> ResolveLeadershipRecipientsAsync(
        Guid projectId,
        IReadOnlyList<string> targetRoles,
        CancellationToken ct = default);
}
