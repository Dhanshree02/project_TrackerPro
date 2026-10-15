namespace PMS.API.Modules.Customers.Services;

/// <summary>
/// Persistent sub-venture identifiers: {ClientCode}-{sequence}, e.g. C013-01.
/// The sequence is scoped to one client and is never reused.
/// </summary>
public static class SubVentureCodes
{
    public static string Format(string clientCode, int sequence)
    {
        if (string.IsNullOrWhiteSpace(clientCode))
            throw new ArgumentException("Client code is required.", nameof(clientCode));
        if (sequence < 1)
            throw new ArgumentOutOfRangeException(nameof(sequence), "Sequence must be at least 1.");
        return $"{clientCode.Trim()}-{sequence.ToString("D2")}";
    }

    public static string? PrefixOf(string? code)
    {
        if (string.IsNullOrWhiteSpace(code)) return null;
        var dash = code.LastIndexOf('-');
        if (dash <= 0) return null;
        return code[..dash];
    }

    public static int ReadSequence(string? code)
    {
        if (string.IsNullOrWhiteSpace(code)) return 0;
        var dash = code.LastIndexOf('-');
        if (dash < 0 || dash >= code.Length - 1) return 0;
        return int.TryParse(code[(dash + 1)..], out var n) ? n : 0;
    }
}
