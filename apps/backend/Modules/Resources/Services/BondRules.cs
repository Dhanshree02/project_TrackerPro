namespace PMS.API.Modules.Resources.Services;

internal static class BondRules
{
    public static DateOnly? ComputeBondExpiry(
        DateOnly? joiningDate,
        string? bondDelivered,
        int? durationMonths)
    {
        if (!IsBondApplicable(bondDelivered)) return null;
        if (joiningDate is null || durationMonths is null or <= 0) return null;
        return joiningDate.Value.AddMonths(durationMonths.Value);
    }

    public static string ComputeBondStatus(string? bondDelivered, DateOnly? expiryDate)
    {
        if (!IsBondApplicable(bondDelivered)) return "No bond";
        if (expiryDate is null) return "No bond";
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        return expiryDate.Value >= today ? "In bond" : "Expired";
    }

    private static bool IsBondApplicable(string? bondDelivered) =>
        string.Equals(bondDelivered?.Trim(), "Yes", StringComparison.OrdinalIgnoreCase);
}
