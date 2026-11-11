using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Projects.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ProjectFeedbackConfiguration : IEntityTypeConfiguration<ProjectFeedback>
{
    public void Configure(EntityTypeBuilder<ProjectFeedback> builder)
    {
        builder.ToTable("tbl_project_feedbacks", DbSchemas.Project);
        builder.HasKey(x => x.Id);

        builder.Property(x => x.EmployeeName).HasMaxLength(200).IsRequired();
        builder.Property(x => x.EmployeeCode).HasMaxLength(50);
        builder.Property(x => x.ReportingManagerName).HasMaxLength(200);
        builder.Property(x => x.SubmittedByName).HasMaxLength(200).IsRequired();
        builder.Property(x => x.FeedbackType).HasMaxLength(50).IsRequired().HasDefaultValue("DirectFeedback");
        builder.Property(x => x.Strengths).HasMaxLength(100);
        builder.Property(x => x.AreasOfImprovement).HasMaxLength(100);
        builder.Property(x => x.Comments).HasMaxLength(100);
        builder.Property(x => x.RequestNote).HasColumnType("text");
        builder.Property(x => x.Status).HasMaxLength(50).IsRequired().HasDefaultValue("Submitted");
        builder.Property(x => x.CommentsJson).HasColumnType("text");
        builder.Property(x => x.HistoryJson).HasColumnType("text");

        builder.HasIndex(x => x.ProjectId);
        builder.HasIndex(x => x.EmployeeId);
        builder.HasIndex(x => x.ReportingManagerId);
        builder.HasIndex(x => x.FeedbackType);

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
