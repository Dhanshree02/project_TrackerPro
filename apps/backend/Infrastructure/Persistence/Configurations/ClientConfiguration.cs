using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Customers.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ClientConfiguration : IEntityTypeConfiguration<Client>
{
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    public void Configure(EntityTypeBuilder<Client> builder)
    {
        builder.ToTable("clients");

        builder.HasKey(c => c.Id);
        builder.HasIndex(c => c.Name);

        builder.Property(c => c.Name).HasMaxLength(255).IsRequired();
        builder.Property(c => c.Industry).HasMaxLength(100).IsRequired();
        builder.Property(c => c.Logo).HasMaxLength(10);
        builder.Property(c => c.ContactEmail).HasMaxLength(255);
        builder.Property(c => c.EngagementManager).HasMaxLength(120);
        builder.Property(c => c.ContactName).HasMaxLength(150);
        builder.Property(c => c.ContactPhone).HasMaxLength(40);
        builder.Property(c => c.ContactDesignation).HasMaxLength(120);
        builder.Property(c => c.ContactType).HasMaxLength(40);
        builder.Property(c => c.City).HasMaxLength(120);
        builder.Property(c => c.Country).HasMaxLength(120);
        builder.Property(c => c.BusinessType).HasMaxLength(40);
        builder.Property(c => c.Notes).HasMaxLength(2000);
        builder.Property(c => c.KycDocumentName).HasMaxLength(255);
        builder.Property(c => c.ClientType).HasConversion<string>().HasMaxLength(10);
        builder.Property(c => c.Status).HasConversion<string>().HasMaxLength(20);

        // SPOC contacts as a JSONB array of objects.
        builder.OwnsMany(c => c.Contacts, contact =>
        {
            contact.ToJson("contacts");
            contact.Property(x => x.Name).HasMaxLength(150);
            contact.Property(x => x.Email).HasMaxLength(255);
            contact.Property(x => x.Phone).HasMaxLength(40);
            contact.Property(x => x.Designation).HasMaxLength(120);
            contact.Property(x => x.ContactType).HasMaxLength(40);
        });
    }
}

public sealed class ClientAssignmentConfiguration : IEntityTypeConfiguration<ClientAssignment>
{
    public void Configure(EntityTypeBuilder<ClientAssignment> builder)
    {
        builder.ToTable("client_assignments");

        builder.HasKey(a => new { a.ClientId, a.UserId });

        builder.HasOne(a => a.Client)
            .WithMany(c => c.Assignments)
            .HasForeignKey(a => a.ClientId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(a => a.User)
            .WithMany()
            .HasForeignKey(a => a.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
