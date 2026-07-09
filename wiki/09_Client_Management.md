# Client Management

> **Route Files:** `clients.index.tsx`, `clients.$clientId.tsx`, `customers.tsx`, `customers.$clientId.tsx`  
> **Data Source:** `mock-data.ts` → `clients[]`, `assignments`  
> **Last Updated:** 2026-06-16

---

## Responsibilities
- Client registration and lifecycle management
- Client type classification (NEW / OLD)
- Client-to-role assignment mapping
- Client detail view with associated projects
- Historical PM relationship tracking

## Actors
| Actor | Permissions |
|-------|------------|
| Sales | Create clients, manage contacts |
| HOD | Approve client creation |
| PMO | View all clients, manage assignments |
| SPM/EM | View assigned clients only |
| Dhanshree | Full client management via Customers module |

## Data Model

```typescript
interface Client {
  id: string;          // e.g., "c1"
  name: string;        // e.g., "Northwind Bank"
  industry: string;    // e.g., "Banking"
  logo: string;        // Initials, e.g., "NB"
  contact: string;     // Email
  clientType?: "NEW" | "OLD";
  previousPmIds?: string[];  // PMs who worked with this client before
}
```

## Current Client Registry (10 Clients)

| ID | Name | Industry | Type | Previous PMs |
|----|------|----------|------|-------------|
| c1 | Northwind Bank | Banking | OLD | u3, u4 |
| c2 | Helix Pharma | Healthcare | OLD | u3, u4, u5 |
| c3 | Orbit Retail | Retail | OLD | u3 |
| c4 | Zenith Logistics | Logistics | NEW | — |
| c5 | Lumen Energy | Energy | OLD | u4, u5 |
| c6 | CloudSync AI | Technology | NEW | — |
| c7 | FinTech Global | Finance | OLD | u3, u4 |
| c8 | MediCare Plus | Healthcare | NEW | — |
| c9 | EcoGreen Solutions | Environment | OLD | u5 |
| c10 | AutoDrive Systems | Automotive | OLD | u3, u4, u5 |

## Client Assignment Map

```typescript
assignments: Record<Role, string[]> = {
  senior_pm: ["c1", "c2", "c3"],
  engagement_manager: ["c2", "c4", "c5", "c6"],
  pmo: ["c1"–"c10"],   // All
  hod: ["c1"–"c10"],   // All
  business_owner: ["c1"–"c10"],
  dhanshree: ["c1"–"c10"],
};
```

## Business Rules
1. NEW clients have no `previousPmIds` — first engagement
2. OLD clients maintain PM history for relationship continuity
3. SPM sees only 3 clients; EM sees 4 clients; PMO/HOD/BO/Dhanshree see all 10
4. Each client can have multiple active projects simultaneously
5. Client detail page shows all projects grouped by status

## UI Patterns
- **Client List:** Card grid with industry badges, project count, health indicators
- **Client Detail:** Project table with health/status pills, progress bars
- **Customers (Dhanshree):** Enhanced view with project history, PM history, onboarding status

## Future Backend Considerations
- Client CRUD API with validation
- Client approval workflow (Sales → HOD)
- Client contact management (multiple contacts per client)
- Client SLA and contract management
- Client communication history

---

## Related Documents
- [[10_Project_Management]]
- [[05_Business_Workflows]]
- [[04_Roles_and_Permissions]]
