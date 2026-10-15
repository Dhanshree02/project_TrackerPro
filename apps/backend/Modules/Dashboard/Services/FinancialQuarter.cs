namespace PMS.API.Modules.Dashboard.Services;

/// <summary>
/// Company financial year runs 1 April through 31 March.
/// Q1 Apr–Jun, Q2 Jul–Sep, Q3 Oct–Dec, Q4 Jan–Mar of the following calendar year.
/// </summary>
public static class FinancialQuarter
{
    public static readonly string[] Codes = ["Q1", "Q2", "Q3", "Q4"];

    private static readonly string[] MonthLabels =
        ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

    public static bool IsValid(string? quarter) =>
        !string.IsNullOrWhiteSpace(quarter)
        && Codes.Contains(quarter.Trim(), StringComparer.OrdinalIgnoreCase);

    public static int CurrentFinancialYearStart(DateOnly today) =>
        today.Month >= 4 ? today.Year : today.Year - 1;

    public static string CurrentCode(DateOnly today) => today.Month switch
    {
        >= 4 and <= 6 => "Q1",
        >= 7 and <= 9 => "Q2",
        >= 10 and <= 12 => "Q3",
        _ => "Q4",
    };

    /// <summary>
    /// Previous two calendar months plus the month that contains <paramref name="today"/>.
    /// The range crosses quarter and year boundaries.
    /// </summary>
    public static IReadOnlyList<(int Year, int Month, string Label)> RollingMonths(DateOnly today)
    {
        var first = new DateOnly(today.Year, today.Month, 1).AddMonths(-2);
        return Enumerable.Range(0, 3)
            .Select(offset =>
            {
                var date = first.AddMonths(offset);
                return (date.Year, date.Month, MonthLabels[date.Month]);
            })
            .ToArray();
    }

    /// <summary>
    /// Rolling three months unless a financial quarter is selected.
    /// </summary>
    public static (string Code, int FinancialYear, IReadOnlyList<(int Year, int Month, string Label)> Months) Resolve(
        string? period,
        string? quarter,
        int? financialYear,
        DateOnly today)
    {
        var rolling = string.Equals(period?.Trim(), "rolling", StringComparison.OrdinalIgnoreCase)
            || string.IsNullOrWhiteSpace(quarter)
            || !IsValid(quarter);
        if (!rolling && IsValid(quarter))
        {
            var code = quarter!.Trim().ToUpperInvariant();
            var year = financialYear ?? CurrentFinancialYearStart(today);
            return (code, year, Months(code, year));
        }

        var months = RollingMonths(today);
        var end = months[^1];
        return ("ROLLING", CurrentFinancialYearStart(new DateOnly(end.Year, end.Month, 1)), months);
    }

    public static IReadOnlyList<(int Year, int Month, string Label)> Months(string quarter, int financialYearStart)
    {
        var code = quarter.Trim().ToUpperInvariant();
        (int Year, int Month)[] months = code switch
        {
            "Q1" => [(financialYearStart, 4), (financialYearStart, 5), (financialYearStart, 6)],
            "Q2" => [(financialYearStart, 7), (financialYearStart, 8), (financialYearStart, 9)],
            "Q3" => [(financialYearStart, 10), (financialYearStart, 11), (financialYearStart, 12)],
            "Q4" => [(financialYearStart + 1, 1), (financialYearStart + 1, 2), (financialYearStart + 1, 3)],
            _ => throw new ArgumentOutOfRangeException(nameof(quarter), "Quarter must be Q1, Q2, Q3, or Q4."),
        };

        return months.Select(m => (m.Year, m.Month, MonthLabels[m.Month])).ToArray();
    }

    public static DateOnly EndOfMonth(int year, int month) =>
        new(year, month, DateTime.DaysInMonth(year, month));
}
