# Business Domain

> **Domain:** IT Professional Services / PMO Governance  
> **Last Updated:** 2026-06-16

---

## Domain Description

Project Compass operates in the **IT Professional Services** domain. The platform serves organizations that deliver technology services to external clients on a project basis. The core business model is:

1. **Win a client** → Sales engagement
2. **Define scope** → WBS (Work Breakdown Structure) creation
3. **Allocate resources** → Match people to projects based on skills and capacity
4. **Execute delivery** → Tasks, timesheets, quality tracking
5. **Collect revenue** → Invoices, payments, financial closure
6. **Maintain governance** → Health monitoring, escalation, audit trails

---

## Domain Entities

### Primary Entities

| Entity | Description | Current Data Source |
|--------|-------------|-------------------|
| **Client** | External organization receiving services | `clients[]` in mock-data.ts |
| **Project** | Engagement with defined scope, timeline, budget | `projects[]` in mock-data.ts |
| **WBS** | Work Breakdown Structure — scope decomposition | `WBSNode[]` on Project |
| **WBS Request** | New WBS intake from Sales for PMO allocation | `wbsRequests[]` in mock-data.ts |
| **Task** | Atomic unit of work within a project | `Task[]` on Project |
| **Person** | Employee within the organization | `people[]` in mock-data.ts |
| **Timesheet** | Weekly time tracking per person | `timesheets[]` in mock-data.ts |
| **Invoice** | Financial claim against a project | `invoices[]` in mock-data.ts |
| **Issue** | Problem or risk requiring escalation | `issues[]` in mock-data.ts |
| **Alert** | System-generated or manual notification | `DhAlert[]` in dh-store.ts |
| **Escalation** | Elevated issue requiring management attention | `DhEscalation[]` in dh-store.ts |

### Supporting Entities

| Entity | Description |
|--------|-------------|
| **Allocation Event** | Record of PM/SPM/EM assignment changes |
| **PM Bucket** | Capacity tracking per Project Manager |
| **Person Workload** | Utilization & skill profile per person |
| **WBS Service** | Individual service line item within a WBS |
| **WBS Invoice** | Milestone-based invoice schedule within WBS |
| **Project Prerequisite** | Collection & validation status before project start |
| **Project Stages** | Sales → PMO → Delivery → Accounts progression |
| **Interview** | Client interview scheduling for resource allocation |
| **Appreciation** | Employee recognition within a project |

---

## Business Rules

### Client Rules
- Every client has a type: `NEW` or `OLD`
- OLD clients track `previousPmIds` for relationship continuity
- Clients are assigned to roles via `assignments` record
- PMO and HOD see all clients; SPM/EM see only assigned clients

### Project Rules
- Projects belong to exactly one client (`clientId`)
- Each project has one PM (`pmId`) and one TL (`tlId`)
- Projects have a primary team (`teamIds`) and optional shadow team (`shadowTeamIds`)
- Status flows: `ongoing` → `completed` or `on_hold`
- Health indicators: `green` (healthy), `amber` (at risk), `red` (critical)

### WBS Rules
- WBS requests flow from Sales → PMO for allocation
- Status progression: `new` → `under_allocation` → `assigned` → `active` → `closed`
- Required roles per WBS: combination of SPM, EM, PM
- PMO allocates roles using fit scores (skill match + utilization + bench status)

### Timesheet Rules
- Timesheets are weekly (Mon–Sun)
- Status flow: `draft` → `submitted` → `approved` or `rejected`
- Rejected timesheets include a `rejectionReason`
- Approval hierarchy varies by submitter role:
  - Employee/TL/PM timesheets → reviewed by Senior PM
  - Senior PM/EM timesheets → reviewed by HOD
  - PMO has monitoring-only access (cannot approve/reject)

### Invoice Rules
- Invoices are linked to projects
- Status: `raised` → `pending` → `paid` or `overdue`
- Payment status: `not_initiated` → `pending` → `completed` or `overdue`
- Dhanshree role can raise invoices and track payment received dates

### Issue Escalation Rules
- Issues follow escalation chain: TL → PM → Senior PM / EM → PMO / HOD
- Issue types: Scope Change, Resource Shortage, Delay, Escalation, Client Issue, Internal Blocker
- Tagged users receive notifications on status changes and comments
- All actions recorded in audit trail

---

## Industry-Specific Terminology

See [[25_Project_Glossary]] for complete terminology reference.

---

## Related Documents

- [[03_Organization_Hierarchy]]
- [[04_Roles_and_Permissions]]
- [[05_Business_Workflows]]
- [[09_Client_Management]]
- [[10_Project_Management]]
