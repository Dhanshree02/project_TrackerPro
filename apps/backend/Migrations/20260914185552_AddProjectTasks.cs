using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddProjectTasks : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "project_tasks",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ProjectId = table.Column<Guid>(type: "uuid", nullable: false),
                    ProjectServiceId = table.Column<Guid>(type: "uuid", nullable: true),
                    Title = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    Description = table.Column<string>(type: "text", nullable: true),
                    Period = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: true),
                    Phase = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    Stage = table.Column<string>(type: "character varying(60)", maxLength: 60, nullable: false),
                    Priority = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    PlannedStartDate = table.Column<DateOnly>(type: "date", nullable: true),
                    PlannedEndDate = table.Column<DateOnly>(type: "date", nullable: true),
                    ActualStartDate = table.Column<DateOnly>(type: "date", nullable: true),
                    ActualEndDate = table.Column<DateOnly>(type: "date", nullable: true),
                    EstimatedHours = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: true),
                    UtilizedHours = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: false),
                    Progress = table.Column<int>(type: "integer", nullable: false),
                    SortOrder = table.Column<int>(type: "integer", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_project_tasks", x => x.Id);
                    table.ForeignKey(
                        name: "FK_project_tasks_project_services_ProjectServiceId",
                        column: x => x.ProjectServiceId,
                        principalTable: "project_services",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_project_tasks_projects_ProjectId",
                        column: x => x.ProjectId,
                        principalTable: "projects",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_project_tasks_Priority",
                table: "project_tasks",
                column: "Priority");

            migrationBuilder.CreateIndex(
                name: "IX_project_tasks_ProjectId",
                table: "project_tasks",
                column: "ProjectId");

            migrationBuilder.CreateIndex(
                name: "IX_project_tasks_ProjectServiceId",
                table: "project_tasks",
                column: "ProjectServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_project_tasks_Stage",
                table: "project_tasks",
                column: "Stage");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "project_tasks");
        }
    }
}
