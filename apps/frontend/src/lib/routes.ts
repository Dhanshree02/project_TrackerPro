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
    DIRECTORY: "/employee-directory",
    DETAIL: (id: string) => `/employee-directory/${id}`,
    EXIT_SUMMARY: "/exit-summary",
  },

  ORGANIZATION: {
    REPOSITORY: "/repository",
    TEAM: "/my-team/",
    TIMESHEETS: "/my-team/timesheets",
  },

  SETTINGS: "/settings",
} as const;
