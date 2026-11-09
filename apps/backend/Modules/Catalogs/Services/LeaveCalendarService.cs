using System.Globalization;
using ClosedXML.Excel;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Catalogs.DTOs;
using PMS.API.Modules.Catalogs.Models;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.Catalogs.Services;

public sealed class LeaveCalendarService(AppDbContext db) : ILeaveCalendarService
{
    public async Task<IReadOnlyList<LeaveCalendarHolidayDto>> GetHolidaysAsync(int? year, CancellationToken ct = default)
    {
        var query = db.LeaveCalendarHolidays
            .AsNoTracking()
            .Where(h => h.DeletedAtUtc == null);

        if (year.HasValue)
        {
            query = query.Where(h => h.Year == year.Value || h.HolidayDate.Year == year.Value);
        }

        var rows = await query
            .OrderBy(h => h.HolidayDate)
            .ToListAsync(ct);

        return rows.Select(MapDto).ToList();
    }

    public async Task<LeaveCalendarHolidayDto?> GetHolidayByIdAsync(Guid id, CancellationToken ct = default)
    {
        var row = await db.LeaveCalendarHolidays
            .AsNoTracking()
            .FirstOrDefaultAsync(h => h.Id == id && h.DeletedAtUtc == null, ct);

        return row is null ? null : MapDto(row);
    }

    public async Task<LeaveCalendarHolidayDto> CreateHolidayAsync(
        UpsertLeaveCalendarHolidayRequest request,
        CancellationToken ct = default)
    {
        ValidateRequest(request);

        var existing = await db.LeaveCalendarHolidays
            .FirstOrDefaultAsync(h => h.HolidayDate == request.Date, ct);

        if (existing is not null)
        {
            if (existing.DeletedAtUtc == null)
            {
                throw new ConflictException($"A holiday named '{existing.Name}' already exists on {request.Date:yyyy-MM-dd}.");
            }

            existing.Name = request.Name.Trim();
            existing.Year = request.Date.Year;
            existing.DeletedAtUtc = null;
            existing.UpdatedAtUtc = DateTime.UtcNow;
            await db.SaveChangesAsync(ct);
            return MapDto(existing);
        }

        var holiday = new LeaveCalendarHoliday
        {
            Id = Guid.NewGuid(),
            HolidayDate = request.Date,
            Name = request.Name.Trim(),
            Year = request.Date.Year,
            CreatedAtUtc = DateTime.UtcNow,
        };

        db.LeaveCalendarHolidays.Add(holiday);
        await db.SaveChangesAsync(ct);

        return MapDto(holiday);
    }

    public async Task<LeaveCalendarHolidayDto> UpdateHolidayAsync(
        Guid id,
        UpsertLeaveCalendarHolidayRequest request,
        CancellationToken ct = default)
    {
        ValidateRequest(request);

        var holiday = await db.LeaveCalendarHolidays
            .FirstOrDefaultAsync(h => h.Id == id && h.DeletedAtUtc == null, ct);

        if (holiday is null)
        {
            throw new NotFoundException($"Holiday with ID '{id}' was not found.");
        }

        if (holiday.HolidayDate != request.Date)
        {
            var conflict = await db.LeaveCalendarHolidays
                .AnyAsync(h => h.Id != id && h.HolidayDate == request.Date && h.DeletedAtUtc == null, ct);

            if (conflict)
            {
                throw new ConflictException($"Another holiday is already registered for {request.Date:yyyy-MM-dd}.");
            }
        }

        holiday.HolidayDate = request.Date;
        holiday.Name = request.Name.Trim();
        holiday.Year = request.Date.Year;
        holiday.UpdatedAtUtc = DateTime.UtcNow;

        await db.SaveChangesAsync(ct);

        return MapDto(holiday);
    }

    public async Task DeleteHolidayAsync(Guid id, CancellationToken ct = default)
    {
        var holiday = await db.LeaveCalendarHolidays
            .FirstOrDefaultAsync(h => h.Id == id && h.DeletedAtUtc == null, ct);

        if (holiday is null)
        {
            throw new NotFoundException($"Holiday with ID '{id}' was not found.");
        }

        holiday.DeletedAtUtc = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);
    }

    public async Task ClearYearHolidaysAsync(int year, CancellationToken ct = default)
    {
        var holidays = await db.LeaveCalendarHolidays
            .Where(h => (h.Year == year || h.HolidayDate.Year == year) && h.DeletedAtUtc == null)
            .ToListAsync(ct);

        var now = DateTime.UtcNow;
        foreach (var h in holidays)
        {
            h.DeletedAtUtc = now;
        }

        await db.SaveChangesAsync(ct);
    }

    public async Task<IReadOnlyList<LeaveCalendarHolidayDto>> BulkCreateHolidaysAsync(
        IReadOnlyList<UpsertLeaveCalendarHolidayRequest> requests,
        CancellationToken ct = default)
    {
        var created = new List<LeaveCalendarHoliday>();

        foreach (var req in requests)
        {
            ValidateRequest(req);

            var existing = await db.LeaveCalendarHolidays
                .FirstOrDefaultAsync(h => h.HolidayDate == req.Date, ct);

            if (existing is not null)
            {
                existing.Name = req.Name.Trim();
                existing.Year = req.Date.Year;
                existing.DeletedAtUtc = null;
                existing.UpdatedAtUtc = DateTime.UtcNow;
                created.Add(existing);
            }
            else
            {
                var newHoliday = new LeaveCalendarHoliday
                {
                    Id = Guid.NewGuid(),
                    HolidayDate = req.Date,
                    Name = req.Name.Trim(),
                    Year = req.Date.Year,
                    CreatedAtUtc = DateTime.UtcNow,
                };
                db.LeaveCalendarHolidays.Add(newHoliday);
                created.Add(newHoliday);
            }
        }

        await db.SaveChangesAsync(ct);
        return created.OrderBy(h => h.HolidayDate).Select(MapDto).ToList();
    }

    public Task<byte[]> GetBulkSampleExcelAsync(int? year, CancellationToken ct = default)
    {
        var targetYear = year ?? DateTime.UtcNow.Year;
        using var workbook = new XLWorkbook();
        var sheet = workbook.Worksheets.Add("Holidays");

        sheet.Row(1).Height = 26;
        sheet.Row(1).Style.Alignment.Vertical = XLAlignmentVerticalValues.Center;

        sheet.Cell(1, 1).Value = "Date";
        sheet.Cell(1, 2).Value = "Holiday Name";

        for (int col = 1; col <= 2; col++)
        {
            var cell = sheet.Cell(1, col);
            cell.Style.Font.Bold = true;
            cell.Style.Font.FontSize = 11;
            cell.Style.Font.FontColor = XLColor.White;
            cell.Style.Fill.BackgroundColor = XLColor.FromHtml("#166534"); // Forest green
            cell.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Center;
        }

        var samples = new (string Date, string Name)[]
        {
            ($"{targetYear}-01-01", "New Year's Day"),
            ($"{targetYear}-01-26", "Republic Day"),
            ($"{targetYear}-03-03", "Holi"),
            ($"{targetYear}-04-14", "Dr. Ambedkar Jayanti"),
            ($"{targetYear}-05-01", "Maharashtra Day / May Day"),
            ($"{targetYear}-08-15", "Independence Day"),
            ($"{targetYear}-10-02", "Mahatma Gandhi Jayanti"),
            ($"{targetYear}-12-25", "Christmas"),
        };

        for (int i = 0; i < samples.Length; i++)
        {
            var row = i + 2;
            sheet.Cell(row, 1).Value = samples[i].Date;
            sheet.Cell(row, 1).Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Center;
            sheet.Cell(row, 2).Value = samples[i].Name;
        }

        sheet.Column(1).Width = 18;
        sheet.Column(2).Width = 36;

        using var ms = new MemoryStream();
        workbook.SaveAs(ms);
        return Task.FromResult(ms.ToArray());
    }

    public async Task<IReadOnlyList<LeaveCalendarHolidayDto>> UploadExcelAsync(IFormFile file, CancellationToken ct = default)
    {
        if (file is null || file.Length == 0)
        {
            throw new BadRequestException("Please upload a valid Excel file.");
        }

        using var stream = file.OpenReadStream();
        using var workbook = new XLWorkbook(stream);
        var sheet = workbook.Worksheets.FirstOrDefault();
        if (sheet is null)
        {
            throw new BadRequestException("The uploaded Excel workbook contains no sheets.");
        }

        int dateCol = -1;
        int nameCol = -1;

        var lastCol = sheet.LastColumnUsed()?.ColumnNumber() ?? 2;
        for (int col = 1; col <= lastCol; col++)
        {
            var header = sheet.Cell(1, col).GetString().Trim().ToLowerInvariant();
            if (header.Contains("date")) dateCol = col;
            else if (header.Contains("name") || header.Contains("holiday")) nameCol = col;
        }

        if (dateCol == -1) dateCol = 1;
        if (nameCol == -1) nameCol = 2;

        var requests = new List<UpsertLeaveCalendarHolidayRequest>();
        var lastRow = sheet.LastRowUsed()?.RowNumber() ?? 1;

        for (int row = 2; row <= lastRow; row++)
        {
            var dateCell = sheet.Cell(row, dateCol);
            var nameCell = sheet.Cell(row, nameCol);

            if (dateCell.IsEmpty() && nameCell.IsEmpty()) continue;

            DateOnly date;
            if (dateCell.DataType == XLDataType.DateTime)
            {
                date = DateOnly.FromDateTime(dateCell.GetDateTime());
            }
            else
            {
                var dateStr = dateCell.GetString().Trim();
                if (!DateOnly.TryParse(dateStr, CultureInfo.InvariantCulture, out date) &&
                    !DateOnly.TryParse(dateStr, out date))
                {
                    continue;
                }
            }

            var name = nameCell.GetString().Trim();
            if (string.IsNullOrWhiteSpace(name)) continue;

            requests.Add(new UpsertLeaveCalendarHolidayRequest(date, name));
        }

        if (requests.Count == 0)
        {
            throw new BadRequestException("No valid holiday rows found in the uploaded file.");
        }

        return await BulkCreateHolidaysAsync(requests, ct);
    }

    private static void ValidateRequest(UpsertLeaveCalendarHolidayRequest request)
    {
        if (request.Date == default)
        {
            throw new BadRequestException("Holiday date is required.");
        }

        if (string.IsNullOrWhiteSpace(request.Name))
        {
            throw new BadRequestException("Holiday name is required.");
        }
    }

    private static LeaveCalendarHolidayDto MapDto(LeaveCalendarHoliday h) =>
        new(
            h.Id,
            h.HolidayDate,
            h.Name,
            h.Year,
            h.CreatedAtUtc);
}
