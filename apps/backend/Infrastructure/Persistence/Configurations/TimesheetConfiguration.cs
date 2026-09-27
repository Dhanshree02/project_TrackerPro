using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Timesheets.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class TimesheetWeekConfiguration : IEntityTypeConfiguration<TimesheetWeek>
{
    public void Configure(EntityTypeBuilder<TimesheetWeek> builder)
    {
        builder.ToTable("timesheets");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.WeekStart).HasColumnType("date");
        builder.Property(x => x.Status).HasMaxLength(32).IsRequired();
        builder.Property(x => x.TotalHours).HasColumnType("numeric(6,1)");
        builder.Property(x => x.ReviewComment).HasMaxLength(2000);
        builder.HasIndex(x => new { x.EmployeeId, x.WeekStart })
            .IsUnique()
            .HasFilter("\"DeletedAtUtc\" IS NULL");

        builder.HasOne(x => x.Employee)
            .WithMany()
            .HasForeignKey(x => x.EmployeeId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class TimesheetEntryConfiguration : IEntityTypeConfiguration<TimesheetEntry>
{
    public void Configure(EntityTypeBuilder<TimesheetEntry> builder)
    {
        builder.ToTable("timesheet_entries");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.ProjectKey).HasMaxLength(64).IsRequired();
        builder.Property(x => x.TaskKey).HasMaxLength(64).IsRequired();
        builder.Property(x => x.ProjectName).HasMaxLength(200).IsRequired();
        builder.Property(x => x.TaskName).HasMaxLength(200).IsRequired();
        builder.Property(x => x.ReviewDecision).HasMaxLength(32);

        builder.HasOne(x => x.TimesheetWeek)
            .WithMany(x => x.Entries)
            .HasForeignKey(x => x.TimesheetWeekId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class TimesheetEntryDayConfiguration : IEntityTypeConfiguration<TimesheetEntryDay>
{
    public void Configure(EntityTypeBuilder<TimesheetEntryDay> builder)
    {
        builder.ToTable("timesheet_entry_days");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Hours).HasColumnType("numeric(4,1)");
        builder.Property(x => x.Comment).HasMaxLength(1000);
        builder.HasIndex(x => new { x.TimesheetEntryId, x.DayIndex })
            .IsUnique()
            .HasFilter("\"DeletedAtUtc\" IS NULL");

        builder.HasOne(x => x.TimesheetEntry)
            .WithMany(x => x.Days)
            .HasForeignKey(x => x.TimesheetEntryId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
