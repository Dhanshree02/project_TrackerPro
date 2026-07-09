# Frontend Architecture

> **Last Updated:** 2026-06-16  
> **Stack:** React 19, TypeScript, TanStack Start/Router, React Query, Tailwind CSS v4, shadcn/ui

---

## Technology Stack

| Technology | Version | Purpose |
|-----------|---------|---------|
| React | 19.2.0 | UI framework |
| TypeScript | 5.8.3 | Type safety |
| TanStack Router | 1.168.25 | File-based routing |
| TanStack Start | 1.167.50 | SSR framework |
| React Query | 5.83.0 | Server state management (ready for API) |
| Tailwind CSS | 4.2.1 | Utility-first styling |
| shadcn/ui | Latest | Accessible UI components |
| Recharts | 2.15.4 | Data visualization |
| React Hook Form | 7.71.2 | Form management |
| Zod | 3.24.2 | Schema validation |
| Sonner | 2.0.7 | Toast notifications |
| Lucide React | 0.575.0 | Icon library |
| date-fns | 4.1.0 | Date utilities |
| Vite | 7.3.1 | Build tool |
| cmdk | 1.1.1 | Command palette |

---

## State Management Architecture

### 1. RoleContext (`role-context.tsx`)

A React Context providing the current simulated role. This replaces what will become JWT-based authentication.

**Shape:**
```typescript
interface RoleContextValue {
  role: Role;                    // Current role key
  setRole: (r: Role) => void;   // Role switcher
  user: Person;                 // Current user object
  isPMO: boolean;               // Role flags
  isHOD: boolean;
  isBO: boolean;
  isDhanshree: boolean;
  assignedClientIds: string[];  // Filtered data
  assignedClients: Client[];
  assignedProjects: Project[];
  assignedIssues: Issue[];
  pendingTimesheets: Timesheet[];
}
```

**Role → User mapping:**
```typescript
const userByRole: Record<Role, string> = {
  senior_pm: "u1",
  engagement_manager: "u2",
  pmo: "u11",
  hod: "u12",
  business_owner: "u13",
  dhanshree: "u14",
};
```

### 2. DhStore (`dh-store.ts`)

A singleton store using `useSyncExternalStore` for Dhanshree-specific workflows. This is the most complex state module at ~2141 lines / 80KB.

**State shape:**
```typescript
interface DhState {
  extraClients: Client[];
  extraProjects: Project[];
  issues: DhIssue[];
  alerts: DhAlert[];
  escalations: DhEscalation[];
  appreciations: DhAppreciation[];
  interviews: DhInterview[];
  requirements: DhAdditionalRequirement[];
  prereqs: Record<string, DhProjectPrereq>;
  projectStages: Record<string, ProjectStagesTracker>;
  taskAssignments: Record<string, TaskAssignmentState>;
  shadowTeams: Record<string, string[]>;
  shadowTeamDetails: Record<string, Record<string, {...}>>;
  timesheets: DhTimesheet[];
  approvals: DhCentralApproval[];
  onboardedResources: OnboardedResource[];
  offboardingResources: OffboardingResource[];
  exitedResources: ExitedResource[];
  invoices: DhInvoice[];
}
```

**Pattern:** All mutations go through `dhStore.methodName()` which calls `emit()` to trigger re-renders.

### 3. Component-Local State

Most route components manage form state, filter state, and UI state using `useState`. Examples:
- `wbs-allocation.tsx`: WBS requests array, selected ID, status filter
- `health.tsx`: Issues state, selected issue, reply text
- `approvals.tsx`: Timesheet state, selected ID, rejection dialog

---

## Routing Architecture

### Route Tree (auto-generated in `routeTree.gen.ts`)

| Route | File | Description |
|-------|------|-------------|
| `/` | `index.tsx` | Dashboard |
| `/clients` | `clients.index.tsx` | Client list |
| `/clients/:clientId` | `clients.$clientId.tsx` | Client detail |
| `/projects` | `projects.index.tsx` | Project list (Dhanshree) |
| `/projects/new` | `projects.new.tsx` | New project form |
| `/projects/:projectId` | `projects.$projectId.tsx` | Project detail |
| `/portfolio` | `portfolio.tsx` | Portfolio view |
| `/wbs-allocation` | `wbs-allocation.tsx` | WBS allocation (PMO) |
| `/resources` | `resources.tsx` | Resource directory |
| `/health` | `health.tsx` | Health & governance |
| `/approvals` | `approvals.tsx` | Timesheet approvals |
| `/reports` | `reports.tsx` | Analytics |
| `/timesheet` | `timesheet.tsx` | Timesheet entry |
| `/allocation` | `allocation.tsx` | Allocation view |
| `/action-centre` | `action-centre.tsx` | Action centre (Dhanshree) |
| `/customers` | `customers.tsx` | Customer list (Dhanshree) |
| `/customers/:clientId` | `customers.$clientId.tsx` | Customer detail |
| `/dh-reports` | `dh-reports.tsx` | Reports (Dhanshree) |
| `/dh-resources` | `dh-resources.tsx` | Resources (Dhanshree) |

### Route Guards
- WBS Allocation: `if (!isPMO) return <Navigate to="/" />`
- Other routes: No guards (any role can access any URL)

---

## Data Flow

### Current (Mock Data)
```
mock-data.ts → RoleContext.filter() → Component → UI
dh-store.ts → useDhStore() → Component → UI
Component.setState() → dh-store.ts → emit() → Re-render
```

### Planned (With Backend)
```
Component → React Query → fetch() → FastAPI → PostgreSQL
              ↓ cache                    ↓ response
           Component → UI          JWT + RBAC check
```

---

## Build & Deployment

- **Dev server:** `npm run dev` from `apps/frontend/` (configured for port 6002)
- **Build:** `npm run build` from `apps/frontend/` (outputs to `apps/frontend/dist/`)
- **Preview:** `npm run preview` from `apps/frontend/`
- **Deploy target:** Cloudflare Workers (via `@cloudflare/vite-plugin` and `apps/frontend/wrangler.jsonc`)

---

## Key Patterns

### 1. Conditional Rendering by Role
```typescript
const items = isDhanshree
  ? [dhActionCentre, dhProjects, ...]
  : isBO
    ? [portfolioItem, clientsItem, ...]
    : isPMO
      ? [clientsItem, wbsItem, ...]
      : [clientsItem, healthItem, ...];
```

### 2. Filter-then-Render
```typescript
const filtered = requests.filter((r) => {
  if (statusFilter !== "all" && r.status !== statusFilter) return false;
  if (search) { /* fuzzy match */ }
  return true;
});
```

### 3. Optimistic UI Updates
```typescript
function approve() {
  setTs((prev) => prev.map((t) =>
    t.id === selected.id ? { ...t, status: "approved" } : t
  ));
}
```

---

## Related Documents

- [[01_System_Architecture]]
- [[06_UI_Architecture]]
- [[08_Module_Analysis]]
- [[29_Known_Frontend_Behavior]]
