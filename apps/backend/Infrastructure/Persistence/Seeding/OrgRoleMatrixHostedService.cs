using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using PMS.API.Infrastructure.Persistence;

namespace PMS.API.Infrastructure.Persistence.Seeding;

/// <summary>
/// Always aligns on-floor / RBAC mapping from <c>docs/rbac.xlsx</c>,
/// including UAT stacks that keep <c>Database:AutoMigrate=false</c>.
/// </summary>
public sealed class OrgRoleMatrixHostedService(
    IServiceScopeFactory scopeFactory,
    ILogger<OrgRoleMatrixHostedService> logger) : IHostedService
{
    public async Task StartAsync(CancellationToken cancellationToken)
    {
        for (var attempt = 1; attempt <= 8; attempt++)
        {
            try
            {
                using var scope = scopeFactory.CreateScope();
                var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

                await db.Database.ExecuteSqlRawAsync(
                    """
                    CREATE SEQUENCE IF NOT EXISTS action.tbl_notifications_number_seq;

                    ALTER TABLE action.tbl_notifications 
                    ADD COLUMN IF NOT EXISTS "NotificationNumber" integer;

                    DO $$
                    BEGIN
                        IF EXISTS (SELECT 1 FROM action.tbl_notifications WHERE "NotificationNumber" IS NULL) THEN
                            WITH ranked AS (
                                SELECT "Id", ROW_NUMBER() OVER (ORDER BY "CreatedAtUtc" ASC, "Id" ASC) as rn
                                FROM action.tbl_notifications
                            )
                            UPDATE action.tbl_notifications n
                            SET "NotificationNumber" = r.rn
                            FROM ranked r
                            WHERE n."Id" = r."Id" AND n."NotificationNumber" IS NULL;

                            PERFORM setval('action.tbl_notifications_number_seq', COALESCE((SELECT MAX("NotificationNumber") FROM action.tbl_notifications), 0) + 1, false);
                        END IF;
                    END $$;

                    ALTER TABLE action.tbl_notifications 
                    ALTER COLUMN "NotificationNumber" SET DEFAULT nextval('action.tbl_notifications_number_seq');

                    ALTER TABLE action.tbl_notifications 
                    ADD COLUMN IF NOT EXISTS "ServiceEscalationId" uuid;

                    CREATE INDEX IF NOT EXISTS "IX_tbl_notifications_ServiceEscalationId"
                    ON action.tbl_notifications ("ServiceEscalationId")
                    WHERE "DeletedAtUtc" IS NULL;

                    DO $$
                    BEGIN
                        IF NOT EXISTS (
                            SELECT 1 FROM pg_constraint WHERE conname = 'FK_tbl_notifications_tbl_project_service_escalations'
                        ) THEN
                            ALTER TABLE action.tbl_notifications
                            ADD CONSTRAINT "FK_tbl_notifications_tbl_project_service_escalations"
                            FOREIGN KEY ("ServiceEscalationId") 
                            REFERENCES project.tbl_project_service_escalations("Id") 
                            ON DELETE SET NULL;
                        END IF;
                    END $$;

                    -- Backfill ServiceEscalationId for WBS notifications matching project alerts
                    UPDATE action.tbl_notifications n
                    SET "ServiceEscalationId" = a."ServiceEscalationId"
                    FROM project.tbl_project_alerts a
                    WHERE n."ServiceEscalationId" IS NULL
                      AND a."ServiceEscalationId" IS NOT NULL
                      AND n."ProjectId" = a."ProjectId"
                      AND (n."Type" = 'WBS Escalation' OR n."Title" LIKE '%WBS Escalation%');

                    -- Backfill ServiceEscalationId from project service escalations directly if still null
                    UPDATE action.tbl_notifications n
                    SET "ServiceEscalationId" = e."Id"
                    FROM project.tbl_project_service_escalations e
                    WHERE n."ServiceEscalationId" IS NULL
                      AND n."ProjectId" = e."ProjectId"
                      AND (n."Type" = 'WBS Escalation' OR n."Title" LIKE '%WBS Escalation%');
                    """, cancellationToken);

                logger.LogInformation("Applying sidebar modules and docs/rbac.xlsx mapping…");
                await ModuleCatalogSync.EnsureAsync(db, cancellationToken);
                await OrgRoleMatrixSync.ApplyAsync(db, cancellationToken);
                logger.LogInformation("On-floor and RBAC mapping is in place.");
                return;
            }
            catch (Exception ex) when (attempt < 8)
            {
                logger.LogWarning(ex, "On-floor mapping sync failed (attempt {Attempt}/8). Retrying…", attempt);
                await Task.Delay(TimeSpan.FromSeconds(2), cancellationToken);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "On-floor mapping sync failed. API will keep running.");
            }
        }
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}
