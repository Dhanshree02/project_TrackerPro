using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations
{
    [DbContext(typeof(AppDbContext))]
    [Migration("20260930173000_AddClientCode")]
    public partial class AddClientCode : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                ALTER TABLE clients ADD COLUMN IF NOT EXISTS "ClientCode" character varying(20);
                CREATE UNIQUE INDEX IF NOT EXISTS "IX_clients_ClientCode" ON clients ("ClientCode");
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(name: "IX_clients_ClientCode", table: "clients");
            migrationBuilder.DropColumn(name: "ClientCode", table: "clients");
        }
    }
}
