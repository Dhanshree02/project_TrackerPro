using System.Text;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using PMS.API.Configuration;
using PMS.API.Infrastructure.Swagger;
using PMS.API.Middleware;
using Serilog;
using Serilog.Events;

DotEnvLoader.Load();

var builder = WebApplication.CreateBuilder(args);

// ---- Serilog (structured logging) ----
builder.Host.UseSerilog((context, services, config) =>
{
    var logRoot = Path.Combine(context.HostingEnvironment.ContentRootPath, "Log");
    var debugDir = Path.Combine(logRoot, "Debug log");
    var errorDir = Path.Combine(logRoot, "Error log");
    Directory.CreateDirectory(debugDir);
    Directory.CreateDirectory(errorDir);

    const string outputTemplate =
        "{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u3}] {SourceContext}: {Message:lj}{NewLine}{Exception}";

    config
        .ReadFrom.Configuration(context.Configuration)
        .ReadFrom.Services(services)
        .Enrich.FromLogContext()
        .WriteTo.Logger(debug => debug
            .Filter.ByIncludingOnly(e => e.Level < LogEventLevel.Error)
            .WriteTo.File(
                Path.Combine(debugDir, "debug-.log"),
                rollingInterval: RollingInterval.Day,
                retainedFileCountLimit: 14,
                shared: true,
                outputTemplate: outputTemplate))
        .WriteTo.Logger(error => error
            .Filter.ByIncludingOnly(e => e.Level >= LogEventLevel.Error)
            .WriteTo.File(
                Path.Combine(errorDir, "error-.log"),
                rollingInterval: RollingInterval.Day,
                retainedFileCountLimit: 30,
                shared: true,
                outputTemplate: outputTemplate));
});

// ---- Controllers ----
builder.Services.AddControllers(o => o.Filters.Add<ValidationFilter>())
    .AddJsonOptions(o =>
        o.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter()));

builder.Services.AddEndpointsApiExplorer();

// ---- Swagger (OpenAPI docs with JWT support) ----
builder.Services.AddSwaggerDocs();

// ---- Application services (persistence, security, features, validators) ----
builder.Services.AddApplicationServices(builder.Configuration);

// ---- CORS (restricted to configured frontend origins) ----
var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? [];
// Credentials are required for the HttpOnly refresh-token cookie to travel
// with cross-origin requests. WithOrigins (never AllowAnyOrigin) + AllowCredentials.
builder.Services.AddCors(o => o.AddPolicy("Frontend", p =>
    p.WithOrigins(allowedOrigins).AllowAnyHeader().AllowAnyMethod().AllowCredentials()));

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

app.MapControllers();
app.MapHealthChecks("/health").AllowAnonymous();

app.Run();

/// <summary>Exposed for integration tests (WebApplicationFactory).</summary>
public partial class Program;
