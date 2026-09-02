using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations
{
    [DbContext(typeof(AppDbContext))]
    [Migration("20260902180000_AddEmployeeCodeFormatCheck")]
    public partial class AddEmployeeCodeFormatCheck : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // TK ID = TK-#### (employee) or TKI-#### (intern). NOT VALID enforces the rule for
            // new/updated rows only, so a shared DB with legacy codes never blocks startup.
            migrationBuilder.Sql(
                """
                ALTER TABLE employees DROP CONSTRAINT IF EXISTS "CK_employees_EmployeeCode_Format";
                ALTER TABLE employees
                    ADD CONSTRAINT "CK_employees_EmployeeCode_Format"
                    CHECK ("EmployeeCode" ~ '^(TK|TKI)-[0-9]{4}$') NOT VALID;
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """ALTER TABLE employees DROP CONSTRAINT IF EXISTS "CK_employees_EmployeeCode_Format";""");
        }
    }
}
