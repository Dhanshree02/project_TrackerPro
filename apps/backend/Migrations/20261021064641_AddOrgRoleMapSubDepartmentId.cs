using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddOrgRoleMapSubDepartmentId : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "SubDepartmentId",
                schema: "master",
                table: "mst_org_role_map",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_mst_org_role_map_SubDepartmentId",
                schema: "master",
                table: "mst_org_role_map",
                column: "SubDepartmentId");

            migrationBuilder.AddForeignKey(
                name: "FK_mst_org_role_map_mst_sub_departments_SubDepartmentId",
                schema: "master",
                table: "mst_org_role_map",
                column: "SubDepartmentId",
                principalSchema: "master",
                principalTable: "mst_sub_departments",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.Sql(
                """
                UPDATE master.mst_org_role_map AS map
                SET "SubDepartmentId" = link."SubDepartmentId"
                FROM (
                    SELECT "OrgRoleMapId", (array_agg("SubDepartmentId"))[1] AS "SubDepartmentId"
                    FROM master.mst_org_role_sub_departments
                    GROUP BY "OrgRoleMapId"
                    HAVING COUNT(*) = 1
                ) AS link
                WHERE map."Id" = link."OrgRoleMapId";
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_mst_org_role_map_mst_sub_departments_SubDepartmentId",
                schema: "master",
                table: "mst_org_role_map");

            migrationBuilder.DropIndex(
                name: "IX_mst_org_role_map_SubDepartmentId",
                schema: "master",
                table: "mst_org_role_map");

            migrationBuilder.DropColumn(
                name: "SubDepartmentId",
                schema: "master",
                table: "mst_org_role_map");
        }
    }
}
