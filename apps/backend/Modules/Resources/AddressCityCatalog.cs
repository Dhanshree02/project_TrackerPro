using System.Text;
using PMS.API.Modules.Resources.Services;

namespace PMS.API.Modules.Resources;

/// <summary>
/// Seed names for <c>master.mst_address_cities</c> and helpers for new rows.
/// </summary>
internal static class AddressCityCatalog
{
    public static IReadOnlyList<string> Names => EmployeeBulkWorkbook.MumbaiStations;

    public static string? LineOf(string name)
    {
        var open = name.LastIndexOf(" (", StringComparison.Ordinal);
        if (open > 0 && name.EndsWith(')'))
            return name[(open + 2)..^1];
        return null;
    }

    /// <summary>
    /// Builds the value stored on the employee. A separate line is appended when the name does not already include it.
    /// </summary>
    public static (string Name, string? Line) Compose(string name, string? line)
    {
        var trimmed = name.Trim();
        var corridor = string.IsNullOrWhiteSpace(line) ? null : line.Trim();
        if (corridor is null)
            corridor = LineOf(trimmed);
        else if (!trimmed.EndsWith($"({corridor})", StringComparison.OrdinalIgnoreCase))
            trimmed = $"{trimmed} ({corridor})";

        if (corridor is not null && corridor.Length > 80)
            corridor = corridor[..80];

        return (trimmed, corridor);
    }

    public static string CodeFor(string name, ISet<string> used)
    {
        var slug = Slug(name);
        if (slug.Length == 0) slug = "city";
        if (slug.Length > 80) slug = slug[..80].TrimEnd('_');

        var code = slug;
        var n = 2;
        while (used.Contains(code))
        {
            var suffix = "_" + n++;
            var stem = slug;
            if (stem.Length + suffix.Length > 80)
                stem = stem[..(80 - suffix.Length)].TrimEnd('_');
            code = stem + suffix;
        }

        used.Add(code);
        return code;
    }

    private static string Slug(string value)
    {
        var builder = new StringBuilder(value.Length);
        foreach (var ch in value.Trim().ToLowerInvariant())
            builder.Append(char.IsLetterOrDigit(ch) ? ch : '_');

        var slug = builder.ToString();
        while (slug.Contains("__", StringComparison.Ordinal))
            slug = slug.Replace("__", "_", StringComparison.Ordinal);
        return slug.Trim('_');
    }
}
