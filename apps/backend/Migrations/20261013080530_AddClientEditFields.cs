using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddClientEditFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                ALTER TABLE customer.tbl_clients
                    ADD COLUMN IF NOT EXISTS "ClientCode" character varying(20);

                ALTER TABLE customer.tbl_clients
                    ADD COLUMN IF NOT EXISTS "CreatedByName" character varying(150);

                ALTER TABLE customer.tbl_clients
                    ADD COLUMN IF NOT EXISTS "GroupSpocPhoneCode" character varying(16);

                DROP INDEX IF EXISTS customer."IX_clients_ClientCode";

                CREATE UNIQUE INDEX IF NOT EXISTS "IX_clients_ClientCode"
                    ON customer.tbl_clients ("ClientCode")
                    WHERE "ClientCode" IS NOT NULL;
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                ALTER TABLE customer.tbl_clients DROP COLUMN IF EXISTS "CreatedByName";
                ALTER TABLE customer.tbl_clients DROP COLUMN IF EXISTS "GroupSpocPhoneCode";
                DROP INDEX IF EXISTS customer."IX_clients_ClientCode";
                CREATE UNIQUE INDEX IF NOT EXISTS "IX_clients_ClientCode"
                    ON customer.tbl_clients ("ClientCode");
                """);
        }
    }
}
