using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Resources.DTOs;
using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Exceptions;
using PMS.API.Shared.Validation;

namespace PMS.API.Modules.Resources.Services;

internal sealed record EmployeeIdentity(
    string? EmployeeCode,
    string? WorkEmail,
    string? PersonalEmail,
    string? Phone,
    string? AltPhone,
    string? Pan,
    string? Aadhaar,
    string? PfUan);

internal sealed class EmployeeIdentitySnapshot
{
    private readonly HashSet<string> _codes = new(StringComparer.OrdinalIgnoreCase);
    private readonly HashSet<string> _emails = new(StringComparer.OrdinalIgnoreCase);
    private readonly HashSet<string> _phones = new(StringComparer.OrdinalIgnoreCase);
    private readonly HashSet<string> _pans = new(StringComparer.OrdinalIgnoreCase);
    private readonly HashSet<string> _aadhaars = new(StringComparer.OrdinalIgnoreCase);
    private readonly HashSet<string> _uans = new(StringComparer.OrdinalIgnoreCase);

    public void Add(EmployeeIdentity identity)
    {
        if (!string.IsNullOrWhiteSpace(identity.EmployeeCode))
            _codes.Add(identity.EmployeeCode.Trim());
        AddEmail(identity.WorkEmail);
        AddEmail(identity.PersonalEmail);
        AddPhone(identity.Phone);
        AddPhone(identity.AltPhone);
        if (!string.IsNullOrWhiteSpace(identity.Pan))
            _pans.Add(identity.Pan);
        if (!string.IsNullOrWhiteSpace(identity.Aadhaar))
            _aadhaars.Add(identity.Aadhaar);
        if (!string.IsNullOrWhiteSpace(identity.PfUan))
            _uans.Add(identity.PfUan);
    }

    public IReadOnlyList<string> Conflicts(EmployeeIdentity identity)
    {
        var conflicts = new List<string>();

        if (!string.IsNullOrWhiteSpace(identity.WorkEmail)
            && !string.IsNullOrWhiteSpace(identity.PersonalEmail)
            && string.Equals(identity.WorkEmail, identity.PersonalEmail, StringComparison.OrdinalIgnoreCase))
        {
            conflicts.Add("Personal email should be different from work email.");
        }

        if (!string.IsNullOrWhiteSpace(identity.Phone)
            && !string.IsNullOrWhiteSpace(identity.AltPhone)
            && identity.Phone == identity.AltPhone)
        {
            conflicts.Add("Alternate phone should be different from mobile number.");
        }

        if (!string.IsNullOrWhiteSpace(identity.EmployeeCode) && _codes.Contains(identity.EmployeeCode.Trim()))
            conflicts.Add("This employee ID already exists.");
        if (!string.IsNullOrWhiteSpace(identity.WorkEmail) && _emails.Contains(identity.WorkEmail))
            conflicts.Add("This work email already exists in the database.");
        if (!string.IsNullOrWhiteSpace(identity.PersonalEmail) && _emails.Contains(identity.PersonalEmail))
            conflicts.Add("This personal email already exists in the database.");
        if (!string.IsNullOrWhiteSpace(identity.Phone) && _phones.Contains(identity.Phone))
            conflicts.Add("This phone number already exists in the database.");
        if (!string.IsNullOrWhiteSpace(identity.AltPhone) && _phones.Contains(identity.AltPhone))
            conflicts.Add("This alternate phone number already exists in the database.");
        if (!string.IsNullOrWhiteSpace(identity.Pan) && _pans.Contains(identity.Pan))
            conflicts.Add("This PAN number already exists in the database.");
        if (!string.IsNullOrWhiteSpace(identity.Aadhaar) && _aadhaars.Contains(identity.Aadhaar))
            conflicts.Add("This Aadhaar number already exists in the database.");
        if (!string.IsNullOrWhiteSpace(identity.PfUan) && _uans.Contains(identity.PfUan))
            conflicts.Add("This UAN number already exists in the database.");

        return conflicts;
    }

    private void AddEmail(string? email)
    {
        if (!string.IsNullOrWhiteSpace(email))
            _emails.Add(email);
    }

    private void AddPhone(string? phone)
    {
        if (!string.IsNullOrWhiteSpace(phone))
            _phones.Add(phone);
    }
}

internal static class EmployeeIdentityGuard
{
    public static string? NormalizeEmail(string? value)
    {
        var normalized = EmailRules.NullIfEmpty(value);
        return normalized?.ToLowerInvariant();
    }

    public static string? NormalizePan(string? value)
    {
        var trimmed = value?.Trim().ToUpperInvariant();
        return string.IsNullOrWhiteSpace(trimmed) ? null : trimmed;
    }

    public static string? NormalizeAadhaar(string? value)
    {
        if (string.IsNullOrWhiteSpace(value)) return null;
        var digits = new string(value.Where(char.IsAsciiDigit).ToArray());
        return digits.Length == 0 ? null : digits;
    }

    public static string? NormalizeUan(string? value) => NormalizeAadhaar(value);

    public static EmployeeIdentity FromRequest(CreateEmployeeRequest request) => new(
        request.EmployeeCode.Trim(),
        NormalizeEmail(request.WorkEmail),
        NormalizeEmail(request.PersonalEmail),
        PhoneRules.NullIfEmpty(request.Phone),
        PhoneRules.NullIfEmpty(request.AltPhone),
        NormalizePan(request.Pan),
        NormalizeAadhaar(request.Aadhaar),
        NormalizeUan(request.PfUan));

    public static EmployeeIdentity FromEntity(Employee entity) => new(
        entity.EmployeeCode,
        NormalizeEmail(entity.WorkEmail),
        NormalizeEmail(entity.PersonalEmail),
        PhoneRules.NullIfEmpty(entity.Phone),
        PhoneRules.NullIfEmpty(entity.AltPhone),
        NormalizePan(entity.Pan),
        NormalizeAadhaar(entity.Aadhaar),
        NormalizeUan(entity.PfUan));

    public static async Task<EmployeeIdentitySnapshot> LoadSnapshotAsync(
        AppDbContext db,
        Guid? excludeId,
        CancellationToken ct)
    {
        var query = db.Employees.AsQueryable();
        if (excludeId.HasValue)
            query = query.Where(e => e.Id != excludeId.Value);

        var rows = await query
            .Select(e => new
            {
                e.EmployeeCode,
                e.WorkEmail,
                e.PersonalEmail,
                e.Phone,
                e.AltPhone,
                e.Pan,
                e.Aadhaar,
                e.PfUan,
            })
            .ToListAsync(ct);

        var snapshot = new EmployeeIdentitySnapshot();
        foreach (var row in rows)
        {
            snapshot.Add(new EmployeeIdentity(
                row.EmployeeCode,
                NormalizeEmail(row.WorkEmail),
                NormalizeEmail(row.PersonalEmail),
                PhoneRules.NullIfEmpty(row.Phone),
                PhoneRules.NullIfEmpty(row.AltPhone),
                NormalizePan(row.Pan),
                NormalizeAadhaar(row.Aadhaar),
                NormalizeUan(row.PfUan)));
        }

        return snapshot;
    }

    public static async Task EnsureUniqueAsync(
        AppDbContext db,
        EmployeeIdentity identity,
        Guid? excludeId,
        CancellationToken ct)
    {
        var snapshot = await LoadSnapshotAsync(db, excludeId, ct);
        var conflicts = snapshot.Conflicts(identity);
        if (conflicts.Count > 0)
            throw new ConflictException(string.Join(" ", conflicts));
    }
}
