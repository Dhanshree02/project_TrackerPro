using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations;

[DbContext(typeof(AppDbContext))]
[Migration("20260908050000_AddCertificationsAndDegrees")]
public partial class AddCertificationsAndDegrees : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql(
            """
            CREATE TABLE IF NOT EXISTS mst_certifications (
                "Id" uuid NOT NULL,
                "Code" character varying(100) NOT NULL,
                "Name" character varying(200) NOT NULL,
                "IsActive" boolean DEFAULT true NOT NULL,
                "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
                "UpdatedAtUtc" timestamp with time zone,
                "CreatedBy" uuid,
                "UpdatedBy" uuid,
                "DeletedAtUtc" timestamp with time zone
            );

            DO $$
            BEGIN
                IF NOT EXISTS (
                    SELECT 1 FROM pg_constraint c
                    JOIN pg_class t ON c.conrelid = t.oid
                    WHERE t.relname = 'mst_certifications' AND c.contype = 'p'
                ) THEN
                    ALTER TABLE mst_certifications ADD PRIMARY KEY ("Id");
                END IF;
            END $$;

            CREATE TABLE IF NOT EXISTS mst_graduation_degrees (
                "Id" uuid NOT NULL,
                "Code" character varying(100) NOT NULL,
                "Name" character varying(200) NOT NULL,
                "IsActive" boolean DEFAULT true NOT NULL,
                "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
                "UpdatedAtUtc" timestamp with time zone,
                "CreatedBy" uuid,
                "UpdatedBy" uuid,
                "DeletedAtUtc" timestamp with time zone
            );

            DO $$
            BEGIN
                IF NOT EXISTS (
                    SELECT 1 FROM pg_constraint c
                    JOIN pg_class t ON c.conrelid = t.oid
                    WHERE t.relname = 'mst_graduation_degrees' AND c.contype = 'p'
                ) THEN
                    ALTER TABLE mst_graduation_degrees ADD PRIMARY KEY ("Id");
                END IF;
            END $$;

            CREATE TABLE IF NOT EXISTS mst_post_graduation_degrees (
                "Id" uuid NOT NULL,
                "Code" character varying(100) NOT NULL,
                "Name" character varying(200) NOT NULL,
                "IsActive" boolean DEFAULT true NOT NULL,
                "CreatedAtUtc" timestamp with time zone DEFAULT now() NOT NULL,
                "UpdatedAtUtc" timestamp with time zone,
                "CreatedBy" uuid,
                "UpdatedBy" uuid,
                "DeletedAtUtc" timestamp with time zone
            );

            DO $$
            BEGIN
                IF NOT EXISTS (
                    SELECT 1 FROM pg_constraint c
                    JOIN pg_class t ON c.conrelid = t.oid
                    WHERE t.relname = 'mst_post_graduation_degrees' AND c.contype = 'p'
                ) THEN
                    ALTER TABLE mst_post_graduation_degrees ADD PRIMARY KEY ("Id");
                END IF;
            END $$;

            ALTER TABLE employees
                ADD COLUMN IF NOT EXISTS "GradDegree" text,
                ADD COLUMN IF NOT EXISTS "GradYear" text,
                ADD COLUMN IF NOT EXISTS "PostGradDegree" text,
                ADD COLUMN IF NOT EXISTS "PostGradYear" text,
                ADD COLUMN IF NOT EXISTS "ExpType" text,
                ADD COLUMN IF NOT EXISTS "PriorTotalExp" text,
                ADD COLUMN IF NOT EXISTS "PriorRelevantExp" text;
            """);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql(
            """
            ALTER TABLE employees
                DROP COLUMN IF EXISTS "GradDegree",
                DROP COLUMN IF EXISTS "GradYear",
                DROP COLUMN IF EXISTS "PostGradDegree",
                DROP COLUMN IF EXISTS "PostGradYear",
                DROP COLUMN IF EXISTS "ExpType",
                DROP COLUMN IF EXISTS "PriorTotalExp",
                DROP COLUMN IF EXISTS "PriorRelevantExp";

            DROP TABLE IF EXISTS mst_post_graduation_degrees;
            DROP TABLE IF EXISTS mst_graduation_degrees;
            DROP TABLE IF EXISTS mst_certifications;
            """);
    }
}
