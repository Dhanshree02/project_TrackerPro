using PMS.API.Modules.Sla.Models;

namespace PMS.API.Modules.Sla.Services;

public interface ISlaPolicyService
{
    Task<SlaPolicy?> GetPolicyAsync(string module, string activityType, string stage = "Default", CancellationToken ct = default);

    Task<IReadOnlyList<SlaPolicy>> GetAllPoliciesAsync(CancellationToken ct = default);

    Task<SlaPolicy> CreateOrUpdatePolicyAsync(SlaPolicy policy, CancellationToken ct = default);
}
