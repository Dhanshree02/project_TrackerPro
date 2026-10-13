using System.Collections.Concurrent;
using System.Text;
using Serilog.Configuration;
using Serilog.Core;
using Serilog.Events;

namespace PMS.API.Infrastructure.Logging;

public class ModularArchivingLogSink : ILogEventSink
{
    private readonly string _logRoot;
    private readonly object _lock = new();

    public ModularArchivingLogSink(string logRoot)
    {
        _logRoot = logRoot;
        Directory.CreateDirectory(_logRoot);
    }

    public void Emit(LogEvent logEvent)
    {
        try
        {
            var now = DateTime.UtcNow;
            var sourceContext = GetStringProperty(logEvent, "SourceContext") ?? string.Empty;
            var requestPath = GetStringProperty(logEvent, "RequestPath") ?? string.Empty;
            var explicitModule = GetStringProperty(logEvent, "Module");
            var isClientLog = logEvent.Properties.ContainsKey("IsFrontend") ||
                              sourceContext.Equals("FrontendLogger", StringComparison.OrdinalIgnoreCase);

            var isDbLog = sourceContext.StartsWith("Microsoft.EntityFrameworkCore", StringComparison.OrdinalIgnoreCase) ||
                          sourceContext.StartsWith("Npgsql", StringComparison.OrdinalIgnoreCase);

            var module = explicitModule ?? ResolveModule(sourceContext, requestPath);

            var formattedMessage = FormatLogEntry(logEvent, now, sourceContext);

            lock (_lock)
            {
                if (isDbLog)
                {
                    // 1. All DB logs go to Log/Database/
                    WriteToFolder("Database", "database", now, formattedMessage);

                    // 2. If associated with a specific module, also copy to Log/{Module}/db/
                    if (!string.IsNullOrEmpty(module) && !module.Equals("System", StringComparison.OrdinalIgnoreCase))
                    {
                        WriteToFolder(Path.Combine(module, "db"), $"{module.ToLowerInvariant()}_db", now, formattedMessage);
                    }
                }
                else if (isClientLog)
                {
                    // Frontend logs go to Log/{Module}/frontend/
                    WriteToFolder(Path.Combine(module, "frontend"), $"{module.ToLowerInvariant()}_frontend", now, formattedMessage);
                }
                else
                {
                    // Backend logs go to Log/{Module}/backend/
                    WriteToFolder(Path.Combine(module, "backend"), $"{module.ToLowerInvariant()}_backend", now, formattedMessage);
                }
            }
        }
        catch
        {
            // Logging sink should never crash the main application thread
        }
    }

    private void WriteToFolder(string subDirectory, string filePrefix, DateTime now, string content)
    {
        var targetDir = Path.Combine(_logRoot, subDirectory);
        Directory.CreateDirectory(targetDir);

        var archiveDir = Path.Combine(targetDir, "archive");
        Directory.CreateDirectory(archiveDir);

        // Perform archive rotation: ensure ONLY today's file remains in targetDir
        var todaySuffix = now.ToString("yyyy-MM-dd");
        var activeFileName = $"{filePrefix}_{todaySuffix}.log";
        var activeFilePath = Path.Combine(targetDir, activeFileName);

        // Move any previous date log files to archive/
        var existingLogFiles = Directory.GetFiles(targetDir, $"{filePrefix}_*.log");
        foreach (var file in existingLogFiles)
        {
            var fileName = Path.GetFileName(file);
            if (!fileName.Equals(activeFileName, StringComparison.OrdinalIgnoreCase))
            {
                var destination = Path.Combine(archiveDir, fileName);
                try
                {
                    if (File.Exists(destination))
                    {
                        File.AppendAllText(destination, File.ReadAllText(file));
                        File.Delete(file);
                    }
                    else
                    {
                        File.Move(file, destination);
                    }
                }
                catch
                {
                    // Best effort move
                }
            }
        }

        File.AppendAllText(activeFilePath, content, Encoding.UTF8);
    }

    private static string FormatLogEntry(LogEvent logEvent, DateTime now, string sourceContext)
    {
        var sb = new StringBuilder();
        sb.Append($"[{now:dd-MM-yyyy HH:mm:ss.fff}] ");
        sb.Append($"[{logEvent.Level.ToString().ToUpperInvariant()}] ");

        if (!string.IsNullOrEmpty(sourceContext))
        {
            var shortContext = sourceContext.Split('.').Last();
            sb.Append($"[{shortContext}] ");
        }

        sb.AppendLine(logEvent.RenderMessage());

        if (logEvent.Exception != null)
        {
            sb.AppendLine("Exception:");
            sb.AppendLine(logEvent.Exception.ToString());
        }

        return sb.ToString();
    }

    private static string ResolveModule(string sourceContext, string requestPath)
    {
        var path = requestPath.ToLowerInvariant();
        var context = sourceContext.ToLowerInvariant();

        if (path.Contains("/employee") || path.Contains("/resource") || context.Contains("resource") || context.Contains("employee"))
            return "Resources";

        if (path.Contains("/client") || path.Contains("/customer") || context.Contains("customer") || context.Contains("client"))
            return "Customers";

        if (path.Contains("/project") || context.Contains("project") || context.Contains("wbs"))
            return "Projects";

        if (path.Contains("/timesheet") || context.Contains("timesheet"))
            return "Timesheets";

        if (path.Contains("/catalog") || context.Contains("catalog"))
            return "Catalogs";

        if (path.Contains("/my-team") || path.Contains("/myteam") || context.Contains("myteam"))
            return "MyTeam";

        if (path.Contains("/user") || path.Contains("/role") || path.Contains("/rbac") || context.Contains("user") || context.Contains("rbac"))
            return "Users";

        return "System";
    }

    private static string? GetStringProperty(LogEvent logEvent, string propertyName)
    {
        if (logEvent.Properties.TryGetValue(propertyName, out var value) &&
            value is ScalarValue scalar &&
            scalar.Value != null)
        {
            return scalar.Value.ToString();
        }

        return null;
    }
}
