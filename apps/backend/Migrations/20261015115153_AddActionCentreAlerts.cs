using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddActionCentreAlerts : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_mst_service_departments_Name",
                schema: "master",
                table: "mst_service_departments");

            migrationBuilder.EnsureSchema(
                name: "action_centre");

            migrationBuilder.CreateTable(
                name: "tbl_alerts",
                schema: "action_centre",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    AlertCode = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Title = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    Description = table.Column<string>(type: "text", nullable: false),
                    Category = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Severity = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    ProjectId = table.Column<Guid>(type: "uuid", nullable: true),
                    ProjectName = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    ClientId = table.Column<Guid>(type: "uuid", nullable: true),
                    ClientName = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    SourceEntity = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    SourceEntityId = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    TriggerCondition = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    OwnerEmployeeId = table.Column<Guid>(type: "uuid", nullable: true),
                    OwnerName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    ResolutionDetails = table.Column<string>(type: "text", nullable: true),
                    AcknowledgedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    AcknowledgedByUserId = table.Column<Guid>(type: "uuid", nullable: true),
                    AcknowledgedByName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    ResolvedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    ResolvedByUserId = table.Column<Guid>(type: "uuid", nullable: true),
                    ResolvedByName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    AuditHistoryJson = table.Column<string>(type: "text", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tbl_alerts", x => x.Id);
                    table.ForeignKey(
                        name: "FK_tbl_alerts_tbl_clients_ClientId",
                        column: x => x.ClientId,
                        principalSchema: "customer",
                        principalTable: "tbl_clients",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_tbl_alerts_tbl_projects_ProjectId",
                        column: x => x.ProjectId,
                        principalSchema: "project",
                        principalTable: "tbl_projects",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "tbl_approval_requests",
                schema: "action_centre",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    RequestCode = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    ApprovalType = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    ProjectId = table.Column<Guid>(type: "uuid", nullable: true),
                    ProjectName = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: true),
                    EmployeeName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    Department = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    Title = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    Description = table.Column<string>(type: "text", nullable: false),
                    RequestedByEmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    RequestedByName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    RequestedByRole = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    AssignedApproverRole = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    AssignedApproverEmployeeId = table.Column<Guid>(type: "uuid", nullable: true),
                    AssignedApproverName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    Status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    Priority = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    PayloadJson = table.Column<string>(type: "text", nullable: false),
                    DecisionNotes = table.Column<string>(type: "text", nullable: true),
                    DecidedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    DecidedByUserId = table.Column<Guid>(type: "uuid", nullable: true),
                    DecidedByName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    AuditHistoryJson = table.Column<string>(type: "text", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tbl_approval_requests", x => x.Id);
                    table.ForeignKey(
                        name: "FK_tbl_approval_requests_tbl_projects_ProjectId",
                        column: x => x.ProjectId,
                        principalSchema: "project",
                        principalTable: "tbl_projects",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "tbl_bench_resource_snapshots",
                schema: "action_centre",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    SnapshotDate = table.Column<DateOnly>(type: "date", nullable: false),
                    TimeSlot = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    TotalBenchCount = table.Column<int>(type: "integer", nullable: false),
                    BillableCount = table.Column<int>(type: "integer", nullable: false),
                    NonBillableCount = table.Column<int>(type: "integer", nullable: false),
                    DepartmentBreakdownJson = table.Column<string>(type: "text", nullable: false),
                    EmployeeListJson = table.Column<string>(type: "text", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tbl_bench_resource_snapshots", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "tbl_project_issues",
                schema: "project",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ProjectId = table.Column<Guid>(type: "uuid", nullable: false),
                    Title = table.Column<string>(type: "character varying(250)", maxLength: 250, nullable: false),
                    Description = table.Column<string>(type: "character varying(4000)", maxLength: 4000, nullable: false),
                    Category = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Priority = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Status = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    RaisedByEmployeeId = table.Column<Guid>(type: "uuid", nullable: true),
                    RaisedByName = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    RaisedByRole = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    EscalationLevel = table.Column<int>(type: "integer", nullable: false),
                    CurrentAssigneeRole = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    CurrentAssigneeEmployeeId = table.Column<Guid>(type: "uuid", nullable: true),
                    CurrentAssigneeName = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: true),
                    DottedLineManagerId = table.Column<Guid>(type: "uuid", nullable: true),
                    DottedLineManagerName = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: true),
                    LastEscalatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    ResolvedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    ResolvedByName = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: true),
                    ResolutionNotes = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true),
                    AuditHistoryJson = table.Column<string>(type: "text", nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tbl_project_issues", x => x.Id);
                    table.ForeignKey(
                        name: "FK_tbl_project_issues_tbl_employees_RaisedByEmployeeId",
                        column: x => x.RaisedByEmployeeId,
                        principalSchema: "resource",
                        principalTable: "tbl_employees",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_tbl_project_issues_tbl_projects_ProjectId",
                        column: x => x.ProjectId,
                        principalSchema: "project",
                        principalTable: "tbl_projects",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_mst_service_departments_GroupId_Name",
                schema: "master",
                table: "mst_service_departments",
                columns: new[] { "GroupId", "Name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_tbl_alerts_AlertCode",
                schema: "action_centre",
                table: "tbl_alerts",
                column: "AlertCode",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_tbl_alerts_Category_SourceEntityId_Status",
                schema: "action_centre",
                table: "tbl_alerts",
                columns: new[] { "Category", "SourceEntityId", "Status" });

            migrationBuilder.CreateIndex(
                name: "IX_tbl_alerts_Category_Status",
                schema: "action_centre",
                table: "tbl_alerts",
                columns: new[] { "Category", "Status" });

            migrationBuilder.CreateIndex(
                name: "IX_tbl_alerts_ClientId",
                schema: "action_centre",
                table: "tbl_alerts",
                column: "ClientId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_alerts_CreatedAtUtc",
                schema: "action_centre",
                table: "tbl_alerts",
                column: "CreatedAtUtc");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_alerts_ProjectId",
                schema: "action_centre",
                table: "tbl_alerts",
                column: "ProjectId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_approval_requests_ApprovalType_Status",
                schema: "action_centre",
                table: "tbl_approval_requests",
                columns: new[] { "ApprovalType", "Status" });

            migrationBuilder.CreateIndex(
                name: "IX_tbl_approval_requests_CreatedAtUtc",
                schema: "action_centre",
                table: "tbl_approval_requests",
                column: "CreatedAtUtc");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_approval_requests_ProjectId",
                schema: "action_centre",
                table: "tbl_approval_requests",
                column: "ProjectId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_approval_requests_RequestCode",
                schema: "action_centre",
                table: "tbl_approval_requests",
                column: "RequestCode",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_tbl_approval_requests_RequestedByEmployeeId",
                schema: "action_centre",
                table: "tbl_approval_requests",
                column: "RequestedByEmployeeId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_bench_resource_snapshots_SnapshotDate_TimeSlot",
                schema: "action_centre",
                table: "tbl_bench_resource_snapshots",
                columns: new[] { "SnapshotDate", "TimeSlot" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_tbl_project_issues_CurrentAssigneeEmployeeId",
                schema: "project",
                table: "tbl_project_issues",
                column: "CurrentAssigneeEmployeeId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_project_issues_EscalationLevel",
                schema: "project",
                table: "tbl_project_issues",
                column: "EscalationLevel");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_project_issues_ProjectId",
                schema: "project",
                table: "tbl_project_issues",
                column: "ProjectId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_project_issues_RaisedByEmployeeId",
                schema: "project",
                table: "tbl_project_issues",
                column: "RaisedByEmployeeId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_project_issues_Status",
                schema: "project",
                table: "tbl_project_issues",
                column: "Status");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "tbl_alerts",
                schema: "action_centre");

            migrationBuilder.DropTable(
                name: "tbl_approval_requests",
                schema: "action_centre");

            migrationBuilder.DropTable(
                name: "tbl_bench_resource_snapshots",
                schema: "action_centre");

            migrationBuilder.DropTable(
                name: "tbl_project_issues",
                schema: "project");

            migrationBuilder.DropIndex(
                name: "IX_mst_service_departments_GroupId_Name",
                schema: "master",
                table: "mst_service_departments");

            migrationBuilder.CreateIndex(
                name: "IX_mst_service_departments_Name",
                schema: "master",
                table: "mst_service_departments",
                column: "Name",
                unique: true);
        }
    }
}
