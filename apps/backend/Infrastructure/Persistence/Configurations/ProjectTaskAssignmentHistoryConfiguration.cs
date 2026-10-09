using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Projects.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ProjectTaskAssignmentHistoryConfiguration : IEntityTypeConfiguration<ProjectTaskAssignmentHistory>
{
    public void Configure(EntityTypeBuilder<ProjectTaskAssignmentHistory> builder)
    {
        builder.ToTable("log_project_task_assignments", DbSchemas.Project);
        builder.HasKey(x => x.Id);

        builder.Property(x => x.Action).HasMaxLength(20).IsRequired();
        builder.Property(x => x.ResourceName).HasMaxLength(200).IsRequired();
        builder.Property(x => x.TeamType).HasMaxLength(30).IsRequired();

        builder.HasIndex(x => x.TaskId);
        builder.HasIndex(x => new { x.TaskId, x.OccurredAtUtc });

        builder.HasOne(x => x.Task)
            .WithMany()
            .HasForeignKey(x => x.TaskId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.Employee)
            .WithMany()
            .HasForeignKey(x => x.EmployeeId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
