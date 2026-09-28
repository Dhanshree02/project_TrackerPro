using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddProjectDraftsTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "project_drafts",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ProjectName = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    ClientId = table.Column<Guid>(type: "uuid", nullable: true),
                    ClientName = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    SalesPerson = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: true),
                    FormSnapshotJson = table.Column<string>(type: "jsonb", nullable: false),
                    CreatedByName = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    UpdatedByName = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: true),
                    Status = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: false, defaultValue: "active"),
                    xmin = table.Column<uint>(type: "xid", rowVersion: true, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_project_drafts", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_project_drafts_ClientId",
                table: "project_drafts",
                column: "ClientId");

            migrationBuilder.CreateIndex(
                name: "IX_project_drafts_Status",
                table: "project_drafts",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_project_drafts_UpdatedAtUtc",
                table: "project_drafts",
                column: "UpdatedAtUtc");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "project_drafts");
        }
    }
}
