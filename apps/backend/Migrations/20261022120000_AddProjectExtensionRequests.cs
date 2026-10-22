using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    [DbContext(typeof(AppDbContext))]
    [Migration("20261022120000_AddProjectExtensionRequests")]
    public partial class AddProjectExtensionRequests : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                CREATE TABLE IF NOT EXISTS project.tbl_project_extension_requests (
                    "Id" uuid NOT NULL,
                    "ProjectId" uuid NOT NULL,
                    "CurrentEndDate" date NOT NULL,
                    "RequestedEndDate" date NOT NULL,
                    "ExtensionDays" integer NOT NULL,
                    "Reason" text NOT NULL,
                    "Status" character varying(20) NOT NULL,
                    "RequestedByEmployeeId" uuid,
                    "RequestedByName" character varying(200) NOT NULL,
                    "CreatedAtUtc" timestamp with time zone NOT NULL,
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone,
                    CONSTRAINT "PK_tbl_project_extension_requests" PRIMARY KEY ("Id"),
                    CONSTRAINT "FK_tbl_project_extension_requests_tbl_projects_ProjectId"
                        FOREIGN KEY ("ProjectId") REFERENCES project.tbl_projects ("Id") ON DELETE CASCADE
                );

                CREATE INDEX IF NOT EXISTS "IX_tbl_project_extension_requests_ProjectId"
                    ON project.tbl_project_extension_requests ("ProjectId");

                CREATE TABLE IF NOT EXISTS project.tbl_project_extension_approvers (
                    "Id" uuid NOT NULL,
                    "ExtensionRequestId" uuid NOT NULL,
                    "EmployeeId" uuid NOT NULL,
                    "EmployeeName" character varying(200) NOT NULL,
                    "Status" character varying(20) NOT NULL,
                    "CreatedAtUtc" timestamp with time zone NOT NULL,
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone,
                    CONSTRAINT "PK_tbl_project_extension_approvers" PRIMARY KEY ("Id"),
                    CONSTRAINT "FK_tbl_project_extension_approvers_tbl_project_extension_requests_ExtensionRequestId"
                        FOREIGN KEY ("ExtensionRequestId") REFERENCES project.tbl_project_extension_requests ("Id") ON DELETE CASCADE
                );

                CREATE INDEX IF NOT EXISTS "IX_tbl_project_extension_approvers_ExtensionRequestId"
                    ON project.tbl_project_extension_approvers ("ExtensionRequestId");

                CREATE INDEX IF NOT EXISTS "IX_tbl_project_extension_approvers_EmployeeId"
                    ON project.tbl_project_extension_approvers ("EmployeeId");
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                DROP TABLE IF EXISTS project.tbl_project_extension_approvers;
                DROP TABLE IF EXISTS project.tbl_project_extension_requests;
                """);
        }
    }
}
