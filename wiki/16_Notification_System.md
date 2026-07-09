# Notification System

> **Status:** 🔲 Not yet implemented  
> **Last Updated:** 2026-06-16

---

## Responsibilities
- Real-time in-app notifications
- Email notification delivery
- Push notifications (future mobile)
- Notification preferences management
- Read/unread tracking

## Current State

The frontend has a **notification bell icon** in `app-topbar.tsx` that shows a badge count:
```typescript
const notifCount = assignedIssues.filter((i) => i.status === "open").length 
                 + pendingTimesheets.length;
```

This is purely visual — no notification system exists. Clicking the bell does nothing.

## Planned Notification Events

| Event | Recipients | Channel |
|-------|-----------|---------|
| Issue raised | Assigned role, tagged users | In-app, Email |
| Issue status change | Raiser, assignee, tagged users | In-app |
| Issue comment | Thread participants | In-app |
| Timesheet submitted | Approver | In-app, Email |
| Timesheet approved/rejected | Submitter | In-app, Email |
| WBS received from Sales | PMO | In-app, Email |
| Resource allocation | Allocated person | In-app, Email |
| Project activated | SPM, EM, PM | In-app, Email |
| Invoice overdue | Accounts, PM | In-app, Email |
| Budget threshold exceeded | PM, SPM, PMO | In-app |
| Prerequisite status change | PM, PMO | In-app |
| Extension request submitted | Tagged approvers | In-app, Email |
| Approval request created | Approver chain | In-app, Email |

## Future Backend Design

### Notification Service Architecture
```
Event Producer → Message Queue → Notification Service → Delivery
                                      ↓
                              ┌───────┴───────┐
                              │               │
                          In-App DB      Email Service
                          (PostgreSQL)   (SendGrid/SES)
```

### Data Model (Draft)
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  type VARCHAR(50),
  title TEXT,
  body TEXT,
  data JSONB,          -- Payload with entity IDs
  read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Related Documents
- [[15_Approval_Engine]]
- [[17_Health_and_Governance]]
- [[22_Backend_Architecture_Draft]]
