using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class SubVentureTableAndLogoRule : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "sub_ventures",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ClientId = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    contacts = table.Column<string>(type: "jsonb", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sub_ventures", x => x.Id);
                    table.ForeignKey(
                        name: "FK_sub_ventures_clients_ClientId",
                        column: x => x.ClientId,
                        principalTable: "clients",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_sub_ventures_ClientId",
                table: "sub_ventures",
                column: "ClientId");

            // Migrate the existing JSONB sub-ventures into real rows. Each element of the
            // clients.SubVentures jsonb array becomes one row, keeping its own contacts.
            migrationBuilder.Sql(
                """
                INSERT INTO "sub_ventures"
                    ("Id", "ClientId", "Name", "contacts", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc")
                SELECT
                    gen_random_uuid(),
                    c."Id",
                    sv ->> 'name',
                    COALESCE(sv -> 'contacts', '[]'::jsonb),
                    c."CreatedAtUtc",
                    c."UpdatedAtUtc",
                    c."CreatedBy",
                    c."UpdatedBy",
                    NULL
                FROM "clients" AS c
                CROSS JOIN LATERAL jsonb_array_elements(c."SubVentures") AS sv
                WHERE jsonb_typeof(c."SubVentures") = 'array'
                  AND jsonb_typeof(sv) = 'object'
                  AND sv ->> 'name' IS NOT NULL;
                """);

            migrationBuilder.DropColumn(
                name: "SubVentures",
                table: "clients");

            // Logo = initials of the first two words of the name:
            // "Northwind Bank" → NB, "AutoDrive Systems" → AS, "ABC" → A.
            migrationBuilder.Sql(
                """
                UPDATE "clients"
                SET "Logo" = UPPER(
                    left(split_part(regexp_replace(trim("Name"), '\s+', ' ', 'g'), ' ', 1), 1) ||
                    COALESCE(left(split_part(regexp_replace(trim("Name"), '\s+', ' ', 'g'), ' ', 2), 1), '')
                )
                WHERE "Name" IS NOT NULL AND trim("Name") <> '';
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Re-create the column FIRST, then rebuild the JSONB array from the sub_ventures
            // rows (contacts included), then drop the table.
            migrationBuilder.AddColumn<string>(
                name: "SubVentures",
                table: "clients",
                type: "jsonb",
                nullable: true,
                defaultValue: "[]");

            migrationBuilder.Sql(
                """
                UPDATE "clients" AS c
                SET "SubVentures" = COALESCE(
                    (SELECT jsonb_agg(jsonb_build_object('name', s."Name", 'contacts', COALESCE(s."contacts", '[]'::jsonb)))
                     FROM "sub_ventures" AS s
                     WHERE s."ClientId" = c."Id" AND s."DeletedAtUtc" IS NULL),
                    '[]'::jsonb
                );
                """);

            migrationBuilder.DropTable(
                name: "sub_ventures");
        }
    }
}
