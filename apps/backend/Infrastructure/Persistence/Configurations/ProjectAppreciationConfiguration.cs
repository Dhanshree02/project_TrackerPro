using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Projects.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ProjectAppreciationConfiguration : IEntityTypeConfiguration<ProjectAppreciation>
{
    public void Configure(EntityTypeBuilder<ProjectAppreciation> builder)
    {
        builder.ToTable("tbl_project_appreciations", DbSchemas.Project);
        builder.HasKey(x => x.Id);

        builder.Property(x => x.RecipientName).HasMaxLength(200).IsRequired();
        builder.Property(x => x.RecipientEmail).HasMaxLength(200);
        builder.Property(x => x.RecipientRole).HasMaxLength(100);
        builder.Property(x => x.Badge).HasMaxLength(100).IsRequired().HasDefaultValue("Star Performer");
        builder.Property(x => x.Message).HasColumnType("text").IsRequired();
        builder.Property(x => x.GivenByName).HasMaxLength(200).IsRequired();

        builder.HasIndex(x => x.ProjectId);
        builder.HasIndex(x => x.RecipientEmployeeId);

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
