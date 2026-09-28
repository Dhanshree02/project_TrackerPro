using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddProjectServicesAndResourceLevels : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "project_services",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ProjectId = table.Column<Guid>(type: "uuid", nullable: false),
                    ServiceCatalogId = table.Column<Guid>(type: "uuid", nullable: true),
                    TaskId = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    Department = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    SubDepartment = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    ServiceName = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    Qty = table.Column<int>(type: "integer", nullable: false),
                    Description = table.Column<string>(type: "text", nullable: true),
                    ResourceLevel = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    Frequency = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: true),
                    Location = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: true),
                    LocationText = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    ServiceModel = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: true),
                    DeliveryModel = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    FinalDeliveryFormat = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: true),
                    BillingModel = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    Tools = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    StartDate = table.Column<DateOnly>(type: "date", nullable: true),
                    EndDate = table.Column<DateOnly>(type: "date", nullable: true),
                    DurationDays = table.Column<int>(type: "integer", nullable: true),
                    DurationHours = table.Column<int>(type: "integer", nullable: true),
                    TotalDays = table.Column<int>(type: "integer", nullable: true),
                    TotalHours = table.Column<int>(type: "integer", nullable: true),
                    UnitPrice = table.Column<decimal>(type: "numeric(18,2)", precision: 18, scale: 2, nullable: true),
                    Total = table.Column<decimal>(type: "numeric(18,2)", precision: 18, scale: 2, nullable: true),
                    SortOrder = table.Column<int>(type: "integer", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_project_services", x => x.Id);
                    table.ForeignKey(
                        name: "FK_project_services_mst_service_catalog_ServiceCatalogId",
                        column: x => x.ServiceCatalogId,
                        principalTable: "mst_service_catalog",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_project_services_projects_ProjectId",
                        column: x => x.ProjectId,
                        principalTable: "projects",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "project_service_resource_levels",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ProjectServiceId = table.Column<Guid>(type: "uuid", nullable: false),
                    Level = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Count = table.Column<int>(type: "integer", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_project_service_resource_levels", x => x.Id);
                    table.ForeignKey(
                        name: "FK_project_service_resource_levels_project_services_ProjectSer~",
                        column: x => x.ProjectServiceId,
                        principalTable: "project_services",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_project_service_resource_levels_ProjectServiceId_Level",
                table: "project_service_resource_levels",
                columns: new[] { "ProjectServiceId", "Level" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_project_services_ProjectId",
                table: "project_services",
                column: "ProjectId");

            migrationBuilder.CreateIndex(
                name: "IX_project_services_ServiceCatalogId",
                table: "project_services",
                column: "ServiceCatalogId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "project_service_resource_levels");

            migrationBuilder.DropTable(
                name: "project_services");
        }
    }
}
