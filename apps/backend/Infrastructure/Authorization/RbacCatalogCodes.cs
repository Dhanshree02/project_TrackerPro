namespace PMS.API.Infrastructure.Authorization;

public static class RbacCatalogCodes
{
    public const string Projects = "projects";
    public const string ProjectDetail = "project-detail";
    public const string ProjectWbs = "project-wbs";
    public const string ProjectTeam = "project-team";
    public const string ProjectTasks = "project-tasks";
    public const string ProjectHealth = "project-health";
    public const string HealthIssues = "health-issues";
    public const string HealthAlerts = "health-alerts";
    public const string HealthEscalations = "health-escalations";
    public const string HealthAppreciation = "health-appreciation";
    public const string HealthCustomerEngagement = "health-customer-engagement";
    public const string HealthExtensionRequest = "health-extension-request";
    public const string Customers = "customers";
    public const string CustomerDetail = "customer-detail";
    public const string Repository = "repository";
    public const string Resources = "resources";
    public const string EmployeeDirectory = "employee-directory";
    public const string EmployeeDetail = "employee-detail";
    public const string TeamDashboard = "team-dashboard";
    public const string MyTeamTab = "my-team-tab";
    public const string MyReportees = "my-reportees";
    public const string AllEmployees = "all-employees";
    public const string Timesheets = "timesheets";
    public const string MyTimesheet = "my-timesheet";
    public const string TimesheetHistory = "timesheet-history";
    public const string TimesheetApproval = "timesheet-approval";
    public const string ActionBucketList = "bucket-list";
    public const string ActionApprovals = "approvals";
    public const string ActionAlerts = "alerts";
    public const string ActionNotifications = "notifications";

    public static readonly IReadOnlyDictionary<string, Guid> CodeToId = new Dictionary<string, Guid>(StringComparer.OrdinalIgnoreCase)
    {
        // Modules
        ["dashboard"] = Guid.Parse("471bc977-be2e-449d-91e7-5c11cb9c4ec0"),
        ["action-centre"] = Guid.Parse("5a049953-8170-4ef4-a59e-43dc19e12de5"),
        ["action-center"] = Guid.Parse("5a049953-8170-4ef4-a59e-43dc19e12de5"),
        ["projects"] = Guid.Parse("168b1296-de6a-4f9e-a3b9-617b83863736"),
        ["resources"] = Guid.Parse("715f79ce-51ea-46d3-b95d-8318840f90a6"),
        ["customers"] = Guid.Parse("4e57fd71-b53e-43c0-862e-5698e09c0922"),
        ["customer"] = Guid.Parse("4e57fd71-b53e-43c0-862e-5698e09c0922"),
        ["repository"] = Guid.Parse("c04c546e-0f2c-448d-b634-5d517843d365"),
        ["my-team"] = Guid.Parse("6055ce3c-b466-4354-ba9a-b4c309111e9d"),
        ["settings"] = Guid.Parse("fcb69b3e-e5aa-49bb-921f-7793f0a8c90d"),

        // Submodules & Detail Pages
        ["employee-directory"] = Guid.Parse("39dbd425-643b-47e9-9936-6bbae9ef5ef5"),
        ["exit-summary"] = Guid.Parse("526e2d0d-47d4-4814-9e5a-8f7c53af1432"),
        ["master"] = Guid.Parse("662d62ab-38b1-447e-876e-7f93bf2ba50e"),
        ["team-dashboard"] = Guid.Parse("9854b7f3-8e7e-4ecb-864f-f2533ff295f9"),
        ["my-team-tab"] = Guid.Parse("9854b7f3-0001-4000-8000-000000000001"),
        ["team-roster"] = Guid.Parse("9854b7f3-0001-4000-8000-000000000001"),
        ["my-reportees"] = Guid.Parse("b1e81c2a-34de-4dd4-b1f3-47387b8ed52b"),
        ["all-employees"] = Guid.Parse("552f9f86-4eb0-473a-8e39-9863cfefcea4"),
        ["timesheets"] = Guid.Parse("d67426d3-05df-4608-b8cf-c0ecfe698dc3"),
        ["roles-permissions"] = Guid.Parse("e231d2d4-9ebb-4eb2-af48-fbe3b3b4ab90"),
        ["customer-detail"] = Guid.Parse("a7e6b014-9f4a-4d2c-87d2-431527ef9a10"),
        ["project-detail"] = Guid.Parse("b8f7c125-0e5b-4e3d-98e3-542638fa0b21"),
        ["employee-detail"] = Guid.Parse("e8f7c125-0e5b-4e3d-98e3-542638fa0b23"),

        // Action Centre Tabs
        ["bucket-list"] = Guid.Parse("db9aa2d2-1876-4d81-9ff6-6b55be19fb7a"),
        ["approvals"] = Guid.Parse("a7bd6c40-4e96-4abb-be93-4ed4e4211978"),
        ["alerts"] = Guid.Parse("5b828ae3-0b45-4a1c-a1cb-78b29e882cf3"),
        ["action-alerts"] = Guid.Parse("5b828ae3-0b45-4a1c-a1cb-78b29e882cf3"),
        ["notifications"] = Guid.Parse("69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc"),

        // Timesheets Tabs
        ["my-timesheet"] = Guid.Parse("d67426d3-0001-4000-8000-000000000001"),
        ["timesheet-history"] = Guid.Parse("d67426d3-0001-4000-8000-000000000002"),
        ["timesheet-approval"] = Guid.Parse("d67426d3-0001-4000-8000-000000000003"),

        // Project Detail Tabs
        ["project-overview"] = Guid.Parse("c1a11111-0001-4000-8000-000000000001"),
        ["project-wbs"] = Guid.Parse("c1a11111-0001-4000-8000-000000000002"),
        ["project-team"] = Guid.Parse("c1a11111-0001-4000-8000-000000000003"),
        ["project-tasks"] = Guid.Parse("c1a11111-0001-4000-8000-000000000004"),
        ["project-health"] = Guid.Parse("c1a11111-0001-4000-8000-000000000005"),
        ["project-invoices"] = Guid.Parse("c1a11111-0001-4000-8000-000000000006"),

        // Project Overview Subtabs
        ["overview-budget"] = Guid.Parse("c1a11111-0003-4000-8000-000000000001"),
        ["overview-senior-project-managers"] = Guid.Parse("c1a11111-0003-4000-8000-000000000002"),
        ["overview-project-managers"] = Guid.Parse("c1a11111-0003-4000-8000-000000000003"),
        ["overview-team-leads"] = Guid.Parse("c1a11111-0003-4000-8000-000000000004"),

        // Project Health Subtabs
        ["health-issues"] = Guid.Parse("c1a11111-0002-4000-8000-000000000001"),
        ["health-alerts"] = Guid.Parse("c1a11111-0002-4000-8000-000000000002"),
        ["health-escalations"] = Guid.Parse("c1a11111-0002-4000-8000-000000000003"),
        ["health-appreciation"] = Guid.Parse("c1a11111-0002-4000-8000-000000000004"),
        ["health-customer-engagement"] = Guid.Parse("c1a11111-0002-4000-8000-000000000005"),
        ["health-extension-request"] = Guid.Parse("c1a11111-0002-4000-8000-000000000006"),

        // Dashboard Widgets
        ["total-team-size"] = Guid.Parse("682f26ec-e31d-43a0-82de-e915bab54b59"),
        ["resource-boarding-details"] = Guid.Parse("9c916f1a-72e0-4d52-bec1-6d684e990c65"),
        ["team-utilization-onsite"] = Guid.Parse("896c2166-8f1f-4ab8-873c-755ab3d051fb"),
        ["team-utilization-offsite"] = Guid.Parse("2b83bafc-1c64-449c-a644-e8e19e0c0a48"),
        ["team-utilization-onsite-projects"] = Guid.Parse("7e3f4519-8acd-489f-a70a-ac39092fbd40"),
        ["team-allocation-onsite-offsite"] = Guid.Parse("3c5780f7-e23d-48bd-b73e-51019dfbc2bd"),
        ["team-resignation-count"] = Guid.Parse("0d274292-537d-4c41-8e23-3df901304d71"),
        ["team-capacity-offsite"] = Guid.Parse("d6dea306-2e8f-41a0-89c8-857cb96f5558"),

        // Employee Detail Tabs
        ["employee-personal-info"] = Guid.Parse("e1a11111-0001-4000-8000-000000000001"),
        ["employee-organization-details"] = Guid.Parse("e1a11111-0001-4000-8000-000000000002"),
        ["employee-employment-bond"] = Guid.Parse("e1a11111-0001-4000-8000-000000000003"),
        ["employee-education-experience"] = Guid.Parse("e1a11111-0001-4000-8000-000000000004"),
        ["employee-pmo-em-information"] = Guid.Parse("e1a11111-0001-4000-8000-000000000005"),
        ["employee-activity-logs"] = Guid.Parse("e1a11111-0001-4000-8000-000000000006"),
    };

    private static readonly IReadOnlyDictionary<Guid, string> IdToCode =
        CodeToId.GroupBy(kv => kv.Value).ToDictionary(g => g.Key, g => g.First().Key);

    public static string? ResolveCode(Guid id) => IdToCode.TryGetValue(id, out var code) ? code : null;

    public static Guid? ResolveId(string codeOrId)
    {
        if (Guid.TryParse(codeOrId, out var parsed))
            return parsed;

        if (CodeToId.TryGetValue(codeOrId, out var id))
            return id;

        return null;
    }
}

