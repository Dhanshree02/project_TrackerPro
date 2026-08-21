namespace PMS.API.Shared.Validation;

/// <summary>
/// Practical Indian phone number format check used by FluentValidation and services.
/// Strips non-digits, leading country code (+91 / 91) or trunk 0.
/// Must be 10 digits starting with 6, 7, 8, or 9, and not all identical repeated digits.
/// </summary>
public static class PhoneRules
{
    public const int MaxLength = 15;

    public const string InvalidMessage =
        "Enter a valid 10-digit Indian mobile number starting with 6, 7, 8, or 9";

    public static string Normalize(string? value)
    {
        if (string.IsNullOrWhiteSpace(value)) return string.Empty;
        var digits = new string(value.Where(char.IsAsciiDigit).ToArray());
        if (digits.StartsWith("91") && digits.Length > 10) digits = digits[2..];
        if (digits.StartsWith("0") && digits.Length == 11) digits = digits[1..];
        return digits.Length > 10 ? digits[..10] : digits;
    }

    public static string? NullIfEmpty(string? value)
    {
        var normalized = Normalize(value);
        return normalized.Length == 0 ? null : normalized;
    }

    public static bool IsValid(string? value)
    {
        if (string.IsNullOrWhiteSpace(value)) return true;
        var digits = Normalize(value);
        if (digits.Length != 10) return false;
        if (digits[0] is not ('6' or '7' or '8' or '9')) return false;
        if (digits.Distinct().Count() == 1) return false;
        return true;
    }
}
