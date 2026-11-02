using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations
{
    /// <inheritdoc />
    [DbContext(typeof(AppDbContext))]
    [Migration("20261102120000_SeedAllServiceAbbreviations")]
    public partial class SeedAllServiceAbbreviations : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'WAPT' WHERE ""Code"" = 'PT003';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'MAPT' WHERE ""Code"" = 'PT004';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'APIPT' WHERE ""Code"" = 'PT005';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'WAVA' WHERE ""Code"" = 'VA002';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'CIVA' WHERE ""Code"" = 'VA003';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'TRTE' WHERE ""Code"" = 'RT002';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'AZURE' WHERE ""Code"" = 'CS002';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'GCP' WHERE ""Code"" = 'CS003';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'SCSR' WHERE ""Code"" = 'CODE001';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'SAST' WHERE ""Code"" = 'CODE002';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'DAST' WHERE ""Code"" = 'CODE003';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'GDPR' WHERE ""Code"" = 'COMP002';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'PCI' WHERE ""Code"" = 'COMP003';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'SOC2' WHERE ""Code"" = 'COMP004';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'PHISH' WHERE ""Code"" = 'SE001';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'SATP' WHERE ""Code"" = 'SE002';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'VPA' WHERE ""Code"" = 'SE003';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'DFI' WHERE ""Code"" = 'FOR001';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'IRC' WHERE ""Code"" = 'FOR002';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'MA' WHERE ""Code"" = 'FOR003';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'NASR' WHERE ""Code"" = 'NET001';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'FICA' WHERE ""Code"" = 'NET002';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'NSA' WHERE ""Code"" = 'NET003';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'TMRA' WHERE ""Code"" = 'THREAT001';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'CTIR' WHERE ""Code"" = 'THREAT002';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'ASA' WHERE ""Code"" = 'THREAT003';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'SOC' WHERE ""Code"" = 'SOC';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'FSF' WHERE ""Code"" = 'FSF';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'SRV1' WHERE ""Code"" = 'SERVICE1';
UPDATE master.mst_service_catalog SET ""Abbreviation"" = 'INPT' WHERE ""Code"" = 'PT002';

UPDATE project.tbl_project_services ps
SET ""ServiceAbbreviation"" = c.""Abbreviation"",
    ""ServiceCatalogId"" = COALESCE(ps.""ServiceCatalogId"", c.""Id"")
FROM master.mst_service_catalog c
WHERE (ps.""ServiceCatalogId"" = c.""Id"" OR lower(trim(ps.""ServiceName"")) = lower(trim(c.""Name"")))
  AND (ps.""ServiceAbbreviation"" IS NULL OR trim(ps.""ServiceAbbreviation"") = '');

UPDATE project.tbl_project_services SET ""ServiceAbbreviation"" = 'CS' WHERE ""ServiceName"" = 'Custom Service';

DELETE FROM project.tbl_project_tasks old_t
USING project.tbl_project_tasks new_t, project.tbl_project_services ps
WHERE old_t.""ProjectServiceId"" = ps.""Id""
  AND old_t.""Phase"" ~ '^AP[0-9]+$'
  AND ps.""ServiceAbbreviation"" IS NOT NULL
  AND new_t.""ProjectId"" = old_t.""ProjectId""
  AND new_t.""ProjectServiceId"" = old_t.""ProjectServiceId""
  AND COALESCE(new_t.""Period"", '') = COALESCE(old_t.""Period"", '')
  AND new_t.""Title"" = old_t.""Title""
  AND new_t.""Phase"" = ps.""ServiceAbbreviation"" || substring(old_t.""Phase"" from 3);

UPDATE project.tbl_project_tasks t
SET ""Phase"" = ps.""ServiceAbbreviation"" || substring(t.""Phase"" from 3),
    ""UpdatedAtUtc"" = NOW()
FROM project.tbl_project_services ps
WHERE t.""ProjectServiceId"" = ps.""Id""
  AND t.""Phase"" ~ '^AP[0-9]+$'
  AND ps.""ServiceAbbreviation"" IS NOT NULL
  AND trim(ps.""ServiceAbbreviation"") != ''
  AND trim(ps.""ServiceAbbreviation"") != 'AP';
");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
        }
    }
}
