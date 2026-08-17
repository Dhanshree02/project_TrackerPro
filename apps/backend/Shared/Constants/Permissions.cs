namespace PMS.API.Shared.Constants;

/// <summary>
/// Central permission catalogue. Kept in sync with the RBAC permission map in
/// <c>wiki/23_Security_and_RBAC.md</c>. Every endpoint is guarded with one of
/// these keys (via <c>RequirePermission</c>).
/// </summary>
public static class Permissions
{
    // ---- Clients ----
    public const string ClientsRead = "clients:read";
    public const string ClientsWrite = "clients:write";
    public const string ClientsApprove = "clients:approve";

    // ---- Projects ----
    public const string ProjectsRead = "projects:read";
    public const string ProjectsWrite = "projects:write";
    public const string ProjectsClose = "projects:close";

    // ---- WBS ----
    public const string WbsRead = "wbs:read";
    public const string WbsAllocate = "wbs:allocate";

    // ---- Timesheets ----
    public const string TimesheetsSubmit = "timesheets:submit";
    public const string TimesheetsApprove = "timesheets:approve";
    public const string TimesheetsMonitor = "timesheets:monitor";

    // ---- Issues / Health ----
    public const string IssuesRaise = "issues:raise";
    public const string IssuesManage = "issues:manage";

    // ---- Finance ----
    public const string InvoicesRaise = "invoices:raise";
    public const string InvoicesPayment = "invoices:payment";

    // ---- Approvals ----
    public const string ApprovalsManage = "approvals:manage";

    // ---- Resources ----
    public const string ResourcesRead = "resources:read";
    public const string ResourcesManage = "resources:manage";

    // ---- Reports ----
    public const string ReportsRead = "reports:read";

    // ---- Administration ----
    public const string UsersManage = "users:manage";
    public const string RolesManage = "roles:manage";
    public const string AuditRead = "audit:read";
}
