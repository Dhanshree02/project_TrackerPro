using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations;

[DbContext(typeof(AppDbContext))]
[Migration("20260927183000_AddTimesheets")]
public partial class AddTimesheets : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql(
            """
            CREATE TABLE IF NOT EXISTS timesheets (
                "Id" uuid NOT NULL,
                "EmployeeId" uuid NOT NULL,
                "WeekStart" date NOT NULL,
                "Status" character varying(32) NOT NULL,
                "TotalHours" numeric(6,1) NOT NULL,
                "SubmittedAtUtc" timestamp with time zone NULL,
                "ReviewedByEmployeeId" uuid NULL,
                "ReviewedAtUtc" timestamp with time zone NULL,
                "ReviewComment" character varying(2000) NULL,
                "CreatedAtUtc" timestamp with time zone NOT NULL,
                "UpdatedAtUtc" timestamp with time zone NULL,
                "CreatedBy" uuid NULL,
                "UpdatedBy" uuid NULL,
                "DeletedAtUtc" timestamp with time zone NULL,
                CONSTRAINT "PK_timesheets" PRIMARY KEY ("Id"),
                CONSTRAINT "FK_timesheets_employees_EmployeeId" FOREIGN KEY ("EmployeeId") REFERENCES employees ("Id") ON DELETE RESTRICT
            );

            CREATE UNIQUE INDEX IF NOT EXISTS "IX_timesheets_EmployeeId_WeekStart"
                ON timesheets ("EmployeeId", "WeekStart")
                WHERE "DeletedAtUtc" IS NULL;

            CREATE TABLE IF NOT EXISTS timesheet_entries (
                "Id" uuid NOT NULL,
                "TimesheetWeekId" uuid NOT NULL,
                "ProjectKey" character varying(64) NOT NULL,
                "TaskKey" character varying(64) NOT NULL,
                "ProjectName" character varying(200) NOT NULL,
                "TaskName" character varying(200) NOT NULL,
                "ReviewDecision" character varying(32) NULL,
                "CreatedAtUtc" timestamp with time zone NOT NULL,
                "UpdatedAtUtc" timestamp with time zone NULL,
                "CreatedBy" uuid NULL,
                "UpdatedBy" uuid NULL,
                "DeletedAtUtc" timestamp with time zone NULL,
                CONSTRAINT "PK_timesheet_entries" PRIMARY KEY ("Id"),
                CONSTRAINT "FK_timesheet_entries_timesheets_TimesheetWeekId" FOREIGN KEY ("TimesheetWeekId") REFERENCES timesheets ("Id") ON DELETE RESTRICT
            );

            CREATE INDEX IF NOT EXISTS "IX_timesheet_entries_TimesheetWeekId"
                ON timesheet_entries ("TimesheetWeekId");

            CREATE TABLE IF NOT EXISTS timesheet_entry_days (
                "Id" uuid NOT NULL,
                "TimesheetEntryId" uuid NOT NULL,
                "DayIndex" smallint NOT NULL,
                "Hours" numeric(4,1) NOT NULL,
                "Comment" character varying(1000) NULL,
                "CreatedAtUtc" timestamp with time zone NOT NULL,
                "UpdatedAtUtc" timestamp with time zone NULL,
                "CreatedBy" uuid NULL,
                "UpdatedBy" uuid NULL,
                "DeletedAtUtc" timestamp with time zone NULL,
                CONSTRAINT "PK_timesheet_entry_days" PRIMARY KEY ("Id"),
                CONSTRAINT "FK_timesheet_entry_days_timesheet_entries_TimesheetEntryId" FOREIGN KEY ("TimesheetEntryId") REFERENCES timesheet_entries ("Id") ON DELETE RESTRICT
            );

            CREATE UNIQUE INDEX IF NOT EXISTS "IX_timesheet_entry_days_TimesheetEntryId_DayIndex"
                ON timesheet_entry_days ("TimesheetEntryId", "DayIndex")
                WHERE "DeletedAtUtc" IS NULL;
            """);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql(
            """
            DROP TABLE IF EXISTS timesheet_entry_days;
            DROP TABLE IF EXISTS timesheet_entries;
            DROP TABLE IF EXISTS timesheets;
            """);
    }
}
