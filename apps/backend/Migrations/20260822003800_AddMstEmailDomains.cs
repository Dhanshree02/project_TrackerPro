using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations
{
    [DbContext(typeof(AppDbContext))]
    [Migration("20260822003800_AddMstEmailDomains")]
    public partial class AddMstEmailDomains : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Idempotent: trackerpro-final.sql already creates this table on fresh Docker volumes.
            migrationBuilder.Sql(
                """
                CREATE TABLE IF NOT EXISTS mst_email_domains (
                    "Id" uuid NOT NULL,
                    "Code" character varying(80) NOT NULL,
                    "DomainName" character varying(150) NOT NULL,
                    "DisplayName" character varying(150) NOT NULL,
                    "IsActive" boolean NOT NULL,
                    "SortOrder" integer NOT NULL,
                    "CreatedAtUtc" timestamp with time zone NOT NULL,
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone
                );
                DO $$
                BEGIN
                    IF NOT EXISTS (
                        SELECT 1 FROM pg_constraint WHERE conname IN ('PK_mst_email_domains', 'mst_email_domains_pkey')
                    ) THEN
                        ALTER TABLE mst_email_domains ADD CONSTRAINT "PK_mst_email_domains" PRIMARY KEY ("Id");
                    END IF;
                END $$;
                CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_email_domains_DomainName"
                    ON mst_email_domains ("DomainName");
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "mst_email_domains");
        }
    }
}
