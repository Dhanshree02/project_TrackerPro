using Microsoft.EntityFrameworkCore;
using PMS.API.Modules.Catalogs.Models;
using PMS.API.Modules.Resources.Models;

namespace PMS.API.Infrastructure.Persistence.Seeding;

/// <summary>
/// Inserts the choice lists the screens used to keep in code, once each.
/// A row that was removed in Settings is not put back.
/// </summary>
public static class ScreenOptionSeed
{
    private static readonly (string Category, string Name, string Parent, int Sort)[] Rows =
    [
        (ScreenOptionCategory.WorkerType, "Permanent", "", 1),
        (ScreenOptionCategory.WorkerType, "Contract", "", 2),
        (ScreenOptionCategory.WorkerType, "Intern", "", 3),

        (ScreenOptionCategory.BondDelivered, "Yes", "", 1),
        (ScreenOptionCategory.BondDelivered, "No", "", 2),

        (ScreenOptionCategory.ExperienceType, "Fresher", "", 1),
        (ScreenOptionCategory.ExperienceType, "Experienced", "", 2),

        (ScreenOptionCategory.BillableStatus, "Billable", "", 1),
        (ScreenOptionCategory.BillableStatus, "Non-Billable", "", 2),

        (ScreenOptionCategory.BillingMedium, "Portal Based", "", 1),
        (ScreenOptionCategory.BillingMedium, "Manual Based", "", 2),

        (ScreenOptionCategory.EmployeeProjectType, "Long Term", "", 1),
        (ScreenOptionCategory.EmployeeProjectType, "Short Term", "", 2),

        (ScreenOptionCategory.WbsProjectType, "Long Term", "Resource", 1),
        (ScreenOptionCategory.WbsProjectType, "Short term (Ad-hoc)", "Scope", 1),
        (ScreenOptionCategory.WbsProjectType, "Long Term", "Scope", 2),

        (ScreenOptionCategory.BillingModel, "100% Advance", "Short term (Ad-hoc)", 1),
        (ScreenOptionCategory.BillingModel, "70% Advance + 30% on Delivery", "Short term (Ad-hoc)", 2),
        (ScreenOptionCategory.BillingModel, "50% Advance + 50% on Delivery", "Short term (Ad-hoc)", 3),
        (ScreenOptionCategory.BillingModel, "Custom", "Short term (Ad-hoc)", 4),
        (ScreenOptionCategory.BillingModel, "Monthly Arrears", "Long Term", 1),
        (ScreenOptionCategory.BillingModel, "Monthly Advance", "Long Term", 2),
        (ScreenOptionCategory.BillingModel, "Quarterly Arrears", "Long Term", 3),
        (ScreenOptionCategory.BillingModel, "Quarterly Advance", "Long Term", 4),

        (ScreenOptionCategory.PaymentTerm, "100% Before Project Start", "100% Advance", 1),
        (ScreenOptionCategory.PaymentTerm, "70% Advance", "70% Advance + 30% on Delivery", 1),
        (ScreenOptionCategory.PaymentTerm, "30% on Final Delivery", "70% Advance + 30% on Delivery", 2),
        (ScreenOptionCategory.PaymentTerm, "50% Advance", "50% Advance + 50% on Delivery", 1),
        (ScreenOptionCategory.PaymentTerm, "50% on Final Delivery", "50% Advance + 50% on Delivery", 2),
        (ScreenOptionCategory.PaymentTerm, "End of Each Month", "Monthly Arrears", 1),
        (ScreenOptionCategory.PaymentTerm, "Start of Each Month", "Monthly Advance", 1),
        (ScreenOptionCategory.PaymentTerm, "End of Each Quarter", "Quarterly Arrears", 1),
        (ScreenOptionCategory.PaymentTerm, "Start of Each Quarter", "Quarterly Advance", 1),
        (ScreenOptionCategory.PaymentTerm, "Custom Terms", "Custom", 1),
    ];

    public static async Task EnsureSchemaAsync(AppDbContext db, CancellationToken ct = default)
    {
        var contactTypes = db.TableName<MstContactType>();
        var screenOptions = db.TableName<MstScreenOption>();
        await db.Database.ExecuteSqlRawAsync(
            $"""ALTER TABLE {contactTypes} ADD COLUMN IF NOT EXISTS "Description" character varying(300);""",
            ct);
        await db.Database.ExecuteSqlRawAsync(
            $"""
            CREATE TABLE IF NOT EXISTS {screenOptions} (
                "Id" uuid NOT NULL,
                "Category" character varying(80) NOT NULL,
                "Name" character varying(200) NOT NULL,
                "ParentName" character varying(200) NOT NULL DEFAULT '',
                "SortOrder" integer NOT NULL DEFAULT 0,
                "IsActive" boolean NOT NULL DEFAULT true,
                "CreatedAtUtc" timestamp with time zone NOT NULL DEFAULT now(),
                "UpdatedAtUtc" timestamp with time zone,
                "CreatedBy" uuid,
                "UpdatedBy" uuid,
                "DeletedAtUtc" timestamp with time zone,
                CONSTRAINT "PK_mst_screen_options" PRIMARY KEY ("Id")
            );
            """,
            ct);
        await db.Database.ExecuteSqlRawAsync(
            $"""
            CREATE UNIQUE INDEX IF NOT EXISTS "IX_mst_screen_options_Category_Name_Parent"
                ON {screenOptions} ("Category", "Name", "ParentName")
                WHERE "DeletedAtUtc" IS NULL;
            """,
            ct);
    }

    public static async Task EnsureAsync(AppDbContext db, CancellationToken ct = default)
    {
        var existing = await db.ScreenOptions
            .IgnoreQueryFilters()
            .Select(row => new { row.Category, row.Name, row.ParentName })
            .ToListAsync(ct);

        var known = existing
            .Select(row => Key(row.Category, row.Name, row.ParentName))
            .ToHashSet(StringComparer.OrdinalIgnoreCase);

        var missing = Rows
            .Where(row => !known.Contains(Key(row.Category, row.Name, row.Parent)))
            .Select(row => new MstScreenOption
            {
                Category = row.Category,
                Name = row.Name,
                ParentName = row.Parent,
                SortOrder = row.Sort,
                IsActive = true,
            })
            .ToList();

        if (missing.Count == 0) return;

        db.ScreenOptions.AddRange(missing);
        await db.SaveChangesAsync(ct);
    }

    private static string Key(string category, string name, string parent) =>
        $"{category}\u001f{name.Trim()}\u001f{parent.Trim()}";
}
