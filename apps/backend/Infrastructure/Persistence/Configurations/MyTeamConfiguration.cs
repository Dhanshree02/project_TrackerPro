using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.MyTeam.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class TeamDayEntryConfiguration : IEntityTypeConfiguration<TeamDayEntry>
{
    public void Configure(EntityTypeBuilder<TeamDayEntry> builder)
    {
        builder.ToTable("team_day_entries");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.WorkDate).HasColumnType("date");
        builder.Property(x => x.Attendance).HasMaxLength(20);
        builder.Property(x => x.Shift).HasMaxLength(20);
        builder.HasIndex(x => new { x.EmployeeId, x.WorkDate })
            .IsUnique()
            .HasFilter("\"DeletedAtUtc\" IS NULL");

        builder.HasOne(x => x.Employee)
            .WithMany()
            .HasForeignKey(x => x.EmployeeId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class TeamMemberScheduleConfiguration : IEntityTypeConfiguration<TeamMemberSchedule>
{
    public void Configure(EntityTypeBuilder<TeamMemberSchedule> builder)
    {
        builder.ToTable("team_member_schedules");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.WorkingDays).HasColumnType("smallint[]");
        builder.Property(x => x.Notes).HasMaxLength(2000);
        builder.HasIndex(x => x.EmployeeId)
            .IsUnique()
            .HasFilter("\"DeletedAtUtc\" IS NULL");

        builder.HasOne(x => x.Employee)
            .WithMany()
            .HasForeignKey(x => x.EmployeeId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class TeamMemberHolidayConfiguration : IEntityTypeConfiguration<TeamMemberHoliday>
{
    public void Configure(EntityTypeBuilder<TeamMemberHoliday> builder)
    {
        builder.ToTable("team_member_holidays");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.HolidayDate).HasColumnType("date");
        builder.Property(x => x.Name).HasMaxLength(200).IsRequired();
        builder.Property(x => x.Comment).HasMaxLength(500);
        builder.HasIndex(x => new { x.EmployeeId, x.HolidayDate })
            .IsUnique()
            .HasFilter("\"DeletedAtUtc\" IS NULL");

        builder.HasOne(x => x.Employee)
            .WithMany()
            .HasForeignKey(x => x.EmployeeId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
