using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Projects.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ProjectTeamMemberConfiguration : IEntityTypeConfiguration<ProjectTeamMember>
{
    public void Configure(EntityTypeBuilder<ProjectTeamMember> builder)
    {
        builder.ToTable("tbl_project_team_members", DbSchemas.Project);
        builder.HasKey(x => x.Id);

        builder.Property(x => x.SubDepartment).HasMaxLength(200);
        builder.Property(x => x.Billability).HasMaxLength(40).IsRequired();
        builder.Property(x => x.ResourceType).HasMaxLength(40).IsRequired();
        builder.Property(x => x.MemberRole)
            .HasMaxLength(40)
            .IsRequired()
            .HasDefaultValue(ProjectMemberRoles.ProjectTeam);

        builder.HasIndex(x => x.ProjectId);
        builder.HasIndex(x => x.EmployeeId);
        builder.HasIndex(x => x.DepartmentId);

        // One active assignment per employee per project (soft-deleted rows excluded).
        builder.HasIndex(x => new { x.ProjectId, x.EmployeeId })
            .IsUnique()
            .HasFilter("\"DeletedAtUtc\" IS NULL");

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.Employee)
            .WithMany()
            .HasForeignKey(x => x.EmployeeId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.Department)
            .WithMany()
            .HasForeignKey(x => x.DepartmentId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}
