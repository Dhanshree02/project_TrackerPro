// AUTO-GENERATED FROM 'TK I PMS I New Modules RBAC I V01.xlsx'
// Canonical RBAC Baseline Permissions Matrix for All 28 Roles and 49 Granular Widgets

export interface WidgetPermissionValue {
  canView: 0 | 1;
  canManage: 0 | 1;
}

export interface WidgetCatalogItem {
  key: string;
  code: string;
  name: string;
  moduleCode: string;
  moduleName: string;
  submoduleCode: string | null;
  submoduleName: string | null;
  widgetType: "widget" | "action" | "tab" | "kpi_card";
  hasManageAction: boolean;
  sortOrder: number;
}

export const RBAC_WIDGET_CATALOG: WidgetCatalogItem[] = [
  {
    "key": "dashboard.kpis",
    "code": "kpis",
    "name": "KPI Summary Cards",
    "moduleCode": "dashboard",
    "moduleName": "Dashboard",
    "submoduleCode": null,
    "submoduleName": null,
    "widgetType": "kpi_card",
    "hasManageAction": false,
    "sortOrder": 1
  },
  {
    "key": "dashboard.assigned_projects",
    "code": "assigned_projects",
    "name": "Assigned Projects",
    "moduleCode": "dashboard",
    "moduleName": "Dashboard",
    "submoduleCode": null,
    "submoduleName": null,
    "widgetType": "widget",
    "hasManageAction": false,
    "sortOrder": 2
  },
  {
    "key": "dashboard.pending_issues",
    "code": "pending_issues",
    "name": "Pending Issues",
    "moduleCode": "dashboard",
    "moduleName": "Dashboard",
    "submoduleCode": null,
    "submoduleName": null,
    "widgetType": "widget",
    "hasManageAction": false,
    "sortOrder": 3
  },
  {
    "key": "dashboard.project_status",
    "code": "project_status",
    "name": "Project Status Summary",
    "moduleCode": "dashboard",
    "moduleName": "Dashboard",
    "submoduleCode": null,
    "submoduleName": null,
    "widgetType": "widget",
    "hasManageAction": false,
    "sortOrder": 4
  },
  {
    "key": "dashboard.pending_approvals",
    "code": "pending_approvals",
    "name": "Pending Approvals",
    "moduleCode": "dashboard",
    "moduleName": "Dashboard",
    "submoduleCode": null,
    "submoduleName": null,
    "widgetType": "widget",
    "hasManageAction": false,
    "sortOrder": 5
  },
  {
    "key": "action_center.bucket_list.raise_issues",
    "code": "raise_issues",
    "name": "Raise Issues Action",
    "moduleCode": "action_center",
    "moduleName": "Action Center",
    "submoduleCode": "bucket_list",
    "submoduleName": "Bucket List",
    "widgetType": "action",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "action_center.bucket_list.start_timer",
    "code": "start_timer",
    "name": "Start / Pause Task Timer",
    "moduleCode": "action_center",
    "moduleName": "Action Center",
    "submoduleCode": "bucket_list",
    "submoduleName": "Bucket List",
    "widgetType": "action",
    "hasManageAction": true,
    "sortOrder": 2
  },
  {
    "key": "action_center.approvals",
    "code": "approvals",
    "name": "Approvals Tab",
    "moduleCode": "action_center",
    "moduleName": "Action Center",
    "submoduleCode": "approvals",
    "submoduleName": "Approvals",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "action_center.alerts",
    "code": "alerts",
    "name": "Alerts Tab",
    "moduleCode": "action_center",
    "moduleName": "Action Center",
    "submoduleCode": "alerts",
    "submoduleName": "Alerts",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "action_center.notifications",
    "code": "notifications",
    "name": "Notifications Tab",
    "moduleCode": "action_center",
    "moduleName": "Action Center",
    "submoduleCode": "notifications",
    "submoduleName": "Notifications",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "projects.overview.budget",
    "code": "budget",
    "name": "Budget & Financials",
    "moduleCode": "projects",
    "moduleName": "Projects",
    "submoduleCode": "overview",
    "submoduleName": "Overview",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "projects.overview.extension_request",
    "code": "extension_request",
    "name": "Extension Request",
    "moduleCode": "projects",
    "moduleName": "Projects",
    "submoduleCode": "overview",
    "submoduleName": "Overview",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 2
  },
  {
    "key": "projects.overview.assign_spm",
    "code": "assign_spm",
    "name": "Assign Senior Project Manager",
    "moduleCode": "projects",
    "moduleName": "Projects",
    "submoduleCode": "overview",
    "submoduleName": "Overview",
    "widgetType": "action",
    "hasManageAction": true,
    "sortOrder": 3
  },
  {
    "key": "projects.overview.assign_pm",
    "code": "assign_pm",
    "name": "Assign Project Manager",
    "moduleCode": "projects",
    "moduleName": "Projects",
    "submoduleCode": "overview",
    "submoduleName": "Overview",
    "widgetType": "action",
    "hasManageAction": true,
    "sortOrder": 4
  },
  {
    "key": "projects.overview.assign_tl",
    "code": "assign_tl",
    "name": "Assign Team Lead",
    "moduleCode": "projects",
    "moduleName": "Projects",
    "submoduleCode": "overview",
    "submoduleName": "Overview",
    "widgetType": "action",
    "hasManageAction": true,
    "sortOrder": 5
  },
  {
    "key": "projects.wbs.billing_info",
    "code": "billing_info",
    "name": "Billing Information",
    "moduleCode": "projects",
    "moduleName": "Projects",
    "submoduleCode": "wbs",
    "submoduleName": "WBS",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "projects.wbs.pmo_intake",
    "code": "pmo_intake",
    "name": "PMO Intake & Prerequisite Workflow",
    "moduleCode": "projects",
    "moduleName": "Projects",
    "submoduleCode": "wbs",
    "submoduleName": "WBS",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 2
  },
  {
    "key": "projects.wbs.invoice_schedule",
    "code": "invoice_schedule",
    "name": "Invoice Schedule",
    "moduleCode": "projects",
    "moduleName": "Projects",
    "submoduleCode": "wbs",
    "submoduleName": "WBS",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 3
  },
  {
    "key": "projects.team.allocation",
    "code": "team_allocation",
    "name": "Team Allocation Grid",
    "moduleCode": "projects",
    "moduleName": "Projects",
    "submoduleCode": "team",
    "submoduleName": "Team",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "projects.task.management",
    "code": "task_management",
    "name": "Task Management Grid",
    "moduleCode": "projects",
    "moduleName": "Projects",
    "submoduleCode": "task",
    "submoduleName": "Task",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "projects.health.issues",
    "code": "issues",
    "name": "Issue Tracker",
    "moduleCode": "projects",
    "moduleName": "Projects",
    "submoduleCode": "health",
    "submoduleName": "Health & Governance",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "projects.health.alerts",
    "code": "alerts",
    "name": "Alerts Feed",
    "moduleCode": "projects",
    "moduleName": "Projects",
    "submoduleCode": "health",
    "submoduleName": "Health & Governance",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 2
  },
  {
    "key": "projects.health.escalation",
    "code": "escalation",
    "name": "Escalation Matrix",
    "moduleCode": "projects",
    "moduleName": "Projects",
    "submoduleCode": "health",
    "submoduleName": "Health & Governance",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 3
  },
  {
    "key": "projects.health.appreciation",
    "code": "appreciation",
    "name": "Appreciation Feed",
    "moduleCode": "projects",
    "moduleName": "Projects",
    "submoduleCode": "health",
    "submoduleName": "Health & Governance",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 4
  },
  {
    "key": "projects.health.engagement.interview",
    "code": "engagement_interview",
    "name": "Interview Scheduling",
    "moduleCode": "projects",
    "moduleName": "Projects",
    "submoduleCode": "health",
    "submoduleName": "Health & Governance",
    "widgetType": "tab",
    "hasManageAction": true,
    "sortOrder": 5
  },
  {
    "key": "projects.health.engagement.requirements",
    "code": "engagement_requirements",
    "name": "Additional Customer Requirement",
    "moduleCode": "projects",
    "moduleName": "Projects",
    "submoduleCode": "health",
    "submoduleName": "Health & Governance",
    "widgetType": "tab",
    "hasManageAction": true,
    "sortOrder": 6
  },
  {
    "key": "projects.invoice.management",
    "code": "invoice_management",
    "name": "Invoicing Grid",
    "moduleCode": "projects",
    "moduleName": "Projects",
    "submoduleCode": "invoice",
    "submoduleName": "Invoice",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "reports.sales",
    "code": "sales",
    "name": "Sales Report",
    "moduleCode": "reports",
    "moduleName": "Reports",
    "submoduleCode": "sales_report",
    "submoduleName": "Sales Report",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "reports.wbs_tracker",
    "code": "wbs_tracker",
    "name": "WBS Tracker",
    "moduleCode": "reports",
    "moduleName": "Reports",
    "submoduleCode": "wbs_tracker",
    "submoduleName": "WBS Tracker",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "reports.po_tracker",
    "code": "po_tracker",
    "name": "PO Tracker",
    "moduleCode": "reports",
    "moduleName": "Reports",
    "submoduleCode": "po_tracker",
    "submoduleName": "PO Tracker",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "reports.invoice_tracker",
    "code": "invoice_tracker",
    "name": "Invoice Tracker",
    "moduleCode": "reports",
    "moduleName": "Reports",
    "submoduleCode": "invoice_tracker",
    "submoduleName": "Invoice Tracker",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "resources.directory.personal_info",
    "code": "personal_info",
    "name": "Personal Information",
    "moduleCode": "resources",
    "moduleName": "Resources",
    "submoduleCode": "resource_details",
    "submoduleName": "Resource Details",
    "widgetType": "tab",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "resources.directory.org_details",
    "code": "org_details",
    "name": "Organization Details",
    "moduleCode": "resources",
    "moduleName": "Resources",
    "submoduleCode": "resource_details",
    "submoduleName": "Resource Details",
    "widgetType": "tab",
    "hasManageAction": true,
    "sortOrder": 2
  },
  {
    "key": "resources.directory.employment_bond",
    "code": "employment_bond",
    "name": "Employment & Bond",
    "moduleCode": "resources",
    "moduleName": "Resources",
    "submoduleCode": "resource_details",
    "submoduleName": "Resource Details",
    "widgetType": "tab",
    "hasManageAction": true,
    "sortOrder": 3
  },
  {
    "key": "resources.directory.education_exp",
    "code": "education_exp",
    "name": "Education & Experience",
    "moduleCode": "resources",
    "moduleName": "Resources",
    "submoduleCode": "resource_details",
    "submoduleName": "Resource Details",
    "widgetType": "tab",
    "hasManageAction": true,
    "sortOrder": 4
  },
  {
    "key": "resources.directory.pmo_info",
    "code": "pmo_info",
    "name": "PMO Information",
    "moduleCode": "resources",
    "moduleName": "Resources",
    "submoduleCode": "resource_details",
    "submoduleName": "Resource Details",
    "widgetType": "tab",
    "hasManageAction": true,
    "sortOrder": 5
  },
  {
    "key": "resources.directory.activity_logs",
    "code": "activity_logs",
    "name": "Activity Logs",
    "moduleCode": "resources",
    "moduleName": "Resources",
    "submoduleCode": "resource_details",
    "submoduleName": "Resource Details",
    "widgetType": "tab",
    "hasManageAction": false,
    "sortOrder": 6
  },
  {
    "key": "resources.resource_pool",
    "code": "resource_pool",
    "name": "Resource Pool Grid",
    "moduleCode": "resources",
    "moduleName": "Resources",
    "submoduleCode": "resource_pool",
    "submoduleName": "Resource Pool",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "resources.exit_summary",
    "code": "exit_summary",
    "name": "Exit Summary Logs",
    "moduleCode": "resources",
    "moduleName": "Resources",
    "submoduleCode": "exit_summary",
    "submoduleName": "Exit Summary",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "customers.customer_profile",
    "code": "customer_profile",
    "name": "Customer Profiles",
    "moduleCode": "customers",
    "moduleName": "Customers",
    "submoduleCode": "customer_profile",
    "submoduleName": "Customer Profile",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "repository.documents",
    "code": "documents",
    "name": "Document Repository",
    "moduleCode": "repository",
    "moduleName": "Repository",
    "submoduleCode": null,
    "submoduleName": null,
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "my_team.dashboard",
    "code": "team_dashboard",
    "name": "Team Dashboard",
    "moduleCode": "my_team",
    "moduleName": "My Team",
    "submoduleCode": "team_dashboard",
    "submoduleName": "Team Dashboard",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "my_team.my_timesheet",
    "code": "my_timesheet",
    "name": "My Timesheet",
    "moduleCode": "my_team",
    "moduleName": "My Team",
    "submoduleCode": "my_timesheet",
    "submoduleName": "My Timesheet",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "my_team.timesheet_approval",
    "code": "timesheet_approval",
    "name": "Timesheet Approval",
    "moduleCode": "my_team",
    "moduleName": "My Team",
    "submoduleCode": "timesheet_approval",
    "submoduleName": "Timesheet Approval",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "settings.roles.modules_access",
    "code": "modules_access",
    "name": "Moduleswise Access",
    "moduleCode": "settings",
    "moduleName": "Settings",
    "submoduleCode": "moduleswise_access",
    "submoduleName": "Moduleswise Access",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "settings.roles.user_access",
    "code": "user_access",
    "name": "User Role Access",
    "moduleCode": "settings",
    "moduleName": "Settings",
    "submoduleCode": "user_role_access",
    "submoduleName": "User Role Access",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 2
  },
  {
    "key": "settings.masters.project",
    "code": "project_masters",
    "name": "Project Masters Grid",
    "moduleCode": "settings",
    "moduleName": "Settings",
    "submoduleCode": "project_masters",
    "submoduleName": "Project Masters",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 1
  },
  {
    "key": "settings.masters.customer",
    "code": "customer_masters",
    "name": "Customer Masters Grid",
    "moduleCode": "settings",
    "moduleName": "Settings",
    "submoduleCode": "customer_masters",
    "submoduleName": "Customer Masters",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 2
  },
  {
    "key": "settings.masters.resource",
    "code": "resource_masters",
    "name": "Resource Masters Grid",
    "moduleCode": "settings",
    "moduleName": "Settings",
    "submoduleCode": "resource_masters",
    "submoduleName": "Resource Masters",
    "widgetType": "widget",
    "hasManageAction": true,
    "sortOrder": 3
  }
];

export const EXCEL_BASELINE_PERMISSIONS: Record<string, Record<string, WidgetPermissionValue>> = {
  "CEO": {
    "dashboard.kpis": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.bucket_list.start_timer": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.budget": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 1,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.task.management": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.issues": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.alerts": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.escalation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.appreciation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.interview": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 1,
      "canManage": 0
    },
    "projects.invoice.management": {
      "canView": 1,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 1,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 1,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 1,
      "canManage": 0
    },
    "resources.exit_summary": {
      "canView": 1,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 1,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 0
    },
    "settings.roles.modules_access": {
      "canView": 1,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 1,
      "canManage": 0
    }
  },
  "COO": {
    "dashboard.kpis": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.bucket_list.start_timer": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.budget": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 1,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.task.management": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.issues": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.alerts": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.escalation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.appreciation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.interview": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 1,
      "canManage": 0
    },
    "projects.invoice.management": {
      "canView": 1,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 1,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 1,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 1,
      "canManage": 0
    },
    "resources.exit_summary": {
      "canView": 1,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 1,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 0
    },
    "settings.roles.modules_access": {
      "canView": 1,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 1,
      "canManage": 0
    }
  },
  "CTO": {
    "dashboard.kpis": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.bucket_list.start_timer": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.budget": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 1,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.task.management": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.issues": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.alerts": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.escalation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.appreciation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.interview": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 1,
      "canManage": 0
    },
    "projects.invoice.management": {
      "canView": 1,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 1,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 1,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 1,
      "canManage": 0
    },
    "resources.exit_summary": {
      "canView": 1,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 1,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 0
    },
    "settings.roles.modules_access": {
      "canView": 1,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 1,
      "canManage": 0
    }
  },
  "IT Admin": {
    "dashboard.kpis": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.approvals": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.task.management": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.issues": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.alerts": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.escalation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.appreciation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.engagement.interview": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 0,
      "canManage": 0
    },
    "projects.invoice.management": {
      "canView": 0,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 0,
      "canManage": 0
    },
    "resources.exit_summary": {
      "canView": 0,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 0,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 0,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 0
    },
    "settings.roles.modules_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 0,
      "canManage": 0
    }
  },
  "Accounts": {
    "dashboard.kpis": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.approvals": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 1,
      "canManage": 1
    },
    "projects.wbs.pmo_intake": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 1,
      "canManage": 1
    },
    "projects.team.allocation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.task.management": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.issues": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.alerts": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.escalation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.appreciation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.engagement.interview": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 0,
      "canManage": 0
    },
    "projects.invoice.management": {
      "canView": 1,
      "canManage": 1
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 0,
      "canManage": 0
    },
    "resources.exit_summary": {
      "canView": 0,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 1,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 0,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 0
    },
    "settings.roles.modules_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 0,
      "canManage": 0
    }
  },
  "HR": {
    "dashboard.kpis": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.bucket_list.start_timer": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.alerts": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.notifications": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.budget": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.task.management": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.issues": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.alerts": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.escalation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.appreciation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.engagement.interview": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 0,
      "canManage": 0
    },
    "projects.invoice.management": {
      "canView": 0,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 1,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 1,
      "canManage": 0
    },
    "resources.exit_summary": {
      "canView": 1,
      "canManage": 1
    },
    "customers.customer_profile": {
      "canView": 0,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 0,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 0,
      "canManage": 0
    },
    "my_team.my_timesheet": {
      "canView": 0,
      "canManage": 0
    },
    "my_team.timesheet_approval": {
      "canView": 0,
      "canManage": 0
    },
    "settings.roles.modules_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 1,
      "canManage": 1
    }
  },
  "Sales Manager": {
    "dashboard.kpis": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.approvals": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.task.management": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.issues": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.alerts": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.escalation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.appreciation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.interview": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 1,
      "canManage": 1
    },
    "projects.invoice.management": {
      "canView": 1,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 1,
      "canManage": 1
    },
    "reports.wbs_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 0,
      "canManage": 0
    },
    "resources.exit_summary": {
      "canView": 0,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 1,
      "canManage": 1
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 0,
      "canManage": 0
    },
    "my_team.my_timesheet": {
      "canView": 0,
      "canManage": 0
    },
    "my_team.timesheet_approval": {
      "canView": 0,
      "canManage": 0
    },
    "settings.roles.modules_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 0,
      "canManage": 0
    }
  },
  "Sales team member": {
    "dashboard.kpis": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.approvals": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.budget": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.task.management": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.issues": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.alerts": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.escalation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.appreciation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.interview": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 1,
      "canManage": 0
    },
    "projects.invoice.management": {
      "canView": 1,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 1,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 0,
      "canManage": 0
    },
    "resources.exit_summary": {
      "canView": 0,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 1,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 0,
      "canManage": 0
    },
    "my_team.my_timesheet": {
      "canView": 0,
      "canManage": 0
    },
    "my_team.timesheet_approval": {
      "canView": 0,
      "canManage": 0
    },
    "settings.roles.modules_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 0,
      "canManage": 0
    }
  },
  "PMO": {
    "dashboard.kpis": {
      "canView": 1,
      "canManage": 1
    },
    "dashboard.assigned_projects": {
      "canView": 1,
      "canManage": 1
    },
    "dashboard.pending_issues": {
      "canView": 1,
      "canManage": 1
    },
    "dashboard.project_status": {
      "canView": 1,
      "canManage": 1
    },
    "dashboard.pending_approvals": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.approvals": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 1
    },
    "projects.wbs.billing_info": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 1,
      "canManage": 1
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.task.management": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.issues": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.escalation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.appreciation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.engagement.interview": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.engagement.requirements": {
      "canView": 1,
      "canManage": 0
    },
    "projects.invoice.management": {
      "canView": 0,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 1,
      "canManage": 1
    },
    "reports.po_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 1,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 1,
      "canManage": 1
    },
    "resources.exit_summary": {
      "canView": 1,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 1,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 1
    },
    "settings.roles.modules_access": {
      "canView": 1,
      "canManage": 1
    },
    "settings.roles.user_access": {
      "canView": 1,
      "canManage": 1
    },
    "settings.masters.project": {
      "canView": 1,
      "canManage": 1
    },
    "settings.masters.customer": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 1,
      "canManage": 0
    }
  },
  "EngagementManager": {
    "dashboard.kpis": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.approvals": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.task.management": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.issues": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.escalation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.appreciation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.engagement.interview": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.engagement.requirements": {
      "canView": 1,
      "canManage": 1
    },
    "projects.invoice.management": {
      "canView": 0,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 1,
      "canManage": 1
    },
    "resources.exit_summary": {
      "canView": 1,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 1,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 1
    },
    "settings.roles.modules_access": {
      "canView": 1,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 1,
      "canManage": 0
    }
  },
  "R&D - Team member": {
    "dashboard.kpis": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.task.management": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.issues": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.alerts": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.escalation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.appreciation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.engagement.interview": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 0,
      "canManage": 0
    },
    "projects.invoice.management": {
      "canView": 0,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 0,
      "canManage": 0
    },
    "resources.exit_summary": {
      "canView": 0,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 0,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 0,
      "canManage": 0
    },
    "my_team.my_timesheet": {
      "canView": 0,
      "canManage": 0
    },
    "my_team.timesheet_approval": {
      "canView": 0,
      "canManage": 0
    },
    "settings.roles.modules_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 0,
      "canManage": 0
    }
  },
  "SOC-Team Member": {
    "dashboard.kpis": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.alerts": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.task.management": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.issues": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.alerts": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.escalation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.appreciation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.engagement.interview": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 0,
      "canManage": 0
    },
    "projects.invoice.management": {
      "canView": 0,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 0,
      "canManage": 0
    },
    "resources.exit_summary": {
      "canView": 0,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 0,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 0
    },
    "settings.roles.modules_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 0,
      "canManage": 0
    }
  },
  "SOC-Team Leader": {
    "dashboard.kpis": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.task.management": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.issues": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.alerts": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.escalation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.appreciation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.interview": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 1,
      "canManage": 0
    },
    "projects.invoice.management": {
      "canView": 0,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 1,
      "canManage": 1
    },
    "resources.exit_summary": {
      "canView": 1,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 0,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 1
    },
    "settings.roles.modules_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 0,
      "canManage": 0
    }
  },
  "SOC-Manager": {
    "dashboard.kpis": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.approvals": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.task.management": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.issues": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.escalation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.appreciation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.engagement.interview": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.engagement.requirements": {
      "canView": 1,
      "canManage": 1
    },
    "projects.invoice.management": {
      "canView": 0,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 1,
      "canManage": 1
    },
    "resources.exit_summary": {
      "canView": 1,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 1,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 1
    },
    "settings.roles.modules_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 0,
      "canManage": 0
    }
  },
  "SOC-Senior Manager": {
    "dashboard.kpis": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.approvals": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.task.management": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.issues": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.escalation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.appreciation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.engagement.interview": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 1,
      "canManage": 1
    },
    "projects.invoice.management": {
      "canView": 0,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 1,
      "canManage": 1
    },
    "resources.exit_summary": {
      "canView": 1,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 1,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 1
    },
    "settings.roles.modules_access": {
      "canView": 1,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 1,
      "canManage": 0
    }
  },
  "SOC-HOD": {
    "dashboard.kpis": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.approvals": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.task.management": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.issues": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.escalation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.appreciation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.engagement.interview": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 1,
      "canManage": 1
    },
    "projects.invoice.management": {
      "canView": 1,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 1,
      "canManage": 1
    },
    "resources.exit_summary": {
      "canView": 1,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 1,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 1
    },
    "settings.roles.modules_access": {
      "canView": 1,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 1,
      "canManage": 0
    }
  },
  "Consulting-Team member": {
    "dashboard.kpis": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.alerts": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.task.management": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.issues": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.alerts": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.escalation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.appreciation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.engagement.interview": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 0,
      "canManage": 0
    },
    "projects.invoice.management": {
      "canView": 0,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 0,
      "canManage": 0
    },
    "resources.exit_summary": {
      "canView": 0,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 0,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 0
    },
    "settings.roles.modules_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 0,
      "canManage": 0
    }
  },
  "Consulting-Team Leader": {
    "dashboard.kpis": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.task.management": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.issues": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.alerts": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.escalation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.appreciation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.interview": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 1,
      "canManage": 0
    },
    "projects.invoice.management": {
      "canView": 0,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 1,
      "canManage": 1
    },
    "resources.exit_summary": {
      "canView": 1,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 0,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 1
    },
    "settings.roles.modules_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 0,
      "canManage": 0
    }
  },
  "Consulting-Manager": {
    "dashboard.kpis": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.approvals": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.task.management": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.issues": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.escalation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.appreciation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.engagement.interview": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.engagement.requirements": {
      "canView": 1,
      "canManage": 1
    },
    "projects.invoice.management": {
      "canView": 0,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 1,
      "canManage": 1
    },
    "resources.exit_summary": {
      "canView": 1,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 1,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 1
    },
    "settings.roles.modules_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 0,
      "canManage": 0
    }
  },
  "Consulting-Senior Manager": {
    "dashboard.kpis": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.approvals": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.task.management": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.issues": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.escalation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.appreciation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.engagement.interview": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 1,
      "canManage": 1
    },
    "projects.invoice.management": {
      "canView": 0,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 1,
      "canManage": 1
    },
    "resources.exit_summary": {
      "canView": 1,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 1,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 1
    },
    "settings.roles.modules_access": {
      "canView": 1,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 1,
      "canManage": 0
    }
  },
  "Consulting-HOD": {
    "dashboard.kpis": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.approvals": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.task.management": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.issues": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.escalation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.appreciation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.engagement.interview": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 1,
      "canManage": 1
    },
    "projects.invoice.management": {
      "canView": 1,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 1,
      "canManage": 1
    },
    "resources.exit_summary": {
      "canView": 1,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 1,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 1
    },
    "settings.roles.modules_access": {
      "canView": 1,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 1,
      "canManage": 0
    }
  },
  "Testing-Team Member": {
    "dashboard.kpis": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.alerts": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.task.management": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.issues": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.alerts": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.escalation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.appreciation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.engagement.interview": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 0,
      "canManage": 0
    },
    "projects.invoice.management": {
      "canView": 0,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 0,
      "canManage": 0
    },
    "resources.exit_summary": {
      "canView": 0,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 0,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 0
    },
    "settings.roles.modules_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 0,
      "canManage": 0
    }
  },
  "Testing-Team Leader": {
    "dashboard.kpis": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.task.management": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.issues": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.alerts": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.escalation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.appreciation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.interview": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 1,
      "canManage": 0
    },
    "projects.invoice.management": {
      "canView": 0,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 1,
      "canManage": 1
    },
    "resources.exit_summary": {
      "canView": 1,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 0,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 1
    },
    "settings.roles.modules_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 0,
      "canManage": 0
    }
  },
  "Testing-Manager": {
    "dashboard.kpis": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.approvals": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.task.management": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.issues": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.escalation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.appreciation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.engagement.interview": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.engagement.requirements": {
      "canView": 1,
      "canManage": 1
    },
    "projects.invoice.management": {
      "canView": 0,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 1,
      "canManage": 1
    },
    "resources.exit_summary": {
      "canView": 1,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 1,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 1
    },
    "settings.roles.modules_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 0,
      "canManage": 0
    }
  },
  "Testing Senior Manager": {
    "dashboard.kpis": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.approvals": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.task.management": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.issues": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.escalation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.appreciation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.engagement.interview": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 1,
      "canManage": 1
    },
    "projects.invoice.management": {
      "canView": 0,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 1,
      "canManage": 1
    },
    "resources.exit_summary": {
      "canView": 1,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 1,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 1
    },
    "settings.roles.modules_access": {
      "canView": 1,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 1,
      "canManage": 0
    }
  },
  "Testing HOD": {
    "dashboard.kpis": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 1,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 1,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.approvals": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 1,
      "canManage": 0
    },
    "projects.task.management": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.issues": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.escalation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.appreciation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.engagement.interview": {
      "canView": 1,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 1,
      "canManage": 1
    },
    "projects.invoice.management": {
      "canView": 1,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 1,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 1,
      "canManage": 1
    },
    "resources.exit_summary": {
      "canView": 1,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 1,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 1
    },
    "settings.roles.modules_access": {
      "canView": 1,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 1,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 1,
      "canManage": 0
    }
  },
  "Intern": {
    "dashboard.kpis": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.assigned_projects": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_issues": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.project_status": {
      "canView": 0,
      "canManage": 0
    },
    "dashboard.pending_approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.approvals": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.alerts": {
      "canView": 0,
      "canManage": 0
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.extension_request": {
      "canView": 0,
      "canManage": 0
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 0
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.billing_info": {
      "canView": 1,
      "canManage": 0
    },
    "projects.wbs.pmo_intake": {
      "canView": 0,
      "canManage": 0
    },
    "projects.wbs.invoice_schedule": {
      "canView": 0,
      "canManage": 0
    },
    "projects.team.allocation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.task.management": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.issues": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.alerts": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.escalation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.appreciation": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.engagement.interview": {
      "canView": 0,
      "canManage": 0
    },
    "projects.health.engagement.requirements": {
      "canView": 0,
      "canManage": 0
    },
    "projects.invoice.management": {
      "canView": 0,
      "canManage": 0
    },
    "reports.sales": {
      "canView": 0,
      "canManage": 0
    },
    "reports.wbs_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.po_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "reports.invoice_tracker": {
      "canView": 0,
      "canManage": 0
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 0
    },
    "resources.directory.activity_logs": {
      "canView": 0,
      "canManage": 0
    },
    "resources.resource_pool": {
      "canView": 0,
      "canManage": 0
    },
    "resources.exit_summary": {
      "canView": 0,
      "canManage": 0
    },
    "customers.customer_profile": {
      "canView": 0,
      "canManage": 0
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 0
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 0
    },
    "settings.roles.modules_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.roles.user_access": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.project": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.customer": {
      "canView": 0,
      "canManage": 0
    },
    "settings.masters.resource": {
      "canView": 0,
      "canManage": 0
    }
  },
  "Admin": {
    "dashboard.kpis": {
      "canView": 1,
      "canManage": 1
    },
    "dashboard.assigned_projects": {
      "canView": 1,
      "canManage": 1
    },
    "dashboard.pending_issues": {
      "canView": 1,
      "canManage": 1
    },
    "dashboard.project_status": {
      "canView": 1,
      "canManage": 1
    },
    "dashboard.pending_approvals": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.raise_issues": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.bucket_list.start_timer": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.approvals": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "action_center.notifications": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.budget": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.extension_request": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.assign_spm": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.assign_pm": {
      "canView": 1,
      "canManage": 1
    },
    "projects.overview.assign_tl": {
      "canView": 1,
      "canManage": 1
    },
    "projects.wbs.billing_info": {
      "canView": 1,
      "canManage": 1
    },
    "projects.wbs.pmo_intake": {
      "canView": 1,
      "canManage": 1
    },
    "projects.wbs.invoice_schedule": {
      "canView": 1,
      "canManage": 1
    },
    "projects.team.allocation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.task.management": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.issues": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.alerts": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.escalation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.appreciation": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.engagement.interview": {
      "canView": 1,
      "canManage": 1
    },
    "projects.health.engagement.requirements": {
      "canView": 1,
      "canManage": 1
    },
    "projects.invoice.management": {
      "canView": 1,
      "canManage": 1
    },
    "reports.sales": {
      "canView": 1,
      "canManage": 1
    },
    "reports.wbs_tracker": {
      "canView": 1,
      "canManage": 1
    },
    "reports.po_tracker": {
      "canView": 1,
      "canManage": 1
    },
    "reports.invoice_tracker": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.personal_info": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.org_details": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.employment_bond": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.education_exp": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.pmo_info": {
      "canView": 1,
      "canManage": 1
    },
    "resources.directory.activity_logs": {
      "canView": 1,
      "canManage": 1
    },
    "resources.resource_pool": {
      "canView": 1,
      "canManage": 1
    },
    "resources.exit_summary": {
      "canView": 1,
      "canManage": 1
    },
    "customers.customer_profile": {
      "canView": 1,
      "canManage": 1
    },
    "repository.documents": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.dashboard": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.my_timesheet": {
      "canView": 1,
      "canManage": 1
    },
    "my_team.timesheet_approval": {
      "canView": 1,
      "canManage": 1
    },
    "settings.roles.modules_access": {
      "canView": 1,
      "canManage": 1
    },
    "settings.roles.user_access": {
      "canView": 1,
      "canManage": 1
    },
    "settings.masters.project": {
      "canView": 1,
      "canManage": 1
    },
    "settings.masters.customer": {
      "canView": 1,
      "canManage": 1
    },
    "settings.masters.resource": {
      "canView": 1,
      "canManage": 1
    }
  }
};

export function getBaselinePermissionsForRole(roleName: string): Record<string, WidgetPermissionValue> {
  const normalized = (roleName || "").trim();
  if (EXCEL_BASELINE_PERMISSIONS[normalized]) {
    return EXCEL_BASELINE_PERMISSIONS[normalized];
  }
  // Fallback matching
  for (const [key, perms] of Object.entries(EXCEL_BASELINE_PERMISSIONS)) {
    if (key.toLowerCase() === normalized.toLowerCase()) {
      return perms;
    }
  }
  // Default fallback: empty / no access
  const empty: Record<string, WidgetPermissionValue> = {};
  for (const item of RBAC_WIDGET_CATALOG) {
    empty[item.key] = { canView: 0, canManage: 0 };
  }
  return empty;
}
