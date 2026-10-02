namespace PMS.API.Infrastructure.Persistence.Configurations;

/// <summary>
/// Physical PostgreSQL layout. Each module owns a schema.
/// Name prefixes: mst_ catalogs, tbl_ business tables, log_ activity and audit rows,
/// vw_ views, fnc_ functions.
/// </summary>
public static class DbSchemas
{
    public const string Auth = "auth";
    public const string Master = "master";
    public const string Resource = "resource";
    public const string Customer = "customer";
    public const string Project = "project";
    public const string Timesheet = "timesheet";
    public const string Repository = "repository";
}
