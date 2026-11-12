using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Sla.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations.Sla;

public sealed class SlaInstanceConfiguration : IEntityTypeConfiguration<SlaInstance>
{
    public void Configure(EntityTypeBuilder<SlaInstance> builder)
    {
        builder.ToTable("tbl_sla_instances", DbSchemas.Sla);
        builder.HasKey(x => x.Id);

        foreach (var property in builder.Metadata.GetProperties())
        {
            property.SetColumnName(property.Name.ToLowerInvariant());
        }

        builder.Property(x => x.Module).HasMaxLength(100).IsRequired();
        builder.Property(x => x.ActivityType).HasMaxLength(100).IsRequired();
        builder.Property(x => x.EntityReference).HasMaxLength(100);
        builder.Property(x => x.CurrentStage).HasMaxLength(100).IsRequired().HasDefaultValue("Default");

        builder.Property(x => x.Status)
            .HasConversion<string>()
            .HasMaxLength(50)
            .IsRequired()
            .HasDefaultValue(SlaInstanceStatus.Tracking);

        builder.Property(x => x.Priority)
            .HasConversion<string>()
            .HasMaxLength(50)
            .IsRequired()
            .HasDefaultValue(SlaPriority.Medium);

        builder.Property(x => x.ActiveHangfireJobId).HasMaxLength(100);

        builder.Property(x => x.CustomPayloadJson)
            .HasColumnType("text")
            .IsRequired()
            .HasDefaultValue("{}");

        builder.HasIndex(x => new { x.EntityId, x.ActivityType, x.DeletedAtUtc });
        builder.HasIndex(x => x.Status);
        builder.HasIndex(x => x.TargetDeadlineUtc);
        builder.HasIndex(x => x.ProjectId);
        builder.HasIndex(x => x.RecipientEmployeeId);

        builder.HasOne(x => x.Policy)
            .WithMany(p => p.Instances)
            .HasForeignKey(x => x.PolicyId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
