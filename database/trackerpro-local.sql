-- =========================================================
-- TrackerPro / Pulse PMO â€” Local Development Database
-- PostgreSQL
-- =========================================================
-- Purpose:
--   Creates (or brings up to date) the schema and master data
--   required to run the PMS.API backend against a LOCAL
--   PostgreSQL instance, for developers working off-network.
--
-- IMPORTANT:
--   Do NOT execute this against the shared/production database
--   (the team Docker host). It is intended for a local
--   developer database only.
--
-- Source of truth:
--   apps/backend/Migrations (EF Core). This file is generated
--   from those migrations plus the runtime schema alignment in
--   Infrastructure/Persistence/Seeding/DbInitializerHostedService.cs,
--   and the master/reference rows currently used by the app.
--   Regenerate with:
--     dotnet ef migrations script --idempotent \
--       --project apps/backend/PMS.API.csproj \
--       --startup-project apps/backend/PMS.API.csproj
--
-- Target database name: trackerpro
--   The script does NOT create the database. Create it first if
--   it does not exist, then run this file while connected to it:
--
--     createdb -U <local_user> trackerpro
--     psql -h localhost -U <local_user> -d trackerpro -f database/trackerpro-local.sql
--
--   (or open the file in pgAdmin against the trackerpro database)
--
-- Safety:
--   Every statement is idempotent. There is no DROP DATABASE,
--   DROP SCHEMA, DROP TABLE, DELETE or TRUNCATE anywhere in this
--   file. Schema blocks are guarded by "__EFMigrationsHistory"
--   and data rows use ON CONFLICT DO NOTHING, so re-running is
--   safe and never removes existing local rows.
--
--   Section 1 does replay the migration history verbatim, which
--   includes a few historical ALTER TABLE ... DROP COLUMN steps
--   (for example clients."SubVentures", superseded by the
--   sub_ventures table). Those run only for migrations this
--   database has not recorded yet, so on an up-to-date database
--   they are skipped, and on a new database they only drop
--   columns created moments earlier in the same script.
--
-- Contents:
--   1. Schema â€” 32 tables (EF Core migrations, idempotent)
--   2. Runtime schema alignment (columns the app adds at startup)
--   3. Master / reference data (504 rows, ON CONFLICT DO NOTHING)
--
-- Not included (created by the application on first run, so that
-- no credentials or business data live in source control):
--   - users / refresh_tokens (demo logins are seeded by DbSeeder)
--   - clients / sub_ventures / client_contacts / employees
--   - repository documents and activity logs
--   - mst_reporting_managers (derived from employees at seed time)
-- =========================================================


-- =========================================================
-- SECTION 1 â€” SCHEMA (EF Core migrations, idempotent)
-- =========================================================

CREATE TABLE IF NOT EXISTS "__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL,
    CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId")
);

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807073751_InitialIdentity') THEN
    CREATE TABLE clients (
        "Id" uuid NOT NULL,
        "Name" character varying(255) NOT NULL,
        "Industry" character varying(100) NOT NULL,
        "Logo" character varying(10),
        "ContactEmail" character varying(255),
        "ClientType" character varying(10) NOT NULL,
        "Status" character varying(20) NOT NULL,
        "EngagementManager" character varying(120),
        "CompanyName" character varying(255),
        "ContactName" character varying(150),
        "ContactPhone" character varying(40),
        "ContactDesignation" character varying(120),
        "ContactType" character varying(40),
        "SubVentures" jsonb NOT NULL,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone,
        contacts jsonb,
        CONSTRAINT "PK_clients" PRIMARY KEY ("Id")
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807073751_InitialIdentity') THEN
    CREATE TABLE roles (
        "Id" uuid NOT NULL,
        "Name" integer NOT NULL,
        "DisplayName" character varying(100) NOT NULL,
        "Permissions" jsonb NOT NULL,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone,
        CONSTRAINT "PK_roles" PRIMARY KEY ("Id")
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807073751_InitialIdentity') THEN
    CREATE TABLE users (
        "Id" uuid NOT NULL,
        "Email" character varying(255) NOT NULL,
        "PasswordHash" character varying(255) NOT NULL,
        "Name" character varying(255) NOT NULL,
        "EmployeeId" character varying(20) NOT NULL,
        "Department" text,
        "SubDepartment" text,
        "Avatar" text,
        "Designation" text,
        "IsActive" boolean NOT NULL,
        "MustChangePassword" boolean NOT NULL,
        "RoleId" uuid,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone,
        CONSTRAINT "PK_users" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_users_roles_RoleId" FOREIGN KEY ("RoleId") REFERENCES roles ("Id") ON DELETE RESTRICT
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807073751_InitialIdentity') THEN
    CREATE TABLE client_assignments (
        "ClientId" uuid NOT NULL,
        "UserId" uuid NOT NULL,
        CONSTRAINT "PK_client_assignments" PRIMARY KEY ("ClientId", "UserId"),
        CONSTRAINT "FK_client_assignments_clients_ClientId" FOREIGN KEY ("ClientId") REFERENCES clients ("Id") ON DELETE CASCADE,
        CONSTRAINT "FK_client_assignments_users_UserId" FOREIGN KEY ("UserId") REFERENCES users ("Id") ON DELETE CASCADE
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807073751_InitialIdentity') THEN
    CREATE TABLE refresh_tokens (
        "Id" uuid NOT NULL,
        "UserId" uuid NOT NULL,
        "TokenHash" character varying(255) NOT NULL,
        "ExpiresAtUtc" timestamp with time zone NOT NULL,
        "RevokedAtUtc" timestamp with time zone,
        "ReplacedByTokenHash" text,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone,
        CONSTRAINT "PK_refresh_tokens" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_refresh_tokens_users_UserId" FOREIGN KEY ("UserId") REFERENCES users ("Id") ON DELETE CASCADE
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807073751_InitialIdentity') THEN
    CREATE INDEX "IX_client_assignments_UserId" ON client_assignments ("UserId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807073751_InitialIdentity') THEN
    CREATE INDEX "IX_clients_Name" ON clients ("Name");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807073751_InitialIdentity') THEN
    CREATE UNIQUE INDEX "IX_refresh_tokens_TokenHash" ON refresh_tokens ("TokenHash");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807073751_InitialIdentity') THEN
    CREATE INDEX "IX_refresh_tokens_UserId" ON refresh_tokens ("UserId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807073751_InitialIdentity') THEN
    CREATE UNIQUE INDEX "IX_roles_Name" ON roles ("Name");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807073751_InitialIdentity') THEN
    CREATE UNIQUE INDEX "IX_users_Email" ON users ("Email");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807073751_InitialIdentity') THEN
    CREATE UNIQUE INDEX "IX_users_EmployeeId" ON users ("EmployeeId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807073751_InitialIdentity') THEN
    CREATE INDEX "IX_users_RoleId" ON users ("RoleId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807073751_InitialIdentity') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260807073751_InitialIdentity', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807075509_AddUserSecurity') THEN
    ALTER TABLE users ADD "FailedLoginAttempts" integer NOT NULL DEFAULT 0;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807075509_AddUserSecurity') THEN
    ALTER TABLE users ADD "LastLoginAtUtc" timestamp with time zone;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807075509_AddUserSecurity') THEN
    ALTER TABLE users ADD "LockedUntilUtc" timestamp with time zone;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807075509_AddUserSecurity') THEN
    ALTER TABLE users ADD "PasswordChangedAtUtc" timestamp with time zone;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807075509_AddUserSecurity') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260807075509_AddUserSecurity', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807101120_AddClientFormDetails') THEN
    ALTER TABLE clients ADD "BusinessType" character varying(40);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807101120_AddClientFormDetails') THEN
    ALTER TABLE clients ADD "City" character varying(120);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807101120_AddClientFormDetails') THEN
    ALTER TABLE clients ADD "Country" character varying(120);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807101120_AddClientFormDetails') THEN
    ALTER TABLE clients ADD "KycDocumentName" character varying(255);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807101120_AddClientFormDetails') THEN
    ALTER TABLE clients ADD "Notes" character varying(2000);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807101120_AddClientFormDetails') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260807101120_AddClientFormDetails', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807105244_SubVentureContactsAndLogo') THEN
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
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807105244_SubVentureContactsAndLogo') THEN
    UPDATE "clients"
    SET "Logo" = UPPER(LEFT("Name", 1) || RIGHT("Name", 1))
    WHERE "Name" IS NOT NULL AND "Name" <> '';
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807105244_SubVentureContactsAndLogo') THEN
    ALTER TABLE clients DROP COLUMN "CompanyName";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807105244_SubVentureContactsAndLogo') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260807105244_SubVentureContactsAndLogo', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807112338_SubVentureTableAndLogoRule') THEN
    CREATE TABLE sub_ventures (
        "Id" uuid NOT NULL,
        "ClientId" uuid NOT NULL,
        "Name" character varying(255) NOT NULL,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone,
        contacts jsonb,
        CONSTRAINT "PK_sub_ventures" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_sub_ventures_clients_ClientId" FOREIGN KEY ("ClientId") REFERENCES clients ("Id") ON DELETE CASCADE
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807112338_SubVentureTableAndLogoRule') THEN
    CREATE INDEX "IX_sub_ventures_ClientId" ON sub_ventures ("ClientId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807112338_SubVentureTableAndLogoRule') THEN
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
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807112338_SubVentureTableAndLogoRule') THEN
    ALTER TABLE clients DROP COLUMN "SubVentures";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807112338_SubVentureTableAndLogoRule') THEN
    UPDATE "clients"
    SET "Logo" = UPPER(
        left(split_part(regexp_replace(trim("Name"), '\s+', ' ', 'g'), ' ', 1), 1) ||
        COALESCE(left(split_part(regexp_replace(trim("Name"), '\s+', ' ', 'g'), ' ', 2), 1), '')
    )
    WHERE "Name" IS NOT NULL AND trim("Name") <> '';
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260807112338_SubVentureTableAndLogoRule') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260807112338_SubVentureTableAndLogoRule', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260810121931_RbacRoleManagement') THEN
    DROP INDEX "IX_roles_Name";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260810121931_RbacRoleManagement') THEN
    ALTER TABLE roles ADD "NameText" character varying(50);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260810121931_RbacRoleManagement') THEN
    UPDATE roles SET "NameText" = CASE "Name"
        WHEN 0 THEN 'SeniorPm'
        WHEN 1 THEN 'EngagementManager'
        WHEN 2 THEN 'Pmo'
        WHEN 3 THEN 'Hod'
        WHEN 4 THEN 'BusinessOwner'
        WHEN 5 THEN 'Dhanshree'
        WHEN 6 THEN 'Sales'
        WHEN 7 THEN 'Accounts'
        WHEN 8 THEN 'Hr'
        WHEN 9 THEN 'ProjectManager'
        WHEN 10 THEN 'TeamLead'
        WHEN 11 THEN 'Employee'
        WHEN 12 THEN 'Admin'
        ELSE 'Role' || "Name"
    END;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260810121931_RbacRoleManagement') THEN
    ALTER TABLE roles DROP COLUMN "Name";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260810121931_RbacRoleManagement') THEN
    ALTER TABLE roles RENAME COLUMN "NameText" TO "Name";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260810121931_RbacRoleManagement') THEN
    UPDATE roles SET "Name" = '' WHERE "Name" IS NULL;
    ALTER TABLE roles ALTER COLUMN "Name" SET NOT NULL;
    ALTER TABLE roles ALTER COLUMN "Name" SET DEFAULT '';
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260810121931_RbacRoleManagement') THEN
    CREATE UNIQUE INDEX "IX_roles_Name" ON roles ("Name");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260810121931_RbacRoleManagement') THEN
    ALTER TABLE roles ADD "Description" character varying(500);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260810121931_RbacRoleManagement') THEN
    ALTER TABLE roles ADD "IsActive" boolean NOT NULL DEFAULT TRUE;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260810121931_RbacRoleManagement') THEN
    ALTER TABLE roles ADD "IsSystemRole" boolean NOT NULL DEFAULT FALSE;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260810121931_RbacRoleManagement') THEN
    UPDATE roles SET "IsSystemRole" = true;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260810121931_RbacRoleManagement') THEN
    CREATE TABLE role_permission_audits (
        "Id" uuid NOT NULL,
        "RoleId" uuid NOT NULL,
        "RoleName" character varying(100) NOT NULL,
        "ModuleKey" character varying(100) NOT NULL,
        "ModuleLabel" character varying(100) NOT NULL,
        "SubmoduleKey" character varying(100),
        "SubmoduleLabel" character varying(100),
        "PermissionKey" character varying(150) NOT NULL,
        "ActionLabel" character varying(100) NOT NULL,
        "ChangeType" character varying(20) NOT NULL,
        "PreviousValue" character varying(50) NOT NULL,
        "NewValue" character varying(50) NOT NULL,
        "ChangedById" uuid,
        "ChangedByName" character varying(255),
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone,
        CONSTRAINT "PK_role_permission_audits" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_role_permission_audits_roles_RoleId" FOREIGN KEY ("RoleId") REFERENCES roles ("Id") ON DELETE CASCADE
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260810121931_RbacRoleManagement') THEN
    CREATE INDEX "IX_role_permission_audits_CreatedAtUtc" ON role_permission_audits ("CreatedAtUtc");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260810121931_RbacRoleManagement') THEN
    CREATE INDEX "IX_role_permission_audits_RoleId" ON role_permission_audits ("RoleId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260810121931_RbacRoleManagement') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260810121931_RbacRoleManagement', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    ALTER TABLE clients ADD "EngagementManagerId" uuid;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    ALTER TABLE clients ADD "IndustryId" uuid;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE TABLE client_contacts (
        "Id" uuid NOT NULL,
        "ClientId" uuid,
        "SubVentureId" uuid,
        "Name" character varying(150),
        "Email" character varying(255),
        "Phone" character varying(40),
        "Designation" character varying(120),
        "ContactType" character varying(40),
        "IsPrimary" boolean NOT NULL,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone,
        CONSTRAINT "PK_client_contacts" PRIMARY KEY ("Id"),
        CONSTRAINT "CK_client_contacts_exactly_one_owner" CHECK (("ClientId" IS NOT NULL AND "SubVentureId" IS NULL) OR ("ClientId" IS NULL AND "SubVentureId" IS NOT NULL)),
        CONSTRAINT "FK_client_contacts_clients_ClientId" FOREIGN KEY ("ClientId") REFERENCES clients ("Id") ON DELETE CASCADE,
        CONSTRAINT "FK_client_contacts_sub_ventures_SubVentureId" FOREIGN KEY ("SubVentureId") REFERENCES sub_ventures ("Id") ON DELETE CASCADE
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE TABLE exited_employees (
        "Id" uuid NOT NULL,
        "OriginalEmployeeId" uuid NOT NULL,
        "EmployeeCode" character varying(20) NOT NULL,
        "FullName" character varying(255) NOT NULL,
        "DepartmentName" character varying(150),
        "DesignationName" character varying(150),
        "WorkEmail" character varying(255),
        "PersonalEmail" character varying(255),
        "Phone" character varying(40),
        "StatusAtExit" character varying(60),
        "ExitType" character varying(80),
        "ExitReason" character varying(500),
        "ResignationDate" date,
        "LastWorkingDay" date,
        "ReasonForLeaving" character varying(500),
        "NoticePeriodServed" character varying(80),
        "ExitChecklistJson" jsonb,
        "AssetReturnJson" jsonb,
        "FinalSettlementJson" jsonb,
        "ExitedAtUtc" timestamp with time zone NOT NULL,
        "ExitedBy" uuid,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone,
        CONSTRAINT "PK_exited_employees" PRIMARY KEY ("Id")
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE TABLE mst_departments (
        "Id" uuid NOT NULL,
        "Code" character varying(50) NOT NULL,
        "Name" character varying(150) NOT NULL,
        "IsActive" boolean NOT NULL,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone,
        CONSTRAINT "PK_mst_departments" PRIMARY KEY ("Id")
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE TABLE mst_industries (
        "Id" uuid NOT NULL,
        "Code" character varying(80) NOT NULL,
        "Name" character varying(150) NOT NULL,
        "IsActive" boolean NOT NULL,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone,
        CONSTRAINT "PK_mst_industries" PRIMARY KEY ("Id")
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE TABLE mst_designations (
        "Id" uuid NOT NULL,
        "Code" character varying(80) NOT NULL,
        "Name" character varying(150) NOT NULL,
        "IsActive" boolean NOT NULL,
        "DepartmentId" uuid,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone,
        CONSTRAINT "PK_mst_designations" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_mst_designations_mst_departments_DepartmentId" FOREIGN KEY ("DepartmentId") REFERENCES mst_departments ("Id") ON DELETE SET NULL
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE TABLE employees (
        "Id" uuid NOT NULL,
        "EmployeeCode" character varying(20) NOT NULL,
        "FirstName" character varying(120) NOT NULL,
        "LastName" character varying(120) NOT NULL,
        "WorkEmail" character varying(255) NOT NULL,
        "PersonalEmail" character varying(255),
        "Phone" character varying(40),
        "AltPhone" character varying(40),
        "Gender" text,
        "DateOfBirth" date,
        "Address" text,
        "EmergencyContact" text,
        "MaritalStatus" text,
        "Nationality" text,
        "DepartmentId" uuid,
        "DesignationId" uuid,
        "Role" character varying(80),
        "ReportingManagerId" uuid,
        "BusinessUnit" character varying(120),
        "WorkLocation" character varying(120),
        "OfficeBranch" character varying(120),
        "Category" character varying(80),
        "Team" character varying(120),
        "ProjectSite" character varying(80),
        "JoiningDate" date,
        "Status" character varying(60),
        "ConfirmationStatus" character varying(80),
        "ProbationStatus" character varying(80),
        "Experience" character varying(80),
        "PreviousCompany" character varying(160),
        "EmploymentType" character varying(80),
        "ContractType" character varying(80),
        "BondStatus" character varying(80),
        "NoticePeriod" character varying(80),
        "AssetId" character varying(80),
        "ExitType" character varying(80),
        "ExitReason" character varying(500),
        "Education" character varying(255),
        "Skills" jsonb NOT NULL,
        "Certifications" jsonb NOT NULL,
        "Languages" jsonb NOT NULL,
        "KpiScore" numeric,
        "QuarterlyKpi" numeric,
        "AnnualRating" numeric,
        "GoalCompletion" numeric,
        "Attendance" numeric,
        "ReportingEfficiency" numeric,
        "PromotionReadiness" character varying(120),
        "ManagerFeedback" character varying(500),
        "Pan" character varying(40),
        "BankAccount" character varying(80),
        "SalaryBand" character varying(40),
        "PfUan" character varying(40),
        "TaxRegime" character varying(80),
        "ComplianceStatus" character varying(80),
        "UserId" uuid,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone,
        CONSTRAINT "PK_employees" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_employees_employees_ReportingManagerId" FOREIGN KEY ("ReportingManagerId") REFERENCES employees ("Id") ON DELETE SET NULL,
        CONSTRAINT "FK_employees_mst_departments_DepartmentId" FOREIGN KEY ("DepartmentId") REFERENCES mst_departments ("Id") ON DELETE SET NULL,
        CONSTRAINT "FK_employees_mst_designations_DesignationId" FOREIGN KEY ("DesignationId") REFERENCES mst_designations ("Id") ON DELETE SET NULL,
        CONSTRAINT "FK_employees_users_UserId" FOREIGN KEY ("UserId") REFERENCES users ("Id") ON DELETE SET NULL
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE INDEX "IX_clients_EngagementManagerId" ON clients ("EngagementManagerId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE INDEX "IX_clients_IndustryId" ON clients ("IndustryId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE INDEX "IX_client_contacts_ClientId" ON client_contacts ("ClientId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE INDEX "IX_client_contacts_SubVentureId" ON client_contacts ("SubVentureId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE INDEX "IX_employees_DepartmentId" ON employees ("DepartmentId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE INDEX "IX_employees_DesignationId" ON employees ("DesignationId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE UNIQUE INDEX "IX_employees_EmployeeCode" ON employees ("EmployeeCode");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE INDEX "IX_employees_ReportingManagerId" ON employees ("ReportingManagerId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE INDEX "IX_employees_UserId" ON employees ("UserId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE UNIQUE INDEX "IX_employees_WorkEmail" ON employees ("WorkEmail");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE INDEX "IX_exited_employees_EmployeeCode" ON exited_employees ("EmployeeCode");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE INDEX "IX_exited_employees_OriginalEmployeeId" ON exited_employees ("OriginalEmployeeId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE UNIQUE INDEX "IX_mst_departments_Code" ON mst_departments ("Code");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE UNIQUE INDEX "IX_mst_departments_Name" ON mst_departments ("Name");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE UNIQUE INDEX "IX_mst_designations_Code" ON mst_designations ("Code");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE INDEX "IX_mst_designations_DepartmentId" ON mst_designations ("DepartmentId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE UNIQUE INDEX "IX_mst_industries_Code" ON mst_industries ("Code");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    CREATE UNIQUE INDEX "IX_mst_industries_Name" ON mst_industries ("Name");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    INSERT INTO mst_departments ("Id","Code","Name","IsActive","CreatedAtUtc")
    VALUES
    (gen_random_uuid(),'product','Product',true,now()),
    (gen_random_uuid(),'design','Design',true,now()),
    (gen_random_uuid(),'marketing','Marketing',true,now()),
    (gen_random_uuid(),'sales','Sales',true,now()),
    (gen_random_uuid(),'finance','Finance',true,now()),
    (gen_random_uuid(),'human_resources','Human Resources',true,now()),
    (gen_random_uuid(),'operations','Operations',true,now()),
    (gen_random_uuid(),'engineering','Engineering',true,now()),
    (gen_random_uuid(),'delivery','Delivery',true,now()),
    (gen_random_uuid(),'leadership','Leadership',true,now())
    ON CONFLICT ("Code") DO NOTHING;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    INSERT INTO mst_designations ("Id","Code","Name","IsActive","CreatedAtUtc")
    VALUES
    (gen_random_uuid(),'engineering_manager','Engineering Manager',true,now()),
    (gen_random_uuid(),'product_manager','Product Manager',true,now()),
    (gen_random_uuid(),'ux_designer','UX Designer',true,now()),
    (gen_random_uuid(),'marketing_lead','Marketing Lead',true,now()),
    (gen_random_uuid(),'sales_executive','Sales Executive',true,now()),
    (gen_random_uuid(),'finance_analyst','Finance Analyst',true,now()),
    (gen_random_uuid(),'hr_business_partner','HR Business Partner',true,now()),
    (gen_random_uuid(),'software_engineer','Software Engineer',true,now()),
    (gen_random_uuid(),'senior_software_engineer','Senior Software Engineer',true,now()),
    (gen_random_uuid(),'tech_lead','Tech Lead',true,now()),
    (gen_random_uuid(),'devops_engineer','DevOps Engineer',true,now()),
    (gen_random_uuid(),'qa_engineer','QA Engineer',true,now()),
    (gen_random_uuid(),'data_analyst','Data Analyst',true,now()),
    (gen_random_uuid(),'content_strategist','Content Strategist',true,now()),
    (gen_random_uuid(),'business_analyst','Business Analyst',true,now()),
    (gen_random_uuid(),'project_manager','Project Manager',true,now()),
    (gen_random_uuid(),'engagement_manager','Engagement Manager',true,now()),
    (gen_random_uuid(),'senior_project_manager','Senior Project Manager',true,now()),
    (gen_random_uuid(),'head_of_department','Head of Department',true,now())
    ON CONFLICT ("Code") DO NOTHING;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    INSERT INTO mst_industries ("Id","Code","Name","IsActive","CreatedAtUtc")
    SELECT gen_random_uuid(),
           lower(regexp_replace(trim("Industry"), '[^a-zA-Z0-9]+', '_', 'g')),
           trim("Industry"),
           true,
           now()
    FROM clients
    WHERE "Industry" IS NOT NULL AND trim("Industry") <> ''
    ON CONFLICT ("Name") DO NOTHING;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    INSERT INTO employees (
        "Id","EmployeeCode","FirstName","LastName","WorkEmail","Status","Category","Role","UserId",
        "Skills","Certifications","Languages","CreatedAtUtc"
    )
    SELECT
        gen_random_uuid(),
        u."EmployeeId",
        split_part(u."Name", ' ', 1),
        nullif(trim(substring(u."Name" from position(' ' in u."Name") + 1)), ''),
        u."Email",
        'Active',
        'Permanent - Without Bond',
        r."Name",
        u."Id",
        '[]'::jsonb,
        '[]'::jsonb,
        '[]'::jsonb,
        now()
    FROM users u
    LEFT JOIN roles r ON r."Id" = u."RoleId"
    WHERE NOT EXISTS (
        SELECT 1 FROM employees e WHERE e."EmployeeCode" = u."EmployeeId"
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    UPDATE clients c
    SET "IndustryId" = i."Id"
    FROM mst_industries i
    WHERE trim(c."Industry") = i."Name";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    UPDATE clients c
    SET "EngagementManagerId" = e."Id"
    FROM employees e
    WHERE trim(c."EngagementManager") = trim(concat(e."FirstName", ' ', coalesce(e."LastName", '')));
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    INSERT INTO client_contacts (
        "Id","ClientId","SubVentureId","Name","Email","Phone","Designation","ContactType","IsPrimary","CreatedAtUtc"
    )
    SELECT
        gen_random_uuid(),
        c."Id",
        NULL,
        v->>'Name',
        v->>'Email',
        v->>'Phone',
        v->>'Designation',
        v->>'ContactType',
        false,
        now()
    FROM clients c,
    LATERAL jsonb_array_elements(coalesce(c.contacts, '[]'::jsonb)) v;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    INSERT INTO client_contacts (
        "Id","ClientId","SubVentureId","Name","Email","Phone","Designation","ContactType","IsPrimary","CreatedAtUtc"
    )
    SELECT
        gen_random_uuid(),
        NULL,
        s."Id",
        v->>'Name',
        v->>'Email',
        v->>'Phone',
        v->>'Designation',
        v->>'ContactType',
        false,
        now()
    FROM sub_ventures s,
    LATERAL jsonb_array_elements(coalesce(s.contacts, '[]'::jsonb)) v;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    ALTER TABLE sub_ventures DROP COLUMN contacts;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    ALTER TABLE clients DROP COLUMN contacts;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    ALTER TABLE clients ADD CONSTRAINT "FK_clients_employees_EngagementManagerId" FOREIGN KEY ("EngagementManagerId") REFERENCES employees ("Id") ON DELETE SET NULL;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    ALTER TABLE clients ADD CONSTRAINT "FK_clients_mst_industries_IndustryId" FOREIGN KEY ("IndustryId") REFERENCES mst_industries ("Id") ON DELETE RESTRICT;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260818075129_AddMasterCatalogs') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260818075129_AddMasterCatalogs', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820113531_AddGeoCatalogs') THEN
    ALTER TABLE clients ADD "CityId" uuid;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820113531_AddGeoCatalogs') THEN
    ALTER TABLE clients ADD "CountryId" uuid;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820113531_AddGeoCatalogs') THEN
    CREATE TABLE mst_countries (
        "Id" uuid NOT NULL,
        "Code" character varying(8) NOT NULL,
        "Name" character varying(120) NOT NULL,
        "IsActive" boolean NOT NULL,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone,
        CONSTRAINT "PK_mst_countries" PRIMARY KEY ("Id")
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820113531_AddGeoCatalogs') THEN
    CREATE TABLE mst_cities (
        "Id" uuid NOT NULL,
        "Code" character varying(80) NOT NULL,
        "Name" character varying(120) NOT NULL,
        "IsActive" boolean NOT NULL,
        "CountryId" uuid NOT NULL,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone,
        CONSTRAINT "PK_mst_cities" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_mst_cities_mst_countries_CountryId" FOREIGN KEY ("CountryId") REFERENCES mst_countries ("Id") ON DELETE RESTRICT
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820113531_AddGeoCatalogs') THEN
    CREATE INDEX "IX_clients_CityId" ON clients ("CityId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820113531_AddGeoCatalogs') THEN
    CREATE INDEX "IX_clients_CountryId" ON clients ("CountryId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820113531_AddGeoCatalogs') THEN
    CREATE UNIQUE INDEX "IX_mst_cities_Code" ON mst_cities ("Code");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820113531_AddGeoCatalogs') THEN
    CREATE UNIQUE INDEX "IX_mst_cities_CountryId_Name" ON mst_cities ("CountryId", "Name");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820113531_AddGeoCatalogs') THEN
    CREATE UNIQUE INDEX "IX_mst_countries_Code" ON mst_countries ("Code");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820113531_AddGeoCatalogs') THEN
    CREATE UNIQUE INDEX "IX_mst_countries_Name" ON mst_countries ("Name");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820113531_AddGeoCatalogs') THEN
    ALTER TABLE clients ADD CONSTRAINT "FK_clients_mst_cities_CityId" FOREIGN KEY ("CityId") REFERENCES mst_cities ("Id") ON DELETE RESTRICT;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820113531_AddGeoCatalogs') THEN
    ALTER TABLE clients ADD CONSTRAINT "FK_clients_mst_countries_CountryId" FOREIGN KEY ("CountryId") REFERENCES mst_countries ("Id") ON DELETE RESTRICT;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820113531_AddGeoCatalogs') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260820113531_AddGeoCatalogs', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820122343_AddEmployeeCatalogs') THEN
    DROP INDEX "IX_mst_designations_DepartmentId";
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820122343_AddEmployeeCatalogs') THEN
    ALTER TABLE employees ADD "JobRoleId" uuid;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820122343_AddEmployeeCatalogs') THEN
    ALTER TABLE employees ADD "NationalityId" uuid;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820122343_AddEmployeeCatalogs') THEN
    CREATE TABLE mst_nationalities (
        "Id" uuid NOT NULL,
        "Code" character varying(80) NOT NULL,
        "Name" character varying(120) NOT NULL,
        "IsActive" boolean NOT NULL,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone,
        CONSTRAINT "PK_mst_nationalities" PRIMARY KEY ("Id")
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820122343_AddEmployeeCatalogs') THEN
    CREATE TABLE mst_roles (
        "Id" uuid NOT NULL,
        "Code" character varying(80) NOT NULL,
        "Name" character varying(150) NOT NULL,
        "IsActive" boolean NOT NULL,
        "DesignationId" uuid NOT NULL,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone,
        CONSTRAINT "PK_mst_roles" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_mst_roles_mst_designations_DesignationId" FOREIGN KEY ("DesignationId") REFERENCES mst_designations ("Id") ON DELETE RESTRICT
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820122343_AddEmployeeCatalogs') THEN
    CREATE UNIQUE INDEX "IX_mst_designations_DepartmentId_Name" ON mst_designations ("DepartmentId", "Name");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820122343_AddEmployeeCatalogs') THEN
    CREATE INDEX "IX_employees_JobRoleId" ON employees ("JobRoleId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820122343_AddEmployeeCatalogs') THEN
    CREATE INDEX "IX_employees_NationalityId" ON employees ("NationalityId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820122343_AddEmployeeCatalogs') THEN
    CREATE UNIQUE INDEX "IX_mst_nationalities_Code" ON mst_nationalities ("Code");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820122343_AddEmployeeCatalogs') THEN
    CREATE UNIQUE INDEX "IX_mst_nationalities_Name" ON mst_nationalities ("Name");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820122343_AddEmployeeCatalogs') THEN
    CREATE UNIQUE INDEX "IX_mst_roles_Code" ON mst_roles ("Code");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820122343_AddEmployeeCatalogs') THEN
    CREATE UNIQUE INDEX "IX_mst_roles_DesignationId_Name" ON mst_roles ("DesignationId", "Name");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820122343_AddEmployeeCatalogs') THEN
    ALTER TABLE employees ADD CONSTRAINT "FK_employees_mst_nationalities_NationalityId" FOREIGN KEY ("NationalityId") REFERENCES mst_nationalities ("Id") ON DELETE RESTRICT;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820122343_AddEmployeeCatalogs') THEN
    ALTER TABLE employees ADD CONSTRAINT "FK_employees_mst_roles_JobRoleId" FOREIGN KEY ("JobRoleId") REFERENCES mst_roles ("Id") ON DELETE RESTRICT;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820122343_AddEmployeeCatalogs') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260820122343_AddEmployeeCatalogs', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820124931_AddSalaryBands') THEN
    ALTER TABLE employees ADD "ProbationPeriod" character varying(40);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820124931_AddSalaryBands') THEN
    ALTER TABLE employees ADD "SalaryBandId" uuid;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820124931_AddSalaryBands') THEN
    CREATE TABLE mst_salary_bands (
        "Id" uuid NOT NULL,
        "Code" character varying(20) NOT NULL,
        "Name" character varying(20) NOT NULL,
        "IsActive" boolean NOT NULL,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone,
        CONSTRAINT "PK_mst_salary_bands" PRIMARY KEY ("Id")
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820124931_AddSalaryBands') THEN
    CREATE INDEX "IX_employees_SalaryBandId" ON employees ("SalaryBandId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820124931_AddSalaryBands') THEN
    CREATE UNIQUE INDEX "IX_mst_salary_bands_Code" ON mst_salary_bands ("Code");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820124931_AddSalaryBands') THEN
    CREATE UNIQUE INDEX "IX_mst_salary_bands_Name" ON mst_salary_bands ("Name");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820124931_AddSalaryBands') THEN
    ALTER TABLE employees ADD CONSTRAINT "FK_employees_mst_salary_bands_SalaryBandId" FOREIGN KEY ("SalaryBandId") REFERENCES mst_salary_bands ("Id") ON DELETE RESTRICT;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260820124931_AddSalaryBands') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260820124931_AddSalaryBands', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260821085833_AddClientCustomerSince') THEN
    ALTER TABLE clients ADD "CustomerSince" date;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260821085833_AddClientCustomerSince') THEN
    UPDATE clients
    SET "CustomerSince" = (("CreatedAtUtc" AT TIME ZONE 'UTC') AT TIME ZONE 'Asia/Kolkata')::date
    WHERE "CustomerSince" IS NULL;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260821085833_AddClientCustomerSince') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260821085833_AddClientCustomerSince', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260821120228_AddSubVentureNotes') THEN
    ALTER TABLE sub_ventures ADD "Notes" character varying(2000);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260821120228_AddSubVentureNotes') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260821120228_AddSubVentureNotes', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260822003800_AddMstEmailDomains') THEN
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
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260822003800_AddMstEmailDomains') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260822003800_AddMstEmailDomains', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260826185721_AddEmployeeAadhaarAndUniqueIdentity') THEN
    ALTER TABLE employees ADD COLUMN IF NOT EXISTS "Aadhaar" character varying(12);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260826185721_AddEmployeeAadhaarAndUniqueIdentity') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260826185721_AddEmployeeAadhaarAndUniqueIdentity', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260828104500_AddClientSalesManager') THEN
    ALTER TABLE clients ADD COLUMN IF NOT EXISTS "SalesManager" character varying(120);
    ALTER TABLE clients ADD COLUMN IF NOT EXISTS "SalesManagerId" uuid;
    CREATE INDEX IF NOT EXISTS "IX_clients_SalesManagerId" ON clients ("SalesManagerId");
    DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM pg_constraint WHERE conname = 'FK_clients_employees_SalesManagerId'
        ) THEN
            ALTER TABLE clients
                ADD CONSTRAINT "FK_clients_employees_SalesManagerId"
                FOREIGN KEY ("SalesManagerId") REFERENCES employees("Id") ON DELETE SET NULL;
        END IF;
    END $$;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260828104500_AddClientSalesManager') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260828104500_AddClientSalesManager', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260831133000_AddCountryPhoneFields') THEN
    ALTER TABLE mst_countries
        ADD COLUMN IF NOT EXISTS "PhoneCode" character varying(8) NOT NULL DEFAULT '+91';
    ALTER TABLE mst_countries
        ADD COLUMN IF NOT EXISTS "PhoneDigits" integer NOT NULL DEFAULT 10;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260831133000_AddCountryPhoneFields') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260831133000_AddCountryPhoneFields', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260831150000_AddResourceCatalogTables') THEN
    CREATE TABLE IF NOT EXISTS mst_business_units (
        "Id" uuid NOT NULL,
        "Code" character varying(80) NOT NULL,
        "Name" character varying(150) NOT NULL,
        "IsActive" boolean NOT NULL DEFAULT true,
        "SortOrder" integer NOT NULL DEFAULT 0,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone
    );
    CREATE TABLE IF NOT EXISTS mst_work_locations (
        "Id" uuid NOT NULL,
        "Code" character varying(80) NOT NULL,
        "Name" character varying(150) NOT NULL,
        "IsActive" boolean NOT NULL DEFAULT true,
        "SortOrder" integer NOT NULL DEFAULT 0,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone
    );
    CREATE TABLE IF NOT EXISTS mst_offices (
        "Id" uuid NOT NULL,
        "Code" character varying(80) NOT NULL,
        "Name" character varying(150) NOT NULL,
        "WorkLocationId" uuid,
        "IsActive" boolean NOT NULL DEFAULT true,
        "SortOrder" integer NOT NULL DEFAULT 0,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone
    );
    CREATE TABLE IF NOT EXISTS mst_reporting_managers (
        "Id" uuid NOT NULL,
        "Code" character varying(80) NOT NULL,
        "Name" character varying(150) NOT NULL,
        "Designation" character varying(150),
        "Email" character varying(255),
        "EmployeeId" uuid,
        "IsActive" boolean NOT NULL DEFAULT true,
        "SortOrder" integer NOT NULL DEFAULT 0,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone
    );
    CREATE TABLE IF NOT EXISTS repository (
        "Id" uuid NOT NULL,
        "FileName" character varying(255) NOT NULL,
        "Category" character varying(50) NOT NULL,
        "Size" bigint NOT NULL,
        "LastUpdated" timestamp with time zone NOT NULL,
        "UploadedBy" character varying(150) NOT NULL,
        "FilePath" character varying(1000) NOT NULL,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone
    );
    CREATE TABLE IF NOT EXISTS repository_activity_logs (
        "Id" uuid NOT NULL,
        "Action" character varying(50) NOT NULL,
        "DocumentId" uuid,
        "FileName" character varying(255) NOT NULL,
        "Category" character varying(50) NOT NULL,
        "PerformedBy" character varying(150) NOT NULL,
        "Details" character varying(1000),
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "DeletedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "UpdatedAtUtc" timestamp with time zone
    );

    DO $$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname IN ('PK_mst_business_units', 'mst_business_units_pkey')) THEN
            ALTER TABLE mst_business_units ADD CONSTRAINT "PK_mst_business_units" PRIMARY KEY ("Id");
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname IN ('PK_mst_work_locations', 'mst_work_locations_pkey')) THEN
            ALTER TABLE mst_work_locations ADD CONSTRAINT "PK_mst_work_locations" PRIMARY KEY ("Id");
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname IN ('PK_mst_offices', 'mst_offices_pkey')) THEN
            ALTER TABLE mst_offices ADD CONSTRAINT "PK_mst_offices" PRIMARY KEY ("Id");
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname IN ('PK_mst_reporting_managers', 'mst_reporting_managers_pkey')) THEN
            ALTER TABLE mst_reporting_managers ADD CONSTRAINT "PK_mst_reporting_managers" PRIMARY KEY ("Id");
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname IN ('PK_repository', 'repository_pkey')) THEN
            ALTER TABLE repository ADD CONSTRAINT "PK_repository" PRIMARY KEY ("Id");
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname IN ('PK_repository_activity_logs', 'repository_activity_logs_pkey')) THEN
            ALTER TABLE repository_activity_logs ADD CONSTRAINT "PK_repository_activity_logs" PRIMARY KEY ("Id");
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname IN ('FK_mst_offices_mst_work_locations_WorkLocationId', 'mst_offices_WorkLocationId_fkey')) THEN
            ALTER TABLE mst_offices
                ADD CONSTRAINT "FK_mst_offices_mst_work_locations_WorkLocationId"
                FOREIGN KEY ("WorkLocationId") REFERENCES mst_work_locations("Id") ON DELETE CASCADE;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'FK_mst_reporting_managers_employees_EmployeeId') THEN
            ALTER TABLE mst_reporting_managers
                ADD CONSTRAINT "FK_mst_reporting_managers_employees_EmployeeId"
                FOREIGN KEY ("EmployeeId") REFERENCES employees("Id") ON DELETE SET NULL;
        END IF;
    END $$;

    CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_business_units_Code" ON mst_business_units ("Code");
    CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_work_locations_Code" ON mst_work_locations ("Code");
    CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_offices_Code" ON mst_offices ("Code");
    CREATE INDEX IF NOT EXISTS "IX_mst_offices_WorkLocationId" ON mst_offices ("WorkLocationId");
    CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_reporting_managers_Code" ON mst_reporting_managers ("Code");
    CREATE INDEX IF NOT EXISTS "IX_mst_reporting_managers_EmployeeId" ON mst_reporting_managers ("EmployeeId");
    CREATE INDEX IF NOT EXISTS "IX_repository_Category" ON repository ("Category");
    CREATE INDEX IF NOT EXISTS "IX_repository_DeletedAtUtc" ON repository ("DeletedAtUtc");
    CREATE INDEX IF NOT EXISTS "IX_repository_activity_logs_CreatedAtUtc" ON repository_activity_logs ("CreatedAtUtc");
    CREATE INDEX IF NOT EXISTS "IX_repository_activity_logs_DeletedAtUtc" ON repository_activity_logs ("DeletedAtUtc");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260831150000_AddResourceCatalogTables') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260831150000_AddResourceCatalogTables', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260902100000_AddClientKycDocumentPath') THEN
    ALTER TABLE clients ADD COLUMN IF NOT EXISTS "KycDocumentPath" character varying(500);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260902100000_AddClientKycDocumentPath') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260902100000_AddClientKycDocumentPath', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260902110000_AddSubVentureKycDocument') THEN
    ALTER TABLE sub_ventures ADD COLUMN IF NOT EXISTS "KycDocumentName" character varying(255);
    ALTER TABLE sub_ventures ADD COLUMN IF NOT EXISTS "KycDocumentPath" character varying(500);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260902110000_AddSubVentureKycDocument') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260902110000_AddSubVentureKycDocument', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260902180000_AddEmployeeCodeFormatCheck') THEN
    ALTER TABLE employees DROP CONSTRAINT IF EXISTS "CK_employees_EmployeeCode_Format";
    ALTER TABLE employees
        ADD CONSTRAINT "CK_employees_EmployeeCode_Format"
        CHECK ("EmployeeCode" ~ '^(TK|TKI)-[0-9]{4}$') NOT VALID;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260902180000_AddEmployeeCodeFormatCheck') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260902180000_AddEmployeeCodeFormatCheck', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260903120000_AddRepositoryDepartments') THEN
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
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260903120000_AddRepositoryDepartments') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260903120000_AddRepositoryDepartments', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260905140000_AddEmployeeEmploymentBondFields') THEN
    CREATE TABLE IF NOT EXISTS mst_employee_statuses (
        "Id" uuid NOT NULL,
        "Code" character varying(80) NOT NULL,
        "Name" character varying(150) NOT NULL,
        "IsActive" boolean NOT NULL DEFAULT true,
        "AllowOnboarding" boolean NOT NULL DEFAULT false,
        "SortOrder" integer NOT NULL DEFAULT 0,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "CreatedBy" uuid,
        "UpdatedBy" uuid,
        "DeletedAtUtc" timestamp with time zone
    );

    CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_employee_statuses_Code"
        ON mst_employee_statuses ("Code")
        WHERE "DeletedAtUtc" IS NULL;

    DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM pg_constraint c
            JOIN pg_class t ON c.conrelid = t.oid
            WHERE t.relname = 'mst_employee_statuses' AND c.contype = 'p'
        ) THEN
            ALTER TABLE mst_employee_statuses ADD PRIMARY KEY ("Id");
        END IF;
    END $$;

    ALTER TABLE employees
        ADD COLUMN IF NOT EXISTS "EmployeeStatusId" uuid,
        ADD COLUMN IF NOT EXISTS "BondDelivered" character varying(10),
        ADD COLUMN IF NOT EXISTS "BondDurationMonths" integer,
        ADD COLUMN IF NOT EXISTS "BondExpiryDate" date;

    DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM pg_constraint WHERE conname = 'FK_employees_mst_employee_statuses_EmployeeStatusId'
        ) THEN
            ALTER TABLE employees
                ADD CONSTRAINT "FK_employees_mst_employee_statuses_EmployeeStatusId"
                FOREIGN KEY ("EmployeeStatusId") REFERENCES mst_employee_statuses ("Id")
                ON DELETE SET NULL;
        END IF;
    END $$;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260905140000_AddEmployeeEmploymentBondFields') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260905140000_AddEmployeeEmploymentBondFields', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260908050000_AddCertificationsAndDegrees') THEN
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
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260908050000_AddCertificationsAndDegrees') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260908050000_AddCertificationsAndDegrees', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260908190000_AddClientBillingMedium') THEN
    ALTER TABLE clients ADD COLUMN IF NOT EXISTS "BillingMedium" character varying(40);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260908190000_AddClientBillingMedium') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260908190000_AddClientBillingMedium', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260908193000_AddClientGroupSpocFields') THEN
    ALTER TABLE clients ADD COLUMN IF NOT EXISTS "GroupSpocName" character varying(150);
    ALTER TABLE clients ADD COLUMN IF NOT EXISTS "GroupSpocContact" character varying(40);
    UPDATE clients
    SET "GroupSpocName" = "ContactName"
    WHERE "GroupSpocName" IS NULL AND "ContactName" IS NOT NULL AND btrim("ContactName") <> '';
    UPDATE clients
    SET "GroupSpocContact" = "ContactPhone"
    WHERE "GroupSpocContact" IS NULL AND "ContactPhone" IS NOT NULL AND btrim("ContactPhone") <> '';
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260908193000_AddClientGroupSpocFields') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260908193000_AddClientGroupSpocFields', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260909120000_AddClientContactCountry') THEN
    ALTER TABLE client_contacts ADD COLUMN IF NOT EXISTS "Country" character varying(120);
    ALTER TABLE client_contacts ADD COLUMN IF NOT EXISTS "PhoneCode" character varying(16);
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260909120000_AddClientContactCountry') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260909120000_AddClientContactCountry', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260909130000_AddContactDesignationMaster') THEN
    CREATE TABLE IF NOT EXISTS mst_contact_designations (
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
        CONSTRAINT "PK_mst_contact_designations" PRIMARY KEY ("Id")
    );
    CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_contact_designations_Code"
        ON mst_contact_designations ("Code");
    CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_contact_designations_Name"
        ON mst_contact_designations ("Name");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260909130000_AddContactDesignationMaster') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260909130000_AddContactDesignationMaster', '10.0.4');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260909140000_AddContactTypeMaster') THEN
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
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260909140000_AddContactTypeMaster') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260909140000_AddContactTypeMaster', '10.0.4');
    END IF;
END $EF$;
COMMIT;


-- =========================================================
-- SECTION 2 â€” RUNTIME SCHEMA ALIGNMENT
-- =========================================================
-- These objects are part of the current entity model but are
-- applied at runtime by DbInitializerHostedService rather than
-- by a migration. They are repeated here so this script alone
-- produces a schema the backend can start against.
-- All statements are idempotent.
-- =========================================================

ALTER TABLE mst_countries ADD COLUMN IF NOT EXISTS "PhoneCode" character varying(8) NOT NULL DEFAULT '+91';
ALTER TABLE mst_countries ADD COLUMN IF NOT EXISTS "PhoneDigits" integer NOT NULL DEFAULT 10;

ALTER TABLE employees
    ADD COLUMN IF NOT EXISTS "GradDegree" text,
    ADD COLUMN IF NOT EXISTS "GradYear" text,
    ADD COLUMN IF NOT EXISTS "PostGradDegree" text,
    ADD COLUMN IF NOT EXISTS "PostGradYear" text,
    ADD COLUMN IF NOT EXISTS "ExpType" text,
    ADD COLUMN IF NOT EXISTS "PriorTotalExp" text,
    ADD COLUMN IF NOT EXISTS "PriorRelevantExp" text,
    -- Employee.EmergencyContactName is mapped and queried by EmployeeService but is
    -- created by no migration and by no startup statement. Without this line a
    -- migration-only database fails on every /api/v1/employees read.
    ADD COLUMN IF NOT EXISTS "EmergencyContactName" text,
    ADD COLUMN IF NOT EXISTS "EmergencyContactRelation" text,
    ADD COLUMN IF NOT EXISTS "PmoDepartment" text,
    ADD COLUMN IF NOT EXISTS "SubDepartment" text,
    ADD COLUMN IF NOT EXISTS "BillableStatus" text,
    ADD COLUMN IF NOT EXISTS "ClientLocation" text,
    ADD COLUMN IF NOT EXISTS "ProjectType" text,
    ADD COLUMN IF NOT EXISTS "ProjectAllocated" text,
    ADD COLUMN IF NOT EXISTS "ClientEngManagerMapping" text;

-- mst_employee_statuses shipped without a primary key in one migration path.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint c
        JOIN pg_class t ON c.conrelid = t.oid
        WHERE t.relname = 'mst_employee_statuses' AND c.contype = 'p'
    ) THEN
        ALTER TABLE mst_employee_statuses ADD PRIMARY KEY ("Id");
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'FK_employees_mst_employee_statuses_EmployeeStatusId'
    ) THEN
        ALTER TABLE employees
            ADD CONSTRAINT "FK_employees_mst_employee_statuses_EmployeeStatusId"
            FOREIGN KEY ("EmployeeStatusId") REFERENCES mst_employee_statuses ("Id")
            ON DELETE SET NULL;
    END IF;
END $$;


-- =========================================================
-- SECTION 3 â€” MASTER / REFERENCE DATA
-- =========================================================
-- Catalog rows the application reads at runtime (departments,
-- designations, on-floor roles, geography, industries, contact
-- masters, employee statuses, RBAC roles and their permissions).
--
-- Every row uses ON CONFLICT DO NOTHING, so rows that already
-- exist locally (by primary key or by unique code/name) are left
-- untouched. Insert order follows foreign-key dependencies.
--
-- Excluded on purpose:
--   mst_reporting_managers â€” FK to employees, rebuilt by DbSeeder
--   mst_entra_roles        â€” legacy table, no longer in the model
-- =========================================================

-- ---------------------------------------------------------------
-- mst_departments  (10 rows)
-- ---------------------------------------------------------------
INSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('6a6bb234-1e03-41e8-a4e7-b0e77c8e442e', 'core', 'Core', true, '2026-09-02 10:24:51.765975+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('f7e882f6-2fa8-45e1-9137-2bc4b70f016a', 'functional_it_administration', 'Functional - IT Administration', true, '2026-09-02 10:24:51.785918+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('bcbd68c8-c3f3-4396-abb0-0b0e13637958', 'functional_accounts', 'Functional - Accounts', true, '2026-09-02 10:24:51.795991+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('310a2f16-15f6-4b82-95f6-ab18b5b429f5', 'functional_hr', 'Functional - HR', true, '2026-09-02 10:24:51.812471+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('13c91c98-00ae-4211-acb8-d06e35953806', 'functional_sales', 'Functional - Sales', true, '2026-09-02 10:24:51.826882+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('8e4e88f1-e294-4554-80cc-92ed6169caeb', 'functional_project_management', 'Functional - Project Management', true, '2026-09-02 10:24:51.843878+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('898c36e9-1cb7-4c56-9148-a3b6893c0149', 'rd_research_and_development', 'R&D (Research & Development)', true, '2026-09-02 10:24:51.86295+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60', 'services_operations', 'Services - Operations', true, '2026-09-02 10:24:51.872711+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('be8e036d-ad13-4c79-89ec-294e490a6816', 'services_consulting', 'Services - Consulting', true, '2026-09-02 10:24:51.907068+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('0aed67b8-c454-439a-a07f-4f46d46d58af', 'services_testing', 'Services - Testing', true, '2026-09-02 10:24:51.926627+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------
-- mst_designations  (88 rows)
-- ---------------------------------------------------------------
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('778f1120-9633-4933-9160-ddaa46668838', 'core_director_and_chief_executive_officer', 'Director and Chief Executive Officer', true, '6a6bb234-1e03-41e8-a4e7-b0e77c8e442e', '2026-09-02 10:24:51.776662+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ffed7aa1-e88f-4281-919f-8d49fbabf5a5', 'core_director_and_chief_operating_officer', 'Director and Chief Operating Officer', true, '6a6bb234-1e03-41e8-a4e7-b0e77c8e442e', '2026-09-02 10:24:51.781954+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('0525d830-ead9-44a0-871f-91b7845fec26', 'core_director_and_chief_technology_officer', 'Director and Chief Technology Officer', true, '6a6bb234-1e03-41e8-a4e7-b0e77c8e442e', '2026-09-02 10:24:51.783926+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('da990f6e-3379-4cc4-89b7-0ead29da472b', 'functional_it_admini_it_admin', 'IT Admin', true, 'f7e882f6-2fa8-45e1-9137-2bc4b70f016a', '2026-09-02 10:24:51.787896+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('c70b9832-841e-4864-9b85-eaba3c0a995f', 'functional_it_admini_desktop_support_engineer_i', 'Desktop Support Engineer - I', true, 'f7e882f6-2fa8-45e1-9137-2bc4b70f016a', '2026-09-02 10:24:51.78998+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('73bd55bb-5d0e-4381-8ad2-2238377fca93', 'functional_it_admini_desktop_support_engineer_ii', 'Desktop Support Engineer - II', true, 'f7e882f6-2fa8-45e1-9137-2bc4b70f016a', '2026-09-02 10:24:51.792134+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('f8502c44-b289-49e4-8401-3dcad4d5bbe0', 'functional_it_admini_intern', 'Intern', true, 'f7e882f6-2fa8-45e1-9137-2bc4b70f016a', '2026-09-02 10:24:51.794108+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('155642eb-a633-4460-b658-aca9fde2d817', 'functional_accounts_accountant_i', 'Accountant - I', true, 'bcbd68c8-c3f3-4396-abb0-0b0e13637958', '2026-09-02 10:24:51.797934+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('8dc0d8fe-593d-422a-8b27-5b68fbe6d224', 'functional_accounts_accountant_ii', 'Accountant - II', true, 'bcbd68c8-c3f3-4396-abb0-0b0e13637958', '2026-09-02 10:24:51.799807+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('6e606c29-2ebf-4ab8-8006-aaedd5680009', 'functional_accounts_accountant_iii', 'Accountant - III', true, 'bcbd68c8-c3f3-4396-abb0-0b0e13637958', '2026-09-02 10:24:51.801711+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('4ef1cb5b-9688-4ce2-95b3-6a0863200166', 'functional_accounts_senior_accountant_i', 'Senior Accountant - I', true, 'bcbd68c8-c3f3-4396-abb0-0b0e13637958', '2026-09-02 10:24:51.803595+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('96efad7d-8b7f-4d7f-a862-c0a6bec3789f', 'functional_accounts_senior_accountant_ii', 'Senior Accountant - II', true, 'bcbd68c8-c3f3-4396-abb0-0b0e13637958', '2026-09-02 10:24:51.805714+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('1f97b442-95c5-4b11-93a0-ea146534ae85', 'functional_accounts_senior_accountant_iii', 'Senior Accountant - III', true, 'bcbd68c8-c3f3-4396-abb0-0b0e13637958', '2026-09-02 10:24:51.807813+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('caa227a1-2dcf-4195-ab9c-8f76d1862daa', 'functional_accounts_intern', 'Intern', true, 'bcbd68c8-c3f3-4396-abb0-0b0e13637958', '2026-09-02 10:24:51.809802+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('8fdfba5d-e947-47b6-aa25-23d9a6dc49ed', 'functional_hr_hr_head', 'HR Head', true, '310a2f16-15f6-4b82-95f6-ab18b5b429f5', '2026-09-02 10:24:51.814553+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('7d542941-65b9-499b-81b3-239748d6da52', 'functional_hr_recruitment_coordinator_i', 'Recruitment Coordinator - I', true, '310a2f16-15f6-4b82-95f6-ab18b5b429f5', '2026-09-02 10:24:51.8165+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('c2e248c8-e917-445f-9f7b-1e25d7bb5abe', 'functional_hr_recruitment_coordinator_ii', 'Recruitment Coordinator - II', true, '310a2f16-15f6-4b82-95f6-ab18b5b429f5', '2026-09-02 10:24:51.818555+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('485012d4-2c28-4bc4-92c7-3609e3e3749e', 'functional_hr_senior_hr_executive_i', 'Senior HR Executive - I', true, '310a2f16-15f6-4b82-95f6-ab18b5b429f5', '2026-09-02 10:24:51.820547+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e4e20503-cd55-4393-83fd-6c7e7d7d0a49', 'functional_hr_senior_hr_executive_ii', 'Senior HR Executive - II', true, '310a2f16-15f6-4b82-95f6-ab18b5b429f5', '2026-09-02 10:24:51.8227+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e8c22eff-0daf-4690-a537-c8b0b6110a01', 'functional_hr_intern', 'Intern', true, '310a2f16-15f6-4b82-95f6-ab18b5b429f5', '2026-09-02 10:24:51.824863+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('b2b687ef-fd62-4cb7-a826-b40a35da7b2c', 'functional_sales_business_development_associate_i', 'Business Development Associate - I', true, '13c91c98-00ae-4211-acb8-d06e35953806', '2026-09-02 10:24:51.828797+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('157d001c-b056-45b1-96a3-3c05bcd8d99c', 'functional_sales_customer_success_representative_ii', 'Customer Success Representative - II', true, '13c91c98-00ae-4211-acb8-d06e35953806', '2026-09-02 10:24:51.830775+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('6193be76-40ad-4973-9ee7-246a4d8f4109', 'functional_sales_director_product_sales', 'Director - Product Sales', true, '13c91c98-00ae-4211-acb8-d06e35953806', '2026-09-02 10:24:51.832885+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e2c675a7-92dc-4477-be75-9a304cbe4def', 'functional_sales_sales_associate', 'Sales Associate', true, '13c91c98-00ae-4211-acb8-d06e35953806', '2026-09-02 10:24:51.83517+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('272973a6-c052-4aef-bf32-9e24f7eb6cc9', 'functional_sales_associate_customer_success_representative_i', 'Associate Customer Success Representative - I', true, '13c91c98-00ae-4211-acb8-d06e35953806', '2026-09-02 10:24:51.837646+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('7e7d954f-34b5-4c23-8c3f-698ec920e9e4', 'functional_sales_associate_customer_success_representative_ii', 'Associate Customer Success Representative - II', true, '13c91c98-00ae-4211-acb8-d06e35953806', '2026-09-02 10:24:51.839641+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e2b10def-c91d-45da-94c5-f5530e743aa2', 'functional_sales_intern', 'Intern', true, '13c91c98-00ae-4211-acb8-d06e35953806', '2026-09-02 10:24:51.841726+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('b3309eea-7374-4a8d-ac13-481b2a7fd492', 'functional_project_m_associate_pmo_i', 'Associate PMO - I', true, '8e4e88f1-e294-4554-80cc-92ed6169caeb', '2026-09-02 10:24:51.845704+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('2a76927c-461a-48e4-8190-dea7361ef3db', 'functional_project_m_associate_pmo_ii', 'Associate PMO - II', true, '8e4e88f1-e294-4554-80cc-92ed6169caeb', '2026-09-02 10:24:51.847585+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('c864b6d5-86c7-40c5-b3c4-27f7b42ebc0c', 'functional_project_m_senior_pmo_i', 'Senior PMO - I', true, '8e4e88f1-e294-4554-80cc-92ed6169caeb', '2026-09-02 10:24:51.849476+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('138434a2-625f-4df5-836d-fcf0cfceef79', 'functional_project_m_senior_pmo_ii', 'Senior PMO - II', true, '8e4e88f1-e294-4554-80cc-92ed6169caeb', '2026-09-02 10:24:51.851761+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('834c9e15-c70d-4a0b-bb12-5e55f23c181d', 'functional_project_m_delivery_account_manager_i', 'Delivery Account Manager - I', true, '8e4e88f1-e294-4554-80cc-92ed6169caeb', '2026-09-02 10:24:51.853646+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('d8a2b9e5-f54d-4344-a78d-c6c840467543', 'functional_project_m_delivery_account_manager_ii', 'Delivery Account Manager - II', true, '8e4e88f1-e294-4554-80cc-92ed6169caeb', '2026-09-02 10:24:51.855524+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('8b57cfd5-5d4e-44a3-9646-b36873c111c2', 'functional_project_m_senior_delivery_account_manager_i', 'Senior Delivery Account Manager - I', true, '8e4e88f1-e294-4554-80cc-92ed6169caeb', '2026-09-02 10:24:51.857373+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('9dc69952-eae6-4ec0-a327-67392315f089', 'functional_project_m_senior_delivery_account_manager_ii', 'Senior Delivery Account Manager - II', true, '8e4e88f1-e294-4554-80cc-92ed6169caeb', '2026-09-02 10:24:51.859188+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('9050e021-7d84-4401-820e-c0e768abb1ab', 'functional_project_m_intern', 'Intern', true, '8e4e88f1-e294-4554-80cc-92ed6169caeb', '2026-09-02 10:24:51.861092+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('f9a11aaf-470a-4eb6-b2b5-3ca3f730ca29', 'rd_research_and_deve_python_developer_i', 'Python Developer - I', true, '898c36e9-1cb7-4c56-9148-a3b6893c0149', '2026-09-02 10:24:51.864858+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('3356f353-1566-4df6-9958-fa01d67d13c7', 'rd_research_and_deve_python_developer_ii', 'Python Developer - II', true, '898c36e9-1cb7-4c56-9148-a3b6893c0149', '2026-09-02 10:24:51.866732+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('9ba2a2f7-e946-4e55-ad1c-135c6fd77e85', 'rd_research_and_deve_python_developer_iii', 'Python Developer - III', true, '898c36e9-1cb7-4c56-9148-a3b6893c0149', '2026-09-02 10:24:51.868943+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('bb7ccd5f-2f60-49fb-b984-f11fc47add22', 'rd_research_and_deve_intern', 'Intern', true, '898c36e9-1cb7-4c56-9148-a3b6893c0149', '2026-09-02 10:24:51.870785+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('6d25ff6d-e13d-440f-b775-215547af7acb', 'services_operations_soc_analyst_i', 'SOC Analyst - I', true, '3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60', '2026-09-02 10:24:51.874793+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('48429bb5-c583-4684-b30a-7ed443b671ca', 'services_operations_soc_analyst_ii', 'SOC Analyst - II', true, '3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60', '2026-09-02 10:24:51.876768+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('f20a7445-0b01-4f20-85a5-853101d864ee', 'services_operations_soc_analyst_iii', 'SOC Analyst - III', true, '3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60', '2026-09-02 10:24:51.878659+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('0c1a5ef4-7fca-45dc-8253-87afa21a1df9', 'services_operations_soc_analyst_iv', 'SOC Analyst - IV', true, '3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60', '2026-09-02 10:24:51.880491+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ea315f7d-d597-41b3-a999-4f3851bcd020', 'services_operations_siem_admin_i', 'SIEM Admin - I', true, '3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60', '2026-09-02 10:24:51.88251+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('4650d4e0-f73c-4688-ae5f-830a46348ff9', 'services_operations_siem_admin_ii', 'SIEM Admin - II', true, '3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60', '2026-09-02 10:24:51.884354+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('af8a1442-c5ee-409d-aa91-61c9dba852ee', 'services_operations_siem_admin_iii', 'SIEM Admin - III', true, '3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60', '2026-09-02 10:24:51.886248+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e36018c5-bf48-4f93-bef7-93e8864a0b51', 'services_operations_siem_admin_iv', 'SIEM Admin - IV', true, '3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60', '2026-09-02 10:24:51.888229+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('73b4d4e6-d6d3-4f2c-bf85-a9f71def8b09', 'services_operations_soc_consultant_i', 'SOC Consultant - I', true, '3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60', '2026-09-02 10:24:51.890218+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('911f6d7f-8d43-40f2-897a-2f416abf8cf9', 'services_operations_soc_consultant_ii', 'SOC Consultant - II', true, '3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60', '2026-09-02 10:24:51.892032+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('444df30d-c195-42ad-b9a7-d80cdef69ccd', 'services_operations_soc_shift_lead_i', 'SOC Shift Lead - I', true, '3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60', '2026-09-02 10:24:51.894767+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('c0f974c3-f49c-449a-9276-aa64ce501344', 'services_operations_soc_shift_lead_ii', 'SOC Shift Lead - II', true, '3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60', '2026-09-02 10:24:51.896662+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('b5f39dd8-c305-489d-9f7d-9adfd010a134', 'services_operations_soc_lead_i', 'SOC Lead - I', true, '3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60', '2026-09-02 10:24:51.899202+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('eb1f4dba-0d12-42c1-9e97-317c2ae55f6f', 'services_operations_soc_lead_ii', 'SOC Lead - II', true, '3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60', '2026-09-02 10:24:51.901107+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('0b8dfaba-3f3f-4f5f-8812-46144a90aeaf', 'services_operations_intern', 'Intern', true, '3b4eaac4-3d54-4f3a-8fc5-c7385cd0ba60', '2026-09-02 10:24:51.904989+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('1e7faab8-273d-40df-9f9a-485160186c5a', 'services_consulting_grc_auditor_i', 'GRC Auditor - I', true, 'be8e036d-ad13-4c79-89ec-294e490a6816', '2026-09-02 10:24:51.908929+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('2c66e6fc-c92b-4b43-bf13-0ad2bb5c058b', 'services_consulting_grc_auditor_ii', 'GRC Auditor - II', true, 'be8e036d-ad13-4c79-89ec-294e490a6816', '2026-09-02 10:24:51.910823+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('8a655ba7-f9db-4de7-8de9-9fec72a2ed1d', 'services_consulting_grc_auditor_iii', 'GRC Auditor - III', true, 'be8e036d-ad13-4c79-89ec-294e490a6816', '2026-09-02 10:24:51.912801+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('7c2380da-3ee6-46ad-93d6-a79ce3027f29', 'services_consulting_grc_auditor_iv', 'GRC Auditor - IV', true, 'be8e036d-ad13-4c79-89ec-294e490a6816', '2026-09-02 10:24:51.915028+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('dcabe0b2-ab10-4c1a-abf7-873e8b5486ca', 'services_consulting_senior_grc_auditor_i', 'Senior GRC Auditor - I', true, 'be8e036d-ad13-4c79-89ec-294e490a6816', '2026-09-02 10:24:51.916903+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('3e60b693-d3dd-4481-95c4-9f02da21625c', 'services_consulting_senior_grc_auditor_ii', 'Senior GRC Auditor - II', true, 'be8e036d-ad13-4c79-89ec-294e490a6816', '2026-09-02 10:24:51.91882+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('195d6a81-8457-4b60-9382-6a3a0664f0e9', 'services_consulting_associate_manager_iii', 'Associate Manager - III', true, 'be8e036d-ad13-4c79-89ec-294e490a6816', '2026-09-02 10:24:51.920769+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('2b1558e3-158a-4a84-ae80-053129861a64', 'services_consulting_senior_vice_president_principal_consultant', 'Senior Vice President - Principal Consultant', true, 'be8e036d-ad13-4c79-89ec-294e490a6816', '2026-09-02 10:24:51.922717+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('2076a9b1-e432-46a9-99b1-36e732159856', 'services_consulting_intern', 'Intern', true, 'be8e036d-ad13-4c79-89ec-294e490a6816', '2026-09-02 10:24:51.924658+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('4f972924-350a-47fb-a6b6-f2b34bb6b621', 'services_testing_pentester_i', 'PenTester - I', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:51.928383+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('0b6ab354-1fcf-4a00-9be3-e58e99c425ed', 'services_testing_pentester_ii', 'PenTester - II', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:51.930296+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('163d8c87-8f90-4295-a926-2e912c625a1c', 'services_testing_pentester_iii', 'PenTester - III', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:51.932399+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('9858c224-f97f-4ff8-908d-f46bd5e2243c', 'services_testing_pentester_iv', 'PenTester - IV', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:51.93473+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('632bf06c-f646-4edd-bf2d-e3cd2e034c7f', 'services_testing_senior_pentester_i', 'Senior Pentester - I', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:51.936785+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85', 'services_testing_senior_pentester_ii', 'Senior Pentester - II', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:51.93907+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e228c999-bf54-48b4-a373-d2bc9db88554', 'services_testing_associate_manager_i', 'Associate Manager - I', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:51.953968+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('168d11d7-ca26-4d61-b870-51779dc63023', 'services_testing_associate_manager_ii', 'Associate Manager - II', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:51.955906+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('aaf4ca75-5fa5-4de2-8353-a5e93beecb56', 'services_testing_associate_manager_iii', 'Associate Manager - III', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:51.957817+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('3b7ea453-324e-40a0-bb41-77a0795d5af5', 'services_testing_associate_project_manager', 'Associate Project Manager', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:51.961716+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('a697a798-caaf-4248-8e4e-7e89096a9c30', 'services_testing_manager_i', 'Manager - I', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:51.966138+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ae255622-ddcc-45ea-a699-8ec416fe57ab', 'services_testing_devsecops_practitioner_i', 'DevSecOps Practitioner - I', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:51.969279+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('35a6b1af-dc78-4632-a9f4-eedabdbdcb52', 'services_testing_devsecops_practitioner_ii', 'DevSecOps Practitioner - II', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:51.97275+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('767a00dd-6f09-4f64-a44e-8fbe901222af', 'services_testing_devsecops_practitioner_iii', 'DevSecOps Practitioner - III', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:51.976579+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('c6c6cd04-6df3-4593-b686-e4b9d362c96f', 'services_testing_devsecops_associate', 'DevSecOps Associate', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:51.980181+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('c1fa4328-a970-48a1-bc08-d50fe36bf44c', 'services_testing_devsecops_specialist_ii', 'DevSecOps Specialist - II', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:51.983425+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('0a60fb48-99c4-44d0-8d97-ff687ccffc9f', 'services_testing_red_team_practitioner_ii', 'Red Team Practitioner - II', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:51.986648+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('85cc9fbe-98a4-464d-a638-05f40529c6de', 'services_testing_red_team_practitioner_iii', 'Red Team Practitioner - III', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:51.991312+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('4b680e29-b4fb-4689-9afb-67a7f089f52b', 'services_testing_red_team_specialist_ii', 'Red Team Specialist - II', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:51.994166+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('8af28894-fd3e-4dea-a4f0-bcb62b0e4e13', 'services_testing_senior_cloud_security_consultant_i', 'Senior Cloud Security Consultant - I', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:51.997244+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e2b4be77-2b20-4064-974d-e6322e7240b4', 'services_testing_associate_ai_engineer_contractual', 'Associate AI Engineer - Contractual', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:52.001242+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('47dbf38f-c022-47bc-8444-d0dfb35ff3fd', 'services_testing_intern', 'Intern', true, '0aed67b8-c454-439a-a07f-4f46d46d58af', '2026-09-02 10:24:52.004312+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('dadac355-1ddc-457c-935a-d297da3a883d', 'services_consulting_principal_manager_i', 'Principal Manager - I', true, 'be8e036d-ad13-4c79-89ec-294e490a6816', '2026-09-02 10:24:51.903029+00', '2026-09-03 07:11:32.975424+00', NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('fdd34566-051a-487d-a985-540c2db8c37f', 'functional_project_management_engagement_manager', 'Engagement Manager', true, '8e4e88f1-e294-4554-80cc-92ed6169caeb', '2026-09-02 11:51:34.862009+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------
-- mst_roles  (89 rows)
-- ---------------------------------------------------------------
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('6032fef5-eb05-42bd-9f10-72f12e154243', 'services_operations_soc_shift_lead_i_team_leader_tl_', 'Team Leader (TL)', true, '444df30d-c195-42ad-b9a7-d80cdef69ccd', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('8366d816-724b-456b-9d0e-85399c2324b7', 'services_operations_soc_lead_i_team_leader_tl_', 'Team Leader (TL)', true, 'b5f39dd8-c305-489d-9f7d-9adfd010a134', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('412826f2-67b6-47c9-a62c-270fa9425ce4', 'functional_sales_director_product_sales_team_member_tm_', 'Team Member (TM)', true, '6193be76-40ad-4973-9ee7-246a4d8f4109', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('d0b9d2a2-d79c-4097-ae63-4bff14436d0a', 'functional_sales_sales_associate_team_member_tm_', 'Team Member (TM)', true, 'e2c675a7-92dc-4477-be75-9a304cbe4def', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('1c1c9112-592b-4f23-92d5-213a5da0d78d', 'functional_it_admini_desktop_support_engineer_i_team_member_tm_', 'Team Member (TM)', true, 'c70b9832-841e-4864-9b85-eaba3c0a995f', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('16f2557a-02c9-4208-a570-55a909532abe', 'functional_accounts_senior_accountant_ii_manager_mng_', 'Manager (Mng.)', true, '96efad7d-8b7f-4d7f-a862-c0a6bec3789f', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('3efb18e5-f8d5-4de9-8959-ab5401f64b74', 'services_consulting_grc_auditor_iv_team_member_tm_', 'Team Member (TM)', true, '7c2380da-3ee6-46ad-93d6-a79ce3027f29', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('40354601-9ac5-41e0-9ddb-6603e5614a86', 'services_consulting_grc_auditor_iii_team_member_tm_', 'Team Member (TM)', true, '8a655ba7-f9db-4de7-8de9-9fec72a2ed1d', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('6886e92b-a2c5-4057-9330-47394a2aac65', 'services_consulting_grc_auditor_ii_team_member_tm_', 'Team Member (TM)', true, '2c66e6fc-c92b-4b43-bf13-0ad2bb5c058b', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('cc4e4c23-fccc-44ba-8423-5e4e6ec35731', 'functional_hr_recruitment_coordinator_ii_hr', 'HR', true, 'c2e248c8-e917-445f-9f7b-1e25d7bb5abe', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('21eac166-3ba7-40c5-a780-bbc7b3e96ddb', 'functional_sales_associate_customer_success_representative_ii_team_member_tm_', 'Team Member (TM)', true, '7e7d954f-34b5-4c23-8c3f-698ec920e9e4', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('db77e167-7f67-43f6-9e2d-4ebaf6f9f802', 'functional_project_m_delivery_account_manager_ii_team_member_tm_', 'Team Member (TM)', true, 'd8a2b9e5-f54d-4344-a78d-c6c840467543', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('6c0bebbb-cc4d-4433-83e9-d65fb5291d75', 'services_consulting_intern_team_member_tm_', 'Team Member (TM)', true, '2076a9b1-e432-46a9-99b1-36e732159856', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('913e691d-e3f9-4f9a-aab8-57eda52a8cd6', 'functional_it_admini_desktop_support_engineer_ii_team_member_tm_', 'Team Member (TM)', true, '73bd55bb-5d0e-4381-8ad2-2238377fca93', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('1e17c9f0-a8ed-4d89-819d-738a84af4e48', 'functional_hr_senior_hr_executive_ii_hr', 'HR', true, 'e4e20503-cd55-4393-83fd-6c7e7d7d0a49', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ea40e2b6-035a-4766-96bc-13ad013020c1', 'services_operations_soc_analyst_iv_team_member_tm_', 'Team Member (TM)', true, '0c1a5ef4-7fca-45dc-8253-87afa21a1df9', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('401a442f-98c4-4b95-9e07-647853bf9122', 'rd_research_and_deve_python_developer_ii_team_member_tm_', 'Team Member (TM)', true, '3356f353-1566-4df6-9958-fa01d67d13c7', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('52ae8b5b-80b3-4d14-b8c5-0bc40e1f4bee', 'services_consulting_associate_manager_iii_manager_mng_', 'Manager (Mng.)', true, '195d6a81-8457-4b60-9382-6a3a0664f0e9', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('31ebb23e-f7d1-4c01-859b-67d24e96e2fb', 'services_operations_soc_lead_ii_team_leader_tl_', 'Team Leader (TL)', true, 'eb1f4dba-0d12-42c1-9e97-317c2ae55f6f', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('24ccdefb-8dd5-411e-8b2e-af8fb743a3cb', 'services_operations_soc_consultant_i_team_member_tm_', 'Team Member (TM)', true, '73b4d4e6-d6d3-4f2c-bf85-a9f71def8b09', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('8ea442c3-8ed7-4b6a-a3db-dd74706e9cce', 'services_testing_devsecops_practitioner_ii_team_member_tm_', 'Team Member (TM)', true, '35a6b1af-dc78-4632-a9f4-eedabdbdcb52', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('218cd458-a6bc-43f8-8eda-02c89193fc35', 'services_operations_soc_shift_lead_ii_team_leader_tl_', 'Team Leader (TL)', true, 'c0f974c3-f49c-449a-9276-aa64ce501344', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('6c1b3c1d-4159-41b9-9171-1e4f2501cc32', 'functional_project_m_intern_team_member_tm_', 'Team Member (TM)', true, '9050e021-7d84-4401-820e-c0e768abb1ab', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('da46be38-b216-44cc-8b6d-70cd4b0aea8e', 'services_operations_siem_admin_iv_team_member_tm_', 'Team Member (TM)', true, 'e36018c5-bf48-4f93-bef7-93e8864a0b51', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('33f2483b-b264-4ec4-857a-205426a8af0f', 'functional_accounts_accountant_i_manager_mng_', 'Manager (Mng.)', true, '155642eb-a633-4460-b658-aca9fde2d817', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('48079f83-fbf9-4639-ae6b-263ca3fb752a', 'functional_project_m_associate_pmo_i_team_member_tm_', 'Team Member (TM)', true, 'b3309eea-7374-4a8d-ac13-481b2a7fd492', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('da59e567-3ee0-4a98-9b1e-83f8e6c01e2c', 'services_testing_associate_manager_i_team_leader_tl_', 'Team Leader (TL)', true, 'e228c999-bf54-48b4-a373-d2bc9db88554', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('1d19d6af-78b4-45ef-bcb3-db1b3896f153', 'services_operations_intern_team_member_tm_', 'Team Member (TM)', true, '0b8dfaba-3f3f-4f5f-8812-46144a90aeaf', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('446498d0-e9e6-4dbb-8fbe-b87bb853a2af', 'functional_project_m_senior_pmo_i_team_leader_tl_', 'Team Leader (TL)', true, 'c864b6d5-86c7-40c5-b3c4-27f7b42ebc0c', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('6b361aa9-a47a-4fed-9d1f-07a4e1dd5f30', 'functional_hr_recruitment_coordinator_i_hr', 'HR', true, '7d542941-65b9-499b-81b3-239748d6da52', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('c7d75b92-f6e2-4dd7-a726-ae662ee83c95', 'functional_hr_hr_head_hr', 'HR', true, '8fdfba5d-e947-47b6-aa25-23d9a6dc49ed', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('5378a1ad-7ab3-40e5-9048-5165efab2140', 'services_testing_senior_pentester_ii_team_member_tm_', 'Team Member (TM)', true, 'e8d42654-b7f5-4a4e-a8e0-a07dd8fd3c85', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('a3d0a1e1-b4a8-4ae5-8577-cd2019268494', 'services_testing_associate_manager_iii_manager_mng_', 'Manager (Mng.)', true, 'aaf4ca75-5fa5-4de2-8353-a5e93beecb56', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('22215465-c056-4ba4-a867-23ed37658a09', 'services_consulting_senior_grc_auditor_i_team_leader_tl_', 'Team Leader (TL)', true, 'dcabe0b2-ab10-4c1a-abf7-873e8b5486ca', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('9c970783-5b89-4fd0-b3f3-1c1953a853ab', 'services_operations_soc_analyst_ii_team_member_tm_', 'Team Member (TM)', true, '48429bb5-c583-4684-b30a-7ed443b671ca', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('4e547334-4964-4dbe-81a4-a316d9394d03', 'services_testing_devsecops_practitioner_i_team_member_tm_', 'Team Member (TM)', true, 'ae255622-ddcc-45ea-a699-8ec416fe57ab', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('57b9b89d-9123-4bd0-b8fd-a373e0648f43', 'functional_project_m_senior_delivery_account_manager_i_team_leader_tl_', 'Team Leader (TL)', true, '8b57cfd5-5d4e-44a3-9646-b36873c111c2', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('8ab74d70-fc77-4767-87ce-13a6d3f911ce', 'services_testing_senior_cloud_security_consultant_i_manager_mng_', 'Manager (Mng.)', true, '8af28894-fd3e-4dea-a4f0-bcb62b0e4e13', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('859254f8-a1b4-4812-b1d0-aacf111f7235', 'rd_research_and_deve_intern_team_member_tm_', 'Team Member (TM)', true, 'bb7ccd5f-2f60-49fb-b984-f11fc47add22', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('70206c08-0203-4784-8b09-d04d0cff95af', 'services_testing_devsecops_practitioner_iii_team_member_tm_', 'Team Member (TM)', true, '767a00dd-6f09-4f64-a44e-8fbe901222af', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('f37fa8d5-1c48-4038-95d5-cd7dfea12085', 'functional_accounts_senior_accountant_i_manager_mng_', 'Manager (Mng.)', true, '4ef1cb5b-9688-4ce2-95b3-6a0863200166', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('3f413c39-a269-4d44-9f3c-9e7f6e3ecced', 'services_operations_soc_analyst_iii_team_member_tm_', 'Team Member (TM)', true, 'f20a7445-0b01-4f20-85a5-853101d864ee', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('178985be-3d47-4903-983b-3a581e788e61', 'services_operations_siem_admin_iii_team_member_tm_', 'Team Member (TM)', true, 'af8a1442-c5ee-409d-aa91-61c9dba852ee', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('c45f4397-0370-43f5-98c7-f419234fa6d8', 'services_testing_red_team_practitioner_iii_team_member_tm_', 'Team Member (TM)', true, '85cc9fbe-98a4-464d-a638-05f40529c6de', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ebdc343e-9f43-4715-8a37-4861594c4b0a', 'functional_hr_senior_hr_executive_i_hr', 'HR', true, '485012d4-2c28-4bc4-92c7-3609e3e3749e', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('98e28e22-95e4-41ee-9178-2912de24f21a', 'functional_accounts_intern_team_member_tm_', 'Team Member (TM)', true, 'caa227a1-2dcf-4195-ab9c-8f76d1862daa', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('568997bf-75a1-46d9-9bdb-6fc05c3b2be1', 'services_testing_pentester_iii_team_member_tm_', 'Team Member (TM)', true, '163d8c87-8f90-4295-a926-2e912c625a1c', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('20d077b9-894b-4bf3-b491-5df765e645f0', 'services_testing_associate_manager_ii_team_leader_tl_', 'Team Leader (TL)', true, '168d11d7-ca26-4d61-b870-51779dc63023', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('5a206a6a-dabc-4dfe-b28f-00cc01bc11da', 'services_testing_red_team_practitioner_ii_team_member_tm_', 'Team Member (TM)', true, '0a60fb48-99c4-44d0-8d97-ff687ccffc9f', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('074ea1a8-d519-4cda-87a4-978cd1eec45a', 'services_consulting_grc_auditor_i_team_member_tm_', 'Team Member (TM)', true, '1e7faab8-273d-40df-9f9a-485160186c5a', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('61cc6cff-4f61-4a1d-90f5-9eb9f61c54f3', 'services_consulting_principal_manager_i_sr_manager_sr_mng_', 'Sr. Manager (Sr.Mng.)', true, 'dadac355-1ddc-457c-935a-d297da3a883d', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('95337b72-6733-48f5-ba8c-cd2afbcbc1e4', 'functional_accounts_accountant_ii_manager_mng_', 'Manager (Mng.)', true, '8dc0d8fe-593d-422a-8b27-5b68fbe6d224', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('3e28d4a4-7d87-41ed-b921-a39dd937df76', 'functional_sales_associate_customer_success_representative_i_team_member_tm_', 'Team Member (TM)', true, '272973a6-c052-4aef-bf32-9e24f7eb6cc9', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('b4e88d70-1263-47af-96a9-203ee422e8b1', 'services_operations_soc_consultant_ii_team_member_tm_', 'Team Member (TM)', true, '911f6d7f-8d43-40f2-897a-2f416abf8cf9', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('9fb9b5b5-bc14-4597-8953-7a1ea10dc0dd', 'functional_project_m_delivery_account_manager_i_team_member_tm_', 'Team Member (TM)', true, '834c9e15-c70d-4a0b-bb12-5e55f23c181d', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('111000c1-ff0c-499c-a9cb-34febe2ac32d', 'services_testing_devsecops_associate_team_leader_tl_', 'Team Leader (TL)', true, 'c6c6cd04-6df3-4593-b686-e4b9d362c96f', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ee402c9b-252b-4eec-8880-7a4a159eac92', 'rd_research_and_deve_python_developer_iii_team_member_tm_', 'Team Member (TM)', true, '9ba2a2f7-e946-4e55-ad1c-135c6fd77e85', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('f43fddea-4dd9-4603-a79c-1710224115ae', 'functional_it_admini_intern_team_member_tm_', 'Team Member (TM)', true, 'f8502c44-b289-49e4-8401-3dcad4d5bbe0', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('94fc014e-37ce-4eb4-8588-ff56a79be98e', 'core_director_and_chief_executive_officer_leader_l_', 'Leader (L)', true, '778f1120-9633-4933-9160-ddaa46668838', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('3000065e-1037-4a6b-a87a-4c461a756531', 'services_operations_siem_admin_i_team_member_tm_', 'Team Member (TM)', true, 'ea315f7d-d597-41b3-a999-4f3851bcd020', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('1cf32162-d510-4a26-a017-e2035425dc93', 'functional_project_m_senior_pmo_ii_manager_mng_', 'Manager (Mng.)', true, '138434a2-625f-4df5-836d-fcf0cfceef79', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('6b840581-65b6-4e1d-916f-38b6018e07e0', 'services_consulting_senior_vice_president_principal_consultant_head_of_departmen', 'Head Of Department (HOD)', true, '2b1558e3-158a-4a84-ae80-053129861a64', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('0b340900-7bd0-4931-8978-832c678c7cbd', 'functional_sales_intern_team_member_tm_', 'Team Member (TM)', true, 'e2b10def-c91d-45da-94c5-f5530e743aa2', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('4e574ffd-c3a9-4a15-832a-5dabfb352dc3', 'services_consulting_senior_grc_auditor_ii_team_leader_tl_', 'Team Leader (TL)', true, '3e60b693-d3dd-4481-95c4-9f02da21625c', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('8ec384d1-5b99-45c9-a95d-8f3325f56ea4', 'services_testing_associate_manager_iii_team_leader_tl_', 'Team Leader (TL)', true, 'aaf4ca75-5fa5-4de2-8353-a5e93beecb56', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('a3986a0e-d20f-4f20-a648-adcc724bb622', 'services_testing_manager_i_sr_manager_sr_mng_', 'Sr. Manager (Sr.Mng.)', true, 'a697a798-caaf-4248-8e4e-7e89096a9c30', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('86a621fc-db0d-4e12-96c5-2af111964ef5', 'services_consulting_associate_manager_iii_team_leader_tl_', 'Team Leader (TL)', true, '195d6a81-8457-4b60-9382-6a3a0664f0e9', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('fdf924c8-3a4a-40bb-9bf9-ea42d4946ecb', 'rd_research_and_deve_python_developer_i_team_member_tm_', 'Team Member (TM)', true, 'f9a11aaf-470a-4eb6-b2b5-3ca3f730ca29', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('fc382efa-48c8-4cc3-a724-2e54c1d6d6e0', 'services_testing_associate_ai_engineer_contractual_team_member_tm_', 'Team Member (TM)', true, 'e2b4be77-2b20-4064-974d-e6322e7240b4', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('9225698b-9ecd-4dfb-9008-fe08b395efc9', 'functional_accounts_senior_accountant_iii_manager_mng_', 'Manager (Mng.)', true, '1f97b442-95c5-4b11-93a0-ea146534ae85', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('a583ec5f-f30a-4b03-9e35-6afc3f1aee8d', 'services_testing_devsecops_specialist_ii_manager_mng_', 'Manager (Mng.)', true, 'c1fa4328-a970-48a1-bc08-d50fe36bf44c', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('3dd672a7-e6a9-42c8-bdbf-4d1340efc1da', 'core_director_and_chief_operating_officer_leader_l_', 'Leader (L)', true, 'ffed7aa1-e88f-4281-919f-8d49fbabf5a5', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('736d1ddd-c56a-4c4f-b266-bc4f6be6ed9c', 'services_testing_senior_pentester_i_team_member_tm_', 'Team Member (TM)', true, '632bf06c-f646-4edd-bf2d-e3cd2e034c7f', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('b3a66833-fc6b-4bac-9438-959333107d3c', 'functional_project_m_senior_delivery_account_manager_ii_manager_mng_', 'Manager (Mng.)', true, '9dc69952-eae6-4ec0-a327-67392315f089', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('c0cdbff8-5ed6-4e49-a562-549aecaacfd7', 'services_testing_red_team_specialist_ii_manager_mng_', 'Manager (Mng.)', true, '4b680e29-b4fb-4689-9afb-67a7f089f52b', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('4ca2ade8-8da6-46d7-a7ec-1124e0229d9e', 'functional_accounts_accountant_iii_manager_mng_', 'Manager (Mng.)', true, '6e606c29-2ebf-4ab8-8006-aaedd5680009', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('9de62ea5-b7da-4a55-8b54-056fdf6bc621', 'functional_sales_business_development_associate_i_manager_mng_', 'Manager (Mng.)', true, 'b2b687ef-fd62-4cb7-a826-b40a35da7b2c', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('eaa98dba-df5b-4b1d-b2d5-20b159a0a070', 'services_operations_soc_analyst_i_team_member_tm_', 'Team Member (TM)', true, '6d25ff6d-e13d-440f-b775-215547af7acb', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('2cd464a5-b857-46fc-89ea-5dea92640964', 'services_testing_pentester_ii_team_member_tm_', 'Team Member (TM)', true, '0b6ab354-1fcf-4a00-9be3-e58e99c425ed', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('0997a260-4ca3-4eb2-b87a-4bd6bf235677', 'services_operations_siem_admin_ii_team_member_tm_', 'Team Member (TM)', true, '4650d4e0-f73c-4688-ae5f-830a46348ff9', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('eda2ca5a-d2b1-45db-94cc-4575f0eda8dc', 'functional_it_admini_it_admin_team_member_tm_', 'Team Member (TM)', true, 'da990f6e-3379-4cc4-89b7-0ead29da472b', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('7b597cd0-0153-4ddb-a7b2-f553cbafc8a9', 'functional_sales_customer_success_representative_ii_manager_mng_', 'Manager (Mng.)', true, '157d001c-b056-45b1-96a3-3c05bcd8d99c', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('caec3c96-23a0-4e88-845c-05f792d0dd0c', 'services_testing_associate_project_manager_manager_mng_', 'Manager (Mng.)', true, '3b7ea453-324e-40a0-bb41-77a0795d5af5', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('a955782d-de73-4939-94f8-5cbf9a2461c2', 'services_testing_pentester_i_team_member_tm_', 'Team Member (TM)', true, '4f972924-350a-47fb-a6b6-f2b34bb6b621', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('7bd6b8a7-be33-43ba-b4d7-4d290e71b91e', 'functional_hr_intern_team_member_tm_', 'Team Member (TM)', true, 'e8c22eff-0daf-4690-a537-c8b0b6110a01', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('0028e31d-d2ff-4a71-b5b2-5f0566961d46', 'core_director_and_chief_technology_officer_leader_l_', 'Leader (L)', true, '0525d830-ead9-44a0-871f-91b7845fec26', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('32d7cead-40d2-4d94-89fb-3e48d4160b7c', 'services_testing_intern_team_member_tm_', 'Team Member (TM)', true, '47dbf38f-c022-47bc-8444-d0dfb35ff3fd', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('3db9d726-85c9-4714-8c95-b5c6ebd45fd4', 'services_testing_pentester_iv_team_member_tm_', 'Team Member (TM)', true, '9858c224-f97f-4ff8-908d-f46bd5e2243c', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_roles ("Id", "Code", "Name", "IsActive", "DesignationId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('f67d5930-703b-4497-a4ea-2add60f7fb58', 'functional_project_m_associate_pmo_ii_team_member_tm_', 'Team Member (TM)', true, '2a76927c-461a-48e4-8190-dea7361ef3db', '2026-09-03 11:55:46.803606+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------
-- mst_countries  (40 rows)
-- ---------------------------------------------------------------
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', 'IN', 'India', true, '2026-08-20 11:37:05.749911+00', NULL, NULL, NULL, NULL, '+91', 10) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('339b1d1f-d716-422e-9090-127430134420', 'US', 'United States', true, '2026-08-20 11:37:05.749911+00', NULL, NULL, NULL, NULL, '+1', 10) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('1da1becb-cf4e-4eb4-a6d6-8615ce6100fb', 'GB', 'United Kingdom', true, '2026-08-20 11:37:05.749911+00', NULL, NULL, NULL, NULL, '+44', 10) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('1d3750a9-fab1-43fb-ab7b-865dda283bf3', 'AE', 'United Arab Emirates', true, '2026-08-20 11:37:05.749911+00', NULL, NULL, NULL, NULL, '+971', 9) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('f1d80739-30d7-4877-a1a7-ee414b074134', 'SG', 'Singapore', true, '2026-08-20 11:37:05.749911+00', NULL, NULL, NULL, NULL, '+65', 8) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('eeb56a1f-9663-4d29-a984-30c4fc133de2', 'AU', 'Australia', true, '2026-08-20 11:37:05.749911+00', NULL, NULL, NULL, NULL, '+61', 9) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('3f86bc47-1e09-482f-9671-9f4b5b089ee4', 'DE', 'Germany', true, '2026-08-20 11:37:05.749911+00', NULL, NULL, NULL, NULL, '+49', 11) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('ba695b57-0f82-4ad0-b14a-2785b26209ff', 'CA', 'Canada', true, '2026-08-20 11:37:05.749911+00', NULL, NULL, NULL, NULL, '+1', 10) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('a6baf7f4-bef5-4a8d-ab73-07d86bbaefbb', 'FR', 'France', true, '2026-08-20 11:37:05.749911+00', NULL, NULL, NULL, NULL, '+33', 9) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('01005b87-3f98-4425-8eb9-6417f2d83b41', 'JP', 'Japan', true, '2026-08-20 11:37:05.749911+00', NULL, NULL, NULL, NULL, '+81', 10) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('28d63d80-4982-4a6b-9400-ee91260b2604', 'SA', 'Saudi Arabia', true, '2026-08-20 11:37:05.749911+00', NULL, NULL, NULL, NULL, '+966', 9) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('7c57576c-45b6-4cf0-b26d-d3e64730118b', 'QA', 'Qatar', true, '2026-08-20 11:37:05.749911+00', NULL, NULL, NULL, NULL, '+974', 8) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('58746abf-d5dc-4cc8-8a35-96a1747f7a1f', 'NZ', 'New Zealand', true, '2026-08-20 11:37:05.749911+00', NULL, NULL, NULL, NULL, '+64', 9) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('585fb67f-28ee-437c-aa84-fdc20a1a11d5', 'ZA', 'South Africa', true, '2026-08-20 11:37:05.749911+00', NULL, NULL, NULL, NULL, '+27', 9) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('9bd3e0a8-de16-4a26-92aa-b43deae65bb7', 'IE', 'Ireland', true, '2026-08-20 11:37:05.749911+00', NULL, NULL, NULL, NULL, '+353', 9) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('6f9bb48d-5314-461c-aab8-3b47b00b27a1', 'NL', 'Netherlands', true, '2026-08-20 11:37:05.749911+00', NULL, NULL, NULL, NULL, '+31', 9) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('c1764720-16fe-4d3f-bd82-9882632239cd', 'IT', 'Italy', true, '2026-08-20 11:37:05.749911+00', NULL, NULL, NULL, NULL, '+39', 10) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('4da9200f-5486-4710-bf58-e73778e1d506', 'ES', 'Spain', true, '2026-08-20 11:37:05.749911+00', NULL, NULL, NULL, NULL, '+34', 9) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('d3791631-5e4b-4efa-a86a-59344c19e1a1', 'CH', 'Switzerland', true, '2026-08-20 11:37:05.749911+00', NULL, NULL, NULL, NULL, '+41', 9) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('c093b0e3-31a9-40b4-840c-539ca86bc578', 'KR', 'South Korea', true, '2026-08-20 11:37:05.749911+00', NULL, NULL, NULL, NULL, '+82', 10) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('068fb26f-376a-4976-9127-b0dae76e7dcd', 'DK', 'Denmark', true, '2026-08-20 11:37:05.749911+00', '2026-09-02 05:13:48.939145+00', NULL, NULL, NULL, '+45', 8) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('0a836600-60d1-4d2e-bbd7-034b338574ba', 'PK', 'Pakistan', true, '2026-08-20 11:37:05.749911+00', '2026-09-02 05:13:48.939145+00', NULL, NULL, NULL, '+92', 10) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('1814186b-4a79-45ea-bfc9-bbdc4721e20b', 'PH', 'Philippines', true, '2026-08-20 11:37:05.749911+00', '2026-09-02 05:13:48.939145+00', NULL, NULL, NULL, '+63', 10) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('25e6b9ec-058b-4778-9c17-1151079562f4', 'AT', 'Austria', true, '2026-08-20 11:37:05.749911+00', '2026-09-02 05:13:48.939145+00', NULL, NULL, NULL, '+43', 10) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('331cec37-bd6c-4a60-8ac5-b413d9677b8a', 'MX', 'Mexico', true, '2026-08-20 11:37:05.749911+00', '2026-09-02 05:13:48.939145+00', NULL, NULL, NULL, '+52', 10) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('6044817c-ffa1-44b3-ac2a-05e52b97df4a', 'BR', 'Brazil', true, '2026-08-20 11:37:05.749911+00', '2026-09-02 05:13:48.939145+00', NULL, NULL, NULL, '+55', 11) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('64ea0815-a39c-4ecb-b771-038dd74a9b7c', 'TH', 'Thailand', true, '2026-08-20 11:37:05.749911+00', '2026-09-02 05:13:48.939145+00', NULL, NULL, NULL, '+66', 9) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('6e5c5f7b-ab38-4926-9945-da9ac35a35b0', 'BE', 'Belgium', true, '2026-08-20 11:37:05.749911+00', '2026-09-02 05:13:48.939145+00', NULL, NULL, NULL, '+32', 9) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('7190bc9f-d9d5-4bb3-b889-af8a1d6ec53f', 'LK', 'Sri Lanka', true, '2026-08-20 11:37:05.749911+00', '2026-09-02 05:13:48.939145+00', NULL, NULL, NULL, '+94', 9) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('8b34d450-add9-4da2-ab29-651c187ae702', 'CN', 'China', true, '2026-08-20 11:37:05.749911+00', '2026-09-02 05:13:48.939145+00', NULL, NULL, NULL, '+86', 11) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('990888a7-50d0-45f0-b650-2686f87c4fd0', 'SE', 'Sweden', true, '2026-08-20 11:37:05.749911+00', '2026-09-02 05:13:48.939145+00', NULL, NULL, NULL, '+46', 9) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('9c93a091-0971-4080-b15f-ddebb9de6bb3', 'FI', 'Finland', true, '2026-08-20 11:37:05.749911+00', '2026-09-02 05:13:48.939145+00', NULL, NULL, NULL, '+358', 9) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('a3228796-7e35-4710-9439-2aa36754dbbe', 'VN', 'Vietnam', true, '2026-08-20 11:37:05.749911+00', '2026-09-02 05:13:48.939145+00', NULL, NULL, NULL, '+84', 9) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('a890f8b0-d80f-4a14-994e-0ba88d6336a9', 'NO', 'Norway', true, '2026-08-20 11:37:05.749911+00', '2026-09-02 05:13:48.939145+00', NULL, NULL, NULL, '+47', 8) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('af68020d-22f0-4f66-91f6-afe82d052ddd', 'PL', 'Poland', true, '2026-08-20 11:37:05.749911+00', '2026-09-02 05:13:48.939145+00', NULL, NULL, NULL, '+48', 9) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('b8307417-a01f-4b81-8f46-b637c865dc76', 'PT', 'Portugal', true, '2026-08-20 11:37:05.749911+00', '2026-09-02 05:13:48.939145+00', NULL, NULL, NULL, '+351', 9) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('c9bb9747-7e0f-424e-864b-182d7a8c4230', 'NP', 'Nepal', true, '2026-08-20 11:37:05.749911+00', '2026-09-02 05:13:48.939145+00', NULL, NULL, NULL, '+977', 10) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('d725a52a-22a3-48d6-b035-001c1aa15eae', 'MY', 'Malaysia', true, '2026-08-20 11:37:05.749911+00', '2026-09-02 05:13:48.939145+00', NULL, NULL, NULL, '+60', 9) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('e341a797-6da6-4427-9bc1-f3271b6882c1', 'ID', 'Indonesia', true, '2026-08-20 11:37:05.749911+00', '2026-09-02 05:13:48.939145+00', NULL, NULL, NULL, '+62', 10) ON CONFLICT DO NOTHING;
INSERT INTO mst_countries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "PhoneCode", "PhoneDigits") VALUES ('ecb5e362-682e-46d2-bee2-ef0b022ebb13', 'BD', 'Bangladesh', true, '2026-08-20 11:37:05.749911+00', '2026-09-02 05:13:48.939145+00', NULL, NULL, NULL, '+880', 10) ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------
-- mst_cities  (137 rows)
-- ---------------------------------------------------------------
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('07183c9f-8e55-4002-bc52-97b380967367', 'in_raipur', 'Raipur', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('084d0e54-375e-4eb2-a348-577dd4ad73fa', 'us_boston', 'Boston', true, '339b1d1f-d716-422e-9090-127430134420', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('08b411f1-b35e-4989-a856-ae6f7596743a', 'mx_mexico_city', 'Mexico City', true, '331cec37-bd6c-4a60-8ac5-b413d9677b8a', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('0b3b4341-9cd1-4d9c-a2ed-12309bce2340', 'gb_manchester', 'Manchester', true, '1da1becb-cf4e-4eb4-a6d6-8615ce6100fb', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('0cc0f358-f7aa-48de-a5da-815f3f06c252', 'us_los_angeles', 'Los Angeles', true, '339b1d1f-d716-422e-9090-127430134420', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('0dd2728e-6f8d-462e-906f-186f51ab2ba7', 'us_new_york', 'New York', true, '339b1d1f-d716-422e-9090-127430134420', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('0e740962-784f-4738-a401-cb10072107e8', 'in_delhi', 'Delhi', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('0fb20e80-ce14-4160-9102-dcec4ccdbecc', 'in_patna', 'Patna', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('11fe6de8-1cab-45d7-b88d-51151386c2e0', 'id_jakarta', 'Jakarta', true, 'e341a797-6da6-4427-9bc1-f3271b6882c1', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('14c601ac-1628-423f-95ef-c2189d3f1cd8', 'us_atlanta', 'Atlanta', true, '339b1d1f-d716-422e-9090-127430134420', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('19062584-e553-4778-96dd-be7031ae6521', 'in_jodhpur', 'Jodhpur', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('19eb3378-5b1f-4b69-b712-37db29dcd4f3', 'ca_montreal', 'Montreal', true, 'ba695b57-0f82-4ad0-b14a-2785b26209ff', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('1a08451f-8c92-4edf-97da-f9bb41a840e1', 'in_udaipur', 'Udaipur', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('1a18d297-caf0-4d13-9a25-4014e1e1c6bf', 'in_kolkata', 'Kolkata', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('1aae890c-96bd-4529-bcc3-fed9fd30c24d', 'kr_seoul', 'Seoul', true, 'c093b0e3-31a9-40b4-840c-539ca86bc578', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('1b61f09f-68d1-480d-bc08-96836413a8c6', 'gb_edinburgh', 'Edinburgh', true, '1da1becb-cf4e-4eb4-a6d6-8615ce6100fb', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('1e051a3a-34a5-4854-9e7b-9813fc76c34f', 'sa_jeddah', 'Jeddah', true, '28d63d80-4982-4a6b-9400-ee91260b2604', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('1fff6b1e-f337-4f93-a98a-d952449aea7b', 'in_lucknow', 'Lucknow', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('213d37ca-46b2-4caa-8551-abbf2274ced7', 'in_jaipur', 'Jaipur', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('21a5ff30-a774-4d3a-80d4-0eeb88e8b395', 'in_kochi', 'Kochi', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('223b9c33-57cc-460f-9433-dc4fb39a649f', 'gb_birmingham', 'Birmingham', true, '1da1becb-cf4e-4eb4-a6d6-8615ce6100fb', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('23d8be99-7dfc-48f1-95b1-8d764af0b16a', 'in_varanasi', 'Varanasi', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('2451c2e3-f142-48e4-96a3-3eb9eba2c892', 'sg_singapore', 'Singapore', true, 'f1d80739-30d7-4877-a1a7-ee414b074134', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('2764903d-c6c1-4049-84b2-0045296b6040', 'au_perth', 'Perth', true, 'eeb56a1f-9663-4d29-a984-30c4fc133de2', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('277cc369-b358-445d-add4-579a493cc3e7', 'pk_karachi', 'Karachi', true, '0a836600-60d1-4d2e-bbd7-034b338574ba', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('29593af5-af1d-4a5b-9562-3c7bbdea45ef', 'fr_paris', 'Paris', true, 'a6baf7f4-bef5-4a8d-ab73-07d86bbaefbb', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('2961f98c-8524-49ca-89fb-c7f51a318d4a', 'pl_krakow', 'Krakow', true, 'af68020d-22f0-4f66-91f6-afe82d052ddd', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('301f6d9d-93cd-4eb6-bf32-8e4f09930007', 'au_melbourne', 'Melbourne', true, 'eeb56a1f-9663-4d29-a984-30c4fc133de2', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('30ff773f-5f99-43d2-a22e-6a0c471d5d2a', 'it_rome', 'Rome', true, 'c1764720-16fe-4d3f-bd82-9882632239cd', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('353adddb-265f-4326-9658-700c3558cee7', 'jp_yokohama', 'Yokohama', true, '01005b87-3f98-4425-8eb9-6417f2d83b41', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('3cf94e25-007c-4f67-9ba2-a64fe7a4e9c5', 'us_austin', 'Austin', true, '339b1d1f-d716-422e-9090-127430134420', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('3fb0cb31-828a-4c49-8ffd-f65721b669f1', 'us_washington_dc', 'Washington DC', true, '339b1d1f-d716-422e-9090-127430134420', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('3fe72ba7-7db7-4e00-8e58-fa685afca0ce', 'my_kuala_lumpur', 'Kuala Lumpur', true, 'd725a52a-22a3-48d6-b035-001c1aa15eae', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('41e88e7d-b540-4f0b-9dc3-b8a6ed375eac', 'bd_chittagong', 'Chittagong', true, 'ecb5e362-682e-46d2-bee2-ef0b022ebb13', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('4351e7e2-fe6b-4062-b7e1-5a23b152a2fd', 'in_guntur', 'Guntur', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('449b8fec-f1a0-4b96-ba76-b11fc95dc854', 'de_hamburg', 'Hamburg', true, '3f86bc47-1e09-482f-9671-9f4b5b089ee4', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('44cff32a-4802-47a7-8590-cb61848bbf81', 'jp_tokyo', 'Tokyo', true, '01005b87-3f98-4425-8eb9-6417f2d83b41', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('45e91295-3902-440f-85af-13e998ad000c', 'in_vadodara', 'Vadodara', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('45fc7e0b-fa8b-4e17-9df2-2b803f1692c2', 'nz_wellington', 'Wellington', true, '58746abf-d5dc-4cc8-8a35-96a1747f7a1f', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('484378bd-7a89-4b55-9add-8a22bd71995a', 'in_ahmedabad', 'Ahmedabad', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('4860b8a2-acf1-47bc-aa0e-b9a88341e321', 'it_milan', 'Milan', true, 'c1764720-16fe-4d3f-bd82-9882632239cd', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('48a796c1-38e5-49f0-bbd5-6400ce30ee23', 'in_nagpur', 'Nagpur', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('4a2b4e31-024b-4bae-9cec-afefe791e0ee', 'ae_sharjah', 'Sharjah', true, '1d3750a9-fab1-43fb-ab7b-865dda283bf3', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('4a9692f8-9fc3-48f8-82bd-075a36f31ecf', 'za_cape_town', 'Cape Town', true, '585fb67f-28ee-437c-aa84-fdc20a1a11d5', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('4c92b186-fb45-4ed0-b38d-cda7f143a993', 'de_frankfurt', 'Frankfurt', true, '3f86bc47-1e09-482f-9671-9f4b5b089ee4', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('4d396fc0-ae55-4eeb-b2db-79bbb757d3cd', 'in_kalyan_dombivli', 'Kalyan-Dombivli', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('4fd00295-51a7-4bfe-81fa-97cdcce23451', 'cn_shenzhen', 'Shenzhen', true, '8b34d450-add9-4da2-ab29-651c187ae702', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('55e401d4-a911-4f92-ba41-23e34513ef78', 'in_amritsar', 'Amritsar', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('57a45744-d93d-4ca7-9fee-8358914674b9', 'bd_dhaka', 'Dhaka', true, 'ecb5e362-682e-46d2-bee2-ef0b022ebb13', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('5965cf30-b981-47ca-a3ba-c875c33c1361', 'ae_dubai', 'Dubai', true, '1d3750a9-fab1-43fb-ab7b-865dda283bf3', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('5a35da4d-0d93-45a9-bb97-aa470535f713', 'in_thiruvananthapuram', 'Thiruvananthapuram', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('5b3989d6-699e-47a3-8c8b-0c6fa6509727', 'de_munich', 'Munich', true, '3f86bc47-1e09-482f-9671-9f4b5b089ee4', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('5cd424e6-ab9c-4498-a67e-027a9c3439ce', 'de_berlin', 'Berlin', true, '3f86bc47-1e09-482f-9671-9f4b5b089ee4', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('626c62f3-eac8-492b-b570-ab1c6ac764a6', 'nl_amsterdam', 'Amsterdam', true, '6f9bb48d-5314-461c-aab8-3b47b00b27a1', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('642f3232-b168-4934-b4e3-f10437500640', 'in_kanpur', 'Kanpur', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('670404c6-c476-4d08-a374-3e4d6669f66c', 'in_chandigarh', 'Chandigarh', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('67f59fe5-a37c-49b9-b0cf-322a8b0b2d3b', 'no_oslo', 'Oslo', true, 'a890f8b0-d80f-4a14-994e-0ba88d6336a9', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('6a068925-de66-4927-979b-5ed42766c09b', 'au_brisbane', 'Brisbane', true, 'eeb56a1f-9663-4d29-a984-30c4fc133de2', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('6e520834-9523-42ad-8ad8-20e8b14dea83', 'es_barcelona', 'Barcelona', true, '4da9200f-5486-4710-bf58-e73778e1d506', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('6ffbb80b-985d-4f00-9140-db22f39a625d', 'in_mumbai', 'Mumbai', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('716817f5-02f6-4f05-8daa-023f6cdffede', 'in_hubballi', 'Hubballi', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('740a6636-f7ab-498d-9f2b-588eaac5338a', 'th_bangkok', 'Bangkok', true, '64ea0815-a39c-4ecb-b771-038dd74a9b7c', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('7621f953-b63b-4a95-b23f-3e0277109b92', 'se_stockholm', 'Stockholm', true, '990888a7-50d0-45f0-b650-2686f87c4fd0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('79b5f114-216f-4ee1-973c-57e22110d450', 'za_johannesburg', 'Johannesburg', true, '585fb67f-28ee-437c-aa84-fdc20a1a11d5', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('7a91b70b-e0ce-4613-9d2f-4ebd06b816eb', 'be_brussels', 'Brussels', true, '6e5c5f7b-ab38-4926-9945-da9ac35a35b0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('7d25aaed-acb8-4b6d-a16a-1b90054e6996', 'vn_hanoi', 'Hanoi', true, 'a3228796-7e35-4710-9439-2aa36754dbbe', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('7dd04422-91e0-4671-965f-66658c3bf3a4', 'es_madrid', 'Madrid', true, '4da9200f-5486-4710-bf58-e73778e1d506', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('8152a6d2-ce3d-48a9-aee8-2508c86199d1', 'nl_rotterdam', 'Rotterdam', true, '6f9bb48d-5314-461c-aab8-3b47b00b27a1', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('81908f77-5500-4974-a57a-ba7cfccc7a9a', 'in_jamshedpur', 'Jamshedpur', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('81a2bc40-e010-43f1-bcce-9a9198d4ab9d', 'au_sydney', 'Sydney', true, 'eeb56a1f-9663-4d29-a984-30c4fc133de2', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('8249edd0-daaf-4d91-8ede-59e00790d90e', 'in_madurai', 'Madurai', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('847e49f7-e605-434e-9abe-35b23cb5af90', 'ch_geneva', 'Geneva', true, 'd3791631-5e4b-4efa-a86a-59344c19e1a1', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('87da8284-74ad-4e12-ad68-23fd727a5e5b', 'ch_zurich', 'Zurich', true, 'd3791631-5e4b-4efa-a86a-59344c19e1a1', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('8a0d7587-098e-4c80-ab86-38aa76c56c2d', 'br_rio_de_janeiro', 'Rio de Janeiro', true, '6044817c-ffa1-44b3-ac2a-05e52b97df4a', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('8c56329e-5d66-48aa-b242-a15150254bf4', 'cn_shanghai', 'Shanghai', true, '8b34d450-add9-4da2-ab29-651c187ae702', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('8cd04b30-de06-4ba0-81e1-b120cb24045e', 'pl_warsaw', 'Warsaw', true, 'af68020d-22f0-4f66-91f6-afe82d052ddd', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('8de0928d-e308-4272-9dfb-efbd97b6b683', 'in_mysuru', 'Mysuru', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('8df31b20-7394-4727-af49-216c3302c4a2', 'ph_cebu', 'Cebu', true, '1814186b-4a79-45ea-bfc9-bbdc4721e20b', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('92187184-87f9-42c6-84a2-30a1cdcd698f', 'ae_abu_dhabi', 'Abu Dhabi', true, '1d3750a9-fab1-43fb-ab7b-865dda283bf3', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('95913438-968f-4e17-8324-a8e75b2242f4', 'in_gurugram', 'Gurugram', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('9600a90b-6463-48cd-887f-45997a11248d', 'in_chennai', 'Chennai', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('96070596-6a1e-44aa-b35b-83b7a6b7b8aa', 'sa_dammam', 'Dammam', true, '28d63d80-4982-4a6b-9400-ee91260b2604', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('97ec307e-5801-49b4-86aa-75563e5e711b', 'in_bhubaneswar', 'Bhubaneswar', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('9891ebbe-9411-4a41-b472-67451441fc56', 'dk_copenhagen', 'Copenhagen', true, '068fb26f-376a-4976-9127-b0dae76e7dcd', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('9ba22a3c-c3ca-4472-a50d-9bb1b5bd8d09', 'gb_bristol', 'Bristol', true, '1da1becb-cf4e-4eb4-a6d6-8615ce6100fb', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('9bc015d9-b447-4cad-b4bb-8d33507cbdaf', 'fr_lyon', 'Lyon', true, 'a6baf7f4-bef5-4a8d-ab73-07d86bbaefbb', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('9cde9f5d-4f0b-4672-a4be-9c1e3f307638', 'in_aurangabad', 'Aurangabad', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('a5a7e7fd-087e-464b-bd31-25f11f357f91', 'us_chicago', 'Chicago', true, '339b1d1f-d716-422e-9090-127430134420', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ab7836eb-7cc7-439d-9dca-49161aa76292', 'in_indore', 'Indore', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ab8ebe77-f842-4ae8-a84e-01e14a9fd702', 'us_seattle', 'Seattle', true, '339b1d1f-d716-422e-9090-127430134420', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ad785e99-dacc-477f-8db6-e8046a39b215', 'pk_islamabad', 'Islamabad', true, '0a836600-60d1-4d2e-bbd7-034b338574ba', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('b1120770-e683-4592-8024-47caf0f35746', 'in_ranchi', 'Ranchi', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('b3e264bf-fcc4-45a2-ac8f-04166724d05b', 'mx_monterrey', 'Monterrey', true, '331cec37-bd6c-4a60-8ac5-b413d9677b8a', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('b5302d8c-0de7-433b-8c87-5cf75f75b5f1', 'in_dehradun', 'Dehradun', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('b76b4b18-8708-4ff8-8134-58d5a02e62e7', 'in_visakhapatnam', 'Visakhapatnam', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('b79f714f-b9e1-4556-be97-02de9d27568b', 'in_surat', 'Surat', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('b8f9023b-e2ec-4095-be6f-2249a95686b5', 'in_hyderabad', 'Hyderabad', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('b9e2a825-60b2-4839-865b-dc6b1874d89b', 'in_bhopal', 'Bhopal', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('bad14380-4cb5-45f5-b7bb-669181caee13', 'in_nashik', 'Nashik', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('bba31ffe-e8c3-4069-9b89-a707f3185cdf', 'nz_auckland', 'Auckland', true, '58746abf-d5dc-4cc8-8a35-96a1747f7a1f', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('bd3bac50-1d10-44cb-b69b-9e09aa0f6a6b', 'in_rajkot', 'Rajkot', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('bd5bed6a-230c-4972-a94a-95457a5ebdaf', 'vn_ho_chi_minh_city', 'Ho Chi Minh City', true, 'a3228796-7e35-4710-9439-2aa36754dbbe', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('bdc2e3e8-bb40-4b50-af48-446cb848bfaf', 'ca_vancouver', 'Vancouver', true, 'ba695b57-0f82-4ad0-b14a-2785b26209ff', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('be3bc063-9c10-4614-94d5-7b847afaf6bd', 'in_thane', 'Thane', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('beb4a29c-e0c5-4509-8400-8f672a820183', 'in_prayagraj', 'Prayagraj', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('bf4289e3-e404-41e7-829d-8f0028a48965', 'in_coimbatore', 'Coimbatore', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ca0b9269-d93e-4748-9280-939d97ed7ffd', 'us_dallas', 'Dallas', true, '339b1d1f-d716-422e-9090-127430134420', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('cd21e337-74ca-4531-920a-fd728182dd9d', 'in_noida', 'Noida', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('cd689e49-cf58-40db-aa97-cad0285a0be8', 'pt_lisbon', 'Lisbon', true, 'b8307417-a01f-4b81-8f46-b637c865dc76', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('d2700377-afed-4114-b7cd-fe5d63394dba', 'kr_busan', 'Busan', true, 'c093b0e3-31a9-40b4-840c-539ca86bc578', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('d76207a2-8c4c-4352-acb7-67f098fb08c4', 'in_bengaluru', 'Bengaluru', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('d768797a-cf38-4742-83c4-de675ed8d7b6', 'in_ludhiana', 'Ludhiana', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('d8136f7e-2533-4704-9c10-4cba8453f4cb', 'pk_lahore', 'Lahore', true, '0a836600-60d1-4d2e-bbd7-034b338574ba', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('d9972aef-6b7e-48a1-abc0-6a5e043233d9', 'in_warangal', 'Warangal', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('dc141bc7-8039-4645-854e-1e2c898ce0dc', 'in_pune', 'Pune', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e00fecb8-b28f-491a-bcb7-dc47445c7c5d', 'ph_manila', 'Manila', true, '1814186b-4a79-45ea-bfc9-bbdc4721e20b', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e051a3eb-67a4-48a1-bd0f-ba12879af889', 'jp_osaka', 'Osaka', true, '01005b87-3f98-4425-8eb9-6417f2d83b41', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e19e0057-cea0-429c-b5ac-4762d5107735', 'ie_dublin', 'Dublin', true, '9bd3e0a8-de16-4a26-92aa-b43deae65bb7', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e28e5c98-4103-43a2-b5a0-ad2ba96bf6d6', 'at_vienna', 'Vienna', true, '25e6b9ec-058b-4778-9c17-1151079562f4', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e2e4ac9d-6292-47c1-9424-7362ab4b024c', 'sa_riyadh', 'Riyadh', true, '28d63d80-4982-4a6b-9400-ee91260b2604', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e4cbe1c4-88f4-4fc3-b7e9-121f08aa3495', 'np_kathmandu', 'Kathmandu', true, 'c9bb9747-7e0f-424e-864b-182d7a8c4230', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e69a29ec-e5fa-4786-a88a-13fbaaedddf0', 'fi_helsinki', 'Helsinki', true, '9c93a091-0971-4080-b15f-ddebb9de6bb3', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ea72f142-d2b7-4d74-8877-4c5c64106d84', 'in_navi_mumbai', 'Navi Mumbai', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ea739f55-0951-498d-bebc-14f34c1aea51', 'br_sao_paulo', 'Sao Paulo', true, '6044817c-ffa1-44b3-ac2a-05e52b97df4a', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('eb19cb49-5743-4f8e-b3de-1c97a8527c8a', 'us_san_francisco', 'San Francisco', true, '339b1d1f-d716-422e-9090-127430134420', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ec893479-ffdd-4ec0-9f85-1fdee09c2e06', 'in_mangaluru', 'Mangaluru', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ee152b57-cf4a-4d13-bfd7-7f19f506caa4', 'ca_toronto', 'Toronto', true, 'ba695b57-0f82-4ad0-b14a-2785b26209ff', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ef0f0962-986c-4894-9ba4-0f0226a8c5ff', 'qa_doha', 'Doha', true, '7c57576c-45b6-4cf0-b26d-d3e64730118b', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ef6bd7b1-faf0-4813-8105-b9d7c240d79d', 'in_vijayawada', 'Vijayawada', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('f2aaa2da-20ad-4d42-9a32-c264a31d747e', 'lk_colombo', 'Colombo', true, '7190bc9f-d9d5-4bb3-b889-af8a1d6ec53f', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('fa492bc9-1015-4a17-9e5b-585b44740f64', 'in_guwahati', 'Guwahati', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('fa7c197c-a692-443e-bdfa-82c591807262', 'id_surabaya', 'Surabaya', true, 'e341a797-6da6-4427-9bc1-f3271b6882c1', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('fb029a31-16c1-4b23-bc35-3d4ca08e6961', 'my_penang', 'Penang', true, 'd725a52a-22a3-48d6-b035-001c1aa15eae', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('fc8929c1-64ad-4185-bd6e-c706486b8a41', 'gb_london', 'London', true, '1da1becb-cf4e-4eb4-a6d6-8615ce6100fb', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('fcf5dd98-6fe2-4ae3-8084-9966e94eb443', 'cn_beijing', 'Beijing', true, '8b34d450-add9-4da2-ab29-651c187ae702', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('fddb7350-b051-4870-bda3-17f51b79fd67', 'se_gothenburg', 'Gothenburg', true, '990888a7-50d0-45f0-b650-2686f87c4fd0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_cities ("Id", "Code", "Name", "IsActive", "CountryId", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('fe6526bc-a57b-4c6e-8094-be6327614409', 'in_tiruchirappalli', 'Tiruchirappalli', true, 'f6f9895d-c4be-4b1c-adf4-6030b5dc9ca0', '2026-08-20 11:37:06.005856+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------
-- mst_nationalities  (40 rows)
-- ---------------------------------------------------------------
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('04b75a98-c6b8-4b0e-a7d4-42ecc057b6cc', 'austrian', 'Austrian', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('09129869-9da0-4b92-b902-bccf3b190924', 'german', 'German', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('09a35109-3ee6-47e7-9b0b-fa88c7d0ac99', 'new_zealander', 'New Zealander', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('09ed0b27-5cde-44d8-9261-3862def51411', 'bangladeshi', 'Bangladeshi', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('0cce8a7a-872b-4dcf-b93f-e970e7738b68', 'nepali', 'Nepali', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('0fa6ec80-f2ce-4e84-a033-5d1087fb0443', 'brazilian', 'Brazilian', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('167a88de-c2f2-4ade-a59f-f0fe528c8148', 'australian', 'Australian', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('1b534d63-f63c-40c4-a2aa-4a4ffb6dc84f', 'malaysian', 'Malaysian', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('24789f37-c453-4501-a58a-28d529548292', 'irish', 'Irish', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('2713bcd3-4be1-419d-9794-bfc156bb272c', 'finnish', 'Finnish', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('27649c51-f84b-4c41-98dd-088137056410', 'portuguese', 'Portuguese', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('2f45efbb-0fe4-4ff4-823a-115b4a4eebe7', 'thai', 'Thai', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('3360906d-ef37-472e-88c2-d683adeb1a3c', 'vietnamese', 'Vietnamese', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('3887a87a-8ddb-4b00-8602-b4b5924948e0', 'italian', 'Italian', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('391e969e-51f9-4f6e-84dc-999bd5388313', 'french', 'French', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('39dd28db-19c0-4825-93ab-cdf200b5293d', 'sri_lankan', 'Sri Lankan', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('3f7d49d0-78d5-4ea0-8dc8-8c2e1f38a608', 'qatari', 'Qatari', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('402a8883-1aec-4de9-9f11-5fe21f4616e4', 'norwegian', 'Norwegian', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('4573bb8a-3983-4b7e-bc35-66cdc453db63', 'filipino', 'Filipino', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('51e0b818-e56e-4620-a76d-fb0cf20276ad', 'singaporean', 'Singaporean', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('5c53c604-752e-483b-9a69-2a6e335fc95f', 'swiss', 'Swiss', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('6bbaf86c-61a5-43d4-8569-88972a5d287b', 'british', 'British', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('6c8a9602-77d6-4779-b2fd-0ad5099a8082', 'swedish', 'Swedish', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('6f17d00b-2ea6-4e76-88d6-59cdb9868042', 'american', 'American', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('72923a6d-50d4-4fee-932a-9285e3790596', 'japanese', 'Japanese', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('73179bf3-ae40-46a9-9d97-31ae9cba3ad5', 'mexican', 'Mexican', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('79686ca4-102c-456d-a08e-bdf9ac4c7a26', 'indian', 'Indian', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('7e7041fd-ea5f-4252-889f-c8397711707e', 'chinese', 'Chinese', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('8e6e00fb-5f3d-4218-a910-24781b714a15', 'canadian', 'Canadian', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('913f6079-fd2b-45cf-9be6-4097d1532c2b', 'south_african', 'South African', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('98426802-63bc-42a4-ba56-b22cc8f62d79', 'saudi', 'Saudi', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('a1e8bb9f-8857-4fa5-96ce-228d8167a680', 'polish', 'Polish', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('a62e9f44-9f08-4279-8dc9-e73b389474b9', 'pakistani', 'Pakistani', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('aa7c3e6d-be99-4998-ab70-b1efeea858b1', 'belgian', 'Belgian', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('b57f453f-4e79-401f-a410-a362cd109c7f', 'south_korean', 'South Korean', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('b7e05ed9-2278-4803-9eec-29022231e80f', 'danish', 'Danish', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('c0723df4-2f0a-4bdd-a6d8-faf6aee6d1ac', 'dutch', 'Dutch', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('edc14e22-d845-4e14-9786-259b50ebe78a', 'emirati', 'Emirati', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('f1d1979a-91bb-46cf-aec1-6dafb707fcb7', 'spanish', 'Spanish', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_nationalities ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('fe29360e-bc38-4557-8653-98b749b34fe0', 'indonesian', 'Indonesian', true, '2026-08-20 12:25:01.232338+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------
-- mst_industries  (13 rows)
-- ---------------------------------------------------------------
INSERT INTO mst_industries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('7f460c51-01ec-4da1-8f71-d6f360b56f91', 'healthcare', 'Healthcare', true, '2026-08-18 07:55:36.166597+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_industries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('f175fde9-14f8-40e8-b564-47d8a29d84ff', 'logistics', 'Logistics', true, '2026-08-18 07:55:36.166597+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_industries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('c7e82721-829b-4450-8393-022587178471', 'energy', 'Energy', true, '2026-08-18 07:55:36.166597+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_industries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('4a80bfdb-a191-4ce1-ab51-2142eb366db7', 'banking', 'Banking', true, '2026-08-18 07:55:36.166597+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_industries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('935db8d7-e2aa-417e-839e-b51d00ce951e', 'retail', 'Retail', true, '2026-08-18 07:55:36.166597+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_industries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e722474e-d845-42b8-978e-91a6ec78f080', 'manufacturing', 'Manufacturing', true, '2026-08-18 07:55:36.166597+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_industries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ff5e83cc-9c1c-4056-ab0b-42a70714ddd3', 'media', 'Media', true, '2026-08-20 06:15:51.759149+00', NULL, 'a2ef1e7d-5d70-8e86-f48d-429ce5a745dc', NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_industries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('dcb2b955-8d33-4b9b-b04a-64208dce1520', 'telecom', 'Telecom', true, '2026-09-09 07:16:02.332706+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_industries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('02012f0c-97b2-4aea-a6b4-954ee97d892d', 'technology', 'Technology', false, '2026-08-18 07:55:36.166597+00', '2026-09-09 07:25:18.453091+00', NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_industries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('16ebeb23-b3d8-4fb7-a4f6-789510c28ad3', 'environment', 'Environment', false, '2026-08-18 07:55:36.166597+00', '2026-09-09 07:25:18.453091+00', NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_industries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('3a8e57e7-2f6d-4c84-9428-d11de98078c9', 'quantum_computing', 'Quantum Computing', false, '2026-08-19 06:32:47.466308+00', '2026-09-09 07:25:18.453091+00', 'a2ef1e7d-5d70-8e86-f48d-429ce5a745dc', NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_industries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('4bf54de4-0e85-4904-a89f-542301b65077', 'automotive', 'Automotive', false, '2026-08-18 07:55:36.166597+00', '2026-09-09 07:25:18.453091+00', NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_industries ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('cd116cba-a939-4cb7-bd0f-233019a005b0', 'finance', 'Finance', false, '2026-08-18 07:55:36.166597+00', '2026-09-09 07:25:18.453091+00', NULL, NULL, NULL) ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------
-- mst_salary_bands  (5 rows)
-- ---------------------------------------------------------------
INSERT INTO mst_salary_bands ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('20ffbe9b-96ca-496e-ab2e-50ccf3c91246', 'l3', 'L3', true, '2026-08-20 12:51:10.222702+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_salary_bands ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('37016f9a-2474-400d-99ae-18157aaad035', 'l1', 'L1', true, '2026-08-20 12:51:10.222702+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_salary_bands ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('822f92eb-c6fa-4c0f-a8ec-e4c2d16af583', 'l4', 'L4', true, '2026-08-20 12:51:10.222702+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_salary_bands ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e5f5511b-dea6-421c-8c0e-b271e4ee5d43', 'l5', 'L5', true, '2026-08-20 12:51:10.222702+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_salary_bands ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ebed343e-301f-4984-b292-fa8d1cb1623c', 'l2', 'L2', true, '2026-08-20 12:51:10.222702+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------
-- mst_email_domains  (3 rows)
-- ---------------------------------------------------------------
INSERT INTO mst_email_domains ("Id", "Code", "DomainName", "DisplayName", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('5112286a-225d-4b86-b16f-74211d9c5779', 'talakunchi_com', 'talakunchi.com', '@talakunchi.com', true, 1, '2026-08-21 19:12:04.483485+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_email_domains ("Id", "Code", "DomainName", "DisplayName", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('a19f97e1-8bf5-4b14-823a-b653b62c2954', 'talakunchi_in', 'talakunchi.in', '@talakunchi.in', true, 2, '2026-08-21 19:12:04.483485+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_email_domains ("Id", "Code", "DomainName", "DisplayName", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('fb66fff9-7911-47de-bde7-ab5fb5ab0757', 'squad1_io', 'squad1.io', '@squad1.io', true, 3, '2026-08-21 19:12:04.483485+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------
-- mst_business_units  (1 rows)
-- ---------------------------------------------------------------
INSERT INTO mst_business_units ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('1ab2e67e-5e47-4f6d-8035-dd6a5c5f6b85', 'talakunchi_networks_private_limited', 'Talakunchi Networks Private Limited', true, 1, '2026-09-03 12:17:46.134222+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------
-- mst_work_locations  (3 rows)
-- ---------------------------------------------------------------
INSERT INTO mst_work_locations ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('3bc10d7b-a705-4ec9-b7b5-71858572a8cc', 'suvidha_square_andheri', 'Suvidha Square, Andheri', true, 2, '2026-09-03 12:26:58.067087+00', '2026-09-10 06:34:25.480503+00', NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_work_locations ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('58e569dc-cb93-4832-bf22-2e8d4836dc65', 'onsite', 'Onsite', true, 1, '2026-09-03 12:26:58.067087+00', '2026-09-10 06:34:25.480503+00', NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_work_locations ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('8d0b23a2-9459-4fbe-a7bf-624abd410c40', 'navare_plaza_dombivli', 'Navare Plaza, Dombivli', true, 3, '2026-09-03 12:26:58.067087+00', '2026-09-10 06:34:25.480503+00', NULL, NULL, NULL) ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------
-- mst_offices : no rows on source
-- ---------------------------------------------------------------

-- ---------------------------------------------------------------
-- mst_employee_statuses  (5 rows)
-- ---------------------------------------------------------------
INSERT INTO mst_employee_statuses ("Id", "Code", "Name", "IsActive", "AllowOnboarding", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('26e2b2e5-b1ab-40af-8f6d-2b80deb463a0', 'absconded', 'Absconded', true, false, 3, '2026-09-07 06:03:13.27055+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_employee_statuses ("Id", "Code", "Name", "IsActive", "AllowOnboarding", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('a0b5f4d8-fb43-4df7-a98d-0e2454a0907b', 'terminated', 'Terminated', true, false, 2, '2026-09-07 06:03:13.27055+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_employee_statuses ("Id", "Code", "Name", "IsActive", "AllowOnboarding", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('beee234f-c734-4d09-a0bb-96a6cc523cc3', 'resignation_under_review', 'Resignation Under Review', true, false, 5, '2026-09-07 06:03:13.27055+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_employee_statuses ("Id", "Code", "Name", "IsActive", "AllowOnboarding", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ce28b4c5-a343-493b-9404-96c983768850', 'resigned', 'Resigned', true, false, 4, '2026-09-07 06:03:13.27055+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_employee_statuses ("Id", "Code", "Name", "IsActive", "AllowOnboarding", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e273e2ed-5fd3-4564-bb87-09a71cd4779a', 'active', 'Active', true, true, 1, '2026-09-07 06:03:13.27055+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------
-- mst_contact_types  (4 rows)
-- ---------------------------------------------------------------
INSERT INTO mst_contact_types ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('58db2f92-2db9-46a1-ae8a-f04a3c7cf54c', 'legal', 'Legal', true, 4, '2026-09-09 07:39:28.906477+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_contact_types ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('670b9a05-6ee2-488e-962c-51cf3cdb86fa', 'procurement', 'Procurement', true, 2, '2026-09-09 07:39:28.906477+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_contact_types ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('6ddcfdba-7311-4f61-b285-88e09a772497', 'accounts', 'Accounts', true, 1, '2026-09-09 07:39:28.906477+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_contact_types ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('b28647ac-40d2-449e-b90c-b71cbae83f8d', 'technical', 'Technical', true, 3, '2026-09-09 07:39:28.906477+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------
-- mst_contact_designations  (5 rows)
-- ---------------------------------------------------------------
INSERT INTO mst_contact_designations ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('301bc813-b2a8-487e-8645-6d613260a7e7', 'cio', 'CIO', true, 3, '2026-09-09 07:16:02.332706+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_contact_designations ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('36d0dd25-0888-4933-b7ec-1ffb839a50bd', 'cfo', 'CFO', true, 4, '2026-09-09 07:16:02.332706+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_contact_designations ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('4289316a-ac66-4577-93b2-b27a1f631bd7', 'ciso', 'CISO', true, 2, '2026-09-09 07:16:02.332706+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_contact_designations ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('634aee41-eb57-41e4-b296-af2a255a7e79', 'accounts_head', 'Accounts Head', true, 5, '2026-09-09 07:16:02.332706+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_contact_designations ("Id", "Code", "Name", "IsActive", "SortOrder", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('8a02dfd7-d731-4231-8eba-29f36d2254c7', 'spoc', 'SPOC', true, 1, '2026-09-09 07:16:02.332706+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------
-- mst_certifications  (29 rows)
-- ---------------------------------------------------------------
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('0705d913-f281-4559-a5a2-273dcdab4c4c', 'comptia_securityplus', 'CompTIA Security+', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('0ff050bb-aff0-48e2-b3f1-0db0b1e4ff0e', 'certified_in_risk_and_information_systems_control_', 'Certified in Risk and Information Systems Control (CRISC)', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('1277ee68-900e-4989-bdab-ea6c79593dfe', 'blue_team_level_1_and_2', 'Blue Team Level 1 and 2', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('13a1fd79-fc90-4c4d-b392-197e2173c3f0', 'offensive_security_certified_expert_3_(osce3)', 'Offensive Security Certified Expert 3 (OSCE3)', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('2dea8afa-5403-43c9-9a03-45156a3c4198', 'elearnsecurity_certified_threat_hunting_profession', 'eLearnSecurity Certified Threat Hunting Professional (eCTHP)', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('45d2575e-48cc-4593-86f6-1d1884e56abe', 'iso_27001', 'ISO 27001', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('5817ff34-8c14-4679-b368-8d5323ccd31b', 'pnpt', 'PNPT', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('6d67283e-fb84-408e-a151-12ee7ef9b7dd', 'ecppt', 'eCPPT', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('7ab3d38a-323d-49d8-8e0e-83b96e520205', 'certified_cloud_security_professional_(ccsp)', 'Certified Cloud Security Professional (CCSP)', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('7d8276b0-d415-4110-b7ab-2bb718b0396f', 'offensive_security_certified_professional_(oscp)', 'Offensive Security Certified Professional (OSCP)', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('7e8c683c-5fb3-4bdb-8d94-e5fbfcdc2e11', 'certified_threat_intelligence_analyst_(ctia)', 'Certified Threat Intelligence Analyst (CTIA)', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('86e2ff2b-d817-4c93-aa51-51742d727d1b', 'offensive_security_wireless_professional_(oswp)', 'Offensive Security Wireless Professional (OSWP)', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('9b093776-b367-4581-b1a9-a141bf9adcbb', 'elearnsecurity_certified_incident_responder_(ecir)', 'eLearnSecurity Certified Incident Responder (eCIR)', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('a6c8ffd7-3497-4f4c-a651-bd1e6230f945', 'licensed_penetration_tester_(lpt)', 'Licensed Penetration Tester (LPT)', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('aaa594dd-b167-4034-b538-a8ed292825f6', 'offensive_security_experienced_penetration_tester_', 'Offensive Security Experienced Penetration Tester (OSEP)', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ab729e39-7b07-4da9-ba03-d155d93695db', 'certified_ethical_hacker_(ceh)', 'Certified Ethical Hacker (CEH)', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('bef0b76e-c4cd-4c11-8bdc-82ba930c8e51', 'iso_22301', 'ISO 22301', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('c38bd75b-3213-4bcd-9ca1-64ff72f02178', 'crte', 'CRTE', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('c4323823-361f-4ff9-a699-a91b2400f59b', 'crt', 'CRT', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('c4f2e057-5906-4154-83e2-4f009d6af825', 'ec_council_certified_incident_handler_(ecih)', 'EC-Council Certified Incident Handler (ECIH)', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('cc0b6618-17ef-48f6-9280-6e7fa9885b60', 'certified_information_systems_security_professiona', 'Certified Information Systems Security Professional (CISSP)', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('cc7740c3-4189-40e2-86f6-797dacb789c0', 'offsec_foundational_security_operations_and_defens', 'OffSec Foundational Security Operations and Defensive Analysis (OSDA)', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('cf42b7a7-dd8c-4395-880c-a27051408df5', 'certified_information_security_manager_(cism)', 'Certified Information Security Manager (CISM)', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('d79a4f9d-8eb3-48ea-baeb-20de01ea05ce', 'elearnsecurity_certified_digital_forensics_profess', 'eLearnSecurity Certified Digital Forensics Professional (eCDFP)', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('daab1e17-24aa-435f-89a5-8a9e8e5052bf', 'iso_iec_42001', 'ISO/IEC 42001', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e5540bc7-50d2-4d70-a943-acd46aa882c5', 'cpts', 'cPTS', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e5ca396a-d689-4010-a451-39b1b99a7bd2', 'offensive_security_web_expert_(oswe)', 'Offensive Security Web Expert (OSWE)', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ef4cd7da-14f7-4f0d-afd0-99ca3bb6ffe2', 'certified_information_systems_auditor_(cisa)', 'Certified Information Systems Auditor (CISA)', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_certifications ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('fc483ca5-d867-433f-a4d6-bac79879517f', 'crtp', 'CRTP', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------
-- mst_graduation_degrees  (10 rows)
-- ---------------------------------------------------------------
INSERT INTO mst_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('0712499d-fdc0-4a12-8fd7-7284f5531cb3', 'bs', 'BS', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('1dc7caa3-b89b-4246-8217-21c6dd59bf4b', 'bpharm', 'B.Pharm', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('511beb93-c358-41f3-b39b-463910bf94e6', 'bcom', 'B.Com', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('564c3ffb-209d-43bf-ab2f-2ba5d509357e', 'ba', 'B.A.', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('62c3218d-a51e-44ab-8fe0-c57d59270448', 'btech', 'B.Tech', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('82ce8912-9b37-4b6a-864e-a7327f8749cb', 'bba', 'BBA', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('a77f78ff-221e-400c-8b14-0c847b34bc92', 'bsc', 'B.Sc', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ce12fc28-02e3-4f2c-bf7d-53607b188057', 'bca', 'BCA', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e89b166b-ebc0-4132-8170-92ea1e78e9d0', 'be', 'BE', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('09e8e464-0642-466a-8ca4-37f3bc37d4d0', 'be', 'B.E.', true, '2026-09-11 05:28:07.455053+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------
-- mst_post_graduation_degrees  (9 rows)
-- ---------------------------------------------------------------
INSERT INTO mst_post_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('02b11fcf-15dc-438e-857d-fe1df19f925b', 'me', 'ME', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_post_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('29c8b610-bca4-41b7-8199-960c4907c189', 'mba', 'MBA', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_post_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('42343c31-3dfa-44e6-a433-5d0c66dcfaf0', 'na', 'NA', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_post_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('93a0a0ed-91ed-41e3-91c1-09e94f248667', 'mtech', 'M.Tech', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_post_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('9ea82119-8356-4b91-87ea-aeeb679b9cf6', 'msc', 'M.Sc', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_post_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('c7bd4e1d-4826-421d-b473-3a926672050e', 'ma', 'M.A.', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_post_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e0725237-7a46-48ee-9ff1-3969f2571d2a', 'mcom', 'M.Com', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_post_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('e2722a3d-0767-4299-afa9-04d89c28cd7c', 'mca', 'MCA', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO mst_post_graduation_degrees ("Id", "Code", "Name", "IsActive", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc") VALUES ('ec8299cf-acb1-4a26-aed5-a03db0ff8bfe', 'ms', 'MS', true, '2026-09-08 04:59:44.231454+00', NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------
-- roles  (13 rows)
-- ---------------------------------------------------------------
INSERT INTO roles ("Id", "DisplayName", "Permissions", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Name", "Description", "IsActive", "IsSystemRole") VALUES ('34331f88-e6f2-4e48-b6e7-7f6baef11ef9', 'Sales & Business Development', '["dashboard.view", "projects.view", "projects.create", "projects.overview.view", "projects.overview.edit", "projects.health.view", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "customers.create", "customers.edit", "customers.assign", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "clients:write", "projects:write", "wbs:read", "timesheets:submit"]', '2026-08-07 07:49:59.669429+00', '2026-08-10 12:23:35.786937+00', NULL, NULL, NULL, 'Sales', 'Sales & business development ??? new projects and customers.', true, true) ON CONFLICT DO NOTHING;
INSERT INTO roles ("Id", "DisplayName", "Permissions", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Name", "Description", "IsActive", "IsSystemRole") VALUES ('3cdaf36a-c349-4239-8533-df54dbdbb770', 'Team Lead', '["dashboard.view", "projects.view", "projects.task.view", "projects.task.update-status", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "issues:raise", "timesheets:submit"]', '2026-08-07 07:49:59.669429+00', '2026-08-10 12:23:35.786937+00', NULL, NULL, NULL, 'TeamLead', 'Leads a delivery team; submits timesheets and raises issues.', true, true) ON CONFLICT DO NOTHING;
INSERT INTO roles ("Id", "DisplayName", "Permissions", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Name", "Description", "IsActive", "IsSystemRole") VALUES ('915f6e40-9ad3-49f9-bbf5-18375e5b49d5', 'Project Manager', '["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "projects:read", "projects:write", "issues:raise", "timesheets:submit", "timesheets:approve"]', '2026-08-07 07:49:59.669429+00', '2026-08-13 06:42:59.518317+00', NULL, '40517b71-5e62-182e-73b5-d4070e20a3c2', NULL, 'ProjectManager', 'Runs assigned projects end-to-end; approves team timesheets.', true, true) ON CONFLICT DO NOTHING;
INSERT INTO roles ("Id", "DisplayName", "Permissions", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Name", "Description", "IsActive", "IsSystemRole") VALUES ('3de8ba61-fd83-4953-9f9e-11e7450ebccd', 'Admin (Dhanshree)', '["action-center.view", "approvals:manage", "approvals.approve", "approvals.reject", "approvals.view", "audit:read", "clients:approve", "clients:read", "clients:write", "customers.approve", "customers.assign", "customers.create", "customers.delete", "customers.edit", "customers.view", "dashboard.view", "invoices:payment", "invoices:raise", "issues:manage", "issues:raise", "my-team.dashboard.view", "my-team.my-timesheet.edit", "my-team.my-timesheet.submit", "my-team.my-timesheet.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "my-team.timesheet-approval.view", "portfolio.view", "projects:close", "projects:read", "projects:write", "projects.alerts.create", "projects.alerts.resolve", "projects.alerts.view", "projects.approve", "projects.assign", "projects.assigned-projects.view", "projects.budget.view", "projects.close", "projects.communication.create", "projects.communication.view", "projects.create", "projects.delete", "projects.edit", "projects.escalation.create", "projects.escalation.resolve", "projects.escalation.view", "projects.export", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.health-issues.view", "projects.health.comment", "projects.health.edit-issue", "projects.health.manage", "projects.health.raise-issue", "projects.health.resolve-issue", "projects.health.view", "projects.import", "projects.invoice-schedule.manage", "projects.invoice-schedule.view", "projects.overview.edit", "projects.overview.view", "projects.pmo.manage", "projects.pmo.view", "projects.prerequisite.manage", "projects.prerequisite.view", "projects.services-deliverables.manage", "projects.services-deliverables.view", "projects.task.assign", "projects.task.create", "projects.task.edit", "projects.task.update-status", "projects.task.view", "projects.team.assign", "projects.team.view", "projects.view", "reports:read", "reports.export", "reports.finance.view", "reports.view", "repository.view", "resources:manage", "resources:read", "resources.directory.view", "resources.kpi.view", "resources.manage", "resources.view", "roles:manage", "settings.audit.view", "settings.permissions.manage", "settings.permissions.view", "settings.roles.manage", "settings.roles.view", "settings.view", "timesheets:approve", "timesheets:monitor", "timesheets:submit", "users:manage", "wbs:allocate", "wbs:read", "wbs.allocate", "wbs.view"]', '2026-08-07 07:49:59.669429+00', '2026-08-11 06:12:16.314057+00', NULL, '40517b71-5e62-182e-73b5-d4070e20a3c2', NULL, 'Dhanshree', 'Super-admin (legacy account) ??? full access to every module.', true, true) ON CONFLICT DO NOTHING;
INSERT INTO roles ("Id", "DisplayName", "Permissions", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Name", "Description", "IsActive", "IsSystemRole") VALUES ('b7271bbe-68a7-4165-996e-869c030c76d3', 'HOD', '["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health.manage", "projects.health-issues.view", "projects.alerts.view", "projects.escalation.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "customers.approve", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "approvals.view", "approvals.approve", "approvals.reject", "clients:read", "clients:approve", "projects:read", "projects:close", "issues:manage", "timesheets:approve", "approvals:manage", "reports:read"]', '2026-08-07 07:49:59.669429+00', '2026-08-10 12:23:35.786937+00', NULL, NULL, NULL, 'Hod', 'Department oversight across projects, resources and approvals.', true, true) ON CONFLICT DO NOTHING;
INSERT INTO roles ("Id", "DisplayName", "Permissions", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Name", "Description", "IsActive", "IsSystemRole") VALUES ('911d3fd2-2e9a-4a85-a79a-49584031c854', 'HR', '["resources.view", "resources.directory.view", "resources.manage", "repository.view", "resources:manage"]', '2026-08-07 07:49:59.669429+00', '2026-08-11 13:02:20.841494+00', NULL, 'a2ef1e7d-5d70-8e86-f48d-429ce5a745dc', NULL, 'Hr', 'HR resource/directory management only.', true, true) ON CONFLICT DO NOTHING;
INSERT INTO roles ("Id", "DisplayName", "Permissions", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Name", "Description", "IsActive", "IsSystemRole") VALUES ('9a4276e4-ddbf-438c-af7a-b4e123ae8271', 'Employee', '["dashboard.view", "action-center.view", "projects.view", "projects.assigned-projects.view", "projects.task.view", "projects.task.update-status", "resources.view", "resources.directory.view", "repository.view", "my-team.dashboard.view", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.my-timesheet.edit", "timesheets:submit", "issues:raise"]', '2026-08-07 07:49:59.669429+00', '2026-08-10 12:26:35.25597+00', NULL, 'a2ef1e7d-5d70-8e86-f48d-429ce5a745dc', NULL, 'Employee', 'Executes assigned tasks; submits own timesheets.', true, true) ON CONFLICT DO NOTHING;
INSERT INTO roles ("Id", "DisplayName", "Permissions", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Name", "Description", "IsActive", "IsSystemRole") VALUES ('1312980c-d7e6-4394-930e-477a5ae8ece8', 'Business Owner', '["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.health.view", "projects.health-issues.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "portfolio.view", "clients:read", "projects:read", "reports:read"]', '2026-08-07 07:49:59.669429+00', '2026-08-10 12:23:35.786937+00', NULL, NULL, NULL, 'BusinessOwner', 'Executive oversight of the project portfolio.', true, true) ON CONFLICT DO NOTHING;
INSERT INTO roles ("Id", "DisplayName", "Permissions", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Name", "Description", "IsActive", "IsSystemRole") VALUES ('a5023c9e-367f-41e1-ba02-bdb2929edc89', 'Engagement Manager', '["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "clients:read", "projects:read", "projects:write", "issues:raise", "issues:manage", "timesheets:approve"]', '2026-08-07 07:49:59.669429+00', '2026-08-10 12:23:35.786937+00', NULL, NULL, NULL, 'EngagementManager', 'Owns customer relationship and delivery for assigned accounts.', true, true) ON CONFLICT DO NOTHING;
INSERT INTO roles ("Id", "DisplayName", "Permissions", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Name", "Description", "IsActive", "IsSystemRole") VALUES ('da95514a-1975-456d-ad0f-06fe33227e9b', 'Senior Project Manager', '["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "resources.view", "resources.directory.view", "resources.kpi.view", "customers.view", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.reject", "clients:read", "projects:read", "projects:write", "projects:close", "issues:raise", "issues:manage", "timesheets:approve"]', '2026-08-07 07:49:59.669429+00', '2026-08-10 12:23:35.786937+00', NULL, NULL, NULL, 'SeniorPm', 'Owns delivery of assigned projects; approves PM timesheets.', true, true) ON CONFLICT DO NOTHING;
INSERT INTO roles ("Id", "DisplayName", "Permissions", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Name", "Description", "IsActive", "IsSystemRole") VALUES ('fd4ad9b6-dc3e-482b-bc1f-dcdb50a68cde', 'PMO', '["dashboard.view", "action-center.view", "projects.view", "projects.overview.view", "projects.budget.view", "reports.view", "reports.export", "resources.view", "resources.directory.view", "customers.view", "repository.view", "my-team.dashboard.view", "approvals.view", "wbs.view", "wbs.allocate", "clients:read", "projects:read", "wbs:read", "wbs:allocate", "timesheets:monitor", "issues:manage", "resources:read", "reports:read", "approvals:manage"]', '2026-08-07 07:49:59.669429+00', '2026-08-10 12:23:35.786937+00', NULL, NULL, NULL, 'Pmo', 'Governance, WBS allocation and timesheet monitoring (view-oriented).', true, true) ON CONFLICT DO NOTHING;
INSERT INTO roles ("Id", "DisplayName", "Permissions", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Name", "Description", "IsActive", "IsSystemRole") VALUES ('4e1cb2cf-a453-4b80-9ddc-2c6ee042290b', 'Admin', '["dashboard.view", "action-center.view", "projects.view", "projects:read", "projects.create", "projects:write", "projects.edit", "projects:write", "projects.delete", "projects:write", "projects.close", "projects:close", "projects.approve", "projects.assign", "projects.export", "projects.import", "projects.overview.view", "projects.overview.edit", "projects.budget.view", "projects.team.view", "projects.team.assign", "projects.task.view", "projects.task.create", "projects.task.edit", "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue", "issues:raise", "projects.health.edit-issue", "projects.health.resolve-issue", "projects.health.comment", "projects.health.manage", "issues:manage", "projects.health-issues.view", "projects.health-issues.create", "projects.health-issues.edit", "projects.health-issues.resolve", "projects.alerts.view", "projects.alerts.create", "projects.alerts.resolve", "projects.escalation.view", "projects.escalation.create", "projects.escalation.resolve", "projects.communication.view", "projects.communication.create", "projects.pmo.view", "projects.pmo.manage", "projects.prerequisite.view", "projects.prerequisite.manage", "projects.services-deliverables.view", "projects.services-deliverables.manage", "projects.invoice-schedule.view", "projects.invoice-schedule.manage", "invoices:raise", "invoices:payment", "projects.assigned-projects.view", "reports.view", "reports:read", "reports.export", "reports.finance.view", "resources.view", "resources:read", "resources.manage", "resources:manage", "resources.directory.view", "resources.kpi.view", "customers.view", "clients:read", "customers.create", "clients:write", "customers.edit", "clients:write", "customers.delete", "clients:write", "customers.approve", "clients:approve", "customers.assign", "repository.view", "my-team.dashboard.view", "my-team.timesheet-approval.view", "timesheets:monitor", "my-team.timesheet-approval.approve", "timesheets:approve", "my-team.timesheet-approval.reject", "timesheets:approve", "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "timesheets:submit", "my-team.my-timesheet.edit", "wbs.view", "wbs:read", "wbs.allocate", "wbs:allocate", "approvals.view", "approvals:manage", "approvals.approve", "timesheets:approve", "approvals.reject", "timesheets:approve", "portfolio.view", "settings.view", "settings.roles.view", "settings.roles.manage", "roles:manage", "settings.permissions.view", "settings.permissions.manage", "users:manage", "settings.audit.view", "audit:read"]', '2026-08-10 12:23:35.786937+00', '2026-08-10 12:40:14.170813+00', NULL, 'a2ef1e7d-5d70-8e86-f48d-429ce5a745dc', NULL, 'Admin', 'Super-admin ??? full access to every module, submodule and action.', true, true) ON CONFLICT DO NOTHING;
INSERT INTO roles ("Id", "DisplayName", "Permissions", "CreatedAtUtc", "UpdatedAtUtc", "CreatedBy", "UpdatedBy", "DeletedAtUtc", "Name", "Description", "IsActive", "IsSystemRole") VALUES ('cd2a32ed-32fc-47bc-88a9-e6fc48863869', 'Accounts & Finance', '["action-center.view", "clients:read", "customers.view", "dashboard.view", "invoices:payment", "invoices:raise", "projects:read", "projects.health.view", "projects.invoice-schedule.manage", "projects.invoice-schedule.view", "projects.overview.view", "projects.view", "reports:read", "reports.export", "reports.finance.view", "reports.view", "repository.view", "resources:read", "resources.directory.view", "resources.kpi.view", "resources.view"]', '2026-08-07 07:49:59.669429+00', '2026-08-23 16:16:27.401283+00', NULL, 'a2ef1e7d-5d70-8e86-f48d-429ce5a745dc', NULL, 'Accounts', 'Finance ??? invoices, payments and finance reports.', true, true) ON CONFLICT DO NOTHING;

-- =========================================================
-- END OF SCRIPT
-- =========================================================
