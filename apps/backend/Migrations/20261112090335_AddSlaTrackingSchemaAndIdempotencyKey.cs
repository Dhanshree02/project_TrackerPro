using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddSlaTrackingSchemaAndIdempotencyKey : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.EnsureSchema(
                name: "action");

            migrationBuilder.EnsureSchema(
                name: "sla");

            migrationBuilder.AddColumn<string>(
                name: "TaskType",
                schema: "project",
                table: "tbl_project_tasks",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ChangeStatus",
                schema: "project",
                table: "tbl_project_services",
                type: "character varying(40)",
                maxLength: 40,
                nullable: false,
                defaultValue: "Active");

            migrationBuilder.AddColumn<string>(
                name: "ModBillingStatus",
                schema: "project",
                table: "tbl_project_services",
                type: "character varying(40)",
                maxLength: 40,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ModCollectionStatus",
                schema: "project",
                table: "tbl_project_services",
                type: "character varying(40)",
                maxLength: 40,
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "ModIsReady",
                schema: "project",
                table: "tbl_project_services",
                type: "boolean",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ModValidationStatus",
                schema: "project",
                table: "tbl_project_services",
                type: "character varying(40)",
                maxLength: 40,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "OriginalQty",
                schema: "project",
                table: "tbl_project_services",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "PendingQty",
                schema: "project",
                table: "tbl_project_services",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PendingResourceLevel",
                schema: "project",
                table: "tbl_project_services",
                type: "character varying(80)",
                maxLength: 80,
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "PendingUnitPrice",
                schema: "project",
                table: "tbl_project_services",
                type: "numeric(18,2)",
                precision: 18,
                scale: 2,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ServiceAbbreviation",
                schema: "project",
                table: "tbl_project_services",
                type: "character varying(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ChatJson",
                schema: "project",
                table: "tbl_project_service_escalations",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "ProjectServiceId",
                schema: "project",
                table: "tbl_project_invoices",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CommentsJson",
                schema: "project",
                table: "tbl_project_extension_requests",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "HistoryJson",
                schema: "project",
                table: "tbl_project_extension_requests",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Abbreviation",
                schema: "master",
                table: "mst_service_catalog",
                type: "character varying(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.CreateTable(
                name: "mst_leave_calendar",
                schema: "master",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    HolidayDate = table.Column<DateOnly>(type: "date", nullable: false),
                    Name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Year = table.Column<int>(type: "integer", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_mst_leave_calendar", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "tbl_bucket_tasks",
                schema: "action",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TaskId = table.Column<Guid>(type: "uuid", nullable: false),
                    ProjectId = table.Column<Guid>(type: "uuid", nullable: false),
                    ProjectServiceId = table.Column<Guid>(type: "uuid", nullable: true),
                    AssignmentId = table.Column<Guid>(type: "uuid", nullable: true),
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    AssignedById = table.Column<Guid>(type: "uuid", nullable: true),
                    AssignedByName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    TaskTitle = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    ProjectName = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    Priority = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false, defaultValue: "Medium"),
                    DueDate = table.Column<DateOnly>(type: "date", nullable: true),
                    Status = table.Column<string>(type: "character varying(60)", maxLength: 60, nullable: false, defaultValue: "Not Started"),
                    ActualStartDate = table.Column<DateOnly>(type: "date", nullable: true),
                    ActualEndDate = table.Column<DateOnly>(type: "date", nullable: true),
                    TimerRunning = table.Column<bool>(type: "boolean", nullable: false),
                    TimerStartedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    TimerAccumulatedSeconds = table.Column<long>(type: "bigint", nullable: false),
                    UtilizedHours = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tbl_bucket_tasks", x => x.Id);
                    table.ForeignKey(
                        name: "FK_tbl_bucket_tasks_tbl_employees_EmployeeId",
                        column: x => x.EmployeeId,
                        principalSchema: "resource",
                        principalTable: "tbl_employees",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_tbl_bucket_tasks_tbl_project_services_ProjectServiceId",
                        column: x => x.ProjectServiceId,
                        principalSchema: "project",
                        principalTable: "tbl_project_services",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_tbl_bucket_tasks_tbl_project_task_assignments_AssignmentId",
                        column: x => x.AssignmentId,
                        principalSchema: "project",
                        principalTable: "tbl_project_task_assignments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_tbl_bucket_tasks_tbl_project_tasks_TaskId",
                        column: x => x.TaskId,
                        principalSchema: "project",
                        principalTable: "tbl_project_tasks",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_tbl_bucket_tasks_tbl_projects_ProjectId",
                        column: x => x.ProjectId,
                        principalSchema: "project",
                        principalTable: "tbl_projects",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "tbl_project_additional_requirements",
                schema: "project",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    RequirementId = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    ProjectId = table.Column<Guid>(type: "uuid", nullable: false),
                    ClientName = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    ProjectName = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    RequirementType = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false, defaultValue: "Add Service"),
                    Title = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    Description = table.Column<string>(type: "text", nullable: false),
                    Priority = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false, defaultValue: "Medium"),
                    RequestedByEmployeeId = table.Column<Guid>(type: "uuid", nullable: true),
                    RequestedByName = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    RequestedDate = table.Column<DateOnly>(type: "date", nullable: false),
                    AttachmentFileName = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    AttachmentPath = table.Column<string>(type: "text", nullable: true),
                    ScopeCancellationService = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    Status = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false, defaultValue: "Open"),
                    ApprovedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    ApprovedByEmployeeId = table.Column<Guid>(type: "uuid", nullable: true),
                    ApprovedByName = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    ApprovalComments = table.Column<string>(type: "text", nullable: true),
                    CommentsJson = table.Column<string>(type: "text", nullable: false, defaultValue: "[]"),
                    HistoryJson = table.Column<string>(type: "text", nullable: false, defaultValue: "[]"),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tbl_project_additional_requirements", x => x.Id);
                    table.ForeignKey(
                        name: "FK_tbl_project_additional_requirements_tbl_projects_ProjectId",
                        column: x => x.ProjectId,
                        principalSchema: "project",
                        principalTable: "tbl_projects",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "tbl_project_appreciations",
                schema: "project",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ProjectId = table.Column<Guid>(type: "uuid", nullable: false),
                    RecipientEmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    RecipientName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    RecipientEmail = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    RecipientRole = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    Badge = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false, defaultValue: "Star Performer"),
                    Message = table.Column<string>(type: "text", nullable: false),
                    GivenByEmployeeId = table.Column<Guid>(type: "uuid", nullable: true),
                    GivenByName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tbl_project_appreciations", x => x.Id);
                    table.ForeignKey(
                        name: "FK_tbl_project_appreciations_tbl_projects_ProjectId",
                        column: x => x.ProjectId,
                        principalSchema: "project",
                        principalTable: "tbl_projects",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "tbl_project_feedbacks",
                schema: "project",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ProjectId = table.Column<Guid>(type: "uuid", nullable: false),
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    EmployeeName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    EmployeeCode = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    ReportingManagerId = table.Column<Guid>(type: "uuid", nullable: true),
                    ReportingManagerName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    SubmittedByEmployeeId = table.Column<Guid>(type: "uuid", nullable: true),
                    SubmittedByName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    FeedbackType = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false, defaultValue: "DirectFeedback"),
                    Strengths = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    AreasOfImprovement = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    Comments = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    Rating = table.Column<int>(type: "integer", nullable: true),
                    RequestNote = table.Column<string>(type: "text", nullable: true),
                    Status = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false, defaultValue: "Submitted"),
                    CommentsJson = table.Column<string>(type: "text", nullable: true),
                    HistoryJson = table.Column<string>(type: "text", nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tbl_project_feedbacks", x => x.Id);
                    table.ForeignKey(
                        name: "FK_tbl_project_feedbacks_tbl_projects_ProjectId",
                        column: x => x.ProjectId,
                        principalSchema: "project",
                        principalTable: "tbl_projects",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "tbl_project_issues",
                schema: "project",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ProjectId = table.Column<Guid>(type: "uuid", nullable: false),
                    ProjectCode = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    ProjectName = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: false),
                    IssueType = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Priority = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Subject = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: false),
                    Description = table.Column<string>(type: "text", nullable: false),
                    Status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    RaisedByEmployeeId = table.Column<Guid>(type: "uuid", nullable: true),
                    RaisedByName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    RaisedByRole = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
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

            migrationBuilder.CreateTable(
                name: "tbl_resource_allocation_requests",
                schema: "project",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ProjectId = table.Column<Guid>(type: "uuid", nullable: false),
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    DepartmentId = table.Column<Guid>(type: "uuid", nullable: true),
                    SubDepartment = table.Column<string>(type: "text", nullable: true),
                    AllocationStartDate = table.Column<DateOnly>(type: "date", nullable: false),
                    AllocationEndDate = table.Column<DateOnly>(type: "date", nullable: false),
                    Billability = table.Column<string>(type: "text", nullable: false),
                    IsTeamLead = table.Column<bool>(type: "boolean", nullable: false),
                    ResourceType = table.Column<string>(type: "text", nullable: false),
                    IsShadowTeam = table.Column<bool>(type: "boolean", nullable: false),
                    Status = table.Column<string>(type: "text", nullable: false),
                    RequestedByEmployeeId = table.Column<Guid>(type: "uuid", nullable: true),
                    RequestedByName = table.Column<string>(type: "text", nullable: true),
                    ApproverEmployeeId = table.Column<Guid>(type: "uuid", nullable: true),
                    ApproverName = table.Column<string>(type: "text", nullable: true),
                    CommentsJson = table.Column<string>(type: "text", nullable: true),
                    HistoryJson = table.Column<string>(type: "text", nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tbl_resource_allocation_requests", x => x.Id);
                    table.ForeignKey(
                        name: "FK_tbl_resource_allocation_requests_mst_departments_Department~",
                        column: x => x.DepartmentId,
                        principalSchema: "master",
                        principalTable: "mst_departments",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_tbl_resource_allocation_requests_tbl_employees_EmployeeId",
                        column: x => x.EmployeeId,
                        principalSchema: "resource",
                        principalTable: "tbl_employees",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_tbl_resource_allocation_requests_tbl_projects_ProjectId",
                        column: x => x.ProjectId,
                        principalSchema: "project",
                        principalTable: "tbl_projects",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "tbl_role_permissions",
                schema: "auth",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    RoleId = table.Column<Guid>(type: "uuid", nullable: false),
                    ItemId = table.Column<Guid>(type: "uuid", nullable: false),
                    ItemType = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    CanView = table.Column<short>(type: "smallint", nullable: false, defaultValue: (short)0),
                    CanManage = table.Column<short>(type: "smallint", nullable: false, defaultValue: (short)0),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tbl_role_permissions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_tbl_role_permissions_tbl_roles_RoleId",
                        column: x => x.RoleId,
                        principalSchema: "auth",
                        principalTable: "tbl_roles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "tbl_sla_policies",
                schema: "sla",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    module = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    activitytype = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    stage = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false, defaultValue: "Default"),
                    name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    description = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    tatdurationminutes = table.Column<int>(type: "integer", nullable: false),
                    calculationmode = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false, defaultValue: "WorkingHours"),
                    workinghoursstart = table.Column<TimeSpan>(type: "interval", nullable: true),
                    workinghoursend = table.Column<TimeSpan>(type: "interval", nullable: true),
                    excludeweekends = table.Column<bool>(type: "boolean", nullable: false),
                    excludeholidays = table.Column<bool>(type: "boolean", nullable: false),
                    reminderintervalsminutesjson = table.Column<string>(type: "text", nullable: false, defaultValue: "[]"),
                    firstescalationafterminutes = table.Column<int>(type: "integer", nullable: true),
                    secondescalationafterminutes = table.Column<int>(type: "integer", nullable: true),
                    responsiblerolesjson = table.Column<string>(type: "text", nullable: false, defaultValue: "[]"),
                    firstescalationrolesjson = table.Column<string>(type: "text", nullable: false, defaultValue: "[]"),
                    secondescalationrolesjson = table.Column<string>(type: "text", nullable: false, defaultValue: "[]"),
                    isactive = table.Column<bool>(type: "boolean", nullable: false),
                    metadatajson = table.Column<string>(type: "text", nullable: false, defaultValue: "{}"),
                    createdatutc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updatedatutc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    createdby = table.Column<Guid>(type: "uuid", nullable: true),
                    updatedby = table.Column<Guid>(type: "uuid", nullable: true),
                    deletedatutc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tbl_sla_policies", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "tbl_notifications",
                schema: "action",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    RecipientEmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    ProjectId = table.Column<Guid>(type: "uuid", nullable: true),
                    ProjectCode = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    ProjectName = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    Title = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    Type = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false, defaultValue: "Issue Raised"),
                    Priority = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false, defaultValue: "Medium"),
                    Status = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false, defaultValue: "Pending"),
                    Unread = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    RaisedByEmployeeId = table.Column<Guid>(type: "uuid", nullable: true),
                    RaisedByName = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false, defaultValue: "System"),
                    RelatedTask = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    IssueId = table.Column<Guid>(type: "uuid", nullable: true),
                    HistoryJson = table.Column<string>(type: "text", nullable: false, defaultValue: "[]"),
                    CommentsJson = table.Column<string>(type: "text", nullable: false, defaultValue: "[]"),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tbl_notifications", x => x.Id);
                    table.ForeignKey(
                        name: "FK_tbl_notifications_tbl_employees_RecipientEmployeeId",
                        column: x => x.RecipientEmployeeId,
                        principalSchema: "resource",
                        principalTable: "tbl_employees",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_tbl_notifications_tbl_project_issues_IssueId",
                        column: x => x.IssueId,
                        principalSchema: "project",
                        principalTable: "tbl_project_issues",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_tbl_notifications_tbl_projects_ProjectId",
                        column: x => x.ProjectId,
                        principalSchema: "project",
                        principalTable: "tbl_projects",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "tbl_project_alerts",
                schema: "project",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ProjectId = table.Column<Guid>(type: "uuid", nullable: false),
                    IssueId = table.Column<Guid>(type: "uuid", nullable: true),
                    Title = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: false),
                    Description = table.Column<string>(type: "text", nullable: true),
                    AlertType = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Priority = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    RaisedByEmployeeId = table.Column<Guid>(type: "uuid", nullable: true),
                    RaisedByName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    AudienceUserIds = table.Column<string>(type: "text", nullable: true),
                    Owner = table.Column<string>(type: "text", nullable: true),
                    ResolutionOwner = table.Column<string>(type: "text", nullable: true),
                    EscalationOwner = table.Column<string>(type: "text", nullable: true),
                    ResolutionDetails = table.Column<string>(type: "text", nullable: true),
                    HistoryJson = table.Column<string>(type: "text", nullable: false),
                    StatusChangedBy = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    StatusChangedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    AttachmentFileName = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    AttachmentPath = table.Column<string>(type: "text", nullable: true),
                    ExpectedResolutionDate = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    ServiceName = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    EscalationType = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    EscalatedTo = table.Column<string>(type: "text", nullable: true),
                    ServiceEscalationId = table.Column<Guid>(type: "uuid", nullable: true),
                    ChatJson = table.Column<string>(type: "text", nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tbl_project_alerts", x => x.Id);
                    table.ForeignKey(
                        name: "FK_tbl_project_alerts_tbl_employees_RaisedByEmployeeId",
                        column: x => x.RaisedByEmployeeId,
                        principalSchema: "resource",
                        principalTable: "tbl_employees",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_tbl_project_alerts_tbl_project_issues_IssueId",
                        column: x => x.IssueId,
                        principalSchema: "project",
                        principalTable: "tbl_project_issues",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_tbl_project_alerts_tbl_projects_ProjectId",
                        column: x => x.ProjectId,
                        principalSchema: "project",
                        principalTable: "tbl_projects",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "tbl_sla_instances",
                schema: "sla",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    policyid = table.Column<Guid>(type: "uuid", nullable: false),
                    module = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    activitytype = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    entityid = table.Column<Guid>(type: "uuid", nullable: false),
                    entityreference = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    currentstage = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false, defaultValue: "Default"),
                    status = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false, defaultValue: "Tracking"),
                    priority = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false, defaultValue: "Medium"),
                    startedatutc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    targetdeadlineutc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    breachedatutc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    completedatutc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    cancelledatutc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    pausedatutc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    totalpausedseconds = table.Column<int>(type: "integer", nullable: false),
                    activehangfirejobid = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    recipientemployeeid = table.Column<Guid>(type: "uuid", nullable: true),
                    projectid = table.Column<Guid>(type: "uuid", nullable: true),
                    custompayloadjson = table.Column<string>(type: "text", nullable: false, defaultValue: "{}"),
                    createdatutc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updatedatutc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    createdby = table.Column<Guid>(type: "uuid", nullable: true),
                    updatedby = table.Column<Guid>(type: "uuid", nullable: true),
                    deletedatutc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tbl_sla_instances", x => x.id);
                    table.ForeignKey(
                        name: "FK_tbl_sla_instances_tbl_sla_policies_policyid",
                        column: x => x.policyid,
                        principalSchema: "sla",
                        principalTable: "tbl_sla_policies",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "tbl_sla_events",
                schema: "sla",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    instanceid = table.Column<Guid>(type: "uuid", nullable: false),
                    eventtype = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    scheduledatutc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    executedatutc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    hangfirejobid = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    status = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false, defaultValue: "Scheduled"),
                    stageatexecution = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false, defaultValue: "Default"),
                    targetrolesjson = table.Column<string>(type: "text", nullable: false, defaultValue: "[]"),
                    targetrecipientidsjson = table.Column<string>(type: "text", nullable: false, defaultValue: "[]"),
                    executionlog = table.Column<string>(type: "text", nullable: true),
                    retrycount = table.Column<int>(type: "integer", nullable: false),
                    idempotencykey = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: true),
                    createdatutc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updatedatutc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    createdby = table.Column<Guid>(type: "uuid", nullable: true),
                    updatedby = table.Column<Guid>(type: "uuid", nullable: true),
                    deletedatutc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tbl_sla_events", x => x.id);
                    table.ForeignKey(
                        name: "FK_tbl_sla_events_tbl_sla_instances_instanceid",
                        column: x => x.instanceid,
                        principalSchema: "sla",
                        principalTable: "tbl_sla_instances",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_tbl_project_invoices_ProjectServiceId",
                schema: "project",
                table: "tbl_project_invoices",
                column: "ProjectServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_mst_leave_calendar_HolidayDate",
                schema: "master",
                table: "mst_leave_calendar",
                column: "HolidayDate",
                unique: true,
                filter: "\"DeletedAtUtc\" IS NULL");

            migrationBuilder.CreateIndex(
                name: "IX_mst_leave_calendar_Year",
                schema: "master",
                table: "mst_leave_calendar",
                column: "Year",
                filter: "\"DeletedAtUtc\" IS NULL");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_bucket_tasks_AssignmentId",
                schema: "action",
                table: "tbl_bucket_tasks",
                column: "AssignmentId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_bucket_tasks_EmployeeId",
                schema: "action",
                table: "tbl_bucket_tasks",
                column: "EmployeeId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_bucket_tasks_Priority",
                schema: "action",
                table: "tbl_bucket_tasks",
                column: "Priority");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_bucket_tasks_ProjectId",
                schema: "action",
                table: "tbl_bucket_tasks",
                column: "ProjectId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_bucket_tasks_ProjectServiceId",
                schema: "action",
                table: "tbl_bucket_tasks",
                column: "ProjectServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_bucket_tasks_Status",
                schema: "action",
                table: "tbl_bucket_tasks",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_bucket_tasks_TaskId",
                schema: "action",
                table: "tbl_bucket_tasks",
                column: "TaskId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_bucket_tasks_TaskId_EmployeeId",
                schema: "action",
                table: "tbl_bucket_tasks",
                columns: new[] { "TaskId", "EmployeeId" });

            migrationBuilder.CreateIndex(
                name: "IX_tbl_notifications_IssueId",
                schema: "action",
                table: "tbl_notifications",
                column: "IssueId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_notifications_ProjectId_DeletedAtUtc",
                schema: "action",
                table: "tbl_notifications",
                columns: new[] { "ProjectId", "DeletedAtUtc" });

            migrationBuilder.CreateIndex(
                name: "IX_tbl_notifications_RecipientEmployeeId_DeletedAtUtc",
                schema: "action",
                table: "tbl_notifications",
                columns: new[] { "RecipientEmployeeId", "DeletedAtUtc" });

            migrationBuilder.CreateIndex(
                name: "IX_tbl_notifications_Status",
                schema: "action",
                table: "tbl_notifications",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_project_additional_requirements_ProjectId",
                schema: "project",
                table: "tbl_project_additional_requirements",
                column: "ProjectId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_project_additional_requirements_Status",
                schema: "project",
                table: "tbl_project_additional_requirements",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_project_alerts_IssueId",
                schema: "project",
                table: "tbl_project_alerts",
                column: "IssueId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_project_alerts_ProjectId",
                schema: "project",
                table: "tbl_project_alerts",
                column: "ProjectId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_project_alerts_RaisedByEmployeeId",
                schema: "project",
                table: "tbl_project_alerts",
                column: "RaisedByEmployeeId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_project_appreciations_ProjectId",
                schema: "project",
                table: "tbl_project_appreciations",
                column: "ProjectId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_project_appreciations_RecipientEmployeeId",
                schema: "project",
                table: "tbl_project_appreciations",
                column: "RecipientEmployeeId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_project_feedbacks_EmployeeId",
                schema: "project",
                table: "tbl_project_feedbacks",
                column: "EmployeeId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_project_feedbacks_FeedbackType",
                schema: "project",
                table: "tbl_project_feedbacks",
                column: "FeedbackType");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_project_feedbacks_ProjectId",
                schema: "project",
                table: "tbl_project_feedbacks",
                column: "ProjectId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_project_feedbacks_ReportingManagerId",
                schema: "project",
                table: "tbl_project_feedbacks",
                column: "ReportingManagerId");

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
                name: "IX_tbl_resource_allocation_requests_ApproverEmployeeId",
                schema: "project",
                table: "tbl_resource_allocation_requests",
                column: "ApproverEmployeeId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_resource_allocation_requests_DepartmentId",
                schema: "project",
                table: "tbl_resource_allocation_requests",
                column: "DepartmentId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_resource_allocation_requests_EmployeeId",
                schema: "project",
                table: "tbl_resource_allocation_requests",
                column: "EmployeeId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_resource_allocation_requests_ProjectId",
                schema: "project",
                table: "tbl_resource_allocation_requests",
                column: "ProjectId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_role_permissions_ItemId",
                schema: "auth",
                table: "tbl_role_permissions",
                column: "ItemId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_role_permissions_RoleId",
                schema: "auth",
                table: "tbl_role_permissions",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_role_permissions_RoleId_ItemId",
                schema: "auth",
                table: "tbl_role_permissions",
                columns: new[] { "RoleId", "ItemId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_tbl_sla_events_hangfirejobid",
                schema: "sla",
                table: "tbl_sla_events",
                column: "hangfirejobid");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_sla_events_idempotencykey",
                schema: "sla",
                table: "tbl_sla_events",
                column: "idempotencykey",
                unique: true,
                filter: "idempotencykey IS NOT NULL AND deletedatutc IS NULL");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_sla_events_instanceid_eventtype",
                schema: "sla",
                table: "tbl_sla_events",
                columns: new[] { "instanceid", "eventtype" });

            migrationBuilder.CreateIndex(
                name: "IX_tbl_sla_events_scheduledatutc",
                schema: "sla",
                table: "tbl_sla_events",
                column: "scheduledatutc");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_sla_events_status",
                schema: "sla",
                table: "tbl_sla_events",
                column: "status");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_sla_instances_entityid_activitytype_deletedatutc",
                schema: "sla",
                table: "tbl_sla_instances",
                columns: new[] { "entityid", "activitytype", "deletedatutc" });

            migrationBuilder.CreateIndex(
                name: "IX_tbl_sla_instances_policyid",
                schema: "sla",
                table: "tbl_sla_instances",
                column: "policyid");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_sla_instances_projectid",
                schema: "sla",
                table: "tbl_sla_instances",
                column: "projectid");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_sla_instances_recipientemployeeid",
                schema: "sla",
                table: "tbl_sla_instances",
                column: "recipientemployeeid");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_sla_instances_status",
                schema: "sla",
                table: "tbl_sla_instances",
                column: "status");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_sla_instances_targetdeadlineutc",
                schema: "sla",
                table: "tbl_sla_instances",
                column: "targetdeadlineutc");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_sla_policies_activitytype",
                schema: "sla",
                table: "tbl_sla_policies",
                column: "activitytype");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_sla_policies_isactive",
                schema: "sla",
                table: "tbl_sla_policies",
                column: "isactive");

            migrationBuilder.CreateIndex(
                name: "IX_tbl_sla_policies_module_activitytype_stage_deletedatutc",
                schema: "sla",
                table: "tbl_sla_policies",
                columns: new[] { "module", "activitytype", "stage", "deletedatutc" },
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_tbl_project_invoices_tbl_project_services_ProjectServiceId",
                schema: "project",
                table: "tbl_project_invoices",
                column: "ProjectServiceId",
                principalSchema: "project",
                principalTable: "tbl_project_services",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_tbl_project_invoices_tbl_project_services_ProjectServiceId",
                schema: "project",
                table: "tbl_project_invoices");

            migrationBuilder.DropTable(
                name: "mst_leave_calendar",
                schema: "master");

            migrationBuilder.DropTable(
                name: "tbl_bucket_tasks",
                schema: "action");

            migrationBuilder.DropTable(
                name: "tbl_notifications",
                schema: "action");

            migrationBuilder.DropTable(
                name: "tbl_project_additional_requirements",
                schema: "project");

            migrationBuilder.DropTable(
                name: "tbl_project_alerts",
                schema: "project");

            migrationBuilder.DropTable(
                name: "tbl_project_appreciations",
                schema: "project");

            migrationBuilder.DropTable(
                name: "tbl_project_feedbacks",
                schema: "project");

            migrationBuilder.DropTable(
                name: "tbl_resource_allocation_requests",
                schema: "project");

            migrationBuilder.DropTable(
                name: "tbl_role_permissions",
                schema: "auth");

            migrationBuilder.DropTable(
                name: "tbl_sla_events",
                schema: "sla");

            migrationBuilder.DropTable(
                name: "tbl_project_issues",
                schema: "project");

            migrationBuilder.DropTable(
                name: "tbl_sla_instances",
                schema: "sla");

            migrationBuilder.DropTable(
                name: "tbl_sla_policies",
                schema: "sla");

            migrationBuilder.DropIndex(
                name: "IX_tbl_project_invoices_ProjectServiceId",
                schema: "project",
                table: "tbl_project_invoices");

            migrationBuilder.DropColumn(
                name: "TaskType",
                schema: "project",
                table: "tbl_project_tasks");

            migrationBuilder.DropColumn(
                name: "ChangeStatus",
                schema: "project",
                table: "tbl_project_services");

            migrationBuilder.DropColumn(
                name: "ModBillingStatus",
                schema: "project",
                table: "tbl_project_services");

            migrationBuilder.DropColumn(
                name: "ModCollectionStatus",
                schema: "project",
                table: "tbl_project_services");

            migrationBuilder.DropColumn(
                name: "ModIsReady",
                schema: "project",
                table: "tbl_project_services");

            migrationBuilder.DropColumn(
                name: "ModValidationStatus",
                schema: "project",
                table: "tbl_project_services");

            migrationBuilder.DropColumn(
                name: "OriginalQty",
                schema: "project",
                table: "tbl_project_services");

            migrationBuilder.DropColumn(
                name: "PendingQty",
                schema: "project",
                table: "tbl_project_services");

            migrationBuilder.DropColumn(
                name: "PendingResourceLevel",
                schema: "project",
                table: "tbl_project_services");

            migrationBuilder.DropColumn(
                name: "PendingUnitPrice",
                schema: "project",
                table: "tbl_project_services");

            migrationBuilder.DropColumn(
                name: "ServiceAbbreviation",
                schema: "project",
                table: "tbl_project_services");

            migrationBuilder.DropColumn(
                name: "ChatJson",
                schema: "project",
                table: "tbl_project_service_escalations");

            migrationBuilder.DropColumn(
                name: "ProjectServiceId",
                schema: "project",
                table: "tbl_project_invoices");

            migrationBuilder.DropColumn(
                name: "CommentsJson",
                schema: "project",
                table: "tbl_project_extension_requests");

            migrationBuilder.DropColumn(
                name: "HistoryJson",
                schema: "project",
                table: "tbl_project_extension_requests");

            migrationBuilder.DropColumn(
                name: "Abbreviation",
                schema: "master",
                table: "mst_service_catalog");
        }
    }
}
