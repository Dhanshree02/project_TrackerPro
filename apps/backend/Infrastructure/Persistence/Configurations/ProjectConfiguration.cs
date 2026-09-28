using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Projects.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class ProjectConfiguration : IEntityTypeConfiguration<Project>
{
    public void Configure(EntityTypeBuilder<Project> builder)
    {
        builder.ToTable("projects");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.ProjectCode).HasMaxLength(50).IsRequired();
        builder.Property(x => x.WbsId).HasMaxLength(80);
        builder.Property(x => x.Name).HasMaxLength(255).IsRequired();
        builder.Property(x => x.Status).HasMaxLength(40).IsRequired();
        builder.Property(x => x.Health).HasMaxLength(20).IsRequired();
        builder.Property(x => x.ContractType).HasMaxLength(80);
        builder.Property(x => x.ProjectType).HasMaxLength(80);
        builder.Property(x => x.Currency).HasMaxLength(10).IsRequired();
        builder.Property(x => x.TaxPercent).HasPrecision(5, 2);
        builder.Property(x => x.Budget).HasPrecision(18, 2);
        builder.Property(x => x.Spent).HasPrecision(18, 2);
        builder.Property(x => x.TotalHours).HasPrecision(10, 2);
        builder.Property(x => x.TotalDays).HasPrecision(10, 2);
        builder.Property(x => x.InvoiceValue).HasPrecision(18, 2);
        builder.Property(x => x.EngagementManager).HasMaxLength(150);
        builder.Property(x => x.SalesPerson).HasMaxLength(150);
        builder.Property(x => x.WbsStatus).HasMaxLength(40).IsRequired();
        builder.Property(x => x.WbsSubStatus).HasMaxLength(80);
        builder.Property(x => x.PoStatus).HasMaxLength(40);
        builder.Property(x => x.PoNumber).HasMaxLength(80);
        builder.Property(x => x.BillingModel).HasMaxLength(80);
        builder.Property(x => x.PaymentTerms).HasMaxLength(120);
        builder.Property(x => x.AccountContactName).HasMaxLength(150);
        builder.Property(x => x.AccountContactPhone).HasMaxLength(40);
        builder.Property(x => x.AccountContactEmail).HasMaxLength(255);

        builder.HasIndex(x => x.ProjectCode).IsUnique();
        builder.HasIndex(x => x.WbsId).IsUnique();
        builder.HasIndex(x => x.ClientId);
        builder.HasIndex(x => x.SubVentureId);
        builder.HasIndex(x => x.Status);
        builder.HasIndex(x => x.WbsStatus);
        builder.HasIndex(x => x.ProjectManagerId);
        builder.HasIndex(x => x.RenewedFromProjectId);

        builder.HasOne(x => x.Client)
            .WithMany()
            .HasForeignKey(x => x.ClientId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.SubVenture)
            .WithMany()
            .HasForeignKey(x => x.SubVentureId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasOne(x => x.ProjectManager)
            .WithMany()
            .HasForeignKey(x => x.ProjectManagerId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasOne(x => x.TeamLead)
            .WithMany()
            .HasForeignKey(x => x.TeamLeadId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasOne(x => x.EngagementManagerRef)
            .WithMany()
            .HasForeignKey(x => x.EngagementManagerId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasOne(x => x.SalesPersonRef)
            .WithMany()
            .HasForeignKey(x => x.SalesPersonId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasOne(x => x.RenewedFromProject)
            .WithMany()
            .HasForeignKey(x => x.RenewedFromProjectId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}
