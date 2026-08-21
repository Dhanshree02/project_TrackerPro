using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Customers.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ClientContactConfiguration : IEntityTypeConfiguration<ClientContactEntity>
{
    public void Configure(EntityTypeBuilder<ClientContactEntity> builder)
    {
        builder.ToTable("client_contacts");

        builder.HasKey(c => c.Id);
        builder.HasIndex(c => c.ClientId);
        builder.HasIndex(c => c.SubVentureId);

        builder.Property(c => c.Name).HasMaxLength(150);
        builder.Property(c => c.Email).HasMaxLength(255);
        builder.Property(c => c.Phone).HasMaxLength(40);
        builder.Property(c => c.Designation).HasMaxLength(120);
        builder.Property(c => c.ContactType).HasMaxLength(40);

        builder.HasOne(c => c.Client)
            .WithMany(c => c.Contacts)
            .HasForeignKey(c => c.ClientId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(c => c.SubVenture)
            .WithMany(s => s.Contacts)
            .HasForeignKey(c => c.SubVentureId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.ToTable(t => t.HasCheckConstraint(
            "CK_client_contacts_exactly_one_owner",
            "(\"ClientId\" IS NOT NULL AND \"SubVentureId\" IS NULL) OR (\"ClientId\" IS NULL AND \"SubVentureId\" IS NOT NULL)"));
    }
}
