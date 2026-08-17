using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using PMS.API.Infrastructure.Authentication;

namespace PMS.API.Infrastructure.Persistence.Seeding;

/// <summary>
/// Development bootstrap: applies pending EF Core migrations and seeds demo data
/// on startup. Enabled only when <c>Database:AutoMigrate=true</c> (set in
/// appsettings.Development.json) — never enable in production.
/// </summary>
public sealed class DbInitializerHostedService(
    IServiceScopeFactory scopeFactory,
    ILogger<DbInitializerHostedService> logger,
    IHostEnvironment environment) : IHostedService
{
    public async Task StartAsync(CancellationToken cancellationToken)
    {
        if (!environment.IsDevelopment())
        {
            logger.LogInformation("DbInitializer skipped (not Development).");
            return;
        }

        using var scope = scopeFactory.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var hasher = scope.ServiceProvider.GetRequiredService<IPasswordHasher>();

        logger.LogInformation("Applying database migrations…");
        try
        {
            await db.Database.MigrateAsync(cancellationToken);
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException(
                "Database unreachable. Set ConnectionStrings:DefaultConnection in " +
                "appsettings.json (or user-secrets), then create the " +
                "trackerpro database and role — see apps/backend/README.md.", ex);
        }

        logger.LogInformation("Seeding demo data…");
        await DbSeeder.SeedAsync(db, hasher, cancellationToken);

        logger.LogInformation("Database ready.");
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}
