using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Sla.Models;

namespace PMS.API.Modules.Sla.Services;

public sealed class SlaPolicyService(AppDbContext db) : ISlaPolicyService
{
    public async Task<SlaPolicy?> GetPolicyAsync(
        string module,
        string activityType,
        string stage = "Default",
        CancellationToken ct = default)
    {
        // 1. Try matching exact stage first
        var policy = await db.SlaPolicies
            .AsNoTracking()
            .FirstOrDefaultAsync(p => p.Module == module
                                      && p.ActivityType == activityType
                                      && p.Stage == stage
                                      && p.IsActive
                                      && p.DeletedAtUtc == null, ct);

        // 2. Fallback to "Default" stage policy if stage-specific policy is not defined
        if (policy == null && !string.Equals(stage, "Default", StringComparison.OrdinalIgnoreCase))
        {
            policy = await db.SlaPolicies
                .AsNoTracking()
                .FirstOrDefaultAsync(p => p.Module == module
                                          && p.ActivityType == activityType
                                          && p.Stage == "Default"
                                          && p.IsActive
                                          && p.DeletedAtUtc == null, ct);
        }

        return policy;
    }

    public async Task<IReadOnlyList<SlaPolicy>> GetAllPoliciesAsync(CancellationToken ct = default)
    {
        return await db.SlaPolicies
            .AsNoTracking()
            .Where(p => p.DeletedAtUtc == null)
            .OrderBy(p => p.Module)
            .ThenBy(p => p.ActivityType)
            .ThenBy(p => p.Stage)
            .ToListAsync(ct);
    }

    public async Task<SlaPolicy> CreateOrUpdatePolicyAsync(SlaPolicy policy, CancellationToken ct = default)
    {
        var existing = await db.SlaPolicies
            .FirstOrDefaultAsync(p => p.Module == policy.Module
                                      && p.ActivityType == policy.ActivityType
                                      && p.Stage == policy.Stage
                                      && p.DeletedAtUtc == null, ct);

        if (existing == null)
        {
            db.SlaPolicies.Add(policy);
            await db.SaveChangesAsync(ct);
            return policy;
        }

        existing.Name = policy.Name;
        existing.Description = policy.Description;
        existing.TatDurationMinutes = policy.TatDurationMinutes;
        existing.CalculationMode = policy.CalculationMode;
        existing.WorkingHoursStart = policy.WorkingHoursStart;
        existing.WorkingHoursEnd = policy.WorkingHoursEnd;
        existing.ExcludeWeekends = policy.ExcludeWeekends;
        existing.ExcludeHolidays = policy.ExcludeHolidays;
        existing.ReminderIntervalsMinutesJson = policy.ReminderIntervalsMinutesJson;
        existing.FirstEscalationAfterMinutes = policy.FirstEscalationAfterMinutes;
        existing.SecondEscalationAfterMinutes = policy.SecondEscalationAfterMinutes;
        existing.ResponsibleRolesJson = policy.ResponsibleRolesJson;
        existing.FirstEscalationRolesJson = policy.FirstEscalationRolesJson;
        existing.SecondEscalationRolesJson = policy.SecondEscalationRolesJson;
        existing.IsActive = policy.IsActive;
        existing.MetadataJson = policy.MetadataJson;

        await db.SaveChangesAsync(ct);
        return existing;
    }
}
