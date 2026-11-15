import { createContext, useContext, useEffect, useMemo, useState, type ReactNode } from "react";
import { useAuth } from "@/lib/auth-context";
import { getDemoPersona } from "@/lib/user-personas";
import { fetchRoles, fetchRolePermissions, type ApiRolePermission } from "@/lib/api/users";
import { fetchSidebarModules, type SidebarTab } from "@/lib/api/catalogs";

interface PermissionsContextValue {
  permissions: ApiRolePermission[];
  canView: (codeOrId: string) => boolean;
  canManage: (codeOrId: string) => boolean;
  hasPermission: (key: string) => boolean;
  hasAny: (...keys: Array<string | undefined | null>) => boolean;
  hasAll: (...keys: Array<string | undefined | null>) => boolean;
  loading: boolean;
  refreshPermissions: () => Promise<void>;
}

const DEFAULT_CODE_TO_ID: Record<string, string> = {
  // Modules
  dashboard: "471bc977-be2e-449d-91e7-5c11cb9c4ec0",
  "action-centre": "5a049953-8170-4ef4-a59e-43dc19e12de5",
  "action-center": "5a049953-8170-4ef4-a59e-43dc19e12de5",
  projects: "168b1296-de6a-4f9e-a3b9-617b83863736",
  resources: "715f79ce-51ea-46d3-b95d-8318840f90a6",
  customers: "4e57fd71-b53e-43c0-862e-5698e09c0922",
  customer: "4e57fd71-b53e-43c0-862e-5698e09c0922",
  repository: "c04c546e-0f2c-448d-b634-5d517843d365",
  "my-team": "6055ce3c-b466-4354-ba9a-b4c309111e9d",

  // Submodules & Detail Pages
  "employee-directory": "39dbd425-643b-47e9-9936-6bbae9ef5ef5",
  "exit-summary": "526e2d0d-47d4-4814-9e5a-8f7c53af1432",
  master: "662d62ab-38b1-447e-876e-7f93bf2ba50e",
  "team-dashboard": "9854b7f3-8e7e-4ecb-864f-f2533ff295f9",
  timesheets: "d67426d3-05df-4608-b8cf-c0ecfe698dc3",
  "roles-permissions": "e231d2d4-9ebb-4eb2-af48-fbe3b3b4ab90",
  "customer-detail": "a7e6b014-9f4a-4d2c-87d2-431527ef9a10",
  "project-detail": "b8f7c125-0e5b-4e3d-98e3-542638fa0b21",
  "employee-detail": "e8f7c125-0e5b-4e3d-98e3-542638fa0b23",

  // Team Dashboard Tabs
  "my-team-tab": "9854b7f3-0001-4000-8000-000000000001",
  "team-roster": "9854b7f3-0001-4000-8000-000000000001",
  "my-reportees": "b1e81c2a-34de-4dd4-b1f3-47387b8ed52b",
  "all-employees": "552f9f86-4eb0-473a-8e39-9863cfefcea4",

  // Action Centre Tabs
  "bucket-list": "db9aa2d2-1876-4d81-9ff6-6b55be19fb7a",
  "approvals": "a7bd6c40-4e96-4abb-be93-4ed4e4211978",
  "alerts": "5b828ae3-0b45-4a1c-a1cb-78b29e882cf3",
  "action-alerts": "5b828ae3-0b45-4a1c-a1cb-78b29e882cf3",
  "notifications": "69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc",

  // Timesheets Tabs
  "my-timesheet": "d67426d3-0001-4000-8000-000000000001",
  "timesheet-history": "d67426d3-0001-4000-8000-000000000002",
  "timesheet-approval": "d67426d3-0001-4000-8000-000000000003",

  // Project Detail Tabs
  "project-overview": "c1a11111-0001-4000-8000-000000000001",
  "project-wbs": "c1a11111-0001-4000-8000-000000000002",
  "project-team": "c1a11111-0001-4000-8000-000000000003",
  "project-tasks": "c1a11111-0001-4000-8000-000000000004",
  "project-health": "c1a11111-0001-4000-8000-000000000005",
  "project-invoices": "c1a11111-0001-4000-8000-000000000006",

  // Project Overview Subtabs
  "overview-budget": "c1a11111-0003-4000-8000-000000000001",
  "overview-senior-project-managers": "c1a11111-0003-4000-8000-000000000002",
  "overview-project-managers": "c1a11111-0003-4000-8000-000000000003",
  "overview-team-leads": "c1a11111-0003-4000-8000-000000000004",

  // Project Health Subtabs
  "health-issues": "c1a11111-0002-4000-8000-000000000001",
  "health-alerts": "c1a11111-0002-4000-8000-000000000002",
  "health-escalations": "c1a11111-0002-4000-8000-000000000003",
  "health-appreciation": "c1a11111-0002-4000-8000-000000000004",
  "health-customer-engagement": "c1a11111-0002-4000-8000-000000000005",
  "health-extension-request": "c1a11111-0002-4000-8000-000000000006",

  // Dashboard Widgets
  "total-team-size": "682f26ec-e31d-43a0-82de-e915bab54b59",
  "resource-boarding-details": "9c916f1a-72e0-4d52-bec1-6d684e990c65",
  "team-utilization-onsite": "896c2166-8f1f-4ab8-873c-755ab3d051fb",
  "team-utilization-offsite": "2b83bafc-1c64-449c-a644-e8e19e0c0a48",
  "team-utilization-onsite-projects": "7e3f4519-8acd-489f-a70a-ac39092fbd40",
  "team-allocation-onsite-offsite": "3c5780f7-e23d-48bd-b73e-51019dfbc2bd",
  "team-resignation-count": "0d274292-537d-4c41-8e23-3df901304d71",
  "team-capacity-offsite": "d6dea306-2e8f-41a0-89c8-857cb96f5558",

  // Employee Detail Tabs
  "employee-personal-info": "e1a11111-0001-4000-8000-000000000001",
  "employee-organization-details": "e1a11111-0001-4000-8000-000000000002",
  "employee-employment-bond": "e1a11111-0001-4000-8000-000000000003",
  "employee-education-experience": "e1a11111-0001-4000-8000-000000000004",
  "employee-pmo-em-information": "e1a11111-0001-4000-8000-000000000005",
  "employee-activity-logs": "e1a11111-0001-4000-8000-000000000006",
};

const DEFAULT_PARENT_MAP: Record<string, string> = {
  // Resources submodules
  "39dbd425-643b-47e9-9936-6bbae9ef5ef5": "715f79ce-51ea-46d3-b95d-8318840f90a6",
  "employee-directory": "resources",
  "526e2d0d-47d4-4814-9e5a-8f7c53af1432": "715f79ce-51ea-46d3-b95d-8318840f90a6",
  "exit-summary": "resources",

  // My Team submodules & Timesheets tabs
  "9854b7f3-8e7e-4ecb-864f-f2533ff295f9": "6055ce3c-b466-4354-ba9a-b4c309111e9d",
  "team-dashboard": "my-team",
  "9854b7f3-0001-4000-8000-000000000001": "9854b7f3-8e7e-4ecb-864f-f2533ff295f9",
  "my-team-tab": "team-dashboard",
  "team-roster": "team-dashboard",
  "b1e81c2a-34de-4dd4-b1f3-47387b8ed52b": "9854b7f3-8e7e-4ecb-864f-f2533ff295f9",
  "my-reportees": "team-dashboard",
  "552f9f86-4eb0-473a-8e39-9863cfefcea4": "9854b7f3-8e7e-4ecb-864f-f2533ff295f9",
  "all-employees": "team-dashboard",
  "d67426d3-05df-4608-b8cf-c0ecfe698dc3": "6055ce3c-b466-4354-ba9a-b4c309111e9d",
  timesheets: "my-team",
  "d67426d3-0001-4000-8000-000000000001": "d67426d3-05df-4608-b8cf-c0ecfe698dc3",
  "my-timesheet": "timesheets",
  "d67426d3-0001-4000-8000-000000000002": "d67426d3-05df-4608-b8cf-c0ecfe698dc3",
  "timesheet-history": "timesheets",
  "d67426d3-0001-4000-8000-000000000003": "d67426d3-05df-4608-b8cf-c0ecfe698dc3",
  "timesheet-approval": "timesheets",

  // Action Centre Tabs
  "db9aa2d2-1876-4d81-9ff6-6b55be19fb7a": "5a049953-8170-4ef4-a59e-43dc19e12de5",
  "bucket-list": "action-centre",
  "a7bd6c40-4e96-4abb-be93-4ed4e4211978": "5a049953-8170-4ef4-a59e-43dc19e12de5",
  "approvals": "action-centre",
  "5b828ae3-0b45-4a1c-a1cb-78b29e882cf3": "5a049953-8170-4ef4-a59e-43dc19e12de5",
  "alerts": "action-centre",
  "action-alerts": "action-centre",
  "69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc": "5a049953-8170-4ef4-a59e-43dc19e12de5",
  "notifications": "action-centre",

  // Detail pages
  "a7e6b014-9f4a-4d2c-87d2-431527ef9a10": "4e57fd71-b53e-43c0-862e-5698e09c0922",
  "customer-detail": "customers",
  "b8f7c125-0e5b-4e3d-98e3-542638fa0b21": "168b1296-de6a-4f9e-a3b9-617b83863736",
  "project-detail": "projects",
  "e8f7c125-0e5b-4e3d-98e3-542638fa0b23": "39dbd425-643b-47e9-9936-6bbae9ef5ef5",
  "employee-detail": "employee-directory",

  // Dashboard widgets
  "682f26ec-e31d-43a0-82de-e915bab54b59": "471bc977-be2e-449d-91e7-5c11cb9c4ec0",
  "total-team-size": "dashboard",
  "9c916f1a-72e0-4d52-bec1-6d684e990c65": "471bc977-be2e-449d-91e7-5c11cb9c4ec0",
  "resource-boarding-details": "dashboard",
  "896c2166-8f1f-4ab8-873c-755ab3d051fb": "471bc977-be2e-449d-91e7-5c11cb9c4ec0",
  "team-utilization-onsite": "dashboard",
  "2b83bafc-1c64-449c-a644-e8e19e0c0a48": "471bc977-be2e-449d-91e7-5c11cb9c4ec0",
  "team-utilization-offsite": "dashboard",
  "7e3f4519-8acd-489f-a70a-ac39092fbd40": "471bc977-be2e-449d-91e7-5c11cb9c4ec0",
  "team-utilization-onsite-projects": "dashboard",
  "3c5780f7-e23d-48bd-b73e-51019dfbc2bd": "471bc977-be2e-449d-91e7-5c11cb9c4ec0",
  "team-allocation-onsite-offsite": "dashboard",
  "0d274292-537d-4c41-8e23-3df901304d71": "471bc977-be2e-449d-91e7-5c11cb9c4ec0",
  "team-resignation-count": "dashboard",
  "d6dea306-2e8f-41a0-89c8-857cb96f5558": "471bc977-be2e-449d-91e7-5c11cb9c4ec0",
  "team-capacity-offsite": "dashboard",

  // Project detail tabs
  "c1a11111-0001-4000-8000-000000000001": "b8f7c125-0e5b-4e3d-98e3-542638fa0b21",
  "project-overview": "project-detail",
  "c1a11111-0001-4000-8000-000000000002": "b8f7c125-0e5b-4e3d-98e3-542638fa0b21",
  "project-wbs": "project-detail",
  "c1a11111-0001-4000-8000-000000000003": "b8f7c125-0e5b-4e3d-98e3-542638fa0b21",
  "project-team": "project-detail",
  "c1a11111-0001-4000-8000-000000000004": "b8f7c125-0e5b-4e3d-98e3-542638fa0b21",
  "project-tasks": "project-detail",
  "c1a11111-0001-4000-8000-000000000005": "b8f7c125-0e5b-4e3d-98e3-542638fa0b21",
  "project-health": "project-detail",
  "c1a11111-0001-4000-8000-000000000006": "b8f7c125-0e5b-4e3d-98e3-542638fa0b21",
  "project-invoices": "project-detail",

  // Overview subtabs
  "c1a11111-0003-4000-8000-000000000001": "c1a11111-0001-4000-8000-000000000001",
  "overview-budget": "project-overview",
  "c1a11111-0003-4000-8000-000000000002": "c1a11111-0001-4000-8000-000000000001",
  "overview-senior-project-managers": "project-overview",
  "c1a11111-0003-4000-8000-000000000003": "c1a11111-0001-4000-8000-000000000001",
  "overview-project-managers": "project-overview",
  "c1a11111-0003-4000-8000-000000000004": "c1a11111-0001-4000-8000-000000000001",
  "overview-team-leads": "project-overview",

  // Health subtabs
  "c1a11111-0002-4000-8000-000000000001": "c1a11111-0001-4000-8000-000000000005",
  "health-issues": "project-health",
  "c1a11111-0002-4000-8000-000000000002": "c1a11111-0001-4000-8000-000000000005",
  "health-alerts": "project-health",
  "c1a11111-0002-4000-8000-000000000003": "c1a11111-0001-4000-8000-000000000005",
  "health-escalations": "project-health",
  "c1a11111-0002-4000-8000-000000000004": "c1a11111-0001-4000-8000-000000000005",
  "health-appreciation": "project-health",
  "c1a11111-0002-4000-8000-000000000005": "c1a11111-0001-4000-8000-000000000005",
  "health-customer-engagement": "project-health",
  "c1a11111-0002-4000-8000-000000000006": "c1a11111-0001-4000-8000-000000000005",
  "health-extension-request": "project-health",

  // Employee detail tabs
  "e1a11111-0001-4000-8000-000000000001": "e8f7c125-0e5b-4e3d-98e3-542638fa0b23",
  "employee-personal-info": "employee-detail",
  "e1a11111-0001-4000-8000-000000000002": "e8f7c125-0e5b-4e3d-98e3-542638fa0b23",
  "employee-organization-details": "employee-detail",
  "e1a11111-0001-4000-8000-000000000003": "e8f7c125-0e5b-4e3d-98e3-542638fa0b23",
  "employee-employment-bond": "employee-detail",
  "e1a11111-0001-4000-8000-000000000004": "e8f7c125-0e5b-4e3d-98e3-542638fa0b23",
  "employee-education-experience": "employee-detail",
  "e1a11111-0001-4000-8000-000000000005": "e8f7c125-0e5b-4e3d-98e3-542638fa0b23",
  "employee-pmo-em-information": "employee-detail",
  "e1a11111-0001-4000-8000-000000000006": "e8f7c125-0e5b-4e3d-98e3-542638fa0b23",
  "employee-activity-logs": "employee-detail",
};

const PermissionsContext = createContext<PermissionsContextValue | null>(null);

export function PermissionProvider({ children }: { children: ReactNode }) {
  const { user, demoRole } = useAuth();
  const [rolePermissions, setRolePermissions] = useState<ApiRolePermission[]>([]);
  const [codeToId, setCodeToId] = useState<Record<string, string>>(() => ({ ...DEFAULT_CODE_TO_ID }));
  const [parentMap, setParentMap] = useState<Record<string, string>>(() => ({ ...DEFAULT_PARENT_MAP }));
  const [loading, setLoading] = useState(true);

  // Load catalog to build code -> ID and child -> parent mappings
  useEffect(() => {
    fetchSidebarModules()
      .then((modules) => {
        const mapping: Record<string, string> = { ...DEFAULT_CODE_TO_ID };
        const parents: Record<string, string> = { ...DEFAULT_PARENT_MAP };
        const registerItem = (code: string, id: string, parentId?: string, parentCode?: string) => {
          const lCode = code.toLowerCase();
          const lId = id.toLowerCase();
          mapping[lCode] = lId;
          if (parentId) {
            parents[lId] = parentId.toLowerCase();
          }
          if (parentCode) {
            parents[lCode] = parentCode.toLowerCase();
          }
        };

        const registerTab = (t: SidebarTab, parentId?: string, parentCode?: string) => {
          const lCode = t.code.toLowerCase();
          const lId = t.id.toLowerCase();
          if (lCode === "my-team") {
            mapping["my-team-tab"] = lId;
            mapping["team-roster"] = lId;
            if (parentId) parents[lId] = parentId.toLowerCase();
            if (parentCode) parents["my-team-tab"] = parentCode.toLowerCase();
          } else {
            registerItem(t.code, t.id, parentId, parentCode);
          }
          for (const child of t.children ?? []) {
            registerTab(child, t.id, t.code);
          }
        };

        const registerSubModule = (sub: SidebarSubModule, parentId?: string, parentCode?: string) => {
          registerItem(sub.code, sub.id, parentId, parentCode);
          for (const subChild of sub.children ?? []) {
            registerSubModule(subChild, sub.id, sub.code);
          }
          for (const tab of sub.tabs ?? []) {
            registerTab(tab, sub.id, sub.code);
          }
        };

        for (const mod of modules) {
          // Exclude Settings from the dynamic RBAC catalog mapping to prevent access looping
          if (
            mod.code?.toLowerCase() === "settings" ||
            mod.name?.toLowerCase() === "settings" ||
            mod.id === "fcb69b3e-e5aa-49bb-921f-7793f0a8c90d"
          ) {
            continue;
          }
          registerItem(mod.code, mod.id);
          for (const sub of mod.subModules ?? []) {
            registerSubModule(sub, mod.id, mod.code);
          }
          for (const w of mod.widgets ?? []) {
            registerItem(w.code, w.id, mod.id, mod.code);
          }
          for (const tab of mod.tabs ?? []) {
            registerTab(tab, mod.id, mod.code);
          }
        }
        setCodeToId(mapping);
        setParentMap(parents);
      })
      .catch(() => {});
  }, []);

  // Extract active role name robustly across employee codes and RBAC roles
  const activeRoleName = useMemo(() => {
    if (user?.role) return user.role.trim().toLowerCase();
    const persona = getDemoPersona(demoRole);
    return (persona?.roleKey || persona?.accessRole || demoRole || "").trim().toLowerCase();
  }, [user?.role, demoRole]);

  const refreshPermissions = async () => {
    if (!activeRoleName) return;
    setLoading(true);
    try {
      const roles = await fetchRoles();
      const normalize = (s: string) => s.toLowerCase().replace(/[^a-z0-9]/g, "");
      const matchingRole = roles.find(
        (r) =>
          r.name.toLowerCase() === activeRoleName ||
          r.displayName.toLowerCase() === activeRoleName ||
          normalize(r.name) === normalize(activeRoleName) ||
          normalize(r.displayName) === normalize(activeRoleName),
      );
      if (!matchingRole) {
        setRolePermissions([]);
        return;
      }
      const perms = await fetchRolePermissions(matchingRole.id);
      setRolePermissions(perms);
    } catch {
      // ignore
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void refreshPermissions();
  }, [activeRoleName]);

  useEffect(() => {
    const handlePermissionsUpdated = () => {
      void refreshPermissions();
    };
    window.addEventListener("permissions-updated", handlePermissionsUpdated);
    return () => {
      window.removeEventListener("permissions-updated", handlePermissionsUpdated);
    };
  }, [activeRoleName]);

  const permissionMap = useMemo(() => {
    const map = new Map<string, ApiRolePermission>();
    for (const p of rolePermissions) {
      map.set(p.itemId.toLowerCase(), p);
    }
    return map;
  }, [rolePermissions]);

  const dashboardWidgets = new Set([
    "total-team-size",
    "resource-boarding-details",
    "team-utilization-onsite",
    "team-utilization-offsite",
    "team-utilization-onsite-projects",
    "team-allocation-onsite-offsite",
    "team-resignation-count",
    "team-capacity-offsite",
    "682f26ec-e31d-43a0-82de-e915bab54b59",
    "9c916f1a-72e0-4d52-bec1-6d684e990c65",
    "896c2166-8f1f-4ab8-873c-755ab3d051fb",
    "2b83bafc-1c64-449c-a644-e8e19e0c0a48",
    "7e3f4519-8acd-489f-a70a-ac39092fbd40",
    "3c5780f7-e23d-48bd-b73e-51019dfbc2bd",
    "0d274292-537d-4c41-8e23-3df901304d71",
    "d6dea306-2e8f-41a0-89c8-857cb96f5558",
  ]);

  const detailPages = new Set([
    "employee-detail",
    "customer-detail",
    "project-detail",
    "e8f7c125-0e5b-4e3d-98e3-542638fa0b23",
    "a7e6b014-9f4a-4d2c-87d2-431527ef9a10",
    "b8f7c125-0e5b-4e3d-98e3-542638fa0b21",
  ]);

  const canView = (codeOrId: string): boolean => {
    const lower = codeOrId.trim().toLowerCase();
    const itemId = (codeToId[lower] ?? lower).toLowerCase();

    // Settings and administrative tools are reserved for Admin and not looped through RBAC catalog
    const settingsItems = new Set([
      "settings",
      "master",
      "roles-permissions",
      "fcb69b3e-e5aa-49bb-921f-7793f0a8c90d",
      "662d62ab-38b1-447e-876e-7f93bf2ba50e",
      "e231d2d4-9ebb-4eb2-af48-fbe3b3b4ab90",
    ]);
    if (settingsItems.has(lower) || settingsItems.has(itemId)) {
      return activeRoleName === "admin";
    }

    // 0. Super-admin default fallback: if no explicit permissions configured for admin, full access
    if (activeRoleName === "admin" && permissionMap.size === 0) return true;

    // Check parent permission if item is a child
    const parent = parentMap[itemId] || parentMap[lower];
    if (parent && !canView(parent)) {
      return false;
    }

    const isWidget = dashboardWidgets.has(lower) || dashboardWidgets.has(itemId);

    // If it's a dashboard widget and the dashboard module itself is turned off, forbid view
    if (isWidget && !canView("dashboard")) {
      return false;
    }

    // 1. If explicit permissions have been saved for this role in auth.tbl_role_permissions:
    if (permissionMap.size > 0) {
      const perm = permissionMap.get(itemId);
      if (perm !== undefined) {
        return perm.canView === 1;
      }

      // If this is a dashboard widget:
      if (isWidget) {
        // Did the admin explicitly configure ANY widgets in permissionMap for this role?
        const hasExplicitWidgetConfigured = Array.from(dashboardWidgets).some((w) => {
          const wid = (codeToId[w] ?? w).toLowerCase();
          return permissionMap.has(wid) || permissionMap.has(w);
        });
        if (hasExplicitWidgetConfigured) {
          // Explicit widget permissions exist, and this widget was not granted -> false
          return false;
        }
        // No widgets were explicitly configured at all -> inherit from dashboard
        return canView("dashboard");
      }

      // Detail pages (employee-detail, customer-detail, project-detail) inherit view from their parent when not explicitly configured in permissionMap
      if (detailPages.has(lower) || detailPages.has(itemId)) {
        if (parent) {
          return canView(parent);
        }
      }

      // If item is part of the catalog hierarchy and not in permissionMap, it was revoked / unselected
      if (codeToId[lower] || parent) {
        return false;
      }
    }

    // 2. Default fallback: only when no permissions exist in DB for the role
    if (activeRoleName === "admin") return true;

    // Strict RBAC items with no records default to false
    const strictRbacItems = new Set(["dashboard", "repository", ...dashboardWidgets]);
    if (strictRbacItems.has(lower) || strictRbacItems.has(itemId)) {
      return false;
    }

    // If item has a parent and no explicit permission was saved, inherit from parent
    if (parent) {
      return canView(parent);
    }

    // Default to true for items not yet configured/migrated
    return true;
  };

  const canManage = (codeOrId: string): boolean => {
    const lower = codeOrId.trim().toLowerCase();
    const itemId = (codeToId[lower] ?? lower).toLowerCase();

    // Settings and administrative tools are reserved for Admin and not looped through RBAC catalog
    const settingsItems = new Set([
      "settings",
      "master",
      "roles-permissions",
      "fcb69b3e-e5aa-49bb-921f-7793f0a8c90d",
      "662d62ab-38b1-447e-876e-7f93bf2ba50e",
      "e231d2d4-9ebb-4eb2-af48-fbe3b3b4ab90",
    ]);
    if (settingsItems.has(lower) || settingsItems.has(itemId)) {
      return activeRoleName === "admin";
    }

    // 0. Super-admin default fallback: if no explicit permissions configured for admin, full access
    if (activeRoleName === "admin" && permissionMap.size === 0) return true;

    // If item is a child, it cannot have manage access if its parent does not have manage access,
    // EXCEPT for Project Detail and Team Dashboard child tabs/submodules whose manage access is configured independently
    const parent = parentMap[itemId] || parentMap[lower];
    const independentContainers = new Set([
      "project-detail",
      "b8f7c125-0e5b-4e3d-98e3-542638fa0b21",
      "project-overview",
      "c1a11111-0001-4000-8000-000000000001",
      "project-health",
      "c1a11111-0001-4000-8000-000000000005",
      "my-team",
      "6055ce3c-b466-4354-ba9a-b4c309111e9d",
      "team-dashboard",
      "9854b7f3-8e7e-4ecb-864f-f2533ff295f9",
      "action-centre",
      "action-center",
      "5a049953-8170-4ef4-a59e-43dc19e12de5",
    ]);
    const isIndependentDescendant =
      parent && (independentContainers.has(parent) || independentContainers.has(parentMap[parent]));

    if (parent && !isIndependentDescendant && !canManage(parent)) {
      return false;
    }

    // 1. If explicit permissions have been saved for this role in auth.tbl_role_permissions:
    if (permissionMap.size > 0) {
      const perm = permissionMap.get(itemId);
      if (perm !== undefined) {
        return perm.canManage === 1;
      }

      // Manage access NEVER inherits automatically — must be explicitly granted
      return false;
    }

    // 2. Default fallback: only when no permissions exist in DB for the role
    if (activeRoleName === "admin") return true;

    return false;
  };

  const hasPermission = (key: string): boolean => {
    const cleaned = key.replace(/\.view$/, "").replace(/\.manage$/, "");
    return canView(cleaned);
  };

  const hasAny = (...keys: Array<string | undefined | null>): boolean => {
    const valid = keys.filter(Boolean) as string[];
    if (valid.length === 0) return true;
    return valid.some((k) => hasPermission(k));
  };

  const hasAll = (...keys: Array<string | undefined | null>): boolean => {
    const valid = keys.filter(Boolean) as string[];
    if (valid.length === 0) return true;
    return valid.every((k) => hasPermission(k));
  };

  const value = useMemo(
    () => ({
      permissions: rolePermissions,
      canView,
      canManage,
      hasPermission,
      hasAny,
      hasAll,
      loading,
      refreshPermissions,
    }),
    [rolePermissions, permissionMap, codeToId, parentMap, activeRoleName, loading, refreshPermissions],
  );

  return <PermissionsContext.Provider value={value}>{children}</PermissionsContext.Provider>;
}

export function usePermissions(): PermissionsContextValue {
  const ctx = useContext(PermissionsContext);
  if (!ctx) throw new Error("usePermissions must be used inside PermissionProvider");
  return ctx;
}
