using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations
{
    [DbContext(typeof(AppDbContext))]
    [Migration("20260909130000_AddContactDesignationMaster")]
    public partial class AddContactDesignationMaster : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                CREATE TABLE IF NOT EXISTS mst_contact_designations (
                    "Id" uuid NOT NULL,
                    "Code" character varying(80) NOT NULL,
                    "Name" character varying(150) NOT NULL,
                    "IsActive" boolean NOT NULL,
                    "SortOrder" integer NOT NULL DEFAULT 0,
                    "CreatedAtUtc" timestamp with time zone NOT NULL,
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone,
                    CONSTRAINT "PK_mst_contact_designations" PRIMARY KEY ("Id")
                );
                CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_contact_designations_Code"
                    ON mst_contact_designations ("Code");
                CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_contact_designations_Name"
                    ON mst_contact_designations ("Name");
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                DROP TABLE IF EXISTS mst_contact_designations;
                """);
        }
    }
}
