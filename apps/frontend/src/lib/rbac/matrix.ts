import type { Role } from "@/lib/mock-data";
import { PERMISSION_CATALOG, type PermissionKey } from "./catalog";

const allKeys = PERMISSION_CATALOG.map((p) => p.key) as PermissionKey[];

function keys(...list: PermissionKey[]): PermissionKey[] {
  return list;
}

const EMPLOYEE_PROFILE_LIMITED: PermissionKey[] = [];

const RESOURCES_EMPLOYEE_LIKE = keys(
  "resources.view",
);

const RESOURCES_PM_LIKE = keys(
  "resources.view",
  "resources.pool",
  "resources.columns.full",
  "resources.profile.org",
  "resources.profile.employment",
  "resources.profile.skills",
  "resources.profile.kpi",
  "resources.profile.finance",
);

const PM_CORE = keys(
  "dashboard.view",
  "action.bucket_list",
  "action.bucket_timer",
  "action.approvals",
  "action.alerts",
  "action.notifications",
  "action.acknowledge",
  "projects.view",
  "projects.stage_tracker",
  "projects.tab.overview",
  "projects.tab.wbs",
  "projects.tab.team",
  "projects.tab.tasks",
  "projects.tab.health",
  "projects.overview.edit_tl",
  "projects.overview.view_spm",
  "projects.wbs.services",
  "projects.team.edit",
  "projects.tasks.edit",
  "projects.health.issues",
  "projects.health.alerts",
  "projects.health.appreciation",
  ...RESOURCES_PM_LIKE,
  "customers.view",
  "repository.view",
  "repository.download",
  "timesheet.my",
  "timesheet.approve",
);

const PMO_CORE = keys(
  "dashboard.view",
  "action.approvals",
  "action.alerts",
  "action.notifications",
  "action.acknowledge",
  "projects.view",
  "projects.stage_tracker",
  "projects.tab.overview",
  "projects.tab.wbs",
  "projects.tab.team",
  "projects.tab.tasks",
  "projects.tab.health",
  "projects.tab.invoices",
  "projects.overview.view_spm",
  "projects.wbs.pmo_intake",
  "projects.wbs.services",
  "projects.wbs.project_allocation",
  "projects.wbs.service_prereq",
  "projects.health.issues",
  "projects.health.alerts",
  "projects.health.appreciation",
  "projects.invoices.limited",
  "reports.sales",
  "reports.wbs_tracker",
  "reports.po_tracker",
  "reports.invoice_tracker",
  ...RESOURCES_PM_LIKE,
  "customers.view",
  "customers.create",
  "customers.change_em",
  "repository.view",
  "repository.download",
  "repository.upload",
  "repository.delete",
  "repository.logs",
  "my_team.dashboard",
);

const BO_VIEW = PMO_CORE.filter(
  (k) =>
    k !== "action.acknowledge" &&
    k !== "repository.upload" &&
    k !== "repository.delete" &&
    k !== "repository.logs" &&
    k !== "customers.create" &&
    k !== "customers.change_em",
);

export const DEFAULT_ROLE_PERMISSIONS: Record<Role, PermissionKey[]> = {
  employee: keys(
    "dashboard.view",
    "action.bucket_list",
    "action.bucket_timer",
    "action.notifications",
    "projects.view",
    "projects.tab.team",
    "projects.tab.tasks",
    "projects.tab.health",
    "projects.health.issues",
    "projects.health.alerts",
    "projects.health.appreciation",
    "resources.view",
    "repository.view",
    "repository.download",
    "timesheet.my",
    ...EMPLOYEE_PROFILE_LIMITED,
  ),

  pm: PM_CORE,

  senior_pm: keys(
    ...PM_CORE,
    "projects.overview.edit_pm",
  ),

  engagement_manager: keys(
    ...PM_CORE.filter((k) => k !== "projects.overview.edit_tl"),
    "projects.health.customer_engagement",
  ),

  pmo: PMO_CORE,

  business_owner: BO_VIEW,

  hod: keys(
    ...BO_VIEW,
    "action.acknowledge",
  ),

  hr: keys(
    "dashboard.view",
    "resources.view",
    "resources.profile.org",
    "resources.profile.employment",
    "resources.profile.skills",
    "resources.profile.kpi",
    "resources.profile.finance",
    "repository.view",
    "repository.download",
    "repository.upload",
    "repository.delete",
    "repository.logs",
  ),

  accounts_finance: keys(
    "dashboard.view",
    "projects.view",
    "projects.tab.overview",
    "projects.tab.wbs",
    "projects.tab.invoices",
    "projects.overview.budget",
    "projects.overview.view_spm",
    "projects.wbs.services",
    "projects.wbs.amount",
    "projects.invoices.edit",
    "projects.invoices.amount",
    "reports.po_tracker",
    "reports.invoice_tracker",
    "resources.view",
    "customers.view",
    "customers.create",
    "customers.change_em",
    "repository.view",
    "repository.download",
  ),

  sales_bd: keys(
    "dashboard.view",
    "action.alerts",
    "action.notifications",
    "projects.view",
    "projects.create",
    "projects.drafts",
    "projects.stage_tracker",
    "projects.tab.overview",
    "projects.tab.wbs",
    "projects.tab.team",
    "projects.tab.tasks",
    "projects.tab.health",
    "projects.tab.invoices",
    "projects.overview.budget",
    "projects.overview.view_spm",
    "projects.wbs.pmo_intake",
    "projects.wbs.services",
    "projects.wbs.amount",
    "projects.health.issues",
    "projects.health.alerts",
    "projects.health.appreciation",
    "projects.invoices.amount",
    "reports.sales",
    "reports.wbs_tracker",
    "resources.view",
    "customers.view",
    "customers.create",
    "repository.view",
    "repository.download",
  ),

  dhanshree: allKeys,
};

export const RBAC_STORAGE_KEY = "pulse-rbac-overrides";
