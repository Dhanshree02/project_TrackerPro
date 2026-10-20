using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddProjectInvoiceScheduleFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                ALTER TABLE project.tbl_project_invoices
                    ADD COLUMN IF NOT EXISTS "ServiceName" character varying(255),
                    ADD COLUMN IF NOT EXISTS "Qty" integer,
                    ADD COLUMN IF NOT EXISTS "UnitPrice" numeric(18,2),
                    ADD COLUMN IF NOT EXISTS "Currency" character varying(10),
                    ADD COLUMN IF NOT EXISTS "ResourceLevel" character varying(500),
                    ADD COLUMN IF NOT EXISTS "PaymentStatus" character varying(40);
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                ALTER TABLE project.tbl_project_invoices
                    DROP COLUMN IF EXISTS "ServiceName",
                    DROP COLUMN IF EXISTS "Qty",
                    DROP COLUMN IF EXISTS "UnitPrice",
                    DROP COLUMN IF EXISTS "Currency",
                    DROP COLUMN IF EXISTS "ResourceLevel",
                    DROP COLUMN IF EXISTS "PaymentStatus";
                """);
        }
    }
}
