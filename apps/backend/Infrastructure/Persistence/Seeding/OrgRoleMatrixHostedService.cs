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
