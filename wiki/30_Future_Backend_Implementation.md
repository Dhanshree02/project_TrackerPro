# Future Backend Implementation

> **Status:** Planning phase  
> **Last Updated:** 2026-06-16

---

## Migration Strategy

### Approach: Incremental Module Migration

Rather than a "big bang" replacement, migrate modules one at a time:

1. **Auth module first** — establishes JWT infrastructure
2. **Users/People** — seed from `mock-data.ts` people array
3. **Clients** — replace `clients[]` import with API call
4. **Projects** — replace `projects[]` import with API call
5. **Continue per module** — tasks, timesheets, issues, invoices, etc.

### Frontend Migration Pattern

**Before (mock data):**
```typescript
import { clients } from "@/lib/mock-data";
// Direct array access
```

**After (API-backed):**
```typescript
const { data: clients } = useQuery({
  queryKey: ["clients"],
  queryFn: () => fetch("/api/v1/clients").then(r => r.json()),
});
```

### Data Seeding
The `mock-data.ts` file should be used to generate database seed scripts:
- Extract all 14 `people` → `users` table
- Extract all 10 `clients` → `clients` table
- Extract all 43 `projects` → `projects` table
- Extract all tasks, timesheets, invoices, issues

---

## Backend Quick Start (.NET)

```bash
# 1. Start PostgreSQL (local install or docker compose up -d)
# 2. Set the connection string (see apps/backend/README.md — appsettings.json or user-secrets)

cd apps/backend
# 3. Create the initial migration
dotnet ef migrations add InitialIdentity --project PMS.API.csproj

# 4. Apply migration (creates the trackerpro database if it does not exist)
dotnet ef database update --project PMS.API.csproj

# 5. Run server
dotnet run --project PMS.API.csproj
```

---

## PMO Project Allocation & Client Engagement Manager Auto-Resolution

### Business Requirement
In employee onboarding and profile management (PMO Section):
- When an employee is assigned to a `Project Allocated`:
  1. The selected project maps to its owning Customer (`projects.client_id` → `clients.id`).
  2. The customer defines the assigned Engagement Manager (`clients.engagement_manager_id` or `projects.engagement_manager_id`).
  3. `Client Engagement Manager` is automatically resolved and populated for that employee profile.

### Pending Database Generation
- The backend tables/relations for `projects` (with `client_id`) and relational engagement manager mapping are not yet generated in PostgreSQL.
- **Frontend Fallback**: Currently implemented as frontend dummy auto-mapping (`dh-employee-directory.index.tsx`) deriving EM from mock `allProjects()` and `allClients()`.
- **Action Required on Backend Table Generation**:
  - Expose foreign key relation: `projects.client_id -> clients.id`.
  - Expose `clients.engagement_manager_id` (or EM contact link).
  - Add API endpoint or query to fetch project metadata including customer name and assigned Engagement Manager.

---

## Related Documents
- [[20_Database_Design_Draft]]
- [[21_API_Design_Draft]]
- [[22_Backend_Architecture_Draft]]
- [[28_Development_Roadmap]]
