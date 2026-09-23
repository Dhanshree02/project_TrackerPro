using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations;

[DbContext(typeof(AppDbContext))]
[Migration("20260923120000_AddTeamSchedule")]
public partial class AddTeamSchedule : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql(
            """
            ALTER TABLE employees
                ADD COLUMN IF NOT EXISTS "EngagementManagerEmployeeId" uuid,
                ADD COLUMN IF NOT EXISTS "ProjectManagerId" uuid;

            CREATE INDEX IF NOT EXISTS "IX_employees_EngagementManagerEmployeeId"
                ON employees ("EngagementManagerEmployeeId");

            CREATE INDEX IF NOT EXISTS "IX_employees_ProjectManagerId"
                ON employees ("ProjectManagerId");

            DO $$
            BEGIN
                IF NOT EXISTS (
                    SELECT 1 FROM pg_constraint WHERE conname = 'FK_employees_employees_EngagementManagerEmployeeId'
                ) THEN
                    ALTER TABLE employees
                        ADD CONSTRAINT "FK_employees_employees_EngagementManagerEmployeeId"
                        FOREIGN KEY ("EngagementManagerEmployeeId") REFERENCES employees ("Id")
                        ON DELETE RESTRICT;
                END IF;

                IF NOT EXISTS (
                    SELECT 1 FROM pg_constraint WHERE conname = 'FK_employees_employees_ProjectManagerId'
                ) THEN
                    ALTER TABLE employees
                        ADD CONSTRAINT "FK_employees_employees_ProjectManagerId"
                        FOREIGN KEY ("ProjectManagerId") REFERENCES employees ("Id")
                        ON DELETE RESTRICT;
                END IF;
            END $$;

            CREATE TABLE IF NOT EXISTS team_day_entries (
                "Id" uuid NOT NULL,
                "EmployeeId" uuid NOT NULL,
                "WorkDate" date NOT NULL,
                "Attendance" character varying(20),
                "Shift" character varying(20),
                "CreatedAtUtc" timestamp with time zone NOT NULL,
                "UpdatedAtUtc" timestamp with time zone,
                "CreatedBy" uuid,
                "UpdatedBy" uuid,
                "DeletedAtUtc" timestamp with time zone,
                CONSTRAINT "PK_team_day_entries" PRIMARY KEY ("Id")
            );

            CREATE UNIQUE INDEX IF NOT EXISTS "IX_team_day_entries_EmployeeId_WorkDate"
                ON team_day_entries ("EmployeeId", "WorkDate")
                WHERE "DeletedAtUtc" IS NULL;

            CREATE TABLE IF NOT EXISTS team_member_schedules (
                "Id" uuid NOT NULL,
                "EmployeeId" uuid NOT NULL,
                "WorkingDays" smallint[] NOT NULL DEFAULT '{1,2,3,4,5}',
                "Notes" character varying(2000),
                "CreatedAtUtc" timestamp with time zone NOT NULL,
                "UpdatedAtUtc" timestamp with time zone,
                "CreatedBy" uuid,
                "UpdatedBy" uuid,
                "DeletedAtUtc" timestamp with time zone,
                CONSTRAINT "PK_team_member_schedules" PRIMARY KEY ("Id")
            );

            CREATE UNIQUE INDEX IF NOT EXISTS "IX_team_member_schedules_EmployeeId"
                ON team_member_schedules ("EmployeeId")
                WHERE "DeletedAtUtc" IS NULL;

            CREATE TABLE IF NOT EXISTS team_member_holidays (
                "Id" uuid NOT NULL,
                "EmployeeId" uuid NOT NULL,
                "HolidayDate" date NOT NULL,
                "Name" character varying(200) NOT NULL,
                "Comment" character varying(500),
                "CreatedAtUtc" timestamp with time zone NOT NULL,
                "UpdatedAtUtc" timestamp with time zone,
                "CreatedBy" uuid,
                "UpdatedBy" uuid,
                "DeletedAtUtc" timestamp with time zone,
                CONSTRAINT "PK_team_member_holidays" PRIMARY KEY ("Id")
            );

            CREATE UNIQUE INDEX IF NOT EXISTS "IX_team_member_holidays_EmployeeId_HolidayDate"
                ON team_member_holidays ("EmployeeId", "HolidayDate")
                WHERE "DeletedAtUtc" IS NULL;

            DO $$
            BEGIN
                IF NOT EXISTS (
                    SELECT 1 FROM pg_constraint WHERE conname = 'FK_team_day_entries_employees_EmployeeId'
                ) THEN
                    ALTER TABLE team_day_entries
                        ADD CONSTRAINT "FK_team_day_entries_employees_EmployeeId"
                        FOREIGN KEY ("EmployeeId") REFERENCES employees ("Id")
                        ON DELETE RESTRICT;
                END IF;

                IF NOT EXISTS (
                    SELECT 1 FROM pg_constraint WHERE conname = 'FK_team_member_schedules_employees_EmployeeId'
                ) THEN
                    ALTER TABLE team_member_schedules
                        ADD CONSTRAINT "FK_team_member_schedules_employees_EmployeeId"
                        FOREIGN KEY ("EmployeeId") REFERENCES employees ("Id")
                        ON DELETE RESTRICT;
                END IF;

                IF NOT EXISTS (
                    SELECT 1 FROM pg_constraint WHERE conname = 'FK_team_member_holidays_employees_EmployeeId'
                ) THEN
                    ALTER TABLE team_member_holidays
                        ADD CONSTRAINT "FK_team_member_holidays_employees_EmployeeId"
                        FOREIGN KEY ("EmployeeId") REFERENCES employees ("Id")
                        ON DELETE RESTRICT;
                END IF;
            END $$;
            """);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql(
            """
            DROP TABLE IF EXISTS team_member_holidays;
            DROP TABLE IF EXISTS team_member_schedules;
            DROP TABLE IF EXISTS team_day_entries;

            ALTER TABLE employees DROP CONSTRAINT IF EXISTS "FK_employees_employees_EngagementManagerEmployeeId";
            ALTER TABLE employees DROP CONSTRAINT IF EXISTS "FK_employees_employees_ProjectManagerId";
            DROP INDEX IF EXISTS "IX_employees_EngagementManagerEmployeeId";
            DROP INDEX IF EXISTS "IX_employees_ProjectManagerId";
            ALTER TABLE employees DROP COLUMN IF EXISTS "EngagementManagerEmployeeId";
            ALTER TABLE employees DROP COLUMN IF EXISTS "ProjectManagerId";
            """);
    }
}
