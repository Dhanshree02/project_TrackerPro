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
  if (norm === "admin" || norm === "dhanshree") {
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
  let hasProjectsManage = false;
  let hasReportsView = false;
  let hasReportsManage = false;
  let hasResourcesView = false;
  let hasResourcesManage = false;
  let hasCustomersView = false;
  let hasCustomersManage = false;
  let hasRepositoryView = false;
  let hasRepositoryManage = false;
  let hasActionCenterView = false;
  let hasActionCenterManage = false;
  let hasDashboardView = false;
  let hasSettingsView = false;
  let hasSettingsRolesView = false;
  let hasSettingsRolesManage = false;
  let hasSettingsMastersView = false;
  let hasMyTeamView = false;
  let hasMyTeamManage = false;
  let hasTimesheetView = false;
  let hasTimesheetApproval = false;

  for (const [wKey, val] of Object.entries(widgetMap)) {
    if (val.canView === 1) {
      keys.add(wKey);

      if (wKey.startsWith("projects.")) {
        hasProjectsView = true;
        if (val.canManage === 1) hasProjectsManage = true;
      }
      if (wKey.startsWith("reports.")) {
        hasReportsView = true;
        if (val.canManage === 1) hasReportsManage = true;
      }
      if (wKey.startsWith("resources.")) {
        hasResourcesView = true;
        if (val.canManage === 1) hasResourcesManage = true;
      }
      if (wKey.startsWith("customers.")) {
        hasCustomersView = true;
        if (val.canManage === 1) hasCustomersManage = true;
      }
      if (wKey.startsWith("repository.")) {
        hasRepositoryView = true;
        if (val.canManage === 1) hasRepositoryManage = true;
      }
      if (wKey.startsWith("action_center.") || wKey.startsWith("action.")) {
        hasActionCenterView = true;
        if (val.canManage === 1) hasActionCenterManage = true;
      }
      if (wKey.startsWith("dashboard.")) {
        hasDashboardView = true;
      }
      if (wKey.startsWith("settings.")) {
        hasSettingsView = true;
        if (wKey.startsWith("settings.roles.")) {
          hasSettingsRolesView = true;
          if (val.canManage === 1) hasSettingsRolesManage = true;
        }
        if (wKey.startsWith("settings.masters.")) {
          hasSettingsMastersView = true;
        }
      }
      if (wKey.startsWith("my_team.") || wKey.startsWith("my-team.")) {
        hasMyTeamView = true;
        if (val.canManage === 1) hasMyTeamManage = true;
      }
      if (wKey === "my_team.my_timesheet") hasTimesheetView = true;
      if (wKey === "my_team.timesheet_approval") hasTimesheetApproval = true;

      if (val.canManage === 1) {
        keys.add(`${wKey}.manage`);
      }
    }
  }

  // Macro module keys required by sidebar and TanStack route guards
  if (hasDashboardView) keys.add("dashboard.view");
  if (hasActionCenterView) {
    keys.add("action-center.view");
    if (hasActionCenterManage) keys.add("action-center.manage");
  }
  if (hasProjectsView) {
    keys.add("projects.view");
    if (hasProjectsManage) {
      keys.add("projects.manage");
      keys.add("projects.create");
      keys.add("projects.edit");
    }
  }
  if (hasReportsView) {
    keys.add("reports.view");
    if (hasReportsManage) keys.add("reports.manage");
  }
  if (hasResourcesView) {
    keys.add("resources.view");
    if (hasResourcesManage) keys.add("resources.manage");
  }
  if (hasCustomersView) {
    keys.add("customers.view");
    if (hasCustomersManage) {
      keys.add("customers.manage");
      keys.add("customers.create");
    }
  }
  if (hasRepositoryView) {
    keys.add("repository.view");
    if (hasRepositoryManage) keys.add("repository.manage");
  }
  if (hasMyTeamView || hasTimesheetView || hasTimesheetApproval) {
    keys.add("my-team.view");
    if (hasMyTeamManage) keys.add("my-team.manage");
  }
  if (hasTimesheetView) keys.add("my-team.my-timesheet.view");
  if (hasTimesheetApproval) {
    keys.add("my-team.timesheet-approval.view");
    keys.add("my-team.timesheet-approval.approve");
  }
  if (hasSettingsView) {
    keys.add("settings.view");
    if (hasSettingsRolesView) keys.add("settings.roles.view");
    if (hasSettingsRolesManage) keys.add("settings.manage_roles");
    if (hasSettingsMastersView) keys.add("settings.masters.view");
  }

  return Array.from(keys);
}
