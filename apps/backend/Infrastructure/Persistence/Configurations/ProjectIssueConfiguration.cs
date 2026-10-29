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

        builder.Property(x => x.ProjectCode).HasMaxLength(50);
        builder.Property(x => x.ProjectName).HasMaxLength(300).IsRequired();
        builder.Property(x => x.IssueType).HasMaxLength(100).IsRequired();
        builder.Property(x => x.Priority).HasMaxLength(20).IsRequired();
        builder.Property(x => x.Subject).HasMaxLength(300).IsRequired();
        builder.Property(x => x.Description).HasColumnType("text").IsRequired();
        builder.Property(x => x.Status).HasMaxLength(30).IsRequired();
        builder.Property(x => x.RaisedByName).HasMaxLength(200).IsRequired();
        builder.Property(x => x.RaisedByRole).HasMaxLength(100);

        builder.HasIndex(x => x.ProjectId);
        builder.HasIndex(x => x.RaisedByEmployeeId);

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.RaisedByEmployee)
            .WithMany()
            .HasForeignKey(x => x.RaisedByEmployeeId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasMany(x => x.Alerts)
            .WithOne(x => x.Issue)
            .HasForeignKey(x => x.IssueId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

public sealed class ProjectAlertConfiguration : IEntityTypeConfiguration<ProjectAlert>
{
    public void Configure(EntityTypeBuilder<ProjectAlert> builder)
    {
        builder.ToTable("tbl_project_alerts", DbSchemas.Project);
        builder.HasKey(x => x.Id);

        builder.Property(x => x.Title).HasMaxLength(300).IsRequired();
        builder.Property(x => x.Description).HasColumnType("text");
        builder.Property(x => x.AlertType).HasMaxLength(50).IsRequired();
        builder.Property(x => x.Priority).HasMaxLength(20).IsRequired();
        builder.Property(x => x.Status).HasMaxLength(30).IsRequired();
        builder.Property(x => x.RaisedByName).HasMaxLength(200).IsRequired();
        builder.Property(x => x.AudienceUserIds).HasColumnType("text");

        builder.HasIndex(x => x.ProjectId);
        builder.HasIndex(x => x.IssueId);

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
