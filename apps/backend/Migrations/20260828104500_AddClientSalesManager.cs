using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    public partial class AddClientSalesManager : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "SalesManager",
                table: "clients",
                type: "character varying(120)",
                maxLength: 120,
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "SalesManagerId",
                table: "clients",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_clients_SalesManagerId",
                table: "clients",
                column: "SalesManagerId");

            migrationBuilder.AddForeignKey(
                name: "FK_clients_employees_SalesManagerId",
                table: "clients",
                column: "SalesManagerId",
                principalTable: "employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_clients_employees_SalesManagerId",
                table: "clients");

            migrationBuilder.DropIndex(
                name: "IX_clients_SalesManagerId",
                table: "clients");

            migrationBuilder.DropColumn(
                name: "SalesManager",
                table: "clients");

            migrationBuilder.DropColumn(
                name: "SalesManagerId",
                table: "clients");
        }
    }
}
