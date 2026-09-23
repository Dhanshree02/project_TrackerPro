using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Projects.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ProjectTaskAssignmentConfiguration : IEntityTypeConfiguration<ProjectTaskAssignment>
{
    public void Configure(EntityTypeBuilder<ProjectTaskAssignment> builder)
    {
        builder.ToTable("project_task_assignments");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.Role).HasMaxLength(50).IsRequired();
        builder.Property(x => x.AllocatedHours).HasPrecision(10, 2);
        builder.Property(x => x.UtilizedHours).HasPrecision(10, 2);

        builder.HasIndex(x => x.TaskId);
        builder.HasIndex(x => x.EmployeeId);
        builder.HasIndex(x => new { x.TaskId, x.EmployeeId });

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
