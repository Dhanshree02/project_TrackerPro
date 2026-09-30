using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations
{
    [DbContext(typeof(AppDbContext))]
    [Migration("20260929183000_AddProjectServicePrerequisite")]
    public partial class AddProjectServicePrerequisite : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "BillingStatus",
                table: "project_services",
                type: "character varying(40)",
                maxLength: 40,
                nullable: false,
                defaultValue: "Advance Pending");

            migrationBuilder.AddColumn<string>(
                name: "CollectionStatus",
                table: "project_services",
                type: "character varying(40)",
                maxLength: 40,
                nullable: false,
                defaultValue: "Pending To Collect");

            migrationBuilder.AddColumn<bool>(
                name: "IsReady",
                table: "project_services",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "ValidationStatus",
                table: "project_services",
                type: "character varying(40)",
                maxLength: 40,
                nullable: false,
                defaultValue: "Pending To Validate");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(name: "BillingStatus", table: "project_services");
            migrationBuilder.DropColumn(name: "CollectionStatus", table: "project_services");
            migrationBuilder.DropColumn(name: "IsReady", table: "project_services");
            migrationBuilder.DropColumn(name: "ValidationStatus", table: "project_services");
        }
    }
}
