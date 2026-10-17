using PMS.API.Modules.MyTeam.DTOs;

namespace PMS.API.Modules.MyTeam.Services;

public interface IMyTeamService
{
    Task<TeamCalendarDto> GetCalendarAsync(DateOnly from, DateOnly to, bool allEmployees = false, CancellationToken ct = default);

    Task UpsertDaysAsync(UpsertTeamDaysRequest request, CancellationToken ct = default);

    Task SaveScheduleAsync(Guid employeeId, SaveTeamScheduleRequest request, CancellationToken ct = default);

    /// <summary>Distinct active on-floor role names from <c>master.mst_roles</c>.</summary>
    Task<IReadOnlyList<string>> GetOnFloorRoleNamesAsync(CancellationToken ct = default);
}
