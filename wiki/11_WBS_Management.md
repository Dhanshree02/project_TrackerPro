# WBS Management

> **Route File:** `wbs-allocation.tsx`, project detail WBS tab  
> **Data Source:** `mock-data.ts` → `wbsRequests[]`, `WBSNode`, `WBSDetails`  
> **Last Updated:** 2026-06-16

---

## Responsibilities
- Receive WBS intake from Sales team
- Review scope, modules, deliverables, skill requirements
- Allocate Senior PM, Engagement Manager, and Project Manager
- Track allocation status through lifecycle
- Manage prerequisite collection and validation per service
- Activate projects from WBS allocation

## Actors
| Actor | Permissions |
|-------|------------|
| Sales | Create and submit WBS |
| PMO | Review WBS, allocate roles, activate projects |
| SPM/EM/PM | Receive assignments, acknowledge |

## Data Models

### WBS Request (Allocation Intake)
```typescript
interface WbsRequest {
  id: string;
  code: string;               // "WBS-2026-014"
  clientId: string;
  projectName: string;
  scope: string;
  modules: string[];
  deliverables: string[];
  complexity: "Low" | "Medium" | "High";
  teamSize: number;
  requiredRoles: AllocationRoleSlot[];   // ["spm", "em", "pm"]
  skillNeeds: string[];
  timelineStart: string;
  timelineEnd: string;
  resourceCount: number;
  estBudget: number;
  receivedFrom: string;        // "Sales · Karan Bhatia"
  receivedAt: string;
  status: WbsRequestStatus;
  slots: WbsAllocationSlot[];
  audit: WbsAllocationAuditEntry[];
}
```

### WBS Status Flow
```
new → under_allocation → assigned → active → closed
```

### WBS Node (Project Structure)
```typescript
interface WBSNode {
  id: string;
  name: string;
  progress: number;
  children?: WBSNode[];
}
```

### WBS Service Detail
```typescript
interface WbsService {
  id: string;
  department: string;
  serviceName: string;
  qty: number;
  description: string;
  frequency: string;
  location: string;
  serviceModel: string;
  deliveryModel: string;
  finalDeliveryFormat: string;
  billingModel: string;
  tools: string;
  startDate: string;
  endDate: string;
  duration: number;
  unitPrice: number;
  total: number;
}
```

## Current WBS Requests (5 entries)

| Code | Client | Project | Complexity | Status | Budget |
|------|--------|---------|-----------|--------|--------|
| WBS-2026-014 | Northwind Bank | Open Banking API Gateway | High | new | $1.45M |
| WBS-2026-013 | Helix Pharma | Patient Engagement Mobile | Medium | under_allocation | $720K |
| WBS-2026-012 | Orbit Retail | Loyalty Program Revamp | Medium | assigned | $540K |
| WBS-2026-011 | Zenith Logistics | Last-Mile Routing AI | High | active | $980K |
| WBS-2026-009 | Lumen Energy | Grid Outage Predictor | Low | closed | $410K |

## Smart Suggestion Algorithm

The fit score algorithm matches candidates to WBS requirements:

```
fitScore(personId, wbsRequest) → 0-100%

Components:
1. Skill Score (60% weight): matchedSkills / requiredSkills × 60
2. Utilization Score (40% weight): max(0, 40 - (utilization - 60) × 0.8)
3. Bench Boost: +15% if person is on bench

Final = min(100, skillScore + utilizationScore + benchBoost)
```

## Prerequisite Tracking

Per-service prerequisite status:
```typescript
interface DhServicePrereq {
  serviceId: string;
  serviceName: string;
  collectionStatus: "Pending To Collect" | "Collected";
  validationStatus: "Pending To Validate" | "Validated";
}
```

**Readiness check:** Project is ready to start when:
- All services collected AND validated
- PM assigned AND acknowledged
- SPM assigned AND acknowledged

## Business Rules
1. Only PMO role can access WBS Allocation page
2. WBS transitions: first assignment moves from `new` → `under_allocation`
3. All required slots filled → status → `assigned`
4. Confirmation → creates real project, updates PM bucket, records allocation history
5. Allocation changes are tracked in audit trail with actor, action, timestamp
6. Active/closed WBS allow reassignment with audit logging

## Future Backend Considerations
- WBS CRUD API with Sales submission workflow
- Automated skill matching with ML-based suggestions
- Real-time capacity impact preview before assignment
- Integration with HR system for skill profiles
- WBS template library for common project types

---

## Related Documents
- [[10_Project_Management]]
- [[12_Resource_Management]]
- [[05_Business_Workflows]]
