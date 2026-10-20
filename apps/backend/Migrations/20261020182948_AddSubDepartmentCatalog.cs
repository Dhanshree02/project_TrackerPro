using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddSubDepartmentCatalog : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "SubDepartmentId",
                schema: "resource",
                table: "tbl_employees",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "mst_sub_departments",
                schema: "master",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Code = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    Name = table.Column<string>(type: "character varying(250)", maxLength: 250, nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    DepartmentId = table.Column<Guid>(type: "uuid", nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_mst_sub_departments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_mst_sub_departments_mst_departments_DepartmentId",
                        column: x => x.DepartmentId,
                        principalSchema: "master",
                        principalTable: "mst_departments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "mst_designation_sub_departments",
                schema: "master",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    DesignationId = table.Column<Guid>(type: "uuid", nullable: false),
                    SubDepartmentId = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_mst_designation_sub_departments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_mst_designation_sub_departments_mst_designations_Designatio~",
                        column: x => x.DesignationId,
                        principalSchema: "master",
                        principalTable: "mst_designations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_mst_designation_sub_departments_mst_sub_departments_SubDepa~",
                        column: x => x.SubDepartmentId,
                        principalSchema: "master",
                        principalTable: "mst_sub_departments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "mst_org_role_sub_departments",
                schema: "master",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    OrgRoleMapId = table.Column<Guid>(type: "uuid", nullable: false),
                    SubDepartmentId = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_mst_org_role_sub_departments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_mst_org_role_sub_departments_mst_org_role_map_OrgRoleMapId",
                        column: x => x.OrgRoleMapId,
                        principalSchema: "master",
                        principalTable: "mst_org_role_map",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_mst_org_role_sub_departments_mst_sub_departments_SubDepartm~",
                        column: x => x.SubDepartmentId,
                        principalSchema: "master",
                        principalTable: "mst_sub_departments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "tbl_onfloorrole_subdepartment",
                schema: "resource",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    OnFloorRoleId = table.Column<Guid>(type: "uuid", nullable: false),
                    SubDepartmentId = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tbl_onfloorrole_subdepartment", x => x.Id);
                    table.ForeignKey(
                        name: "FK_tbl_onfloorrole_subdepartment_mst_sub_departments_SubDepart~",
                        column: x => x.SubDepartmentId,
                        principalSchema: "master",
                        principalTable: "mst_sub_departments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_tbl_onfloorrole_subdepartment_tbl_onfloorrole_OnFloorRoleId",
                        column: x => x.OnFloorRoleId,
                        principalSchema: "resource",
                        principalTable: "tbl_onfloorrole",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_tbl_employees_SubDepartmentId",
                schema: "resource",
                table: "tbl_employees",
                column: "SubDepartmentId");

            migrationBuilder.CreateIndex(
                name: "IX_mst_designation_sub_departments_DesignationId_SubDepartment~",
                schema: "master",
                table: "mst_designation_sub_departments",
                columns: new[] { "DesignationId", "SubDepartmentId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_mst_designation_sub_departments_SubDepartmentId",
                schema: "master",
                table: "mst_designation_sub_departments",
                column: "SubDepartmentId");

            migrationBuilder.CreateIndex(
                name: "IX_mst_org_role_sub_departments_OrgRoleMapId_SubDepartmentId",
                schema: "master",
                table: "mst_org_role_sub_departments",
                columns: new[] { "OrgRoleMapId", "SubDepartmentId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_mst_org_role_sub_departments_SubDepartmentId",
                schema: "master",
                table: "mst_org_role_sub_departments",
                column: "SubDepartmentId");

            migrationBuilder.CreateIndex(
                name: "IX_mst_sub_departments_Code",
                schema: "master",
                table: "mst_sub_departments",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_mst_sub_departments_DepartmentId",
                schema: "master",
                table: "mst_sub_departments",
                column: "DepartmentId");

            migrationBuilder.CreateIndex(
                name: "IX_mst_sub_departments_Name",
                schema: "master",
                table: "mst_sub_departments",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_tbl_onfloorrole_subdepartment_OnFloorRoleId_SubDepartmentId",
                schema: "resource",
                table: "tbl_onfloorrole_subdepartment",
                columns: new[] { "OnFloorRoleId", "SubDepartmentId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_tbl_onfloorrole_subdepartment_SubDepartmentId",
                schema: "resource",
                table: "tbl_onfloorrole_subdepartment",
                column: "SubDepartmentId");

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_employees_mst_sub_departments_SubDepartmentId",
                schema: "resource",
                table: "tbl_employees",
                column: "SubDepartmentId",
                principalSchema: "master",
                principalTable: "mst_sub_departments",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_tbl_employees_mst_sub_departments_SubDepartmentId",
                schema: "resource",
                table: "tbl_employees");

            migrationBuilder.DropTable(
                name: "mst_designation_sub_departments",
                schema: "master");

            migrationBuilder.DropTable(
                name: "mst_org_role_sub_departments",
                schema: "master");

            migrationBuilder.DropTable(
                name: "tbl_onfloorrole_subdepartment",
                schema: "resource");

            migrationBuilder.DropTable(
                name: "mst_sub_departments",
                schema: "master");

            migrationBuilder.DropIndex(
                name: "IX_tbl_employees_SubDepartmentId",
                schema: "resource",
                table: "tbl_employees");

            migrationBuilder.DropColumn(
                name: "SubDepartmentId",
                schema: "resource",
                table: "tbl_employees");
        }
    }
}
