using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddTabSubModuleId : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_mst_tabs_OneParent",
                schema: "master",
                table: "mst_tabs");

            migrationBuilder.AddColumn<Guid>(
                name: "SubModuleId",
                schema: "master",
                table: "mst_tabs",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_mst_tabs_SubModuleId",
                schema: "master",
                table: "mst_tabs",
                column: "SubModuleId");

            migrationBuilder.AddCheckConstraint(
                name: "CK_mst_tabs_OneParent",
                schema: "master",
                table: "mst_tabs",
                sql: "(\"ModuleId\" IS NOT NULL AND \"SubModuleId\" IS NULL AND \"TabId\" IS NULL) OR (\"ModuleId\" IS NULL AND \"SubModuleId\" IS NOT NULL AND \"TabId\" IS NULL) OR (\"ModuleId\" IS NULL AND \"SubModuleId\" IS NULL AND \"TabId\" IS NOT NULL)");

            migrationBuilder.AddForeignKey(
                name: "FK_mst_tabs_mst_submodules_SubModuleId",
                schema: "master",
                table: "mst_tabs",
                column: "SubModuleId",
                principalSchema: "master",
                principalTable: "mst_submodules",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_mst_tabs_mst_submodules_SubModuleId",
                schema: "master",
                table: "mst_tabs");

            migrationBuilder.DropIndex(
                name: "IX_mst_tabs_SubModuleId",
                schema: "master",
                table: "mst_tabs");

            migrationBuilder.DropCheckConstraint(
                name: "CK_mst_tabs_OneParent",
                schema: "master",
                table: "mst_tabs");

            migrationBuilder.DropColumn(
                name: "SubModuleId",
                schema: "master",
                table: "mst_tabs");

            migrationBuilder.AddCheckConstraint(
                name: "CK_mst_tabs_OneParent",
                schema: "master",
                table: "mst_tabs",
                sql: "(\"ModuleId\" IS NOT NULL AND \"TabId\" IS NULL) OR (\"ModuleId\" IS NULL AND \"TabId\" IS NOT NULL)");
        }
    }
}
