using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations
{
    [DbContext(typeof(AppDbContext))]
    [Migration("20260903120000_AddRepositoryDepartments")]
    public partial class AddRepositoryDepartments : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                CREATE TABLE IF NOT EXISTS repository_departments (
                    "RepositoryItemId" uuid NOT NULL,
                    "DepartmentId" uuid NOT NULL,
                    CONSTRAINT "PK_repository_departments" PRIMARY KEY ("RepositoryItemId", "DepartmentId")
                );

                DO $$
                BEGIN
                    IF NOT EXISTS (
                        SELECT 1 FROM pg_constraint WHERE conname = 'FK_repository_departments_repository_RepositoryItemId'
                    ) THEN
                        ALTER TABLE repository_departments
                            ADD CONSTRAINT "FK_repository_departments_repository_RepositoryItemId"
                            FOREIGN KEY ("RepositoryItemId") REFERENCES repository ("Id") ON DELETE CASCADE;
                    END IF;

                    IF NOT EXISTS (
                        SELECT 1 FROM pg_constraint WHERE conname = 'FK_repository_departments_mst_departments_DepartmentId'
                    ) THEN
                        ALTER TABLE repository_departments
                            ADD CONSTRAINT "FK_repository_departments_mst_departments_DepartmentId"
                            FOREIGN KEY ("DepartmentId") REFERENCES mst_departments ("Id") ON DELETE CASCADE;
                    END IF;
                END $$;

                CREATE INDEX IF NOT EXISTS "IX_repository_departments_DepartmentId"
                    ON repository_departments ("DepartmentId");
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(name: "repository_departments");
        }
    }
}
