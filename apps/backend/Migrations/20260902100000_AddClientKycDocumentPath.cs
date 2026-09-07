using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations
{
    [DbContext(typeof(AppDbContext))]
    [Migration("20260902100000_AddClientKycDocumentPath")]
    public partial class AddClientKycDocumentPath : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Idempotent: the column may already exist on fresh Docker volumes seeded from SQL.
            migrationBuilder.Sql(
                """
                ALTER TABLE clients ADD COLUMN IF NOT EXISTS "KycDocumentPath" character varying(500);
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "KycDocumentPath",
                table: "clients");
        }
    }
}
