using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddEmployeeCatalogs : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_mst_designations_DepartmentId",
                table: "mst_designations");

            migrationBuilder.AddColumn<Guid>(
                name: "JobRoleId",
                table: "employees",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "NationalityId",
                table: "employees",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "mst_nationalities",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Code = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
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
                    table.PrimaryKey("PK_mst_nationalities", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "mst_roles",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Code = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    Name = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    DesignationId = table.Column<Guid>(type: "uuid", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_mst_roles", x => x.Id);
                    table.ForeignKey(
                        name: "FK_mst_roles_mst_designations_DesignationId",
                        column: x => x.DesignationId,
                        principalTable: "mst_designations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_mst_designations_DepartmentId_Name",
                table: "mst_designations",
                columns: new[] { "DepartmentId", "Name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_employees_JobRoleId",
                table: "employees",
                column: "JobRoleId");

            migrationBuilder.CreateIndex(
                name: "IX_employees_NationalityId",
                table: "employees",
                column: "NationalityId");

            migrationBuilder.CreateIndex(
                name: "IX_mst_nationalities_Code",
                table: "mst_nationalities",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_mst_nationalities_Name",
                table: "mst_nationalities",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_mst_roles_Code",
                table: "mst_roles",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_mst_roles_DesignationId_Name",
                table: "mst_roles",
                columns: new[] { "DesignationId", "Name" },
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_employees_mst_nationalities_NationalityId",
                table: "employees",
                column: "NationalityId",
                principalTable: "mst_nationalities",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_employees_mst_roles_JobRoleId",
                table: "employees",
                column: "JobRoleId",
                principalTable: "mst_roles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_employees_mst_nationalities_NationalityId",
                table: "employees");

            migrationBuilder.DropForeignKey(
                name: "FK_employees_mst_roles_JobRoleId",
                table: "employees");

            migrationBuilder.DropTable(
                name: "mst_nationalities");

            migrationBuilder.DropTable(
                name: "mst_roles");

            migrationBuilder.DropIndex(
                name: "IX_mst_designations_DepartmentId_Name",
                table: "mst_designations");

            migrationBuilder.DropIndex(
                name: "IX_employees_JobRoleId",
                table: "employees");

            migrationBuilder.DropIndex(
                name: "IX_employees_NationalityId",
                table: "employees");

            migrationBuilder.DropColumn(
                name: "JobRoleId",
                table: "employees");

            migrationBuilder.DropColumn(
                name: "NationalityId",
                table: "employees");

            migrationBuilder.CreateIndex(
                name: "IX_mst_designations_DepartmentId",
                table: "mst_designations",
                column: "DepartmentId");
        }
    }
}
