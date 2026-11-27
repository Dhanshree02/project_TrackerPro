-- Idempotent schema update for production.
-- Adds missing columns and widens project alert type. Existing rows stay in place.
-- Safe to run more than once.

BEGIN;

ALTER TABLE auth.tbl_role_permissions
    ADD COLUMN IF NOT EXISTS "DefaultCanManage" smallint NOT NULL DEFAULT 0;
ALTER TABLE auth.tbl_role_permissions
    ADD COLUMN IF NOT EXISTS "DefaultCanView" smallint NOT NULL DEFAULT 0;

ALTER TABLE project.tbl_project_alerts
    ALTER COLUMN "AlertType" TYPE character varying(100);

ALTER TABLE resource.tbl_employees
    ADD COLUMN IF NOT EXISTS "OriginalRole" character varying(80);

ALTER TABLE action.tbl_notifications
    ADD COLUMN IF NOT EXISTS "NotificationNumber" integer;
ALTER TABLE action.tbl_notifications
    ADD COLUMN IF NOT EXISTS "ServiceEscalationId" uuid;

CREATE SEQUENCE IF NOT EXISTS action.tbl_notifications_number_seq;

WITH ranked AS (
    SELECT "Id",
           COALESCE((SELECT MAX("NotificationNumber") FROM action.tbl_notifications), 0)
           + ROW_NUMBER() OVER (ORDER BY "CreatedAtUtc" ASC, "Id" ASC) AS rn
    FROM action.tbl_notifications
    WHERE "NotificationNumber" IS NULL
)
UPDATE action.tbl_notifications n
SET "NotificationNumber" = r.rn
FROM ranked r
WHERE n."Id" = r."Id";

SELECT setval(
    'action.tbl_notifications_number_seq',
    COALESCE((SELECT MAX("NotificationNumber") FROM action.tbl_notifications), 0) + 1,
    false);

ALTER TABLE action.tbl_notifications
    ALTER COLUMN "NotificationNumber" SET DEFAULT nextval('action.tbl_notifications_number_seq');
ALTER TABLE action.tbl_notifications
    ALTER COLUMN "NotificationNumber" SET NOT NULL;

CREATE INDEX IF NOT EXISTS "IX_tbl_notifications_ServiceEscalationId"
    ON action.tbl_notifications ("ServiceEscalationId");

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'FK_tbl_notifications_tbl_project_service_escalations'
    ) THEN
        ALTER TABLE action.tbl_notifications
            ADD CONSTRAINT "FK_tbl_notifications_tbl_project_service_escalations"
            FOREIGN KEY ("ServiceEscalationId")
            REFERENCES project.tbl_project_service_escalations ("Id")
            ON DELETE SET NULL;
    END IF;
END $$;

INSERT INTO public."__EFMigrationsHistory" ("MigrationId", "ProductVersion")
SELECT '20261122074055_WidenProjectAlertType', '10.0.4'
WHERE NOT EXISTS (
    SELECT 1 FROM public."__EFMigrationsHistory"
    WHERE "MigrationId" = '20261122074055_WidenProjectAlertType'
);

ALTER TABLE project.tbl_project_team_members
    ADD COLUMN IF NOT EXISTS "IsCurrentlyWorking" boolean NOT NULL DEFAULT true;

ALTER TABLE project.tbl_resource_allocation_requests
    ADD COLUMN IF NOT EXISTS "RequiresPmoApproval" boolean NOT NULL DEFAULT false;

ALTER TABLE master.mst_contact_types
    ADD COLUMN IF NOT EXISTS "Description" character varying(300);

CREATE TABLE IF NOT EXISTS master.mst_screen_options (
    "Id" uuid NOT NULL,
    "Category" character varying(80) NOT NULL,
    "Name" character varying(200) NOT NULL,
    "ParentName" character varying(200) NOT NULL DEFAULT '',
    "SortOrder" integer NOT NULL DEFAULT 0,
    "IsActive" boolean NOT NULL DEFAULT true,
    "CreatedAtUtc" timestamp with time zone NOT NULL DEFAULT now(),
    "UpdatedAtUtc" timestamp with time zone,
    "CreatedBy" uuid,
    "UpdatedBy" uuid,
    "DeletedAtUtc" timestamp with time zone,
    CONSTRAINT "PK_mst_screen_options" PRIMARY KEY ("Id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_screen_options_Category_Name_Parent"
    ON master.mst_screen_options ("Category", "Name", "ParentName")
    WHERE "DeletedAtUtc" IS NULL;

INSERT INTO public."__EFMigrationsHistory" ("MigrationId", "ProductVersion")
SELECT '20261123140000_AddAllocationWorkingAndPmoRoute', '10.0.4'
WHERE NOT EXISTS (
    SELECT 1 FROM public."__EFMigrationsHistory"
    WHERE "MigrationId" = '20261123140000_AddAllocationWorkingAndPmoRoute'
);

-- Baseline View+Manage on Projects & Project Detail for Sales Manager and Sales team member
UPDATE auth.tbl_role_permissions rp
SET "CanView" = 1,
    "CanManage" = 1,
    "DefaultCanView" = 1,
    "DefaultCanManage" = 1,
    "UpdatedAtUtc" = now()
FROM auth.tbl_roles r
WHERE rp."RoleId" = r."Id"
  AND r."Name" IN ('Sales Manager', 'Sales team member')
  AND rp."ItemId" IN (
      '168b1296-de6a-4f9e-a3b9-617b83863736'::uuid,
      'b8f7c125-0e5b-4e3d-98e3-542638fa0b21'::uuid
  );

INSERT INTO auth.tbl_role_permissions (
    "Id", "RoleId", "ItemId", "ItemType",
    "CanView", "CanManage", "DefaultCanView", "DefaultCanManage",
    "CreatedAtUtc"
)
SELECT
    md5(r."Id"::text || ':' || v."ItemId"::text)::uuid,
    r."Id",
    v."ItemId",
    v."ItemType",
    1, 1, 1, 1,
    now()
FROM auth.tbl_roles r
CROSS JOIN (
    VALUES
        ('168b1296-de6a-4f9e-a3b9-617b83863736'::uuid, 'module'),
        ('b8f7c125-0e5b-4e3d-98e3-542638fa0b21'::uuid, 'submodule')
) AS v("ItemId", "ItemType")
WHERE r."Name" IN ('Sales Manager', 'Sales team member')
  AND NOT EXISTS (
      SELECT 1 FROM auth.tbl_role_permissions rp
      WHERE rp."RoleId" = r."Id" AND rp."ItemId" = v."ItemId"
  );

COMMIT;
