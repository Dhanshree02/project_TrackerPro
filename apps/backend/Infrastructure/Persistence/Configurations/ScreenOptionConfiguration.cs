using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Catalogs.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ScreenOptionConfiguration : IEntityTypeConfiguration<MstScreenOption>
{
    public void Configure(EntityTypeBuilder<MstScreenOption> builder)
    {
        builder.ToTable("mst_screen_options", DbSchemas.Master);
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Category).HasMaxLength(80).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(200).IsRequired();
        builder.Property(x => x.ParentName).HasMaxLength(200).IsRequired();
        builder.HasIndex(x => new { x.Category, x.Name, x.ParentName })
            .IsUnique()
            .HasFilter("\"DeletedAtUtc\" IS NULL");
    }
}
