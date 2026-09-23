using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Projects.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ProjectTaskConfiguration : IEntityTypeConfiguration<ProjectTask>
{
    public void Configure(EntityTypeBuilder<ProjectTask> builder)
    {
        builder.ToTable("project_tasks");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.Title).HasMaxLength(255).IsRequired();
        builder.Property(x => x.Period).HasMaxLength(40);
        builder.Property(x => x.Phase).HasMaxLength(80);
        builder.Property(x => x.Stage).HasMaxLength(60).IsRequired();
        builder.Property(x => x.Priority).HasMaxLength(20).IsRequired();
        builder.Property(x => x.EstimatedHours).HasPrecision(10, 2);
        builder.Property(x => x.UtilizedHours).HasPrecision(10, 2);

        builder.HasIndex(x => x.ProjectId);
        builder.HasIndex(x => x.ProjectServiceId);
        builder.HasIndex(x => x.Stage);
        builder.HasIndex(x => x.Priority);

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.ProjectService)
            .WithMany()
            .HasForeignKey(x => x.ProjectServiceId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}
