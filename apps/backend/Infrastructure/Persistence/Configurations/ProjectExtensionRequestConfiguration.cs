using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Projects.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ProjectExtensionRequestConfiguration : IEntityTypeConfiguration<ProjectExtensionRequest>
{
    public void Configure(EntityTypeBuilder<ProjectExtensionRequest> builder)
    {
        builder.ToTable("tbl_project_extension_requests", DbSchemas.Project);
        builder.HasKey(x => x.Id);

        builder.Property(x => x.Reason).HasColumnType("text").IsRequired();
        builder.Property(x => x.Status).HasMaxLength(20).IsRequired();
        builder.Property(x => x.RequestedByName).HasMaxLength(200).IsRequired();

        builder.HasIndex(x => x.ProjectId);

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(x => x.Approvers)
            .WithOne(x => x.ExtensionRequest)
            .HasForeignKey(x => x.ExtensionRequestId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

public sealed class ProjectExtensionApproverConfiguration : IEntityTypeConfiguration<ProjectExtensionApprover>
{
    public void Configure(EntityTypeBuilder<ProjectExtensionApprover> builder)
    {
        builder.ToTable("tbl_project_extension_approvers", DbSchemas.Project);
        builder.HasKey(x => x.Id);

        builder.Property(x => x.EmployeeName).HasMaxLength(200).IsRequired();
        builder.Property(x => x.Status).HasMaxLength(20).IsRequired();

        builder.HasIndex(x => x.ExtensionRequestId);
        builder.HasIndex(x => x.EmployeeId);
    }
}
