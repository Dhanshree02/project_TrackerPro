# Project Recovery Guide

> **Purpose:** Enable any new AI assistant or developer to understand the project and start contributing within minutes.  
> **Last Updated:** 2026-06-16

---

## Quick Start (Read These First)

### For Understanding the Business
1. **[[00_Project_Overview]]** — What is Project Compass? Who is it for?
2. **[[02_Business_Domain]]** — Domain entities and business rules
3. **[[05_Business_Workflows]]** — 9 major workflows with diagrams

### For Understanding the Code
4. **[[Repository_Analysis]]** — Complete repository scan with file sizes, dependencies, tech debt
5. **[[Frontend_Architecture]]** — How the app boots, routes, renders, and manages state
6. **[[RUNNING_THE_PROJECT]]** — Step-by-step local development setup

### For Understanding Roles
7. **[[04_Roles_and_Permissions]]** — 6 roles with full permission matrix
8. **[[03_Organization_Hierarchy]]** — Department structure and approval authority

### For Understanding Data
9. **[[27_Data_Model_Reference]]** — All entity types and relationships
10. **[[08_Module_Analysis]]** — File size hotspots and module dependency graph

---

## Critical Context

### What Exists ✅
- **Frontend SPA** (~810KB source) built with React 19, TanStack Start/Router, Tailwind CSS, shadcn/ui
- **Mock data layer** in `apps/frontend/src/lib/mock-data.ts` (48.6KB) — all domain data
- **Dhanshree workflow store** in `apps/frontend/src/lib/dh-store.ts` (80.3KB) — complex stateful workflows
- **Role context** in `apps/frontend/src/lib/role-context.tsx` — role switching and data filtering
- **26 route files** covering all modules (20 active routes)
- **46 shadcn/ui components** + 6 custom components
- **This wiki** — 40+ documents covering every aspect of the system
- **Deploy target:** Cloudflare Workers (via wrangler.jsonc)

### What Does NOT Exist ❌
- No backend (no API, no database, no authentication)
- No real authentication (role switcher dropdown simulates users)
- No persistent storage (everything resets on page refresh)
- No real notifications (bell icon is cosmetic)
- No file uploads
- No test suite (zero test files)
- No CI/CD pipeline
- No `.env` or environment configuration

### The Most Important Files
(Paths relative to `apps/frontend/`)

| File | Size | Why It Matters |
|------|------|---------------|
| `src/lib/mock-data.ts` | 48.6KB | **All domain data** — entities, types, relationships |
| `src/lib/dh-store.ts` | 80.3KB | **All Dhanshree workflows** — mutations, state, history |
| `src/lib/role-context.tsx` | 2.6KB | **RBAC simulation** — role switching, data filtering |
| `src/routes/projects.$projectId.tsx` | 167.6KB | **Largest module** — 6 tabs, 15+ inline components |
| `src/routes/action-centre.tsx` | 83.2KB | **Dhanshree hub** — 8 sub-modules in one file |
| `src/components/app-sidebar.tsx` | 4.6KB | **Navigation** — role-conditional menu items |
| `vite.config.ts` | 866B | **Build config** — uses @lovable.dev preset, port 6002 |

---

## Technical Debt (Known Issues)

| Issue | Severity | Where |
|-------|----------|-------|
| 167KB single route file | 🔴 Critical | `apps/frontend/src/routes/projects.$projectId.tsx` |
| 83KB single route file | 🔴 Critical | `apps/frontend/src/routes/action-centre.tsx` |
| 80KB monolithic store | 🔴 Critical | `apps/frontend/src/lib/dh-store.ts` |
| No route guards | 🟠 High | Only WBS allocation has a guard |
| Dual lockfiles | 🟡 Medium | `apps/frontend/bun.lock` + `apps/frontend/package-lock.json` |
| Orphan files | 🟡 Medium | `apps/frontend/simple-server.cjs/js`, `wbstabhtml.txt` in root, `apps/frontend/simplified-app/` |
| Duplicate routes | 🟡 Medium | `apps/frontend/src/routes/customer-detail.$clientId.tsx` |
| React Query unused | 🟢 Low | Provider mounted, no queries |

---

## How to Navigate the Wiki

```
SYSTEM-LEVEL DOCUMENTS (00-08):
  00: Project Overview (hub)
  01: System Architecture
  02: Business Domain
  03: Organization Hierarchy
  04: Roles and Permissions
  05: Business Workflows (9 workflows with Mermaid diagrams)
  06: UI Architecture
  07: Frontend Architecture (wiki version)
  08: Module Analysis

DOMAINS & FUNCTIONAL MODULES (09-19):
  09: Client Management
  10: Project Management
  11: WBS Management
  12: Resource Management
  13: Task Management
  14: Timesheet Management
  15: Approval Engine
  16: Notification System
  17: Health and Governance
  18: Finance Module
  19: Reports and Analytics

BACKEND DESIGN DRAFTS (20-24):
  20: Database Design Draft (PostgreSQL schema)
  21: API Design Draft (REST endpoints)
  22: Backend Architecture Draft (FastAPI layers)
  23: Security and RBAC
  24: Audit Logging

REFERENCE & DIAGNOSTICS (25-30):
  25: Project Glossary
  26: Open Questions
  27: Data Model Reference
  28: Development Roadmap
  29: Known Frontend Behavior
  30: Future Backend Implementation

DEVELOPMENT GUIDES:
  Repository_Analysis: Full codebase scan
  Frontend_Architecture: How the app works (new developer guide)
  RUNNING_THE_PROJECT: Local setup instructions
  Repository_Improvement_Plan: Restructuring recommendations
  Backend_Master_Plan: Backend architecture design
  BACKEND_DEVELOPMENT_PHASES: 7-phase implementation roadmap
  REPOSITORY_SETUP: Monorepo environment and running instructions (Start Here for Setup)

AI GOVERNANCE:
  PROJECT_RECOVERY_GUIDE: This file (start here)
  AI_DEVELOPMENT_WORKFLOW: Rules for code changes
  KNOWLEDGE_SYNC_RULES: How to keep wiki and code in sync
  AI_HANDOVER_TEMPLATE: Session end protocol

DEVELOPMENT TRACKING:
  development/decisions/: Architecture Decision Records
  development/frontend-progress/: Frontend session logs
  development/backend-progress/: Backend session logs
  development/daily-notes/: Daily development notes
```

---

## Current Priorities

1. **Frontend restructuring** — Split 167KB project detail, 83KB action centre, 80KB store
2. **Backend scaffolding** — FastAPI + PostgreSQL + Docker setup inside `apps/backend/`
3. **Auth implementation** — JWT login replacing role switcher
4. **Data seeding** — mock-data.ts → database seed scripts
5. **API integration** — Replace static imports with React Query hooks

---

## Running the Project

```powershell
cd "d:\TalaKunchi\Project Compass 12\apps\frontend"
npm install
npm run dev
# Opens at http://localhost:6002
```

---

## Related Documents
- [[AI_DEVELOPMENT_WORKFLOW]]
- [[KNOWLEDGE_SYNC_RULES]]
- [[AI_HANDOVER_TEMPLATE]]
- [[28_Development_Roadmap]]
- [[Backend_Master_Plan]]
- [[REPOSITORY_SETUP]]
