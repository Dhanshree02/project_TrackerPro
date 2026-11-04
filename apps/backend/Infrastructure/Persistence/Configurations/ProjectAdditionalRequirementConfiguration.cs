using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Projects.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ProjectAdditionalRequirementConfiguration : IEntityTypeConfiguration<ProjectAdditionalRequirement>
{
    public void Configure(EntityTypeBuilder<ProjectAdditionalRequirement> builder)
    {
        builder.ToTable("tbl_project_additional_requirements", DbSchemas.Project);
        builder.HasKey(x => x.Id);

        builder.Property(x => x.RequirementId).HasMaxLength(50).IsRequired();
        builder.Property(x => x.ClientName).HasMaxLength(255);
        builder.Property(x => x.ProjectName).HasMaxLength(255);
        builder.Property(x => x.RequirementType).HasMaxLength(50).IsRequired().HasDefaultValue("Add Service");
        builder.Property(x => x.Title).HasMaxLength(255).IsRequired();
        builder.Property(x => x.Description).HasColumnType("text").IsRequired();
        builder.Property(x => x.Priority).HasMaxLength(50).IsRequired().HasDefaultValue("Medium");
        builder.Property(x => x.RequestedByName).HasMaxLength(255).IsRequired();
        builder.Property(x => x.AttachmentFileName).HasMaxLength(255);
        builder.Property(x => x.AttachmentPath).HasColumnType("text");
        builder.Property(x => x.ScopeCancellationService).HasMaxLength(255);
        builder.Property(x => x.Status).HasMaxLength(50).IsRequired().HasDefaultValue("Open");
        builder.Property(x => x.ApprovedByName).HasMaxLength(255);
        builder.Property(x => x.ApprovalComments).HasColumnType("text");
        builder.Property(x => x.CommentsJson).HasColumnType("text").IsRequired().HasDefaultValue("[]");
        builder.Property(x => x.HistoryJson).HasColumnType("text").IsRequired().HasDefaultValue("[]");

        builder.HasIndex(x => x.ProjectId);
        builder.HasIndex(x => x.Status);

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
