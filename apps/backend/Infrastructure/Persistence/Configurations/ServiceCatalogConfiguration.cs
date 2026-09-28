using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Projects.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class MstServiceGroupConfiguration : IEntityTypeConfiguration<MstServiceGroup>
{
    public void Configure(EntityTypeBuilder<MstServiceGroup> builder)
    {
        builder.ToTable("mst_service_groups");
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => x.Code).IsUnique();
        builder.HasIndex(x => x.Name).IsUnique();
        builder.Property(x => x.Code).HasMaxLength(40).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(100).IsRequired();
    }
}

public sealed class MstServiceDepartmentConfiguration : IEntityTypeConfiguration<MstServiceDepartment>
{
    public void Configure(EntityTypeBuilder<MstServiceDepartment> builder)
    {
        builder.ToTable("mst_service_departments");
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => x.Code).IsUnique();
        builder.HasIndex(x => x.Name).IsUnique();
        builder.HasIndex(x => x.GroupId);
        builder.Property(x => x.Code).HasMaxLength(80).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(150).IsRequired();

        builder.HasOne(x => x.Group)
            .WithMany(g => g.Departments)
            .HasForeignKey(x => x.GroupId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class MstServiceSubDepartmentConfiguration : IEntityTypeConfiguration<MstServiceSubDepartment>
{
    public void Configure(EntityTypeBuilder<MstServiceSubDepartment> builder)
    {
        builder.ToTable("mst_service_sub_departments");
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => x.Code).IsUnique();
        builder.HasIndex(x => new { x.DepartmentId, x.Name }).IsUnique();
        builder.Property(x => x.Code).HasMaxLength(120).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(200).IsRequired();

        builder.HasOne(x => x.Department)
            .WithMany(d => d.SubDepartments)
            .HasForeignKey(x => x.DepartmentId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

public sealed class MstServiceCatalogConfiguration : IEntityTypeConfiguration<MstServiceCatalog>
{
    public void Configure(EntityTypeBuilder<MstServiceCatalog> builder)
    {
        builder.ToTable("mst_service_catalog");
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => x.Code).IsUnique();
        builder.HasIndex(x => new { x.SubDepartmentId, x.Name }).IsUnique();
        builder.Property(x => x.Code).HasMaxLength(50).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(255).IsRequired();
        builder.Property(x => x.DefaultTools).HasMaxLength(500);
        builder.Property(x => x.DefaultUnitPrice).HasPrecision(18, 2);

        builder.HasOne(x => x.SubDepartment)
            .WithMany(s => s.Services)
            .HasForeignKey(x => x.SubDepartmentId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
