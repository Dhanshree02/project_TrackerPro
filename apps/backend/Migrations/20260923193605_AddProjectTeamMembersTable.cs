using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddProjectTeamMembersTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "project_team_members",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ProjectId = table.Column<Guid>(type: "uuid", nullable: false),
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    DepartmentId = table.Column<Guid>(type: "uuid", nullable: true),
                    SubDepartment = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    AllocationStartDate = table.Column<DateOnly>(type: "date", nullable: false),
                    AllocationEndDate = table.Column<DateOnly>(type: "date", nullable: false),
                    Billability = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: false),
                    IsTeamLead = table.Column<bool>(type: "boolean", nullable: false),
                    ResourceType = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_project_team_members", x => x.Id);
                    table.ForeignKey(
                        name: "FK_project_team_members_employees_EmployeeId",
                        column: x => x.EmployeeId,
                        principalTable: "employees",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_project_team_members_mst_departments_DepartmentId",
                        column: x => x.DepartmentId,
                        principalTable: "mst_departments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_project_team_members_projects_ProjectId",
                        column: x => x.ProjectId,
                        principalTable: "projects",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_project_team_members_DepartmentId",
                table: "project_team_members",
                column: "DepartmentId");

            migrationBuilder.CreateIndex(
                name: "IX_project_team_members_EmployeeId",
                table: "project_team_members",
                column: "EmployeeId");

            migrationBuilder.CreateIndex(
                name: "IX_project_team_members_ProjectId",
                table: "project_team_members",
                column: "ProjectId");

            migrationBuilder.CreateIndex(
                name: "IX_project_team_members_ProjectId_EmployeeId",
                table: "project_team_members",
                columns: new[] { "ProjectId", "EmployeeId" },
                unique: true,
                filter: "\"DeletedAtUtc\" IS NULL");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "project_team_members");
        }
    }
}
