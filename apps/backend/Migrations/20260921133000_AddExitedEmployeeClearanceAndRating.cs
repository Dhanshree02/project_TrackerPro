using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations;

[DbContext(typeof(AppDbContext))]
[Migration("20260921133000_AddExitedEmployeeClearanceAndRating")]
public partial class AddExitedEmployeeClearanceAndRating : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql(
            """
            ALTER TABLE exited_employees
                ADD COLUMN IF NOT EXISTS "ClearanceCompleted" boolean NOT NULL DEFAULT false,
                ADD COLUMN IF NOT EXISTS "ExitRating" numeric(3, 1);

            UPDATE exited_employees
            SET "ClearanceCompleted" = true
            WHERE "ClearanceCompleted" = false
              AND "LastWorkingDay" IS NOT NULL
              AND "LastWorkingDay" < CURRENT_DATE;

            UPDATE exited_employees e
            SET "ExitRating" = emp."AnnualRating"
            FROM employees emp
            WHERE e."OriginalEmployeeId" = emp."Id"
              AND e."ExitRating" IS NULL
              AND emp."AnnualRating" IS NOT NULL
              AND emp."AnnualRating" > 0
              AND emp."AnnualRating" <= 5;
            """);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql(
            """
            ALTER TABLE exited_employees
                DROP COLUMN IF EXISTS "ClearanceCompleted",
                DROP COLUMN IF EXISTS "ExitRating";
            """);
    }
}
