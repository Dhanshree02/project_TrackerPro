# Health and Governance

> **Route File:** `health.tsx`, project detail Health tab, Action Centre  
> **Data Source:** `mock-data.ts` → `issues[]`, `dh-store.ts` → alerts, escalations  
> **Last Updated:** 2026-06-16

---

## Responsibilities
- Issue lifecycle management (raise, discuss, resolve, close)
- Multi-level escalation tracking
- Alert management (system and manual)
- Governance audit trails
- Health status monitoring (project-level and portfolio-level)
- Threaded discussion on issues
- User tagging with notification simulation

## Issue Types
| Type | Code | Description |
|------|------|-------------|
| Scope Change | `scope_change` | Client requests not in original SOW |
| Resource Shortage | `resource_shortage` | Insufficient team capacity |
| Delay | `delay` | Timeline slippage |
| Escalation | `escalation` | Issue requiring management intervention |
| Client Issue | `client_issue` | Problem originating from client side |
| Internal Blocker | `internal_blocker` | Internal process or technical blocker |

## Alert Types (Dhanshree Store)
| Alert Type | Description |
|-----------|-------------|
| Project Risk | Overall project health concern |
| Resource Risk | Resource availability/capacity |
| Technical Issue | Technical problem affecting delivery |
| Dependency Blocker | External dependency stalling progress |
| Escalation | Elevated issue requiring management action |
| Client Concern | Client satisfaction or relationship risk |
| Budget Concern | Cost overrun or budget slippage |
| Schedule Delay | Timeline deviation |
| Quality Concern | Quality metrics below threshold |
| Governance Alert | Compliance or process violation |

## Data Models

### Issue
```typescript
interface Issue {
  id: string;
  clientId: string;
  projectId: string;
  type: IssueType;
  description: string;
  priority: "low" | "medium" | "high" | "critical";
  status: "open" | "in_progress" | "resolved" | "closed";
  raisedById: string;
  raisedByRole: "TL" | "PM" | "Senior PM" | "EM";
  assignedToId: string;
  assignedToRole: "PM" | "Senior PM" | "EM" | "PMO" | "HOD";
  createdAt: string;
  updatedAt: string;
  comments: IssueComment[];
  audit: IssueAuditEntry[];
  resolution?: string;
  taggedUserIds: string[];
}
```

### Alert (Dhanshree)
```typescript
interface DhAlert {
  id: string;
  title: string;
  kind: "Issue" | "Interview Rejected" | "Interview Selected" 
      | "Escalation" | "Approval" | "Dependency";
  projectId?: string;
  priority: "Low" | "Medium" | "High" | "Critical";
  status: "Open" | "In Progress" | "Resolved" | "Closed" | "Acknowledged";
  alertType?: string;  // Project Risk, Resource Risk, etc.
  owner?: string;
  resolutionOwner?: string;
  escalationOwner?: string;
  resolutionDetails?: string;
  attachments?: string[];
  history?: { status, at, updatedBy, details }[];
}
```

## Escalation Chain
```
TL → PM → Senior PM / EM → PMO / HOD
```

## Current Issues (5 entries)

| ID | Project | Type | Priority | Status | Assigned To |
|----|---------|------|----------|--------|-------------|
| i1 | Core Banking | Resource Shortage | High | Open | Senior PM |
| i2 | Clinical Data | Delay | Critical | In Progress | EM |
| i3 | Fleet Tracking | Scope Change | Medium | Open | EM |
| i4 | Mobile Banking | Client Issue | Medium | Resolved | PM |
| i5 | Smart Grid | Internal Blocker | High | Open | EM |

## UI Features
- **Issue List Panel:** Filterable by status (All, Open, In Progress, Resolved, Closed)
- **Issue Detail Panel:** Full discussion thread, status buttons, tagged users, audit history
- **Raise Issue Form:** Client/project selection, type, priority, assignee, description, tag people
- **User Tag Picker:** Search by name/role/email, chip display with remove

## Business Rules
1. Issues can be raised by TL, PM, SPM, or EM
2. Tagged users (CC) receive updates on status changes and comments
3. All status changes and comments recorded in audit trail
4. Escalation text includes notification count for tagged users
5. Resolution text is optional, displayed in green banner when present
6. Footer shows escalation chain: TL → PM → Senior PM / EM → PMO / HOD

## Future Backend Considerations
- Issue CRUD API with real-time updates via WebSocket
- SLA tracking (response time, resolution time)
- Automated escalation on SLA breach
- Issue templates for common problem types
- Integration with external ticketing systems (Jira, ServiceNow)
- Health score calculation algorithm
- Risk assessment and mitigation tracking

---

## Related Documents
- [[10_Project_Management]]
- [[15_Approval_Engine]]
- [[16_Notification_System]]
- [[24_Audit_Logging]]
