using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Projects.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ProjectDraftConfiguration : IEntityTypeConfiguration<ProjectDraft>
{
    public void Configure(EntityTypeBuilder<ProjectDraft> builder)
    {
        builder.ToTable("project_drafts");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.ProjectName).HasMaxLength(255).IsRequired();
        builder.Property(x => x.ClientName).HasMaxLength(255);
        builder.Property(x => x.SalesPerson).HasMaxLength(150);
        builder.Property(x => x.CreatedByName).HasMaxLength(150).IsRequired();
        builder.Property(x => x.UpdatedByName).HasMaxLength(150);
        builder.Property(x => x.Status).HasMaxLength(40).HasDefaultValue("active").IsRequired();

        // jsonb column for Postgres
        builder.Property(x => x.FormSnapshotJson)
            .HasColumnType("jsonb")
            .IsRequired();

        // Optimistic concurrency control via PostgreSQL xmin
        builder.Property(x => x.RowVersion)
            .HasColumnName("xmin")
            .HasColumnType("xid")
            .ValueGeneratedOnAddOrUpdate()
            .IsConcurrencyToken();

        builder.HasIndex(x => x.ClientId);
        builder.HasIndex(x => x.Status);
        builder.HasIndex(x => x.UpdatedAtUtc);
    }
}
