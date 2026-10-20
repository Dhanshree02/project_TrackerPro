using Microsoft.Extensions.Hosting;

namespace PMS.API.Modules.Rbac;

public sealed class RbacBaselineHostedService(IServiceScopeFactory scopes, ILogger<RbacBaselineHostedService> logger) : IHostedService
{
    public async Task StartAsync(CancellationToken cancellationToken)
    {
        for (var attempt = 1; attempt <= 8; attempt++)
        {
            try
            {
                using var scope = scopes.CreateScope();
                var rbac = scope.ServiceProvider.GetRequiredService<IRbacAccessService>();
                await rbac.EnsureBaselineAsync(cancellationToken);
                logger.LogInformation("RBAC catalog is in place.");
                return;
            }
            catch (Exception ex) when (attempt < 8)
            {
                logger.LogWarning(ex, "RBAC catalog sync failed (attempt {Attempt}/8). Retrying…", attempt);
                await Task.Delay(TimeSpan.FromSeconds(2), cancellationToken);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "RBAC catalog sync failed. API will keep running.");
            }
        }
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}
