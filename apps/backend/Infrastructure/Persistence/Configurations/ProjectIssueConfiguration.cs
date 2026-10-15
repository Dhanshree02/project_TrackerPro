using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Projects.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ProjectIssueConfiguration : IEntityTypeConfiguration<ProjectIssue>
{
    public void Configure(EntityTypeBuilder<ProjectIssue> builder)
    {
        builder.ToTable("tbl_project_issues", DbSchemas.Project);
        builder.HasKey(x => x.Id);

        builder.Property(x => x.Title).HasMaxLength(250).IsRequired();
        builder.Property(x => x.Description).HasMaxLength(4000).IsRequired();
        builder.Property(x => x.Category).HasMaxLength(100).IsRequired();
        builder.Property(x => x.Priority).HasMaxLength(50).IsRequired();
        builder.Property(x => x.Status).HasMaxLength(50).IsRequired();
        builder.Property(x => x.RaisedByName).HasMaxLength(150).IsRequired();
        builder.Property(x => x.RaisedByRole).HasMaxLength(100).IsRequired();
        builder.Property(x => x.CurrentAssigneeRole).HasMaxLength(50).IsRequired();
        builder.Property(x => x.CurrentAssigneeName).HasMaxLength(150);
        builder.Property(x => x.DottedLineManagerName).HasMaxLength(150);
        builder.Property(x => x.ResolvedByName).HasMaxLength(150);
        builder.Property(x => x.ResolutionNotes).HasMaxLength(2000);

        builder.HasIndex(x => x.ProjectId);
        builder.HasIndex(x => x.Status);
        builder.HasIndex(x => x.EscalationLevel);
        builder.HasIndex(x => x.RaisedByEmployeeId);
        builder.HasIndex(x => x.CurrentAssigneeEmployeeId);

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.RaisedByEmployee)
            .WithMany()
            .HasForeignKey(x => x.RaisedByEmployeeId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}
