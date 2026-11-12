using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Sla.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations.Sla;

public sealed class SlaPolicyConfiguration : IEntityTypeConfiguration<SlaPolicy>
{
    public void Configure(EntityTypeBuilder<SlaPolicy> builder)
    {
        builder.ToTable("tbl_sla_policies", DbSchemas.Sla);
        builder.HasKey(x => x.Id);

        foreach (var property in builder.Metadata.GetProperties())
        {
            property.SetColumnName(property.Name.ToLowerInvariant());
        }

        builder.Property(x => x.Module).HasMaxLength(100).IsRequired();
        builder.Property(x => x.ActivityType).HasMaxLength(100).IsRequired();
        builder.Property(x => x.Stage).HasMaxLength(100).IsRequired().HasDefaultValue("Default");
        builder.Property(x => x.Name).HasMaxLength(200).IsRequired();
        builder.Property(x => x.Description).HasMaxLength(500);

        builder.Property(x => x.CalculationMode)
            .HasConversion<string>()
            .HasMaxLength(50)
            .IsRequired()
            .HasDefaultValue(SlaCalculationMode.WorkingHours);

        builder.Property(x => x.ReminderIntervalsMinutesJson)
            .HasColumnType("text")
            .IsRequired()
            .HasDefaultValue("[]");

        builder.Property(x => x.ResponsibleRolesJson)
            .HasColumnType("text")
            .IsRequired()
            .HasDefaultValue("[]");

        builder.Property(x => x.FirstEscalationRolesJson)
            .HasColumnType("text")
            .IsRequired()
            .HasDefaultValue("[]");

        builder.Property(x => x.SecondEscalationRolesJson)
            .HasColumnType("text")
            .IsRequired()
            .HasDefaultValue("[]");

        builder.Property(x => x.MetadataJson)
            .HasColumnType("text")
            .IsRequired()
            .HasDefaultValue("{}");

        builder.HasIndex(x => new { x.Module, x.ActivityType, x.Stage, x.DeletedAtUtc })
            .IsUnique();

        builder.HasIndex(x => x.ActivityType);
        builder.HasIndex(x => x.IsActive);
    }
}
