using Hangfire;
using Hangfire.PostgreSql;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace PMS.API.Infrastructure.Hangfire;

/// <summary>
/// Dependency Injection extensions for Hangfire background job infrastructure.
/// </summary>
public static class HangfireServiceExtensions
{
    public static IServiceCollection AddHangfireInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("ConnectionStrings:DefaultConnection is not configured.");

        var hangfireSection = configuration.GetSection(HangfireOptions.SectionName);
        var options = hangfireSection.Get<HangfireOptions>() ?? new HangfireOptions();

        var workerCount = options.WorkerCount > 0 ? options.WorkerCount : 2;
        var queues = (options.Queues != null && options.Queues.Length > 0)
            ? options.Queues
            : ["default"];
        var pollInterval = TimeSpan.FromSeconds(
            options.PollIntervalSeconds > 0 ? options.PollIntervalSeconds : 15);

        services.Configure<HangfireOptions>(hangfireSection);

        // Configure persistent job storage in dedicated "hangfire" schema
        services.AddHangfire(config =>
        {
            config
                .SetDataCompatibilityLevel(CompatibilityLevel.Version_180)
                .UseSimpleAssemblyNameTypeSerializer()
                .UseRecommendedSerializerSettings()
                .UsePostgreSqlStorage(c => c.UseNpgsqlConnection(connectionString), new PostgreSqlStorageOptions
                {
                    SchemaName = "hangfire",
                    PrepareSchemaIfNecessary = true,
                    QueuePollInterval = pollInterval
                });
        });

        // Register Hangfire server with conservative worker count
        services.AddHangfireServer(serverOptions =>
        {
            serverOptions.WorkerCount = workerCount;
            serverOptions.Queues = queues;
            serverOptions.ServerName = $"ProjectCompass-PMS-{Environment.MachineName}";
        });

        // Register temporary diagnostic job for Phase 1 verification
        services.AddTransient<HangfireDiagnosticJob>();

        return services;
    }
}
