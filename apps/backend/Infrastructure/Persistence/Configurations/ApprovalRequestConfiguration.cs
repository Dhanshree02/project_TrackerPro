using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.ActionCentre.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public class ApprovalRequestConfiguration : IEntityTypeConfiguration<ApprovalRequest>
{
    public void Configure(EntityTypeBuilder<ApprovalRequest> builder)
    {
        builder.ToTable("tbl_approval_requests", "action_centre");

        builder.HasKey(a => a.Id);

        builder.Property(a => a.RequestCode).HasMaxLength(50).IsRequired();
        builder.HasIndex(a => a.RequestCode).IsUnique();

        builder.Property(a => a.ApprovalType).HasMaxLength(50).IsRequired();
        builder.Property(a => a.Title).HasMaxLength(255).IsRequired();
        builder.Property(a => a.Description).IsRequired();
        builder.Property(a => a.Status).HasMaxLength(30).IsRequired();
        builder.Property(a => a.Priority).HasMaxLength(20).IsRequired();

        builder.Property(a => a.ProjectName).HasMaxLength(255);
        builder.Property(a => a.EmployeeName).HasMaxLength(200);
        builder.Property(a => a.Department).HasMaxLength(100);

        builder.Property(a => a.RequestedByName).HasMaxLength(200).IsRequired();
        builder.Property(a => a.RequestedByRole).HasMaxLength(100).IsRequired();

        builder.Property(a => a.AssignedApproverRole).HasMaxLength(100);
        builder.Property(a => a.AssignedApproverName).HasMaxLength(200);

        builder.Property(a => a.PayloadJson).IsRequired();
        builder.Property(a => a.AuditHistoryJson).IsRequired();

        builder.Property(a => a.DecidedByName).HasMaxLength(200);

        builder.HasOne(a => a.Project)
            .WithMany()
            .HasForeignKey(a => a.ProjectId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasIndex(a => new { a.ApprovalType, a.Status });
        builder.HasIndex(a => a.ProjectId);
        builder.HasIndex(a => a.RequestedByEmployeeId);
        builder.HasIndex(a => a.CreatedAtUtc);
    }
}
