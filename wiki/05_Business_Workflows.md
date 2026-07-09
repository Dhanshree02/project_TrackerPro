# Business Workflows

> **Last Updated:** 2026-06-16

---

## Master Workflow

```mermaid
flowchart TD
    S1["Sales Creates Client"] --> S2["HOD Approves Client"]
    S2 --> S3["Sales Creates Project"]
    S3 --> S4["HOD Approves Project"]
    S4 --> S5["Sales Creates WBS"]
    S5 --> S6["HOD Approves WBS"]
    S6 --> S7["PMO Review"]
    S7 --> S8["Engagement Manager Review"]
    S8 --> S9["PM Assignment"]
    S9 --> S10["Resource Allocation"]
    S10 --> S11["Team Lead Assignment"]
    S11 --> S12["Task Creation"]
    S12 --> S13["Task Assignment"]
    S13 --> S14["Employee Work Execution"]
    S14 --> S15["Timesheet Submission"]
    S15 --> S16["Team Lead Approval"]
    S16 --> S17["PM Approval"]
    S17 --> S18["Invoice Generation"]
    S18 --> S19["Accounts Validation"]
    S19 --> S20["Payment Tracking"]
    S20 --> S21["Project Closure"]
```

---

## Workflow 1: Client Onboarding

**Actors:** Sales, HOD  
**Status:** 🔲 Backend required (currently clients are static mock data)

| Step | Actor | Action | System Response |
|------|-------|--------|----------------|
| 1 | Sales | Create new client | Client record created with `clientType: "NEW"` |
| 2 | HOD | Review client details | Validation of industry, contact info |
| 3 | HOD | Approve client | Client becomes active, visible to assigned roles |
| 4 | System | Assign to managers | Update `assignments` record |

---

## Workflow 2: Project Creation

**Actors:** Sales, HOD, Dhanshree  
**Status:** ⚠️ Dhanshree can create projects via `projects.new.tsx`

| Step | Actor | Action | System Response |
|------|-------|--------|----------------|
| 1 | Sales/Dhanshree | Create project under client | Project record with budget, timeline, scope |
| 2 | HOD | Review and approve | Project status → `ongoing` |
| 3 | System | Initialize WBS structure | Default WBS phases created |
| 4 | System | Create project stages | Sales → PMO → Delivery → Accounts tracker |

---

## Workflow 3: WBS Allocation

**Actors:** Sales, PMO  
**Status:** ✅ Implemented in `wbs-allocation.tsx`

```mermaid
flowchart LR
    A["Sales submits WBS"] --> B["PMO receives in WBS Inbox"]
    B --> C["PMO reviews scope, skills, budget"]
    C --> D["PMO assigns SPM using Smart Suggestions"]
    D --> E["PMO assigns EM using Smart Suggestions"]
    E --> F["PMO assigns PM using Smart Suggestions"]
    F --> G{"All roles filled?"}
    G -->|Yes| H["Confirm Allocation"]
    G -->|No| D
    H --> I["Project activated"]
    I --> J["PM bucket updated"]
    I --> K["Allocation history recorded"]
    I --> L["Owners notified"]
```

**Smart Suggestion Algorithm** (from `fitScore()` in `wbs-allocation.tsx`):
```
fitScore = skillScore (60% weight) + utilizationScore (40% weight) + benchBoost (15%)

skillScore = (matchedSkills / requiredSkills) × 60
utilizationScore = max(0, 40 - (utilization - 60) × 0.8)
benchBoost = 15 if person is on bench, else 0
```

**WBS Status Flow:**
```
new → under_allocation → assigned → active → closed
```

---

## Workflow 4: Prerequisite Collection & Validation

**Actors:** PMO, Dhanshree  
**Status:** ✅ Implemented in project detail WBS tab

| Step | Actor | Action | System Response |
|------|-------|--------|----------------|
| 1 | PMO | Initiate prerequisite collection | Per-service collection status tracking |
| 2 | PMO | Collect documents per service | `collectionStatus: "Collected"` |
| 3 | PMO | Validate each service | `validationStatus: "Validated"` |
| 4 | PMO | Assign PM and SPM | `assignedPmIds`, `assignedSpmIds` |
| 5 | PM/SPM | Acknowledge assignment | `acknowledgedByPmIds`, `acknowledgedBySpmIds` |
| 6 | System | Check readiness | If all collected + validated + PM + SPM → `isProjectReadyToStart: true` |

**Service Prerequisite States:**
- Collection: `Pending To Collect` → `Collected`
- Validation: `Pending To Validate` → `Validated`

---

## Workflow 5: Project Stage Tracking

**Actors:** Dhanshree, Sales, PMO, Delivery, Accounts  
**Status:** ✅ Implemented via `StageTracker` component

```mermaid
flowchart LR
    subgraph Sales
        S1["Pending"] --> S2["Assigned"] --> S3["Approval"]
    end
    subgraph PMO
        P1["Prerequisite Collection"] --> P2["Validation"] --> P3["Ready To Start"]
    end
    subgraph Delivery
        D1["Ongoing"] --> D2["Completed"]
        D1 --> D3["On Hold Internally"]
        D1 --> D4["On Hold Externally"]
        D1 --> D5["Cancelled"]
        D2 --> D6["After Release"]
    end
    subgraph Accounts
        A1["PO Pending"] --> A2["PO Received"] --> A3["PO Validated"]
        A3 --> A4["Invoice Not Raised"] --> A5["Invoice Raised"]
        A5 --> A6["Payment Pending"] --> A7["Payment Received"]
    end
    S3 --> P1
    P3 --> D1
    D2 --> A1
```

---

## Workflow 6: Timesheet Submission & Approval

**Actors:** Employee, TL, PM, SPM, HOD  
**Status:** ✅ Implemented in `approvals.tsx` and `timesheet.tsx`

```mermaid
flowchart TD
    A["Employee fills weekly timesheet"] --> B["Submit timesheet"]
    B --> C{"Reviewer role?"}
    C -->|Employee/TL/PM| D["Senior PM reviews"]
    C -->|Senior PM/EM| E["HOD reviews"]
    D --> F{"Decision?"}
    E --> F
    F -->|Approve| G["Status → approved"]
    F -->|Reject| H["Status → rejected + reason"]
    H --> I["Employee resubmits"]
    I --> B
```

**Timesheet Data Model:**
- Weekly entries (Mon–Sun) per project/task
- Cell-level comments with comment threads
- History tracking with status transitions

---

## Workflow 7: Issue Escalation

**Actors:** TL, PM, SPM, EM, PMO, HOD  
**Status:** ✅ Implemented in `health.tsx`

```mermaid
flowchart TD
    A["TL/PM raises issue"] --> B["Assign to target role"]
    B --> C["Tag stakeholders (CC)"]
    C --> D["Issue thread created"]
    D --> E{"Resolution?"}
    E -->|Comment/Update| F["Threaded discussion"]
    F --> E
    E -->|Status change| G["Audit trail recorded"]
    G --> H["Tagged users notified"]
    E -->|Resolved| I["Resolution recorded"]
    E -->|Escalate| J["Reassign to higher role"]
    J --> B
```

**Escalation Chain:** TL → PM → Senior PM / EM → PMO / HOD

---

## Workflow 8: Invoice & Payment Tracking

**Actors:** Dhanshree, Accounts  
**Status:** ✅ Implemented in project detail Invoices tab

| Step | Actor | Action | System Response |
|------|-------|--------|----------------|
| 1 | System | Generate invoice schedule from WBS | Milestones with target dates |
| 2 | Dhanshree | Raise invoice (enter invoice number) | `invoiceStatus: "Raised"` |
| 3 | Accounts | Track payment | `paymentStatus: "Received"` with date |
| 4 | System | Update project stage | Accounts stage progression |

---

## Workflow 9: Resource Onboarding/Offboarding

**Actors:** HR, Dhanshree  
**Status:** ✅ Implemented in `dh-resources.tsx`

**Onboarding:**
- Track new hires with department, designation, joining date
- Assign to projects
- Status: `Probation` → `Active`

**Offboarding:**
- Track resignation date, last working date
- Resignation status: `Pending` → `Accepted` or `Retain`
- Track impacted projects for knowledge transfer

---

## Related Documents

- [[09_Client_Management]]
- [[10_Project_Management]]
- [[11_WBS_Management]]
- [[14_Timesheet_Management]]
- [[15_Approval_Engine]]
- [[17_Health_and_Governance]]
- [[18_Finance_Module]]
