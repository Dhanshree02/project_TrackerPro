# Resource Management

> **Route Files:** `resources.tsx`, `dh-resources.tsx`  
> **Data Source:** `mock-data.ts`, `dh-store.ts`, `dh-helpers.ts`  
> **Last Updated:** 2026-06-16

---

## Responsibilities
- Resource capacity tracking and utilization monitoring
- PM bucket management (allocation percentage)
- Bench resource tracking
- Employee onboarding and offboarding lifecycle
- Team assignment to projects (project team + shadow team)
- Skill-based resource matching

## Actors
| Actor | Permissions |
|-------|------------|
| PMO | View all resources, manage allocations, PM buckets |
| HOD | Department-wide resource visibility |
| BO | Executive resource overview |
| Dhanshree | Full resource management (onboarding, offboarding, assignments) |
| HR | Onboarding initiation, offboarding processing |

## Data Models

### Person Workload
```typescript
interface PersonWorkload {
  personId: string;
  activeProjects: number;
  utilization: number;       // 0-100%
  availableFrom: string;
  skills: string[];
  onBench: boolean;
}
```

### PM Buckets
```typescript
{ pmId: string; capacity: number; allocated: number }
// Current: u3 → 92/100, u4 → 78/100
```

### Bench Resources
```typescript
benchResourceIds: ["u9", "u10"]  // Dev Patel, Kavya Nair
```

### Onboarded Resources (Dhanshree Store)
```typescript
interface OnboardedResource {
  employeeId: string;
  name: string;
  department: string;
  subDepartment: string;
  joiningDate: string;
  designation: string;
  currentProject?: string;
  status: "Active" | "Probation";
}
```

### Offboarding Resources
```typescript
interface OffboardingResource {
  employeeId: string;
  name: string;
  department: string;
  subDepartment: string;
  resignationDate: string;
  lastWorkingDate?: string;
  resignationStatus: "Pending" | "Accepted" | "Retain";
}
```

### Team Allocation
```typescript
interface TeamAllocation {
  person: Person;
  duration: string;
  billability: "Billable" | "Non-Billable";
  resourceType: "Fixed" | "Adhoc";
}
```

## Current Resource Pool

**Person Workload:**
| Person | Projects | Utilization | Available From | Skills |
|--------|----------|------------|----------------|--------|
| Aarav Mehta (u1) | 4 | 85% | Jun 15 | BFSI, Programme, Cloud |
| Riya Kapoor (u2) | 3 | 70% | May 25 | Healthcare, Retail, Client mgmt |
| Vikram Shah (u3) | 4 | 92% | Jul 1 | Java, Kafka, Banking |
| Sana Iyer (u4) | 3 | 78% | Jun 5 | Pharma, Data, Analytics |

**Onboarded (Recent):**
- EMP-0021: Priya Sharma — Frontend Engineer, Probation
- EMP-0022: Rohan Mehta — QA Engineer, Probation
- EMP-0023: Sneha Iyer — Sr. Software Engineer, Active
- EMP-0024: Karthik Bose — DevOps Engineer, Probation

**Offboarding:**
- EMP-0008: Rahul Sharma — Accepted, LWD Jun 10
- EMP-0012: Anjali Nair — Pending
- EMP-0015: Vivek Tiwari — Retain

## Department Structure (from `dh-helpers.ts`)

| Role | Department | Sub-Department |
|------|-----------|---------------|
| Engineer | Engineering | Backend |
| Designer | Design | Product Design |
| TL | Engineering | Team Leadership |
| PM | Delivery | Project Management |
| Senior PM | Delivery | Senior Management |
| EM | Delivery | Engagement |
| PMO | Operations | PMO |
| HOD | Leadership | Department Head |

## Business Rules
1. PM bucket capacity defaults to 100; allocation increments by ~20% per project
2. On-bench resources get +15% boost in WBS allocation fit scores
3. Shadow team members have separate billability and resource type tracking
4. Offboarding resources must trigger knowledge transfer planning
5. Resignation status flow: `Pending` → `Accepted` or `Retain`
6. Probation resources may be reassigned more flexibly

## Future Backend Considerations
- Real-time utilization calculation from timesheet data
- Skill matrix and competency assessment
- Resource forecasting and demand planning
- Bench analytics and optimization
- Integration with HRMS for payroll and leave management
- Resource conflict detection across projects

---

## Related Documents
- [[11_WBS_Management]]
- [[13_Task_Management]]
- [[03_Organization_Hierarchy]]
