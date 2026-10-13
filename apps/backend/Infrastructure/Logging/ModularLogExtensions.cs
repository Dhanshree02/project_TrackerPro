using Serilog;
using Serilog.Configuration;

namespace PMS.API.Infrastructure.Logging;

public static class ModularLogExtensions
{
    public static LoggerConfiguration ModularArchivingFile(
        this LoggerSinkConfiguration sinkConfiguration,
        string logRoot)
    {
        return sinkConfiguration.Sink(new ModularArchivingLogSink(logRoot));
    }
}
