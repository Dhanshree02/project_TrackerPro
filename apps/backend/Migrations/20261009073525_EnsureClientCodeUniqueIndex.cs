using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <summary>
    /// Brings the model snapshot in line with Customer ID on <c>customer.tbl_clients</c>.
    /// The column and index may already exist: <c>20260930173000_AddClientCode</c> adds them on
    /// databases that start from the old flat layout, and <c>ClientService</c> adds them at
    /// runtime on databases that never ran that migration. Everything here is IF NOT EXISTS.
    /// </summary>
    public partial class EnsureClientCodeUniqueIndex : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                ALTER TABLE customer.tbl_clients ADD COLUMN IF NOT EXISTS "ClientCode" character varying(20);
                CREATE UNIQUE INDEX IF NOT EXISTS "IX_clients_ClientCode" ON customer.tbl_clients ("ClientCode");
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                DROP INDEX IF EXISTS customer."IX_clients_ClientCode";
                """);
        }
    }
}
