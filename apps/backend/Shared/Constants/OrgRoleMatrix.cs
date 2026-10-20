namespace PMS.API.Shared.Constants;

/// <summary>
/// Canonical Department → Designation → Sub-Department → On Floor Role → RBAC
/// rows from <c>docs/rbac.xlsx</c>. Live mapping is <c>master.mst_org_role_map</c>.
/// </summary>
public static class OrgRoleMatrix
{
    public const string SuperAdminEmployeeCode = "TK-0004";
    public const string SuperAdminEmail = "admin@talakunchi.com";
    public const string SuperAdminRbac = "Admin";

    public static readonly string[] OnFloorRoles =
    [
        "Leader",
        "IT Admin",
        "Accounts",
        "HR",
        "Manager",
        "Team Member",
        "Team Leader",
        "Project Manager",
        "Sr. Manager",
        "Head Of Department",
    ];

    public sealed record Row(
        string Department,
        string Designation,
        string SubDepartment,
        string OnFloorRole,
        string RbacRole);

    /// <summary>Existing <c>auth.tbl_roles.Name</c> keys for Excel RBAC labels.</summary>
    public static string RbacKey(string excelOrKey)
    {
        var raw = Normalize(excelOrKey);
        return Aliases.TryGetValue(raw, out var key) ? key : excelOrKey.Trim();
    }

    public static bool TryFind(string? department, string? designation, out Row row)
    {
        row = default!;
        if (string.IsNullOrWhiteSpace(designation)) return false;
        if (Normalize(designation) == "intern")
        {
            row = InternRow(department);
            return true;
        }

        if (string.IsNullOrWhiteSpace(department)) return false;
        return Map.TryGetValue((Normalize(department), Normalize(designation)), out row!);
    }

    public static IReadOnlyList<Row> All => Rows;

    private static Row InternRow(string? department) =>
        new(
            string.IsNullOrWhiteSpace(department) ? "Internship Program" : department.Trim(),
            "Intern",
            "Across all Sub Departments",
            "Team Member",
            "Intern");

    private static readonly Dictionary<string, string> Aliases = new(StringComparer.OrdinalIgnoreCase)
    {
        ["ceo"] = "CEO",
        ["coo"] = "COO",
        ["cto"] = "CTO",
        ["it admin"] = "IT Admin",
        ["accounts"] = "Accounts",
        ["hr"] = "HR",
        ["sales manager"] = "Sales Manager",
        ["sales team member"] = "Sales team member",
        ["pmo"] = "PMO",
        ["pmo (project management office)"] = "PMO",
        ["em (engagement manager)"] = "EngagementManager",
        ["engagement manager"] = "EngagementManager",
        ["engagementmanager"] = "EngagementManager",
        ["r&d -team member"] = "R&D - Team member",
        ["r&d - team member"] = "R&D - Team member",
        ["soc- team member"] = "SOC-Team Member",
        ["soc-team member"] = "SOC-Team Member",
        ["soc- team leader"] = "SOC-Team Leader",
        ["soc-team leader"] = "SOC-Team Leader",
        ["soc- manager"] = "SOC-Manager",
        ["soc-manager"] = "SOC-Manager",
        ["soc- senior manager"] = "SOC-Senior Manager",
        ["soc-senior manager"] = "SOC-Senior Manager",
        ["soc- hod"] = "SOC-HOD",
        ["soc-hod"] = "SOC-HOD",
        ["consulting -team member"] = "Consulting-Team member",
        ["consulting-team member"] = "Consulting-Team member",
        ["consulting -team leader"] = "Consulting-Team Leader",
        ["consulting-team leader"] = "Consulting-Team Leader",
        ["consulting-manager"] = "Consulting-Manager",
        ["consulting-hod"] = "Consulting-HOD",
        ["testing-team member"] = "Testing-Team Member",
        ["testing-team leader"] = "Testing-Team Leader",
        ["testing-manager"] = "Testing-Manager",
        ["testing- senior manager"] = "Testing Senior Manager",
        ["testing senior manager"] = "Testing Senior Manager",
        ["intern"] = "Intern",
        ["admin"] = "Admin",
    };

    public static readonly Dictionary<string, string> RbacDisplayNames = new(StringComparer.OrdinalIgnoreCase)
    {
        ["CEO"] = "CEO",
        ["COO"] = "COO",
        ["CTO"] = "CTO",
        ["IT Admin"] = "IT Admin",
        ["Accounts"] = "Accounts",
        ["HR"] = "HR",
        ["Sales Manager"] = "Sales Manager",
        ["Sales team member"] = "Sales Team Member",
        ["PMO"] = "PMO (Project Management Office)",
        ["EngagementManager"] = "EM (Engagement Manager)",
        ["R&D - Team member"] = "R&D -Team member",
        ["SOC-Team Member"] = "SOC- Team Member",
        ["SOC-Team Leader"] = "SOC- Team Leader",
        ["SOC-Manager"] = "SOC- Manager",
        ["SOC-Senior Manager"] = "SOC- Senior Manager",
        ["SOC-HOD"] = "SOC- HOD",
        ["Consulting-Team member"] = "Consulting -Team member",
        ["Consulting-Team Leader"] = "Consulting -Team Leader",
        ["Consulting-Manager"] = "Consulting-Manager",
        ["Consulting-HOD"] = "Consulting-HOD",
        ["Testing-Team Member"] = "Testing-Team Member",
        ["Testing-Team Leader"] = "Testing-Team Leader",
        ["Testing-Manager"] = "Testing-Manager",
        ["Testing Senior Manager"] = "Testing- Senior Manager",
        ["Intern"] = "Intern",
        ["Admin"] = "Admin",
    };

    private static readonly Row[] Rows =
    [
        new("Core", "Director and Chief Executive Officer", "Leading Sales & A/C Department", "Leader", "CEO"),
        new("Core", "Director and Chief Operating Officer", "Leading Delivery Department", "Leader", "COO"),
        new("Core", "Director and Chief Technology Officer", "Leading Compliance & HR Department", "Leader", "CTO"),
        new("Functional - IT Administration", "IT Admin", "Functional - IT Administration", "IT Admin", "IT Admin"),
        new("Functional - IT Administration", "Desktop Support Engineer - I", "Functional - IT Administration", "IT Admin", "IT Admin"),
        new("Functional - IT Administration", "Desktop Support Engineer - II", "Functional - IT Administration", "IT Admin", "IT Admin"),
        new("Functional - Accounts", "Accountant - I", "Functional - Accounts", "Accounts", "Accounts"),
        new("Functional - Accounts", "Accountant - II", "Functional - Accounts", "Accounts", "Accounts"),
        new("Functional - Accounts", "Accountant - III", "Functional - Accounts", "Accounts", "Accounts"),
        new("Functional - Accounts", "Senior Accountant - I", "Functional - Accounts", "Accounts", "Accounts"),
        new("Functional - Accounts", "Senior Accountant - II", "Functional - Accounts", "Accounts", "Accounts"),
        new("Functional - Accounts", "Senior Accountant - III", "Functional - Accounts", "Accounts", "Accounts"),
        new("Functional - HR", "HR Head", "Functional - HR", "HR", "HR"),
        new("Functional - HR", "Recruitment Coordinator - I", "Functional - HR", "HR", "HR"),
        new("Functional - HR", "Recruitment Coordinator - II", "Functional - HR", "HR", "HR"),
        new("Functional - HR", "Senior HR Executive - I", "Functional - HR", "HR", "HR"),
        new("Functional - HR", "Senior HR Executive - II", "Functional - HR", "HR", "HR"),
        new("Functional - Sales", "Business Development Associate - I", "Functional - Sales", "Manager", "Sales Manager"),
        new("Functional - Sales", "Customer Success Representative - II", "Functional - Sales", "Manager", "Sales Manager"),
        new("Functional - Sales", "Director - Product Sales", "Functional - Sales", "Team Member", "Sales Team Member"),
        new("Functional - Sales", "Sales Associate", "Functional - Sales", "Team Member", "Sales Team Member"),
        new("Functional - Sales", "Associate Customer Success Representative - I", "Functional - Sales", "Team Member", "Sales Team Member"),
        new("Functional - Sales", "Associate Customer Success Representative - II", "Functional - Sales", "Team Member", "Sales Team Member"),
        new("Functional - Project Management", "Associate PMO - I", "PMO (Project Management Office)", "Team Member", "PMO (Project Management Office)"),
        new("Functional - Project Management", "Associate PMO - II", "PMO (Project Management Office)", "Team Member", "PMO (Project Management Office)"),
        new("Functional - Project Management", "Senior PMO - I", "PMO (Project Management Office)", "Team Leader", "PMO (Project Management Office)"),
        new("Functional - Project Management", "Senior PMO - II", "PMO (Project Management Office)", "Manager", "PMO (Project Management Office)"),
        new("Functional - Project Management", "Delivery Account Manager - I", "EM (Engagement Manager)", "Team Member", "EM (Engagement Manager)"),
        new("Functional - Project Management", "Delivery Account Manager - II", "EM (Engagement Manager)", "Team Member", "EM (Engagement Manager)"),
        new("Functional - Project Management", "Senior Delivery Account Manager - I", "EM (Engagement Manager)", "Team Leader", "EM (Engagement Manager)"),
        new("Functional - Project Management", "Senior Delivery Account Manager - II", "EM (Engagement Manager)", "Manager", "EM (Engagement Manager)"),
        new("R&D (Research & Development)", "Python Developer - I", "R&D (Research & Development)", "Team Member", "R&D -Team member"),
        new("R&D (Research & Development)", "Python Developer - II", "R&D (Research & Development)", "Team Member", "R&D -Team member"),
        new("R&D (Research & Development)", "Python Developer - III", "R&D (Research & Development)", "Team Member", "R&D -Team member"),
        new("Services - Operations", "SOC Analyst - I", "Services - Operations", "Team Member", "SOC- Team Member"),
        new("Services - Operations", "SOC Analyst - II", "Services - Operations", "Team Member", "SOC- Team Member"),
        new("Services - Operations", "SOC Analyst - III", "Services - Operations", "Team Member", "SOC- Team Member"),
        new("Services - Operations", "SOC Analyst - IV", "Services - Operations", "Team Member", "SOC- Team Member"),
        new("Services - Operations", "SIEM Admin - I", "Services - Operations", "Team Member", "SOC- Team Member"),
        new("Services - Operations", "SIEM Admin - II", "Services - Operations", "Team Member", "SOC- Team Member"),
        new("Services - Operations", "SIEM Admin - III", "Services - Operations", "Team Member", "SOC- Team Member"),
        new("Services - Operations", "SIEM Admin - IV", "Services - Operations", "Team Leader", "SOC- Team Leader"),
        new("Services - Operations", "SOC Consultant - I", "Services - Operations", "Team Member", "SOC- Team Member"),
        new("Services - Operations", "SOC Consultant - II", "Services - Operations", "Team Member", "SOC- Team Member"),
        new("Services - Operations", "SOC Shift Lead - I", "Services - Operations", "Team Leader", "SOC- Team Leader"),
        new("Services - Operations", "SOC Shift Lead - II", "Services - Operations", "Team Leader", "SOC- Team Leader"),
        new("Services - Operations", "SOC Lead - I", "Services - Operations", "Project Manager", "SOC- Manager"),
        new("Services - Operations", "SOC Lead - II", "Services - Operations", "Sr. Manager", "SOC- Senior Manager"),
        new("Services - Operations", "Principal Manager - I", "Services - Operations", "Head Of Department", "SOC- HOD"),
        new("Services - Consulting", "GRC Auditor - I", "Services - Consulting", "Team Member", "Consulting -Team member"),
        new("Services - Consulting", "GRC Auditor - II", "Services - Consulting", "Team Member", "Consulting -Team member"),
        new("Services - Consulting", "GRC Auditor - III", "Services - Consulting", "Team Member", "Consulting -Team member"),
        new("Services - Consulting", "GRC Auditor - IV", "Services - Consulting", "Team Member", "Consulting -Team member"),
        new("Services - Consulting", "Senior GRC Auditor - I", "Services - Consulting", "Team Leader", "Consulting -Team Leader"),
        new("Services - Consulting", "Senior GRC Auditor - II", "Services - Consulting", "Team Leader", "Consulting -Team Leader"),
        new("Services - Consulting", "Associate Manager - III", "Services - Consulting", "Manager", "Consulting-Manager"),
        new("Services - Consulting", "Senior Vice President - Principal Consultant", "Services - Consulting", "Head Of Department", "Consulting-HOD"),
        new("Services - Testing", "PenTester - I", TestingCore, "Team Member", "Testing-Team Member"),
        new("Services - Testing", "PenTester - II", TestingCore, "Team Member", "Testing-Team Member"),
        new("Services - Testing", "PenTester - III", TestingCore, "Team Member", "Testing-Team Member"),
        new("Services - Testing", "PenTester - IV", TestingCore, "Team Member", "Testing-Team Member"),
        new("Services - Testing", "Senior Pentester - I", TestingCore, "Team Member", "Testing-Team Member"),
        new("Services - Testing", "Senior Pentester - II", TestingCore, "Team Member", "Testing-Team Member"),
        new("Services - Testing", "Associate Manager - I", TestingCore, "Team Leader", "Testing-Team Leader"),
        new("Services - Testing", "Associate Manager - II", TestingCore, "Team Leader", "Testing-Team Leader"),
        new("Services - Testing", "Associate Manager - III", TestingCore, "Team Leader", "Testing-Team Leader"),
        new("Services - Testing", "Associate Project Manager", TestingCore, "Manager", "Testing-Manager"),
        new("Services - Testing", "Manager - I", TestingCore, "Sr. Manager", "Testing- Senior Manager"),
        new("Services - Testing", "DevSecOps Practitioner - I", "Services - Testing - DevSecOps", "Team Member", "Testing-Team Member"),
        new("Services - Testing", "DevSecOps Practitioner - II", "Services - Testing - DevSecOps", "Team Member", "Testing-Team Member"),
        new("Services - Testing", "DevSecOps Practitioner - III", "Services - Testing - DevSecOps", "Team Member", "Testing-Team Member"),
        new("Services - Testing", "DevSecOps Associate", "Services - Testing - DevSecOps", "Team Leader", "Testing-Team Leader"),
        new("Services - Testing", "DevSecOps Specialist - II", "Services - Testing - DevSecOps", "Manager", "Testing-Manager"),
        new("Services - Testing", "Red Team Practitioner - II", "Services - Testing - Red Team", "Team Member", "Testing-Team Member"),
        new("Services - Testing", "Red Team Practitioner - III", "Services - Testing - Red Team", "Team Member", "Testing-Team Member"),
        new("Services - Testing", "Red Team Specialist - II", "Services - Testing - Red Team", "Manager", "Testing-Manager"),
        new("Services - Testing", "Senior Cloud Security Consultant - I", "Services - Testing - Cloud & AI", "Manager", "Testing-Manager"),
        new("Services - Testing", "Associate AI Engineer - Contractual", "Services - Testing - Cloud & AI", "Team Member", "Testing-Team Member"),
        new("Internship Program", "Intern", "Across all Sub Departments", "Team Member", "Intern"),
    ];

    private const string TestingCore =
        "Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra";

    private static readonly Dictionary<(string Department, string Designation), Row> Map =
        Rows.ToDictionary(r => (Normalize(r.Department), Normalize(r.Designation)), r => r);

    public static string Normalize(string? value) =>
        string.Join(' ', (value ?? string.Empty).Replace('\u00a0', ' ').Split(' ', StringSplitOptions.RemoveEmptyEntries))
            .Trim()
            .ToLowerInvariant();

    public static string OnFloorCode(string name) =>
        "onfloor_" + name.ToLowerInvariant()
            .Replace(".", "")
            .Replace("&", "and")
            .Replace(" ", "_");

    public static bool IsSuperAdmin(string? employeeCode, string? workEmail)
    {
        if (string.Equals(employeeCode?.Trim(), SuperAdminEmployeeCode, StringComparison.OrdinalIgnoreCase))
            return true;
        return string.Equals(workEmail?.Trim(), SuperAdminEmail, StringComparison.OrdinalIgnoreCase);
    }
}
