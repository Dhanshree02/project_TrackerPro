using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations;

[DbContext(typeof(AppDbContext))]
[Migration("20260905140000_AddEmployeeEmploymentBondFields")]
public partial class AddEmployeeEmploymentBondFields : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql(
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
            """);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql(
            """
            ALTER TABLE employees DROP CONSTRAINT IF EXISTS "FK_employees_mst_employee_statuses_EmployeeStatusId";
            ALTER TABLE employees
                DROP COLUMN IF EXISTS "EmployeeStatusId",
                DROP COLUMN IF EXISTS "BondDelivered",
                DROP COLUMN IF EXISTS "BondDurationMonths",
                DROP COLUMN IF EXISTS "BondExpiryDate";
            DROP TABLE IF EXISTS mst_employee_statuses;
            """);
    }
}
