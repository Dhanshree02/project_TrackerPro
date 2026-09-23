using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PMS.API.Infrastructure.Persistence;

#nullable disable

namespace PMS.API.Migrations
{
    public partial class AddServiceCatalogMasterTables : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                CREATE TABLE IF NOT EXISTS mst_service_groups (
                    "Id" uuid NOT NULL,
                    "Code" character varying(40) NOT NULL,
                    "Name" character varying(100) NOT NULL,
                    "IsActive" boolean NOT NULL DEFAULT true,
                    "SortOrder" integer NOT NULL DEFAULT 0,
                    "CreatedAtUtc" timestamp with time zone NOT NULL,
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone,
                    CONSTRAINT "PK_mst_service_groups" PRIMARY KEY ("Id")
                );
                CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_service_groups_Code"
                    ON mst_service_groups ("Code");
                CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_service_groups_Name"
                    ON mst_service_groups ("Name");

                CREATE TABLE IF NOT EXISTS mst_service_departments (
                    "Id" uuid NOT NULL,
                    "Code" character varying(80) NOT NULL,
                    "Name" character varying(150) NOT NULL,
                    "GroupId" uuid NOT NULL,
                    "IsActive" boolean NOT NULL DEFAULT true,
                    "SortOrder" integer NOT NULL DEFAULT 0,
                    "CreatedAtUtc" timestamp with time zone NOT NULL,
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone,
                    CONSTRAINT "PK_mst_service_departments" PRIMARY KEY ("Id"),
                    CONSTRAINT "FK_mst_service_departments_mst_service_groups_GroupId"
                        FOREIGN KEY ("GroupId") REFERENCES mst_service_groups ("Id") ON DELETE RESTRICT
                );
                CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_service_departments_Code"
                    ON mst_service_departments ("Code");
                CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_service_departments_Name"
                    ON mst_service_departments ("Name");
                CREATE INDEX IF NOT EXISTS "IX_mst_service_departments_GroupId"
                    ON mst_service_departments ("GroupId");

                CREATE TABLE IF NOT EXISTS mst_service_sub_departments (
                    "Id" uuid NOT NULL,
                    "Code" character varying(120) NOT NULL,
                    "Name" character varying(200) NOT NULL,
                    "DepartmentId" uuid NOT NULL,
                    "IsActive" boolean NOT NULL DEFAULT true,
                    "SortOrder" integer NOT NULL DEFAULT 0,
                    "CreatedAtUtc" timestamp with time zone NOT NULL,
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone,
                    CONSTRAINT "PK_mst_service_sub_departments" PRIMARY KEY ("Id"),
                    CONSTRAINT "FK_mst_service_sub_departments_mst_service_departments_DepartmentId"
                        FOREIGN KEY ("DepartmentId") REFERENCES mst_service_departments ("Id") ON DELETE CASCADE
                );
                CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_service_sub_departments_Code"
                    ON mst_service_sub_departments ("Code");
                CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_service_sub_departments_DepartmentId_Name"
                    ON mst_service_sub_departments ("DepartmentId", "Name");

                CREATE TABLE IF NOT EXISTS mst_service_catalog (
                    "Id" uuid NOT NULL,
                    "Code" character varying(50) NOT NULL,
                    "Name" character varying(255) NOT NULL,
                    "SubDepartmentId" uuid NOT NULL,
                    "DefaultTools" character varying(500),
                    "DefaultUnitPrice" numeric(18,2),
                    "DefaultDurationDays" integer,
                    "Description" text,
                    "IsActive" boolean NOT NULL DEFAULT true,
                    "SortOrder" integer NOT NULL DEFAULT 0,
                    "CreatedAtUtc" timestamp with time zone NOT NULL,
                    "UpdatedAtUtc" timestamp with time zone,
                    "CreatedBy" uuid,
                    "UpdatedBy" uuid,
                    "DeletedAtUtc" timestamp with time zone,
                    CONSTRAINT "PK_mst_service_catalog" PRIMARY KEY ("Id"),
                    CONSTRAINT "FK_mst_service_catalog_mst_service_sub_departments_SubDepartmentId"
                        FOREIGN KEY ("SubDepartmentId") REFERENCES mst_service_sub_departments ("Id") ON DELETE CASCADE
                );
                CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_service_catalog_Code"
                    ON mst_service_catalog ("Code");
                CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_service_catalog_SubDepartmentId_Name"
                    ON mst_service_catalog ("SubDepartmentId", "Name");

                -- 1. Seed Service Groups
                INSERT INTO mst_service_groups ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc") VALUES
                    ('a1111111-1111-1111-1111-111111111111', 'RESOURCE', 'Resource', true, 1, NOW() AT TIME ZONE 'UTC'),
                    ('a2222222-2222-2222-2222-222222222222', 'SCOPE', 'Scope', true, 2, NOW() AT TIME ZONE 'UTC')
                ON CONFLICT ("Code") DO NOTHING;

                -- 2. Seed Service Departments
                INSERT INTO mst_service_departments ("Id", "Code", "Name", "GroupId", "IsActive", "SortOrder", "CreatedAtUtc") VALUES
                    ('b0000001-0000-0000-0000-000000000001', 'PEN_TESTING', 'Penetration Testing', 'a2222222-2222-2222-2222-222222222222', true, 1, NOW() AT TIME ZONE 'UTC'),
                    ('b0000002-0000-0000-0000-000000000002', 'VULN_ASSESSMENT', 'Vulnerability Assessment', 'a2222222-2222-2222-2222-222222222222', true, 2, NOW() AT TIME ZONE 'UTC'),
                    ('b0000003-0000-0000-0000-000000000003', 'RED_TEAM', 'Red Team & Adversary Simulation', 'a1111111-1111-1111-1111-111111111111', true, 3, NOW() AT TIME ZONE 'UTC'),
                    ('b0000004-0000-0000-0000-000000000004', 'CLOUD_SECURITY', 'Cloud Security', 'a1111111-1111-1111-1111-111111111111', true, 4, NOW() AT TIME ZONE 'UTC'),
                    ('b0000005-0000-0000-0000-000000000005', 'CODE_APP_SECURITY', 'Code & Application Security', 'a2222222-2222-2222-2222-222222222222', true, 5, NOW() AT TIME ZONE 'UTC'),
                    ('b0000006-0000-0000-0000-000000000006', 'COMPLIANCE_AUDIT', 'Compliance & Audit', 'a1111111-1111-1111-1111-111111111111', true, 6, NOW() AT TIME ZONE 'UTC'),
                    ('b0000007-0000-0000-0000-000000000007', 'SOCIAL_ENGINEERING', 'Social Engineering & Awareness', 'a2222222-2222-2222-2222-222222222222', true, 7, NOW() AT TIME ZONE 'UTC'),
                    ('b0000008-0000-0000-0000-000000000008', 'FORENSICS_IR', 'Forensics & Incident Response', 'a1111111-1111-1111-1111-111111111111', true, 8, NOW() AT TIME ZONE 'UTC'),
                    ('b0000009-0000-0000-0000-000000000009', 'NETWORK_INFRA', 'Network & Infrastructure', 'a2222222-2222-2222-2222-222222222222', true, 9, NOW() AT TIME ZONE 'UTC'),
                    ('b000000a-0000-0000-0000-00000000000a', 'THREAT_INTEL', 'Threat Intelligence & Modeling', 'a1111111-1111-1111-1111-111111111111', true, 10, NOW() AT TIME ZONE 'UTC')
                ON CONFLICT ("Code") DO NOTHING;

                -- 3. Seed Service Sub-Departments
                INSERT INTO mst_service_sub_departments ("Id", "Code", "Name", "DepartmentId", "IsActive", "SortOrder", "CreatedAtUtc") VALUES
                    -- Penetration Testing
                    ('c0000001-0000-0000-0000-000000000001', 'SUB_NET_PT', 'Network Penetration Testing', 'b0000001-0000-0000-0000-000000000001', true, 1, NOW() AT TIME ZONE 'UTC'),
                    ('c0000002-0000-0000-0000-000000000002', 'SUB_WEB_PT', 'Web Application Penetration Testing', 'b0000001-0000-0000-0000-000000000001', true, 2, NOW() AT TIME ZONE 'UTC'),
                    ('c0000003-0000-0000-0000-000000000003', 'SUB_MOB_PT', 'Mobile Application Penetration Testing', 'b0000001-0000-0000-0000-000000000001', true, 3, NOW() AT TIME ZONE 'UTC'),
                    ('c0000004-0000-0000-0000-000000000004', 'SUB_API_PT', 'API Penetration Testing', 'b0000001-0000-0000-0000-000000000001', true, 4, NOW() AT TIME ZONE 'UTC'),
                    ('c0000005-0000-0000-0000-000000000005', 'SUB_THICK_PT', 'Thick Client Penetration Testing', 'b0000001-0000-0000-0000-000000000001', true, 5, NOW() AT TIME ZONE 'UTC'),
                    -- Vulnerability Assessment
                    ('c0000006-0000-0000-0000-000000000006', 'SUB_NET_VA', 'Network Vulnerability Assessment', 'b0000002-0000-0000-0000-000000000002', true, 1, NOW() AT TIME ZONE 'UTC'),
                    ('c0000007-0000-0000-0000-000000000007', 'SUB_WEB_VA', 'Web Application Vulnerability Assessment', 'b0000002-0000-0000-0000-000000000002', true, 2, NOW() AT TIME ZONE 'UTC'),
                    ('c0000008-0000-0000-0000-000000000008', 'SUB_CLOUD_VA', 'Cloud Infrastructure Vulnerability Assessment', 'b0000002-0000-0000-0000-000000000002', true, 3, NOW() AT TIME ZONE 'UTC'),
                    -- Red Team
                    ('c0000009-0000-0000-0000-000000000009', 'SUB_ADV_SIM', 'Adversary Simulation', 'b0000003-0000-0000-0000-000000000003', true, 1, NOW() AT TIME ZONE 'UTC'),
                    -- Cloud Security
                    ('c000000a-0000-0000-0000-00000000000a', 'SUB_AWS_SEC', 'AWS Security Assessment', 'b0000004-0000-0000-0000-000000000004', true, 1, NOW() AT TIME ZONE 'UTC'),
                    ('c000000b-0000-0000-0000-00000000000b', 'SUB_AZURE_SEC', 'Azure Security Assessment', 'b0000004-0000-0000-0000-000000000004', true, 2, NOW() AT TIME ZONE 'UTC'),
                    ('c000000c-0000-0000-0000-00000000000c', 'SUB_GCP_SEC', 'Google Cloud Security Assessment', 'b0000004-0000-0000-0000-000000000004', true, 3, NOW() AT TIME ZONE 'UTC'),
                    -- Code & App Security
                    ('c000000d-0000-0000-0000-00000000000d', 'SUB_CODE_REV', 'Source Code Security Review', 'b0000005-0000-0000-0000-000000000005', true, 1, NOW() AT TIME ZONE 'UTC'),
                    ('c000000e-0000-0000-0000-00000000000e', 'SUB_SAST', 'Static Application Security Testing', 'b0000005-0000-0000-0000-000000000005', true, 2, NOW() AT TIME ZONE 'UTC'),
                    ('c000000f-0000-0000-0000-00000000000f', 'SUB_DAST', 'Dynamic Application Security Testing', 'b0000005-0000-0000-0000-000000000005', true, 3, NOW() AT TIME ZONE 'UTC'),
                    -- Compliance & Audit
                    ('c0000010-0000-0000-0000-000000000010', 'SUB_ISO27001', 'ISO 27001 Security Audit', 'b0000006-0000-0000-0000-000000000006', true, 1, NOW() AT TIME ZONE 'UTC'),
                    ('c0000011-0000-0000-0000-000000000011', 'SUB_GDPR', 'GDPR Compliance Assessment', 'b0000006-0000-0000-0000-000000000006', true, 2, NOW() AT TIME ZONE 'UTC'),
                    ('c0000012-0000-0000-0000-000000000012', 'SUB_PCIDSS', 'PCI-DSS Compliance Assessment', 'b0000006-0000-0000-0000-000000000006', true, 3, NOW() AT TIME ZONE 'UTC'),
                    ('c0000013-0000-0000-0000-000000000013', 'SUB_SOC2', 'SOC 2 Type II Audit', 'b0000006-0000-0000-0000-000000000006', true, 4, NOW() AT TIME ZONE 'UTC'),
                    -- Social Engineering
                    ('c0000014-0000-0000-0000-000000000014', 'SUB_PHISHING', 'Phishing Campaign & Assessment', 'b0000007-0000-0000-0000-000000000007', true, 1, NOW() AT TIME ZONE 'UTC'),
                    ('c0000015-0000-0000-0000-000000000015', 'SUB_AWARENESS', 'Security Awareness Training Program', 'b0000007-0000-0000-0000-000000000007', true, 2, NOW() AT TIME ZONE 'UTC'),
                    ('c0000016-0000-0000-0000-000000000016', 'SUB_VISHING', 'Vishing & Pretexting Assessment', 'b0000007-0000-0000-0000-000000000007', true, 3, NOW() AT TIME ZONE 'UTC'),
                    -- Forensics & IR
                    ('c0000017-0000-0000-0000-000000000017', 'SUB_FORENSICS', 'Digital Forensics Investigation', 'b0000008-0000-0000-0000-000000000008', true, 1, NOW() AT TIME ZONE 'UTC'),
                    ('c0000018-0000-0000-0000-000000000018', 'SUB_IR', 'Incident Response & Containment', 'b0000008-0000-0000-0000-000000000008', true, 2, NOW() AT TIME ZONE 'UTC'),
                    ('c0000019-0000-0000-0000-000000000019', 'SUB_MALWARE', 'Malware Analysis', 'b0000008-0000-0000-0000-000000000008', true, 3, NOW() AT TIME ZONE 'UTC'),
                    -- Network & Infra
                    ('c000001a-0000-0000-0000-00000000001a', 'SUB_NET_ARCH', 'Network Architecture Security Review', 'b0000009-0000-0000-0000-000000000009', true, 1, NOW() AT TIME ZONE 'UTC'),
                    ('c000001b-0000-0000-0000-00000000001b', 'SUB_FIREWALL', 'Firewall & IDS/IPS Configuration Audit', 'b0000009-0000-0000-0000-000000000009', true, 2, NOW() AT TIME ZONE 'UTC'),
                    ('c000001c-0000-0000-0000-00000000001c', 'SUB_NET_SEG', 'Network Segmentation Assessment', 'b0000009-0000-0000-0000-000000000009', true, 3, NOW() AT TIME ZONE 'UTC'),
                    -- Threat Intel
                    ('c000001d-0000-0000-0000-00000000001d', 'SUB_THREAT_MOD', 'Threat Modeling & Risk Assessment', 'b000000a-0000-0000-0000-00000000000a', true, 1, NOW() AT TIME ZONE 'UTC'),
                    ('c000001e-0000-0000-0000-00000000001e', 'SUB_THREAT_REP', 'Cyber Threat Intelligence Report', 'b000000a-0000-0000-0000-00000000000a', true, 2, NOW() AT TIME ZONE 'UTC'),
                    ('c000001f-0000-0000-0000-00000000001f', 'SUB_ATTACK_SURF', 'Attack Surface Analysis', 'b000000a-0000-0000-0000-00000000000a', true, 3, NOW() AT TIME ZONE 'UTC')
                ON CONFLICT ("Code") DO NOTHING;

                -- 4. Seed Service Catalog
                INSERT INTO mst_service_catalog ("Id", "Code", "Name", "SubDepartmentId", "DefaultTools", "DefaultUnitPrice", "DefaultDurationDays", "IsActive", "SortOrder", "CreatedAtUtc") VALUES
                    -- Penetration Testing
                    ('d0000001-0000-0000-0000-000000000001', 'PT001', 'External Network Penetration Testing', 'c0000001-0000-0000-0000-000000000001', 'Nessus, Metasploit', 60000.00, 5, true, 1, NOW() AT TIME ZONE 'UTC'),
                    ('d0000002-0000-0000-0000-000000000002', 'PT002', 'Internal Network Penetration Testing', 'c0000001-0000-0000-0000-000000000001', 'Burp Suite, Cobalt Strike', 75000.00, 6, true, 2, NOW() AT TIME ZONE 'UTC'),
                    ('d0000003-0000-0000-0000-000000000003', 'PT003', 'Web Application Penetration Testing', 'c0000002-0000-0000-0000-000000000002', 'Burp Suite, OWASP ZAP', 50000.00, 5, true, 3, NOW() AT TIME ZONE 'UTC'),
                    ('d0000004-0000-0000-0000-000000000004', 'PT004', 'Mobile Application Penetration Testing', 'c0000003-0000-0000-0000-000000000003', 'Frida, Burp Suite Mobile', 55000.00, 5, true, 4, NOW() AT TIME ZONE 'UTC'),
                    ('d0000005-0000-0000-0000-000000000005', 'PT005', 'API Penetration Testing', 'c0000004-0000-0000-0000-000000000004', 'Postman, Burp Suite', 40000.00, 4, true, 5, NOW() AT TIME ZONE 'UTC'),
                    ('d0000006-0000-0000-0000-000000000006', 'PT006', 'Thick Client Penetration Testing', 'c0000005-0000-0000-0000-000000000005', 'Burp Suite, API Fuzzer', 45000.00, 4, true, 6, NOW() AT TIME ZONE 'UTC'),
                    -- Vulnerability Assessment
                    ('d0000007-0000-0000-0000-000000000007', 'VA001', 'Network Vulnerability Assessment', 'c0000006-0000-0000-0000-000000000006', 'Nessus, OpenVAS, Qualys', 35000.00, 3, true, 7, NOW() AT TIME ZONE 'UTC'),
                    ('d0000008-0000-0000-0000-000000000008', 'VA002', 'Web Application Vulnerability Assessment', 'c0000007-0000-0000-0000-000000000007', 'Acunetix, Qualys, Rapid7', 40000.00, 4, true, 8, NOW() AT TIME ZONE 'UTC'),
                    ('d0000009-0000-0000-0000-000000000009', 'VA003', 'Cloud Infrastructure Vulnerability Assessment', 'c0000008-0000-0000-0000-000000000008', 'Dome9, CloudSploit', 50000.00, 4, true, 9, NOW() AT TIME ZONE 'UTC'),
                    -- Red Team
                    ('d000000a-0000-0000-0000-00000000000a', 'RT001', 'Full Spectrum Red Team Exercise', 'c0000009-0000-0000-0000-000000000009', 'Cobalt Strike, Metasploit, Mimikatz', 120000.00, 10, true, 10, NOW() AT TIME ZONE 'UTC'),
                    ('d000000b-0000-0000-0000-00000000000b', 'RT002', 'Targeted Red Team Engagement', 'c0000009-0000-0000-0000-000000000009', 'Custom Tools, Cobalt Strike', 80000.00, 7, true, 11, NOW() AT TIME ZONE 'UTC'),
                    -- Cloud Security
                    ('d000000c-0000-0000-0000-00000000000c', 'CS001', 'AWS Security Assessment', 'c000000a-0000-0000-0000-00000000000a', 'Scout2, CloudMapper, AWS Inspector', 55000.00, 5, true, 12, NOW() AT TIME ZONE 'UTC'),
                    ('d000000d-0000-0000-0000-00000000000d', 'CS002', 'Azure Security Assessment', 'c000000b-0000-0000-0000-00000000000b', 'Azucar, Microsoft Defender, Qualys', 55000.00, 5, true, 13, NOW() AT TIME ZONE 'UTC'),
                    ('d000000e-0000-0000-0000-00000000000e', 'CS003', 'Google Cloud Security Assessment', 'c000000c-0000-0000-0000-00000000000c', 'GCP Security Command Center', 50000.00, 5, true, 14, NOW() AT TIME ZONE 'UTC'),
                    -- Code & App Security
                    ('d000000f-0000-0000-0000-00000000000f', 'CODE001', 'Source Code Security Review', 'c000000d-0000-0000-0000-00000000000d', 'SonarQube, Checkmarx, Fortify', 65000.00, 6, true, 15, NOW() AT TIME ZONE 'UTC'),
                    ('d0000010-0000-0000-0000-000000000010', 'CODE002', 'Static Application Security Testing (SAST)', 'c000000e-0000-0000-0000-00000000000e', 'Checkmarx, Veracode, Fortify', 70000.00, 7, true, 16, NOW() AT TIME ZONE 'UTC'),
                    ('d0000011-0000-0000-0000-000000000011', 'CODE003', 'Dynamic Application Security Testing (DAST)', 'c000000f-0000-0000-0000-00000000000f', 'Burp Suite, Acunetix, AppScan', 60000.00, 6, true, 17, NOW() AT TIME ZONE 'UTC'),
                    -- Compliance & Audit
                    ('d0000012-0000-0000-0000-000000000012', 'COMP001', 'ISO 27001 Security Audit', 'c0000010-0000-0000-0000-000000000010', 'AuditBoard, Drata, Vanta', 85000.00, 8, true, 18, NOW() AT TIME ZONE 'UTC'),
                    ('d0000013-0000-0000-0000-000000000013', 'COMP002', 'GDPR Compliance Assessment', 'c0000011-0000-0000-0000-000000000011', 'OneTrust, TrustArc, Compliance.ai', 75000.00, 7, true, 19, NOW() AT TIME ZONE 'UTC'),
                    ('d0000014-0000-0000-0000-000000000014', 'COMP003', 'PCI-DSS Compliance Assessment', 'c0000012-0000-0000-0000-000000000012', 'Qualys, Rapid7, Nessus', 80000.00, 7, true, 20, NOW() AT TIME ZONE 'UTC'),
                    ('d0000015-0000-0000-0000-000000000015', 'COMP004', 'SOC 2 Type II Audit', 'c0000013-0000-0000-0000-000000000013', 'AuditBoard, Drata', 95000.00, 10, true, 21, NOW() AT TIME ZONE 'UTC'),
                    -- Social Engineering
                    ('d0000016-0000-0000-0000-000000000016', 'SE001', 'Phishing Campaign & Assessment', 'c0000014-0000-0000-0000-000000000014', 'KnowBe4, Gophish, Phish Alert', 30000.00, 2, true, 22, NOW() AT TIME ZONE 'UTC'),
                    ('d0000017-0000-0000-0000-000000000017', 'SE002', 'Security Awareness Training Program', 'c0000015-0000-0000-0000-000000000015', 'LinkedIn Learning, KnowBe4, SANS', 45000.00, 4, true, 23, NOW() AT TIME ZONE 'UTC'),
                    ('d0000018-0000-0000-0000-000000000018', 'SE003', 'Vishing & Pretexting Assessment', 'c0000016-0000-0000-0000-000000000016', 'Custom, KnowBe4', 35000.00, 3, true, 24, NOW() AT TIME ZONE 'UTC'),
                    -- Forensics & IR
                    ('d0000019-0000-0000-0000-000000000019', 'FOR001', 'Digital Forensics Investigation', 'c0000017-0000-0000-0000-000000000017', 'EnCase, FTK, Volatility, X-Ways', 90000.00, 8, true, 25, NOW() AT TIME ZONE 'UTC'),
                    ('d000001a-0000-0000-0000-00000000001a', 'FOR002', 'Incident Response & Containment', 'c0000018-0000-0000-0000-000000000018', 'Splunk, ELK, Rapid7 InsightIDR', 75000.00, 7, true, 26, NOW() AT TIME ZONE 'UTC'),
                    ('d000001b-0000-0000-0000-00000000001b', 'FOR003', 'Malware Analysis', 'c0000019-0000-0000-0000-000000000019', 'IDA Pro, Ghidra, Wireshark, Cuckoo', 70000.00, 6, true, 27, NOW() AT TIME ZONE 'UTC'),
                    -- Network & Infra
                    ('d000001c-0000-0000-0000-00000000001c', 'NET001', 'Network Architecture Security Review', 'c000001a-0000-0000-0000-00000000001a', 'Nmap, Wireshark, NETMON', 55000.00, 5, true, 28, NOW() AT TIME ZONE 'UTC'),
                    ('d000001d-0000-0000-0000-00000000001d', 'NET002', 'Firewall & IDS/IPS Configuration Audit', 'c000001b-0000-0000-0000-00000000001b', 'Nessus, OpenVAS, Custom Scripts', 65000.00, 6, true, 29, NOW() AT TIME ZONE 'UTC'),
                    ('d000001e-0000-0000-0000-00000000001e', 'NET003', 'Network Segmentation Assessment', 'c000001c-0000-0000-0000-00000000001c', 'Nmap, Shodan, Custom Tools', 60000.00, 5, true, 30, NOW() AT TIME ZONE 'UTC'),
                    -- Threat Intel
                    ('d000001f-0000-0000-0000-00000000001f', 'THREAT001', 'Threat Modeling & Risk Assessment', 'c000001d-0000-0000-0000-00000000001d', 'Microsoft Threat Modeling Tool, IriusRisk', 50000.00, 4, true, 31, NOW() AT TIME ZONE 'UTC'),
                    ('d0000020-0000-0000-0000-000000000020', 'THREAT002', 'Cyber Threat Intelligence Report', 'c000001e-0000-0000-0000-00000000001e', 'MISP, Mandiant, CrowdStrike', 40000.00, 3, true, 32, NOW() AT TIME ZONE 'UTC'),
                    ('d0000021-0000-0000-0000-000000000021', 'THREAT003', 'Attack Surface Analysis', 'c000001f-0000-0000-0000-00000000001f', 'Shodan, Censys, Rapid7 Sonar', 45000.00, 4, true, 33, NOW() AT TIME ZONE 'UTC')
                ON CONFLICT ("Code") DO NOTHING;
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                DROP TABLE IF EXISTS mst_service_catalog;
                DROP TABLE IF EXISTS mst_service_sub_departments;
                DROP TABLE IF EXISTS mst_service_departments;
                DROP TABLE IF EXISTS mst_service_groups;
                """);
        }
    }
}
