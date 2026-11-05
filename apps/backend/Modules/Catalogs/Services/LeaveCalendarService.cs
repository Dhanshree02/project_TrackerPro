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
