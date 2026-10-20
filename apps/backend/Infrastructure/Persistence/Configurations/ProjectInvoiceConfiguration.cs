using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Projects.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ProjectInvoiceConfiguration : IEntityTypeConfiguration<ProjectInvoice>
{
    public void Configure(EntityTypeBuilder<ProjectInvoice> builder)
    {
        builder.ToTable("tbl_project_invoices", DbSchemas.Project);
        builder.HasKey(x => x.Id);

        builder.Property(x => x.MilestoneName).HasMaxLength(255).IsRequired();
        builder.Property(x => x.Percentage).HasPrecision(5, 2);
        builder.Property(x => x.Amount).HasPrecision(18, 2);
        builder.Property(x => x.TaxAmount).HasPrecision(18, 2);
        builder.Property(x => x.TotalAmount).HasPrecision(18, 2);
        builder.Property(x => x.Status).HasMaxLength(40).IsRequired();
        builder.Property(x => x.InvoiceNumber).HasMaxLength(80);
        builder.Property(x => x.ServiceName).HasMaxLength(255);
        builder.Property(x => x.UnitPrice).HasPrecision(18, 2);
        builder.Property(x => x.Currency).HasMaxLength(10);
        builder.Property(x => x.ResourceLevel).HasMaxLength(500);
        builder.Property(x => x.PaymentStatus).HasMaxLength(40);

        builder.HasIndex(x => x.ProjectId);
        builder.HasIndex(x => x.Status);
        builder.HasIndex(x => x.InvoiceNumber);

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
