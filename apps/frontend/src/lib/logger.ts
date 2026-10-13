export type LogModule =
  | 'Resources'
  | 'Customers'
  | 'Projects'
  | 'Timesheets'
  | 'Catalogs'
  | 'MyTeam'
  | 'Users'
  | 'System';

export type LogLevel = 'Information' | 'Warning' | 'Error' | 'Debug';

export interface LogPayload {
  module: LogModule;
  level?: LogLevel;
  message: string;
  details?: unknown;
}

export const logger = {
  log: async ({ module, level = 'Information', message, details }: LogPayload) => {
    try {
      const url = typeof window !== 'undefined' ? window.location.pathname : '';
      const userEmail =
        typeof localStorage !== 'undefined' ? localStorage.getItem('pms_user_email') || undefined : undefined;

      fetch('/api/v1/logs/frontend', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          module,
          level,
          message,
          url,
          userEmail,
          details,
        }),
      }).catch(() => {
        // Silently catch network drops
      });
    } catch {
      // Non-blocking
    }
  },
  info: (module: LogModule, message: string, details?: unknown) =>
    logger.log({ module, level: 'Information', message, details }),
  warn: (module: LogModule, message: string, details?: unknown) =>
    logger.log({ module, level: 'Warning', message, details }),
  error: (module: LogModule, message: string, details?: unknown) =>
    logger.log({ module, level: 'Error', message, details }),
};
