using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;
using PMS.API.Shared.Constants;
using PMS.API.Modules.Customers.Models;
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

        var existingDepartments = await db.Departments.ToDictionaryAsync(d => d.Code, ct);
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

        var existingIndustries = await db.Industries.ToDictionaryAsync(i => i.Code, ct);
        var industries = new[]
        {
            ("banking", "Banking"),
            ("healthcare", "Healthcare"),
            ("retail", "Retail"),
            ("logistics", "Logistics"),
            ("energy", "Energy"),
            ("technology", "Technology"),
            ("finance", "Finance"),
            ("environment", "Environment"),
            ("automotive", "Automotive"),
        };
        foreach (var (code, name) in industries)
        {
            if (existingIndustries.ContainsKey(code)) continue;
            db.Industries.Add(new MstIndustry
            {
                Code = code,
                Name = name,
                IsActive = true,
            });
        }

        await SeedNationalitiesAsync(db, ct);
        await SeedSalaryBandsAsync(db, ct);
        var existingDesignations = await db.Designations.ToDictionaryAsync(d => d.Code, ct);
        await SeedJobRolesAsync(db, existingDesignations, ct);
        await SeedGeoCatalogsAsync(db, ct);
        await SeedEmailDomainsAsync(db, ct);
        await SeedBusinessUnitsAsync(db, ct);
        await SeedWorkLocationsAndOfficesAsync(db, ct);
    }

    private static async Task SeedBusinessUnitsAsync(AppDbContext db, CancellationToken ct)
    {
        var bus = new[] { "Cloud Platform", "Consumer Apps", "Enterprise", "Digital Solutions" };
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
        var locations = new (string Code, string Name, string[] Offices)[]
        {
            ("andheri", "Andheri", ["Suvidha Square"]),
            ("dombivli", "Dombivli", ["Navare Plaza"]),
        };

        var existingLocations = await db.WorkLocations.Include(w => w.Offices).ToListAsync(ct);
        var allowedCodes = locations.Select(l => l.Code).ToHashSet(StringComparer.OrdinalIgnoreCase);

        // Deactivate any locations & offices that are not allowed
        foreach (var loc in existingLocations)
        {
            if (!allowedCodes.Contains(loc.Code))
            {
                loc.IsActive = false;
                foreach (var off in loc.Offices)
                {
                    off.IsActive = false;
                }
            }
        }

        var locDict = existingLocations.ToDictionary(w => w.Code, StringComparer.OrdinalIgnoreCase);
        var locOrder = 1;
        foreach (var (code, name, offices) in locations)
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

            var officeOrder = 1;
            var existingOffices = loc.Offices.ToDictionary(o => o.Name.ToLower(), StringComparer.OrdinalIgnoreCase);
            var allowedOffices = offices.ToHashSet(StringComparer.OrdinalIgnoreCase);

            foreach (var off in loc.Offices)
            {
                if (!allowedOffices.Contains(off.Name))
                {
                    off.IsActive = false;
                }
            }

            foreach (var offName in offices)
            {
                if (existingOffices.TryGetValue(offName.ToLower(), out var existingOff))
                {
                    existingOff.Name = offName;
                    existingOff.IsActive = true;
                    existingOff.SortOrder = officeOrder++;
                }
                else
                {
                    loc.Offices.Add(new MstOffice
                    {
                        Code = $"{code}_{Slug(offName)}",
                        Name = offName,
                        IsActive = true,
                        SortOrder = officeOrder++,
                    });
                }
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
            ("Aisha Rao", "VP of Engineering", "aisha.rao@talakunchi.com"),
            ("Vikram Deshmukh", "Director of Product", "vikram.deshmukh@talakunchi.com"),
            ("Rohan Verma", "Engineering Manager", "rohan.verma@talakunchi.com"),
            ("Neha Kulkarni", "Technical Lead", "neha.kulkarni@talakunchi.com"),
            ("Devansh Shah", "Head of Design", "devansh.shah@talakunchi.com"),
            ("Ananya Sharma", "Lead Architect", "ananya.sharma@talakunchi.com"),
            ("Rajesh Iyer", "Delivery Manager", "rajesh.iyer@talakunchi.com"),
            ("Arjun Mehta", "Product Manager", "arjun.mehta@talakunchi.com"),
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
        var rolesByDesignation = new Dictionary<string, string[]>
        {
            ["software_engineer"] = ["Employee", "Developer", "Associate Engineer"],
            ["senior_software_engineer"] = ["Employee", "Senior Developer", "Specialist"],
            ["tech_lead"] = ["TeamLead", "Technical Lead", "Module Lead"],
            ["devops_engineer"] = ["Employee", "DevOps Specialist", "SRE"],
            ["qa_engineer"] = ["Employee", "QA Analyst", "Test Engineer"],
            ["data_analyst"] = ["Employee", "Analyst", "Data Specialist"],
            ["engineering_manager"] = ["Engineering Manager", "People Manager"],
            ["product_manager"] = ["ProjectManager", "Product Owner", "Product Manager"],
            ["ux_designer"] = ["Employee", "Designer", "UX Specialist"],
            ["marketing_lead"] = ["Marketing Lead", "Campaign Lead"],
            ["sales_executive"] = ["Sales", "Account Executive"],
            ["finance_analyst"] = ["Accounts", "Analyst"],
            ["hr_business_partner"] = ["Hr", "Business Partner"],
            ["content_strategist"] = ["Employee", "Strategist"],
            ["business_analyst"] = ["Pmo", "Analyst", "Consultant"],
            ["project_manager"] = ["ProjectManager", "Delivery Manager"],
            ["engagement_manager"] = ["Engagement Manager", "Client Partner"],
            ["senior_project_manager"] = ["Senior Project Manager", "Program Manager"],
            ["head_of_department"] = ["Head of Department", "Director"],
        };

        var existingCodes = await db.JobRoles.Select(r => r.Code).ToHashSetAsync(ct);
        var existingPairs = await db.JobRoles
            .Select(r => new { r.DesignationId, r.Name })
            .ToListAsync(ct);
        var existingKeys = existingPairs
            .Select(r => (r.DesignationId, r.Name))
            .ToHashSet();

        foreach (var (designationCode, names) in rolesByDesignation)
        {
            if (!designations.TryGetValue(designationCode, out var designation)) continue;
            foreach (var name in names)
            {
                if (existingKeys.Contains((designation.Id, name))) continue;
                var roleCode = Truncate($"{designationCode}_{Slug(name)}", 80);
                var n = 2;
                while (existingCodes.Contains(roleCode))
                {
                    var suffix = $"_{n}";
                    roleCode = Truncate(designationCode + "_" + Slug(name), 80 - suffix.Length) + suffix;
                    n++;
                }

                db.JobRoles.Add(new MstRole
                {
                    Code = roleCode,
                    Name = name,
                    DesignationId = designation.Id,
                    IsActive = true,
                });
                existingCodes.Add(roleCode);
                existingKeys.Add((designation.Id, name));
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
            ("TK-0002", "Priya", "Sharma", "Services - Testing", "PenTester - II", "Employee", "Female"),
            ("TK-0003", "Rohan", "Mehta", "Functional - IT Administration", "DevSecOps Practitioner - II", "Employee", "Male"),
            ("TK-0004", "Sneha", "Iyer", "Services - Operations", "SOC Lead - I", "TeamLead", "Female"),
            ("TK-0005", "Karthik", "Bose", "Services - Operations", "SOC Analyst - II", "Employee", "Male"),
            ("TK-0006", "Divya", "Rao", "Functional - Project Management", "Associate Project Manager", "ProjectManager", "Female"),
            ("TK-0007", "Ankit", "Verma", "Services - Operations", "SIEM Admin - II", "Employee", "Male"),
            ("TK-0008", "Neha", "Kulkarni", "Functional - Accounts", "Senior Accountant - I", "Accounts", "Female"),
            ("TK-0009", "Samar", "Patel", "Functional - HR", "HR Head", "Hr", "Male"),
            ("TK-0010", "Aanya", "Joshi", "Functional - Sales", "Business Development Associate - I", "Sales", "Female"),
            ("TK-0011", "Harsh", "Nair", "Functional - Project Management", "Associate PMO - I", "Pmo", "Male"),
            ("TK-0012", "Ira", "Kapoor", "Services - Consulting", "GRC Auditor - II", "Employee", "Female"),
            ("TK-0013", "Yash", "Malik", "Services - Testing", "Red Team Practitioner - II", "Employee", "Male"),
            ("TK-0014", "Kavya", "Desai", "R&D (Research & Development)", "Python Developer - II", "Employee", "Female"),
            ("TK-0015", "Arjun", "Shah", "Functional - IT Administration", "Desktop Support Engineer - I", "Employee", "Male"),
            ("TK-0016", "Meera", "Nambiar", "Services - Consulting", "GRC Auditor - I", "Employee", "Female"),
            ("TK-0017", "Vikram", "Gupta", "Functional - Project Management", "Senior PMO - I", "ProjectManager", "Male"),
            ("TK-0018", "Ishita", "Bansal", "Services - Testing", "PenTester - I", "Employee", "Female"),
            ("TK-0019", "Aditya", "Reddy", "Services - Operations", "SOC Analyst - I", "Employee", "Male"),
            ("TK-0020", "Pooja", "Menon", "Functional - HR", "Senior HR Executive - I", "Hr", "Female"),
            ("TK-0021", "Nikhil", "Khanna", "Functional - Sales", "Sales Associate", "Sales", "Male"),
            ("TK-0022", "Riya", "Kapoor", "Functional - Project Management", "Engagement Manager", "Engagement Manager", "Female"),
            ("TK-0023", "Rahul", "Sharma", "Functional - Project Management", "Engagement Manager", "Engagement Manager", "Male"),
            ("TK-0024", "Pradeep", "Singh", "Functional - Project Management", "Engagement Manager", "Engagement Manager", "Male"),
            ("TK-0025", "Arjun", "Mehta", "Functional - Project Management", "Engagement Manager", "Engagement Manager", "Male"),
            ("TKI-0001", "Sample", "Intern", "Services - Testing", "Intern", "Intern", "Female"),
        };

        var existingCodes = await db.Employees
            .IgnoreQueryFilters()
            .Select(e => e.EmployeeCode)
            .ToHashSetAsync(StringComparer.OrdinalIgnoreCase, ct);

        var entities = new List<Employee>();
        for (var i = 0; i < seed.Length; i++)
        {
            var row = seed[i];
            if (existingCodes.Contains(row.Code)) continue;
            departments.TryGetValue(row.Department, out var dept);
            designations.TryGetValue(row.Designation, out var desig);
            var andheri = i % 2 == 0;
            var location = andheri ? "Andheri" : "Dombivli";
            var branch = andheri ? "Suvidha Square" : "Navare Plaza";
            var n = i + 1;

            entities.Add(new Employee
            {
                EmployeeCode = row.Code,
                FirstName = row.FirstName,
                LastName = row.LastName,
                WorkEmail = $"{row.FirstName.ToLowerInvariant()}.{row.LastName.ToLowerInvariant()}@acme.co",
                PersonalEmail = $"{row.FirstName.ToLowerInvariant()}{1000 + n}@gmail.com",
                Phone = (9876501000 + n).ToString(),
                AltPhone = (9866501000 + n).ToString(),
                Gender = row.Gender,
                DateOfBirth = new DateOnly(1990 + (i % 8), 1 + (i % 12), 1 + (i % 27)),
                Address = $"{120 + n}, {location}",
                EmergencyContact = (9811101000 + n).ToString(),
                MaritalStatus = i % 3 == 0 ? "Married" : "Single",
                Nationality = indian?.Name ?? "Indian",
                NationalityId = indian?.Id,
                DepartmentId = dept?.Id,
                DesignationId = desig?.Id,
                Role = row.Role,
                JobRoleId = jobRoles.FirstOrDefault(r =>
                    r.DesignationId == desig?.Id && r.Name == row.Role)?.Id,
                BusinessUnit = i % 2 == 0 ? "Cloud Platform" : "Enterprise",
                WorkLocation = location,
                OfficeBranch = branch,
                Category = i % 5 == 0 ? "Permanent - Bond" : "Permanent - Without Bond",
                Team = $"Team {(char)('A' + (i % 6))}",
                ProjectSite = i % 3 == 0 ? "Onsite" : "Offsite",
                JoiningDate = new DateOnly(2019 + (i % 6), 1 + (i % 12), 10),
                Status = "Active",
                ConfirmationStatus = "Active",
                ProbationStatus = "Completed",
                Experience = $"{2 + (i % 10)} years",
                PreviousCompany = i % 2 == 0 ? "Infosys" : "TCS",
                EmploymentType = "Full-time",
                ContractType = "Permanent",
                BondStatus = i % 5 == 0 ? "Yes — 2 years" : "No",
                NoticePeriod = i % 2 == 0 ? "60 days" : "90 days",
                AssetId = $"TK-{4000 + n}",
                ExitType = "NA",
                ExitReason = "NA",
                Education = i % 2 == 0 ? "B.Tech Computer Science" : "MCA",
                Skills = ["Communication", "Delivery", row.Department],
                Certifications = ["NA"],
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

        var lead = entities.FirstOrDefault(e => e.EmployeeCode == "EMP-1003")
            ?? await db.Employees.FirstOrDefaultAsync(e => e.EmployeeCode == "EMP-1003", ct);

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
                emp.WorkLocation = "Andheri";
                emp.OfficeBranch = "Suvidha Square";
            }
            else
            {
                emp.WorkLocation = "Dombivli";
                emp.OfficeBranch = "Navare Plaza";
            }
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

    // ---------- helpers ----------

    /// <summary>Deterministic GUID so seeds are stable across reseeds.</summary>
    public static Guid StableGuid(string seed)
    {
        var hash = SHA256.HashData(Encoding.UTF8.GetBytes(seed));
        return new Guid(hash.AsSpan(0, 16));
    }
}
