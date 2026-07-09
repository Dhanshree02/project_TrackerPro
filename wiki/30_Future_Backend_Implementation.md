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

## Backend Quick Start (When Ready)

```bash
# 1. Create Python environment
python -m venv venv
venv\Scripts\activate  # Windows

# 2. Install dependencies
pip install fastapi uvicorn sqlalchemy alembic psycopg2-binary python-jose passlib

# 3. Initialize Alembic
alembic init alembic

# 4. Create first migration
alembic revision --autogenerate -m "initial schema"

# 5. Apply migration
alembic upgrade head

# 6. Run server
uvicorn app.main:app --reload
```

---

## Related Documents
- [[20_Database_Design_Draft]]
- [[21_API_Design_Draft]]
- [[22_Backend_Architecture_Draft]]
- [[28_Development_Roadmap]]
