using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.ActionCentre.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public class AlertConfiguration : IEntityTypeConfiguration<Alert>
{
    public void Configure(EntityTypeBuilder<Alert> builder)
    {
        builder.ToTable("tbl_alerts", "action_centre");

        builder.HasKey(a => a.Id);

        builder.Property(a => a.AlertCode).HasMaxLength(50).IsRequired();
        builder.HasIndex(a => a.AlertCode).IsUnique();

        builder.Property(a => a.Title).HasMaxLength(255).IsRequired();
        builder.Property(a => a.Description).IsRequired();
        builder.Property(a => a.Category).HasMaxLength(50).IsRequired();
        builder.Property(a => a.Severity).HasMaxLength(20).IsRequired();
        builder.Property(a => a.Status).HasMaxLength(30).IsRequired();

        builder.Property(a => a.ProjectName).HasMaxLength(255);
        builder.Property(a => a.ClientName).HasMaxLength(255);
        builder.Property(a => a.SourceEntity).HasMaxLength(50).IsRequired();
        builder.Property(a => a.SourceEntityId).HasMaxLength(100).IsRequired();
        builder.Property(a => a.TriggerCondition).HasMaxLength(255).IsRequired();
        builder.Property(a => a.OwnerName).HasMaxLength(200);

        builder.Property(a => a.AcknowledgedByName).HasMaxLength(200);
        builder.Property(a => a.ResolvedByName).HasMaxLength(200);
        builder.Property(a => a.AuditHistoryJson).IsRequired();

        builder.HasOne(a => a.Project)
            .WithMany()
            .HasForeignKey(a => a.ProjectId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasOne(a => a.Client)
            .WithMany()
            .HasForeignKey(a => a.ClientId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasIndex(a => new { a.Category, a.Status });
        builder.HasIndex(a => a.ProjectId);
        builder.HasIndex(a => new { a.Category, a.SourceEntityId, a.Status });
        builder.HasIndex(a => a.CreatedAtUtc);
    }
}
