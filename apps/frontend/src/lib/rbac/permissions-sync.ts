import { getBaselinePermissionsForRole, RBAC_WIDGET_CATALOG } from "./excel-baseline";

export const CUSTOM_ROLE_PERMS_STORAGE_KEY = "pulse_role_custom_widget_permissions";
export const PERMISSIONS_CHANGED_EVENT = "pulse_permissions_changed";

export interface WidgetPermValue {
  canView: number;
  canManage: number;
}

export function getCustomRolePermissions(roleName: string): Record<string, WidgetPermValue> | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = window.localStorage.getItem(CUSTOM_ROLE_PERMS_STORAGE_KEY);
    if (!raw) return null;
    const store = JSON.parse(raw) as Record<string, Record<string, WidgetPermValue>>;
    return store[roleName] || store[roleName.toLowerCase()] || null;
  } catch {
    return null;
  }
}

export function saveCustomRolePermissions(
  roleName: string,
  perms: Record<string, WidgetPermValue>
): void {
  if (typeof window === "undefined") return;
  try {
    const raw = window.localStorage.getItem(CUSTOM_ROLE_PERMS_STORAGE_KEY);
    const store: Record<string, Record<string, WidgetPermValue>> = raw ? JSON.parse(raw) : {};
    store[roleName] = perms;
    window.localStorage.setItem(CUSTOM_ROLE_PERMS_STORAGE_KEY, JSON.stringify(store));

    // Dispatch event to notify all components
    window.dispatchEvent(
      new CustomEvent(PERMISSIONS_CHANGED_EVENT, { detail: { roleName, perms } })
    );
  } catch (err) {
    console.error("Failed to save custom role permissions to localStorage", err);
  }
}

export function clearCustomRolePermissions(roleName: string): void {
  if (typeof window === "undefined") return;
  try {
    const raw = window.localStorage.getItem(CUSTOM_ROLE_PERMS_STORAGE_KEY);
    if (!raw) return;
    const store: Record<string, Record<string, WidgetPermValue>> = JSON.parse(raw);
    delete store[roleName];
    delete store[roleName.toLowerCase()];
    window.localStorage.setItem(CUSTOM_ROLE_PERMS_STORAGE_KEY, JSON.stringify(store));

    window.dispatchEvent(
      new CustomEvent(PERMISSIONS_CHANGED_EVENT, { detail: { roleName, cleared: true } })
    );
  } catch (err) {
    console.error("Failed to clear custom role permissions in localStorage", err);
  }
}

export function getEffectiveRoleWidgetMap(roleName: string): Record<string, WidgetPermValue> {
  const custom = getCustomRolePermissions(roleName);
  if (custom && Object.keys(custom).length > 0) {
    return custom;
  }
  return getBaselinePermissionsForRole(roleName);
}

/**
 * Derives the complete flat array of permission strings for a role
 * based on its active widget permissions (including macro module keys
 * like 'projects.view', 'reports.view' etc. so sidebar and guards respond immediately).
 */
export function deriveRolePermissionKeys(roleName: string): string[] {
  const norm = (roleName || "").trim().toLowerCase();
  if (norm === "admin" || norm === "dhanshree" || norm === "ceo") {
    return [
      "dashboard.view",
      "action-center.view",
      "projects.view",
      "projects.create",
      "reports.view",
      "resources.view",
      "customers.view",
      "repository.view",
      "settings.view",
      "settings.manage_roles",
      "my-team.my-timesheet.view",
      "my-team.timesheet-approval.view",
      "my-team.timesheet-approval.approve",
      ...RBAC_WIDGET_CATALOG.map((w) => w.key),
      ...RBAC_WIDGET_CATALOG.map((w) => `${w.key}.manage`),
    ];
  }

  const widgetMap = getEffectiveRoleWidgetMap(roleName);
  const keys = new Set<string>();

  let hasProjectsView = false;
  let hasReportsView = false;
  let hasResourcesView = false;
  let hasCustomersView = false;
  let hasRepositoryView = false;
  let hasActionCenterView = false;
  let hasDashboardView = false;
  let hasSettingsView = false;
  let hasTimesheetView = false;
  let hasTimesheetApproval = false;

  for (const [wKey, val] of Object.entries(widgetMap)) {
    if (val.canView === 1) {
      keys.add(wKey);

      if (wKey.startsWith("projects.")) hasProjectsView = true;
      if (wKey.startsWith("reports.")) hasReportsView = true;
      if (wKey.startsWith("resources.")) hasResourcesView = true;
      if (wKey.startsWith("customers.")) hasCustomersView = true;
      if (wKey.startsWith("repository.")) hasRepositoryView = true;
      if (wKey.startsWith("action_center.") || wKey.startsWith("action.")) hasActionCenterView = true;
      if (wKey.startsWith("dashboard.")) hasDashboardView = true;
      if (wKey.startsWith("settings.")) hasSettingsView = true;
      if (wKey === "my_team.my_timesheet") hasTimesheetView = true;
      if (wKey === "my_team.timesheet_approval") hasTimesheetApproval = true;

      if (val.canManage === 1) {
        keys.add(`${wKey}.manage`);
      }
    }
  }

  // Macro module keys required by sidebar and TanStack route guards
  if (hasDashboardView) keys.add("dashboard.view");
  if (hasActionCenterView) keys.add("action-center.view");
  if (hasProjectsView) keys.add("projects.view");
  if (hasReportsView) keys.add("reports.view");
  if (hasResourcesView) keys.add("resources.view");
  if (hasCustomersView) keys.add("customers.view");
  if (hasRepositoryView) keys.add("repository.view");
  if (hasTimesheetView) keys.add("my-team.my-timesheet.view");
  if (hasTimesheetApproval) {
    keys.add("my-team.timesheet-approval.view");
    keys.add("my-team.timesheet-approval.approve");
  }
  if (hasSettingsView) {
    keys.add("settings.view");
    keys.add("settings.manage_roles");
  }

  return Array.from(keys);
}
