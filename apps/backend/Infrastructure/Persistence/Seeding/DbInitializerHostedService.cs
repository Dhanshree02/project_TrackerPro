using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using PMS.API.Infrastructure.Authentication;
using PMS.API.Infrastructure.Persistence;

namespace PMS.API.Infrastructure.Persistence.Seeding;

/// <summary>
/// Applies EF Core migrations when registered (Database:AutoMigrate=true).
/// Seeds demo data only when Database:Seed is true (Development default).
/// Seeding is idempotent and does not drop existing tables or rows.
/// </summary>
public sealed class DbInitializerHostedService(
    IServiceScopeFactory scopeFactory,
    ILogger<DbInitializerHostedService> logger,
    IHostEnvironment environment,
    IConfiguration configuration) : IHostedService
{
    public async Task StartAsync(CancellationToken cancellationToken)
    {
        using var scope = scopeFactory.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var hasher = scope.ServiceProvider.GetRequiredService<IPasswordHasher>();

        logger.LogInformation("Applying database migrations…");
        try
        {
            await db.Database.MigrateAsync(cancellationToken);
            // Dump-initialized DBs can lag the model (PhoneCode was added in code before a migration ran).
            await db.Database.ExecuteSqlRawAsync(
                """ALTER TABLE mst_countries ADD COLUMN IF NOT EXISTS "PhoneCode" character varying(8) NOT NULL DEFAULT '+91';""",
                cancellationToken);
            await db.Database.ExecuteSqlRawAsync(
                """ALTER TABLE mst_countries ADD COLUMN IF NOT EXISTS "PhoneDigits" integer NOT NULL DEFAULT 10;""",
                cancellationToken);
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException(
                "Database unreachable. Check that PostgreSQL is running on this machine " +
                "and ConnectionStrings:DefaultConnection in appsettings.json / .env is correct.", ex);
        }

        var seed = configuration.GetValue("Database:Seed", environment.IsDevelopment());
        if (seed)
        {
            logger.LogInformation("Seeding demo data (idempotent)…");
            await DbSeeder.SeedAsync(db, hasher, cancellationToken);
        }
        else
        {
            logger.LogInformation("Skipping seed (Database:Seed is false).");
        }

        logger.LogInformation("Database ready.");
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}
