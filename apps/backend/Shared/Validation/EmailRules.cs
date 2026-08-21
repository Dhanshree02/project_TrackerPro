namespace PMS.API.Shared.Validation;

/// <summary>
/// Practical email format check used by FluentValidation and services.
/// Trims first. Requires local@domain with a real TLD (name@company.com),
/// not a full RFC regex.
/// </summary>
public static class EmailRules
{
    public const int MaxLength = 255;

    public const string InvalidMessage =
        "Enter a valid email address (for example name@company.com)";

    public static string Normalize(string? value) => (value ?? string.Empty).Trim();

    public static string? NullIfEmpty(string? value)
    {
        var normalized = Normalize(value);
        return normalized.Length == 0 ? null : normalized;
    }

    public static bool IsValid(string? value)
    {
        var email = Normalize(value);
        if (email.Length == 0 || email.Length > MaxLength) return false;
        if (email.Contains(' ') || email.Contains('\t')) return false;

        var at = email.IndexOf('@');
        if (at <= 0 || at != email.LastIndexOf('@') || at == email.Length - 1)
            return false;

        var local = email[..at];
        var domain = email[(at + 1)..];
        if (local.StartsWith('.') || local.EndsWith('.')) return false;
        if (domain.StartsWith('.') || domain.EndsWith('.') || domain.Contains(".."))
            return false;

        var lastDot = domain.LastIndexOf('.');
        if (lastDot <= 0) return false;

        var tld = domain[(lastDot + 1)..];
        if (tld.Length < 2 || !tld.All(char.IsAsciiLetter)) return false;

        foreach (var label in domain.Split('.'))
        {
            if (label.Length == 0) return false;
        }

        return true;
    }
}
