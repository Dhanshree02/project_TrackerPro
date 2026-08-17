using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;
using PMS.API.Shared.Constants;
using PMS.API.Modules.Customers.Models;
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
        await SeedClientsAsync(db, users, ct);
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

    // ---------- Clients ----------

    private static async Task SeedClientsAsync(AppDbContext db, Dictionary<string, User> users, CancellationToken ct)
    {
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

    // ---------- helpers ----------

    /// <summary>Deterministic GUID so seeds are stable across reseeds.</summary>
    public static Guid StableGuid(string seed)
    {
        var hash = SHA256.HashData(Encoding.UTF8.GetBytes(seed));
        return new Guid(hash.AsSpan(0, 16));
    }
}
