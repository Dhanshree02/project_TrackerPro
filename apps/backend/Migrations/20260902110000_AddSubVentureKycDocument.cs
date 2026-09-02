using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations
{
    [DbContext(typeof(AppDbContext))]
    [Migration("20260902110000_AddSubVentureKycDocument")]
    public partial class AddSubVentureKycDocument : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Idempotent: KYC is stored per sub-venture (each end-customer division can
            // have its own KYC document).
            migrationBuilder.Sql(
                """
                ALTER TABLE sub_ventures ADD COLUMN IF NOT EXISTS "KycDocumentName" character varying(255);
                ALTER TABLE sub_ventures ADD COLUMN IF NOT EXISTS "KycDocumentPath" character varying(500);
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "KycDocumentName",
                table: "sub_ventures");

            migrationBuilder.DropColumn(
                name: "KycDocumentPath",
                table: "sub_ventures");
        }
    }
}
