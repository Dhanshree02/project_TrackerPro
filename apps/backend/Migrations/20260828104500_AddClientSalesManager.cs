using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations
{
    [DbContext(typeof(AppDbContext))]
    [Migration("20260828104500_AddClientSalesManager")]
    public partial class AddClientSalesManager : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Idempotent: trackerpro-final.sql already has these columns/FK on fresh Docker volumes.
            migrationBuilder.Sql(
                """
                ALTER TABLE clients ADD COLUMN IF NOT EXISTS "SalesManager" character varying(120);
                ALTER TABLE clients ADD COLUMN IF NOT EXISTS "SalesManagerId" uuid;
                CREATE INDEX IF NOT EXISTS "IX_clients_SalesManagerId" ON clients ("SalesManagerId");
                DO $$
                BEGIN
                    IF NOT EXISTS (
                        SELECT 1 FROM pg_constraint WHERE conname = 'FK_clients_employees_SalesManagerId'
                    ) THEN
                        ALTER TABLE clients
                            ADD CONSTRAINT "FK_clients_employees_SalesManagerId"
                            FOREIGN KEY ("SalesManagerId") REFERENCES employees("Id") ON DELETE SET NULL;
                    END IF;
                END $$;
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_clients_employees_SalesManagerId",
                table: "clients");

            migrationBuilder.DropIndex(
                name: "IX_clients_SalesManagerId",
                table: "clients");

            migrationBuilder.DropColumn(
                name: "SalesManager",
                table: "clients");

            migrationBuilder.DropColumn(
                name: "SalesManagerId",
                table: "clients");
        }
    }
}
