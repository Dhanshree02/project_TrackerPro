using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations
{
    [DbContext(typeof(AppDbContext))]
    [Migration("20260831150000_AddResourceCatalogTables")]
    public partial class AddResourceCatalogTables : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // These tables exist on dump-initialized DBs but were never created by EF
            // migrations, so AutoMigrate left them missing on migration-only databases.
            migrationBuilder.Sql(
                """
                CREATE TABLE IF NOT EXISTS mst_business_units (
                    "Id" uuid NOT NULL,
                    "Code" character varying(80) NOT NULL,
                    "Name" character varying(150) NOT NULL,
                    "IsActive" boolean NOT NULL DEFAULT true,
                    "SortOrder" integer NOT NULL DEFAULT 0,
                    "CreatedAtUtc" timestamp with time zone NOT NULL,
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone
                );
                CREATE TABLE IF NOT EXISTS mst_work_locations (
                    "Id" uuid NOT NULL,
                    "Code" character varying(80) NOT NULL,
                    "Name" character varying(150) NOT NULL,
                    "IsActive" boolean NOT NULL DEFAULT true,
                    "SortOrder" integer NOT NULL DEFAULT 0,
                    "CreatedAtUtc" timestamp with time zone NOT NULL,
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone
                );
                CREATE TABLE IF NOT EXISTS mst_offices (
                    "Id" uuid NOT NULL,
                    "Code" character varying(80) NOT NULL,
                    "Name" character varying(150) NOT NULL,
                    "WorkLocationId" uuid,
                    "IsActive" boolean NOT NULL DEFAULT true,
                    "SortOrder" integer NOT NULL DEFAULT 0,
                    "CreatedAtUtc" timestamp with time zone NOT NULL,
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone
                );
                CREATE TABLE IF NOT EXISTS mst_reporting_managers (
                    "Id" uuid NOT NULL,
                    "Code" character varying(80) NOT NULL,
                    "Name" character varying(150) NOT NULL,
                    "Designation" character varying(150),
                    "Email" character varying(255),
                    "EmployeeId" uuid,
                    "IsActive" boolean NOT NULL DEFAULT true,
                    "SortOrder" integer NOT NULL DEFAULT 0,
                    "CreatedAtUtc" timestamp with time zone NOT NULL,
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone
                );
                CREATE TABLE IF NOT EXISTS repository (
                    "Id" uuid NOT NULL,
                    "FileName" character varying(255) NOT NULL,
                    "Category" character varying(50) NOT NULL,
                    "Size" bigint NOT NULL,
                    "LastUpdated" timestamp with time zone NOT NULL,
                    "UploadedBy" character varying(150) NOT NULL,
                    "FilePath" character varying(1000) NOT NULL,
                    "CreatedAtUtc" timestamp with time zone NOT NULL,
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone
                );
                CREATE TABLE IF NOT EXISTS repository_activity_logs (
                    "Id" uuid NOT NULL,
                    "Action" character varying(50) NOT NULL,
                    "DocumentId" uuid,
                    "FileName" character varying(255) NOT NULL,
                    "Category" character varying(50) NOT NULL,
                    "PerformedBy" character varying(150) NOT NULL,
                    "Details" character varying(1000),
                    "CreatedAtUtc" timestamp with time zone NOT NULL,
                    "DeletedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "UpdatedAtUtc" timestamp with time zone
                );

                DO $$
                BEGIN
                    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname IN ('PK_mst_business_units', 'mst_business_units_pkey')) THEN
                        ALTER TABLE mst_business_units ADD CONSTRAINT "PK_mst_business_units" PRIMARY KEY ("Id");
                    END IF;
                    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname IN ('PK_mst_work_locations', 'mst_work_locations_pkey')) THEN
                        ALTER TABLE mst_work_locations ADD CONSTRAINT "PK_mst_work_locations" PRIMARY KEY ("Id");
                    END IF;
                    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname IN ('PK_mst_offices', 'mst_offices_pkey')) THEN
                        ALTER TABLE mst_offices ADD CONSTRAINT "PK_mst_offices" PRIMARY KEY ("Id");
                    END IF;
                    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname IN ('PK_mst_reporting_managers', 'mst_reporting_managers_pkey')) THEN
                        ALTER TABLE mst_reporting_managers ADD CONSTRAINT "PK_mst_reporting_managers" PRIMARY KEY ("Id");
                    END IF;
                    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname IN ('PK_repository', 'repository_pkey')) THEN
                        ALTER TABLE repository ADD CONSTRAINT "PK_repository" PRIMARY KEY ("Id");
                    END IF;
                    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname IN ('PK_repository_activity_logs', 'repository_activity_logs_pkey')) THEN
                        ALTER TABLE repository_activity_logs ADD CONSTRAINT "PK_repository_activity_logs" PRIMARY KEY ("Id");
                    END IF;
                    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname IN ('FK_mst_offices_mst_work_locations_WorkLocationId', 'mst_offices_WorkLocationId_fkey')) THEN
                        ALTER TABLE mst_offices
                            ADD CONSTRAINT "FK_mst_offices_mst_work_locations_WorkLocationId"
                            FOREIGN KEY ("WorkLocationId") REFERENCES mst_work_locations("Id") ON DELETE CASCADE;
                    END IF;
                    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'FK_mst_reporting_managers_employees_EmployeeId') THEN
                        ALTER TABLE mst_reporting_managers
                            ADD CONSTRAINT "FK_mst_reporting_managers_employees_EmployeeId"
                            FOREIGN KEY ("EmployeeId") REFERENCES employees("Id") ON DELETE SET NULL;
                    END IF;
                END $$;

                CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_business_units_Code" ON mst_business_units ("Code");
                CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_work_locations_Code" ON mst_work_locations ("Code");
                CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_offices_Code" ON mst_offices ("Code");
                CREATE INDEX IF NOT EXISTS "IX_mst_offices_WorkLocationId" ON mst_offices ("WorkLocationId");
                CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_reporting_managers_Code" ON mst_reporting_managers ("Code");
                CREATE INDEX IF NOT EXISTS "IX_mst_reporting_managers_EmployeeId" ON mst_reporting_managers ("EmployeeId");
                CREATE INDEX IF NOT EXISTS "IX_repository_Category" ON repository ("Category");
                CREATE INDEX IF NOT EXISTS "IX_repository_DeletedAtUtc" ON repository ("DeletedAtUtc");
                CREATE INDEX IF NOT EXISTS "IX_repository_activity_logs_CreatedAtUtc" ON repository_activity_logs ("CreatedAtUtc");
                CREATE INDEX IF NOT EXISTS "IX_repository_activity_logs_DeletedAtUtc" ON repository_activity_logs ("DeletedAtUtc");
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(name: "mst_offices");
            migrationBuilder.DropTable(name: "mst_reporting_managers");
            migrationBuilder.DropTable(name: "mst_business_units");
            migrationBuilder.DropTable(name: "mst_work_locations");
            migrationBuilder.DropTable(name: "repository_activity_logs");
            migrationBuilder.DropTable(name: "repository");
        }
    }
}
