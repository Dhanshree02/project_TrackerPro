using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Projects.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ProjectInterviewConfiguration : IEntityTypeConfiguration<ProjectInterview>
{
    public void Configure(EntityTypeBuilder<ProjectInterview> builder)
    {
        builder.ToTable("tbl_project_interviews", DbSchemas.Project);
        builder.HasKey(x => x.Id);

        builder.Property(x => x.ResourceName).HasMaxLength(200).IsRequired();
        builder.Property(x => x.Result).HasMaxLength(20).IsRequired();
        builder.Property(x => x.Comments).HasColumnType("text");

        builder.HasIndex(x => x.ProjectId);
        builder.HasIndex(x => x.EmployeeId);

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
