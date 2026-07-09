# Backend Architecture Draft

> **Status:** 🔲 Not yet implemented  
> **Stack:** FastAPI, PostgreSQL, SQLAlchemy, Alembic  
> **Last Updated:** 2026-06-16

---

## Architecture Overview

```
┌─────────────────────────────────┐
│ FastAPI Application             │
├─────────────────────────────────┤
│ Middleware Layer                │
│ ├── CORS                       │
│ ├── JWT Authentication         │
│ ├── RBAC Authorization         │
│ ├── Request Logging            │
│ └── Error Handling             │
├─────────────────────────────────┤
│ Router Layer (API Endpoints)   │
│ ├── auth/                      │
│ ├── clients/                   │
│ ├── projects/                  │
│ ├── tasks/                     │
│ ├── timesheets/                │
│ ├── issues/                    │
│ ├── invoices/                  │
│ ├── wbs/                       │
│ ├── approvals/                 │
│ ├── resources/                 │
│ └── notifications/             │
├─────────────────────────────────┤
│ Service Layer (Business Logic) │
│ ├── ApprovalEngine             │
│ ├── NotificationService        │
│ ├── AuditLogger                │
│ ├── AllocationEngine           │
│ └── HealthCalculator           │
├─────────────────────────────────┤
│ Data Access Layer (SQLAlchemy) │
│ ├── Models                     │
│ ├── Repositories               │
│ └── Migrations (Alembic)       │
├─────────────────────────────────┤
│ PostgreSQL Database            │
└─────────────────────────────────┘
```

## Proposed Directory Structure

```
apps/backend/
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI app instance
│   ├── config.py               # Settings & env vars
│   ├── dependencies.py         # Dependency injection
│   ├── middleware/
│   │   ├── auth.py             # JWT verification
│   │   ├── rbac.py             # Role-based access
│   │   └── logging.py          # Request/response logging
│   ├── routers/
│   │   ├── auth.py
│   │   ├── clients.py
│   │   ├── projects.py
│   │   ├── tasks.py
│   │   ├── timesheets.py
│   │   ├── issues.py
│   │   ├── invoices.py
│   │   ├── wbs.py
│   │   ├── approvals.py
│   │   ├── resources.py
│   │   └── notifications.py
│   ├── services/
│   │   ├── approval_engine.py
│   │   ├── notification_service.py
│   │   ├── audit_logger.py
│   │   ├── allocation_engine.py
│   │   └── health_calculator.py
│   ├── models/                 # SQLAlchemy models
│   │   ├── user.py
│   │   ├── client.py
│   │   ├── project.py
│   │   ├── task.py
│   │   ├── timesheet.py
│   │   ├── issue.py
│   │   ├── invoice.py
│   │   └── approval.py
│   ├── schemas/                # Pydantic schemas
│   │   ├── user.py
│   │   ├── client.py
│   │   ├── project.py
│   │   └── ...
│   └── database.py             # DB connection & session
├── alembic/
│   ├── env.py
│   └── versions/
├── tests/
├── alembic.ini
├── requirements.txt
└── .env
```

## Key Services

### Approval Engine
- Configurable approval chains per request type
- SLA tracking and auto-escalation
- Parallel and sequential approval support
- Delegation and proxy approval

### Notification Service
- Event-driven notification dispatch
- Multi-channel delivery (in-app, email)
- Template-based message formatting
- User preference management

### Allocation Engine
- Smart suggestion algorithm (port from frontend `fitScore`)
- Real-time capacity impact preview
- Conflict detection across projects
- Skill-based matching with weighted scoring

### Audit Logger
- Automatic audit trail for all state changes
- Structured logging with entity type, ID, actor, action
- Queryable audit history per entity

### Health Calculator
- Automated health score based on: budget burn, timeline adherence, issue severity, team utilization
- Configurable thresholds for green/amber/red

---

## Related Documents
- [[20_Database_Design_Draft]]
- [[21_API_Design_Draft]]
- [[23_Security_and_RBAC]]
- [[30_Future_Backend_Implementation]]
