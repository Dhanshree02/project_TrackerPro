import type { Role } from "@/lib/mock-data";

/** Login roles used across Settings and the app. Admin is the super-user (current Dhanshree workspace). */
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

export const PERMISSION_CATALOG = [
  // Dashboard
  { key: "dashboard.view", module: "Dashboard", group: "Access", label: "View dashboard" },

  // Action Centre
  { key: "action.bucket_list", module: "Action Centre", group: "Tabs", label: "Bucket list" },
  { key: "action.bucket_timer", module: "Action Centre", group: "Actions", label: "Start / pause task timer" },
  { key: "action.approvals", module: "Action Centre", group: "Tabs", label: "Approvals tab" },
  { key: "action.alerts", module: "Action Centre", group: "Tabs", label: "Alerts tab" },
  { key: "action.notifications", module: "Action Centre", group: "Tabs", label: "Notifications tab" },
  { key: "action.acknowledge", module: "Action Centre", group: "Actions", label: "Approve / acknowledge" },

  // Projects
  { key: "projects.view", module: "Projects", group: "Access", label: "View projects" },
  { key: "projects.create", module: "Projects", group: "Actions", label: "Create new project" },
  { key: "projects.drafts", module: "Projects", group: "Actions", label: "View drafts" },
  { key: "projects.stage_tracker", module: "Projects", group: "Detail", label: "Stage tracker" },
  { key: "projects.tab.overview", module: "Projects", group: "Tabs", label: "Overview tab" },
  { key: "projects.tab.wbs", module: "Projects", group: "Tabs", label: "WBS tab" },
  { key: "projects.tab.team", module: "Projects", group: "Tabs", label: "Team tab" },
  { key: "projects.tab.tasks", module: "Projects", group: "Tabs", label: "Tasks tab" },
  { key: "projects.tab.health", module: "Projects", group: "Tabs", label: "Health tab" },
  { key: "projects.tab.invoices", module: "Projects", group: "Tabs", label: "Invoices tab" },
  { key: "projects.overview.budget", module: "Projects", group: "Overview", label: "View budget / amounts" },
  { key: "projects.overview.extension", module: "Projects", group: "Overview", label: "Extension request" },
  { key: "projects.overview.edit_pm", module: "Projects", group: "Overview", label: "Change project manager" },
  { key: "projects.overview.edit_tl", module: "Projects", group: "Overview", label: "Change team lead" },
  { key: "projects.overview.edit_spm", module: "Projects", group: "Overview", label: "Change senior project manager" },
  { key: "projects.overview.view_spm", module: "Projects", group: "Overview", label: "View senior project manager" },
  { key: "projects.wbs.pmo_intake", module: "Projects", group: "WBS", label: "PMO intake & prerequisite workflow" },
  { key: "projects.wbs.services", module: "Projects", group: "WBS", label: "Services & deliverables" },
  { key: "projects.wbs.amount", module: "Projects", group: "WBS", label: "View WBS amounts" },
  { key: "projects.wbs.project_allocation", module: "Projects", group: "WBS", label: "Project allocation" },
  { key: "projects.wbs.service_prereq", module: "Projects", group: "WBS", label: "Service-wise prerequisite tracking" },
  { key: "projects.team.edit", module: "Projects", group: "Team", label: "Edit team" },
  { key: "projects.tasks.edit", module: "Projects", group: "Tasks", label: "Edit tasks" },
  { key: "projects.health.issues", module: "Projects", group: "Health", label: "Issues" },
  { key: "projects.health.alerts", module: "Projects", group: "Health", label: "Alerts" },
  { key: "projects.health.appreciation", module: "Projects", group: "Health", label: "Appreciation" },
  { key: "projects.health.customer_engagement", module: "Projects", group: "Health", label: "Customer engagement" },
  { key: "projects.invoices.edit", module: "Projects", group: "Invoices", label: "Edit invoices" },
  { key: "projects.invoices.amount", module: "Projects", group: "Invoices", label: "View invoice amounts" },
  { key: "projects.invoices.limited", module: "Projects", group: "Invoices", label: "Limited invoice columns (no amounts)" },

  // Reports
  { key: "reports.sales", module: "Reports", group: "Tabs", label: "Sales reports" },
  { key: "reports.wbs_tracker", module: "Reports", group: "Tabs", label: "WBS tracker" },
  { key: "reports.po_tracker", module: "Reports", group: "Tabs", label: "PO tracker" },
  { key: "reports.invoice_tracker", module: "Reports", group: "Tabs", label: "Invoice tracker" },

  // Resources
  { key: "resources.view", module: "Resources", group: "Access", label: "View directory" },
  { key: "resources.pool", module: "Resources", group: "Access", label: "Resource pool" },
  { key: "resources.add_employee", module: "Resources", group: "Actions", label: "Add employee" },
  { key: "resources.columns.full", module: "Resources", group: "Directory", label: "Full directory columns" },
  { key: "resources.profile.org", module: "Resources", group: "Profile", label: "Organization details tab" },
  { key: "resources.profile.employment", module: "Resources", group: "Profile", label: "Employment details tab" },
  { key: "resources.profile.skills", module: "Resources", group: "Profile", label: "Skills & qualifications tab" },
  { key: "resources.profile.kpi", module: "Resources", group: "Profile", label: "KPI & performance tab" },
  { key: "resources.profile.finance", module: "Resources", group: "Profile", label: "Financial & compliance tab" },
  { key: "resources.profile.edit", module: "Resources", group: "Profile", label: "Edit profile" },
  { key: "resources.profile.report", module: "Resources", group: "Profile", label: "Generate report" },
  { key: "resources.profile.offboard", module: "Resources", group: "Profile", label: "Offboard employee" },
  { key: "resources.exit_summary", module: "Resources", group: "Access", label: "Exit summary" },

  // Customers
  { key: "customers.view", module: "Customers", group: "Access", label: "View customers" },
  { key: "customers.create", module: "Customers", group: "Actions", label: "Add customer" },
  { key: "customers.change_em", module: "Customers", group: "Actions", label: "Change engagement manager" },

  // Repository
  { key: "repository.view", module: "Repository", group: "Access", label: "View repository" },
  { key: "repository.download", module: "Repository", group: "Actions", label: "Download documents" },
  { key: "repository.upload", module: "Repository", group: "Actions", label: "Upload document" },
  { key: "repository.delete", module: "Repository", group: "Actions", label: "Delete document" },
  { key: "repository.logs", module: "Repository", group: "Actions", label: "View activity log" },

  // My Team / Timesheet
  { key: "timesheet.my", module: "Timesheet", group: "Access", label: "My timesheet" },
  { key: "timesheet.approve", module: "Timesheet", group: "Access", label: "Timesheet approval" },
  { key: "my_team.dashboard", module: "My Team", group: "Access", label: "Team dashboard" },

  // Settings
  { key: "settings.view", module: "Settings", group: "Access", label: "View settings" },
  { key: "settings.manage_roles", module: "Settings", group: "Access", label: "Manage roles & permissions" },
] as const;

export type PermissionKey = (typeof PERMISSION_CATALOG)[number]["key"];

export const MODULE_ORDER = [
  "Dashboard",
  "Action Centre",
  "Projects",
  "Reports",
  "Resources",
  "Customers",
  "Repository",
  "Timesheet",
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
