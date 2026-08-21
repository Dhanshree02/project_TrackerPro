namespace PMS.API.Configuration;

/// <summary>
/// Loads KEY=VALUE pairs from a <c>.env</c> file into process environment
/// variables when the key is not already set. Called before
/// <see cref="WebApplication.CreateBuilder"/> so ASP.NET configuration picks them up.
/// </summary>
public static class DotEnvLoader
{
    public static void Load()
    {
        foreach (var path in DiscoverEnvFiles())
            LoadFile(path);
    }

    private static IEnumerable<string> DiscoverEnvFiles()
    {
        var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var start in new[] { Directory.GetCurrentDirectory(), AppContext.BaseDirectory })
        {
            for (var dir = new DirectoryInfo(start); dir is not null; dir = dir.Parent)
            {
                var candidate = Path.Combine(dir.FullName, ".env");
                if (seen.Add(candidate) && File.Exists(candidate))
                    yield return candidate;
            }
        }
    }

    private static void LoadFile(string path)
    {
        foreach (var raw in File.ReadAllLines(path))
        {
            var line = raw.Trim();
            if (line.Length == 0 || line.StartsWith('#')) continue;

            var eq = line.IndexOf('=');
            if (eq <= 0) continue;

            var key = line[..eq].Trim();
            var value = Unquote(line[(eq + 1)..].Trim());
            if (key.Length == 0) continue;

            if (string.IsNullOrEmpty(Environment.GetEnvironmentVariable(key)))
                Environment.SetEnvironmentVariable(key, value);
        }
    }

    private static string Unquote(string value)
    {
        if (value.Length >= 2 &&
            ((value[0] == '"' && value[^1] == '"') || (value[0] == '\'' && value[^1] == '\'')))
        {
            return value[1..^1];
        }

        var comment = value.IndexOf(" #", StringComparison.Ordinal);
        return comment >= 0 ? value[..comment].Trim() : value;
    }
}
