using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PMS.API.Modules.Resources.Models;

namespace PMS.API.Infrastructure.Persistence.Configurations;

public sealed class MstDepartmentConfiguration : IEntityTypeConfiguration<MstDepartment>
{
    public void Configure(EntityTypeBuilder<MstDepartment> builder)
    {
        builder.ToTable("mst_departments");
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => x.Code).IsUnique();
        builder.HasIndex(x => x.Name).IsUnique();
        builder.Property(x => x.Code).HasMaxLength(50).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(150).IsRequired();
    }
}

public sealed class MstDesignationConfiguration : IEntityTypeConfiguration<MstDesignation>
{
    public void Configure(EntityTypeBuilder<MstDesignation> builder)
    {
        builder.ToTable("mst_designations");
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => x.Code).IsUnique();
        builder.HasIndex(x => new { x.DepartmentId, x.Name }).IsUnique();
        builder.Property(x => x.Code).HasMaxLength(80).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(150).IsRequired();

        builder.HasOne(x => x.Department)
            .WithMany(d => d.Designations)
            .HasForeignKey(x => x.DepartmentId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}

public sealed class MstIndustryConfiguration : IEntityTypeConfiguration<MstIndustry>
{
    public void Configure(EntityTypeBuilder<MstIndustry> builder)
    {
        builder.ToTable("mst_industries");
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => x.Code).IsUnique();
        builder.HasIndex(x => x.Name).IsUnique();
        builder.Property(x => x.Code).HasMaxLength(80).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(150).IsRequired();
    }
}

public sealed class MstCountryConfiguration : IEntityTypeConfiguration<MstCountry>
{
    public void Configure(EntityTypeBuilder<MstCountry> builder)
    {
        builder.ToTable("mst_countries");
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => x.Code).IsUnique();
        builder.HasIndex(x => x.Name).IsUnique();
        builder.Property(x => x.Code).HasMaxLength(8).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(120).IsRequired();
    }
}

public sealed class MstCityConfiguration : IEntityTypeConfiguration<MstCity>
{
    public void Configure(EntityTypeBuilder<MstCity> builder)
    {
        builder.ToTable("mst_cities");
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => x.Code).IsUnique();
        builder.HasIndex(x => new { x.CountryId, x.Name }).IsUnique();
        builder.Property(x => x.Code).HasMaxLength(80).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(120).IsRequired();

        builder.HasOne(x => x.Country)
            .WithMany(c => c.Cities)
            .HasForeignKey(x => x.CountryId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class MstNationalityConfiguration : IEntityTypeConfiguration<MstNationality>
{
    public void Configure(EntityTypeBuilder<MstNationality> builder)
    {
        builder.ToTable("mst_nationalities");
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => x.Code).IsUnique();
        builder.HasIndex(x => x.Name).IsUnique();
        builder.Property(x => x.Code).HasMaxLength(80).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(120).IsRequired();
    }
}

public sealed class MstSalaryBandConfiguration : IEntityTypeConfiguration<MstSalaryBand>
{
    public void Configure(EntityTypeBuilder<MstSalaryBand> builder)
    {
        builder.ToTable("mst_salary_bands");
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => x.Code).IsUnique();
        builder.HasIndex(x => x.Name).IsUnique();
        builder.Property(x => x.Code).HasMaxLength(20).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(20).IsRequired();
    }
}

public sealed class MstRoleConfiguration : IEntityTypeConfiguration<MstRole>
{
    public void Configure(EntityTypeBuilder<MstRole> builder)
    {
        builder.ToTable("mst_roles");
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => x.Code).IsUnique();
        builder.HasIndex(x => new { x.DesignationId, x.Name }).IsUnique();
        builder.Property(x => x.Code).HasMaxLength(80).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(150).IsRequired();

        builder.HasOne(x => x.Designation)
            .WithMany(d => d.Roles)
            .HasForeignKey(x => x.DesignationId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class EmployeeConfiguration : IEntityTypeConfiguration<Employee>
{
    public void Configure(EntityTypeBuilder<Employee> builder)
    {
        builder.ToTable("employees");
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => x.EmployeeCode).IsUnique();
        builder.HasIndex(x => x.WorkEmail).IsUnique();
        builder.Property(x => x.EmployeeCode).HasMaxLength(20).IsRequired();
        builder.Property(x => x.FirstName).HasMaxLength(120).IsRequired();
        builder.Property(x => x.LastName).HasMaxLength(120).IsRequired();
        builder.Property(x => x.WorkEmail).HasMaxLength(255).IsRequired();
        builder.Property(x => x.PersonalEmail).HasMaxLength(255);
        builder.Property(x => x.Phone).HasMaxLength(40);
        builder.Property(x => x.AltPhone).HasMaxLength(40);
        builder.Property(x => x.Role).HasMaxLength(80);
        builder.Property(x => x.BusinessUnit).HasMaxLength(120);
        builder.Property(x => x.WorkLocation).HasMaxLength(120);
        builder.Property(x => x.OfficeBranch).HasMaxLength(120);
        builder.Property(x => x.Category).HasMaxLength(80);
        builder.Property(x => x.Team).HasMaxLength(120);
        builder.Property(x => x.ProjectSite).HasMaxLength(80);
        builder.Property(x => x.Status).HasMaxLength(60);
        builder.Property(x => x.ConfirmationStatus).HasMaxLength(80);
        builder.Property(x => x.ProbationStatus).HasMaxLength(80);
        builder.Property(x => x.ProbationPeriod).HasMaxLength(40);
        builder.Property(x => x.Experience).HasMaxLength(80);
        builder.Property(x => x.PreviousCompany).HasMaxLength(160);
        builder.Property(x => x.EmploymentType).HasMaxLength(80);
        builder.Property(x => x.ContractType).HasMaxLength(80);
        builder.Property(x => x.BondStatus).HasMaxLength(80);
        builder.Property(x => x.NoticePeriod).HasMaxLength(80);
        builder.Property(x => x.AssetId).HasMaxLength(80);
        builder.Property(x => x.ExitType).HasMaxLength(80);
        builder.Property(x => x.ExitReason).HasMaxLength(500);
        builder.Property(x => x.Education).HasMaxLength(255);
        builder.Property(x => x.Skills).HasColumnType("jsonb");
        builder.Property(x => x.Certifications).HasColumnType("jsonb");
        builder.Property(x => x.Languages).HasColumnType("jsonb");
        builder.Property(x => x.PromotionReadiness).HasMaxLength(120);
        builder.Property(x => x.ManagerFeedback).HasMaxLength(500);
        builder.Property(x => x.Pan).HasMaxLength(40);
        builder.Property(x => x.BankAccount).HasMaxLength(80);
        builder.Property(x => x.SalaryBand).HasMaxLength(40);
        builder.Property(x => x.PfUan).HasMaxLength(40);
        builder.Property(x => x.TaxRegime).HasMaxLength(80);
        builder.Property(x => x.ComplianceStatus).HasMaxLength(80);

        builder.HasOne(x => x.Department)
            .WithMany()
            .HasForeignKey(x => x.DepartmentId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasOne(x => x.Designation)
            .WithMany()
            .HasForeignKey(x => x.DesignationId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasOne(x => x.NationalityRef)
            .WithMany()
            .HasForeignKey(x => x.NationalityId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.JobRole)
            .WithMany()
            .HasForeignKey(x => x.JobRoleId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.SalaryBandRef)
            .WithMany()
            .HasForeignKey(x => x.SalaryBandId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.ReportingManager)
            .WithMany()
            .HasForeignKey(x => x.ReportingManagerId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasOne(x => x.User)
            .WithMany()
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}

public sealed class ExitedEmployeeConfiguration : IEntityTypeConfiguration<ExitedEmployee>
{
    public void Configure(EntityTypeBuilder<ExitedEmployee> builder)
    {
        builder.ToTable("exited_employees");
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => x.OriginalEmployeeId);
        builder.HasIndex(x => x.EmployeeCode);
        builder.Property(x => x.EmployeeCode).HasMaxLength(20).IsRequired();
        builder.Property(x => x.FullName).HasMaxLength(255).IsRequired();
        builder.Property(x => x.DepartmentName).HasMaxLength(150);
        builder.Property(x => x.DesignationName).HasMaxLength(150);
        builder.Property(x => x.WorkEmail).HasMaxLength(255);
        builder.Property(x => x.PersonalEmail).HasMaxLength(255);
        builder.Property(x => x.Phone).HasMaxLength(40);
        builder.Property(x => x.StatusAtExit).HasMaxLength(60);
        builder.Property(x => x.ExitType).HasMaxLength(80);
        builder.Property(x => x.ExitReason).HasMaxLength(500);
        builder.Property(x => x.ReasonForLeaving).HasMaxLength(500);
        builder.Property(x => x.NoticePeriodServed).HasMaxLength(80);
        builder.Property(x => x.ExitChecklistJson).HasColumnType("jsonb");
        builder.Property(x => x.AssetReturnJson).HasColumnType("jsonb");
        builder.Property(x => x.FinalSettlementJson).HasColumnType("jsonb");
    }
}
