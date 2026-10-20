using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using PMS.API.Infrastructure.Authentication;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Infrastructure.Persistence.Configurations;
using PMS.API.Modules.Resources.Models;

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

            // Schema-qualified names from the EF model (master.*, resource.*, …).
            var countries = db.TableName<MstCountry>();
            var employeeStatuses = db.TableName<MstEmployeeStatus>();
            var employees = db.TableName<Employee>();
            var exitedEmployees = db.TableName<ExitedEmployee>();
            var certifications = db.TableName<MstCertification>();
            var graduationDegrees = db.TableName<MstGraduationDegree>();
            var postGraduationDegrees = db.TableName<MstPostGraduationDegree>();
            var designations = db.TableName<MstDesignation>();
            var jobRoles = db.TableName<MstRole>();
            var employeeActivityLogs = db.TableName<EmployeeActivityLog>();
            var resourceSchema = DbSchemas.Resource;

            // Dump-initialized DBs can lag the model (PhoneCode was added in code before a migration ran).
            await db.Database.ExecuteSqlRawAsync(
                $"""ALTER TABLE {countries} ADD COLUMN IF NOT EXISTS "PhoneCode" character varying(8) NOT NULL DEFAULT '+91';""",
                cancellationToken);
            await db.Database.ExecuteSqlRawAsync(
                $"""ALTER TABLE {countries} ADD COLUMN IF NOT EXISTS "PhoneDigits" integer NOT NULL DEFAULT 10;""",
                cancellationToken);
            // Dump-initialized DBs can lag the model (employee status catalog added after dump).
            await db.Database.ExecuteSqlRawAsync(
                $"""
                CREATE TABLE IF NOT EXISTS {employeeStatuses} (
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
                    ON {employeeStatuses} ("Code")
                    WHERE "DeletedAtUtc" IS NULL;

                DO $$
                BEGIN
                    IF NOT EXISTS (
                        SELECT 1 FROM pg_constraint c
                        WHERE c.conrelid = '{employeeStatuses}'::regclass AND c.contype = 'p'
                    ) THEN
                        ALTER TABLE {employeeStatuses} ADD PRIMARY KEY ("Id");
                    END IF;
                END $$;

                ALTER TABLE {employees}
                    ADD COLUMN IF NOT EXISTS "EmployeeStatusId" uuid,
                    ADD COLUMN IF NOT EXISTS "BondDelivered" character varying(10),
                    ADD COLUMN IF NOT EXISTS "BondDurationMonths" integer,
                    ADD COLUMN IF NOT EXISTS "BondExpiryDate" date;

                DO $$
                BEGIN
                    IF NOT EXISTS (
                        SELECT 1 FROM pg_constraint WHERE conname = 'FK_employees_mst_employee_statuses_EmployeeStatusId'
                    ) THEN
                        ALTER TABLE {employees}
                            ADD CONSTRAINT "FK_employees_mst_employee_statuses_EmployeeStatusId"
                            FOREIGN KEY ("EmployeeStatusId") REFERENCES {employeeStatuses} ("Id")
                            ON DELETE SET NULL;
                    END IF;
                END $$;

                CREATE TABLE IF NOT EXISTS {certifications} (
                    "Id" uuid NOT NULL,
                    "Code" character varying(100) NOT NULL,
                    "Name" character varying(200) NOT NULL,
                    "IsActive" boolean DEFAULT true NOT NULL,
                    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone
                );

                DO $$
                BEGIN
                    IF NOT EXISTS (
                        SELECT 1 FROM pg_constraint c
                        WHERE c.conrelid = '{certifications}'::regclass AND c.contype = 'p'
                    ) THEN
                        ALTER TABLE {certifications} ADD PRIMARY KEY ("Id");
                    END IF;
                END $$;

                CREATE TABLE IF NOT EXISTS {graduationDegrees} (
                    "Id" uuid NOT NULL,
                    "Code" character varying(100) NOT NULL,
                    "Name" character varying(200) NOT NULL,
                    "IsActive" boolean DEFAULT true NOT NULL,
                    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone
                );

                DO $$
                BEGIN
                    IF NOT EXISTS (
                        SELECT 1 FROM pg_constraint c
                        WHERE c.conrelid = '{graduationDegrees}'::regclass AND c.contype = 'p'
                    ) THEN
                        ALTER TABLE {graduationDegrees} ADD PRIMARY KEY ("Id");
                    END IF;
                END $$;

                CREATE TABLE IF NOT EXISTS {postGraduationDegrees} (
                    "Id" uuid NOT NULL,
                    "Code" character varying(100) NOT NULL,
                    "Name" character varying(200) NOT NULL,
                    "IsActive" boolean DEFAULT true NOT NULL,
                    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone
                );

                DO $$
                BEGIN
                    IF NOT EXISTS (
                        SELECT 1 FROM pg_constraint c
                        WHERE c.conrelid = '{postGraduationDegrees}'::regclass AND c.contype = 'p'
                    ) THEN
                        ALTER TABLE {postGraduationDegrees} ADD PRIMARY KEY ("Id");
                    END IF;
                END $$;

                ALTER TABLE {designations}
                    ADD COLUMN IF NOT EXISTS "SubDepartment" text;

                DO $$
                BEGIN
                    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = '{resourceSchema}' AND table_name = 'tbl_employees' AND column_name = 'projectsite') THEN
                        ALTER TABLE {employees} RENAME COLUMN projectsite TO "ProjectSite";
                    ELSIF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = '{resourceSchema}' AND table_name = 'tbl_employees' AND column_name = 'ProjectSite') THEN
                        ALTER TABLE {employees} ADD COLUMN "ProjectSite" character varying(80);
                    END IF;
                END $$;

                ALTER TABLE {employees}
                    ADD COLUMN IF NOT EXISTS "GradDegree" text,
                    ADD COLUMN IF NOT EXISTS "GradYear" text,
                    ADD COLUMN IF NOT EXISTS "PostGradDegree" text,
                    ADD COLUMN IF NOT EXISTS "PostGradYear" text,
                    ADD COLUMN IF NOT EXISTS "ExpType" text,
                    ADD COLUMN IF NOT EXISTS "PriorTotalExp" text,
                    ADD COLUMN IF NOT EXISTS "PriorRelevantExp" text,
                    ADD COLUMN IF NOT EXISTS "EmergencyContactRelation" text,
                    ADD COLUMN IF NOT EXISTS "PmoDepartment" text,
                    ADD COLUMN IF NOT EXISTS "SubDepartment" text,
                    ADD COLUMN IF NOT EXISTS "BillableStatus" text,
                    ADD COLUMN IF NOT EXISTS "ClientLocation" text,
                    ADD COLUMN IF NOT EXISTS "ProjectType" text,
                    ADD COLUMN IF NOT EXISTS "ProjectAllocated" text,
                    ADD COLUMN IF NOT EXISTS "ClientEngManagerMapping" text;

                CREATE TABLE IF NOT EXISTS {employeeActivityLogs} (
                    "Id" uuid NOT NULL PRIMARY KEY,
                    "EmployeeId" uuid NOT NULL,
                    "Action" character varying(50) NOT NULL,
                    "PerformedByEmail" character varying(255) NOT NULL,
                    "PerformedByName" character varying(255),
                    "Details" text,
                    "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone
                );

                CREATE INDEX IF NOT EXISTS "IX_employee_activity_logs_EmployeeId"
                    ON {employeeActivityLogs} ("EmployeeId");

                CREATE INDEX IF NOT EXISTS "IX_employee_activity_logs_CreatedAtUtc"
                    ON {employeeActivityLogs} ("CreatedAtUtc" DESC);
                """,
                cancellationToken);
            await db.Database.ExecuteSqlRawAsync(
                $"""
                ALTER TABLE {exitedEmployees}
                    ADD COLUMN IF NOT EXISTS "ClearanceCompleted" boolean NOT NULL DEFAULT false,
                    ADD COLUMN IF NOT EXISTS "ExitRating" numeric(3, 1);

                UPDATE {exitedEmployees}
                SET "ClearanceCompleted" = true
                WHERE "ClearanceCompleted" = false
                  AND "LastWorkingDay" IS NOT NULL
                  AND "LastWorkingDay" < CURRENT_DATE;

                UPDATE {exitedEmployees} e
                SET "ExitRating" = emp."AnnualRating"
                FROM {employees} emp
                WHERE e."OriginalEmployeeId" = emp."Id"
                  AND e."ExitRating" IS NULL
                  AND emp."AnnualRating" IS NOT NULL
                  AND emp."AnnualRating" > 0
                  AND emp."AnnualRating" <= 5;
                """,
                cancellationToken);
            await db.Database.ExecuteSqlRawAsync(
                $"""
                UPDATE {jobRoles}
                SET "Name" = 'Leader', "UpdatedAtUtc" = NOW()
                WHERE "Name" IN ('Leader (L)', 'Leader(L)');

                UPDATE {jobRoles}
                SET "Name" = 'Team Leader', "UpdatedAtUtc" = NOW()
                WHERE "Name" = 'Team Leader (TL)';

                UPDATE {jobRoles}
                SET "Name" = 'Team Member', "UpdatedAtUtc" = NOW()
                WHERE "Name" = 'Team Member (TM)';

                UPDATE {jobRoles}
                SET "Name" = 'Manager', "UpdatedAtUtc" = NOW()
                WHERE "Name" = 'Manager (Mng.)';

                UPDATE {jobRoles}
                SET "Name" = 'Sr. Manager', "UpdatedAtUtc" = NOW()
                WHERE "Name" = 'Sr. Manager (Sr.Mng.)';

                UPDATE {jobRoles}
                SET "Name" = 'Head Of Department', "UpdatedAtUtc" = NOW()
                WHERE "Name" = 'Head Of Department (HOD)';

                UPDATE {employees}
                SET "Role" = CASE "Role"
                    WHEN 'Leader (L)' THEN 'Leader'
                    WHEN 'Leader(L)' THEN 'Leader'
                    WHEN 'Team Leader (TL)' THEN 'Team Leader'
                    WHEN 'Team Member (TM)' THEN 'Team Member'
                    WHEN 'Manager (Mng.)' THEN 'Manager'
                    WHEN 'Sr. Manager (Sr.Mng.)' THEN 'Sr. Manager'
                    WHEN 'Head Of Department (HOD)' THEN 'Head Of Department'
                    ELSE "Role"
                END,
                "UpdatedAtUtc" = NOW()
                WHERE "Role" IN (
                    'Leader (L)', 'Leader(L)', 'Team Leader (TL)', 'Team Member (TM)',
                    'Manager (Mng.)', 'Sr. Manager (Sr.Mng.)', 'Head Of Department (HOD)'
                );

                UPDATE {employees} AS e
                SET "JobRoleId" = pick.role_id,
                    "UpdatedAtUtc" = NOW()
                FROM (
                    SELECT
                        emp."Id" AS employee_id,
                        (
                            SELECT r."Id"
                            FROM {jobRoles} AS r
                            WHERE r."DesignationId" = emp."DesignationId"
                              AND r."IsActive" = TRUE
                              AND r."DeletedAtUtc" IS NULL
                            ORDER BY r."CreatedAtUtc", r."Name"
                            LIMIT 1
                        ) AS role_id
                    FROM {employees} AS emp
                    WHERE emp."DeletedAtUtc" IS NULL
                      AND emp."DesignationId" IS NOT NULL
                ) AS pick
                WHERE e."Id" = pick.employee_id
                  AND pick.role_id IS NOT NULL
                  AND (
                      e."JobRoleId" IS NULL
                      OR NOT EXISTS (
                          SELECT 1
                          FROM {jobRoles} AS r
                          WHERE r."Id" = e."JobRoleId"
                            AND r."DesignationId" = e."DesignationId"
                            AND r."IsActive" = TRUE
                            AND r."DeletedAtUtc" IS NULL
                      )
                  );
                """,
                cancellationToken);
            await DbSeeder.EnsureEmployeeStatusesAsync(db, cancellationToken);
            await OrgRoleMatrixSync.ApplyAsync(db, cancellationToken);
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
