using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddGeoCatalogs : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "CityId",
                table: "clients",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "CountryId",
                table: "clients",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "mst_countries",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Code = table.Column<string>(type: "character varying(8)", maxLength: 8, nullable: false),
                    Name = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_mst_countries", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "mst_cities",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Code = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    Name = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CountryId = table.Column<Guid>(type: "uuid", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_mst_cities", x => x.Id);
                    table.ForeignKey(
                        name: "FK_mst_cities_mst_countries_CountryId",
                        column: x => x.CountryId,
                        principalTable: "mst_countries",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_clients_CityId",
                table: "clients",
                column: "CityId");

            migrationBuilder.CreateIndex(
                name: "IX_clients_CountryId",
                table: "clients",
                column: "CountryId");

            migrationBuilder.CreateIndex(
                name: "IX_mst_cities_Code",
                table: "mst_cities",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_mst_cities_CountryId_Name",
                table: "mst_cities",
                columns: new[] { "CountryId", "Name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_mst_countries_Code",
                table: "mst_countries",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_mst_countries_Name",
                table: "mst_countries",
                column: "Name",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_clients_mst_cities_CityId",
                table: "clients",
                column: "CityId",
                principalTable: "mst_cities",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_clients_mst_countries_CountryId",
                table: "clients",
                column: "CountryId",
                principalTable: "mst_countries",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_clients_mst_cities_CityId",
                table: "clients");

            migrationBuilder.DropForeignKey(
                name: "FK_clients_mst_countries_CountryId",
                table: "clients");

            migrationBuilder.DropTable(
                name: "mst_cities");

            migrationBuilder.DropTable(
                name: "mst_countries");

            migrationBuilder.DropIndex(
                name: "IX_clients_CityId",
                table: "clients");

            migrationBuilder.DropIndex(
                name: "IX_clients_CountryId",
                table: "clients");

            migrationBuilder.DropColumn(
                name: "CityId",
                table: "clients");

            migrationBuilder.DropColumn(
                name: "CountryId",
                table: "clients");
        }
    }
}
