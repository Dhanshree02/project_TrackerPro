# Project Compass — Project Overview

> **Internal Name:** Pulse PMO  
> **Project Type:** Enterprise PMO, Resource Management, HRMS, Timesheet, Approval & Finance Platform  
> **Target Market:** IT Service Companies & Professional Services Organizations  
> **Last Updated:** 2026-06-16  
> **Wiki Version:** 1.0.0

---

## Executive Summary

Project Compass (internally branded **Pulse PMO**) is a comprehensive, enterprise-grade platform designed to manage the **complete project lifecycle** for IT service companies and professional services organizations. Unlike simple HRMS or task management tools, Compass orchestrates the entire business flow from client acquisition through project delivery, financial settlement, and closure.

### Core Business Flow

```
Client → Project → WBS → Resource Allocation → Task Management 
→ Timesheets → Invoice → Payment → Project Closure
```

---

## Problem Statement

IT service companies managing multiple clients, projects, and teams face fragmented workflows across:
- Sales handoff to delivery
- Resource allocation and capacity planning
- Multi-tier approval chains
- Financial tracking from WBS to invoice to payment
- Governance, health monitoring, and escalation

Compass consolidates all these workflows into a single platform with role-based access and approval engines.

---

## Key Modules

| Module | Status | Description |
|--------|--------|-------------|
| [[06_UI_Architecture\|Dashboard]] | ✅ Frontend | Role-based KPI overview |
| [[09_Client_Management\|Client Management]] | ✅ Frontend | Client CRUD, client types, assignment |
| [[10_Project_Management\|Project Management]] | ✅ Frontend | Project lifecycle, stages tracker |
| [[11_WBS_Management\|WBS Management]] | ✅ Frontend | WBS intake, allocation, prerequisite tracking |
| [[12_Resource_Management\|Resource Management]] | ✅ Frontend | Capacity planning, bench tracking, onboarding/offboarding |
| [[13_Task_Management\|Task Management]] | ✅ Frontend | Task CRUD, multi-assignee, status tracking |
| [[14_Timesheet_Management\|Timesheet Management]] | ✅ Frontend | Weekly timesheet submission, cell comments |
| [[15_Approval_Engine\|Approval Engine]] | ✅ Frontend (Mock) | Multi-level timesheet & central approvals |
| [[16_Notification_System\|Notification System]] | 🔲 Planned | Real-time alerts, email notifications |
| [[17_Health_and_Governance\|Health & Governance]] | ✅ Frontend | Issue escalation, alerts, audit trail |
| [[18_Finance_Module\|Finance Module]] | ✅ Frontend | Invoice tracking, payment status, PO management |
| [[19_Reports_and_Analytics\|Reports & Analytics]] | ✅ Frontend | Recharts-based analytics dashboards |
| [[23_Security_and_RBAC\|Security & RBAC]] | 🔲 Planned | JWT auth, role-based access control |
| [[24_Audit_Logging\|Audit Logging]] | ✅ Frontend (Mock) | Action trails on issues, allocations, timesheets |

---

## Current Implementation Status

### Frontend (~80% Complete)
- **Stack:** React 19, TypeScript, TanStack Start + Router, React Query, Tailwind CSS, shadcn/ui, Recharts
- **State Management:** React Context (role switching), `useSyncExternalStore` (Dhanshree store)
- **Data:** All data sourced from `mock-data.ts` and `dh-store.ts` — no backend exists
- **Routing:** File-based routing via TanStack Router
- **Build:** Vite 7, deployed to Cloudflare Workers (Wrangler config present)

### Backend (Not Yet Implemented)
- **Planned Stack:** FastAPI, PostgreSQL, SQLAlchemy, Alembic, JWT, RBAC
- See [[22_Backend_Architecture_Draft]] and [[20_Database_Design_Draft]]

---

## Organization Hierarchy

```
CEO
 └── HOD (Head of Department)
      └── Engagement Manager
           └── Senior Project Manager
                └── Project Manager
                     └── Team Lead
                          └── Employee
```

See [[03_Organization_Hierarchy]] for detailed hierarchy documentation.

---

## Roles

| Role | Code Key | Responsibilities |
|------|----------|-----------------|
| Sales | — | Client/project/WBS creation |
| Accounts | — | Invoice, PO, payment validation |
| HR | — | Onboarding, offboarding |
| PMO | `pmo` | Governance, WBS allocation, monitoring |
| HOD | `hod` | Department oversight, approvals |
| Engagement Manager | `engagement_manager` | Client relationship, escalation |
| Senior PM | `senior_pm` | Portfolio oversight, escalation handling |
| Project Manager | (via `pmId`) | Day-to-day project execution |
| Team Lead | (via `tlId`) | Task assignment, team coordination |
| Employee | — | Task execution, timesheet submission |
| Business Owner | `business_owner` | Executive oversight |
| Dhanshree | `dhanshree` | Delivery operations (super-admin view) |

See [[04_Roles_and_Permissions]] for detailed RBAC matrix.

---

## Related Documents

### System & Domain
- [[01_System_Architecture]]
- [[02_Business_Domain]]
- [[05_Business_Workflows]]
- [[07_Frontend_Architecture]]
- [[25_Project_Glossary]]
- [[26_Open_Questions]]
- [[28_Development_Roadmap]]

### Analysis & Planning
- [[Repository_Analysis]] — Complete codebase scan
- [[Frontend_Architecture]] — How the app works (new developer guide)
- [[RUNNING_THE_PROJECT]] — Local development setup
- [[Repository_Improvement_Plan]] — Restructuring recommendations
- [[Backend_Master_Plan]] — Future backend architecture
- [[BACKEND_DEVELOPMENT_PHASES]] — 7-phase implementation roadmap

### AI Governance
- [[PROJECT_RECOVERY_GUIDE]] — Start here
- [[AI_DEVELOPMENT_WORKFLOW]]
- [[KNOWLEDGE_SYNC_RULES]]
- [[AI_HANDOVER_TEMPLATE]]

---

## Document Conventions

- `✅` = Implemented (frontend)
- `🔲` = Planned / Not yet implemented
- `⚠️` = Partially implemented or has known issues
- `[[Link]]` = Obsidian internal wiki link
- All code paths are relative to `apps/frontend/src/` unless otherwise noted
