using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Infrastructure.Persistence.Configurations;
using PMS.API.Modules.Repository.Models;

namespace PMS.API.Modules.Repository.Configurations;

public class RepositoryItemConfiguration : IEntityTypeConfiguration<RepositoryItem>
{
    public void Configure(EntityTypeBuilder<RepositoryItem> builder)
    {
        builder.ToTable("tbl_repository_items", DbSchemas.Repository);

        builder.HasKey(r => r.Id);

        builder.Property(r => r.FileName)
            .IsRequired()
            .HasMaxLength(255);

        builder.Property(r => r.Category)
            .IsRequired()
            .HasMaxLength(50);

        builder.Property(r => r.Size)
            .IsRequired();

        builder.Property(r => r.LastUpdated)
            .IsRequired();

        builder.Property(r => r.UploadedBy)
            .IsRequired()
            .HasMaxLength(150);

        builder.Property(r => r.FilePath)
            .IsRequired()
            .HasMaxLength(1000);

        builder.HasIndex(r => r.Category);
        builder.HasIndex(r => r.DeletedAtUtc);

        builder.HasMany(r => r.Departments)
            .WithOne(d => d.RepositoryItem)
            .HasForeignKey(d => d.RepositoryItemId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

public class RepositoryDepartmentConfiguration : IEntityTypeConfiguration<RepositoryDepartment>
{
    public void Configure(EntityTypeBuilder<RepositoryDepartment> builder)
    {
        builder.ToTable("tbl_repository_departments", DbSchemas.Repository);

        builder.HasKey(d => new { d.RepositoryItemId, d.DepartmentId });

        builder.HasIndex(d => d.DepartmentId);

        builder.HasOne(d => d.Department)
            .WithMany()
            .HasForeignKey(d => d.DepartmentId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

public class RepositoryActivityLogConfiguration : IEntityTypeConfiguration<RepositoryActivityLog>
{
    public void Configure(EntityTypeBuilder<RepositoryActivityLog> builder)
    {
        builder.ToTable("log_repository_activity", DbSchemas.Repository);

        builder.HasKey(l => l.Id);

        builder.Property(l => l.Action)
            .IsRequired()
            .HasMaxLength(50);

        builder.Property(l => l.FileName)
            .IsRequired()
            .HasMaxLength(255);

        builder.Property(l => l.Category)
            .IsRequired()
            .HasMaxLength(50);

        builder.Property(l => l.PerformedBy)
            .IsRequired()
            .HasMaxLength(150);

        builder.Property(l => l.Details)
            .HasMaxLength(1000);

        builder.HasIndex(l => l.CreatedAtUtc);
        builder.HasIndex(l => l.DeletedAtUtc);
    }
}
