using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Shared.Common.Models;
using PMS.API.Modules.Auth.Models;
using PMS.API.Modules.Customers.Models;
using PMS.API.Modules.Repository.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Users.Models;

namespace PMS.API.Infrastructure.Persistence;

public class AppDbContext(
    DbContextOptions<AppDbContext> options,
    ICurrentUserService currentUser) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();

    public DbSet<Role> Roles => Set<Role>();

    public DbSet<RolePermissionAudit> RolePermissionAudits => Set<RolePermissionAudit>();

    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();

    public DbSet<Client> Clients => Set<Client>();

    public DbSet<SubVenture> SubVentures => Set<SubVenture>();

    public DbSet<ClientAssignment> ClientAssignments => Set<ClientAssignment>();

    public DbSet<ClientContactEntity> ClientContacts => Set<ClientContactEntity>();

    public DbSet<MstDepartment> Departments => Set<MstDepartment>();

    public DbSet<MstDesignation> Designations => Set<MstDesignation>();

    public DbSet<MstIndustry> Industries => Set<MstIndustry>();

    public DbSet<MstCountry> Countries => Set<MstCountry>();

    public DbSet<MstCity> Cities => Set<MstCity>();

    public DbSet<MstNationality> Nationalities => Set<MstNationality>();

    public DbSet<MstRole> JobRoles => Set<MstRole>();

    public DbSet<MstSalaryBand> SalaryBands => Set<MstSalaryBand>();

    public DbSet<MstEmailDomain> EmailDomains => Set<MstEmailDomain>();

    public DbSet<MstReportingManager> ReportingManagers => Set<MstReportingManager>();

    public DbSet<MstBusinessUnit> BusinessUnits => Set<MstBusinessUnit>();

    public DbSet<MstWorkLocation> WorkLocations => Set<MstWorkLocation>();

    public DbSet<MstOffice> Offices => Set<MstOffice>();

    public DbSet<MstEmployeeStatus> EmployeeStatuses => Set<MstEmployeeStatus>();

    public DbSet<Employee> Employees => Set<Employee>();

    public DbSet<ExitedEmployee> ExitedEmployees => Set<ExitedEmployee>();

    public DbSet<RepositoryItem> RepositoryItems => Set<RepositoryItem>();

    public DbSet<RepositoryActivityLog> RepositoryActivityLogs => Set<RepositoryActivityLog>();

    public DbSet<RepositoryDepartment> RepositoryDepartments => Set<RepositoryDepartment>();

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.ConfigureWarnings(w => w.Ignore(Microsoft.EntityFrameworkCore.Diagnostics.RelationalEventId.PendingModelChangesWarning));
        base.OnConfiguring(optionsBuilder);
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);

        // Global soft-delete filter — rows marked DeletedAtUtc are hidden everywhere.
        foreach (var entityType in modelBuilder.Model.GetEntityTypes())
        {
            entityType.AddSoftDeleteFilter();
        }

        base.OnModelCreating(modelBuilder);
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        var userId = currentUser.UserId;
        var now = DateTime.UtcNow;

        foreach (var entry in ChangeTracker.Entries<BaseEntity>())
        {
            switch (entry.State)
            {
                case EntityState.Added:
                    entry.Entity.CreatedAtUtc = now;
                    entry.Entity.CreatedBy ??= userId;
                    break;

                case EntityState.Modified:
                    entry.Entity.UpdatedAtUtc = now;
                    entry.Entity.UpdatedBy = userId;
                    break;

                // Soft delete: calling Remove() marks DeletedAtUtc instead of issuing a hard DELETE.
                case EntityState.Deleted:
                    entry.State = EntityState.Modified;
                    entry.Entity.DeletedAtUtc = now;
                    entry.Entity.UpdatedAtUtc = now;
                    entry.Entity.UpdatedBy = userId;
                    break;
            }
        }

        return base.SaveChangesAsync(cancellationToken);
    }
}
