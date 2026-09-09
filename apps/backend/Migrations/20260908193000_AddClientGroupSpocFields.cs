using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations
{
    [DbContext(typeof(AppDbContext))]
    [Migration("20260908193000_AddClientGroupSpocFields")]
    public partial class AddClientGroupSpocFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                ALTER TABLE clients ADD COLUMN IF NOT EXISTS "GroupSpocName" character varying(150);
                ALTER TABLE clients ADD COLUMN IF NOT EXISTS "GroupSpocContact" character varying(40);
                UPDATE clients
                SET "GroupSpocName" = "ContactName"
                WHERE "GroupSpocName" IS NULL AND "ContactName" IS NOT NULL AND btrim("ContactName") <> '';
                UPDATE clients
                SET "GroupSpocContact" = "ContactPhone"
                WHERE "GroupSpocContact" IS NULL AND "ContactPhone" IS NOT NULL AND btrim("ContactPhone") <> '';
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                ALTER TABLE clients DROP COLUMN IF EXISTS "GroupSpocName";
                ALTER TABLE clients DROP COLUMN IF EXISTS "GroupSpocContact";
                """);
        }
    }
}
