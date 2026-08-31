using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations
{
    [DbContext(typeof(AppDbContext))]
    [Migration("20260831133000_AddCountryPhoneFields")]
    public partial class AddCountryPhoneFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                ALTER TABLE mst_countries
                    ADD COLUMN IF NOT EXISTS "PhoneCode" character varying(8) NOT NULL DEFAULT '+91';
                ALTER TABLE mst_countries
                    ADD COLUMN IF NOT EXISTS "PhoneDigits" integer NOT NULL DEFAULT 10;
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PhoneCode",
                table: "mst_countries");

            migrationBuilder.DropColumn(
                name: "PhoneDigits",
                table: "mst_countries");
        }
    }
}
