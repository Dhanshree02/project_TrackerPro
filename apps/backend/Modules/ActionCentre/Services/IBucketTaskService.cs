using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.ActionCentre.Services;

public interface IBucketTaskService
{
    Task<PagedResult<BucketTaskDto>> GetBucketTasksAsync(BucketTaskQueryParameters query, CancellationToken ct = default);

    Task<BucketTaskDto?> GetBucketTaskByIdAsync(Guid id, CancellationToken ct = default);

    Task<BucketTaskDto> StartBucketTaskTimerAsync(Guid id, CancellationToken ct = default);

    Task<BucketTaskDto> PauseBucketTaskTimerAsync(Guid id, CancellationToken ct = default);

    Task<BucketTaskDto> StopBucketTaskTimerAsync(Guid id, CancellationToken ct = default);

    Task<BucketTaskDto> CompleteBucketTaskAsync(Guid id, CancellationToken ct = default);

    Task<BucketTaskDto> UpdateBucketTaskStatusAsync(Guid id, string status, CancellationToken ct = default);

    Task SyncBucketTasksFromAssignmentsAsync(Guid? projectId = null, Guid? taskId = null, CancellationToken ct = default);
}
