# Development Roadmap

> **Last Updated:** 2026-06-16

---

## Phase 0: Foundation ✅ (Current State)
- [x] Frontend SPA with role-based views
- [x] Mock data layer for all entities
- [x] 6 roles with filtered data access
- [x] Dashboard with KPIs
- [x] Client and project management views
- [x] WBS allocation with smart suggestions
- [x] Health & governance with issue management
- [x] Timesheet submission and approval
- [x] Invoice tracking
- [x] Dhanshree super-admin workflows
- [x] Project stage tracker
- [x] Prerequisite collection tracking
- [x] Resource management (onboarding/offboarding)
- [x] Action centre (central hub)
- [x] Obsidian wiki knowledge base

## Phase 1: Backend Scaffolding
- [ ] FastAPI project setup with dependency injection
- [ ] PostgreSQL database with Alembic migrations
- [ ] User model and seed data (from mock-data people)
- [ ] JWT authentication (login, refresh, logout)
- [ ] RBAC middleware with permission guards
- [ ] Client CRUD API
- [ ] Project CRUD API
- [ ] Frontend: Replace mock-data imports with React Query API calls

## Phase 2: Core Modules
- [ ] Task management API
- [ ] Timesheet submission and approval API
- [ ] Issue management API with comments
- [ ] Invoice management API
- [ ] WBS allocation API
- [ ] Audit logging service
- [ ] Frontend: Migrate all routes to API-backed data

## Phase 3: Advanced Features
- [ ] Notification engine (in-app + email)
- [ ] Approval workflow engine with configurable chains
- [ ] Resource allocation engine (port fitScore algorithm)
- [ ] Health score calculation engine
- [ ] Prerequisite management API
- [ ] Project stage tracking API

## Phase 4: Polish & Scale
- [ ] Real-time updates (WebSocket or SSE)
- [ ] File upload support (prerequisites, attachments)
- [ ] Report generation (PDF/Excel export)
- [ ] Performance optimization
- [ ] End-to-end testing
- [ ] Production deployment

---

## Related Documents
- [[00_Project_Overview]]
- [[30_Future_Backend_Implementation]]
- [[26_Open_Questions]]
