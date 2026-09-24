using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Auth.DTOs;
using PMS.API.Modules.MyTeam.DTOs;
using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.IntegrationTests;

public class MyTeamModuleTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public MyTeamModuleTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory.WithWebHostBuilder(b =>
            b.UseSetting("Database:AutoMigrate", "true"));
        _client = _factory.CreateClient();
    }

    [Fact]
    public async Task Calendar_IsScopedToEmManagerAndPm()
    {
        var graph = await SeedGraphAsync();

        await AuthorizeAsync("dhanshree@acme.co");
        var asEm = await GetCalendarAsync();
        Assert.Contains(asEm.Members, m => m.Id == graph.MemberId);
        Assert.DoesNotContain(asEm.Members, m => m.Id == graph.IncompleteId);
        Assert.DoesNotContain(asEm.Members, m => m.Id == graph.OutsiderId);

        await AuthorizeAsync("aarav@acme.co");
        var asManager = await GetCalendarAsync();
        Assert.Contains(asManager.Members, m => m.Id == graph.MemberId);

        await AuthorizeAsync("vikram@acme.co");
        var asPm = await GetCalendarAsync();
        Assert.Contains(asPm.Members, m => m.Id == graph.MemberId);
    }

    [Fact]
    public async Task DayUpsert_LocksPastDates_AndClearsAttendance()
    {
        var graph = await SeedGraphAsync();
        await AuthorizeAsync("aarav@acme.co");
        var future = TodayIst().AddDays(10);

        var saved = await _client.PutAsJsonAsync("/api/v1/my-team/days", new UpsertTeamDaysRequest(
            graph.MemberId, [future], "onsite", "Morning"));
        Assert.Equal(HttpStatusCode.OK, saved.StatusCode);

        var cleared = await _client.PutAsJsonAsync("/api/v1/my-team/days", new UpsertTeamDaysRequest(
            graph.MemberId, [future], "clear", null));
        Assert.Equal(HttpStatusCode.OK, cleared.StatusCode);

        var calendar = await GetCalendarAsync(future, future);
        var kept = Assert.Single(calendar.Entries, e => e.EmployeeId == graph.MemberId && e.Date == future);
        Assert.Null(kept.Attendance);
        Assert.Equal("Morning", kept.Shift);

        var bothCleared = await _client.PutAsJsonAsync("/api/v1/my-team/days", new UpsertTeamDaysRequest(
            graph.MemberId, [future.AddDays(1)], "leave", null));
        Assert.Equal(HttpStatusCode.OK, bothCleared.StatusCode);
        var removed = await _client.PutAsJsonAsync("/api/v1/my-team/days", new UpsertTeamDaysRequest(
            graph.MemberId, [future.AddDays(1)], "clear", null));
        Assert.Equal(HttpStatusCode.OK, removed.StatusCode);
        var after = await GetCalendarAsync(future, future.AddDays(1));
        Assert.DoesNotContain(after.Entries, e => e.EmployeeId == graph.MemberId && e.Date == future.AddDays(1));

        var past = await _client.PutAsJsonAsync("/api/v1/my-team/days", new UpsertTeamDaysRequest(
            graph.MemberId, [TodayIst().AddDays(-2)], "wfh", "General"));
        Assert.Equal(HttpStatusCode.BadRequest, past.StatusCode);

        await AuthorizeAsync("rahul@acme.co");
        var forbidden = await _client.PutAsJsonAsync("/api/v1/my-team/days", new UpsertTeamDaysRequest(
            graph.MemberId, [future], "wfh", "Night"));
        Assert.Equal(HttpStatusCode.Forbidden, forbidden.StatusCode);
    }

    [Fact]
    public async Task ScheduleSave_ReplacesHolidays_AndClearsNonWorkingDays()
    {
        var graph = await SeedGraphAsync();
        await AuthorizeAsync("vikram@acme.co");
        var saturday = NextWeekday(DayOfWeek.Saturday);
        var monday = NextWeekday(DayOfWeek.Monday);

        var saturdayWrite = await _client.PutAsJsonAsync("/api/v1/my-team/days", new UpsertTeamDaysRequest(
            graph.MemberId, [saturday], null, "Night"));
        Assert.Equal(HttpStatusCode.OK, saturdayWrite.StatusCode);
        var mondayWrite = await _client.PutAsJsonAsync("/api/v1/my-team/days", new UpsertTeamDaysRequest(
            graph.MemberId, [monday], "onsite", "General"));
        Assert.Equal(HttpStatusCode.OK, mondayWrite.StatusCode);

        var holidayA = saturday.AddDays(14);
        var holidayB = holidayA.AddDays(1);
        var first = await _client.PutAsJsonAsync($"/api/v1/my-team/members/{graph.MemberId}/schedule",
            new SaveTeamScheduleRequest(
                [1, 2, 3, 4, 5],
                "Weekdays",
                [
                    new TeamHolidayInput(holidayA, "Regional holiday", "Onsite client"),
                    new TeamHolidayInput(holidayB, "Local holiday", null),
                ]));
        Assert.Equal(HttpStatusCode.OK, first.StatusCode);

        var replaced = await _client.PutAsJsonAsync($"/api/v1/my-team/members/{graph.MemberId}/schedule",
            new SaveTeamScheduleRequest(
                [1, 2, 3, 4, 5],
                "Weekdays",
                [new TeamHolidayInput(holidayA, "Regional holiday", "Updated")]));
        Assert.Equal(HttpStatusCode.OK, replaced.StatusCode);

        var calendar = await GetCalendarAsync(monday < saturday ? monday : saturday, holidayB);
        var schedule = Assert.Single(calendar.Schedules, s => s.EmployeeId == graph.MemberId);
        var holiday = Assert.Single(schedule.Holidays);
        Assert.Equal(holidayA, holiday.Date);
        Assert.Equal("Updated", holiday.Comment);
        Assert.Contains(calendar.Entries, e => e.EmployeeId == graph.MemberId && e.Date == monday);
        Assert.DoesNotContain(calendar.Entries, e => e.EmployeeId == graph.MemberId && e.Date == saturday);

        var locked = await _client.PutAsJsonAsync("/api/v1/my-team/days", new UpsertTeamDaysRequest(
            graph.MemberId, [holidayA], "leave", "Morning"));
        Assert.Equal(HttpStatusCode.BadRequest, locked.StatusCode);
    }

    private async Task<TeamCalendarDto> GetCalendarAsync(DateOnly? from = null, DateOnly? to = null)
    {
        var start = from ?? TodayIst();
        var end = to ?? start.AddDays(40);
        var response = await _client.GetAsync($"/api/v1/my-team/calendar?from={start:yyyy-MM-dd}&to={end:yyyy-MM-dd}");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var envelope = await response.Content.ReadFromJsonAsync<ApiResponse<TeamCalendarDto>>();
        return envelope!.Data!;
    }

    private async Task AuthorizeAsync(string email)
    {
        var response = await _client.PostAsJsonAsync("/api/v1/auth/login",
            new LoginRequest(email, "Password@123"));
        response.EnsureSuccessStatusCode();
        var envelope = await response.Content.ReadFromJsonAsync<ApiResponse<AuthResult>>();
        _client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", envelope!.Data!.AccessToken);
    }

    private async Task<Graph> SeedGraphAsync()
    {
        await using var scope = _factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var emId = await EnsureCallerAsync(db, "dhanshree@acme.co");
        var managerId = await EnsureCallerAsync(db, "aarav@acme.co");
        var pmId = await EnsureCallerAsync(db, "vikram@acme.co");
        await EnsureCallerAsync(db, "rahul@acme.co");

        var otherEm = NewEmployee("Other", "Em");
        var otherManager = NewEmployee("Other", "Manager");
        var otherPm = NewEmployee("Other", "Pm");
        db.Employees.AddRange(otherEm, otherManager, otherPm);
        await db.SaveChangesAsync();

        var member = NewEmployee("Calendar", "Member");
        member.EngagementManagerEmployeeId = emId;
        member.ReportingManagerId = managerId;
        member.ProjectManagerId = pmId;

        var incomplete = NewEmployee("Missing", "PmLink");
        incomplete.EngagementManagerEmployeeId = emId;
        incomplete.ReportingManagerId = managerId;

        var outsider = NewEmployee("Other", "Team");
        outsider.EngagementManagerEmployeeId = otherEm.Id;
        outsider.ReportingManagerId = otherManager.Id;
        outsider.ProjectManagerId = otherPm.Id;

        db.Employees.AddRange(member, incomplete, outsider);
        await db.SaveChangesAsync();
        return new Graph(member.Id, incomplete.Id, outsider.Id);
    }

    private static async Task<Guid> EnsureCallerAsync(AppDbContext db, string email)
    {
        var user = await db.Users.FirstAsync(u => u.Email == email);
        var existing = await db.Employees.FirstOrDefaultAsync(e => e.UserId == user.Id);
        if (existing is not null) return existing.Id;

        var employee = NewEmployee(user.Name, "Link");
        employee.WorkEmail = $"link.{Guid.NewGuid():N}@trackerpro.test";
        employee.UserId = user.Id;
        db.Employees.Add(employee);
        await db.SaveChangesAsync();
        return employee.Id;
    }

    private static Employee NewEmployee(string first, string last) => new()
    {
        EmployeeCode = "TK-" + Random.Shared.Next(1000, 9999).ToString("0000"),
        FirstName = first,
        LastName = last + Random.Shared.Next(100, 999),
        WorkEmail = $"myteam.{Guid.NewGuid():N}@trackerpro.test",
        Status = "Active",
    };

    private static DateOnly TodayIst()
    {
        TimeZoneInfo tz;
        try
        {
            tz = TimeZoneInfo.FindSystemTimeZoneById("India Standard Time");
        }
        catch (TimeZoneNotFoundException)
        {
            tz = TimeZoneInfo.FindSystemTimeZoneById("Asia/Kolkata");
        }

        return DateOnly.FromDateTime(TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, tz));
    }

    private static DateOnly NextWeekday(DayOfWeek weekday)
    {
        var date = TodayIst().AddDays(1);
        while (date.DayOfWeek != weekday) date = date.AddDays(1);
        return date;
    }

    private sealed record Graph(Guid MemberId, Guid IncompleteId, Guid OutsiderId);
}
