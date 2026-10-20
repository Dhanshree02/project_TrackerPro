using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddProjectInterviews : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                CREATE TABLE IF NOT EXISTS project.tbl_project_interviews (
                    "Id" uuid NOT NULL,
                    "ProjectId" uuid NOT NULL,
                    "EmployeeId" uuid NOT NULL,
                    "ResourceName" character varying(200) NOT NULL,
                    "InterviewDate" date NOT NULL,
                    "InterviewTime" time without time zone NOT NULL,
                    "Result" character varying(20) NOT NULL,
                    "Comments" text,
                    "CreatedAtUtc" timestamp with time zone NOT NULL,
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone,
                    CONSTRAINT "PK_tbl_project_interviews" PRIMARY KEY ("Id"),
                    CONSTRAINT "FK_tbl_project_interviews_tbl_projects_ProjectId"
                        FOREIGN KEY ("ProjectId") REFERENCES project.tbl_projects ("Id") ON DELETE CASCADE
                );

                CREATE INDEX IF NOT EXISTS "IX_tbl_project_interviews_ProjectId"
                    ON project.tbl_project_interviews ("ProjectId");

                CREATE INDEX IF NOT EXISTS "IX_tbl_project_interviews_EmployeeId"
                    ON project.tbl_project_interviews ("EmployeeId");
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                DROP TABLE IF EXISTS project.tbl_project_interviews;
                """);
        }
    }
}
