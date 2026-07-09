# Architecture Decision Record Registry

> **Last Updated:** 2026-06-16

---

## Decision Log

| ADR # | Title | Status | Date | Impact |
|-------|-------|--------|------|--------|
| ADR-001 | React Context for Role Management | Accepted | 2026 | State Management |
| ADR-002 | TanStack Start for Framework | Accepted | 2026 | Frontend Architecture |
| ADR-003 | useSyncExternalStore for DhStore | Accepted | 2026 | State Management |
| ADR-004 | Mock Data Layer (No Backend) | Accepted | 2026 | Data Architecture |
| ADR-005 | File-Based Routing | Accepted | 2026 | Routing Architecture |

---

## Template

See `development/decisions/ADR-TEMPLATE.md` for the standard template.

New decisions should be added as files in `development/decisions/ADR-NNN-title.md`.

---

## Implicit Decisions (Documented Retroactively)

### ADR-001: React Context for Role Management
**Decision:** Use React Context (`RoleProvider`) for role-based data filtering.  
**Rationale:** Lightweight, no external library. Sufficient for frontend-only demo with 6 predefined roles.  
**Consequences:** Must be replaced with JWT-based auth when backend is implemented.

### ADR-002: TanStack Start Framework
**Decision:** Use TanStack Start (with TanStack Router and React Query built-in).  
**Rationale:** File-based routing, SSR support, built-in Query integration, React 19 compatibility.  
**Consequences:** Locked into TanStack ecosystem. Migration cost if framework changes.

### ADR-003: useSyncExternalStore for Dhanshree Store
**Decision:** Use `useSyncExternalStore` pattern for Dhanshree-specific state instead of Context or Zustand.  
**Rationale:** No external dependency, fine-grained subscriptions, singleton pattern for complex state.  
**Consequences:** Custom implementation to maintain. Must be replaced with API calls during backend migration.

### ADR-004: Mock Data Layer
**Decision:** Use static TypeScript exports (`mock-data.ts`) for all domain data.  
**Rationale:** Enables rapid UI development without backend dependency.  
**Consequences:** All data resets on page refresh. Must be migrated to database-backed API calls.

### ADR-005: File-Based Routing
**Decision:** One route file per page in `apps/frontend/src/routes/`.  
**Rationale:** Convention-based routing reduces configuration, matches TanStack Router best practices.  
**Consequences:** Large route files (3193 lines for project detail) should be refactored into component modules.
