using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Repository.Models;

namespace PMS.API.Modules.Repository.Configurations;

public class RepositoryItemConfiguration : IEntityTypeConfiguration<RepositoryItem>
{
    public void Configure(EntityTypeBuilder<RepositoryItem> builder)
    {
        builder.ToTable("repository");

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

        builder.HasIndex(r => r.Category);
        builder.HasIndex(r => r.DeletedAtUtc);
    }
}

public class RepositoryActivityLogConfiguration : IEntityTypeConfiguration<RepositoryActivityLog>
{
    public void Configure(EntityTypeBuilder<RepositoryActivityLog> builder)
    {
        builder.ToTable("repository_activity_logs");

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
