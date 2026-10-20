using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class RemoveRbacPermissionsAndOnFloorRoles : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Widget catalog and grants were created outside EF. Drop them before the role column they reference.
            migrationBuilder.Sql("""
                DROP VIEW IF EXISTS auth.vw_role_widget_matrix;
                DROP TABLE IF EXISTS auth.tbl_role_widget_permissions;
                DROP TABLE IF EXISTS master.mst_widgets;
                DROP TABLE IF EXISTS master.mst_submodules;
                DROP TABLE IF EXISTS master.mst_modules;
                DROP TABLE IF EXISTS master.mst_rbac_baseline;
                """);

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_employees_mst_roles_JobRoleId",
                schema: "resource",
                table: "tbl_employees");

            migrationBuilder.DropForeignKey(
                name: "FK_mst_designations_mst_roles_JobRoleId",
                schema: "master",
                table: "mst_designations");

            migrationBuilder.DropForeignKey(
                name: "FK_mst_org_role_map_OnFloorRoleId",
                schema: "master",
                table: "mst_org_role_map");

            migrationBuilder.DropTable(
                name: "mst_roles",
                schema: "master");

            migrationBuilder.DropIndex(
                name: "IX_tbl_employees_JobRoleId",
                schema: "resource",
                table: "tbl_employees");

            migrationBuilder.DropIndex(
                name: "IX_mst_designations_JobRoleId",
                schema: "master",
                table: "mst_designations");

            migrationBuilder.DropIndex(
                name: "IX_mst_service_departments_Name",
                schema: "master",
                table: "mst_service_departments");

            migrationBuilder.DropColumn(
                name: "Permissions",
                schema: "auth",
                table: "tbl_roles");

            migrationBuilder.DropColumn(
                name: "JobRoleId",
                schema: "resource",
                table: "tbl_employees");

            migrationBuilder.DropColumn(
                name: "JobRoleId",
                schema: "master",
                table: "mst_designations");

            migrationBuilder.DropColumn(
                name: "OnFloorRoleId",
                schema: "master",
                table: "mst_org_role_map");

            migrationBuilder.CreateIndex(
                name: "IX_mst_service_departments_GroupId_Name",
                schema: "master",
                table: "mst_service_departments",
                columns: new[] { "GroupId", "Name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_mst_org_role_map_RbacRoleId",
                schema: "master",
                table: "mst_org_role_map",
                column: "RbacRoleId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_mst_org_role_map_RbacRoleId",
                schema: "master",
                table: "mst_org_role_map");

            migrationBuilder.DropIndex(
                name: "IX_mst_service_departments_GroupId_Name",
                schema: "master",
                table: "mst_service_departments");

            migrationBuilder.AddColumn<string>(
                name: "Permissions",
                schema: "auth",
                table: "tbl_roles",
                type: "jsonb",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<Guid>(
                name: "JobRoleId",
                schema: "resource",
                table: "tbl_employees",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "JobRoleId",
                schema: "master",
                table: "mst_designations",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "OnFloorRoleId",
                schema: "master",
                table: "mst_org_role_map",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "mst_roles",
                schema: "master",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    DesignationId = table.Column<Guid>(type: "uuid", nullable: false),
                    Code = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    Name = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_mst_roles", x => x.Id);
                    table.ForeignKey(
                        name: "FK_mst_roles_mst_designations_DesignationId",
                        column: x => x.DesignationId,
                        principalSchema: "master",
                        principalTable: "mst_designations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_tbl_employees_JobRoleId",
                schema: "resource",
                table: "tbl_employees",
                column: "JobRoleId");

            migrationBuilder.CreateIndex(
                name: "IX_mst_designations_JobRoleId",
                schema: "master",
                table: "mst_designations",
                column: "JobRoleId");

            migrationBuilder.CreateIndex(
                name: "IX_mst_service_departments_Name",
                schema: "master",
                table: "mst_service_departments",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_mst_roles_Code",
                schema: "master",
                table: "mst_roles",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_mst_roles_DesignationId_Name",
                schema: "master",
                table: "mst_roles",
                columns: new[] { "DesignationId", "Name" },
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_employees_mst_roles_JobRoleId",
                schema: "resource",
                table: "tbl_employees",
                column: "JobRoleId",
                principalSchema: "master",
                principalTable: "mst_roles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_mst_designations_mst_roles_JobRoleId",
                schema: "master",
                table: "mst_designations",
                column: "JobRoleId",
                principalSchema: "master",
                principalTable: "mst_roles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_mst_org_role_map_OnFloorRoleId",
                schema: "master",
                table: "mst_org_role_map",
                column: "OnFloorRoleId",
                principalSchema: "master",
                principalTable: "mst_roles",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }
    }
}
