# Project Management

> **Route Files:** `projects.index.tsx`, `projects.new.tsx`, `projects.$projectId.tsx`  
> **Data Source:** `mock-data.ts` → `projects[]`, `dh-store.ts`  
> **Last Updated:** 2026-06-16

---

## Responsibilities
- Project lifecycle management (creation through closure)
- Project health and status tracking
- Budget and timeline monitoring
- Team assignment and shadow team management
- Project stage progression (Sales → PMO → Delivery → Accounts)
- WBS structure management
- Prerequisite collection and validation
- Invoice and payment tracking per project

## Actors
| Actor | Permissions |
|-------|------------|
| Sales | Create projects |
| HOD | Approve project creation |
| PMO | Monitor all projects, allocate resources |
| SPM | View assigned projects, approve timesheets |
| EM | View assigned projects, manage escalations |
| PM | Day-to-day project management |
| TL | Task management, team coordination |
| Dhanshree | Full CRUD, stage tracking, prerequisites, invoices |

## Data Model

```typescript
interface Project {
  id: string;
  name: string;
  clientId: string;
  status: "ongoing" | "completed" | "on_hold";
  health: "green" | "amber" | "red";
  progress: number;            // 0-100
  pmId: string;
  tlId: string;
  teamIds: string[];
  shadowTeamIds?: string[];    // Backup/support resources
  startDate: string;
  endDate: string;
  budget: number;
  spent: number;
  description: string;
  wbs: WBSNode[];
  wbsDetails?: WBSDetails;    // Extended WBS with services & invoices
  tasks: Task[];
  // Extended fields (Dhanshree role)
  wbsStatus?: WbsStatus;
  wbsSubStatus?: string;
  engagementManager?: string;
  salesPerson?: string;
  contractType?: string;
  projectType?: string;
  currency?: string;
  taxPercent?: number;
  totalHours?: number;
  totalDays?: number;
  invoiceValue?: number;
}
```

## Current Project Registry (43 Projects)

| Client | Active Projects | Completed | Total |
|--------|----------------|-----------|-------|
| Northwind Bank (c1) | 3 | 3 | 6 |
| Helix Pharma (c2) | 2 | 2 | 4 |
| Orbit Retail (c3) | 2 | 2 | 4 |
| Zenith Logistics (c4) | 2 | 1 | 3 |
| Lumen Energy (c5) | 2 | 2 | 4 |
| CloudSync AI (c6) | 2 | 1 | 3 |
| FinTech Global (c7) | 2 | 2 | 4 |
| MediCare Plus (c8) | 2 | 2 | 4 |
| EcoGreen Solutions (c9) | 2 | 2 | 4 |
| AutoDrive Systems (c10) | 2 | 2 | 4 |

## Project Detail Tabs

### Overview Tab
- Description, timeline, budget burn
- PM, TL, and team display
- Dhanshree: EM/PM/TL blocks, extension request card

### WBS Tab
- WBS tree structure with progress bars
- Service and deliverable tables
- Billing information
- Invoice schedule
- **Prerequisite Collection Status:** Per-service collection and validation tracking

### Tasks Tab
- Standard: Task list with status, assignee, progress
- Dhanshree: Enhanced with task codes, start dates, estimated vs actual hours, multi-assignee

### Team Tab
- Standard: PM, TL, team members
- Dhanshree: Project team + shadow team with billability, resource type, duration

### Health Tab
- Issues and alerts specific to the project
- Escalation management
- Appreciation/recognition

### Invoices Tab
- Standard: Invoice list with payment status
- Dhanshree: Full invoice management with raise/cancel, invoice number entry, payment tracking

## Business Rules
1. Every project belongs to exactly one client
2. Project has exactly one PM and one TL
3. Shadow team members are backup/support resources
4. Health status affects dashboard KPI calculations
5. Budget burn = (spent / budget) × 100
6. Project stages are tracked independently of project status
7. Prerequisites must be collected and validated before project start

## Future Backend Considerations
- Project CRUD API with approval workflow
- Real-time health calculation based on metrics
- Automated stage progression
- Budget alerts and threshold notifications
- Resource utilization impact calculations

---

## Related Documents
- [[09_Client_Management]]
- [[11_WBS_Management]]
- [[13_Task_Management]]
- [[18_Finance_Module]]
