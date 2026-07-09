# UI Architecture

> **Last Updated:** 2026-06-16  
> **Source:** Route files, component files, styles.css

---

## Layout System

### AppShell Pattern
All pages use `AppShell` (`components/app-shell.tsx`) which wraps content with:
- `AppSidebar` — Role-aware left navigation (hidden on mobile)
- `AppTopbar` — Header with title, search, role switcher, notifications, user avatar
- `MobileTabs` — Bottom tab navigation on mobile
- Content area — Scrollable main content

### Responsive Design
- **Desktop (≥768px):** Sidebar (240px) + Content area
- **Mobile (<768px):** Full-width content + bottom tabs
- **Large screens (≥1024px):** Multi-column grid layouts

### Navigation Architecture

**Standard Roles (SPM, EM):**
| Item | Route | Icon |
|------|-------|------|
| Dashboard | `/` | LayoutDashboard |
| Clients & Projects | `/clients` | Briefcase |
| Health & Governance | `/health` | Activity |
| Approvals | `/approvals` | CheckCircle2 |

**PMO Role:**
| Item | Route | Icon |
|------|-------|------|
| Dashboard | `/` | LayoutDashboard |
| Clients & Projects | `/clients` | Briefcase |
| WBS Allocation | `/wbs-allocation` | Inbox |
| Resources | `/resources` | Users |
| Health & Governance | `/health` | Activity |
| Approvals | `/approvals` | CheckCircle2 |

**HOD Role:**
| Item | Route | Icon |
|------|-------|------|
| Dashboard | `/` | LayoutDashboard |
| Portfolio | `/portfolio` | Layers |
| Resources | `/resources` | Users |
| Health & Governance | `/health` | Activity |
| Approvals | `/approvals` | CheckCircle2 |
| Reports | `/reports` | BarChart3 |

**Business Owner Role:**
| Item | Route | Icon |
|------|-------|------|
| Dashboard | `/` | LayoutDashboard |
| Portfolio | `/portfolio` | Layers |
| Clients & Projects | `/clients` | Briefcase |
| Resources | `/resources` | Users |
| Health & Governance | `/health` | Activity |
| Reports | `/reports` | BarChart3 |

**Dhanshree Role:**
| Item | Route | Icon |
|------|-------|------|
| Dashboard | `/` | LayoutDashboard |
| Action Centre | `/action-centre` | ListChecks |
| Projects | `/projects` | FolderKanban |
| Reports | `/dh-reports` | BarChart3 |
| Resources | `/dh-resources` | Users |
| Customers | `/customers` | Building2 |

---

## Page Layout Patterns

### Master-Detail Pattern
Used by: Approvals, Health & Governance, WBS Allocation, Action Centre
```
┌──────────────────────────────────┐
│ Topbar                           │
├────────┬─────────────────────────┤
│ List   │ Detail Panel            │
│ Panel  │                         │
│ (340px)│                         │
│        │                         │
└────────┴─────────────────────────┘
```

### Dashboard KPI Grid
Used by: Dashboard (`index.tsx`)
```
┌──────┬──────┬──────┬──────┐
│ Stat │ Stat │ Stat │ Stat │  ← 4-column grid
├──────┴──────┴──────┴──────┤
│ Executive Panels (PMO/BO) │  ← 3-column grid (conditional)
├──────────────┬────────────┤
│ Project List │ Issues     │  ← 2:1 grid
├──────────────┴────────────┤
│ Status Mix │ Approvals    │  ← 2-column grid
└───────────────────────────┘
```

### Tabbed Detail View
Used by: Project Detail (`projects.$projectId.tsx`)
```
┌───────────────────────────────┐
│ Breadcrumb                    │
├───────────────────────────────┤
│ Stage Tracker (Dhanshree only)│
├───────────────────────────────┤
│ Health + Status + Progress    │
├────┬────┬────┬────┬────┬─────┤
│ OV │WBS │Task│Team│Hlth│ Inv │  ← Tab bar
├────┴────┴────┴────┴────┴─────┤
│ Tab Content                   │
└───────────────────────────────┘
```

---

## Component Library

### Status Indicators (`pills.tsx`)
- `HealthPill` — Green/Amber/Red health status
- `StatusPill` — Ongoing/Completed/On Hold project status
- `PriorityPill` — Low/Medium/High/Critical issue priority
- `IssueStatusPill` — Open/In Progress/Resolved/Closed
- `TimesheetStatusPill` — Draft/Submitted/Approved/Rejected
- `TaskStatusPill` — To Do/In Progress/Review/Done
- `ProgressBar` — Percentage progress bar with color coding
- `Avatar` — Initials-based avatar with size variants

### Stage Tracker (`stage-tracker.tsx`)
Visual horizontal pipeline showing Sales → PMO → Delivery → Accounts with:
- Circle icons (completed/active/pending)
- Status badges with color coding
- Sub-status text
- Expandable history view per stage

---

## Design System

### Color Tokens (CSS Variables)
From `styles.css`:
- Background/Foreground: `--background`, `--foreground`
- Card: `--card`, `--card-foreground`
- Primary: `--primary`, `--primary-foreground`
- Accent: `--accent`, `--accent-foreground`
- Destructive: `--destructive`
- Success: `--success`, `--success-foreground`
- Warning: `--warning`, `--warning-foreground`
- Info: `--info`
- Sidebar: `--sidebar`, `--sidebar-foreground`, `--sidebar-accent`

### Typography
- Font: System font stack (no custom web fonts loaded)
- Sizes: `text-[10px]`, `text-[11px]`, `text-xs`, `text-sm`, `text-base`, `text-lg`, `text-2xl`, `text-7xl`

### Spacing
- Card padding: `p-4`, `p-5`
- Section gaps: `gap-3`, `gap-4`, `gap-6`
- Rounded corners: `rounded-md`, `rounded-lg`, `rounded-xl`

---

## Related Documents

- [[07_Frontend_Architecture]]
- [[08_Module_Analysis]]
