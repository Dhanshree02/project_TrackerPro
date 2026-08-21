using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Customers.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class SubVentureConfiguration : IEntityTypeConfiguration<SubVenture>
{
    public void Configure(EntityTypeBuilder<SubVenture> builder)
    {
        builder.ToTable("sub_ventures");

        builder.HasKey(s => s.Id);
        builder.HasIndex(s => s.ClientId);

        builder.Property(s => s.Name).HasMaxLength(255).IsRequired();

        builder.HasOne(s => s.Client)
            .WithMany(c => c.SubVentures)
            .HasForeignKey(s => s.ClientId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
