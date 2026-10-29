using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.ActionCentre.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class BucketTaskConfiguration : IEntityTypeConfiguration<BucketTask>
{
    public void Configure(EntityTypeBuilder<BucketTask> builder)
    {
        builder.ToTable("tbl_bucket_tasks", DbSchemas.Action);
        builder.HasKey(x => x.Id);

        builder.Property(x => x.TaskTitle).HasMaxLength(255).IsRequired();
        builder.Property(x => x.ProjectName).HasMaxLength(255).IsRequired();
        builder.Property(x => x.Priority).HasMaxLength(50).IsRequired().HasDefaultValue("Medium");
        builder.Property(x => x.Status).HasMaxLength(60).IsRequired().HasDefaultValue("Not Started");
        builder.Property(x => x.AssignedByName).HasMaxLength(200);
        builder.Property(x => x.UtilizedHours).HasPrecision(10, 2);

        builder.HasIndex(x => x.EmployeeId);
        builder.HasIndex(x => x.TaskId);
        builder.HasIndex(x => x.ProjectId);
        builder.HasIndex(x => x.Status);
        builder.HasIndex(x => x.Priority);
        builder.HasIndex(x => new { x.TaskId, x.EmployeeId });

        builder.HasOne(x => x.Task)
            .WithMany()
            .HasForeignKey(x => x.TaskId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.ProjectService)
            .WithMany()
            .HasForeignKey(x => x.ProjectServiceId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasOne(x => x.Assignment)
            .WithMany()
            .HasForeignKey(x => x.AssignmentId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasOne(x => x.Employee)
            .WithMany()
            .HasForeignKey(x => x.EmployeeId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
