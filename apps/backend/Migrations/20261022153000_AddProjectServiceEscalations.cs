using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    [DbContext(typeof(AppDbContext))]
    [Migration("20261022153000_AddProjectServiceEscalations")]
    public partial class AddProjectServiceEscalations : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                CREATE TABLE IF NOT EXISTS project.tbl_project_service_escalations (
                    "Id" uuid NOT NULL,
                    "ProjectId" uuid NOT NULL,
                    "ProjectServiceId" uuid,
                    "ProjectCode" character varying(40),
                    "ProjectName" character varying(300) NOT NULL,
                    "CustomerName" character varying(200),
                    "ServiceName" character varying(200) NOT NULL,
                    "EscalationType" character varying(80) NOT NULL,
                    "Priority" character varying(20) NOT NULL,
                    "Subject" character varying(300) NOT NULL,
                    "Description" text NOT NULL,
                    "ExpectedResolutionDate" date,
                    "AttachmentFileName" character varying(260),
                    "AttachmentPath" character varying(500),
                    "AttachmentContentType" character varying(120),
                    "AttachmentSizeBytes" bigint,
                    "Status" character varying(20) NOT NULL,
                    "RaisedByEmployeeId" uuid,
                    "RaisedByName" character varying(200) NOT NULL,
                    "CreatedAtUtc" timestamp with time zone NOT NULL,
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone,
                    CONSTRAINT "PK_tbl_project_service_escalations" PRIMARY KEY ("Id"),
                    CONSTRAINT "FK_tbl_project_service_escalations_projects"
                        FOREIGN KEY ("ProjectId") REFERENCES project.tbl_projects ("Id") ON DELETE CASCADE
                );

                CREATE INDEX IF NOT EXISTS "IX_tbl_project_service_escalations_ProjectId"
                    ON project.tbl_project_service_escalations ("ProjectId");
                CREATE INDEX IF NOT EXISTS "IX_tbl_project_service_escalations_ProjectServiceId"
                    ON project.tbl_project_service_escalations ("ProjectServiceId");

                CREATE TABLE IF NOT EXISTS project.tbl_project_service_escalation_stakeholders (
                    "Id" uuid NOT NULL,
                    "EscalationId" uuid NOT NULL,
                    "EmployeeId" uuid NOT NULL,
                    "EmployeeName" character varying(200) NOT NULL,
                    "SubDepartment" character varying(160) NOT NULL,
                    "Status" character varying(20) NOT NULL,
                    "CreatedAtUtc" timestamp with time zone NOT NULL,
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone,
                    CONSTRAINT "PK_tbl_project_service_escalation_stakeholders" PRIMARY KEY ("Id"),
                    CONSTRAINT "FK_tbl_svc_escalation_stakeholders_escalation"
                        FOREIGN KEY ("EscalationId") REFERENCES project.tbl_project_service_escalations ("Id") ON DELETE CASCADE
                );

                CREATE INDEX IF NOT EXISTS "IX_tbl_svc_escalation_stakeholders_EscalationId"
                    ON project.tbl_project_service_escalation_stakeholders ("EscalationId");
                CREATE INDEX IF NOT EXISTS "IX_tbl_svc_escalation_stakeholders_EmployeeId"
                    ON project.tbl_project_service_escalation_stakeholders ("EmployeeId");
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                DROP TABLE IF EXISTS project.tbl_project_service_escalation_stakeholders;
                DROP TABLE IF EXISTS project.tbl_project_service_escalations;
                """);
        }
    }
}
