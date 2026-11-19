using PMS.API.Infrastructure.Logging;
using PMS.API.Infrastructure.Persistence;
using System.Text;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Hangfire;
using PMS.API.Configuration;
using PMS.API.Infrastructure.Hangfire;
using PMS.API.Infrastructure.Swagger;
using PMS.API.Middleware;
using PMS.API.Modules.ActionCentre.Jobs;
using PMS.API.Modules.MyTeam.Jobs;
using PMS.API.Modules.Timesheets.Jobs;
using PMS.API.Modules.Resources.Jobs;
using PMS.API.Modules.Sla.Jobs;
using Serilog;
using Serilog.Events;

DotEnvLoader.Load();

var builder = WebApplication.CreateBuilder(args);

// ---- Serilog (modular structured logging with auto-archiving) ----
builder.Host.UseSerilog((context, services, config) =>
{
    var logRoot = Path.Combine(context.HostingEnvironment.ContentRootPath, "Log");

    config
        .ReadFrom.Configuration(context.Configuration)
        .ReadFrom.Services(services)
        .Enrich.FromLogContext()
        .WriteTo.Console()
        .WriteTo.ModularArchivingFile(logRoot);
});

// ---- Controllers ----
builder.Services.AddControllers(o => o.Filters.Add<ValidationFilter>())
    .AddJsonOptions(o =>
        o.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter()));

builder.Services.AddEndpointsApiExplorer();

// ---- Swagger (OpenAPI docs with JWT support) ----
builder.Services.AddSwaggerDocs();

// ---- Application services (persistence, security, features, validators) ----
DatabaseSyncHelper.Initialize(builder.Configuration.GetConnectionString("DefaultConnection"));
builder.Services.AddApplicationServices(builder.Configuration);

// ---- CORS (restricted to configured frontend origins) ----
var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? [];
// Credentials are required for the HttpOnly refresh-token cookie to travel
// with cross-origin requests. WithOrigins (never AllowAnyOrigin) + AllowCredentials.
builder.Services.AddCors(o => o.AddPolicy("Frontend", p =>
{
    if (builder.Environment.IsDevelopment())
    {
        p.SetIsOriginAllowed(_ => true).AllowAnyHeader().AllowAnyMethod().AllowCredentials();
    }
    else
    {
        p.WithOrigins(allowedOrigins).AllowAnyHeader().AllowAnyMethod().AllowCredentials();
    }
}));

// ---- Authentication (JWT Bearer) ----
var jwt = builder.Configuration.GetSection("Jwt");
var signingKey = jwt["SigningKey"]
    ?? throw new InvalidOperationException("Jwt:SigningKey is not configured.");

if (Encoding.UTF8.GetByteCount(signingKey) < 64)
    throw new InvalidOperationException("Jwt:SigningKey must be at least 64 bytes for HmacSha512.");

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(o =>
    {
        o.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = jwt["Issuer"],
            ValidateAudience = true,
            ValidAudience = jwt["Audience"],
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(signingKey)),
            ValidateLifetime = true,
            ClockSkew = TimeSpan.FromMinutes(1),
            NameClaimType = System.Security.Claims.ClaimTypes.Name,
            RoleClaimType = System.Security.Claims.ClaimTypes.Role,
        };
    });

// Authenticated by default — new endpoints must opt out with [AllowAnonymous].
builder.Services.AddAuthorization(o =>
    o.FallbackPolicy = new Microsoft.AspNetCore.Authorization.AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser()
        .Build());

// ---- Health checks ----
builder.Services.AddHealthChecks();

var app = builder.Build();

// ---- Pipeline ----
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseSerilogRequestLogging();
app.UseMiddleware<ExceptionHandlingMiddleware>();
if (!app.Configuration.GetValue("DisableHttpsRedirection", false))
    app.UseHttpsRedirection();
app.UseCors("Frontend");
app.UseAuthentication();
if (app.Environment.IsDevelopment())
    app.UseMiddleware<DevelopmentAuthBypassMiddleware>();
app.UseAuthorization();

// ---- Background Job Dashboard (Hangfire) ----
var hangfireOptions = app.Configuration.GetSection(HangfireOptions.SectionName).Get<HangfireOptions>() ?? new HangfireOptions();
app.UseHangfireDashboard("/hangfire", new DashboardOptions
{
    DashboardTitle = "Project Compass - Job Monitor",
    Authorization = [new HangfireDashboardAuthFilter(app.Environment, hangfireOptions)]
});

// Initialize SLA job display name formatter and pre-warm dashboard cache
SlaJobDisplayNameFormatter.Initialize(app.Services);

// Register Recurring Timesheet Submission Reminder Job (Daily at 09:00 IST / 03:30 UTC)
try
{
    RecurringJob.AddOrUpdate<TimesheetReminderJob>(
        "timesheet-submission-reminders",
        job => job.ExecuteAsync(CancellationToken.None),
        "30 3 * * *");
}
catch (Exception ex)
{
    Log.Warning(ex, "Failed to schedule recurring Hangfire job for timesheet reminders.");
}

// Register Recurring Employee Offboarding Reminder Job (Daily at 09:00 IST / 03:30 UTC)
try
{
    RecurringJob.AddOrUpdate<EmployeeOffboardingReminderJob>(
        "employee-offboarding-reminders",
        job => job.ExecuteAsync(CancellationToken.None),
        "30 3 * * *");
}
catch (Exception ex)
{
    Log.Warning(ex, "Failed to schedule recurring Hangfire job for employee offboarding reminders.");
}

// Register Recurring Bucket Task Auto-Pause Job (Every 15 minutes to auto-pause timers running >= 12h with 8h cap)
try
{
    RecurringJob.AddOrUpdate<BucketTaskAutoPauseJob>(
        "bucket-task-auto-pause",
        job => job.ExecuteAsync(CancellationToken.None),
        "*/15 * * * *");
}
catch (Exception ex)
{
    Log.Warning(ex, "Failed to schedule recurring Hangfire job for bucket task auto-pause.");
}

// Register Recurring My Team Availability & Shift Coverage Jobs
try
{
    // Tier 1: 2-Hour Reminders to Reporting Managers (09:00, 11:00, 13:00, 15:00, 17:00 IST / 03:30, 05:30, 07:30, 09:30, 11:30 UTC Mon-Fri)
    RecurringJob.AddOrUpdate<TeamAvailabilityTwoHourReminderJob>(
        "team-availability-2hour-reminders",
        job => job.ExecuteAsync(CancellationToken.None),
        "30 3,5,7,9,11 * * 1-5");

    // Tier 2: 11:00 AM IST Project Leadership Alert (05:30 UTC Mon-Fri)
    RecurringJob.AddOrUpdate<TeamAvailabilityLeadershipAlertJob>(
        "team-availability-leadership-11am",
        job => job.ExecuteAsync(11, CancellationToken.None),
        "30 5 * * 1-5");

    // Tier 2: 12:00 PM IST Project Leadership Alert (06:30 UTC Mon-Fri)
    RecurringJob.AddOrUpdate<TeamAvailabilityLeadershipAlertJob>(
        "team-availability-leadership-12pm",
        job => job.ExecuteAsync(12, CancellationToken.None),
        "30 6 * * 1-5");

    // Tier 3: 1:00 PM IST SPM Daily Escalation Alert (07:30 UTC Mon-Fri)
    RecurringJob.AddOrUpdate<TeamAvailabilitySpmAlertJob>(
        "team-availability-spm-1pm",
        job => job.ExecuteAsync(CancellationToken.None),
        "30 7 * * 1-5");

    // Tier 4: Next-Day EOD (18:00 IST / 12:30 UTC Mon-Fri) HOD Escalation for Unresolved Shift Availability
    RecurringJob.AddOrUpdate<TeamAvailabilityHodEscalationJob>(
        "team-availability-hod-eod",
        job => job.ExecuteAsync(CancellationToken.None),
        "30 12 * * 1-5");
}
catch (Exception ex)
{
    Log.Warning(ex, "Failed to schedule recurring Hangfire jobs for team availability & shift notifications.");
}

// Register Recurring Service Prerequisite Daily EOD Reminder Job (Daily at 18:00 IST / 12:30 UTC Mon-Fri)
try
{
    RecurringJob.AddOrUpdate<PMS.API.Modules.ActionCentre.Services.IActionNotificationService>(
        "service-prerequisite-daily-eod-reminders",
        job => job.ExecuteAllProjectsServicePrerequisiteDailyEodCheckAsync(),
        "30 12 * * 1-5");
}
catch (Exception ex)
{
    Log.Warning(ex, "Failed to schedule recurring Hangfire job for service prerequisite daily EOD reminders.");
}

app.MapControllers();
app.MapHealthChecks("/health").AllowAnonymous();
if (app.Environment.IsDevelopment())
{
    app.MapGet("/", () => Results.Redirect("http://localhost:3000/"))
        .AllowAnonymous();
}

app.Run();

/// <summary>Exposed for integration tests (WebApplicationFactory).</summary>
public partial class Program;
