using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class RbacRoleManagement : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // ---- Role.Name: int enum → free-text key ----
            // The column currently holds UserRole enum ints. Convert via a temp
            // text column so the values become the enum names (e.g. 2 → "Pmo").
            migrationBuilder.DropIndex(
                name: "IX_roles_Name",
                table: "roles");

            migrationBuilder.AddColumn<string>(
                name: "NameText",
                table: "roles",
                type: "character varying(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.Sql("""
                UPDATE roles SET "NameText" = CASE "Name"
                    WHEN 0 THEN 'SeniorPm'
                    WHEN 1 THEN 'EngagementManager'
                    WHEN 2 THEN 'Pmo'
                    WHEN 3 THEN 'Hod'
                    WHEN 4 THEN 'BusinessOwner'
                    WHEN 5 THEN 'Dhanshree'
                    WHEN 6 THEN 'Sales'
                    WHEN 7 THEN 'Accounts'
                    WHEN 8 THEN 'Hr'
                    WHEN 9 THEN 'ProjectManager'
                    WHEN 10 THEN 'TeamLead'
                    WHEN 11 THEN 'Employee'
                    WHEN 12 THEN 'Admin'
                    ELSE 'Role' || "Name"
                END;
                """);

            migrationBuilder.DropColumn(
                name: "Name",
                table: "roles");

            migrationBuilder.RenameColumn(
                name: "NameText",
                table: "roles",
                newName: "Name");

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "roles",
                type: "character varying(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "character varying(50)",
                oldMaxLength: 50,
                oldNullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_roles_Name",
                table: "roles",
                column: "Name",
                unique: true);

            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "roles",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);

            // Existing roles are active by default; the seeder reconciles state.
            migrationBuilder.AddColumn<bool>(
                name: "IsActive",
                table: "roles",
                type: "boolean",
                nullable: false,
                defaultValue: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsSystemRole",
                table: "roles",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            // Every pre-existing role was seeded — mark them all as system roles.
            migrationBuilder.Sql("""UPDATE roles SET "IsSystemRole" = true;""");

            migrationBuilder.CreateTable(
                name: "role_permission_audits",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    RoleId = table.Column<Guid>(type: "uuid", nullable: false),
                    RoleName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    ModuleKey = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    ModuleLabel = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    SubmoduleKey = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    SubmoduleLabel = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    PermissionKey = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    ActionLabel = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    ChangeType = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    PreviousValue = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    NewValue = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    ChangedById = table.Column<Guid>(type: "uuid", nullable: true),
                    ChangedByName = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_role_permission_audits", x => x.Id);
                    table.ForeignKey(
                        name: "FK_role_permission_audits_roles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "roles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_role_permission_audits_CreatedAtUtc",
                table: "role_permission_audits",
                column: "CreatedAtUtc");

            migrationBuilder.CreateIndex(
                name: "IX_role_permission_audits_RoleId",
                table: "role_permission_audits",
                column: "RoleId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "role_permission_audits");

            migrationBuilder.DropColumn(
                name: "Description",
                table: "roles");

            migrationBuilder.DropColumn(
                name: "IsActive",
                table: "roles");

            migrationBuilder.DropColumn(
                name: "IsSystemRole",
                table: "roles");

            // Map the text keys back to their enum ints before reverting the type.
            migrationBuilder.DropIndex(
                name: "IX_roles_Name",
                table: "roles");

            migrationBuilder.AddColumn<int>(
                name: "NameInt",
                table: "roles",
                type: "integer",
                nullable: true);

            migrationBuilder.Sql("""
                UPDATE roles SET "NameInt" = CASE "Name"
                    WHEN 'SeniorPm' THEN 0
                    WHEN 'EngagementManager' THEN 1
                    WHEN 'Pmo' THEN 2
                    WHEN 'Hod' THEN 3
                    WHEN 'BusinessOwner' THEN 4
                    WHEN 'Dhanshree' THEN 5
                    WHEN 'Sales' THEN 6
                    WHEN 'Accounts' THEN 7
                    WHEN 'Hr' THEN 8
                    WHEN 'ProjectManager' THEN 9
                    WHEN 'TeamLead' THEN 10
                    WHEN 'Employee' THEN 11
                    WHEN 'Admin' THEN 12
                END;
                """);

            migrationBuilder.DropColumn(
                name: "Name",
                table: "roles");

            migrationBuilder.RenameColumn(
                name: "NameInt",
                table: "roles",
                newName: "Name");

            migrationBuilder.AlterColumn<int>(
                name: "Name",
                table: "roles",
                type: "integer",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "integer",
                oldNullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_roles_Name",
                table: "roles",
                column: "Name",
                unique: true);
        }
    }
}
