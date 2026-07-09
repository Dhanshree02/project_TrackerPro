# Known Frontend Behavior

> **Last Updated:** 2026-06-16

---

## Architecture Observations

### 1. No Route Guards
Only `wbs-allocation.tsx` enforces role access (`if (!isPMO) return <Navigate to="/" />`). All other routes are accessible by any role via direct URL navigation. The sidebar hides items per role, but URLs are not protected.

### 2. Data Mutation Pattern
Frontend mutations update local `useState` arrays. These changes are **ephemeral** — they reset on page refresh since they modify local state, not persistent storage. The exceptions are:
- `projects.push(newProject)` in WBS allocation — mutates the imported array directly (persists in SPA memory but lost on reload)
- `dhStore` methods — use singleton store that persists in SPA memory

### 3. Hydration Risk
`projects.$projectId.tsx` uses `formatDate()` helper to prevent SSR/client hydration mismatches when formatting dates. Without this, `toLocaleDateString()` produces different output on server vs client.

### 4. Large File Sizes
- `projects.$projectId.tsx` — 3193 lines (should be split into sub-components)
- `action-centre.tsx` — ~2000 lines (should be split into per-tab modules)
- `dh-store.ts` — 2141 lines (should be split into domain stores)

### 5. Role Switcher
The top bar includes a dropdown to switch between all 6 roles at any time. This is a development convenience that must be removed in production.

### 6. Mock Data Imports
All data is imported directly:
```typescript
import { clients, projects, people } from "@/lib/mock-data";
```
This means the entire dataset is bundled into the client JavaScript. Backend migration must replace these with React Query hooks.

### 7. Toast Notifications
Uses `sonner` library for toast notifications (success/error). Currently used in:
- Invoice raise/cancel operations
- Extension request submission
- Form validation errors

### 8. Error Handling
- `error-capture.ts` and `error-page.ts` exist for error boundary support
- Route loaders throw `notFound()` for invalid project IDs
- No global error boundary is visible in `__root.tsx`

### 9. Conditional Component Rendering
Many components render entirely different UIs based on `isDhanshree`:
```typescript
{tab === "Tasks" && (isDhanshree ? <DhTasksTab /> : <DefaultTasksTab />)}
{tab === "Team" && (isDhanshree ? <DhTeamTab /> : <DefaultTeamTab />)}
```
This doubles the component surface area and should be unified with role-aware props.

---

## Related Documents
- [[07_Frontend_Architecture]]
- [[08_Module_Analysis]]
