using Npgsql;

namespace PMS.API.Infrastructure.Persistence;

public static class DatabaseSyncHelper
{
    private static bool _initialized;
    private static bool _isPrimaryPmsUat;

    public static bool IsPrimaryPmsUat
    {
        get
        {
            if (!_initialized)
            {
                var connStr = Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection");
                Initialize(connStr);
            }
            return _isPrimaryPmsUat;
        }
    }

    public static void Initialize(string? connectionString)
    {
        _initialized = true;
        if (string.IsNullOrWhiteSpace(connectionString)) return;

        try
        {
            var csb = new NpgsqlConnectionStringBuilder(connectionString);
            _isPrimaryPmsUat = string.Equals(csb.Database, "pms_uat", StringComparison.OrdinalIgnoreCase);
        }
        catch
        {
            _isPrimaryPmsUat = connectionString.Contains("Database=pms_uat", StringComparison.OrdinalIgnoreCase);
        }
    }
}
