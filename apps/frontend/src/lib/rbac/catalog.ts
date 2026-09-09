import type { Role } from "@/lib/mock-data";

/** Login roles used across Settings and the app. Admin is the super-user. */
export const APP_ROLES = [
  "employee",
  "pm",
  "senior_pm",
  "engagement_manager",
  "pmo",
  "business_owner",
  "hod",
  "hr",
  "accounts_finance",
  "sales_bd",
  "dhanshree",
] as const satisfies readonly Role[];

export type AppRole = (typeof APP_ROLES)[number];

export const ROLE_LABELS: Record<Role, string> = {
  employee: "Employee",
  pm: "Project Manager",
  senior_pm: "Senior Project Manager",
  engagement_manager: "Engagement Manager",
  pmo: "PMO",
  business_owner: "Business Owner",
  hod: "Head of Department",
  hr: "HR",
  accounts_finance: "Accounts & Finance",
  sales_bd: "Sales & BD",
  dhanshree: "Admin",
};

export interface PermissionCatalogItem {
  key: string;
  module: string;
  submodule?: string | null;
  group: string;
  label: string;
  description?: string;
}

export const PERMISSION_CATALOG: PermissionCatalogItem[] = [
  // ─── Dashboard ────────────────────────────────────────────────────────────
  { key: "dashboard.view", module: "Dashboard", submodule: "Overview", group: "Access", label: "View dashboard" },
  { key: "dashboard.stats", module: "Dashboard", submodule: "Overview", group: "Widgets", label: "View statistics cards" },
  { key: "dashboard.kpi", module: "Dashboard", submodule: "Overview", group: "Widgets", label: "View KPI metrics" },
  { key: "dashboard.activity", module: "Dashboard", submodule: "Overview", group: "Widgets", label: "View recent activity" },

  // ─── Action Centre ────────────────────────────────────────────────────────
  { key: "action-center.view", module: "Action Centre", submodule: "Overview", group: "Access", label: "View action centre" },
  { key: "action.bucket_list", module: "Action Centre", submodule: "Bucket List", group: "Tabs", label: "View bucket list" },
  { key: "action-center.bucket-list.view", module: "Action Centre", submodule: "Bucket List", group: "Tabs", label: "Bucket list tab" },
  { key: "action.bucket_timer", module: "Action Centre", submodule: "Bucket List", group: "Actions", label: "Start / pause task timer" },
  { key: "action-center.bucket-list.timer", module: "Action Centre", submodule: "Bucket List", group: "Actions", label: "Task timer controls" },
  { key: "action.approvals", module: "Action Centre", submodule: "Approvals", group: "Tabs", label: "Approvals tab" },
  { key: "action-center.approvals.view", module: "Action Centre", submodule: "Approvals", group: "Tabs", label: "View pending approvals" },
  { key: "action.acknowledge", module: "Action Centre", submodule: "Approvals", group: "Actions", label: "Approve / reject requests" },
  { key: "action-center.approvals.act", module: "Action Centre", submodule: "Approvals", group: "Actions", label: "Approve / acknowledge actions" },
  { key: "action.alerts", module: "Action Centre", submodule: "Alerts", group: "Tabs", label: "Alerts tab" },
  { key: "action-center.alerts.view", module: "Action Centre", submodule: "Alerts", group: "Tabs", label: "View active alerts" },
  { key: "action-center.alerts.resolve", module: "Action Centre", submodule: "Alerts", group: "Actions", label: "Resolve / dismiss alerts" },
  { key: "action.notifications", module: "Action Centre", submodule: "Notifications", group: "Tabs", label: "Notifications tab" },
  { key: "action-center.notifications.view", module: "Action Centre", submodule: "Notifications", group: "Tabs", label: "View notifications" },

  // ─── Projects ─────────────────────────────────────────────────────────────
  { key: "projects.view", module: "Projects", submodule: "Directory", group: "Access", label: "View projects" },
  { key: "projects.create", module: "Projects", submodule: "Directory", group: "Actions", label: "Create new project" },
  { key: "projects.drafts", module: "Projects", submodule: "Directory", group: "Actions", label: "View drafts" },
  { key: "projects.export", module: "Projects", submodule: "Directory", group: "Actions", label: "Export projects list" },
  { key: "projects.close", module: "Projects", submodule: "Directory", group: "Actions", label: "Close / archive project" },

  // Projects -> Stage Tracker
  { key: "projects.stage_tracker", module: "Projects", submodule: "Stage Tracker", group: "Widgets", label: "Stage tracker widget" },
  { key: "projects.stage-tracker.view", module: "Projects", submodule: "Stage Tracker", group: "Widgets", label: "View stage tracker" },
  { key: "projects.stage-tracker.edit", module: "Projects", submodule: "Stage Tracker", group: "Actions", label: "Update stage progress" },

  // Projects -> Overview Tab
  { key: "projects.tab.overview", module: "Projects", submodule: "Overview", group: "Tabs", label: "Overview tab" },
  { key: "projects.overview.view", module: "Projects", submodule: "Overview", group: "Access", label: "View project overview" },
  { key: "projects.overview.edit", module: "Projects", submodule: "Overview", group: "Actions", label: "Edit project overview" },
  { key: "projects.overview.budget", module: "Projects", submodule: "Overview", group: "Widgets", label: "View budget / amounts" },
  { key: "projects.budget.view", module: "Projects", submodule: "Overview", group: "Widgets", label: "View project budget" },
  { key: "projects.overview.extension", module: "Projects", submodule: "Overview", group: "Actions", label: "Request extension" },
  { key: "projects.overview.edit_pm", module: "Projects", submodule: "Overview", group: "Actions", label: "Change project manager" },
  { key: "projects.overview.edit_tl", module: "Projects", submodule: "Overview", group: "Actions", label: "Change team lead" },
  { key: "projects.overview.edit_spm", module: "Projects", submodule: "Overview", group: "Actions", label: "Change senior project manager" },
  { key: "projects.overview.view_spm", module: "Projects", submodule: "Overview", group: "Widgets", label: "View senior project manager" },

  // Projects -> WBS Tab
  { key: "projects.tab.wbs", module: "Projects", submodule: "WBS", group: "Tabs", label: "WBS tab" },
  { key: "projects.wbs.view", module: "Projects", submodule: "WBS", group: "Access", label: "View WBS breakdown" },
  { key: "projects.wbs.pmo_intake", module: "Projects", submodule: "WBS", group: "Widgets", label: "PMO intake & prerequisite workflow" },
  { key: "projects.wbs.services", module: "Projects", submodule: "WBS", group: "Widgets", label: "Services & deliverables" },
  { key: "projects.wbs.amount", module: "Projects", submodule: "WBS", group: "Widgets", label: "View WBS amounts" },
  { key: "projects.wbs.project_allocation", module: "Projects", submodule: "WBS", group: "Actions", label: "Project resource allocation" },
  { key: "projects.wbs.service_prereq", module: "Projects", submodule: "WBS", group: "Widgets", label: "Service-wise prerequisite tracking" },

  // Projects -> Team Tab
  { key: "projects.tab.team", module: "Projects", submodule: "Team", group: "Tabs", label: "Team tab" },
  { key: "projects.team.view", module: "Projects", submodule: "Team", group: "Access", label: "View team members" },
  { key: "projects.team.edit", module: "Projects", submodule: "Team", group: "Actions", label: "Edit team allocation" },
  { key: "projects.team.assign", module: "Projects", submodule: "Team", group: "Actions", label: "Assign team members" },

  // Projects -> Tasks Tab
  { key: "projects.tab.tasks", module: "Projects", submodule: "Tasks", group: "Tabs", label: "Tasks tab" },
  { key: "projects.task.view", module: "Projects", submodule: "Tasks", group: "Access", label: "View tasks" },
  { key: "projects.task.create", module: "Projects", submodule: "Tasks", group: "Actions", label: "Create task" },
  { key: "projects.tasks.edit", module: "Projects", submodule: "Tasks", group: "Actions", label: "Edit tasks" },
  { key: "projects.task.assign", module: "Projects", submodule: "Tasks", group: "Actions", label: "Assign task" },
  { key: "projects.task.update-status", module: "Projects", submodule: "Tasks", group: "Actions", label: "Update task status" },

  // Projects -> Health Tab
  { key: "projects.tab.health", module: "Projects", submodule: "Health", group: "Tabs", label: "Health tab" },
  { key: "projects.health.view", module: "Projects", submodule: "Health", group: "Access", label: "View project health" },
  { key: "projects.health.issues", module: "Projects", submodule: "Health", group: "Widgets", label: "Issues list widget" },
  { key: "projects.health.raise-issue", module: "Projects", submodule: "Health", group: "Actions", label: "Raise issue" },
  { key: "projects.health.edit-issue", module: "Projects", submodule: "Health", group: "Actions", label: "Edit issue details" },
  { key: "projects.health.resolve-issue", module: "Projects", submodule: "Health", group: "Actions", label: "Resolve issue" },
  { key: "projects.health.alerts", module: "Projects", submodule: "Health", group: "Widgets", label: "Alerts widget" },
  { key: "projects.health.appreciation", module: "Projects", submodule: "Health", group: "Widgets", label: "Appreciation widget" },
  { key: "projects.health.customer_engagement", module: "Projects", submodule: "Health", group: "Widgets", label: "Customer engagement logs" },

  // Projects -> Invoices Tab
  { key: "projects.tab.invoices", module: "Projects", submodule: "Invoices", group: "Tabs", label: "Invoices tab" },
  { key: "projects.invoices.view", module: "Projects", submodule: "Invoices", group: "Access", label: "View invoices" },
  { key: "projects.invoices.edit", module: "Projects", submodule: "Invoices", group: "Actions", label: "Create / edit invoices" },
  { key: "projects.invoices.amount", module: "Projects", submodule: "Invoices", group: "Widgets", label: "View invoice amounts" },
  { key: "projects.invoices.limited", module: "Projects", submodule: "Invoices", group: "Widgets", label: "Limited invoice columns (no amounts)" },

  // ─── Reports ──────────────────────────────────────────────────────────────
  { key: "reports.view", module: "Reports", submodule: "Overview", group: "Access", label: "View reports module" },
  { key: "reports.sales", module: "Reports", submodule: "Sales", group: "Tabs", label: "Sales reports" },
  { key: "reports.wbs_tracker", module: "Reports", submodule: "WBS Tracker", group: "Tabs", label: "WBS tracker" },
  { key: "reports.po_tracker", module: "Reports", submodule: "PO Tracker", group: "Tabs", label: "PO tracker" },
  { key: "reports.invoice_tracker", module: "Reports", submodule: "Invoice Tracker", group: "Tabs", label: "Invoice tracker" },
  { key: "reports.finance", module: "Reports", submodule: "Finance", group: "Tabs", label: "Financial analytics reports" },
  { key: "reports.export", module: "Reports", submodule: "Overview", group: "Actions", label: "Export reports" },

  // ─── Resources ────────────────────────────────────────────────────────────
  { key: "resources.view", module: "Resources", submodule: "Directory", group: "Access", label: "View directory" },
  { key: "resources.directory.view", module: "Resources", submodule: "Directory", group: "Access", label: "Directory view" },
  { key: "resources.add_employee", module: "Resources", submodule: "Directory", group: "Actions", label: "Add / onboard employee" },
  { key: "resources.directory.add-employee", module: "Resources", submodule: "Directory", group: "Actions", label: "Add employee action" },
  { key: "resources.columns.full", module: "Resources", submodule: "Directory", group: "Widgets", label: "Full directory columns (sensitive)" },
  { key: "resources.pool", module: "Resources", submodule: "Resource Pool", group: "Access", label: "Resource pool" },
  { key: "resources.pool.view", module: "Resources", submodule: "Resource Pool", group: "Access", label: "View resource pool" },
  { key: "resources.exit_summary", module: "Resources", submodule: "Exit Summary", group: "Access", label: "Exit summary" },
  { key: "resources.exit-summary.view", module: "Resources", submodule: "Exit Summary", group: "Access", label: "View exit directory" },

  // Resources Profile Submodule
  { key: "resources.profile.org", module: "Resources", submodule: "Profile", group: "Tabs", label: "Organization details tab" },
  { key: "resources.profile.employment", module: "Resources", submodule: "Profile", group: "Tabs", label: "Employment details tab" },
  { key: "resources.profile.skills", module: "Resources", submodule: "Profile", group: "Tabs", label: "Skills & qualifications tab" },
  { key: "resources.profile.kpi", module: "Resources", submodule: "Profile", group: "Tabs", label: "KPI & performance tab" },
  { key: "resources.profile.finance", module: "Resources", submodule: "Profile", group: "Tabs", label: "Financial & compliance tab" },
  { key: "resources.profile.edit", module: "Resources", submodule: "Profile", group: "Actions", label: "Edit employee profile" },
  { key: "resources.profile.report", module: "Resources", submodule: "Profile", group: "Actions", label: "Generate employee report" },
  { key: "resources.profile.offboard", module: "Resources", submodule: "Profile", group: "Actions", label: "Offboard employee" },

  // ─── Customers ────────────────────────────────────────────────────────────
  { key: "customers.view", module: "Customers", submodule: "Accounts", group: "Access", label: "View customers" },
  { key: "customers.create", module: "Customers", submodule: "Accounts", group: "Actions", label: "Add customer" },
  { key: "customers.edit", module: "Customers", submodule: "Accounts", group: "Actions", label: "Edit customer details" },
  { key: "customers.delete", module: "Customers", submodule: "Accounts", group: "Actions", label: "Delete customer" },
  { key: "customers.approve", module: "Customers", submodule: "Accounts", group: "Actions", label: "Approve customer" },
  { key: "customers.change_em", module: "Customers", submodule: "Accounts", group: "Actions", label: "Change engagement manager" },
  { key: "customers.assign", module: "Customers", submodule: "Accounts", group: "Actions", label: "Assign customers" },

  // ─── Repository ───────────────────────────────────────────────────────────
  { key: "repository.view", module: "Repository", submodule: "Documents", group: "Access", label: "View repository" },
  { key: "repository.download", module: "Repository", submodule: "Documents", group: "Actions", label: "Download documents" },
  { key: "repository.upload", module: "Repository", submodule: "Documents", group: "Actions", label: "Upload documents" },
  { key: "repository.delete", module: "Repository", submodule: "Documents", group: "Actions", label: "Delete documents" },
  { key: "repository.logs", module: "Repository", submodule: "Documents", group: "Actions", label: "View repository activity log" },

  // ─── My Team / Timesheet ──────────────────────────────────────────────────
  { key: "my-team.dashboard.view", module: "My Team", submodule: "Team Dashboard", group: "Access", label: "Team dashboard" },
  { key: "my_team.dashboard", module: "My Team", submodule: "Team Dashboard", group: "Access", label: "View team dashboard" },
  { key: "timesheet.my", module: "My Team", submodule: "My Timesheet", group: "Tabs", label: "My timesheet" },
  { key: "my-team.my-timesheet.view", module: "My Team", submodule: "My Timesheet", group: "Tabs", label: "View my timesheet" },
  { key: "my-team.my-timesheet.submit", module: "My Team", submodule: "My Timesheet", group: "Actions", label: "Submit weekly timesheet" },
  { key: "my-team.my-timesheet.edit", module: "My Team", submodule: "My Timesheet", group: "Actions", label: "Edit timesheet entries" },
  { key: "timesheet.approve", module: "My Team", submodule: "Approval Queue", group: "Tabs", label: "Timesheet approval" },
  { key: "my-team.timesheet-approval.view", module: "My Team", submodule: "Approval Queue", group: "Tabs", label: "View timesheet approval queue" },
  { key: "my-team.timesheet-approval.approve", module: "My Team", submodule: "Approval Queue", group: "Actions", label: "Approve timesheet" },
  { key: "my-team.timesheet-approval.reject", module: "My Team", submodule: "Approval Queue", group: "Actions", label: "Reject timesheet" },

  // ─── Settings ─────────────────────────────────────────────────────────────
  { key: "settings.view", module: "Settings", submodule: "Settings Hub", group: "Access", label: "View settings hub" },
  { key: "settings.roles.view", module: "Settings", submodule: "Roles & Permissions", group: "Tabs", label: "Module access matrix tab" },
  { key: "settings.manage_roles", module: "Settings", submodule: "Roles & Permissions", group: "Tabs", label: "Manage roles & permissions" },
  { key: "settings.roles.users.view", module: "Settings", submodule: "Roles & Permissions", group: "Tabs", label: "User role access tab" },
  { key: "settings.roles.manage", module: "Settings", submodule: "Roles & Permissions", group: "Actions", label: "Edit role permissions" },
  { key: "settings.users.assign", module: "Settings", submodule: "Roles & Permissions", group: "Actions", label: "Assign user roles" },
  { key: "settings.roles.reset", module: "Settings", submodule: "Roles & Permissions", group: "Actions", label: "Reset to baseline permissions" },
  { key: "settings.audit.view", module: "Settings", submodule: "Audit & Logs", group: "Tabs", label: "View security audit log" },
  { key: "settings.audit.export", module: "Settings", submodule: "Audit & Logs", group: "Actions", label: "Export audit history" },
];

export type PermissionKey = string;

export const MODULE_ORDER = [
  "Dashboard",
  "Action Centre",
  "Projects",
  "Reports",
  "Resources",
  "Customers",
  "Repository",
  "My Team",
  "Settings",
] as const;

export type ProjectScope = "involved" | "pm" | "assigned" | "department" | "all";

export const ROLE_PROJECT_SCOPE: Record<Role, ProjectScope> = {
  employee: "involved",
  pm: "pm",
  senior_pm: "assigned",
  engagement_manager: "assigned",
  pmo: "all",
  business_owner: "all",
  hod: "department",
  hr: "all",
  accounts_finance: "all",
  sales_bd: "all",
  dhanshree: "all",
};

/** Normalizes permission aliases so legacy and dot-notation keys both match. */
export const PERMISSION_ALIASES: Record<string, string[]> = {
  "dashboard.view": ["dashboard.view"],
  "action-center.view": ["action-center.view"],
  "action.bucket_list": ["action.bucket_list", "action-center.bucket-list.view"],
  "action-center.bucket-list.view": ["action.bucket_list", "action-center.bucket-list.view"],
  "action.bucket_timer": ["action.bucket_timer", "action-center.bucket-list.timer"],
  "action-center.bucket-list.timer": ["action.bucket_timer", "action-center.bucket-list.timer"],
  "action.approvals": ["action.approvals", "action-center.approvals.view"],
  "action-center.approvals.view": ["action.approvals", "action-center.approvals.view"],
  "action.acknowledge": ["action.acknowledge", "action-center.approvals.act"],
  "action-center.approvals.act": ["action.acknowledge", "action-center.approvals.act"],
  "action.alerts": ["action.alerts", "action-center.alerts.view"],
  "action-center.alerts.view": ["action.alerts", "action-center.alerts.view"],
  "action.notifications": ["action.notifications", "action-center.notifications.view"],
  "action-center.notifications.view": ["action.notifications", "action-center.notifications.view"],
  "projects.view": ["projects.view", "projects:read"],
  "projects.create": ["projects.create", "projects:write"],
  "projects.tab.overview": ["projects.tab.overview", "projects.overview.view"],
  "projects.overview.view": ["projects.tab.overview", "projects.overview.view"],
  "projects.tab.wbs": ["projects.tab.wbs", "projects.wbs.view"],
  "projects.wbs.view": ["projects.tab.wbs", "projects.wbs.view"],
  "projects.tab.team": ["projects.tab.team", "projects.team.view"],
  "projects.team.view": ["projects.tab.team", "projects.team.view"],
  "projects.tab.tasks": ["projects.tab.tasks", "projects.task.view"],
  "projects.task.view": ["projects.tab.tasks", "projects.task.view"],
  "projects.tab.health": ["projects.tab.health", "projects.health.view"],
  "projects.health.view": ["projects.tab.health", "projects.health.view"],
  "projects.tab.invoices": ["projects.tab.invoices", "projects.invoices.view"],
  "projects.invoices.view": ["projects.tab.invoices", "projects.invoices.view"],
  "resources.view": ["resources.view", "resources:read", "resources.directory.view"],
  "resources.directory.view": ["resources.view", "resources:read", "resources.directory.view"],
  "resources.add_employee": ["resources.add_employee", "resources.directory.add-employee", "resources:manage"],
  "resources.directory.add-employee": ["resources.add_employee", "resources.directory.add-employee", "resources:manage"],
  "resources.pool": ["resources.pool", "resources.pool.view"],
  "resources.pool.view": ["resources.pool", "resources.pool.view"],
  "resources.exit_summary": ["resources.exit_summary", "resources.exit-summary.view"],
  "resources.exit-summary.view": ["resources.exit_summary", "resources.exit-summary.view"],
  "customers.view": ["customers.view", "clients:read"],
  "customers.create": ["customers.create", "clients:write"],
  "customers.edit": ["customers.edit", "clients:write"],
  "customers.approve": ["customers.approve", "clients:approve"],
  "repository.view": ["repository.view"],
  "timesheet.my": ["timesheet.my", "my-team.my-timesheet.view"],
  "my-team.my-timesheet.view": ["timesheet.my", "my-team.my-timesheet.view"],
  "timesheet.approve": ["timesheet.approve", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "timesheets:approve"],
  "my-team.timesheet-approval.view": ["timesheet.approve", "my-team.timesheet-approval.view"],
  "my-team.timesheet-approval.approve": ["timesheet.approve", "my-team.timesheet-approval.approve", "timesheets:approve"],
  "my_team.dashboard": ["my_team.dashboard", "my-team.dashboard.view"],
  "my-team.dashboard.view": ["my_team.dashboard", "my-team.dashboard.view"],
  "wbs.allocate": ["wbs.allocate", "wbs:allocate"],
  "wbs.view": ["wbs.view", "wbs:read"],
  "approvals.view": ["approvals.view"],
  "settings.view": ["settings.view"],
  "settings.roles.view": ["settings.roles.view", "settings.manage_roles", "settings.roles.manage", "roles:manage"],
  "settings.manage_roles": ["settings.manage_roles", "settings.roles.manage", "settings.roles.view", "roles:manage", "users:manage"],
  "settings.roles.manage": ["settings.manage_roles", "settings.roles.manage", "settings.roles.view", "roles:manage", "users:manage"],
  "settings.roles.users.view": ["settings.roles.users.view", "settings.manage_roles", "users:manage"],
  "settings.users.assign": ["settings.users.assign", "settings.manage_roles", "users:manage"],
  "settings.roles.reset": ["settings.roles.reset", "settings.manage_roles", "settings.roles.manage"],
  "settings.audit.view": ["settings.audit.view", "audit:read"],
  "settings.audit.export": ["settings.audit.export", "settings.audit.view", "audit:read"],
};
