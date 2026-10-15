using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddSubVentureCode : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "SubVentureCode",
                schema: "customer",
                table: "tbl_sub_ventures",
                type: "character varying(32)",
                maxLength: 32,
                nullable: true);

            // Assign {client code}-{01..} using the same CreatedAtUtc client order as customer IDs.
            // Existing non-blank codes are kept. Sequence numbers already used under a client are skipped.
            migrationBuilder.Sql(
                """
                DO $$
                DECLARE
                    rec record;
                    n int := 0;
                    client_code text;
                    prefix text;
                    sv record;
                    seq int;
                    candidate text;
                BEGIN
                    FOR rec IN
                        SELECT "Id"
                        FROM customer.tbl_clients
                        ORDER BY "CreatedAtUtc"
                    LOOP
                        n := n + 1;
                        client_code := 'C' || LPAD(n::text, 3, '0');

                        SELECT split_part("SubVentureCode", '-', 1)
                          INTO prefix
                        FROM customer.tbl_sub_ventures
                        WHERE "ClientId" = rec."Id"
                          AND "SubVentureCode" IS NOT NULL
                          AND btrim("SubVentureCode") <> ''
                        LIMIT 1;

                        IF prefix IS NULL OR btrim(prefix) = '' THEN
                            prefix := client_code;
                        END IF;

                        SELECT COALESCE(MAX(NULLIF(substring("SubVentureCode" from '-([0-9]+)$'), '')::int), 0)
                          INTO seq
                        FROM customer.tbl_sub_ventures
                        WHERE "ClientId" = rec."Id";

                        FOR sv IN
                            SELECT "Id"
                            FROM customer.tbl_sub_ventures
                            WHERE "ClientId" = rec."Id"
                              AND ("SubVentureCode" IS NULL OR btrim("SubVentureCode") = '')
                            ORDER BY "CreatedAtUtc", "Id"
                        LOOP
                            LOOP
                                seq := seq + 1;
                                candidate := prefix || '-' || LPAD(seq::text, 2, '0');
                                EXIT WHEN NOT EXISTS (
                                    SELECT 1
                                    FROM customer.tbl_sub_ventures
                                    WHERE "SubVentureCode" = candidate
                                );
                            END LOOP;

                            UPDATE customer.tbl_sub_ventures
                            SET "SubVentureCode" = candidate
                            WHERE "Id" = sv."Id";
                        END LOOP;
                    END LOOP;
                END $$;
                """);

            migrationBuilder.Sql(
                """
                ALTER TABLE customer.tbl_sub_ventures
                    ALTER COLUMN "SubVentureCode" SET NOT NULL;
                """);

            migrationBuilder.CreateIndex(
                name: "IX_tbl_sub_ventures_SubVentureCode",
                schema: "customer",
                table: "tbl_sub_ventures",
                column: "SubVentureCode",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_tbl_sub_ventures_SubVentureCode",
                schema: "customer",
                table: "tbl_sub_ventures");

            migrationBuilder.DropColumn(
                name: "SubVentureCode",
                schema: "customer",
                table: "tbl_sub_ventures");
        }
    }
}
