using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Auth.Models;
using PMS.API.Modules.Users.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.ToTable("users");

        builder.HasKey(u => u.Id);
        builder.HasIndex(u => u.Email).IsUnique();
        builder.HasIndex(u => u.EmployeeId).IsUnique();

        builder.Property(u => u.Email).HasMaxLength(255).IsRequired();
        builder.Property(u => u.Name).HasMaxLength(255).IsRequired();
        builder.Property(u => u.EmployeeId).HasMaxLength(20).IsRequired();
        builder.Property(u => u.PasswordHash).HasMaxLength(255).IsRequired();

        builder.HasOne(u => u.Role)
            .WithMany(r => r.Users)
            .HasForeignKey(u => u.RoleId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class RoleConfiguration : IEntityTypeConfiguration<Role>
{
    public void Configure(EntityTypeBuilder<Role> builder)
    {
        builder.ToTable("roles");

        builder.HasKey(r => r.Id);
        builder.HasIndex(r => r.Name).IsUnique();
        builder.Property(r => r.Name).HasMaxLength(50).IsRequired();
        builder.Property(r => r.DisplayName).HasMaxLength(100).IsRequired();
        builder.Property(r => r.Description).HasMaxLength(500);

        // Permissions stored as JSONB array of strings.
        builder.Property(r => r.Permissions)
            .HasColumnType("jsonb")
            .HasConversion(
                v => System.Text.Json.JsonSerializer.Serialize(v, (System.Text.Json.JsonSerializerOptions?)null),
                v => System.Text.Json.JsonSerializer.Deserialize<List<string>>(v, (System.Text.Json.JsonSerializerOptions?)null) ?? new List<string>());
    }
}

public sealed class RolePermissionAuditConfiguration : IEntityTypeConfiguration<RolePermissionAudit>
{
    public void Configure(EntityTypeBuilder<RolePermissionAudit> builder)
    {
        builder.ToTable("role_permission_audits");

        builder.HasKey(a => a.Id);
        builder.HasIndex(a => a.RoleId);
        builder.HasIndex(a => a.CreatedAtUtc);

        builder.Property(a => a.RoleName).HasMaxLength(100).IsRequired();
        builder.Property(a => a.ModuleKey).HasMaxLength(100).IsRequired();
        builder.Property(a => a.ModuleLabel).HasMaxLength(100).IsRequired();
        builder.Property(a => a.SubmoduleKey).HasMaxLength(100);
        builder.Property(a => a.SubmoduleLabel).HasMaxLength(100);
        builder.Property(a => a.PermissionKey).HasMaxLength(150).IsRequired();
        builder.Property(a => a.ActionLabel).HasMaxLength(100).IsRequired();
        builder.Property(a => a.ChangeType).HasMaxLength(20).IsRequired();
        builder.Property(a => a.PreviousValue).HasMaxLength(50).IsRequired();
        builder.Property(a => a.NewValue).HasMaxLength(50).IsRequired();
        builder.Property(a => a.ChangedByName).HasMaxLength(255);

        builder.HasOne(a => a.Role)
            .WithMany()
            .HasForeignKey(a => a.RoleId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

public sealed class RefreshTokenConfiguration : IEntityTypeConfiguration<RefreshToken>
{
    public void Configure(EntityTypeBuilder<RefreshToken> builder)
    {
        builder.ToTable("refresh_tokens");

        builder.HasKey(t => t.Id);
        builder.HasIndex(t => t.TokenHash).IsUnique();
        builder.Property(t => t.TokenHash).HasMaxLength(255).IsRequired();

        builder.HasOne(t => t.User)
            .WithMany(u => u.RefreshTokens)
            .HasForeignKey(t => t.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
