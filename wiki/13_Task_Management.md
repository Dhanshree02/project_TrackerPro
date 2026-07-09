# Task Management

> **Source:** Project detail Tasks tab, `mock-data.ts` → `Task[]`, `dh-helpers.ts`  
> **Last Updated:** 2026-06-16

---

## Responsibilities
- Task creation, assignment, and tracking within projects
- Status progression management
- Multi-assignee support (Dhanshree view)
- Task code generation and metadata tracking
- Hours estimation vs actual tracking

## Data Model
```typescript
interface Task {
  id: string;          // "p1-t1"
  title: string;       // "Requirements gathering"
  status: TaskStatus;  // "todo" | "in_progress" | "review" | "done"
  assigneeId: string;
  dueDate: string;
  progress: number;    // 0-100
}
```

### Extended Task Metadata (Dhanshree)
```typescript
interface DhTaskMeta {
  taskCode: string;      // "P1-TSK-001"
  startDate: string;
  estHours: number;      // 52, 64, 76...
  actualHours: number;   // Calculated from progress
  assigneeIds: string[]; // Multi-assignee
}
```

### Dhanshree Task Statuses
```
Ongoing | Completed | On Hold Internally | On Hold Client | After Release
```

Mapping from base statuses: `done` → Completed, `todo` → On Hold Internally, others → Ongoing

## Standard Task Template (per project)
Every project generates 6 tasks via `mkTasks()`:
1. Requirements gathering (done)
2. Architecture design (done)
3. API implementation (in_progress, 65%)
4. Frontend integration (in_progress, 40%)
5. QA & UAT (review, 20%)
6. Deployment (todo, 0%)

## Business Rules
1. Tasks belong to exactly one project
2. Each task has one primary assignee (`assigneeId`)
3. Dhanshree view supports secondary assignees from project team
4. Task codes follow pattern: `{PROJECT_ID}-TSK-{SEQUENTIAL}`
5. Estimated hours increase linearly per task index: `40 + (index + 1) × 12`
6. Actual hours = `estHours × (progress / 100)`

## Future Backend Considerations
- Task CRUD API with real-time updates
- Task dependencies and blocking relationships
- Sprint/iteration management
- Time logging against tasks (integration with timesheets)
- Kanban board with drag-and-drop
- Task templates per project type
- Automated task generation from WBS phases

---

## Related Documents
- [[10_Project_Management]]
- [[14_Timesheet_Management]]
- [[12_Resource_Management]]
