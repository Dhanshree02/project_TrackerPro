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

COMMIT;
