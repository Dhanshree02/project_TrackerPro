using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Projects.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ProjectServiceConfiguration : IEntityTypeConfiguration<ProjectServiceEntity>
{
    public void Configure(EntityTypeBuilder<ProjectServiceEntity> builder)
    {
        builder.ToTable("project_services");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.TaskId).HasMaxLength(50);
        builder.Property(x => x.Department).HasMaxLength(150).IsRequired();
        builder.Property(x => x.SubDepartment).HasMaxLength(200);
        builder.Property(x => x.ServiceName).HasMaxLength(255).IsRequired();
        builder.Property(x => x.ResourceLevel).HasMaxLength(80);
        builder.Property(x => x.Frequency).HasMaxLength(40);
        builder.Property(x => x.Location).HasMaxLength(40);
        builder.Property(x => x.LocationText).HasMaxLength(200);
        builder.Property(x => x.ServiceModel).HasMaxLength(40);
        builder.Property(x => x.DeliveryModel).HasMaxLength(80);
        builder.Property(x => x.FinalDeliveryFormat).HasMaxLength(120);
        builder.Property(x => x.BillingModel).HasMaxLength(80);
        builder.Property(x => x.Tools).HasMaxLength(500);
        builder.Property(x => x.UnitPrice).HasPrecision(18, 2);
        builder.Property(x => x.Total).HasPrecision(18, 2);

        builder.HasIndex(x => x.ProjectId);
        builder.HasIndex(x => x.ServiceCatalogId);

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.ServiceCatalog)
            .WithMany()
            .HasForeignKey(x => x.ServiceCatalogId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}
