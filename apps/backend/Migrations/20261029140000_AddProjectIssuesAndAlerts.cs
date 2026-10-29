using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    [DbContext(typeof(AppDbContext))]
    [Migration("20261029140000_AddProjectIssuesAndAlerts")]
    public partial class AddProjectIssuesAndAlerts : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                CREATE TABLE IF NOT EXISTS project.tbl_project_issues (
                    "Id" uuid NOT NULL,
                    "ProjectId" uuid NOT NULL,
                    "ProjectCode" character varying(50),
                    "ProjectName" character varying(300) NOT NULL,
                    "IssueType" character varying(100) NOT NULL,
                    "Priority" character varying(20) NOT NULL,
                    "Subject" character varying(300) NOT NULL,
                    "Description" text NOT NULL,
                    "Status" character varying(30) NOT NULL DEFAULT 'Open',
                    "RaisedByEmployeeId" uuid,
                    "RaisedByName" character varying(200) NOT NULL,
                    "RaisedByRole" character varying(100),
                    "CreatedAtUtc" timestamp with time zone NOT NULL DEFAULT NOW(),
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone,
                    CONSTRAINT "PK_tbl_project_issues" PRIMARY KEY ("Id"),
                    CONSTRAINT "FK_tbl_project_issues_projects"
                        FOREIGN KEY ("ProjectId") REFERENCES project.tbl_projects ("Id") ON DELETE CASCADE,
                    CONSTRAINT "FK_tbl_project_issues_employees"
                        FOREIGN KEY ("RaisedByEmployeeId") REFERENCES resource.tbl_employees ("Id") ON DELETE SET NULL
                );

                CREATE INDEX IF NOT EXISTS "IX_tbl_project_issues_ProjectId"
                    ON project.tbl_project_issues ("ProjectId");
                CREATE INDEX IF NOT EXISTS "IX_tbl_project_issues_RaisedByEmployeeId"
                    ON project.tbl_project_issues ("RaisedByEmployeeId");

                CREATE TABLE IF NOT EXISTS project.tbl_project_alerts (
                    "Id" uuid NOT NULL,
                    "ProjectId" uuid NOT NULL,
                    "IssueId" uuid,
                    "Title" character varying(300) NOT NULL,
                    "Description" text,
                    "AlertType" character varying(50) NOT NULL DEFAULT 'Issue',
                    "Priority" character varying(20) NOT NULL DEFAULT 'Medium',
                    "Status" character varying(30) NOT NULL DEFAULT 'Open',
                    "RaisedByEmployeeId" uuid,
                    "RaisedByName" character varying(200) NOT NULL,
                    "AudienceUserIds" text,
                    "CreatedAtUtc" timestamp with time zone NOT NULL DEFAULT NOW(),
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone,
                    CONSTRAINT "PK_tbl_project_alerts" PRIMARY KEY ("Id"),
                    CONSTRAINT "FK_tbl_project_alerts_projects"
                        FOREIGN KEY ("ProjectId") REFERENCES project.tbl_projects ("Id") ON DELETE CASCADE,
                    CONSTRAINT "FK_tbl_project_alerts_issues"
                        FOREIGN KEY ("IssueId") REFERENCES project.tbl_project_issues ("Id") ON DELETE CASCADE,
                    CONSTRAINT "FK_tbl_project_alerts_employees"
                        FOREIGN KEY ("RaisedByEmployeeId") REFERENCES resource.tbl_employees ("Id") ON DELETE SET NULL
                );

                CREATE INDEX IF NOT EXISTS "IX_tbl_project_alerts_ProjectId"
                    ON project.tbl_project_alerts ("ProjectId");
                CREATE INDEX IF NOT EXISTS "IX_tbl_project_alerts_IssueId"
                    ON project.tbl_project_alerts ("IssueId");
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                DROP TABLE IF EXISTS project.tbl_project_alerts;
                DROP TABLE IF EXISTS project.tbl_project_issues;
                """);
        }
    }
}
