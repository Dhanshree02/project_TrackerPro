# API Design Draft

> **Status:** 🔲 Not yet implemented  
> **Framework:** FastAPI  
> **Last Updated:** 2026-06-16

---

## API Conventions
- Base URL: `/api/v1/`
- Authentication: Bearer JWT in `Authorization` header
- Response format: `{ data, meta, errors }`
- Pagination: `?page=1&per_page=20`
- Sorting: `?sort=name&order=asc`
- Filtering: `?status=ongoing&health=red`

---

## Endpoints

### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/login` | Login with credentials |
| POST | `/auth/refresh` | Refresh JWT token |
| GET | `/auth/me` | Current user profile |

### Clients
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/clients` | List clients (filtered by role) |
| GET | `/clients/{id}` | Client detail |
| POST | `/clients` | Create client (Sales) |
| PUT | `/clients/{id}` | Update client |
| GET | `/clients/{id}/projects` | Projects for client |

### Projects
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/projects` | List projects (filtered by role) |
| GET | `/projects/{id}` | Project detail with WBS, tasks, team |
| POST | `/projects` | Create project |
| PUT | `/projects/{id}` | Update project |
| GET | `/projects/{id}/tasks` | Tasks for project |
| GET | `/projects/{id}/team` | Team members |
| GET | `/projects/{id}/invoices` | Invoices for project |
| GET | `/projects/{id}/issues` | Issues for project |
| GET | `/projects/{id}/stages` | Stage tracker data |
| GET | `/projects/{id}/prerequisites` | Prerequisite status |
| PUT | `/projects/{id}/prerequisites` | Update prerequisites |

### Tasks
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/tasks` | List tasks (filtered) |
| POST | `/tasks` | Create task |
| PUT | `/tasks/{id}` | Update task |
| PUT | `/tasks/{id}/assign` | Assign/reassign |

### Timesheets
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/timesheets` | List timesheets (filtered by scope) |
| GET | `/timesheets/{id}` | Timesheet detail |
| POST | `/timesheets` | Create timesheet |
| PUT | `/timesheets/{id}` | Update draft |
| POST | `/timesheets/{id}/submit` | Submit for approval |
| POST | `/timesheets/{id}/approve` | Approve |
| POST | `/timesheets/{id}/reject` | Reject (with reason) |

### Issues
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/issues` | List issues (filtered) |
| GET | `/issues/{id}` | Issue detail with comments |
| POST | `/issues` | Raise issue |
| PUT | `/issues/{id}/status` | Change status |
| POST | `/issues/{id}/comments` | Add comment |
| PUT | `/issues/{id}/tags` | Update tagged users |

### Invoices
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/invoices` | List invoices |
| POST | `/invoices/{id}/raise` | Raise invoice |
| PUT | `/invoices/{id}/payment` | Update payment status |

### WBS Allocation
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/wbs-requests` | List WBS requests |
| GET | `/wbs-requests/{id}` | WBS request detail |
| POST | `/wbs-requests/{id}/assign` | Assign role |
| POST | `/wbs-requests/{id}/activate` | Activate project |

### Approvals
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/approvals` | List approval requests |
| PUT | `/approvals/{id}` | Update status |
| POST | `/approvals/{id}/comments` | Add comment |

### Resources
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/resources` | List all resources |
| GET | `/resources/workload` | Workload & utilization |
| GET | `/resources/bench` | Bench resources |
| GET | `/resources/onboarded` | Recent onboarding |
| GET | `/resources/offboarding` | Offboarding tracking |

### Notifications
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/notifications` | User's notifications |
| PUT | `/notifications/{id}/read` | Mark as read |
| PUT | `/notifications/read-all` | Mark all read |

---

## Related Documents
- [[20_Database_Design_Draft]]
- [[22_Backend_Architecture_Draft]]
- [[23_Security_and_RBAC]]
