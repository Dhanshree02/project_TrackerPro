using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Projects.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ProjectResourceAllocationRequestConfiguration : IEntityTypeConfiguration<ProjectResourceAllocationRequest>
{
    public void Configure(EntityTypeBuilder<ProjectResourceAllocationRequest> builder)
    {
        builder.ToTable("tbl_resource_allocation_requests", DbSchemas.Project);
        builder.HasKey(x => x.Id);

        builder.HasIndex(x => x.ProjectId);
        builder.HasIndex(x => x.EmployeeId);
        builder.HasIndex(x => x.ApproverEmployeeId);

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.Employee)
            .WithMany()
            .HasForeignKey(x => x.EmployeeId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
