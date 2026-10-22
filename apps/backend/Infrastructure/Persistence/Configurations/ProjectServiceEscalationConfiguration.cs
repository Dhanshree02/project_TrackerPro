using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Projects.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ProjectServiceEscalationConfiguration : IEntityTypeConfiguration<ProjectServiceEscalation>
{
    public void Configure(EntityTypeBuilder<ProjectServiceEscalation> builder)
    {
        builder.ToTable("tbl_project_service_escalations", DbSchemas.Project);
        builder.HasKey(x => x.Id);

        builder.Property(x => x.ProjectCode).HasMaxLength(40);
        builder.Property(x => x.ProjectName).HasMaxLength(300).IsRequired();
        builder.Property(x => x.CustomerName).HasMaxLength(200);
        builder.Property(x => x.ServiceName).HasMaxLength(200).IsRequired();
        builder.Property(x => x.EscalationType).HasMaxLength(80).IsRequired();
        builder.Property(x => x.Priority).HasMaxLength(20).IsRequired();
        builder.Property(x => x.Subject).HasMaxLength(300).IsRequired();
        builder.Property(x => x.Description).HasColumnType("text").IsRequired();
        builder.Property(x => x.AttachmentFileName).HasMaxLength(260);
        builder.Property(x => x.AttachmentPath).HasMaxLength(500);
        builder.Property(x => x.AttachmentContentType).HasMaxLength(120);
        builder.Property(x => x.Status).HasMaxLength(20).IsRequired();
        builder.Property(x => x.RaisedByName).HasMaxLength(200).IsRequired();

        builder.HasIndex(x => x.ProjectId);
        builder.HasIndex(x => x.ProjectServiceId);

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(x => x.Stakeholders)
            .WithOne(x => x.Escalation)
            .HasForeignKey(x => x.EscalationId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

public sealed class ProjectServiceEscalationStakeholderConfiguration : IEntityTypeConfiguration<ProjectServiceEscalationStakeholder>
{
    public void Configure(EntityTypeBuilder<ProjectServiceEscalationStakeholder> builder)
    {
        builder.ToTable("tbl_project_service_escalation_stakeholders", DbSchemas.Project);
        builder.HasKey(x => x.Id);

        builder.Property(x => x.EmployeeName).HasMaxLength(200).IsRequired();
        builder.Property(x => x.SubDepartment).HasMaxLength(160).IsRequired();
        builder.Property(x => x.Status).HasMaxLength(20).IsRequired();

        builder.HasIndex(x => x.EscalationId);
        builder.HasIndex(x => x.EmployeeId);
    }
}
