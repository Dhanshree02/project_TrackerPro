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
            Sub(null!, "Dashboard", Action("view", "View"))),

        Mod("action-center", "Action Center",
            Sub(null!, "Action Center", Action("view", "View"))),

        Mod("projects", "Projects",
            Sub(null!, "Projects",
                Action("view", "View", Permissions.ProjectsRead),
                Action("create", "Create", Permissions.ProjectsWrite),
                Action("edit", "Edit", Permissions.ProjectsWrite),
                Action("delete", "Delete", Permissions.ProjectsWrite),
                Action("close", "Close", Permissions.ProjectsClose),
                Action("approve", "Approve"),
                Action("assign", "Assign"),
                Action("export", "Export"),
                Action("import", "Import")),
            Sub("overview", "Overview",
                Action("view", "View"),
                Action("edit", "Edit")),
            Sub("budget", "Budget",
                Action("view", "View")),
            Sub("team", "Team",
                Action("view", "View"),
                Action("assign", "Assign")),
            Sub("task", "Task",
                Action("view", "View"),
                Action("create", "Create"),
                Action("edit", "Edit"),
                Action("assign", "Assign"),
                Action("update-status", "Update Status")),
            Sub("health", "Health",
                Action("view", "View"),
                Action("raise-issue", "Raise Issue", Permissions.IssuesRaise),
                Action("edit-issue", "Edit Issue"),
                Action("resolve-issue", "Resolve Issue"),
                Action("comment", "Comment"),
                Action("manage", "Manage Issues", Permissions.IssuesManage)),
            Sub("health-issues", "Health Issues",
                Action("view", "View"),
                Action("create", "Create"),
                Action("edit", "Edit"),
                Action("resolve", "Resolve")),
            Sub("alerts", "Alerts",
                Action("view", "View"),
                Action("create", "Create"),
                Action("resolve", "Resolve")),
            Sub("escalation", "Escalation",
                Action("view", "View"),
                Action("create", "Create"),
                Action("resolve", "Resolve")),
            Sub("communication", "Communication",
                Action("view", "View"),
                Action("create", "Create")),
            Sub("pmo", "PMO",
                Action("view", "View"),
                Action("manage", "Manage")),
            Sub("prerequisite", "Prerequisite",
                Action("view", "View"),
                Action("manage", "Manage")),
            Sub("services-deliverables", "Services & Deliverables",
                Action("view", "View"),
                Action("manage", "Manage")),
            Sub("invoice-schedule", "Invoice Schedule",
                Action("view", "View"),
                Action("manage", "Manage", Permissions.InvoicesRaise, Permissions.InvoicesPayment)),
            Sub("assigned-projects", "Assigned Projects",
                Action("view", "View"))),

        Mod("reports", "Reports",
            Sub(null!, "Reports",
                Action("view", "View", Permissions.ReportsRead),
                Action("export", "Export")),
            Sub("finance", "Finance Reports",
                Action("view", "View"))),

        Mod("resources", "Resources",
            Sub(null!, "Resources",
                Action("view", "View", Permissions.ResourcesRead),
                Action("manage", "Manage", Permissions.ResourcesManage)),
            Sub("directory", "Directory",
                Action("view", "View")),
            Sub("kpi", "Restricted Status / KPI",
                Action("view", "View"))),

        Mod("customers", "Customers",
            Sub(null!, "Customers",
                Action("view", "View", Permissions.ClientsRead),
                Action("create", "Create", Permissions.ClientsWrite),
                Action("edit", "Edit", Permissions.ClientsWrite),
                Action("delete", "Delete", Permissions.ClientsWrite),
                Action("approve", "Approve", Permissions.ClientsApprove),
                Action("assign", "Assign"))),

        Mod("repository", "Repository",
            Sub(null!, "Repository", Action("view", "View"))),

        Mod("my-team", "My Team",
            Sub("dashboard", "Team Dashboard",
                Action("view", "View")),
            Sub("timesheet-approval", "Timesheet Approval",
                Action("view", "View", Permissions.TimesheetsMonitor),
                Action("approve", "Approve", Permissions.TimesheetsApprove),
                Action("reject", "Reject", Permissions.TimesheetsApprove)),
            Sub("my-timesheet", "My Timesheet",
                Action("view", "View"),
                Action("submit", "Submit", Permissions.TimesheetsSubmit),
                Action("edit", "Edit"))),

        Mod("wbs", "WBS Allocation",
            Sub(null!, "WBS Allocation",
                Action("view", "View", Permissions.WbsRead),
                Action("allocate", "Allocate", Permissions.WbsAllocate))),

        Mod("approvals", "Approvals",
            Sub(null!, "Approvals",
                Action("view", "View", Permissions.ApprovalsManage),
                Action("approve", "Approve", Permissions.TimesheetsApprove),
                Action("reject", "Reject", Permissions.TimesheetsApprove))),

        Mod("portfolio", "Portfolio",
            Sub(null!, "Portfolio", Action("view", "View"))),

        Mod("settings", "Settings",
            Sub(null!, "Settings",
                Action("view", "View")),
            Sub("roles", "Role Management",
                Action("view", "View"),
                Action("manage", "Manage Roles", Permissions.RolesManage)),
            Sub("permissions", "Permission Management",
                Action("view", "View"),
                Action("manage", "Manage Permissions", Permissions.UsersManage)),
            Sub("audit", "Audit Log",
                Action("view", "View", Permissions.AuditRead))),
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
