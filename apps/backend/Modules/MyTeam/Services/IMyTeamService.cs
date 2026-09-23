using PMS.API.Modules.MyTeam.DTOs;

namespace PMS.API.Modules.MyTeam.Services;

public interface IMyTeamService
{
    Task<TeamCalendarDto> GetCalendarAsync(DateOnly from, DateOnly to, CancellationToken ct = default);

    Task UpsertDaysAsync(UpsertTeamDaysRequest request, CancellationToken ct = default);

    Task SaveScheduleAsync(Guid employeeId, SaveTeamScheduleRequest request, CancellationToken ct = default);
}
