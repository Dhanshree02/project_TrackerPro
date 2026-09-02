using FluentValidation;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using PMS.API.Infrastructure.Authentication;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Infrastructure.Persistence.Seeding;
using PMS.API.Infrastructure.Storage;
using PMS.API.Modules.Auth.Services;
using PMS.API.Modules.Catalogs.Services;
using PMS.API.Modules.Customers.Services;
using PMS.API.Modules.Repository.Services;
using PMS.API.Modules.Resources.Services;
using PMS.API.Modules.Users.Services;

namespace PMS.API.Configuration;

/// <summary>
/// Central dependency-injection registrations for the whole application.
/// Called once from <c>Program.cs</c> via <c>builder.Services.AddApplicationServices()</c>.
/// </summary>
public static class DependencyInjectionExtensions
{
    public static IServiceCollection AddApplicationServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        // ---- Persistence (EF Core + Npgsql) ----
        services.AddDbContext<AppDbContext>(options =>
            options.UseNpgsql(configuration.GetConnectionString("DefaultConnection")));

        // ---- Storage (Local Modular File Storage) ----
        services.AddSingleton<IFileStorageService, FileStorageService>();

        // ---- Security / Authentication ----
        services.Configure<JwtOptions>(configuration.GetSection(JwtOptions.SectionName));
        services.Configure<RefreshCookieOptions>(configuration.GetSection(RefreshCookieOptions.SectionName));
        services.Configure<MicrosoftAuthOptions>(configuration.GetSection(MicrosoftAuthOptions.SectionName));
        services.AddSingleton<MicrosoftTokenValidator>();
        services.AddSingleton<JwtTokenService>();
        services.AddSingleton<RefreshTokenCookie>();
        services.AddScoped<IPasswordHasher, BCryptPasswordHasher>();
        services.AddScoped<IAuthService, AuthService>();
        // Brute-force mitigation on /auth/* (10 attempts / 15 min per IP).
        services.AddSingleton(_ => new LoginRateLimiter(TimeSpan.FromMinutes(15), 10));

        // ---- Authorization ----
        services.AddHttpContextAccessor();
        services.AddScoped<ICurrentUserService, CurrentUserService>();

        // ---- Features (modules) ----
        services.AddScoped<IClientService, ClientService>();
        services.AddScoped<ICatalogService, CatalogService>();
        services.AddScoped<IEmployeeService, EmployeeService>();
        services.AddScoped<IUserService, UserService>();
        services.AddScoped<IRepositoryService, RepositoryService>();

        // ---- FluentValidation validators (scanned from this assembly) ----
        services.AddValidatorsFromAssembly(typeof(DependencyInjectionExtensions).Assembly);

        // ---- Database bootstrap (Development only): apply migrations + seed demo data ----
        if (configuration.GetValue<bool>("Database:AutoMigrate"))
        {
            services.AddHostedService<DbInitializerHostedService>();
        }

        return services;
    }
}
