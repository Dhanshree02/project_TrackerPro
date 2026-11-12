using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Sla.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations.Sla;

public sealed class SlaEventConfiguration : IEntityTypeConfiguration<SlaEvent>
{
    public void Configure(EntityTypeBuilder<SlaEvent> builder)
    {
        builder.ToTable("tbl_sla_events", DbSchemas.Sla);
        builder.HasKey(x => x.Id);

        foreach (var property in builder.Metadata.GetProperties())
        {
            property.SetColumnName(property.Name.ToLowerInvariant());
        }

        builder.Property(x => x.EventType)
            .HasConversion<string>()
            .HasMaxLength(50)
            .IsRequired();

        builder.Property(x => x.Status)
            .HasConversion<string>()
            .HasMaxLength(50)
            .IsRequired()
            .HasDefaultValue(SlaEventStatus.Scheduled);

        builder.Property(x => x.HangfireJobId).HasMaxLength(100);
        builder.Property(x => x.StageAtExecution).HasMaxLength(100).IsRequired().HasDefaultValue("Default");

        builder.Property(x => x.TargetRolesJson)
            .HasColumnType("text")
            .IsRequired()
            .HasDefaultValue("[]");

        builder.Property(x => x.TargetRecipientIdsJson)
            .HasColumnType("text")
            .IsRequired()
            .HasDefaultValue("[]");

        builder.Property(x => x.ExecutionLog)
            .HasColumnType("text");

        builder.Property(x => x.IdempotencyKey)
            .HasMaxLength(150);

        builder.HasIndex(x => new { x.InstanceId, x.EventType });
        builder.HasIndex(x => x.HangfireJobId);
        builder.HasIndex(x => x.Status);
        builder.HasIndex(x => x.ScheduledAtUtc);
        builder.HasIndex(x => x.IdempotencyKey)
            .IsUnique()
            .HasFilter("idempotencykey IS NOT NULL AND deletedatutc IS NULL");

        builder.HasOne(x => x.Instance)
            .WithMany(i => i.Events)
            .HasForeignKey(x => x.InstanceId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
