using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddProjectsTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "projects",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ProjectCode = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    WbsId = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    Name = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    Description = table.Column<string>(type: "text", nullable: true),
                    ClientId = table.Column<Guid>(type: "uuid", nullable: false),
                    SubVentureId = table.Column<Guid>(type: "uuid", nullable: true),
                    Status = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: false),
                    Health = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Progress = table.Column<int>(type: "integer", nullable: false),
                    ContractType = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    ProjectType = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    Currency = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    TaxPercent = table.Column<decimal>(type: "numeric(5,2)", precision: 5, scale: 2, nullable: false),
                    StartDate = table.Column<DateOnly>(type: "date", nullable: true),
                    EndDate = table.Column<DateOnly>(type: "date", nullable: true),
                    Budget = table.Column<decimal>(type: "numeric(18,2)", precision: 18, scale: 2, nullable: true),
                    Spent = table.Column<decimal>(type: "numeric(18,2)", precision: 18, scale: 2, nullable: false),
                    TotalHours = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: true),
                    TotalDays = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: true),
                    InvoiceValue = table.Column<decimal>(type: "numeric(18,2)", precision: 18, scale: 2, nullable: true),
                    ProjectManagerId = table.Column<Guid>(type: "uuid", nullable: true),
                    TeamLeadId = table.Column<Guid>(type: "uuid", nullable: true),
                    EngagementManager = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: true),
                    EngagementManagerId = table.Column<Guid>(type: "uuid", nullable: true),
                    SalesPerson = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: true),
                    SalesPersonId = table.Column<Guid>(type: "uuid", nullable: true),
                    ProjectIssuedDate = table.Column<DateOnly>(type: "date", nullable: true),
                    SectionAComments = table.Column<string>(type: "text", nullable: true),
                    SectionBComments = table.Column<string>(type: "text", nullable: true),
                    WbsStatus = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: false),
                    WbsSubStatus = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    RenewedFromProjectId = table.Column<Guid>(type: "uuid", nullable: true),
                    PoStatus = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: true),
                    PoNumber = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    PoDate = table.Column<DateOnly>(type: "date", nullable: true),
                    BillingModel = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    PaymentTerms = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: true),
                    TargetDate = table.Column<DateOnly>(type: "date", nullable: true),
                    AccountContactName = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: true),
                    AccountContactPhone = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: true),
                    AccountContactEmail = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_projects", x => x.Id);
                    table.ForeignKey(
                        name: "FK_projects_clients_ClientId",
                        column: x => x.ClientId,
                        principalTable: "clients",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_projects_employees_EngagementManagerId",
                        column: x => x.EngagementManagerId,
                        principalTable: "employees",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_projects_employees_ProjectManagerId",
                        column: x => x.ProjectManagerId,
                        principalTable: "employees",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_projects_employees_SalesPersonId",
                        column: x => x.SalesPersonId,
                        principalTable: "employees",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_projects_employees_TeamLeadId",
                        column: x => x.TeamLeadId,
                        principalTable: "employees",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_projects_projects_RenewedFromProjectId",
                        column: x => x.RenewedFromProjectId,
                        principalTable: "projects",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_projects_sub_ventures_SubVentureId",
                        column: x => x.SubVentureId,
                        principalTable: "sub_ventures",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateIndex(
                name: "IX_projects_ClientId",
                table: "projects",
                column: "ClientId");

            migrationBuilder.CreateIndex(
                name: "IX_projects_EngagementManagerId",
                table: "projects",
                column: "EngagementManagerId");

            migrationBuilder.CreateIndex(
                name: "IX_projects_ProjectCode",
                table: "projects",
                column: "ProjectCode",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_projects_ProjectManagerId",
                table: "projects",
                column: "ProjectManagerId");

            migrationBuilder.CreateIndex(
                name: "IX_projects_RenewedFromProjectId",
                table: "projects",
                column: "RenewedFromProjectId");

            migrationBuilder.CreateIndex(
                name: "IX_projects_SalesPersonId",
                table: "projects",
                column: "SalesPersonId");

            migrationBuilder.CreateIndex(
                name: "IX_projects_Status",
                table: "projects",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_projects_SubVentureId",
                table: "projects",
                column: "SubVentureId");

            migrationBuilder.CreateIndex(
                name: "IX_projects_TeamLeadId",
                table: "projects",
                column: "TeamLeadId");

            migrationBuilder.CreateIndex(
                name: "IX_projects_WbsId",
                table: "projects",
                column: "WbsId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_projects_WbsStatus",
                table: "projects",
                column: "WbsStatus");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "projects");
        }
    }
}
