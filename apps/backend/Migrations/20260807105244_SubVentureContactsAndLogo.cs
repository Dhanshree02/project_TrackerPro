using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class SubVentureContactsAndLogo : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Convert SubVentures from a plain jsonb string array (old shape: ["a","b"])
            // to the structured shape (new shape: [{"name":"a","contacts":[]}]).
            // Only rows still holding the old string-array shape are converted, so the
            // migration is safe to re-run on partially migrated databases.
            migrationBuilder.Sql(
                """
                UPDATE "clients"
                SET "SubVentures" = (
                    SELECT COALESCE(jsonb_agg(jsonb_build_object('name', v, 'contacts', '[]'::jsonb)), '[]'::jsonb)
                    FROM jsonb_array_elements_text("SubVentures") AS v
                )
                WHERE jsonb_typeof("SubVentures") = 'array'
                  AND NOT EXISTS (
                      SELECT 1 FROM jsonb_array_elements("SubVentures") AS e
                      WHERE jsonb_typeof(e) = 'object'
                  );
                """);

            // Derive the Logo from the client name: first + last letter, uppercased.
            migrationBuilder.Sql(
                """
                UPDATE "clients"
                SET "Logo" = UPPER(LEFT("Name", 1) || RIGHT("Name", 1))
                WHERE "Name" IS NOT NULL AND "Name" <> '';
                """);

            migrationBuilder.DropColumn(
                name: "CompanyName",
                table: "clients");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Reverse the SubVentures conversion: keep only the names (contacts are lost).
            migrationBuilder.Sql(
                """
                UPDATE "clients"
                SET "SubVentures" = (
                    SELECT COALESCE(jsonb_agg(v ->> 'name'), '[]'::jsonb)
                    FROM jsonb_array_elements("SubVentures") AS e(v)
                )
                WHERE jsonb_typeof("SubVentures") = 'array'
                  AND EXISTS (
                      SELECT 1 FROM jsonb_array_elements("SubVentures") AS e
                      WHERE jsonb_typeof(e) = 'object'
                  );
                """);

            migrationBuilder.AddColumn<string>(
                name: "CompanyName",
                table: "clients",
                type: "character varying(255)",
                maxLength: 255,
                nullable: true);
        }
    }
}
