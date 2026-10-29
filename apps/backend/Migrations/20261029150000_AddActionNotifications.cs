using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    [DbContext(typeof(AppDbContext))]
    [Migration("20261029150000_AddActionNotifications")]
    public partial class AddActionNotifications : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                CREATE TABLE IF NOT EXISTS action.tbl_notifications (
                    "Id" uuid NOT NULL,
                    "RecipientEmployeeId" uuid NOT NULL,
                    "ProjectId" uuid NOT NULL,
                    "ProjectCode" character varying(50),
                    "ProjectName" character varying(255) NOT NULL,
                    "Title" character varying(255) NOT NULL,
                    "Type" character varying(100) NOT NULL DEFAULT 'Issue Raised',
                    "Priority" character varying(20) NOT NULL DEFAULT 'Medium',
                    "Status" character varying(50) NOT NULL DEFAULT 'Pending',
                    "Unread" boolean NOT NULL DEFAULT true,
                    "RaisedByEmployeeId" uuid,
                    "RaisedByName" character varying(255) NOT NULL DEFAULT 'System',
                    "RelatedTask" character varying(255),
                    "IssueId" uuid,
                    "AcknowledgedBy" character varying(255),
                    "AcknowledgedDate" character varying(50),
                    "AcknowledgedTime" character varying(50),
                    "HistoryJson" text NOT NULL DEFAULT '[]',
                    "CreatedAtUtc" timestamp with time zone NOT NULL DEFAULT now(),
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone,
                    CONSTRAINT "PK_tbl_notifications" PRIMARY KEY ("Id"),
                    CONSTRAINT "FK_tbl_notifications_employees"
                        FOREIGN KEY ("RecipientEmployeeId") REFERENCES resource.tbl_employees ("Id") ON DELETE CASCADE,
                    CONSTRAINT "FK_tbl_notifications_projects"
                        FOREIGN KEY ("ProjectId") REFERENCES project.tbl_projects ("Id") ON DELETE CASCADE,
                    CONSTRAINT "FK_tbl_notifications_issues"
                        FOREIGN KEY ("IssueId") REFERENCES project.tbl_project_issues ("Id") ON DELETE SET NULL
                );

                CREATE INDEX IF NOT EXISTS "IX_tbl_notifications_RecipientEmployeeId"
                    ON action.tbl_notifications ("RecipientEmployeeId", "DeletedAtUtc");

                CREATE INDEX IF NOT EXISTS "IX_tbl_notifications_ProjectId"
                    ON action.tbl_notifications ("ProjectId", "DeletedAtUtc");

                CREATE INDEX IF NOT EXISTS "IX_tbl_notifications_Status"
                    ON action.tbl_notifications ("Status");
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("DROP TABLE IF EXISTS action.tbl_notifications CASCADE;");
        }
    }
}
