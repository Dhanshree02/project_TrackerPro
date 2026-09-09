using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations
{
    [DbContext(typeof(AppDbContext))]
    [Migration("20260909120000_AddClientContactCountry")]
    public partial class AddClientContactCountry : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                ALTER TABLE client_contacts ADD COLUMN IF NOT EXISTS "Country" character varying(120);
                ALTER TABLE client_contacts ADD COLUMN IF NOT EXISTS "PhoneCode" character varying(16);
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                ALTER TABLE client_contacts DROP COLUMN IF EXISTS "Country";
                ALTER TABLE client_contacts DROP COLUMN IF EXISTS "PhoneCode";
                """);
        }
    }
}
