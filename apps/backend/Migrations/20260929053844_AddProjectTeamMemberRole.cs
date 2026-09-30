using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddProjectTeamMemberRole : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "MemberRole",
                table: "project_team_members",
                type: "character varying(40)",
                maxLength: 40,
                nullable: false,
                defaultValue: "ProjectTeam");

            migrationBuilder.Sql("""
                UPDATE project_team_members
                SET "MemberRole" = 'ShadowTeam'
                WHERE "IsShadowTeam" = TRUE
                  AND "DeletedAtUtc" IS NULL;

                UPDATE project_team_members AS m
                SET
                    "MemberRole" = 'ProjectManager',
                    "IsTeamLead" = FALSE,
                    "IsShadowTeam" = FALSE,
                    "AllocationStartDate" = COALESCE(p."StartDate", m."AllocationStartDate"),
                    "AllocationEndDate" = GREATEST(
                        COALESCE(p."EndDate", p."StartDate", m."AllocationEndDate"),
                        COALESCE(p."StartDate", m."AllocationStartDate")),
                    "DepartmentId" = e."DepartmentId",
                    "SubDepartment" = NULLIF(BTRIM(e."SubDepartment"), '')
                FROM projects AS p
                JOIN employees AS e ON e."Id" = p."ProjectManagerId"
                WHERE m."ProjectId" = p."Id"
                  AND m."EmployeeId" = p."ProjectManagerId"
                  AND m."DeletedAtUtc" IS NULL
                  AND p."DeletedAtUtc" IS NULL
                  AND e."DeletedAtUtc" IS NULL;

                INSERT INTO project_team_members (
                    "Id", "ProjectId", "EmployeeId", "DepartmentId", "SubDepartment",
                    "AllocationStartDate", "AllocationEndDate", "Billability", "IsTeamLead",
                    "ResourceType", "IsShadowTeam", "MemberRole", "CreatedAtUtc")
                SELECT
                    gen_random_uuid(),
                    p."Id",
                    p."ProjectManagerId",
                    e."DepartmentId",
                    NULLIF(BTRIM(e."SubDepartment"), ''),
                    COALESCE(p."StartDate", CURRENT_DATE),
                    GREATEST(
                        COALESCE(p."EndDate", p."StartDate", CURRENT_DATE),
                        COALESCE(p."StartDate", CURRENT_DATE)),
                    'Billable',
                    FALSE,
                    'Dedicated',
                    FALSE,
                    'ProjectManager',
                    NOW()
                FROM projects AS p
                JOIN employees AS e ON e."Id" = p."ProjectManagerId"
                WHERE p."DeletedAtUtc" IS NULL
                  AND e."DeletedAtUtc" IS NULL
                  AND NOT EXISTS (
                      SELECT 1
                      FROM project_team_members AS m
                      WHERE m."ProjectId" = p."Id"
                        AND m."EmployeeId" = p."ProjectManagerId"
                        AND m."DeletedAtUtc" IS NULL);
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
                DELETE FROM project_team_members
                WHERE "MemberRole" IN ('ProjectManager', 'SeniorProjectManager');
                """);

            migrationBuilder.DropColumn(
                name: "MemberRole",
                table: "project_team_members");
        }
    }
}
