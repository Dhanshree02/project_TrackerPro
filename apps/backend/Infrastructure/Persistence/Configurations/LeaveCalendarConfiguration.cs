using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Catalogs.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public class LeaveCalendarConfiguration : IEntityTypeConfiguration<LeaveCalendarHoliday>
{
    public void Configure(EntityTypeBuilder<LeaveCalendarHoliday> builder)
    {
        builder.ToTable("mst_leave_calendar", DbSchemas.Master);

        builder.HasKey(x => x.Id);

        builder.Property(x => x.HolidayDate)
            .IsRequired();

        builder.Property(x => x.Name)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(x => x.Tag)
            .IsRequired()
            .HasMaxLength(100)
            .HasDefaultValue("Public Holiday");

        builder.Property(x => x.Color)
            .IsRequired()
            .HasMaxLength(50)
            .HasDefaultValue("#a6c63a");

        builder.Property(x => x.Description)
            .HasMaxLength(500);

        builder.Property(x => x.Year)
            .IsRequired();

        builder.HasIndex(x => x.HolidayDate)
            .IsUnique()
            .HasFilter("\"DeletedAtUtc\" IS NULL");

        builder.HasIndex(x => x.Year)
            .HasFilter("\"DeletedAtUtc\" IS NULL");
    }
}

