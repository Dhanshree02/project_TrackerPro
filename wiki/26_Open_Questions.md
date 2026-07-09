# Open Questions

> **Last Updated:** 2026-06-16  
> **Status:** Living document — update as questions are resolved

---

## Architecture Questions

### AQ-1: Backend Hosting Strategy
**Question:** Should the backend be deployed to the same Cloudflare Workers infrastructure, or use a separate cloud (AWS/GCP/Azure)?
**Impact:** Determines database choice, deployment pipeline, and latency characteristics
**Status:** ❓ Unresolved

### AQ-2: Database Hosting
**Question:** Managed PostgreSQL service selection — Neon, Supabase, RDS, Cloud SQL, or self-hosted?
**Impact:** Cost, scaling, maintenance burden
**Status:** ❓ Unresolved

### AQ-3: Real-Time vs Polling
**Question:** Should issue comments, notifications, and status updates use WebSocket/SSE or polling?
**Impact:** Architecture complexity, user experience, infrastructure cost
**Status:** ❓ Unresolved

### AQ-4: File Upload Strategy
**Question:** How should document uploads (prerequisites, attachments) be handled? S3? Cloudflare R2?
**Impact:** Storage architecture, cost, CDN strategy
**Status:** ❓ Unresolved

---

## Business Logic Questions

### BQ-1: Multi-Role Users
**Question:** Can a single user have multiple roles simultaneously (e.g., PM and TL)?
**Impact:** RBAC model complexity
**Status:** ❓ Unresolved — current mock data assigns one role per user

### BQ-2: Approval Delegation
**Question:** Can a manager delegate approval authority to a peer or subordinate?
**Impact:** Approval engine design
**Status:** ❓ Unresolved

### BQ-3: Cross-Client Resources
**Question:** Can the same resource be assigned to projects across multiple clients?
**Impact:** Utilization calculation, conflict detection
**Status:** ❓ Unresolved — current data suggests yes (u5 assigned to multiple clients)

### BQ-4: Historical Data Retention
**Question:** How long should audit logs, timesheet history, and issue histories be retained?
**Impact:** Database size, compliance requirements
**Status:** ❓ Unresolved

### BQ-5: Dhanshree Role Permanence
**Question:** Is the "Dhanshree" role a permanent super-admin, or should it be generalized to "Delivery Operations Manager"?
**Impact:** RBAC design, role naming
**Status:** ❓ Unresolved

---

## Frontend Questions

### FQ-1: Mobile App
**Question:** Is a dedicated mobile app planned, or is responsive web sufficient?
**Impact:** Tech stack decisions, development timeline
**Status:** ❓ Unresolved

### FQ-2: Offline Support
**Question:** Should timesheets and task updates support offline entry with sync?
**Impact:** Service worker implementation, conflict resolution strategy
**Status:** ❓ Unresolved

---

## Related Documents
- [[28_Development_Roadmap]]
- [[00_Project_Overview]]
