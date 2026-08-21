using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddSalaryBands : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ProbationPeriod",
                table: "employees",
                type: "character varying(40)",
                maxLength: 40,
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "SalaryBandId",
                table: "employees",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "mst_salary_bands",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Code = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Name = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_mst_salary_bands", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_employees_SalaryBandId",
                table: "employees",
                column: "SalaryBandId");

            migrationBuilder.CreateIndex(
                name: "IX_mst_salary_bands_Code",
                table: "mst_salary_bands",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_mst_salary_bands_Name",
                table: "mst_salary_bands",
                column: "Name",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_employees_mst_salary_bands_SalaryBandId",
                table: "employees",
                column: "SalaryBandId",
                principalTable: "mst_salary_bands",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_employees_mst_salary_bands_SalaryBandId",
                table: "employees");

            migrationBuilder.DropTable(
                name: "mst_salary_bands");

            migrationBuilder.DropIndex(
                name: "IX_employees_SalaryBandId",
                table: "employees");

            migrationBuilder.DropColumn(
                name: "ProbationPeriod",
                table: "employees");

            migrationBuilder.DropColumn(
                name: "SalaryBandId",
                table: "employees");
        }
    }
}
