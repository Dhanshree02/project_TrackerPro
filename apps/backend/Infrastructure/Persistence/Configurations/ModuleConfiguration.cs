using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Catalogs.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class MstModuleConfiguration : IEntityTypeConfiguration<MstModule>
{
    public void Configure(EntityTypeBuilder<MstModule> builder)
    {
        builder.ToTable("mst_modules", DbSchemas.Master);
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => x.Code).IsUnique();
        builder.Property(x => x.Code).HasMaxLength(40).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(80).IsRequired();
        builder.Property(x => x.Route).HasMaxLength(120);
        builder.Property(x => x.IconKey).HasMaxLength(40).IsRequired();
    }
}

public sealed class MstSubModuleConfiguration : IEntityTypeConfiguration<MstSubModule>
{
    public void Configure(EntityTypeBuilder<MstSubModule> builder)
    {
        builder.ToTable("mst_submodules", DbSchemas.Master, table =>
        {
            table.HasCheckConstraint(
                "CK_mst_submodules_OneParent",
                "(\"ModuleId\" IS NOT NULL AND \"ParentId\" IS NULL) OR (\"ModuleId\" IS NULL AND \"ParentId\" IS NOT NULL)");
        });
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => x.Code).IsUnique();
        builder.HasIndex(x => x.ModuleId);
        builder.HasIndex(x => x.ParentId);
        builder.Property(x => x.Code).HasMaxLength(60).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(80).IsRequired();
        builder.Property(x => x.Route).HasMaxLength(120);
        builder.HasOne(x => x.Module)
            .WithMany()
            .HasForeignKey(x => x.ModuleId)
            .OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(x => x.Parent)
            .WithMany(x => x.Children)
            .HasForeignKey(x => x.ParentId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class MstWidgetConfiguration : IEntityTypeConfiguration<MstWidget>
{
    public void Configure(EntityTypeBuilder<MstWidget> builder)
    {
        builder.ToTable("mst_widgets", DbSchemas.Master);
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => x.Code).IsUnique();
        builder.HasIndex(x => x.ParentId);
        builder.Property(x => x.Code).HasMaxLength(80).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(160).IsRequired();
        builder.HasOne(x => x.Module)
            .WithMany()
            .HasForeignKey(x => x.ParentId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class MstTabConfiguration : IEntityTypeConfiguration<MstTab>
{
    public void Configure(EntityTypeBuilder<MstTab> builder)
    {
        builder.ToTable("mst_tabs", DbSchemas.Master, table =>
        {
            table.HasCheckConstraint(
                "CK_mst_tabs_OneParent",
                "(\"ModuleId\" IS NOT NULL AND \"SubModuleId\" IS NULL AND \"TabId\" IS NULL) OR (\"ModuleId\" IS NULL AND \"SubModuleId\" IS NOT NULL AND \"TabId\" IS NULL) OR (\"ModuleId\" IS NULL AND \"SubModuleId\" IS NULL AND \"TabId\" IS NOT NULL)");
        });
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => x.Code).IsUnique();
        builder.HasIndex(x => x.ModuleId);
        builder.HasIndex(x => x.SubModuleId);
        builder.HasIndex(x => x.TabId);
        builder.Property(x => x.Code).HasMaxLength(60).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(120).IsRequired();
        builder.HasOne(x => x.Module)
            .WithMany()
            .HasForeignKey(x => x.ModuleId)
            .OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(x => x.SubModule)
            .WithMany()
            .HasForeignKey(x => x.SubModuleId)
            .OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(x => x.Parent)
            .WithMany(x => x.Children)
            .HasForeignKey(x => x.TabId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
