using Microsoft.Extensions.Hosting;

namespace PMS.API.Modules.Rbac;

public sealed class RbacBaselineHostedService(IServiceScopeFactory scopes, ILogger<RbacBaselineHostedService> logger) : IHostedService
{
    public async Task StartAsync(CancellationToken cancellationToken)
    {
        using var scope = scopes.CreateScope();
        var rbac = scope.ServiceProvider.GetRequiredService<IRbacAccessService>();
        await rbac.EnsureBaselineAsync(cancellationToken);
        logger.LogInformation("RBAC baseline {Version} is in place.", RbacAccessService.BaselineVersion);
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}
