using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;
using PMS.API.Infrastructure.Authorization;

namespace PMS.API.Infrastructure.Persistence;

/// <summary>
/// Used by <c>dotnet ef migrations</c> / <c>dotnet ef database update</c>.
/// Reads the connection string from appsettings.json (API project).
/// </summary>
public sealed class DesignTimeDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
{
    public AppDbContext CreateDbContext(string[] args)
    {
        var basePath = Directory.GetCurrentDirectory();

        // Walk up from the current directory until appsettings.json is found.
        var apiConfig = new ConfigurationBuilder()
            .SetBasePath(FindApiDirectory(basePath))
            .AddJsonFile("appsettings.json", optional: false)
            .AddJsonFile("appsettings.Development.json", optional: true)
            .AddEnvironmentVariables()
            .Build();

        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseNpgsql(apiConfig.GetConnectionString("DefaultConnection"))
            .Options;

        return new AppDbContext(options, new DesignTimeCurrentUser());
    }

    private static string FindApiDirectory(string start)
    {
        var dir = new DirectoryInfo(start);
        while (dir is not null)
        {
            if (File.Exists(Path.Combine(dir.FullName, "appsettings.json")))
                return dir.FullName;
            dir = dir.Parent;
        }

        throw new DirectoryNotFoundException(
            "Could not locate appsettings.json for the API project. Run EF commands from the solution or API directory.");
    }

    private sealed class DesignTimeCurrentUser : ICurrentUserService
    {
        public Guid? UserId => null;
        public string? Email => null;
        public string? Name => null;
        public string? Role => null;
        public IReadOnlyList<string> Permissions => [];
        public bool HasPermission(string _) => false;
        public System.Security.Claims.ClaimsPrincipal? Principal => null;
    }
}
