using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;
using PMS.API.Shared.Constants;
using PMS.API.Modules.Customers.Models;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Repository.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Users.Models;
using PMS.API.Infrastructure.Authentication;

namespace PMS.API.Infrastructure.Persistence.Seeding;

/// <summary>
/// Seeds the RBAC roles (baseline permissions from the role matrix in
/// <c>RoleBaselines.cs</c>), demo users for every role and the 10 mock clients
/// with deterministic ids. Demo password for every seeded user: <c>Password@123</c>.
///
/// The seeder is idempotent and Development-only (see DbInitializerHostedService).
/// Custom roles created through the Settings UI are never touched. System roles
/// that still carry the pre-RBAC legacy permission set (no dot-notation keys)
/// are upgraded to their baseline once so existing databases pick up the matrix.
/// </summary>
public static class DbSeeder
{
    public const string DevPassword = "Password@123";

    /// <summary>
    /// Ensures <c>mst_employee_statuses</c> catalog rows exist. Runs on every API boot
    /// (not only full demo seed) so onboarding can load statuses from the DB.
    /// </summary>
    public static async Task EnsureEmployeeStatusesAsync(AppDbContext db, CancellationToken ct = default)
    {
        await SeedEmployeeStatusesAsync(db, ct);
        await db.SaveChangesAsync(ct);
    }

    public static async Task SeedAsync(AppDbContext db, IPasswordHasher hasher, CancellationToken ct = default)
    {
        // Each Seed* method is individually idempotent, so partial seeds self-heal.
        var roles = await SeedRolesAsync(db, ct);
        var users = await SeedUsersAsync(db, hasher, roles, ct);
        await SeedMasterCatalogsAsync(db, ct);
        await db.SaveChangesAsync(ct);
        await SeedDirectoryEmployeesAsync(db, ct);
        await db.SaveChangesAsync(ct);
        await SeedReportingManagersAsync(db, ct);
        await db.SaveChangesAsync(ct);
        await SeedClientsAsync(db, users, ct);
        await db.SaveChangesAsync(ct);
        await SeedProjectsAsync(db, ct);
        await db.SaveChangesAsync(ct);
        await SeedRepositoryAsync(db, ct);
        await db.SaveChangesAsync(ct);
    }

    // ---------- Roles ----------

    private static async Task<Dictionary<string, Role>> SeedRolesAsync(AppDbContext db, CancellationToken ct)
    {
        // Canonical system-role keys (UserRole enum names) + Admin.
        var roleKeys = Enum.GetNames<UserRole>().OrderBy(k => k).ToList();

        var existing = await db.Roles.ToDictionaryAsync(r => r.Name, ct);
        var roles = new Dictionary<string, Role>();

        foreach (var key in roleKeys)
        {
            if (existing.TryGetValue(key, out var found))
            {
                // Upgrade legacy-only roles (created before RBAC) to the baseline
                // once; custom roles and already-migrated roles are untouched.
                var hasDotKeys = found.Permissions.Any(p => p.Contains('.'));
                if (found.Permissions.Count == 0 || !hasDotKeys)
                {
                    found.Permissions = [.. RoleBaselines.For(key)];
                }

                found.DisplayName = DisplayName(key);
                found.Description ??= RoleDescription(key);
                found.IsSystemRole = true;
                found.IsActive = true;
                roles[key] = found;
                continue;
            }

            var entity = new Role
            {
                Name = key,
                DisplayName = DisplayName(key),
                Description = RoleDescription(key),
                IsSystemRole = true,
                IsActive = true,
                Permissions = [.. RoleBaselines.For(key)],
            };
            db.Roles.Add(entity);
            roles[key] = entity;
        }

        return roles;
    }

    private static string DisplayName(string key) => key switch
    {
        nameof(UserRole.SeniorPm) => "Senior Project Manager",
        nameof(UserRole.EngagementManager) => "Engagement Manager",
        nameof(UserRole.Pmo) => "PMO",
        nameof(UserRole.Hod) => "HOD",
        nameof(UserRole.BusinessOwner) => "Business Owner",
        nameof(UserRole.Dhanshree) => "Admin (Dhanshree)",
        nameof(UserRole.Sales) => "Sales & Business Development",
        nameof(UserRole.Accounts) => "Accounts & Finance",
        nameof(UserRole.Hr) => "HR",
        nameof(UserRole.ProjectManager) => "Project Manager",
        nameof(UserRole.TeamLead) => "Team Lead",
        nameof(UserRole.Employee) => "Employee",
        nameof(UserRole.Admin) => "Admin",
        _ => key,
    };

    private static string RoleDescription(string key) => key switch
    {
        nameof(UserRole.Admin) => "Super-admin — full access to every module, submodule and action.",
        nameof(UserRole.Dhanshree) => "Super-admin (legacy account) — full access to every module.",
        nameof(UserRole.SeniorPm) => "Owns delivery of assigned projects; approves PM timesheets.",
        nameof(UserRole.EngagementManager) => "Owns customer relationship and delivery for assigned accounts.",
        nameof(UserRole.Pmo) => "Governance, WBS allocation and timesheet monitoring (view-oriented).",
        nameof(UserRole.Hod) => "Department oversight across projects, resources and approvals.",
        nameof(UserRole.BusinessOwner) => "Executive oversight of the project portfolio.",
        nameof(UserRole.ProjectManager) => "Runs assigned projects end-to-end; approves team timesheets.",
        nameof(UserRole.TeamLead) => "Leads a delivery team; submits timesheets and raises issues.",
        nameof(UserRole.Employee) => "Executes assigned tasks; submits own timesheets.",
        nameof(UserRole.Hr) => "HR resource/directory management only.",
        nameof(UserRole.Accounts) => "Finance — invoices, payments and finance reports.",
        nameof(UserRole.Sales) => "Sales & business development — new projects and customers.",
        _ => key,
    };

    // ---------- Users ----------

    private static async Task<Dictionary<string, User>> SeedUsersAsync(
        AppDbContext db, IPasswordHasher hasher, Dictionary<string, Role> roles, CancellationToken ct)
    {
        var seed = new (string Id, string Name, string Email, string Avatar, string Role)[]
        {
            ("u1", "Aarav Mehta", "aarav@acme.co", "AM", nameof(UserRole.SeniorPm)),
            ("u2", "Riya Kapoor", "riya@acme.co", "RK", nameof(UserRole.EngagementManager)),
            ("u3", "Vikram Shah", "vikram@acme.co", "VS", nameof(UserRole.ProjectManager)),
            ("u4", "Sana Iyer", "sana@acme.co", "SI", nameof(UserRole.ProjectManager)),
            ("u5", "Nikhil Rao", "nikhil@acme.co", "NR", nameof(UserRole.TeamLead)),
            ("u6", "Priya Verma", "priya@acme.co", "PV", nameof(UserRole.TeamLead)),
            ("u7", "Arjun Singh", "arjun@acme.co", "AS", nameof(UserRole.Employee)),
            ("u8", "Meera Joshi", "meera@acme.co", "MJ", nameof(UserRole.Employee)),
            ("u9", "Dev Patel", "dev@acme.co", "DP", nameof(UserRole.Employee)),
            ("u10", "Kavya Nair", "kavya@acme.co", "KN", nameof(UserRole.Employee)),
            ("u11", "Rahul Gupta", "rahul@acme.co", "RG", nameof(UserRole.Pmo)),
            ("u12", "Anita Desai", "anita@acme.co", "AD", nameof(UserRole.Hod)),
            ("u13", "Vikrant Malhotra", "vikrant@acme.co", "VM", nameof(UserRole.BusinessOwner)),
            ("u14", "Dhanshree", "dhanshree@acme.co", "DS", nameof(UserRole.Dhanshree)),
            // Test users for the RBAC roles that previously had no seeded account.
            ("u15", "Admin User", "admin@acme.co", "AU", nameof(UserRole.Admin)),
            ("u16", "HR User", "hr@acme.co", "HU", nameof(UserRole.Hr)),
            ("u17", "Accounts User", "accounts@acme.co", "AC", nameof(UserRole.Accounts)),
            ("u18", "Sales User", "sales@acme.co", "SU", nameof(UserRole.Sales)),
        };

        // Some imported/legacy user rows have NULL PasswordHash. The User entity
        // maps it as non-nullable string, so materializing those rows crashes startup.
        await db.Database.ExecuteSqlRawAsync(
            """UPDATE users SET "PasswordHash" = '' WHERE "PasswordHash" IS NULL""",
            ct);

        var existing = await db.Users.ToDictionaryAsync(u => u.EmployeeId, ct);
        var users = new Dictionary<string, User>();

        for (var i = 0; i < seed.Length; i++)
        {
            var (id, name, email, avatar, role) = seed[i];

            if (existing.TryGetValue(id, out var found))
            {
                // Keep the demo environment testable: every seeded account always
                // signs in with the same dev password and is never forced to change it.
                found.PasswordHash = hasher.Hash(DevPassword);
                found.MustChangePassword = false;
                found.IsActive = true;
                if (roles.TryGetValue(role, out var roleEntity)) found.RoleId = roleEntity.Id;
                users[id] = found;
                continue;
            }

            var user = new User
            {
                Id = StableGuid("user-" + id),
                Email = email,
                Name = name,
                Avatar = avatar,
                EmployeeId = id,
                RoleId = roles[role].Id,
                PasswordHash = hasher.Hash(DevPassword), // per-user salt
                MustChangePassword = false,
                IsActive = true,
            };
            db.Users.Add(user);
            users[id] = user;
        }

        return users;
    }

    // ---------- Master catalogs ----------

    private static async Task SeedMasterCatalogsAsync(AppDbContext db, CancellationToken ct)
    {
        var departments = new[]
        {
            ("core", "Core"),
            ("functional_it_administration", "Functional - IT Administration"),
            ("functional_accounts", "Functional - Accounts"),
            ("functional_hr", "Functional - HR"),
            ("functional_sales", "Functional - Sales"),
            ("functional_project_management", "Functional - Project Management"),
            ("rd_research_and_development", "R&D (Research & Development)"),
            ("services_operations", "Services - Operations"),
            ("services_consulting", "Services - Consulting"),
            ("services_testing", "Services - Testing"),
        };

        // Ignore the soft-delete query filter when checking existence: a seed
        // department the user has since removed is soft-deleted (DeletedAtUtc set)
        // but still occupies its unique Code, so a plain insert would collide with
        // IX_mst_departments_Code. Skip any code that already exists in any state —
        // we never resurrect a department the user intentionally deleted.
        var existingDepartments = await db.Departments
            .IgnoreQueryFilters()
            .ToDictionaryAsync(d => d.Code, ct);
        foreach (var (code, name) in departments)
        {
            if (existingDepartments.ContainsKey(code)) continue;
            var department = new MstDepartment
            {
                Code = code,
                Name = name,
                IsActive = true,
            };
            db.Departments.Add(department);
            existingDepartments[code] = department;
        }

        var oldSampleCodes = new[] { "product", "design", "marketing", "sales", "finance", "human_resources", "operations", "engineering", "delivery", "leadership" };
        var obsoleteDepts = await db.Departments.Where(d => oldSampleCodes.Contains(d.Code)).ToListAsync(ct);
        if (obsoleteDepts.Count > 0)
        {
            db.Departments.RemoveRange(obsoleteDepts);
        }

        var existingIndustries = await db.Industries
            .IgnoreQueryFilters()
            .ToListAsync(ct);
        var industries = new[]
        {
            ("banking", "Banking"),
            ("healthcare", "Healthcare"),
            ("retail", "Retail"),
            ("logistics", "Logistics"),
            ("energy", "Energy"),
            ("manufacturing", "Manufacturing"),
            ("telecom", "Telecom"),
            ("media", "Media"),
        };
        var canonicalCodes = industries.Select(i => i.Item1).ToHashSet(StringComparer.OrdinalIgnoreCase);
        foreach (var (code, name) in industries)
        {
            var existing = existingIndustries.FirstOrDefault(i =>
                string.Equals(i.Code, code, StringComparison.OrdinalIgnoreCase)
                || string.Equals(i.Name, name, StringComparison.OrdinalIgnoreCase));
            if (existing is not null)
            {
                existing.Code = code;
                existing.Name = name;
                existing.IsActive = true;
                continue;
            }

            var row = new MstIndustry
            {
                Code = code,
                Name = name,
                IsActive = true,
            };
            db.Industries.Add(row);
            existingIndustries.Add(row);
        }

        foreach (var extra in existingIndustries)
        {
            if (!canonicalCodes.Contains(extra.Code))
                extra.IsActive = false;
        }

        await SeedContactDesignationsAsync(db, ct);
        await SeedContactTypesAsync(db, ct);
        await SeedNationalitiesAsync(db, ct);
        await SeedSalaryBandsAsync(db, ct);
        var existingDesignations = await db.Designations.ToDictionaryAsync(d => d.Code, ct);
        await SeedJobRolesAsync(db, existingDesignations, ct);
        await SeedGeoCatalogsAsync(db, ct);
        await SeedEmailDomainsAsync(db, ct);
        await SeedBusinessUnitsAsync(db, ct);
        await SeedEmployeeStatusesAsync(db, ct);
        await SeedWorkLocationsAndOfficesAsync(db, ct);
        await SeedCertificationsAsync(db, ct);
        await SeedGraduationDegreesAsync(db, ct);
        await SeedPostGraduationDegreesAsync(db, ct);
    }

    private static async Task SeedEmployeeStatusesAsync(AppDbContext db, CancellationToken ct)
    {
        var statuses = new (string Code, string Name, bool AllowOnboarding, int SortOrder)[]
        {
            ("active", "Active", true, 1),
            ("terminated", "Terminated", false, 2),
            ("absconded", "Absconded", false, 3),
            ("resigned", "Resigned", false, 4),
            ("resignation_under_review", "Resignation Under Review", false, 5),
        };

        var existing = await db.EmployeeStatuses
            .IgnoreQueryFilters()
            .ToDictionaryAsync(s => s.Code, StringComparer.OrdinalIgnoreCase, ct);

        foreach (var (code, name, allowOnboarding, sortOrder) in statuses)
        {
            if (existing.ContainsKey(code)) continue;
            db.EmployeeStatuses.Add(new MstEmployeeStatus
            {
                Code = code,
                Name = name,
                IsActive = true,
                AllowOnboarding = allowOnboarding,
                SortOrder = sortOrder,
            });
        }
    }

    private static async Task SeedContactDesignationsAsync(AppDbContext db, CancellationToken ct)
    {
        var rows = new (string Code, string Name, int SortOrder)[]
        {
            ("spoc", "SPOC", 1),
            ("ciso", "CISO", 2),
            ("cio", "CIO", 3),
            ("cfo", "CFO", 4),
            ("accounts_head", "Accounts Head", 5),
        };
        var existing = await db.ContactDesignations
            .IgnoreQueryFilters()
            .ToDictionaryAsync(d => d.Code, ct);
        foreach (var (code, name, sortOrder) in rows)
        {
            if (existing.ContainsKey(code)) continue;
            db.ContactDesignations.Add(new MstContactDesignation
            {
                Code = code,
                Name = name,
                IsActive = true,
                SortOrder = sortOrder,
            });
        }
    }

    private static async Task SeedContactTypesAsync(AppDbContext db, CancellationToken ct)
    {
        var rows = new (string Code, string Name, int SortOrder)[]
        {
            ("accounts", "Accounts", 1),
            ("procurement", "Procurement", 2),
            ("technical", "Technical", 3),
            ("legal", "Legal", 4),
        };
        var existing = await db.ContactTypes
            .IgnoreQueryFilters()
            .ToListAsync(ct);
        foreach (var (code, name, sortOrder) in rows)
        {
            var row = existing.FirstOrDefault(t =>
                string.Equals(t.Code, code, StringComparison.OrdinalIgnoreCase)
                || string.Equals(t.Name, name, StringComparison.OrdinalIgnoreCase));
            if (row is not null)
            {
                row.Code = code;
                row.Name = name;
                row.IsActive = true;
                row.SortOrder = sortOrder;
                continue;
            }

            db.ContactTypes.Add(new MstContactType
            {
                Code = code,
                Name = name,
                IsActive = true,
                SortOrder = sortOrder,
            });
        }
    }

    private static async Task SeedBusinessUnitsAsync(AppDbContext db, CancellationToken ct)
    {
        var bus = new[] { "Talakunchi Networks Private Limited" };
        var existing = await db.BusinessUnits.ToDictionaryAsync(b => b.Name.ToLower(), ct);
        var order = 1;
        foreach (var name in bus)
        {
            if (existing.ContainsKey(name.ToLower())) continue;
            db.BusinessUnits.Add(new MstBusinessUnit
            {
                Code = Slug(name),
                Name = name,
                IsActive = true,
                SortOrder = order++,
            });
        }
    }

    private static async Task SeedWorkLocationsAndOfficesAsync(AppDbContext db, CancellationToken ct)
    {
        var locations = new (string Code, string Name)[]
        {
            ("onsite", "Onsite"),
            ("suvidha_square_andheri", "Suvidha Square, Andheri"),
            ("navare_plaza_dombivli", "Navare Plaza, Dombivli"),
        };

        var existingLocations = await db.WorkLocations.ToListAsync(ct);
        var allowedCodes = locations.Select(l => l.Code).ToHashSet(StringComparer.OrdinalIgnoreCase);

        foreach (var loc in existingLocations)
        {
            if (!allowedCodes.Contains(loc.Code))
            {
                loc.IsActive = false;
            }
        }

        var locDict = existingLocations.ToDictionary(w => w.Code, StringComparer.OrdinalIgnoreCase);
        var locOrder = 1;
        foreach (var (code, name) in locations)
        {
            if (!locDict.TryGetValue(code, out var loc))
            {
                loc = new MstWorkLocation
                {
                    Code = code,
                    Name = name,
                    IsActive = true,
                    SortOrder = locOrder++,
                };
                db.WorkLocations.Add(loc);
                locDict[code] = loc;
            }
            else
            {
                loc.Name = name;
                loc.IsActive = true;
                loc.SortOrder = locOrder++;
            }
        }
    }

    private static async Task SeedEmailDomainsAsync(AppDbContext db, CancellationToken ct)
    {
        var domains = new (string Code, string Domain, string Display, int Order)[]
        {
            ("talakunchi_com", "talakunchi.com", "@talakunchi.com", 1),
            ("talakunchi_in", "talakunchi.in", "@talakunchi.in", 2),
            ("squad1_io", "squad1.io", "@squad1.io", 3),
        };

        var existing = await db.EmailDomains.ToDictionaryAsync(d => d.DomainName, ct);
        foreach (var (code, domain, display, order) in domains)
        {
            if (existing.ContainsKey(domain)) continue;
            db.EmailDomains.Add(new MstEmailDomain
            {
                Code = code,
                DomainName = domain,
                DisplayName = display,
                IsActive = true,
                SortOrder = order,
            });
        }
    }

    private static async Task SeedReportingManagersAsync(AppDbContext db, CancellationToken ct)
    {
        var existingCodes = await db.ReportingManagers.Select(m => m.Code).ToHashSetAsync(ct);
        var existingNames = await db.ReportingManagers.Select(m => m.Name.ToLower()).ToHashSetAsync(ct);

        // 1. Copy key employees holding leadership/managerial designations into mst_reporting_managers
        var candidates = await db.Employees
            .Include(e => e.Designation)
            .Where(e => e.DeletedAtUtc == null && e.Status == "Active")
            .OrderBy(e => e.FirstName)
            .ThenBy(e => e.LastName)
            .ToListAsync(ct);

        var order = 1;
        foreach (var emp in candidates)
        {
            var fullName = $"{emp.FirstName} {emp.LastName}".Trim();
            if (string.IsNullOrWhiteSpace(fullName)) continue;
            var code = Slug(fullName);
            if (existingNames.Contains(fullName.ToLower()) || existingCodes.Contains(code))
                continue;

            var desig = emp.Designation?.Name ?? emp.Role ?? "";
            var isLeadOrManager = desig.Contains("Lead", StringComparison.OrdinalIgnoreCase) ||
                                  desig.Contains("Manager", StringComparison.OrdinalIgnoreCase) ||
                                  desig.Contains("Director", StringComparison.OrdinalIgnoreCase) ||
                                  desig.Contains("Head", StringComparison.OrdinalIgnoreCase) ||
                                  desig.Contains("VP", StringComparison.OrdinalIgnoreCase) ||
                                  order <= 6;

            if (isLeadOrManager)
            {
                db.ReportingManagers.Add(new MstReportingManager
                {
                    Code = code,
                    Name = fullName,
                    Designation = desig,
                    Email = emp.WorkEmail,
                    EmployeeId = emp.Id,
                    IsActive = true,
                    SortOrder = order++,
                });
                existingCodes.Add(code);
                existingNames.Add(fullName.ToLower());
            }
        }

        // 2. Default seeded managers if none were added
        var defaults = new (string Name, string Desig, string Email)[]
        {
            ("Dhanshree Pansare", "Director & Delivery Head", "dhanshree.pansare@acme.co"),
            ("Sneha Iyer", "Tech Lead", "sneha.iyer@acme.co"),
            ("Divya Rao", "Product Manager", "divya.rao@acme.co"),
            ("Neha Kulkarni", "Technical Lead", "neha.kulkarni@acme.co"),
            ("Samar Patel", "HR Business Partner", "samar.patel@acme.co"),
            ("Aanya Joshi", "Sales Executive", "aanya.joshi@acme.co"),
            ("Harsh Nair", "Business Analyst", "harsh.nair@acme.co"),
            ("Vikram Gupta", "Project Manager", "vikram.gupta@acme.co"),
            ("Pooja Menon", "HR Business Partner", "pooja.menon@acme.co"),
            ("Nikhil Khanna", "Sales Executive", "nikhil.khanna@acme.co"),
            ("Riya Kapoor", "Engagement Manager", "riya.kapoor@acme.co"),
            ("Rahul Sharma", "Engagement Manager", "rahul.sharma@acme.co"),
            ("Pradeep Singh", "Engagement Manager", "pradeep.singh@acme.co"),
            ("Arjun Mehta", "Engagement Manager", "arjun.mehta@acme.co"),
        };

        foreach (var (name, desig, email) in defaults)
        {
            var code = Slug(name);
            if (existingNames.Contains(name.ToLower()) || existingCodes.Contains(code))
                continue;

            db.ReportingManagers.Add(new MstReportingManager
            {
                Code = code,
                Name = name,
                Designation = desig,
                Email = email,
                IsActive = true,
                SortOrder = order++,
            });
            existingCodes.Add(code);
            existingNames.Add(name.ToLower());
        }
    }

    private static async Task SeedNationalitiesAsync(AppDbContext db, CancellationToken ct)
    {
        var nationalities = new[]
        {
            ("indian", "Indian"),
            ("american", "American"),
            ("british", "British"),
            ("canadian", "Canadian"),
            ("australian", "Australian"),
            ("german", "German"),
            ("french", "French"),
            ("emirati", "Emirati"),
            ("singaporean", "Singaporean"),
            ("japanese", "Japanese"),
            ("chinese", "Chinese"),
            ("south_korean", "South Korean"),
            ("brazilian", "Brazilian"),
            ("mexican", "Mexican"),
            ("south_african", "South African"),
            ("irish", "Irish"),
            ("dutch", "Dutch"),
            ("swedish", "Swedish"),
            ("italian", "Italian"),
            ("spanish", "Spanish"),
            ("filipino", "Filipino"),
            ("indonesian", "Indonesian"),
            ("thai", "Thai"),
            ("vietnamese", "Vietnamese"),
            ("bangladeshi", "Bangladeshi"),
            ("sri_lankan", "Sri Lankan"),
            ("nepali", "Nepali"),
            ("pakistani", "Pakistani"),
            ("malaysian", "Malaysian"),
            ("saudi", "Saudi"),
            ("qatari", "Qatari"),
            ("new_zealander", "New Zealander"),
            ("swiss", "Swiss"),
            ("polish", "Polish"),
            ("austrian", "Austrian"),
            ("belgian", "Belgian"),
            ("danish", "Danish"),
            ("norwegian", "Norwegian"),
            ("finnish", "Finnish"),
            ("portuguese", "Portuguese"),
        };

        var existing = await db.Nationalities.ToDictionaryAsync(n => n.Code, ct);
        foreach (var (code, name) in nationalities)
        {
            if (existing.ContainsKey(code)) continue;
            db.Nationalities.Add(new MstNationality
            {
                Code = code,
                Name = name,
                IsActive = true,
            });
        }
    }

    private static async Task SeedSalaryBandsAsync(AppDbContext db, CancellationToken ct)
    {
        var bands = new[] { "L1", "L2", "L3", "L4", "L5" };
        var existing = await db.SalaryBands.ToDictionaryAsync(b => b.Code, ct);
        foreach (var name in bands)
        {
            var code = name.ToLowerInvariant();
            if (existing.ContainsKey(code)) continue;
            db.SalaryBands.Add(new MstSalaryBand
            {
                Code = code,
                Name = name,
                IsActive = true,
            });
        }
    }

    private static async Task SeedJobRolesAsync(
        AppDbContext db,
        IReadOnlyDictionary<string, MstDesignation> designations,
        CancellationToken ct)
    {
        var onFloorRolesByDesignation = new Dictionary<string, string[]>(StringComparer.OrdinalIgnoreCase)
        {
            ["Director and Chief Executive Officer"] = ["Leader (L)"],
            ["Director and Chief Operating Officer"] = ["Leader (L)"],
            ["Director and Chief Technology Officer"] = ["Leader (L)"],
            ["IT Admin"] = ["Team Member (TM)"],
            ["Desktop Support Engineer - I"] = ["Team Member (TM)"],
            ["Desktop Support Engineer - II"] = ["Team Member (TM)"],
            ["Accountant - I"] = ["Manager (Mng.)"],
            ["Accountant - II"] = ["Manager (Mng.)"],
            ["Accountant - III"] = ["Manager (Mng.)"],
            ["Senior Accountant - I"] = ["Manager (Mng.)"],
            ["Senior Accountant - II"] = ["Manager (Mng.)"],
            ["Senior Accountant - III"] = ["Manager (Mng.)"],
            ["HR Head"] = ["HR"],
            ["Recruitment Coordinator - I"] = ["HR"],
            ["Recruitment Coordinator - II"] = ["HR"],
            ["Senior HR Executive - I"] = ["HR"],
            ["Senior HR Executive - II"] = ["HR"],
            ["Business Development Associate - I"] = ["Manager (Mng.)"],
            ["Customer Success Representative - II"] = ["Manager (Mng.)"],
            ["Director - Product Sales"] = ["Team Member (TM)"],
            ["Sales Associate"] = ["Team Member (TM)"],
            ["Associate Customer Success Representative - I"] = ["Team Member (TM)"],
            ["Associate Customer Success Representative - II"] = ["Team Member (TM)"],
            ["Associate PMO - I"] = ["Team Member (TM)"],
            ["Associate PMO - II"] = ["Team Member (TM)"],
            ["Senior PMO - I"] = ["Team Leader (TL)"],
            ["Senior PMO - II"] = ["Manager (Mng.)"],
            ["Delivery Account Manager - I"] = ["Team Member (TM)"],
            ["Delivery Account Manager - II"] = ["Team Member (TM)"],
            ["Senior Delivery Account Manager - I"] = ["Team Leader (TL)"],
            ["Senior Delivery Account Manager - II"] = ["Manager (Mng.)"],
            ["Python Developer - I"] = ["Team Member (TM)"],
            ["Python Developer - II"] = ["Team Member (TM)"],
            ["Python Developer - III"] = ["Team Member (TM)"],
            ["SOC Analyst - I"] = ["Team Member (TM)"],
            ["SOC Analyst - II"] = ["Team Member (TM)"],
            ["SOC Analyst - III"] = ["Team Member (TM)"],
            ["SOC Analyst - IV"] = ["Team Member (TM)"],
            ["SIEM Admin - I"] = ["Team Member (TM)"],
            ["SIEM Admin - II"] = ["Team Member (TM)"],
            ["SIEM Admin - III"] = ["Team Member (TM)"],
            ["SIEM Admin - IV"] = ["Team Member (TM)"],
            ["SOC Consultant - I"] = ["Team Member (TM)"],
            ["SOC Consultant - II"] = ["Team Member (TM)"],
            ["SOC Shift Lead - I"] = ["Team Leader (TL)"],
            ["SOC Shift Lead - II"] = ["Team Leader (TL)"],
            ["SOC Lead - I"] = ["Team Leader (TL)"],
            ["SOC Lead - II"] = ["Team Leader (TL)"],
            ["GRC Auditor - I"] = ["Team Member (TM)"],
            ["GRC Auditor - II"] = ["Team Member (TM)"],
            ["GRC Auditor - III"] = ["Team Member (TM)"],
            ["GRC Auditor - IV"] = ["Team Member (TM)"],
            ["Senior GRC Auditor - I"] = ["Team Leader (TL)"],
            ["Senior GRC Auditor - II"] = ["Team Leader (TL)"],
            ["Associate Manager - III"] = ["Manager (Mng.)", "Team Leader (TL)"],
            ["Principal Manager - I"] = ["Sr. Manager (Sr.Mng.)"],
            ["Senior Vice President - Principal Consultant"] = ["Head Of Department (HOD)"],
            ["PenTester - I"] = ["Team Member (TM)"],
            ["PenTester - II"] = ["Team Member (TM)"],
            ["PenTester - III"] = ["Team Member (TM)"],
            ["PenTester - IV"] = ["Team Member (TM)"],
            ["Senior Pentester - I"] = ["Team Member (TM)"],
            ["Senior Pentester - II"] = ["Team Member (TM)"],
            ["Associate Manager - I"] = ["Team Leader (TL)"],
            ["Associate Manager - II"] = ["Team Leader (TL)"],
            ["Associate Project Manager"] = ["Manager (Mng.)"],
            ["Manager - I"] = ["Sr. Manager (Sr.Mng.)"],
            ["DevSecOps Practitioner - I"] = ["Team Member (TM)"],
            ["DevSecOps Practitioner - II"] = ["Team Member (TM)"],
            ["DevSecOps Practitioner - III"] = ["Team Member (TM)"],
            ["DevSecOps Associate"] = ["Team Leader (TL)"],
            ["DevSecOps Specialist - II"] = ["Manager (Mng.)"],
            ["Red Team Practitioner - II"] = ["Team Member (TM)"],
            ["Red Team Practitioner - III"] = ["Team Member (TM)"],
            ["Red Team Specialist - II"] = ["Manager (Mng.)"],
            ["Senior Cloud Security Consultant - I"] = ["Manager (Mng.)"],
            ["Associate AI Engineer - Contractual"] = ["Team Member (TM)"],
            ["Intern"] = ["Team Member (TM)"],
        };

        var allDesignations = await db.Designations.ToListAsync(ct);
        var existingCodes = await db.JobRoles.Select(r => r.Code).ToHashSetAsync(ct);
        var existingPairs = await db.JobRoles
            .Select(r => new { r.DesignationId, r.Name })
            .ToListAsync(ct);
        var existingKeys = existingPairs
            .Select(r => (r.DesignationId, r.Name))
            .ToHashSet();

        foreach (var desig in allDesignations)
        {
            if (!onFloorRolesByDesignation.TryGetValue(desig.Name.Trim(), out var names)) continue;
            foreach (var name in names)
            {
                if (existingKeys.Contains((desig.Id, name))) continue;
                var roleCode = Truncate($"{desig.Code}_{Slug(name)}", 80);
                var n = 2;
                while (existingCodes.Contains(roleCode))
                {
                    var suffix = $"_{n}";
                    roleCode = Truncate(desig.Code + "_" + Slug(name), 80 - suffix.Length) + suffix;
                    n++;
                }

                db.JobRoles.Add(new MstRole
                {
                    Code = roleCode,
                    Name = name,
                    DesignationId = desig.Id,
                    IsActive = true,
                });
                existingCodes.Add(roleCode);
                existingKeys.Add((desig.Id, name));
            }
        }
    }

    private static string Truncate(string value, int max) =>
        value.Length <= max ? value : value[..max].Trim('_');

    private static async Task SeedGeoCatalogsAsync(AppDbContext db, CancellationToken ct)
    {
        var geo = new (string Code, string Name, string[] Cities)[]
        {
            ("IN", "India",
            [
                "Mumbai", "Delhi", "Bengaluru", "Hyderabad", "Chennai", "Kolkata", "Pune",
                "Ahmedabad", "Jaipur", "Surat", "Lucknow", "Noida", "Gurugram", "Chandigarh",
                "Kochi", "Thiruvananthapuram", "Coimbatore", "Indore", "Bhopal", "Nagpur",
                "Visakhapatnam", "Bhubaneswar", "Guwahati", "Patna", "Ranchi", "Dehradun",
                "Mysuru", "Mangaluru", "Vadodara", "Nashik", "Aurangabad", "Rajkot",
                "Jodhpur", "Udaipur", "Amritsar", "Ludhiana", "Kanpur", "Varanasi",
                "Prayagraj", "Raipur", "Vijayawada", "Madurai", "Tiruchirappalli",
                "Hubballi", "Warangal", "Guntur", "Jamshedpur", "Kalyan-Dombivli",
                "Navi Mumbai", "Thane",
            ]),
            ("US", "United States",
            [
                "New York", "San Francisco", "Seattle", "Austin", "Chicago", "Boston",
                "Los Angeles", "Dallas", "Atlanta", "Washington DC",
            ]),
            ("GB", "United Kingdom", ["London", "Manchester", "Birmingham", "Edinburgh", "Bristol"]),
            ("AE", "United Arab Emirates", ["Dubai", "Abu Dhabi", "Sharjah"]),
            ("SG", "Singapore", ["Singapore"]),
            ("DE", "Germany", ["Berlin", "Munich", "Frankfurt", "Hamburg"]),
            ("AU", "Australia", ["Sydney", "Melbourne", "Brisbane", "Perth"]),
            ("CA", "Canada", ["Toronto", "Vancouver", "Montreal"]),
            ("NL", "Netherlands", ["Amsterdam", "Rotterdam"]),
            ("JP", "Japan", ["Tokyo", "Osaka", "Yokohama"]),
            ("FR", "France", ["Paris", "Lyon"]),
            ("SA", "Saudi Arabia", ["Riyadh", "Jeddah", "Dammam"]),
            ("QA", "Qatar", ["Doha"]),
            ("MY", "Malaysia", ["Kuala Lumpur", "Penang"]),
            ("ZA", "South Africa", ["Johannesburg", "Cape Town"]),
            ("IE", "Ireland", ["Dublin"]),
            ("CH", "Switzerland", ["Zurich", "Geneva"]),
            ("SE", "Sweden", ["Stockholm", "Gothenburg"]),
            ("CN", "China", ["Shanghai", "Beijing", "Shenzhen"]),
            ("KR", "South Korea", ["Seoul", "Busan"]),
            ("NZ", "New Zealand", ["Auckland", "Wellington"]),
            ("PH", "Philippines", ["Manila", "Cebu"]),
            ("ID", "Indonesia", ["Jakarta", "Surabaya"]),
            ("TH", "Thailand", ["Bangkok"]),
            ("VN", "Vietnam", ["Ho Chi Minh City", "Hanoi"]),
            ("BD", "Bangladesh", ["Dhaka", "Chittagong"]),
            ("LK", "Sri Lanka", ["Colombo"]),
            ("NP", "Nepal", ["Kathmandu"]),
            ("PK", "Pakistan", ["Karachi", "Lahore", "Islamabad"]),
            ("BR", "Brazil", ["Sao Paulo", "Rio de Janeiro"]),
            ("MX", "Mexico", ["Mexico City", "Monterrey"]),
            ("IT", "Italy", ["Milan", "Rome"]),
            ("ES", "Spain", ["Madrid", "Barcelona"]),
            ("PL", "Poland", ["Warsaw", "Krakow"]),
            ("AT", "Austria", ["Vienna"]),
            ("BE", "Belgium", ["Brussels"]),
            ("DK", "Denmark", ["Copenhagen"]),
            ("NO", "Norway", ["Oslo"]),
            ("FI", "Finland", ["Helsinki"]),
            ("PT", "Portugal", ["Lisbon"]),
        };

        var dialByCode = new Dictionary<string, (string PhoneCode, int PhoneDigits)>(StringComparer.OrdinalIgnoreCase)
        {
            ["IN"] = ("+91", 10), ["US"] = ("+1", 10), ["GB"] = ("+44", 10),
            ["AE"] = ("+971", 9), ["SG"] = ("+65", 8), ["DE"] = ("+49", 11),
            ["AU"] = ("+61", 9), ["CA"] = ("+1", 10), ["NL"] = ("+31", 9),
            ["JP"] = ("+81", 10), ["FR"] = ("+33", 9), ["SA"] = ("+966", 9),
            ["QA"] = ("+974", 8), ["MY"] = ("+60", 9), ["ZA"] = ("+27", 9),
            ["IE"] = ("+353", 9), ["CH"] = ("+41", 9), ["SE"] = ("+46", 9),
            ["CN"] = ("+86", 11), ["KR"] = ("+82", 10), ["NZ"] = ("+64", 9),
            ["PH"] = ("+63", 10), ["ID"] = ("+62", 10), ["TH"] = ("+66", 9),
            ["VN"] = ("+84", 9), ["BD"] = ("+880", 10), ["LK"] = ("+94", 9),
            ["NP"] = ("+977", 10), ["PK"] = ("+92", 10), ["BR"] = ("+55", 11),
            ["MX"] = ("+52", 10), ["IT"] = ("+39", 10), ["ES"] = ("+34", 9),
            ["PL"] = ("+48", 9), ["AT"] = ("+43", 10), ["BE"] = ("+32", 9),
            ["DK"] = ("+45", 8), ["NO"] = ("+47", 8), ["FI"] = ("+358", 9),
            ["PT"] = ("+351", 9),
        };

        var existingCountries = await db.Countries.ToDictionaryAsync(c => c.Code, ct);
        foreach (var (code, name, _) in geo)
        {
            dialByCode.TryGetValue(code, out var dial);
            var phoneCode = string.IsNullOrWhiteSpace(dial.PhoneCode) ? "+91" : dial.PhoneCode;
            var phoneDigits = dial.PhoneDigits == 0 ? 10 : dial.PhoneDigits;

            if (existingCountries.TryGetValue(code, out var existing))
            {
                existing.PhoneCode = phoneCode;
                existing.PhoneDigits = phoneDigits;
                continue;
            }

            var country = new MstCountry
            {
                Code = code,
                Name = name,
                PhoneCode = phoneCode,
                PhoneDigits = phoneDigits,
                IsActive = true,
            };
            db.Countries.Add(country);
            existingCountries[code] = country;
        }

        if (db.ChangeTracker.HasChanges())
        {
            await db.SaveChangesAsync(ct);
        }

        var existingCityCodes = await db.Cities.Select(c => c.Code).ToHashSetAsync(ct);
        foreach (var (countryCode, _, cities) in geo)
        {
            if (!existingCountries.TryGetValue(countryCode, out var country)) continue;
            foreach (var cityName in cities)
            {
                var cityCode = $"{countryCode.ToLowerInvariant()}_{Slug(cityName)}";
                if (existingCityCodes.Contains(cityCode)) continue;
                db.Cities.Add(new MstCity
                {
                    Code = cityCode,
                    Name = cityName,
                    CountryId = country.Id,
                    IsActive = true,
                });
                existingCityCodes.Add(cityCode);
            }
        }
    }

    private static string Slug(string value)
    {
        var chars = value.Trim().ToLowerInvariant()
            .Select(c => char.IsLetterOrDigit(c) ? c : '_')
            .ToArray();
        var slug = new string(chars);
        while (slug.Contains("__", StringComparison.Ordinal))
        {
            slug = slug.Replace("__", "_", StringComparison.Ordinal);
        }

        return slug.Trim('_');
    }

    private static async Task SeedDirectoryEmployeesAsync(AppDbContext db, CancellationToken ct)
    {
        // Designation/department Names are not unique (e.g. many departments each have an
        // "Intern" designation with distinct codes), so dedup by name and keep the first match.
        var departments = (await db.Departments.ToListAsync(ct))
            .GroupBy(d => d.Name, StringComparer.OrdinalIgnoreCase)
            .ToDictionary(g => g.Key, g => g.First(), StringComparer.OrdinalIgnoreCase);
        var designations = (await db.Designations.ToListAsync(ct))
            .GroupBy(d => d.Name, StringComparer.OrdinalIgnoreCase)
            .ToDictionary(g => g.Key, g => g.First(), StringComparer.OrdinalIgnoreCase);
        var indian = await db.Nationalities.FirstOrDefaultAsync(n => n.Code == "indian", ct);
        var jobRoles = await db.JobRoles.ToListAsync(ct);

        var seed = new (string Code, string FirstName, string LastName, string Department, string Designation, string Role, string Gender)[]
        {
            ("TK-0001", "Dhanshree", "Pansare", "Core", "Director & Delivery Head", "Leader (L)", "Female"),
            ("TK-0002", "Priya", "Sharma", "Services - Testing", "PenTester - II", "Team Member (TM)", "Female"),
            ("TK-0003", "Rohan", "Mehta", "Functional - IT Administration", "DevSecOps Practitioner - II", "Team Member (TM)", "Male"),
            ("TK-0004", "Sneha", "Iyer", "Services - Operations", "SOC Lead - I", "Team Leader (TL)", "Female"),
            ("TK-0005", "Karthik", "Bose", "Services - Operations", "SOC Analyst - II", "Team Member (TM)", "Male"),
            ("TK-0006", "Divya", "Rao", "Functional - Project Management", "Associate Project Manager", "Manager (Mng.)", "Female"),
            ("TK-0007", "Ankit", "Verma", "Services - Operations", "SIEM Admin - II", "Team Member (TM)", "Male"),
            ("TK-0008", "Neha", "Kulkarni", "Functional - Accounts", "Senior Accountant - I", "Manager (Mng.)", "Female"),
            ("TK-0009", "Samar", "Patel", "Functional - HR", "HR Head", "HR", "Male"),
            ("TK-0010", "Aanya", "Joshi", "Functional - Sales", "Business Development Associate - I", "Manager (Mng.)", "Female"),
            ("TK-0011", "Harsh", "Nair", "Functional - Project Management", "Associate PMO - I", "Team Member (TM)", "Male"),
            ("TK-0012", "Ira", "Kapoor", "Services - Consulting", "GRC Auditor - II", "Team Member (TM)", "Female"),
            ("TK-0013", "Yash", "Malik", "Services - Testing", "Red Team Practitioner - II", "Team Member (TM)", "Male"),
            ("TK-0014", "Kavya", "Desai", "R&D (Research & Development)", "Python Developer - II", "Team Member (TM)", "Female"),
            ("TK-0015", "Arjun", "Shah", "Functional - IT Administration", "Desktop Support Engineer - I", "Team Member (TM)", "Male"),
            ("TK-0016", "Meera", "Nambiar", "Services - Consulting", "GRC Auditor - I", "Team Member (TM)", "Female"),
            ("TK-0017", "Vikram", "Gupta", "Functional - Project Management", "Senior PMO - I", "Team Leader (TL)", "Male"),
            ("TK-0018", "Ishita", "Bansal", "Services - Testing", "PenTester - I", "Team Member (TM)", "Female"),
            ("TK-0019", "Aditya", "Reddy", "Services - Operations", "SOC Analyst - I", "Team Member (TM)", "Male"),
            ("TK-0020", "Pooja", "Menon", "Functional - HR", "Senior HR Executive - I", "HR", "Female"),
            ("TK-0021", "Nikhil", "Khanna", "Functional - Sales", "Sales Associate", "Team Member (TM)", "Male"),
            ("TK-0022", "Riya", "Kapoor", "Functional - Project Management", "Engagement Manager", "Manager (Mng.)", "Female"),
            ("TK-0023", "Rahul", "Sharma", "Functional - Project Management", "Engagement Manager", "Manager (Mng.)", "Male"),
            ("TK-0024", "Pradeep", "Singh", "Functional - Project Management", "Engagement Manager", "Manager (Mng.)", "Male"),
            ("TK-0025", "Arjun", "Mehta", "Functional - Project Management", "Engagement Manager", "Manager (Mng.)", "Male"),
            ("TKI-0001", "Ananya", "Verma", "Services - Testing", "Intern", "Team Member (TM)", "Female"),
            ("TKI-0002", "Rohan", "Joshi", "Services - Testing", "Intern", "Team Member (TM)", "Male"),
        };

        var existingCodes = await db.Employees
            .IgnoreQueryFilters()
            .Select(e => e.EmployeeCode)
            .ToHashSetAsync(StringComparer.OrdinalIgnoreCase, ct);

        // WorkEmail is unique-constrained (including soft-deleted rows). A seed
        // employee whose email already belongs to another row must be skipped,
        // otherwise the insert collides with IX_employees_WorkEmail.
        var existingEmails = await db.Employees
            .IgnoreQueryFilters()
            .Select(e => e.WorkEmail)
            .ToHashSetAsync(StringComparer.OrdinalIgnoreCase, ct);

        var entities = new List<Employee>();
        for (var i = 0; i < seed.Length; i++)
        {
            var row = seed[i];
            var workEmail = $"{row.FirstName.ToLowerInvariant()}.{row.LastName.ToLowerInvariant()}@acme.co";
            if (existingCodes.Contains(row.Code) || existingEmails.Contains(workEmail)) continue;
            departments.TryGetValue(row.Department, out var dept);
            designations.TryGetValue(row.Designation, out var desig);
            var andheri = i % 2 == 0;
            var location = andheri ? "Suvidha Square, Andheri" : "Navare Plaza, Dombivli";
            var n = i + 1;

            var pmoDept = row.Code == "TK-0001" ? "Core"
                : row.Code.StartsWith("TKI") ? "Internship Program"
                : row.Department.Contains("Testing") ? "Services - Testing"
                : row.Department.Contains("Operations") ? "Services - Operations"
                : row.Department.Contains("Consulting") ? "Services - Consulting"
                : row.Department.Contains("Project Management") ? "Functional - Project Management"
                : row.Department;

            var subDept = row.Code == "TK-0001" ? "Leading Delivery Dept."
                : row.Code.StartsWith("TKI") ? "Across all Sub Departments"
                : pmoDept == "Services - Testing" ? "Service - Testing - AppSec"
                : pmoDept == "Functional - Project Management" ? "PMO (Project Management Office)"
                : "-";

            var isBillable = !(row.Role.Contains("Leader") || row.Role.Contains("HR") || row.Department.Contains("Sales") || row.Department.Contains("Accounts") || row.Department.Contains("IT") || row.Code.StartsWith("TKI"));

            entities.Add(new Employee
            {
                EmployeeCode = row.Code,
                FirstName = row.FirstName,
                LastName = row.LastName,
                WorkEmail = workEmail,
                Phone = (9820000000 + n).ToString(),
                DateOfBirth = new DateOnly(1990 + (i % 8), 1 + (i % 12), 1 + (i % 27)),
                Address = $"{120 + n}, {location}",
                EmergencyContact = (9811101000 + n).ToString(),
                EmergencyContactName = $"Contact {row.FirstName}",
                EmergencyContactRelation = i % 3 == 0 ? "Spouse" : "Father",
                MaritalStatus = i % 3 == 0 ? "Married" : "Single",
                Nationality = indian?.Name ?? "Indian",
                NationalityId = indian?.Id,
                DepartmentId = dept?.Id,
                DesignationId = desig?.Id,
                Role = row.Role,
                JobRoleId = jobRoles.FirstOrDefault(r =>
                    r.DesignationId == desig?.Id && r.Name == row.Role)?.Id,
                BusinessUnit = "Talakunchi Networks Private Limited",
                WorkLocation = location,
                OfficeBranch = null,
                Category = i % 5 == 0 ? "Permanent - Bond" : "Permanent - Without Bond",
                Team = null,
                ProjectSite = null,
                JoiningDate = new DateOnly(2019 + (i % 6), 1 + (i % 12), 10),
                Status = "Active",
                ConfirmationStatus = "Active",
                ProbationStatus = "Completed",
                Experience = $"{2 + (i % 10)} years",
                PreviousCompany = i % 2 == 0 ? "Infosys" : "TCS",
                EmploymentType = "Full-time",
                ContractType = "Permanent",
                BondDelivered = i % 5 == 0 ? "Yes" : "No",
                BondDurationMonths = i % 5 == 0 ? 24 : 0,
                BondExpiryDate = i % 5 == 0 ? new DateOnly(2026, 12, 31) : null,
                BondStatus = i % 5 == 0 ? "Yes — 2 years" : "No",
                NoticePeriod = i % 2 == 0 ? "60 days" : "90 days",
                AssetId = $"TK-{4000 + n}",
                ExitType = "NA",
                ExitReason = "NA",
                GradDegree = i % 3 == 0 ? "B.Tech" : i % 3 == 1 ? "BE" : "B.Sc",
                GradYear = (2014 + (i % 6)).ToString(),
                PostGradDegree = row.Code.StartsWith("TKI") || i % 2 != 0 ? "NA" : "M.Tech",
                PostGradYear = row.Code.StartsWith("TKI") || i % 2 != 0 ? "NA" : (2017 + (i % 5)).ToString(),
                ExpType = row.Code.StartsWith("TKI") ? "Fresher" : "Experienced",
                PriorTotalExp = row.Code.StartsWith("TKI") ? "0" : $"{2.5 + (i % 5):F1}",
                PriorRelevantExp = row.Code.StartsWith("TKI") ? "0" : $"{1.5 + (i % 4):F1}",
                PmoDepartment = pmoDept,
                SubDepartment = subDept,
                BillableStatus = isBillable ? "Billable" : "Non-Billable",
                ClientLocation = andheri ? "Andheri" : "Dombivli",
                ProjectType = "Long Term",
                ProjectAllocated = i % 3 == 0 ? "Helix Core EHR" : i % 3 == 1 ? "Northwind Core Modernization" : "CloudSync Multi-Region Sync",
                ClientEngManagerMapping = "Rahul Sharma",
                Education = i % 2 == 0 ? "B.Tech (2018), M.Tech (2020)" : "BE (2019)",
                Skills = ["Communication", "Delivery", row.Department],
                Certifications = row.Code.StartsWith("TKI") ? ["CompTIA Security+"] : ["Certified Ethical Hacker (CEH)", "ISO 27001"],
                Languages = ["English", "Hindi"],
                KpiScore = 70 + (i % 25),
                QuarterlyKpi = 68 + (i % 20),
                AnnualRating = 3 + (i % 3),
                GoalCompletion = 75 + (i % 20),
                Attendance = 90 + (i % 9),
                ReportingEfficiency = 80 + (i % 15),
                PromotionReadiness = i % 4 == 0 ? "Ready Now" : "Ready in 1 year",
                ManagerFeedback = "Solid contributor on current assignments.",
                Pan = $"ABCDE{(1234 + n):0000}F",
                Aadhaar = (234567890000 + n).ToString(),
                BankAccount = (501234567800 + n).ToString(),
                SalaryBand = i < 4 ? "L5" : "L4",
                PfUan = (100112345000 + n).ToString(),
                TaxRegime = i % 2 == 0 ? "New Regime" : "Old Regime",
                ComplianceStatus = "Compliant",
            });
        }

        if (entities.Count > 0)
            db.Employees.AddRange(entities);

        var lead = entities.FirstOrDefault(e => e.EmployeeCode == "TK-0001")
            ?? await db.Employees.FirstOrDefaultAsync(e => e.EmployeeCode == "TK-0001", ct);

        if (lead is not null)
        {
            foreach (var employee in entities)
            {
                if (employee.EmployeeCode == lead.EmployeeCode) continue;
                employee.ReportingManagerId = lead.Id;
            }
        }

        var allDbEmployees = await db.Employees.ToListAsync(ct);
        foreach (var emp in allDbEmployees)
        {
            if (string.IsNullOrWhiteSpace(emp.WorkLocation) ||
                emp.WorkLocation.Contains("Andheri", StringComparison.OrdinalIgnoreCase))
            {
                emp.WorkLocation = "Suvidha Square, Andheri";
            }
            else if (emp.WorkLocation.Contains("Dombi", StringComparison.OrdinalIgnoreCase))
            {
                emp.WorkLocation = "Navare Plaza, Dombivli";
            }
            else
            {
                emp.WorkLocation = "Onsite";
            }
            emp.OfficeBranch = null;
            emp.Team = null;
        }

        var seedCodes = seed.Select(s => s.Code).ToArray();
        var existingDummy = allDbEmployees
            .Where(e => seedCodes.Contains(e.EmployeeCode))
            .ToList();
        for (var i = 0; i < seed.Length; i++)
        {
            var row = seed[i];
            var employee = existingDummy.FirstOrDefault(e => e.EmployeeCode == row.Code);
            if (employee is null) continue;
            employee.JoiningDate ??= new DateOnly(2019 + (i % 6), 1 + (i % 12), 10);
            if (employee.DepartmentId is null && departments.TryGetValue(row.Department, out var dept))
                employee.DepartmentId = dept.Id;
            if (employee.DesignationId is null && designations.TryGetValue(row.Designation, out var desig))
                employee.DesignationId = desig.Id;
            if (lead is not null
                && employee.ReportingManagerId is null
                && employee.EmployeeCode != lead.EmployeeCode)
            {
                employee.ReportingManagerId = lead.Id;
            }
            if (string.IsNullOrWhiteSpace(employee.Aadhaar))
                employee.Aadhaar = (234567890000 + (i + 1)).ToString();
        }
    }

    // ---------- Clients ----------

    private static async Task SeedClientsAsync(AppDbContext db, Dictionary<string, User> users, CancellationToken ct)
    {
        // Backfill Customer Since for clients created before the column existed.
        await db.Database.ExecuteSqlRawAsync(
            """
            UPDATE clients
            SET "CustomerSince" = (("CreatedAtUtc" AT TIME ZONE 'UTC') AT TIME ZONE 'Asia/Kolkata')::date
            WHERE "CustomerSince" IS NULL AND "DeletedAtUtc" IS NULL;
            """,
            ct);

        if (await db.Clients.AnyAsync(ct)) return; // already seeded

        var seed = new (string Id, string Name, string Industry, string Contact, ClientType Type,
            string Em, string[] SubVentures, string? ContactName, string? ContactPhone,
            string? ContactDesignation, string? ContactType)[]
        {
            ("c1", "Northwind Bank", "Banking", "ops@northwind.com", ClientType.Old, "Rahul Sharma",
                ["Northwind Retail Banking", "Northwind Corporate Banking", "Northwind Digital Payments", "Northwind Treasury Services", "Northwind Wealth Management"],
                "Rahul Sharma", "+91 98765 43210", "IT Manager", "Technical SPOC"),
            ("c2", "Helix Pharma", "Healthcare", "it@helix.com", ClientType.Old, "Pradeep Singh",
                ["Helix Clinical Research", "Helix Biotech Division", "Helix Manufacturing", "Helix Global Healthcare", "Helix Medical Devices"],
                "Sanjay Sen", "+91 98765 43211", "Procurement Head", "Procurement"),
            ("c3", "Orbit Retail", "Retail", "tech@orbit.com", ClientType.Old, "Riya Kapoor",
                ["Orbit E-Commerce", "Orbit Hypermarket", "Orbit Fashion", "Orbit Supply Chain", "Orbit Digital Commerce"],
                "Aditi Rao", "+91 98765 43212", "CFO", "Accounts"),
            ("c4", "Zenith Logistics", "Logistics", "pm@zenith.com", ClientType.New, "Rahul Sharma",
                ["Zenith Freight Services", "Zenith Warehouse Operations", "Zenith International Logistics", "Zenith Fleet Management", "Zenith Express Delivery"],
                "Vikram Malhotra", "+91 98765 43213", "Legal Counsel", "Legal"),
            ("c5", "Lumen Energy", "Energy", "digital@lumen.com", ClientType.Old, "Pradeep Singh",
                ["Lumen Renewable Energy", "Lumen Power Distribution", "Lumen Smart Grid", "Lumen Solar Division", "Lumen Energy Consulting"],
                "Arjun Mehta", "+91 98765 43214", "Operations Manager", "Technical SPOC"),
            ("c6", "CloudSync AI", "Technology", "contact@cloudsync.com", ClientType.New, "Riya Kapoor",
                ["CloudSync AI Platform", "CloudSync Cloud Infrastructure", "CloudSync Data Engineering", "CloudSync Machine Learning", "CloudSync Enterprise Solutions"],
                "Neha Gupta", "+91 98765 43215", "IT Lead", "Technical SPOC"),
            ("c7", "FinTech Global", "Finance", "dev@fintechglobal.com", ClientType.Old, "Rahul Sharma",
                ["FinTech Digital Banking", "FinTech Payment Solutions", "FinTech Lending", "FinTech Investment Services", "FinTech Risk & Compliance"],
                "Siddharth Shah", "+91 98765 43216", "Finance VP", "Accounts"),
            ("c8", "MediCare Plus", "Healthcare", "tech@medicareplus.com", ClientType.New, "Pradeep Singh",
                ["MediCare Hospital Systems", "MediCare Telemedicine", "MediCare Diagnostics", "MediCare Health Analytics", "MediCare Patient Services"],
                "Priyanka Joshi", "+91 98765 43217", "Procurement Mgr", "Procurement"),
            ("c9", "EcoGreen Solutions", "Environment", "projects@ecogreen.com", ClientType.Old, "Riya Kapoor",
                ["EcoGreen Waste Management", "EcoGreen Sustainability Consulting", "EcoGreen Renewable Projects", "EcoGreen Water Management", "EcoGreen Carbon Solutions"],
                "Rohan Varma", "+91 98765 43218", "Legal Head", "Legal"),
            ("c10", "AutoDrive Systems", "Automotive", "engineering@autodrive.com", ClientType.Old, "Rahul Sharma",
                ["AutoDrive Connected Vehicles", "AutoDrive Autonomous Systems", "AutoDrive EV Solutions", "AutoDrive Manufacturing", "AutoDrive Smart Mobility"],
                "Kabir Sen", "+91 98765 43219", "Engineering SPOC", "Technical SPOC"),
        };

        foreach (var (id, name, industry, contact, type, em, subs, cName, cPhone, cDesig, cType) in seed)
        {
            var client = new Client
            {
                Id = StableGuid("client-" + id),
                Name = name,
                Industry = industry,
                Logo = Client.LogoFromName(name),
                ContactEmail = contact,
                ClientType = type,
                EngagementManager = em,
                ContactName = cName,
                ContactPhone = cPhone,
                ContactDesignation = cDesig,
                ContactType = cType,
                CustomerSince = DateOnly.FromDateTime(DateTime.UtcNow.Date.AddMonths(-6)),
            };
            // Each sub-venture lives in its own row referencing this client.
            client.SubVentures = subs.Select(s => new SubVenture
            {
                ClientId = client.Id,
                Name = s,
            }).ToList();
            db.Clients.Add(client);
        }

        // Data-scoping demo: SPM (u1) sees c1+c2, EM (u2) sees c3+c6 via assignment.
        var assignments = new (string ClientId, string UserId)[]
        {
            ("c1", "u1"), ("c2", "u1"),
            ("c3", "u2"), ("c6", "u2"),
        };
        foreach (var (clientId, userId) in assignments)
        {
            db.ClientAssignments.Add(new ClientAssignment
            {
                ClientId = StableGuid("client-" + clientId),
                UserId = StableGuid("user-" + userId),
            });
        }
    }

    // ---------- Repository Documents ----------

    private static async Task SeedRepositoryAsync(AppDbContext db, CancellationToken ct)
    {
        if (await db.RepositoryItems.AnyAsync(ct))
        {
            return;
        }

        var solutionDir = AppDomain.CurrentDomain.BaseDirectory;
        // Search upward for storage folder
        var current = new DirectoryInfo(solutionDir);
        string? storageRoot = null;
        while (current != null)
        {
            var candidate = Path.Combine(current.FullName, "storage");
            if (Directory.Exists(candidate))
            {
                storageRoot = candidate;
                break;
            }
            current = current.Parent;
        }

        if (storageRoot == null)
        {
            storageRoot = Path.Combine(Directory.GetCurrentDirectory(), "storage");
        }

        var techDir = Path.Combine(storageRoot, "repository", "tech");
        var pmsDir = Path.Combine(storageRoot, "repository", "pms");
        var impDir = Path.Combine(storageRoot, "repository", "imp");

        Directory.CreateDirectory(techDir);
        Directory.CreateDirectory(pmsDir);
        Directory.CreateDirectory(impDir);

        var seedDocs = new (string FileName, string Category, string SubDir, long Size, string UploadedBy, string Content)[]
        {
            ("API_Gateway_Configuration_Guide.pdf", "Tech", "tech", 2457600, "Rahul Sharma", "%PDF-1.4 TrackerPro API Gateway Configuration Guide SOP\nTech Documentation"),
            ("CI_CD_Pipeline_Setup_Procedures.docx", "Tech", "tech", 1048576, "Sneha Iyer", "TrackerPro CI-CD Pipeline Setup Procedures SOP"),
            ("Database_Backup_and_Recovery_SOP.pdf", "Tech", "tech", 3145728, "Vikram Gupta", "%PDF-1.4 TrackerPro Database Backup and Recovery SOP"),
            ("Security_Incident_Response_Plan.pdf", "Tech", "tech", 1572864, "Nikhil Khanna", "%PDF-1.4 TrackerPro Security Incident Response Plan SOP"),

            ("Project_Onboarding_Checklist.pdf", "PMS", "pms", 524288, "Pooja Menon", "%PDF-1.4 TrackerPro Project Onboarding Checklist SOP"),
            ("WBS_Creation_Guidelines.docx", "PMS", "pms", 786432, "Rahul Sharma", "TrackerPro WBS Creation Guidelines SOP"),
            ("Timesheet_Submission_Process.pdf", "PMS", "pms", 409600, "Kavya Desai", "%PDF-1.4 TrackerPro Timesheet Submission Process SOP"),
            ("Resource_Allocation_SOP.pdf", "PMS", "pms", 655360, "Pooja Menon", "%PDF-1.4 TrackerPro Resource Allocation SOP"),
            ("Change_Request_Management_Process.docx", "PMS", "pms", 327680, "Ira Kapoor", "TrackerPro Change Request Management Process SOP"),

            ("Code_of_Conduct_2026.pdf", "IMP", "imp", 1048576, "Ankit Verma", "%PDF-1.4 TrackerPro Company Code of Conduct 2026 Policy"),
            ("Remote_Work_Policy.pdf", "IMP", "imp", 614400, "Arjun Shah", "%PDF-1.4 TrackerPro Remote Work Policy & Guidelines"),
            ("Data_Privacy_and_GDPR_Guidelines.pdf", "IMP", "imp", 2097152, "Rohan Mehta", "%PDF-1.4 TrackerPro Data Privacy and GDPR Compliance Guidelines"),
            ("Leave_and_Attendance_Policy.pdf", "IMP", "imp", 819200, "Harsh Nair", "%PDF-1.4 TrackerPro Leave and Attendance Policy 2026")
        };

        var employees = await db.Employees
            .AsNoTracking()
            .Where(e => e.Status == "Active")
            .Select(e => new { e.FirstName, e.LastName, e.WorkEmail })
            .ToListAsync(ct);

        var activeEmployeeNames = employees
            .Select(e =>
            {
                var fullName = $"{e.FirstName} {e.LastName}".Trim();
                if (!string.IsNullOrWhiteSpace(fullName)) return fullName;
                var local = e.WorkEmail.Split('@')[0].Replace('.', ' ');
                return local;
            })
            .Where(n => !string.IsNullOrWhiteSpace(n))
            .ToList();

        if (activeEmployeeNames.Count == 0)
        {
            activeEmployeeNames = ["Aanya Joshi", "Ankit Verma", "Arjun Mehta", "Dhanshree Pansare", "Divya Rao", "Harsh Nair", "Ira Kapoor", "Neha Kulkarni", "Priya Sharma", "Rahul Sharma", "Riya Kapoor", "Rohan Mehta", "Sneha Iyer", "Vikram Gupta", "Yash Malik"];
        }

        foreach (var item in seedDocs)
        {
            var targetDir = Path.Combine(storageRoot, "repository", item.SubDir);
            var filePath = Path.Combine(targetDir, item.FileName);
            if (!File.Exists(filePath))
            {
                await File.WriteAllTextAsync(filePath, item.Content, ct);
            }

            var doc = new RepositoryItem
            {
                Id = StableGuid("repo-" + item.FileName),
                FileName = item.FileName.Replace('_', ' '),
                Category = item.Category,
                Size = item.Size,
                LastUpdated = DateTime.UtcNow.AddDays(-Random.Shared.Next(2, 60)),
                UploadedBy = item.UploadedBy,
                FilePath = Path.Combine("repository", item.SubDir, item.FileName).Replace('\\', '/'),
                CreatedAtUtc = DateTime.UtcNow.AddDays(-Random.Shared.Next(2, 60))
            };

            db.RepositoryItems.Add(doc);

            db.RepositoryActivityLogs.Add(new RepositoryActivityLog
            {
                Id = Guid.NewGuid(),
                Action = "Uploaded",
                DocumentId = doc.Id,
                FileName = doc.FileName,
                Category = doc.Category,
                PerformedBy = doc.UploadedBy,
                Details = $"Initial repository import for {doc.FileName}",
                CreatedAtUtc = doc.CreatedAtUtc
            });

            // Seed access/download logs using real active employees from Resource Directory
            var accessorCount = Random.Shared.Next(2, 5);
            for (var i = 0; i < accessorCount; i++)
            {
                var emp = activeEmployeeNames[Random.Shared.Next(activeEmployeeNames.Count)];
                var accessDate = doc.CreatedAtUtc.AddHours(Random.Shared.Next(2, 48));
                if (accessDate > DateTime.UtcNow) accessDate = DateTime.UtcNow.AddMinutes(-Random.Shared.Next(5, 300));

                db.RepositoryActivityLogs.Add(new RepositoryActivityLog
                {
                    Id = Guid.NewGuid(),
                    Action = "Downloaded",
                    DocumentId = doc.Id,
                    FileName = doc.FileName,
                    Category = doc.Category,
                    PerformedBy = emp,
                    Details = $"{emp} downloaded {doc.FileName}",
                    CreatedAtUtc = accessDate
                });
            }
        }
    }

    // ---------- Projects, Tasks & Invoices ----------

    private static async Task SeedProjectsAsync(AppDbContext db, CancellationToken ct)
    {
        if (await db.Projects.AnyAsync(ct)) return; // Idempotent

        var allClients = await db.Clients.Include(c => c.SubVentures).ToDictionaryAsync(c => c.Id, ct);
        var subVenturesByName = await db.SubVentures.ToDictionaryAsync(s => $"{s.ClientId}_{s.Name.ToLower()}", s => s.Id, ct);

        // Pre-fetch employees for assignment linking
        var employees = await db.Employees.Where(e => e.DeletedAtUtc == null && e.Status == "Active").ToListAsync(ct);
        var defaultEmpId = employees.FirstOrDefault()?.Id;

        // Sub-venture mappings for projects p1 to p43
        var projectSubventures = new Dictionary<string, string>
        {
            ["p1"] = "Northwind Retail Banking",
            ["p2"] = "Northwind Digital Payments",
            ["p3"] = "Helix Clinical Research",
            ["p4"] = "Helix Biotech Division",
            ["p5"] = "Orbit E-Commerce",
            ["p6"] = "Orbit Hypermarket",
            ["p7"] = "Zenith Freight Services",
            ["p8"] = "Zenith Warehouse Operations",
            ["p9"] = "Lumen Smart Grid",
            ["p10"] = "CloudSync AI Platform",
            ["p11"] = "FinTech Digital Banking",
            ["p12"] = "MediCare Hospital Systems",
            ["p13"] = "EcoGreen Sustainability Consulting",
            ["p14"] = "AutoDrive Autonomous Systems",
            ["p15"] = "Northwind Corporate Banking",
            ["p16"] = "Northwind Treasury Services",
            ["p17"] = "Northwind Wealth Management",
            ["p18"] = "Northwind Financial Services",
            ["p19"] = "Helix Manufacturing",
            ["p20"] = "Helix Global Healthcare",
            ["p21"] = "Helix Medical Devices",
            ["p22"] = "Orbit Fashion",
            ["p23"] = "Orbit Supply Chain",
            ["p24"] = "Orbit Digital Commerce",
            ["p25"] = "Zenith International Logistics",
            ["p26"] = "Zenith Fleet Management",
            ["p27"] = "Lumen Renewable Energy",
            ["p28"] = "Lumen Power Distribution",
            ["p29"] = "Lumen Solar Division",
            ["p30"] = "CloudSync Data Engineering",
            ["p31"] = "CloudSync Machine Learning",
            ["p32"] = "FinTech Payment Solutions",
            ["p33"] = "FinTech Risk & Compliance",
            ["p34"] = "FinTech Lending",
            ["p35"] = "MediCare Telemedicine",
            ["p36"] = "MediCare Diagnostics",
            ["p37"] = "MediCare Patient Services",
            ["p38"] = "EcoGreen Waste Management",
            ["p39"] = "EcoGreen Renewable Projects",
            ["p40"] = "EcoGreen Water Management",
            ["p41"] = "AutoDrive Connected Vehicles",
            ["p42"] = "AutoDrive EV Solutions",
            ["p43"] = "AutoDrive Manufacturing"
        };

        var projectSeedData = new (string Id, string Name, string ClientKey, string? WbsId, string Status, string Health, int Progress, string StartDate, string EndDate, decimal Budget, decimal Spent, string Desc)[]
        {
            ("p1", "Core Banking Modernization", "c1", "IN-2025-26-C001-P006", "ongoing", "amber", 62, "2026-02-01", "2026-08-30", 1200000m, 740000m, "Modernize legacy core banking platform to a cloud-native microservices stack."),
            ("p2", "Mobile Banking App v3", "c1", "IN-2025-26-C001-P002", "ongoing", "green", 78, "2026-01-15", "2026-06-30", 480000m, 360000m, "Next-gen mobile app with biometric auth and real-time payments."),
            ("p3", "Clinical Data Platform", "c2", "IN-2025-26-C002-P011", "ongoing", "red", 35, "2026-03-01", "2026-09-15", 950000m, 410000m, "Unified clinical trials data platform with HIPAA compliance."),
            ("p4", "Pharma Sales Dashboard", "c2", "IN-2025-26-C002-P008", "on_hold", "amber", 45, "2026-02-10", "2026-07-20", 320000m, 180000m, "Sales analytics dashboard with territory performance views."),
            ("p5", "Omnichannel Commerce", "c3", "IN-2025-26-C003-P004", "ongoing", "green", 58, "2026-01-20", "2026-08-10", 760000m, 420000m, "Unified storefront across web, mobile and in-store kiosks."),
            ("p6", "POS Migration", "c3", "IN-2024-25-C003-P002", "ongoing", "green", 65, "2025-09-01", "2026-03-30", 280000m, 265000m, "Migrated 1,200 POS terminals to new cloud-managed platform."),
            ("p7", "Fleet Tracking System", "c4", "IN-2025-26-C004-P009", "ongoing", "amber", 48, "2026-02-15", "2026-09-01", 540000m, 280000m, "Real-time GPS tracking and route optimization for 5,000 vehicles."),
            ("p8", "Warehouse Automation", "c4", "IN-2025-26-C004-P001", "ongoing", "green", 70, "2026-01-05", "2026-07-15", 890000m, 600000m, "Robotics + WMS integration across 4 distribution centers."),
            ("p9", "Smart Grid Analytics", "c5", "IN-2025-26-C005-P010", "ongoing", "amber", 55, "2026-02-20", "2026-10-10", 1050000m, 510000m, "Predictive load balancing and outage detection across the grid."),
            ("p10", "AI-Powered Analytics Platform", "c6", "IN-2025-26-C006-P012", "ongoing", "green", 82, "2026-03-01", "2026-08-30", 750000m, 615000m, "Machine learning pipeline for real-time data analytics and insights."),
            ("p11", "Digital Wallet MVP", "c7", "IN-2025-26-C007-P003", "ongoing", "green", 65, "2026-01-15", "2026-06-20", 580000m, 377000m, "Mobile-first digital payment wallet with blockchain security."),
            ("p12", "Hospital Management System", "c8", "IN-2025-26-C008-P007", "ongoing", "amber", 48, "2026-02-10", "2026-09-25", 920000m, 441600m, "Comprehensive EHR and patient management system for 50+ hospitals."),
            ("p13", "Carbon Tracking Platform", "c9", "IN-2025-26-C009-P005", "ongoing", "green", 71, "2026-01-20", "2026-07-31", 640000m, 454400m, "Enterprise platform for monitoring and reducing carbon footprint."),
            ("p14", "Autonomous Vehicle Control", "c10", "IN-2025-26-C010-P013", "ongoing", "red", 38, "2026-03-10", "2026-11-15", 1200000m, 456000m, "Advanced control system for autonomous vehicle fleet management."),
            ("p15", "Internet Banking Portal", "c1", "IN-2024-25-C001-P003", "archived", "green", 100, "2024-06-01", "2025-01-15", 520000m, 510000m, "Full-featured internet banking portal with 2FA and real-time notifications."),
            ("p16", "Fraud Detection ML Model", "c1", "IN-2023-24-C001-P006", "completed", "green", 100, "2024-02-01", "2024-10-30", 680000m, 665000m, "Machine learning pipeline for real-time transaction fraud detection."),
            ("p17", "API Gateway Revamp", "c1", "IN-2026-27-C001-P001", "ongoing", "green", 0, "2026-06-01", "2026-12-31", 390000m, 0m, "Rebuild API gateway with rate limiting, OAuth 2.0 and developer portal."),
            ("p18", "Loan Origination System", "c1", "IN-2023-24-C001-P005", "archived", "amber", 72, "2023-09-01", "2024-04-30", 450000m, 420000m, "End-to-end digital loan origination and approval workflow system."),
            ("p19", "Lab Information System", "c2", "IN-2023-24-C002-P007", "completed", "green", 100, "2024-01-10", "2024-09-20", 610000m, 590000m, "Digital laboratory information system for sample tracking and reporting."),
            ("p20", "Regulatory Compliance Portal", "c2", "IN-2026-27-C002-P002", "ongoing", "green", 0, "2026-06-10", "2026-12-20", 280000m, 0m, "Centralized portal for managing FDA/EMA regulatory submissions."),
            ("p21", "Drug Trial Management", "c2", "IN-2023-24-C002-P002", "archived", "amber", 68, "2023-05-01", "2024-01-31", 730000m, 690000m, "Phase II/III clinical trial participant management and data collection."),
            ("p22", "Loyalty Rewards Platform", "c3", "IN-2023-24-C003-P008", "completed", "green", 100, "2024-03-01", "2024-11-30", 340000m, 330000m, "Points-based loyalty engine with gamification for 5M+ customers."),
            ("p23", "Inventory AI Forecasting", "c3", "IN-2026-27-C003-P001", "ongoing", "green", 0, "2026-06-05", "2026-11-30", 420000m, 0m, "AI-driven demand forecasting and automated replenishment system."),
            ("p24", "Customer Data Platform", "c3", "IN-2023-24-C003-P005", "archived", "amber", 55, "2023-01-15", "2023-09-30", 490000m, 460000m, "Unified customer data platform integrating 12 data sources."),
            ("p25", "Supply Chain Visibility", "c4", "IN-2024-25-C004-P005", "completed", "green", 100, "2024-04-01", "2024-12-15", 570000m, 555000m, "End-to-end supply chain visibility platform with IoT sensor integration."),
            ("p26", "Driver Mobile App", "c4", "IN-2026-27-C004-P002", "ongoing", "green", 0, "2026-06-15", "2026-11-20", 220000m, 0m, "Driver-facing mobile app for route optimization and POD collection."),
            ("p27", "Renewable Energy Dashboard", "c5", "IN-2024-25-C005-P003", "archived", "green", 100, "2024-02-01", "2024-10-31", 460000m, 445000m, "Executive dashboard for real-time monitoring of solar and wind assets."),
            ("p28", "Customer Energy Portal", "c5", "IN-2026-27-C005-P001", "ongoing", "green", 0, "2026-06-08", "2026-12-15", 310000m, 0m, "Self-service portal for residential customers to track usage and billing."),
            ("p29", "Grid Modernization Program", "c5", "IN-2023-24-C005-P004", "completed", "amber", 61, "2023-06-01", "2024-03-31", 870000m, 840000m, "Phase 1 smart meter rollout across 3 states."),
            ("p30", "Data Lakehouse Migration", "c6", "IN-2026-27-C006-P001", "ongoing", "green", 0, "2026-06-01", "2026-11-30", 490000m, 0m, "Migrate 3PB data warehouse to modern lakehouse architecture on Snowflake."),
            ("p31", "MLOps Framework", "c6", "IN-2024-25-C006-P002", "archived", "green", 100, "2024-03-15", "2024-11-30", 380000m, 365000m, "Production ML model lifecycle management with drift detection and retraining."),
            ("p32", "Cross-Border Payments", "c7", "IN-2026-27-C007-P001", "ongoing", "amber", 0, "2026-06-12", "2027-01-31", 920000m, 0m, "SWIFT-compliant cross-border payment rails for 40+ countries."),
            ("p33", "KYC Automation", "c7", "IN-2024-25-C007-P002", "completed", "green", 100, "2024-01-01", "2024-08-31", 540000m, 525000m, "AI-driven KYC document verification reducing manual review by 80%."),
            ("p34", "Open Banking API Suite", "c7", "IN-2023-24-C007-P001", "archived", "amber", 44, "2023-03-01", "2023-10-15", 320000m, 300000m, "PSD2-compliant open banking API suite for third-party integrators."),
            ("p35", "Telemedicine Platform", "c8", "IN-2024-25-C008-P004", "completed", "green", 100, "2024-05-01", "2025-01-15", 670000m, 650000m, "HIPAA-compliant video consultation and remote monitoring platform."),
            ("p36", "Insurance Claims Automation", "c8", "IN-2026-27-C008-P001", "ongoing", "green", 0, "2026-06-20", "2026-12-31", 380000m, 0m, "AI-powered claims processing reducing settlement time from 30 to 3 days."),
            ("p37", "Patient Engagement App", "c8", "IN-2023-24-C008-P003", "archived", "amber", 52, "2023-07-01", "2024-03-31", 290000m, 270000m, "Patient-facing app for appointment booking, reminders and health records."),
            ("p38", "ESG Reporting Engine", "c9", "IN-2024-25-C009-P002", "completed", "green", 100, "2024-02-15", "2024-10-30", 420000m, 405000m, "Automated ESG data aggregation and reporting aligned to GRI and TCFD standards."),
            ("p39", "Waste Management IoT", "c9", "IN-2026-27-C009-P001", "ongoing", "green", 0, "2026-06-18", "2026-12-20", 360000m, 0m, "Smart bin monitoring network with route optimization for waste collectors."),
            ("p40", "Water Quality Platform", "c9", "IN-2023-24-C009-P004", "archived", "amber", 48, "2023-04-01", "2023-11-30", 310000m, 290000m, "IoT sensor network for real-time water quality monitoring across 200 sites."),
            ("p41", "ADAS Integration Suite", "c10", "IN-2024-25-C010-P003", "completed", "green", 100, "2024-01-20", "2024-11-30", 980000m, 960000m, "Advanced driver-assistance system integration for 3 OEM partners."),
            ("p42", "V2X Communication Platform", "c10", "IN-2026-27-C010-P001", "ongoing", "amber", 0, "2026-06-25", "2027-02-28", 1100000m, 0m, "Vehicle-to-everything communication layer for smart city integration."),
            ("p43", "OBD Diagnostics Cloud", "c10", "IN-2023-24-C010-P002", "archived", "amber", 38, "2023-08-01", "2024-04-30", 430000m, 400000m, "Cloud-based OBD-II diagnostics aggregation for fleet health monitoring.")
        };

        var taskTitles = new (string Title, string Stage, int Progress, decimal EstHours)[]
        {
            ("External Network Penetration Testing", "Completed", 100, 40m),
            ("Web Application Penetration Testing", "Completed", 100, 32m),
            ("Cloud Infrastructure Assessment", "Ongoing", 65, 40m),
            ("Source Code Security Review", "Ready to Start", 40, 48m),
            ("ISO 27001 Security Audit", "On Hold (Internal)", 20, 64m),
            ("Phishing Campaign & Assessment", "Ready to Start", 0, 16m)
        };

        var projectCounter = 1;
        foreach (var (pId, name, clientKey, wbsId, status, health, progress, startDate, endDate, budget, spent, desc) in projectSeedData)
        {
            var clientId = StableGuid("client-" + clientKey);
            Guid? subVentureId = null;

            if (projectSubventures.TryGetValue(pId, out var svName))
            {
                var svKey = $"{clientId}_{svName.ToLower()}";
                if (subVenturesByName.TryGetValue(svKey, out var svGuid))
                {
                    subVentureId = svGuid;
                }
            }

            var projectGuid = StableGuid("project-" + pId);
            var projectCode = $"P{projectCounter:D3}";
            projectCounter++;

            var finalWbsId = wbsId ?? $"IN-2026-27-C{int.Parse(clientKey.TrimStart('c')):D3}-{projectCode}";

            var project = new Project
            {
                Id = projectGuid,
                ProjectCode = projectCode,
                WbsId = finalWbsId,
                Name = name,
                Description = desc,
                ClientId = clientId,
                SubVentureId = subVentureId,
                Status = status,
                Health = health,
                Progress = progress,
                ContractType = "Fixed Price",
                ProjectType = "Short term (Ad-hoc)",
                Currency = "USD",
                TaxPercent = 18m,
                StartDate = DateOnly.Parse(startDate),
                EndDate = DateOnly.Parse(endDate),
                Budget = budget,
                Spent = spent,
                TotalHours = 240m,
                TotalDays = 30m,
                InvoiceValue = budget,
                WbsStatus = status == "archived" ? "Archived" : (status == "completed" ? "Approved" : "Published"),
                WbsSubStatus = status == "archived" ? "Archived" : (status == "completed" ? "Completed" : "Active"),
                BillingModel = "50-50",
                PaymentTerms = "Net 30 Days",
                PoStatus = "Uploaded",
                PoNumber = $"PO-{finalWbsId.Split('-').Last()}",
                PoDate = DateOnly.Parse(startDate).AddDays(-5),
                CreatedAtUtc = DateTime.UtcNow.AddDays(-100)
            };

            db.Projects.Add(project);

            // Seed 2 default Project Services
            var s1 = new ProjectServiceEntity
            {
                Id = StableGuid($"{pId}-service-1"),
                ProjectId = projectGuid,
                Department = "Penetration Testing",
                SubDepartment = "Network Penetration Testing",
                ServiceName = "External Network Penetration Testing",
                ResourceLevel = "Senior",
                Frequency = "One Time",
                Location = "Remote",
                ServiceModel = "Black Box",
                DeliveryModel = "Fixed Scope",
                FinalDeliveryFormat = "PDF Report",
                BillingModel = "50-50",
                Qty = 1,
                UnitPrice = budget * 0.6m,
                Total = budget * 0.6m,
                DurationDays = 15,
                DurationHours = 120,
                TotalDays = 15,
                TotalHours = 120,
                CreatedAtUtc = project.CreatedAtUtc
            };
            s1.ResourceLevels.Add(new ProjectServiceResourceLevel
            {
                Id = Guid.NewGuid(),
                ProjectServiceId = s1.Id,
                Level = "Senior",
                Count = 1,
                CreatedAtUtc = s1.CreatedAtUtc
            });
            db.ProjectServices.Add(s1);

            var s2 = new ProjectServiceEntity
            {
                Id = StableGuid($"{pId}-service-2"),
                ProjectId = projectGuid,
                Department = "Vulnerability Assessment",
                SubDepartment = "Web Application Vulnerability Assessment",
                ServiceName = "Web Application Vulnerability Assessment",
                ResourceLevel = "Mid",
                Frequency = "One Time",
                Location = "Remote",
                ServiceModel = "Grey Box",
                DeliveryModel = "Fixed Scope",
                FinalDeliveryFormat = "PDF Report",
                BillingModel = "50-50",
                Qty = 1,
                UnitPrice = budget * 0.4m,
                Total = budget * 0.4m,
                DurationDays = 15,
                DurationHours = 120,
                TotalDays = 15,
                TotalHours = 120,
                CreatedAtUtc = project.CreatedAtUtc
            };
            s2.ResourceLevels.Add(new ProjectServiceResourceLevel
            {
                Id = Guid.NewGuid(),
                ProjectServiceId = s2.Id,
                Level = "Mid",
                Count = 1,
                CreatedAtUtc = s2.CreatedAtUtc
            });
            db.ProjectServices.Add(s2);

            // Seed tasks for this project
            var taskIdx = 1;
            foreach (var (title, tStage, tProg, estHours) in taskTitles)
            {
                var taskGuid = StableGuid($"{pId}-task-{taskIdx}");
                var task = new ProjectTask
                {
                    Id = taskGuid,
                    ProjectId = projectGuid,
                    ProjectServiceId = taskIdx <= 3 ? s1.Id : s2.Id,
                    Title = title,
                    Description = $"{title} execution phase",
                    Period = "Q1",
                    Phase = $"AP{taskIdx}",
                    Stage = tStage,
                    Priority = taskIdx % 2 == 0 ? "high" : "medium",
                    EstimatedHours = estHours,
                    UtilizedHours = (estHours * tProg) / 100m,
                    Progress = tProg,
                    SortOrder = taskIdx,
                    PlannedStartDate = project.StartDate?.AddDays(taskIdx * 5),
                    PlannedEndDate = project.StartDate?.AddDays(taskIdx * 5 + 7),
                    ActualStartDate = tProg > 0 ? project.StartDate?.AddDays(taskIdx * 5) : null,
                    ActualEndDate = tProg == 100 ? project.StartDate?.AddDays(taskIdx * 5 + 7) : null,
                    CreatedAtUtc = project.CreatedAtUtc
                };
                db.ProjectTasks.Add(task);

                // Add default assignment if employees exist
                if (defaultEmpId.HasValue)
                {
                    db.ProjectTaskAssignments.Add(new ProjectTaskAssignment
                    {
                        Id = StableGuid($"{pId}-task-{taskIdx}-assign-1"),
                        TaskId = taskGuid,
                        EmployeeId = defaultEmpId.Value,
                        Role = "Lead",
                        AllocatedHours = estHours,
                        UtilizedHours = task.UtilizedHours,
                        CreatedAtUtc = project.CreatedAtUtc
                    });
                }

                taskIdx++;
            }

            // Seed 2 milestone invoices (50% upfront, 50% on completion)
            var inv1Amount = budget * 0.5m;
            var inv1Tax = inv1Amount * 0.18m;
            db.ProjectInvoices.Add(new ProjectInvoice
            {
                Id = StableGuid($"{pId}-inv-1"),
                ProjectId = projectGuid,
                MilestoneName = "Initial Milestone (50% Advance)",
                Percentage = 50m,
                Amount = inv1Amount,
                TaxAmount = inv1Tax,
                TotalAmount = inv1Amount + inv1Tax,
                Status = progress >= 50 ? "Paid" : "Raised",
                InvoiceNumber = $"INV-{pId.ToUpper()}-01",
                InvoiceDate = project.StartDate,
                DueDate = project.StartDate?.AddDays(30),
                PaymentDate = progress >= 50 ? project.StartDate?.AddDays(15) : null,
                SortOrder = 1,
                CreatedAtUtc = project.CreatedAtUtc
            });

            var inv2Amount = budget * 0.5m;
            var inv2Tax = inv2Amount * 0.18m;
            db.ProjectInvoices.Add(new ProjectInvoice
            {
                Id = StableGuid($"{pId}-inv-2"),
                ProjectId = projectGuid,
                MilestoneName = "Final Milestone (50% on Sign-off)",
                Percentage = 50m,
                Amount = inv2Amount,
                TaxAmount = inv2Tax,
                TotalAmount = inv2Amount + inv2Tax,
                Status = progress == 100 ? "Paid" : (progress >= 50 ? "Raised" : "Pending"),
                InvoiceNumber = $"INV-{pId.ToUpper()}-02",
                InvoiceDate = project.EndDate?.AddDays(-15),
                DueDate = project.EndDate?.AddDays(15),
                PaymentDate = progress == 100 ? project.EndDate?.AddDays(5) : null,
                SortOrder = 2,
                CreatedAtUtc = project.CreatedAtUtc
            });
        }
    }

    // ---------- helpers ----------

    /// <summary>Deterministic GUID so seeds are stable across reseeds.</summary>
    public static Guid StableGuid(string seed)
    {
        var hash = SHA256.HashData(Encoding.UTF8.GetBytes(seed));
        return new Guid(hash.AsSpan(0, 16));
    }

    private static async Task SeedCertificationsAsync(AppDbContext db, CancellationToken ct)
    {
        var certs = new[]
        {
            "Certified Ethical Hacker (CEH)",
            "CompTIA Security+",
            "eCPPT",
            "cPTS",
            "CRTP",
            "Licensed Penetration Tester (LPT)",
            "PNPT",
            "CRTE",
            "CRT",
            "Offensive Security Certified Professional (OSCP)",
            "Offensive Security Wireless Professional (OSWP)",
            "Offensive Security Web Expert (OSWE)",
            "Offensive Security Experienced Penetration Tester (OSEP)",
            "Offensive Security Certified Expert 3 (OSCE3)",
            "ISO 27001",
            "ISO 22301",
            "ISO/IEC 42001",
            "Certified Cloud Security Professional (CCSP)",
            "Certified Information Systems Auditor (CISA)",
            "Certified Information Security Manager (CISM)",
            "Certified Information Systems Security Professional (CISSP)",
            "Certified in Risk and Information Systems Control (CRISC)",
            "EC-Council Certified Incident Handler (ECIH)",
            "Certified Threat Intelligence Analyst (CTIA)",
            "Blue Team Level 1 and 2",
            "eLearnSecurity Certified Threat Hunting Professional (eCTHP)",
            "eLearnSecurity Certified Incident Responder (eCIR)",
            "eLearnSecurity Certified Digital Forensics Professional (eCDFP)",
            "OffSec Foundational Security Operations and Defensive Analysis (OSDA)",
        };

        var existing = await db.Certifications.IgnoreQueryFilters().ToDictionaryAsync(c => c.Name.ToLower(), ct);
        foreach (var name in certs)
        {
            if (existing.ContainsKey(name.ToLower())) continue;
            var code = name.ToLower().Replace(" ", "_").Replace("-", "_").Replace("+", "plus").Replace("/", "_");
            db.Certifications.Add(new MstCertification
            {
                Code = code.Length > 50 ? code[..50] : code,
                Name = name,
                IsActive = true
            });
        }
    }

    private static async Task SeedGraduationDegreesAsync(AppDbContext db, CancellationToken ct)
    {
        var degrees = new[] { "BE", "B.Tech", "B.Sc", "B.Com", "BCA", "B.E.", "B.A.", "B.Pharm", "BBA", "BS" };
        var existing = await db.GraduationDegrees.IgnoreQueryFilters().ToDictionaryAsync(d => d.Name.ToLower(), ct);
        foreach (var name in degrees)
        {
            if (existing.ContainsKey(name.ToLower())) continue;
            var code = name.ToLower().Replace(".", "").Replace(" ", "_");
            db.GraduationDegrees.Add(new MstGraduationDegree
            {
                Code = code,
                Name = name,
                IsActive = true
            });
        }
    }

    private static async Task SeedPostGraduationDegreesAsync(AppDbContext db, CancellationToken ct)
    {
        var degrees = new[] { "NA", "MCA", "MBA", "M.Tech", "ME", "M.Sc", "MS", "M.Com", "M.A." };
        var existing = await db.PostGraduationDegrees.IgnoreQueryFilters().ToDictionaryAsync(d => d.Name.ToLower(), ct);
        foreach (var name in degrees)
        {
            if (existing.ContainsKey(name.ToLower())) continue;
            var code = name.ToLower().Replace(".", "").Replace(" ", "_");
            db.PostGraduationDegrees.Add(new MstPostGraduationDegree
            {
                Code = code,
                Name = name,
                IsActive = true
            });
        }
    }
}