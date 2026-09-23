using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Projects.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ProjectDocumentConfiguration : IEntityTypeConfiguration<ProjectDocument>
{
    public void Configure(EntityTypeBuilder<ProjectDocument> builder)
    {
        builder.ToTable("project_documents");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.DocumentType).HasMaxLength(80).IsRequired();
        builder.Property(x => x.FileName).HasMaxLength(255).IsRequired();
        builder.Property(x => x.OriginalFileName).HasMaxLength(255).IsRequired();
        builder.Property(x => x.FilePath).HasMaxLength(500).IsRequired();
        builder.Property(x => x.ContentType).HasMaxLength(120).IsRequired();

        builder.HasIndex(x => x.ProjectId);
        builder.HasIndex(x => x.DocumentType);

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
