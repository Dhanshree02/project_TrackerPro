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
            // Dump-initialized DBs can lag the model (employee status catalog added after dump).
            await db.Database.ExecuteSqlRawAsync(
                """
                CREATE TABLE IF NOT EXISTS mst_employee_statuses (
                    "Id" uuid NOT NULL,
                    "Code" character varying(80) NOT NULL,
                    "Name" character varying(150) NOT NULL,
                    "IsActive" boolean NOT NULL DEFAULT true,
                    "AllowOnboarding" boolean NOT NULL DEFAULT false,
                    "SortOrder" integer NOT NULL DEFAULT 0,
                    "CreatedAtUtc" timestamp with time zone NOT NULL,
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone
                );

                CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_employee_statuses_Code"
                    ON mst_employee_statuses ("Code")
                    WHERE "DeletedAtUtc" IS NULL;

                DO $$
                BEGIN
                    IF NOT EXISTS (
                        SELECT 1 FROM pg_constraint c
                        JOIN pg_class t ON c.conrelid = t.oid
                        WHERE t.relname = 'mst_employee_statuses' AND c.contype = 'p'
                    ) THEN
                        ALTER TABLE mst_employee_statuses ADD PRIMARY KEY ("Id");
                    END IF;
                END $$;

                ALTER TABLE employees
                    ADD COLUMN IF NOT EXISTS "EmployeeStatusId" uuid,
                    ADD COLUMN IF NOT EXISTS "BondDelivered" character varying(10),
                    ADD COLUMN IF NOT EXISTS "BondDurationMonths" integer,
                    ADD COLUMN IF NOT EXISTS "BondExpiryDate" date;

                DO $$
                BEGIN
                    IF NOT EXISTS (
                        SELECT 1 FROM pg_constraint WHERE conname = 'FK_employees_mst_employee_statuses_EmployeeStatusId'
                    ) THEN
                        ALTER TABLE employees
                            ADD CONSTRAINT "FK_employees_mst_employee_statuses_EmployeeStatusId"
                            FOREIGN KEY ("EmployeeStatusId") REFERENCES mst_employee_statuses ("Id")
                            ON DELETE SET NULL;
                    END IF;
                END $$;
                """,
                cancellationToken);
            await DbSeeder.EnsureEmployeeStatusesAsync(db, cancellationToken);
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
