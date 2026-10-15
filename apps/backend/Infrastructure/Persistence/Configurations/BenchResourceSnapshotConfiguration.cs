using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.ActionCentre.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public class BenchResourceSnapshotConfiguration : IEntityTypeConfiguration<BenchResourceSnapshot>
{
    public void Configure(EntityTypeBuilder<BenchResourceSnapshot> builder)
    {
        builder.ToTable("tbl_bench_resource_snapshots", "action_centre");

        builder.HasKey(s => s.Id);

        builder.Property(s => s.TimeSlot).HasMaxLength(20).IsRequired();
        builder.Property(s => s.DepartmentBreakdownJson).IsRequired();
        builder.Property(s => s.EmployeeListJson).IsRequired();

        builder.HasIndex(s => new { s.SnapshotDate, s.TimeSlot }).IsUnique();
    }
}
