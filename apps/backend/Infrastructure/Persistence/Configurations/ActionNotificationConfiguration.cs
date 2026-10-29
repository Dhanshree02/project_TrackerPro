using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.ActionCentre.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ActionNotificationConfiguration : IEntityTypeConfiguration<ActionNotification>
{
    public void Configure(EntityTypeBuilder<ActionNotification> builder)
    {
        builder.ToTable("tbl_notifications", DbSchemas.Action);
        builder.HasKey(x => x.Id);

        builder.Property(x => x.ProjectCode).HasMaxLength(50);
        builder.Property(x => x.ProjectName).HasMaxLength(255).IsRequired();
        builder.Property(x => x.Title).HasMaxLength(255).IsRequired();
        builder.Property(x => x.Type).HasMaxLength(100).IsRequired().HasDefaultValue("Issue Raised");
        builder.Property(x => x.Priority).HasMaxLength(20).IsRequired().HasDefaultValue("Medium");
        builder.Property(x => x.Status).HasMaxLength(50).IsRequired().HasDefaultValue("Pending");
        builder.Property(x => x.Unread).IsRequired().HasDefaultValue(true);
        builder.Property(x => x.RaisedByName).HasMaxLength(255).IsRequired().HasDefaultValue("System");
        builder.Property(x => x.RelatedTask).HasMaxLength(255);
        builder.Property(x => x.AcknowledgedBy).HasMaxLength(255);
        builder.Property(x => x.AcknowledgedDate).HasMaxLength(50);
        builder.Property(x => x.AcknowledgedTime).HasMaxLength(50);
        builder.Property(x => x.HistoryJson).HasColumnType("text").IsRequired().HasDefaultValue("[]");

        builder.HasIndex(x => new { x.RecipientEmployeeId, x.DeletedAtUtc });
        builder.HasIndex(x => new { x.ProjectId, x.DeletedAtUtc });
        builder.HasIndex(x => x.Status);

        builder.HasOne(x => x.RecipientEmployee)
            .WithMany()
            .HasForeignKey(x => x.RecipientEmployeeId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.Issue)
            .WithMany()
            .HasForeignKey(x => x.IssueId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}
