using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddModuleTabs : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "mst_tabs",
                schema: "master",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Code = table.Column<string>(type: "character varying(60)", maxLength: 60, nullable: false),
                    Name = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    SortOrder = table.Column<int>(type: "integer", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    ModuleId = table.Column<Guid>(type: "uuid", nullable: true),
                    TabId = table.Column<Guid>(type: "uuid", nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_mst_tabs", x => x.Id);
                    table.CheckConstraint("CK_mst_tabs_OneParent", "(\"ModuleId\" IS NOT NULL AND \"TabId\" IS NULL) OR (\"ModuleId\" IS NULL AND \"TabId\" IS NOT NULL)");
                    table.ForeignKey(
                        name: "FK_mst_tabs_mst_modules_ModuleId",
                        column: x => x.ModuleId,
                        principalSchema: "master",
                        principalTable: "mst_modules",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_mst_tabs_mst_tabs_TabId",
                        column: x => x.TabId,
                        principalSchema: "master",
                        principalTable: "mst_tabs",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_mst_tabs_Code",
                schema: "master",
                table: "mst_tabs",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_mst_tabs_ModuleId",
                schema: "master",
                table: "mst_tabs",
                column: "ModuleId");

            migrationBuilder.CreateIndex(
                name: "IX_mst_tabs_TabId",
                schema: "master",
                table: "mst_tabs",
                column: "TabId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "mst_tabs",
                schema: "master");
        }
    }
}
