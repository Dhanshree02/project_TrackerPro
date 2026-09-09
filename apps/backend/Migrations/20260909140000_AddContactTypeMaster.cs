using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations
{
    [DbContext(typeof(AppDbContext))]
    [Migration("20260909140000_AddContactTypeMaster")]
    public partial class AddContactTypeMaster : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                CREATE TABLE IF NOT EXISTS mst_contact_types (
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
                    CONSTRAINT "PK_mst_contact_types" PRIMARY KEY ("Id")
                );
                CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_contact_types_Code"
                    ON mst_contact_types ("Code");
                CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_contact_types_Name"
                    ON mst_contact_types ("Name");
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                DROP TABLE IF EXISTS mst_contact_types;
                """);
        }
    }
}
