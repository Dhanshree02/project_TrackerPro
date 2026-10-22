using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class MoveOnFloorSubDepartmentToMaster : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_tbl_onfloorrole_subdepartment_mst_sub_departments_SubDepart~",
                schema: "resource",
                table: "tbl_onfloorrole_subdepartment");

            migrationBuilder.DropForeignKey(
                name: "FK_tbl_onfloorrole_subdepartment_tbl_onfloorrole_OnFloorRoleId",
                schema: "resource",
                table: "tbl_onfloorrole_subdepartment");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tbl_onfloorrole_subdepartment",
                schema: "resource",
                table: "tbl_onfloorrole_subdepartment");

            migrationBuilder.RenameTable(
                name: "tbl_onfloorrole_subdepartment",
                schema: "resource",
                newName: "mst_onfloorrole_sub_departments",
                newSchema: "master");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_onfloorrole_subdepartment_SubDepartmentId",
                schema: "master",
                table: "mst_onfloorrole_sub_departments",
                newName: "IX_mst_onfloorrole_sub_departments_SubDepartmentId");

            migrationBuilder.RenameIndex(
                name: "IX_tbl_onfloorrole_subdepartment_OnFloorRoleId_SubDepartmentId",
                schema: "master",
                table: "mst_onfloorrole_sub_departments",
                newName: "IX_mst_onfloorrole_sub_departments_OnFloorRoleId_SubDepartment~");

            migrationBuilder.AddPrimaryKey(
                name: "PK_mst_onfloorrole_sub_departments",
                schema: "master",
                table: "mst_onfloorrole_sub_departments",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_mst_onfloorrole_sub_departments_mst_sub_departments_SubDepa~",
                schema: "master",
                table: "mst_onfloorrole_sub_departments",
                column: "SubDepartmentId",
                principalSchema: "master",
                principalTable: "mst_sub_departments",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_mst_onfloorrole_sub_departments_tbl_onfloorrole_OnFloorRole~",
                schema: "master",
                table: "mst_onfloorrole_sub_departments",
                column: "OnFloorRoleId",
                principalSchema: "resource",
                principalTable: "tbl_onfloorrole",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_mst_onfloorrole_sub_departments_mst_sub_departments_SubDepa~",
                schema: "master",
                table: "mst_onfloorrole_sub_departments");

            migrationBuilder.DropForeignKey(
                name: "FK_mst_onfloorrole_sub_departments_tbl_onfloorrole_OnFloorRole~",
                schema: "master",
                table: "mst_onfloorrole_sub_departments");

            migrationBuilder.DropPrimaryKey(
                name: "PK_mst_onfloorrole_sub_departments",
                schema: "master",
                table: "mst_onfloorrole_sub_departments");

            migrationBuilder.RenameTable(
                name: "mst_onfloorrole_sub_departments",
                schema: "master",
                newName: "tbl_onfloorrole_subdepartment",
                newSchema: "resource");

            migrationBuilder.RenameIndex(
                name: "IX_mst_onfloorrole_sub_departments_SubDepartmentId",
                schema: "resource",
                table: "tbl_onfloorrole_subdepartment",
                newName: "IX_tbl_onfloorrole_subdepartment_SubDepartmentId");

            migrationBuilder.RenameIndex(
                name: "IX_mst_onfloorrole_sub_departments_OnFloorRoleId_SubDepartment~",
                schema: "resource",
                table: "tbl_onfloorrole_subdepartment",
                newName: "IX_tbl_onfloorrole_subdepartment_OnFloorRoleId_SubDepartmentId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_tbl_onfloorrole_subdepartment",
                schema: "resource",
                table: "tbl_onfloorrole_subdepartment",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_onfloorrole_subdepartment_mst_sub_departments_SubDepart~",
                schema: "resource",
                table: "tbl_onfloorrole_subdepartment",
                column: "SubDepartmentId",
                principalSchema: "master",
                principalTable: "mst_sub_departments",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_onfloorrole_subdepartment_tbl_onfloorrole_OnFloorRoleId",
                schema: "resource",
                table: "tbl_onfloorrole_subdepartment",
                column: "OnFloorRoleId",
                principalSchema: "resource",
                principalTable: "tbl_onfloorrole",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
