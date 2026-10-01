import { createContext, useContext, useMemo, type ReactNode } from "react";
import { useAuth } from "@/lib/auth-context";
import { useWidgetPermissions } from "@/lib/rbac/widget-permissions";

/**
 * Central permission mechanism (frontend half of RBAC).
 *
 * Dynamically resolves against the 4-tier PostgreSQL RBAC matrix via useWidgetPermissions(),
 * with backwards-compatible fallback to JWT claims / mock user permissions.
 */
interface PermissionsContextValue {
  /** Effective permission keys for the signed-in user (e.g. "projects.team.assign"). */
  permissions: string[];
  /** True when the user holds the exact permission key. */
  hasPermission: (key: string) => boolean;
  /** True when the user holds ANY of the given keys (null/undefined entries are ignored). */
  hasAny: (...keys: Array<string | undefined | null>) => boolean;
  /** True when the user holds ALL of the given keys. */
  hasAll: (...keys: Array<string | undefined | null>) => boolean;
}

const PermissionsContext = createContext<PermissionsContextValue | null>(null);

export function PermissionProvider({ children }: { children: ReactNode }) {
  const { user } = useAuth();
  const { permissionsMap, canView, canManage, canViewModule, canManageModule, canViewSubmodule } = useWidgetPermissions();

  const value = useMemo<PermissionsContextValue>(() => {
    const permissions = user?.permissions ?? [];
    const set = new Set(permissions);
    const roleLower = user?.role?.toLowerCase() ?? "";
    const isSuperAdmin =
      roleLower === "admin" ||
      roleLower === "dhanshree" ||
      roleLower === "ceo" ||
      roleLower === "coo";

    const hasRbacData = Object.keys(permissionsMap).length > 0;

    const checkKey = (key: string): boolean => {
      if (isSuperAdmin) return true;

      const norm = key.toLowerCase();

      // If live 4-tier RBAC data is loaded for this role, query the database matrix
      if (hasRbacData) {
        // Dashboard
        if (norm === "dashboard.view" || norm === "dashboard") {
          return canViewModule("dashboard");
        }

        // Projects module & submodules
        if (norm === "projects.view" || norm === "projects") {
          return canViewModule("projects");
        }
        if (norm === "projects.create" || norm === "projects.manage") {
          return canManageModule("projects");
        }
        if (norm === "projects.overview" || norm === "projects.overview.view") {
          return canViewSubmodule("projects.overview");
        }
        if (norm === "projects.wbs" || norm === "projects.wbs.view") {
          return canViewSubmodule("projects.wbs");
        }
        if (norm === "projects.team" || norm === "projects.team.view") {
          return canViewSubmodule("projects.team");
        }
        if (norm === "projects.task" || norm === "projects.task.view") {
          return canViewSubmodule("projects.task");
        }
        if (norm === "projects.health" || norm === "projects.health.view") {
          return canViewSubmodule("projects.health");
        }
        if (norm === "projects.invoice" || norm === "projects.invoice.view") {
          return canViewSubmodule("projects.invoice");
        }

        // Reports module & submodules
        if (norm === "reports.view" || norm === "reports") {
          return canViewModule("reports");
        }
        if (norm === "reports.sales") {
          return canView("reports.sales");
        }
        if (norm === "reports.wbs_tracker" || norm === "reports.wbs") {
          return canView("reports.wbs_tracker");
        }
        if (norm === "reports.po_tracker" || norm === "reports.po") {
          return canView("reports.po_tracker");
        }
        if (norm === "reports.invoice_tracker" || norm === "reports.invoice") {
          return canView("reports.invoice_tracker");
        }

        // Resources module & submodules
        if (norm === "resources.view" || norm === "resources" || norm === "resource.view" || norm === "resource") {
          return canViewModule("resources") || canViewModule("resource");
        }
        if (norm === "resources.manage") {
          return canManageModule("resources");
        }
        if (norm === "resources.directory" || norm.startsWith("resources.directory.")) {
          return canViewSubmodule("resources.directory") || canView(norm);
        }
        if (norm === "resources.resource_pool" || norm === "resources.pool") {
          return canView("resources.resource_pool");
        }
        if (norm === "resources.exit_summary" || norm === "resources.exit") {
          return canView("resources.exit_summary");
        }

        // Customers module
        if (norm === "customers.view" || norm === "customers") {
          return canViewModule("customers");
        }
        if (norm === "customers.create" || norm === "customers.manage" || norm === "customers.edit") {
          return canManageModule("customers");
        }
        if (norm === "customers.customer_profile" || norm === "customers.profile") {
          return canView("customers.customer_profile");
        }

        // Repository module
        if (norm === "repository.view" || norm === "repository" || norm === "my-org.view") {
          return canViewModule("repository") || canView("repository.documents");
        }

        // Action Center module & submodules
        if (norm === "action-center.view" || norm === "action_center.view" || norm === "action-center" || norm === "action_center") {
          return canViewModule("action_center");
        }
        if (norm === "action_center.bucket_list" || norm === "action-center.bucket-list") {
          return canViewSubmodule("action_center.bucket_list");
        }
        if (norm === "action_center.approvals" || norm === "action-center.approvals" || norm === "approvals.view") {
          return canView("action_center.approvals");
        }
        if (norm === "action_center.alerts" || norm === "action-center.alerts") {
          return canView("action_center.alerts");
        }
        if (norm === "action_center.notifications" || norm === "action-center.notifications") {
          return canView("action_center.notifications");
        }

        // My Team module & submodules
        if (norm === "my-team.view" || norm === "my_team.view" || norm === "my-team" || norm === "my_team") {
          return canViewModule("my_team");
        }
        if (norm === "my_team.my_timesheet" || norm === "timesheet.my" || norm === "my-team.my-timesheet.view") {
          return canView("my_team.my_timesheet");
        }
        if (norm === "my_team.dashboard" || norm === "my-team.dashboard" || norm === "my_team.team_timesheets" || norm === "my-team.team-timesheets.view") {
          return canView("my_team.dashboard");
        }
        if (norm === "my_team.timesheet_approval" || norm === "my-team.timesheet-approval.view" || norm === "my-team.timesheets") {
          return canView("my_team.timesheet_approval");
        }

        // Settings module & submodules
        if (norm === "settings.view" || norm === "settings") {
          return canViewModule("settings");
        }
        if (
          norm === "settings.manage_roles" ||
          norm === "roles:manage" ||
          norm === "settings.roles_permissions" ||
          norm === "settings.roles"
        ) {
          return (
            canView("settings.roles.modules_access") ||
            canView("settings.roles.user_access") ||
            canViewSubmodule("settings.roles")
          );
        }
        if (norm === "settings.roles.modules_access") {
          return canView("settings.roles.modules_access");
        }
        if (norm === "settings.roles.user_access") {
          return canView("settings.roles.user_access");
        }
        if (norm === "settings.masters" || norm === "settings.masters.departments") {
          return (
            canView("settings.masters.project") ||
            canView("settings.masters.customer") ||
            canView("settings.masters.resource") ||
            canViewSubmodule("settings.masters")
          );
        }
        if (norm === "settings.masters.project") {
          return canView("settings.masters.project");
        }
        if (norm === "settings.masters.customer") {
          return canView("settings.masters.customer");
        }
        if (norm === "settings.masters.resource") {
          return canView("settings.masters.resource");
        }

        // Direct widget key check
        if (canView(norm)) {
          return true;
        }
      }

      // Fallback to JWT / legacy mock permissions set
      return set.has(key);
    };

    return {
      permissions,
      hasPermission: checkKey,
      hasAny: (...keys) => isSuperAdmin || keys.some((k) => !!k && checkKey(k)),
      hasAll: (...keys) => isSuperAdmin || keys.every((k) => !k || checkKey(k)),
    };
  }, [user?.permissions, user?.role, permissionsMap, canView, canManage, canViewModule, canManageModule]);

  return <PermissionsContext.Provider value={value}>{children}</PermissionsContext.Provider>;
}

export function usePermissions(): PermissionsContextValue {
  const ctx = useContext(PermissionsContext);
  if (!ctx) throw new Error("usePermissions must be used inside PermissionProvider");
  return ctx;
}
