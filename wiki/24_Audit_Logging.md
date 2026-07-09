# Audit Logging

> **Status:** ⚠️ Frontend mock (audit arrays on entities), backend not implemented  
> **Last Updated:** 2026-06-16

---

## Current Implementation

Audit trails exist as arrays on frontend entities:

### Issue Audit
```typescript
interface IssueAuditEntry {
  id: string;
  actorId: string;
  action: string;    // "Raised issue", "Acknowledged", "Status → resolved"
  at: string;
}
```

### WBS Allocation Audit
```typescript
interface WbsAllocationAuditEntry {
  id: string;
  actorId: string;
  action: string;    // "WBS received from Sales", "Assigned PM → Name"
  at: string;
}
```

### Allocation History
```typescript
interface AllocationEvent {
  id: string;
  projectId: string;
  action: string;    // "Assigned Senior PM", "Reassigned Project Manager"
  actorId: string;
  fromId?: string;
  toId: string;
  at: string;
}
```

### DH Store Audit Trails
- Issue comments with author, timestamp
- Alert history with status transitions
- Approval history with status, updater, comment
- Prerequisite audit trail (collection/validation status changes)
- Project stage history (status transitions with previous/new)
- Timesheet history (status transitions)
- Interview history (status changes)
- Requirements history (status changes)

## Planned Backend Audit System

### Centralized Audit Log Table
```sql
CREATE TABLE audit_log (
  id UUID PRIMARY KEY,
  entity_type VARCHAR(50),     -- 'project', 'issue', 'timesheet', etc.
  entity_id UUID,
  actor_id UUID,
  action VARCHAR(255),
  old_value JSONB,
  new_value JSONB,
  metadata JSONB,              -- IP, user agent, etc.
  created_at TIMESTAMPTZ
);
```

### Tracked Events
- Entity CRUD operations
- Status transitions
- Assignment changes
- Approval decisions
- Login/logout events
- Permission changes
- Configuration changes

---

## Related Documents
- [[23_Security_and_RBAC]]
- [[17_Health_and_Governance]]
- [[22_Backend_Architecture_Draft]]
