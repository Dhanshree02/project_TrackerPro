using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddMasterCatalogs : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "EngagementManagerId",
                table: "clients",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "IndustryId",
                table: "clients",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "client_contacts",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ClientId = table.Column<Guid>(type: "uuid", nullable: true),
                    SubVentureId = table.Column<Guid>(type: "uuid", nullable: true),
                    Name = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: true),
                    Email = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    Phone = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: true),
                    Designation = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: true),
                    ContactType = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: true),
                    IsPrimary = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_client_contacts", x => x.Id);
                    table.CheckConstraint("CK_client_contacts_exactly_one_owner", "(\"ClientId\" IS NOT NULL AND \"SubVentureId\" IS NULL) OR (\"ClientId\" IS NULL AND \"SubVentureId\" IS NOT NULL)");
                    table.ForeignKey(
                        name: "FK_client_contacts_clients_ClientId",
                        column: x => x.ClientId,
                        principalTable: "clients",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_client_contacts_sub_ventures_SubVentureId",
                        column: x => x.SubVentureId,
                        principalTable: "sub_ventures",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "exited_employees",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    OriginalEmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    EmployeeCode = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    FullName = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    DepartmentName = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: true),
                    DesignationName = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: true),
                    WorkEmail = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    PersonalEmail = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    Phone = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: true),
                    StatusAtExit = table.Column<string>(type: "character varying(60)", maxLength: 60, nullable: true),
                    ExitType = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    ExitReason = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    ResignationDate = table.Column<DateOnly>(type: "date", nullable: true),
                    LastWorkingDay = table.Column<DateOnly>(type: "date", nullable: true),
                    ReasonForLeaving = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    NoticePeriodServed = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    ExitChecklistJson = table.Column<string>(type: "jsonb", nullable: true),
                    AssetReturnJson = table.Column<string>(type: "jsonb", nullable: true),
                    FinalSettlementJson = table.Column<string>(type: "jsonb", nullable: true),
                    ExitedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    ExitedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_exited_employees", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "mst_departments",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Code = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Name = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_mst_departments", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "mst_industries",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Code = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    Name = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_mst_industries", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "mst_designations",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Code = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    Name = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    DepartmentId = table.Column<Guid>(type: "uuid", nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_mst_designations", x => x.Id);
                    table.ForeignKey(
                        name: "FK_mst_designations_mst_departments_DepartmentId",
                        column: x => x.DepartmentId,
                        principalTable: "mst_departments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "employees",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    EmployeeCode = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    FirstName = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    LastName = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    WorkEmail = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    PersonalEmail = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    Phone = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: true),
                    AltPhone = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: true),
                    Gender = table.Column<string>(type: "text", nullable: true),
                    DateOfBirth = table.Column<DateOnly>(type: "date", nullable: true),
                    Address = table.Column<string>(type: "text", nullable: true),
                    EmergencyContact = table.Column<string>(type: "text", nullable: true),
                    MaritalStatus = table.Column<string>(type: "text", nullable: true),
                    Nationality = table.Column<string>(type: "text", nullable: true),
                    DepartmentId = table.Column<Guid>(type: "uuid", nullable: true),
                    DesignationId = table.Column<Guid>(type: "uuid", nullable: true),
                    Role = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    ReportingManagerId = table.Column<Guid>(type: "uuid", nullable: true),
                    BusinessUnit = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: true),
                    WorkLocation = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: true),
                    OfficeBranch = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: true),
                    Category = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    Team = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: true),
                    ProjectSite = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    JoiningDate = table.Column<DateOnly>(type: "date", nullable: true),
                    Status = table.Column<string>(type: "character varying(60)", maxLength: 60, nullable: true),
                    ConfirmationStatus = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    ProbationStatus = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    Experience = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    PreviousCompany = table.Column<string>(type: "character varying(160)", maxLength: 160, nullable: true),
                    EmploymentType = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    ContractType = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    BondStatus = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    NoticePeriod = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    AssetId = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    ExitType = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    ExitReason = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    Education = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    Skills = table.Column<string>(type: "jsonb", nullable: false),
                    Certifications = table.Column<string>(type: "jsonb", nullable: false),
                    Languages = table.Column<string>(type: "jsonb", nullable: false),
                    KpiScore = table.Column<decimal>(type: "numeric", nullable: true),
                    QuarterlyKpi = table.Column<decimal>(type: "numeric", nullable: true),
                    AnnualRating = table.Column<decimal>(type: "numeric", nullable: true),
                    GoalCompletion = table.Column<decimal>(type: "numeric", nullable: true),
                    Attendance = table.Column<decimal>(type: "numeric", nullable: true),
                    ReportingEfficiency = table.Column<decimal>(type: "numeric", nullable: true),
                    PromotionReadiness = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: true),
                    ManagerFeedback = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    Pan = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: true),
                    BankAccount = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    SalaryBand = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: true),
                    PfUan = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: true),
                    TaxRegime = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    ComplianceStatus = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    UserId = table.Column<Guid>(type: "uuid", nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_employees", x => x.Id);
                    table.ForeignKey(
                        name: "FK_employees_employees_ReportingManagerId",
                        column: x => x.ReportingManagerId,
                        principalTable: "employees",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_employees_mst_departments_DepartmentId",
                        column: x => x.DepartmentId,
                        principalTable: "mst_departments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_employees_mst_designations_DesignationId",
                        column: x => x.DesignationId,
                        principalTable: "mst_designations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_employees_users_UserId",
                        column: x => x.UserId,
                        principalTable: "users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateIndex(
                name: "IX_clients_EngagementManagerId",
                table: "clients",
                column: "EngagementManagerId");

            migrationBuilder.CreateIndex(
                name: "IX_clients_IndustryId",
                table: "clients",
                column: "IndustryId");

            migrationBuilder.CreateIndex(
                name: "IX_client_contacts_ClientId",
                table: "client_contacts",
                column: "ClientId");

            migrationBuilder.CreateIndex(
                name: "IX_client_contacts_SubVentureId",
                table: "client_contacts",
                column: "SubVentureId");

            migrationBuilder.CreateIndex(
                name: "IX_employees_DepartmentId",
                table: "employees",
                column: "DepartmentId");

            migrationBuilder.CreateIndex(
                name: "IX_employees_DesignationId",
                table: "employees",
                column: "DesignationId");

            migrationBuilder.CreateIndex(
                name: "IX_employees_EmployeeCode",
                table: "employees",
                column: "EmployeeCode",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_employees_ReportingManagerId",
                table: "employees",
                column: "ReportingManagerId");

            migrationBuilder.CreateIndex(
                name: "IX_employees_UserId",
                table: "employees",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_employees_WorkEmail",
                table: "employees",
                column: "WorkEmail",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_exited_employees_EmployeeCode",
                table: "exited_employees",
                column: "EmployeeCode");

            migrationBuilder.CreateIndex(
                name: "IX_exited_employees_OriginalEmployeeId",
                table: "exited_employees",
                column: "OriginalEmployeeId");

            migrationBuilder.CreateIndex(
                name: "IX_mst_departments_Code",
                table: "mst_departments",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_mst_departments_Name",
                table: "mst_departments",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_mst_designations_Code",
                table: "mst_designations",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_mst_designations_DepartmentId",
                table: "mst_designations",
                column: "DepartmentId");

            migrationBuilder.CreateIndex(
                name: "IX_mst_industries_Code",
                table: "mst_industries",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_mst_industries_Name",
                table: "mst_industries",
                column: "Name",
                unique: true);

            migrationBuilder.Sql(
                """
                INSERT INTO mst_departments ("Id","Code","Name","IsActive","CreatedAtUtc")
                VALUES
                (gen_random_uuid(),'product','Product',true,now()),
                (gen_random_uuid(),'design','Design',true,now()),
                (gen_random_uuid(),'marketing','Marketing',true,now()),
                (gen_random_uuid(),'sales','Sales',true,now()),
                (gen_random_uuid(),'finance','Finance',true,now()),
                (gen_random_uuid(),'human_resources','Human Resources',true,now()),
                (gen_random_uuid(),'operations','Operations',true,now()),
                (gen_random_uuid(),'engineering','Engineering',true,now()),
                (gen_random_uuid(),'delivery','Delivery',true,now()),
                (gen_random_uuid(),'leadership','Leadership',true,now())
                ON CONFLICT ("Code") DO NOTHING;
                """);

            migrationBuilder.Sql(
                """
                INSERT INTO mst_designations ("Id","Code","Name","IsActive","CreatedAtUtc")
                VALUES
                (gen_random_uuid(),'engineering_manager','Engineering Manager',true,now()),
                (gen_random_uuid(),'product_manager','Product Manager',true,now()),
                (gen_random_uuid(),'ux_designer','UX Designer',true,now()),
                (gen_random_uuid(),'marketing_lead','Marketing Lead',true,now()),
                (gen_random_uuid(),'sales_executive','Sales Executive',true,now()),
                (gen_random_uuid(),'finance_analyst','Finance Analyst',true,now()),
                (gen_random_uuid(),'hr_business_partner','HR Business Partner',true,now()),
                (gen_random_uuid(),'software_engineer','Software Engineer',true,now()),
                (gen_random_uuid(),'senior_software_engineer','Senior Software Engineer',true,now()),
                (gen_random_uuid(),'tech_lead','Tech Lead',true,now()),
                (gen_random_uuid(),'devops_engineer','DevOps Engineer',true,now()),
                (gen_random_uuid(),'qa_engineer','QA Engineer',true,now()),
                (gen_random_uuid(),'data_analyst','Data Analyst',true,now()),
                (gen_random_uuid(),'content_strategist','Content Strategist',true,now()),
                (gen_random_uuid(),'business_analyst','Business Analyst',true,now()),
                (gen_random_uuid(),'project_manager','Project Manager',true,now()),
                (gen_random_uuid(),'engagement_manager','Engagement Manager',true,now()),
                (gen_random_uuid(),'senior_project_manager','Senior Project Manager',true,now()),
                (gen_random_uuid(),'head_of_department','Head of Department',true,now())
                ON CONFLICT ("Code") DO NOTHING;
                """);

            migrationBuilder.Sql(
                """
                INSERT INTO mst_industries ("Id","Code","Name","IsActive","CreatedAtUtc")
                SELECT gen_random_uuid(),
                       lower(regexp_replace(trim("Industry"), '[^a-zA-Z0-9]+', '_', 'g')),
                       trim("Industry"),
                       true,
                       now()
                FROM clients
                WHERE "Industry" IS NOT NULL AND trim("Industry") <> ''
                ON CONFLICT ("Name") DO NOTHING;
                """);

            migrationBuilder.Sql(
                """
                INSERT INTO employees (
                    "Id","EmployeeCode","FirstName","LastName","WorkEmail","Status","Category","Role","UserId",
                    "Skills","Certifications","Languages","CreatedAtUtc"
                )
                SELECT
                    gen_random_uuid(),
                    u."EmployeeId",
                    split_part(u."Name", ' ', 1),
                    nullif(trim(substring(u."Name" from position(' ' in u."Name") + 1)), ''),
                    u."Email",
                    'Active',
                    'Permanent - Without Bond',
                    r."Name",
                    u."Id",
                    '[]'::jsonb,
                    '[]'::jsonb,
                    '[]'::jsonb,
                    now()
                FROM users u
                LEFT JOIN roles r ON r."Id" = u."RoleId"
                WHERE NOT EXISTS (
                    SELECT 1 FROM employees e WHERE e."EmployeeCode" = u."EmployeeId"
                );
                """);

            migrationBuilder.Sql(
                """
                UPDATE clients c
                SET "IndustryId" = i."Id"
                FROM mst_industries i
                WHERE trim(c."Industry") = i."Name";
                """);

            migrationBuilder.Sql(
                """
                UPDATE clients c
                SET "EngagementManagerId" = e."Id"
                FROM employees e
                WHERE trim(c."EngagementManager") = trim(concat(e."FirstName", ' ', coalesce(e."LastName", '')));
                """);

            migrationBuilder.Sql(
                """
                INSERT INTO client_contacts (
                    "Id","ClientId","SubVentureId","Name","Email","Phone","Designation","ContactType","IsPrimary","CreatedAtUtc"
                )
                SELECT
                    gen_random_uuid(),
                    c."Id",
                    NULL,
                    v->>'Name',
                    v->>'Email',
                    v->>'Phone',
                    v->>'Designation',
                    v->>'ContactType',
                    false,
                    now()
                FROM clients c,
                LATERAL jsonb_array_elements(coalesce(c.contacts, '[]'::jsonb)) v;
                """);

            migrationBuilder.Sql(
                """
                INSERT INTO client_contacts (
                    "Id","ClientId","SubVentureId","Name","Email","Phone","Designation","ContactType","IsPrimary","CreatedAtUtc"
                )
                SELECT
                    gen_random_uuid(),
                    NULL,
                    s."Id",
                    v->>'Name',
                    v->>'Email',
                    v->>'Phone',
                    v->>'Designation',
                    v->>'ContactType',
                    false,
                    now()
                FROM sub_ventures s,
                LATERAL jsonb_array_elements(coalesce(s.contacts, '[]'::jsonb)) v;
                """);

            migrationBuilder.DropColumn(
                name: "contacts",
                table: "sub_ventures");

            migrationBuilder.DropColumn(
                name: "contacts",
                table: "clients");

            migrationBuilder.AddForeignKey(
                name: "FK_clients_employees_EngagementManagerId",
                table: "clients",
                column: "EngagementManagerId",
                principalTable: "employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_clients_mst_industries_IndustryId",
                table: "clients",
                column: "IndustryId",
                principalTable: "mst_industries",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_clients_employees_EngagementManagerId",
                table: "clients");

            migrationBuilder.DropForeignKey(
                name: "FK_clients_mst_industries_IndustryId",
                table: "clients");

            migrationBuilder.DropTable(
                name: "client_contacts");

            migrationBuilder.DropTable(
                name: "employees");

            migrationBuilder.DropTable(
                name: "exited_employees");

            migrationBuilder.DropTable(
                name: "mst_industries");

            migrationBuilder.DropTable(
                name: "mst_designations");

            migrationBuilder.DropTable(
                name: "mst_departments");

            migrationBuilder.DropIndex(
                name: "IX_clients_EngagementManagerId",
                table: "clients");

            migrationBuilder.DropIndex(
                name: "IX_clients_IndustryId",
                table: "clients");

            migrationBuilder.DropColumn(
                name: "EngagementManagerId",
                table: "clients");

            migrationBuilder.DropColumn(
                name: "IndustryId",
                table: "clients");

            migrationBuilder.AddColumn<string>(
                name: "contacts",
                table: "sub_ventures",
                type: "jsonb",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "contacts",
                table: "clients",
                type: "jsonb",
                nullable: true);
        }
    }
}
