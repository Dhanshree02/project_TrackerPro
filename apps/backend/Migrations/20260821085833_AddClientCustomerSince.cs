using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddClientCustomerSince : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateOnly>(
                name: "CustomerSince",
                table: "clients",
                type: "date",
                nullable: true);

            migrationBuilder.Sql(
                """
                UPDATE clients
                SET "CustomerSince" = (("CreatedAtUtc" AT TIME ZONE 'UTC') AT TIME ZONE 'Asia/Kolkata')::date
                WHERE "CustomerSince" IS NULL;
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CustomerSince",
                table: "clients");
        }
    }
}
