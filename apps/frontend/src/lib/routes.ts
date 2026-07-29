/**
 * Centralized Application Routes Helper
 * Provides strongly-typed route paths to ensure consistent navigation across the application.
 */

export const APP_ROUTES = {
  HOME: "/",
  ACTION_CENTRE: "/action-centre",
  
  PROJECTS: {
    INDEX: "/projects",
    NEW: "/projects/new",
    DETAIL: (projectId: string) => `/projects/${projectId}`,
  },
  
  CUSTOMERS: {
    INDEX: "/customers",
    DETAIL: (clientId: string) => `/customers/${clientId}`,
  },
  
  EMPLOYEES: {
    DIRECTORY: "/dh-employee-directory",
    DETAIL: (id: string) => `/dh-employee-directory/${id}`,
    EXIT_SUMMARY: "/dh-exit-summary",
  },
  
  ORGANIZATION: {
    REPOSITORY: "/my-org",
    TEAM: "/my-team/",
    TIMESHEETS: "/my-team/timesheets",
  },
  
  GOVERNANCE: {
    HEALTH: "/health",
    REPORTS: "/reports",
    APPROVALS: "/approvals",
    RESOURCES: "/resources",
    WBS_ALLOCATION: "/wbs-allocation",
  },
  
  SETTINGS: "/dh-settings",
} as const;
