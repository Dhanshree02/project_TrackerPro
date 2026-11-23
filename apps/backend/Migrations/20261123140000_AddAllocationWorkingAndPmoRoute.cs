using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations
{
    [DbContext(typeof(AppDbContext))]
    [Migration("20261123140000_AddAllocationWorkingAndPmoRoute")]
    public partial class AddAllocationWorkingAndPmoRoute : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                ALTER TABLE project.tbl_project_team_members
                    ADD COLUMN IF NOT EXISTS "IsCurrentlyWorking" boolean NOT NULL DEFAULT true;

                ALTER TABLE project.tbl_resource_allocation_requests
                    ADD COLUMN IF NOT EXISTS "RequiresPmoApproval" boolean NOT NULL DEFAULT false;
                """);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                ALTER TABLE project.tbl_project_team_members
                    DROP COLUMN IF EXISTS "IsCurrentlyWorking";

                ALTER TABLE project.tbl_resource_allocation_requests
                    DROP COLUMN IF EXISTS "RequiresPmoApproval";
                """);
        }
    }
}
