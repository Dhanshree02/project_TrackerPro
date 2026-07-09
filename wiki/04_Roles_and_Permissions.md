# Roles and Permissions

> **Last Updated:** 2026-06-16  
> **Source:** `role-context.tsx`, `app-sidebar.tsx`, `mock-data.ts`

---

## Role Definitions

### Senior Project Manager (`senior_pm`)
- **User:** Aarav Mehta (u1)
- **Scope:** Assigned clients only (c1, c2, c3)
- **Sidebar:** Dashboard, Clients & Projects, Health & Governance, Approvals
- **Capabilities:**
  - View assigned clients and their projects
  - Review and approve PM timesheets
  - Raise and manage issues (escalation target from PM)
  - Track project health, budget burn, team allocation
  - View invoice status
- **Footer Label:** "Read-only tracking"

### Engagement Manager (`engagement_manager`)
- **User:** Riya Kapoor (u2)
- **Scope:** Assigned clients only (c2, c4, c5, c6)
- **Sidebar:** Dashboard, Clients & Projects, Health & Governance, Approvals
- **Capabilities:**
  - Manage client relationships
  - Handle escalations from PM level
  - Participate in issue resolution
  - Review PM timesheets
  - Coordinate with Sales on scope changes

### PMO (`pmo`)
- **User:** Rahul Gupta (u11)
- **Scope:** All clients (c1–c10) — global visibility
- **Sidebar:** Dashboard, Clients & Projects, WBS Allocation, Resources, Health & Governance, Approvals
- **Capabilities:**
  - **WBS Allocation:** Receive WBS from Sales, allocate SPM/EM/PM using smart suggestions
  - **Resource monitoring:** View PM buckets, bench resources
  - **Timesheet monitoring:** View all timesheets (monitoring only — cannot approve/reject)
  - **Governance:** Full visibility into all issues, alerts, escalations
  - **Allocation history:** Track all assignment changes
- **Footer Label:** "Governance + allocation"

### HOD (`hod`)
- **User:** Anita Desai (u12)
- **Scope:** All clients (c1–c10) — global visibility
- **Sidebar:** Dashboard, Portfolio, Resources, Health & Governance, Approvals, Reports
- **Capabilities:**
  - **Portfolio view:** Cross-client, cross-project oversight
  - **Approvals:** Review SPM and EM timesheets
  - **Resources:** Department-wide resource visibility
  - **Strategic decisions:** Budget approvals, timeline extensions
- **Footer Label:** "Department oversight"

### Business Owner (`business_owner`)
- **User:** Vikrant Malhotra (u13)
- **Scope:** All clients (c1–c10) — global visibility
- **Sidebar:** Dashboard, Portfolio, Clients & Projects, Resources, Health & Governance, Reports
- **Capabilities:**
  - **Executive dashboard:** KPIs, invoice status, PM buckets, bench resources
  - **Portfolio view:** Strategic oversight
  - **Open escalations:** Review strategic issues
  - **No timesheet approval:** BO does not approve timesheets
- **Footer Label:** "Executive oversight"

### Dhanshree (`dhanshree`)
- **User:** Dhanshree (u14)
- **Scope:** All clients (c1–c10) — super-admin view
- **Sidebar:** Dashboard, Action Centre, Projects, Reports, Resources, Customers
- **Capabilities:**
  - **Action Centre:** Central hub for issues, alerts, escalations, appreciations, interviews, approvals, timesheets
  - **Project management:** Full CRUD, stage tracker, prerequisites, invoices
  - **Resource management:** Onboarding, offboarding, exited tracking, task assignment
  - **Customer management:** Client detail views, project history
  - **Invoice management:** Raise invoices, track payment status
  - **Extension requests:** Submit timeline extension approvals
- **Footer Label:** "Workspace"

---

## Permission Matrix

### Module Access

| Module | SPM | EM | PMO | HOD | BO | Dhanshree |
|--------|-----|-----|-----|-----|-----|-----------|
| Dashboard | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Clients & Projects | ✅ | ✅ | ✅ | — | ✅ | — |
| Portfolio | — | — | — | ✅ | ✅ | — |
| WBS Allocation | — | — | ✅ | — | — | — |
| Resources | — | — | ✅ | ✅ | ✅ | ✅* |
| Health & Governance | ✅ | ✅ | ✅ | ✅ | ✅ | — |
| Approvals | ✅ | ✅ | ✅ | ✅ | — | — |
| Reports | — | — | — | ✅ | ✅ | ✅* |
| Action Centre | — | — | — | — | — | ✅ |
| Projects (CRUD) | — | — | — | — | — | ✅ |
| Customers | — | — | — | — | — | ✅ |

*Dhanshree has role-specific variants of Resources and Reports modules.

### Data Scope

| Role | Client Visibility | Project Visibility |
|------|-------------------|-------------------|
| SPM | Assigned only (3 clients) | Projects under assigned clients |
| EM | Assigned only (4 clients) | Projects under assigned clients |
| PMO | All (10 clients) | All projects |
| HOD | All (10 clients) | All projects |
| BO | All (10 clients) | All projects |
| Dhanshree | All (10 clients) | All projects |

### Timesheet Approval Scope

| Reviewer Role | Can Review | Can Approve/Reject |
|--------------|-----------|-------------------|
| SPM | PM timesheets | ✅ Yes |
| EM | PM timesheets | ✅ Yes |
| PMO | All timesheets | ❌ Monitoring only |
| HOD | SPM + EM timesheets | ✅ Yes |
| BO | — | ❌ No timesheet access |
| Dhanshree | All timesheets | ✅ Yes (via Action Centre) |

---

## Future RBAC Considerations

When the backend is implemented:
- Roles should be stored in a `roles` table with granular permissions
- Use JWT claims to carry role information
- Implement middleware guards on API endpoints
- Consider attribute-based access control (ABAC) for complex rules
- Support multi-role assignment per user

See [[23_Security_and_RBAC]] for detailed security architecture.

---

## Related Documents

- [[03_Organization_Hierarchy]]
- [[23_Security_and_RBAC]]
- [[15_Approval_Engine]]
- [[05_Business_Workflows]]
