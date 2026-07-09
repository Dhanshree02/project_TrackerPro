# Data Model Reference

> **Source:** `mock-data.ts` (1100+ lines), `dh-store.ts` (2141 lines)  
> **Last Updated:** 2026-06-16

---

## Mock Data Exports (mock-data.ts)

### Entity Arrays
| Export | Type | Count | Description |
|--------|------|-------|-------------|
| `people` | `Person[]` | 14 | All system users |
| `clients` | `Client[]` | 10 | Client organizations |
| `projects` | `Project[]` | 43 | Active + completed projects |
| `issues` | `Issue[]` | 5 | Governance issues |
| `timesheets` | `Timesheet[]` | 7 | Weekly timesheet records |
| `invoices` | `Invoice[]` | 18 | Project invoices |
| `wbsRequests` | `WbsRequest[]` | 5 | WBS allocation requests |
| `personWorkload` | `PersonWorkload[]` | 4 | Resource utilization profiles |
| `pmBuckets` | `PmBucket[]` | 2 | PM capacity tracking |
| `assignments` | `Record<Role, string[]>` | 6 | Role-to-client mapping |
| `allocationHistory` | `AllocationEvent[]` | 6 | Assignment change history |
| `benchResourceIds` | `string[]` | 2 | Available resource IDs |

### Type Definitions
| Type | Fields | Used By |
|------|--------|---------|
| `Person` | id, name, role, avatar, email | All modules |
| `Client` | id, name, industry, logo, contact, clientType, previousPmIds | Client/Project |
| `Project` | id, name, clientId, status, health, progress, pmId, tlId, teamIds, dates, budget, wbs, tasks | Project Detail |
| `WBSNode` | id, name, progress, children? | Project WBS tab |
| `Task` | id, title, status, assigneeId, dueDate, progress | Task Management |
| `Timesheet` | id, userId, userRole, weekStart, status, entries, totalHours | Timesheets |
| `TimesheetEntry` | taskId, projectId, hours[], note, cellComments? | Timesheets |
| `Issue` | id, clientId, projectId, type, description, priority, status, comments, audit, taggedUserIds | Health & Governance |
| `Invoice` | projectId, unitPrice, qty, currency, amount, status, paymentStatus | Finance |
| `WbsRequest` | id, code, clientId, projectName, scope, modules, deliverables, complexity, slots, audit | WBS Allocation |

### Helper Functions
| Function | Signature | Purpose |
|----------|----------|---------|
| `getPerson` | `(id: string) => Person` | Lookup person by ID |
| `mkTasks` | `(projectId, pmId, tlId, teamIds, N) => Task[]` | Generate N tasks for a project |

---

## Dhanshree Store Exports (dh-store.ts)

### State Entities
| Entity | Type | Description |
|--------|------|-------------|
| `DhIssue` | Full issue with comments, history | Enhanced issue tracking |
| `DhAlert` | Alert with history, attachments | System/manual alerts |
| `DhEscalation` | Escalation with resolution tracking | Elevated issues |
| `DhAppreciation` | Employee recognition record | Positive feedback |
| `DhInterview` | Interview scheduling and status | Resource acquisition |
| `DhAdditionalRequirement` | Resource requests from PMs | Additional staffing |
| `DhProjectPrereq` | Per-project prerequisite tracking | Pre-kickoff checklist |
| `ProjectStagesTracker` | Sales/PMO/Delivery/Accounts stages | Pipeline tracking |
| `DhTimesheet` | Extended timesheet with cell comments | Enhanced time tracking |
| `DhCentralApproval` | Cross-module approval requests | Centralized approvals |
| `OnboardedResource` | New hire tracking | HR integration |
| `OffboardingResource` | Resignation/offboarding tracking | HR integration |
| `ExitedResource` | Completed exit records | Historical reference |
| `DhInvoice` | Enhanced invoice with milestone tracking | Finance management |
| `TaskAssignmentState` | Multi-assignee task mapping | Resource allocation |

### Store Methods (Mutations)
- `addIssue`, `updateIssueStatus`, `addIssueComment`
- `addAlert`, `updateAlert`
- `addEscalation`, `updateEscalation`
- `addAppreciation`
- `addInterview`, `updateInterview`
- `addRequirement`, `updateRequirement`
- `updatePrereqCollection`, `updatePrereqValidation`, `assignPrereqPM`, `assignPrereqSPM`
- `updateProjectStage`
- `updateTimesheetStatus`, `rejectTimesheet`
- `updateApproval`, `addApprovalComment`
- `addOnboardedResource`
- `addOffboardingResource`, `updateResignationStatus`
- `raiseInvoice`, `cancelInvoice`, `updatePaymentStatus`
- `submitExtensionRequest`
- `assignTaskToUser`, `updateShadowTeam`

---

## Related Documents
- [[02_Business_Domain]]
- [[20_Database_Design_Draft]]
