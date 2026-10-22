using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class DropOrgRoleMapSubDepartmentName : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "SubDepartment",
                schema: "master",
                table: "mst_org_role_map");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "SubDepartment",
                schema: "master",
                table: "mst_org_role_map",
                type: "character varying(250)",
                maxLength: 250,
                nullable: true);
        }
    }
}
