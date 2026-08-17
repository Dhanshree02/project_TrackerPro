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

        // SPOC contacts as a JSONB array of objects (same shape as Client.Contacts).
        builder.OwnsMany(s => s.Contacts, contact =>
        {
            contact.ToJson("contacts");
            contact.Property(x => x.Name).HasMaxLength(150);
            contact.Property(x => x.Email).HasMaxLength(255);
            contact.Property(x => x.Phone).HasMaxLength(40);
            contact.Property(x => x.Designation).HasMaxLength(120);
            contact.Property(x => x.ContactType).HasMaxLength(40);
        });

        builder.HasOne(s => s.Client)
            .WithMany(c => c.SubVentures)
            .HasForeignKey(s => s.ClientId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
