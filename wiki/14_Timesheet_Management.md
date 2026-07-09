# Timesheet Management

> **Route Files:** `timesheet.tsx`, `approvals.tsx`, Action Centre timesheets tab  
> **Data Source:** `mock-data.ts` → `timesheets[]`, `dh-store.ts` → `DhTimesheet[]`  
> **Last Updated:** 2026-06-16

---

## Responsibilities
- Weekly timesheet submission (Mon–Sun)
- Per-project, per-task hour logging
- Cell-level commenting and clarification
- Multi-level approval workflow
- Rejection with mandatory reason
- History tracking with status transitions

## Data Models

```typescript
interface TimesheetEntry {
  taskId: string;
  projectId: string;
  hours: number[];    // 7 days [Mon..Sun]
  note?: string;
  notes?: string[];
  cellComments?: Record<number, CellCommentData>;
}

interface Timesheet {
  id: string;
  userId: string;
  userRole: "Employee" | "TL" | "PM" | "Senior PM" | "EM";
  weekStart: string;  // ISO date
  status: "draft" | "submitted" | "approved" | "rejected";
  entries: TimesheetEntry[];
  totalHours: number;
  submittedAt?: string;
  rejectionReason?: string;
}
```

### Cell Comment System
```typescript
interface CellCommentMessage {
  author: string;
  text: string;
  type: "comment" | "response" | "clarification_request";
  createdAt: string;
}

interface CellCommentData {
  status: "new" | "viewed" | "clarification_requested";
  history: CellCommentMessage[];
}
```

## Current Timesheet Data (7 entries)

| ID | User | Role | Week | Status | Hours |
|----|------|------|------|--------|-------|
| ts1 | Vikram Shah | PM | May 4 | submitted | 42h |
| ts2 | Sana Iyer | PM | May 4 | submitted | 40h |
| ts3 | Vikram Shah | PM | Apr 27 | approved | 41h |
| ts4 | Sana Iyer | PM | Apr 27 | rejected | 38h |
| ts5 | Aarav Mehta | SPM | May 4 | submitted | 44h |
| ts6 | Riya Kapoor | EM | May 4 | submitted | 41h |
| ts7 | Aarav Mehta | SPM | Apr 27 | approved | 42h |

## Approval Matrix

| Submitter Role | Reviewer | Can Approve/Reject |
|---------------|----------|-------------------|
| Employee | TL → PM | Yes |
| TL | PM → SPM | Yes |
| PM | SPM | Yes |
| Senior PM | HOD | Yes |
| EM | HOD | Yes |
| Any | PMO | Monitoring only |
| Any | Dhanshree | Yes (Action Centre) |

## Approval UI Flow
1. Left panel: Scrollable list of timesheets with avatar, name, status pill, week/hours
2. Right panel: Selected timesheet detail with:
   - User info header
   - Daily breakdown table (project × day matrix)
   - Day totals row
   - Approve/Reject buttons (not shown for PMO monitoring)
3. Rejection modal: Requires mandatory reason text

## Business Rules
1. Timesheets are weekly: Monday to Sunday
2. Weekend hours are typically 0 (but allowed)
3. Rejection requires a mandatory reason string
4. PMO can view all timesheets but cannot approve or reject
5. HOD reviews only SPM and EM timesheets
6. SPM/EM review PM timesheets
7. BO has no timesheet approval access
8. Rejected timesheets show rejection reason in red banner
9. Cell comments allow per-day clarification threads

## Future Backend Considerations
- Timesheet submission API with draft auto-save
- Automated overtime calculation
- Leave integration (days off should be reflected)
- Manager delegation (approve on behalf)
- Bulk approval/rejection
- Timesheet locking after approval
- Integration with payroll systems
- Monthly/quarterly aggregation reports

---

## Related Documents
- [[15_Approval_Engine]]
- [[13_Task_Management]]
- [[05_Business_Workflows]]
