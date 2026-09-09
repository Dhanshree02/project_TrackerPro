namespace PMS.API.Shared.Constants;

// ─────────────────────────────────────────────────────────────────────────────
// RBAC Permission Catalogue
//
// The catalogue is the single source of truth for every permission the system
// understands. It is organised as a three-level tree:
//
//     MODULE  →  SUBMODULE  →  ACTION
//     projects → health     → view / raise-issue / edit-issue / resolve-issue
//
// Every leaf produces a canonical permission key in dot notation, e.g.
// `projects.health.edit-issue`. Keys are stored on the `roles` row (JSONB
// array) exactly like the legacy `module:action` keys, are embedded in the JWT
// as `permission` claims and are checked by `RequirePermissionAttribute`.
//
// `LegacyKeys` are coarse-grained aliases that map a leaf back to the older
// `module:action` permission keys (Permissions.cs). Granting a leaf also
// grants its legacy aliases, so the existing endpoint guards keep working
// while the UI manages the finer-grained tree.
// ─────────────────────────────────────────────────────────────────────────────

/// <summary>A single grantable action on a (sub)module.</summary>
public sealed record PermissionAction(
    string Key,
    string Label,
    params string[] LegacyKeys)
{
    /// <summary>Canonical key, e.g. `projects.health.edit-issue`.</summary>
    public string FullKey(string module, string? submodule) =>
        submodule is null ? $"{module}.{Key}" : $"{module}.{submodule}.{Key}";
}

/// <summary>A submodule (e.g. "Health") holding a set of actions.</summary>
public sealed record PermissionSubmodule(string Key, string Label, params PermissionAction[] Actions);

/// <summary>A top-level module (e.g. "Projects") holding submodules and/or module-level actions.</summary>
public sealed record PermissionModule(string Key, string Label, params PermissionSubmodule[] Submodules);

public static class PermissionCatalog
{
    private static PermissionAction Action(string key, string label, params string[] legacy) => new(key, label, legacy);
    private static PermissionSubmodule Sub(string key, string label, params PermissionAction[] actions) => new(key, label, actions);
    private static PermissionModule Mod(string key, string label, params PermissionSubmodule[] subs) => new(key, label, subs);

    /// <summary>
    /// Module-level actions (no submodule). Keep in sync with the submodules of
    /// each module below — these are rendered as the module's own row.
    /// </summary>
    public static readonly IReadOnlyList<PermissionModule> Modules =
    [
        Mod("dashboard", "Dashboard",
            Sub(null!, "Dashboard",
                Action("view", "View Dashboard"),
                Action("stats", "View Statistics Cards"),
                Action("kpi", "View KPI Metrics"),
                Action("activity", "View Recent Activity"))),

        Mod("action-center", "Action Centre",
            Sub(null!, "Action Centre",
                Action("view", "View Action Centre")),
            Sub("bucket-list", "Bucket List",
                Action("view", "View Bucket List"),
                Action("timer", "Start / Pause Task Timer")),
            Sub("approvals", "Approvals Tab",
                Action("view", "View Pending Approvals"),
                Action("act", "Approve / Reject Requests", Permissions.ApprovalsManage, Permissions.TimesheetsApprove)),
            Sub("alerts", "Alerts Tab",
                Action("view", "View Active Alerts"),
                Action("resolve", "Acknowledge / Resolve Alerts")),
            Sub("notifications", "Notifications Tab",
                Action("view", "View Notifications"))),

        Mod("projects", "Projects",
            Sub(null!, "Projects",
                Action("view", "View Projects", Permissions.ProjectsRead),
                Action("create", "Create Project", Permissions.ProjectsWrite),
                Action("edit", "Edit Project Details", Permissions.ProjectsWrite),
                Action("delete", "Delete Project", Permissions.ProjectsWrite),
                Action("close", "Close Project", Permissions.ProjectsClose),
                Action("drafts", "View Draft Projects"),
                Action("export", "Export Projects"),
                Action("import", "Import Projects")),
            Sub("stage-tracker", "Stage Tracker",
                Action("view", "View Stage Tracker"),
                Action("edit", "Update Stage Progress")),
            Sub("overview", "Overview Tab",
                Action("view", "View Project Overview"),
                Action("edit", "Edit Overview Details"),
                Action("budget", "View Budget & Financials"),
                Action("extension", "Request Extension"),
                Action("edit-pm", "Change Project Manager"),
                Action("edit-tl", "Change Team Lead"),
                Action("edit-spm", "Change Senior PM"),
                Action("view-spm", "View Senior PM")),
            Sub("wbs", "WBS Tab",
                Action("view", "View WBS", Permissions.WbsRead),
                Action("pmo-intake", "PMO Intake & Workflow", Permissions.WbsAllocate),
                Action("services", "Services & Deliverables"),
                Action("amount", "View WBS Amounts"),
                Action("project-allocation", "Project Resource Allocation", Permissions.WbsAllocate),
                Action("service-prereq", "Prerequisite Tracking")),
            Sub("team", "Team Tab",
                Action("view", "View Team Members"),
                Action("edit", "Edit Team Allocation"),
                Action("assign", "Assign Team Members")),
            Sub("tasks", "Tasks Tab",
                Action("view", "View Tasks"),
                Action("create", "Create Task"),
                Action("edit", "Edit Task Details"),
                Action("assign", "Assign Tasks"),
                Action("update-status", "Update Task Status")),
            Sub("health", "Health Tab",
                Action("view", "View Project Health"),
                Action("raise-issue", "Raise Issue", Permissions.IssuesRaise),
                Action("edit-issue", "Edit Issue Details"),
                Action("resolve-issue", "Resolve Issue"),
                Action("comment", "Add Health Comments"),
                Action("manage", "Manage Health & Governance", Permissions.IssuesManage),
                Action("customer-engagement", "Customer Engagement Logs")),
            Sub("invoices", "Invoices Tab",
                Action("view", "View Invoices"),
                Action("edit", "Create & Edit Invoices", Permissions.InvoicesRaise),
                Action("amount", "View Invoice Amounts"),
                Action("limited", "Limited Columns (Amounts Hidden)"))),

        Mod("reports", "Reports",
            Sub(null!, "Reports",
                Action("view", "View Reports", Permissions.ReportsRead),
                Action("export", "Export Reports")),
            Sub("sales", "Sales Reports",
                Action("view", "View Sales Pipeline")),
            Sub("wbs-tracker", "WBS Tracker",
                Action("view", "View WBS Tracker")),
            Sub("po-tracker", "PO Tracker",
                Action("view", "View Purchase Orders")),
            Sub("invoice-tracker", "Invoice Tracker",
                Action("view", "View Invoice Tracker")),
            Sub("finance", "Finance Reports",
                Action("view", "View Financial Analytics"))),

        Mod("resources", "Resources",
            Sub(null!, "Resources",
                Action("view", "View Resources Module", Permissions.ResourcesRead),
                Action("manage", "Manage Resources", Permissions.ResourcesManage)),
            Sub("directory", "Employee Directory",
                Action("view", "View Directory", Permissions.ResourcesRead),
                Action("add-employee", "Add / Onboard Employee", Permissions.ResourcesManage),
                Action("full-columns", "View Full Sensitive Columns")),
            Sub("pool", "Resource Pool",
                Action("view", "View Resource Pool"),
                Action("allocate", "Allocate Bench Resources")),
            Sub("profile", "Employee Profile",
                Action("org", "Organization Tab"),
                Action("employment", "Employment Tab"),
                Action("skills", "Skills & Qualifications Tab"),
                Action("kpi", "KPI & Performance Tab"),
                Action("finance", "Financial & Compliance Tab"),
                Action("edit", "Edit Employee Profile", Permissions.ResourcesManage),
                Action("report", "Generate Employee Report"),
                Action("offboard", "Offboard Employee", Permissions.ResourcesManage)),
            Sub("exit-summary", "Exit Summary",
                Action("view", "View Exit Directory"))),

        Mod("customers", "Customers",
            Sub(null!, "Customers",
                Action("view", "View Customers", Permissions.ClientsRead),
                Action("create", "Add Customer", Permissions.ClientsWrite),
                Action("edit", "Edit Customer Info", Permissions.ClientsWrite),
                Action("delete", "Delete Customer", Permissions.ClientsWrite),
                Action("approve", "Approve Customer", Permissions.ClientsApprove),
                Action("change-em", "Change Engagement Manager"),
                Action("assign", "Assign Customer Accounts"))),

        Mod("repository", "Repository",
            Sub(null!, "Repository",
                Action("view", "View Repository"),
                Action("download", "Download Documents"),
                Action("upload", "Upload Documents"),
                Action("delete", "Delete Documents"),
                Action("logs", "View Repository Logs"))),

        Mod("my-team", "My Team",
            Sub("dashboard", "Team Dashboard",
                Action("view", "View Team Dashboard")),
            Sub("timesheet-approval", "Timesheet Approval",
                Action("view", "View Approval Queue", Permissions.TimesheetsMonitor),
                Action("approve", "Approve Timesheet", Permissions.TimesheetsApprove),
                Action("reject", "Reject Timesheet", Permissions.TimesheetsApprove)),
            Sub("my-timesheet", "My Timesheet",
                Action("view", "View My Timesheet"),
                Action("submit", "Submit Weekly Timesheet", Permissions.TimesheetsSubmit),
                Action("edit", "Edit Timesheet Entries"))),

        Mod("settings", "Settings",
            Sub(null!, "Settings",
                Action("view", "View Settings")),
            Sub("roles", "Role Management",
                Action("view", "View Roles & Permissions"),
                Action("manage", "Manage Roles & Permissions", Permissions.RolesManage, Permissions.UsersManage)),
            Sub("audit", "Audit Log",
                Action("view", "View Permission Audit Logs", Permissions.AuditRead))),
    ];

    /// <summary>All modules as a flat list.</summary>
    public static IReadOnlyList<PermissionModule> All => Modules;

    /// <summary>
    /// Every canonical key the catalogue defines (dot notation, plus legacy aliases).
    /// </summary>
    public static IEnumerable<string> AllKeys()
    {
        foreach (var module in Modules)
        {
            foreach (var sub in module.Submodules)
            {
                foreach (var action in sub.Actions)
                {
                    yield return action.FullKey(module.Key, sub.Key);
                    foreach (var legacy in action.LegacyKeys)
                        yield return legacy;
                }
            }
        }
    }

    /// <summary>
    /// True when the permission key (dot or legacy) belongs to the catalogue.
    /// Unknown keys are preserved as-is when saving a role so nothing is lost.
    /// </summary>
    public static bool IsKnownKey(string key) => AllKeys().Contains(key);

    /// <summary>
    /// Human-readable labels for a permission key, used by the audit log.
    /// Returns (moduleLabel, submoduleLabel, actionLabel) or null when unknown.
    /// </summary>
    public static (string Module, string? Submodule, string Action)? DescribeKey(string key)
    {
        foreach (var module in Modules)
        {
            foreach (var sub in module.Submodules)
            {
                foreach (var action in sub.Actions)
                {
                    if (action.FullKey(module.Key, sub.Key) == key)
                        return (module.Label, string.IsNullOrEmpty(sub.Key) ? null : sub.Label, action.Label);

                    // Legacy aliases map to the same leaf.
                    if (action.LegacyKeys.Contains(key))
                        return (module.Label, string.IsNullOrEmpty(sub.Key) ? null : sub.Label, action.Label);
                }
            }
        }

        return null;
    }
}
