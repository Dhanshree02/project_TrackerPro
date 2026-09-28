using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Projects.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ProjectInvoiceConfiguration : IEntityTypeConfiguration<ProjectInvoice>
{
    public void Configure(EntityTypeBuilder<ProjectInvoice> builder)
    {
        builder.ToTable("project_invoices");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.MilestoneName).HasMaxLength(255).IsRequired();
        builder.Property(x => x.Percentage).HasPrecision(5, 2);
        builder.Property(x => x.Amount).HasPrecision(18, 2);
        builder.Property(x => x.TaxAmount).HasPrecision(18, 2);
        builder.Property(x => x.TotalAmount).HasPrecision(18, 2);
        builder.Property(x => x.Status).HasMaxLength(40).IsRequired();
        builder.Property(x => x.InvoiceNumber).HasMaxLength(80);

        builder.HasIndex(x => x.ProjectId);
        builder.HasIndex(x => x.Status);
        builder.HasIndex(x => x.InvoiceNumber);

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
