using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddOnFloorRoleMap : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "tbl_onfloorrole",
                schema: "resource",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    DepartmentId = table.Column<Guid>(type: "uuid", nullable: true),
                    DesignationId = table.Column<Guid>(type: "uuid", nullable: false),
                    SubDepartment = table.Column<string>(type: "character varying(250)", maxLength: 250, nullable: true),
                    RbacRoleId = table.Column<Guid>(type: "uuid", nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tbl_onfloorrole", x => x.Id);
                    table.ForeignKey(
                        name: "FK_tbl_onfloorrole_mst_departments_DepartmentId",
                        column: x => x.DepartmentId,
                        principalSchema: "master",
                        principalTable: "mst_departments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_tbl_onfloorrole_mst_designations_DesignationId",
                        column: x => x.DesignationId,
                        principalSchema: "master",
                        principalTable: "mst_designations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_tbl_onfloorrole_tbl_roles_RbacRoleId",
                        column: x => x.RbacRoleId,
                        principalSchema: "auth",
                        principalTable: "tbl_roles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateIndex(
                name: "IX_tbl_onfloorrole_DepartmentId",
                schema: "resource",
                table: "tbl_onfloorrole",
                column: "DepartmentId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_onfloorrole_DesignationId",
                schema: "resource",
                table: "tbl_onfloorrole",
                column: "DesignationId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_tbl_onfloorrole_Name",
                schema: "resource",
                table: "tbl_onfloorrole",
                column: "Name");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_onfloorrole_RbacRoleId",
                schema: "resource",
                table: "tbl_onfloorrole",
                column: "RbacRoleId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "tbl_onfloorrole",
                schema: "resource");
        }
    }
}
