# Repository Restructuring Plan

> **Date:** 2026-06-16  
> **Status:** COMPLETED — Restructured under apps/ directory  
> **Approach:** Analysis-first, safest migration strategy

---

## Deliverable 1: Current Repository Analysis

### Complete File Inventory

#### Root Files (15 files)

| File | Size | Classification | Verdict |
|------|------|---------------|---------|
| `package.json` | 2.9KB | Frontend config | → `frontend/` |
| `package-lock.json` | 363KB | Frontend lockfile | → `frontend/` |
| `bun.lock` | 184KB | Duplicate lockfile | 🗑️ DELETE |
| `tsconfig.json` | 659B | Frontend TS config | → `frontend/` |
| `vite.config.ts` | 866B | Frontend build | → `frontend/` |
| `eslint.config.js` | 1.3KB | Frontend lint | → `frontend/` |
| `.prettierrc` | 90B | Formatter config | → Root (shared) |
| `.prettierignore` | 92B | Formatter ignore | → Root (shared) |
| `components.json` | 443B | shadcn/ui config | → `frontend/` |
| `wrangler.jsonc` | 202B | Cloudflare deploy | → `frontend/` |
| `README.md` | 10B | Empty README | ✏️ REWRITE |
| `simple-server.cjs` | 1.3KB | Orphan fallback | 🗑️ DELETE |
| `simple-server.js` | 906B | Orphan fallback | 🗑️ DELETE |
| `wbstabhtml.txt` | 14KB | Scratch file | 🗑️ DELETE |
| `.gitignore` | 334B | Git ignore | ✏️ UPDATE |

#### Root Directories (11 directories)

| Directory | Contents | Classification | Verdict |
|-----------|----------|---------------|---------|
| `src/` | 26 routes, 52 components, 7 lib files | Frontend source | → `frontend/src/` |
| `wiki/` | 42 markdown docs + development/ | Documentation | ✅ STAYS (reorganize internally) |
| `dist/` | Production build output | Generated | 🚫 GITIGNORE (stays, not committed) |
| `node_modules/` | Dependencies | Generated | 🚫 GITIGNORE (stays, not committed) |
| `.tanstack/` | TanStack generated config | Generated | 🚫 GITIGNORE |
| `.wrangler/` | Cloudflare local state | Generated | 🚫 GITIGNORE |
| `.git/` | Git history | Infrastructure | ✅ STAYS |
| `.lovable/` | 1 file (project.json, 71B) | Platform metadata | ✅ STAYS at root |
| `.obsidian/` | 5 config files | Obsidian vault config | ✅ STAYS (for wiki vault) |
| `.vscode/` | tasks.json (609B) | Editor config | ✏️ UPDATE |
| `simplified-app/` | Abandoned mini app | Dead code | 🗑️ DELETE entirely |

#### Source Code Breakdown (`src/`)

| Path | Files | Total Size | Category |
|------|-------|-----------|----------|
| `src/routes/` | 26 files | 605KB | Route pages |
| `src/components/ui/` | 46 files | 126KB | shadcn/ui base |
| `src/components/` (custom) | 6 files | 24KB | App components |
| `src/lib/` | 7 files | 138KB | Data, state, utils |
| `src/hooks/` | 1 file | 576B | Custom hooks |
| `src/` (root files) | 6 files | 29KB | Router, server, styles |

#### Wiki Breakdown (`wiki/`)

| Path | Files | Total Size | Category |
|------|-------|-----------|----------|
| `wiki/` (root) | 42 markdown files | ~196KB | Documentation |
| `wiki/development/decisions/` | 2 files | 3.2KB | ADRs |
| `wiki/development/daily-notes/` | 1 file | 3.7KB | Session logs |
| `wiki/development/frontend-progress/` | 1 file | 1.5KB | Frontend log |
| `wiki/development/backend-progress/` | 1 file | 496B | Backend log |

---

## Deliverable 2: Proposed Repository Structure

```
project-compass/                      # Repository root
│
├── frontend/                         # React/TanStack frontend application
│   ├── src/
│   │   ├── components/
│   │   │   ├── ui/                   # 46 shadcn/ui components (unchanged)
│   │   │   ├── app-shell.tsx
│   │   │   ├── app-sidebar.tsx
│   │   │   ├── app-topbar.tsx
│   │   │   ├── mobile-tabs.tsx
│   │   │   ├── pills.tsx
│   │   │   └── stage-tracker.tsx
│   │   ├── hooks/
│   │   │   └── use-mobile.tsx
│   │   ├── lib/
│   │   │   ├── dh-helpers.ts
│   │   │   ├── dh-store.ts
│   │   │   ├── error-capture.ts
│   │   │   ├── error-page.ts
│   │   │   ├── mock-data.ts
│   │   │   ├── role-context.tsx
│   │   │   └── utils.ts
│   │   ├── routes/                   # 26 route files (unchanged)
│   │   ├── routeTree.gen.ts          # Auto-generated
│   │   ├── router.tsx
│   │   ├── server.ts
│   │   ├── start.ts
│   │   ├── styles.css
│   │   └── vite-env.d.ts
│   ├── package.json
│   ├── package-lock.json
│   ├── tsconfig.json
│   ├── vite.config.ts
│   ├── eslint.config.js
│   ├── components.json
│   └── wrangler.jsonc
│
├── backend/                          # FastAPI backend (empty scaffold)
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py
│   │   ├── config.py
│   │   ├── database.py
│   │   ├── dependencies.py
│   │   ├── middleware/
│   │   │   ├── __init__.py
│   │   │   ├── auth.py
│   │   │   └── rbac.py
│   │   ├── models/
│   │   │   └── __init__.py
│   │   ├── schemas/
│   │   │   └── __init__.py
│   │   ├── routers/
│   │   │   └── __init__.py
│   │   └── services/
│   │       └── __init__.py
│   ├── alembic/
│   │   └── versions/
│   ├── seeds/
│   │   └── __init__.py
│   ├── tests/
│   │   └── __init__.py
│   ├── alembic.ini
│   ├── requirements.txt
│   ├── requirements-dev.txt
│   ├── Dockerfile
│   └── .env.example
│
├── wiki/                             # Obsidian Knowledge Base (reorganized)
│   ├── project/                      # Project-level docs
│   │   ├── 00_Project_Overview.md
│   │   ├── 01_System_Architecture.md
│   │   ├── 02_Business_Domain.md
│   │   ├── 03_Organization_Hierarchy.md
│   │   ├── 04_Roles_and_Permissions.md
│   │   ├── 05_Business_Workflows.md
│   │   └── 25_Project_Glossary.md
│   ├── frontend/                     # Frontend-specific docs
│   │   ├── 06_UI_Architecture.md
│   │   ├── 07_Frontend_Architecture.md
│   │   ├── 08_Module_Analysis.md
│   │   ├── 29_Known_Frontend_Behavior.md
│   │   └── Frontend_Architecture.md
│   ├── modules/                      # Business module docs
│   │   ├── 09_Client_Management.md
│   │   ├── 10_Project_Management.md
│   │   ├── 11_WBS_Management.md
│   │   ├── 12_Resource_Management.md
│   │   ├── 13_Task_Management.md
│   │   ├── 14_Timesheet_Management.md
│   │   ├── 15_Approval_Engine.md
│   │   ├── 16_Notification_System.md
│   │   ├── 17_Health_and_Governance.md
│   │   ├── 18_Finance_Module.md
│   │   └── 19_Reports_and_Analytics.md
│   ├── backend/                      # Backend design docs
│   │   ├── 20_Database_Design_Draft.md
│   │   ├── 21_API_Design_Draft.md
│   │   ├── 22_Backend_Architecture_Draft.md
│   │   ├── 23_Security_and_RBAC.md
│   │   ├── 24_Audit_Logging.md
│   │   ├── 30_Future_Backend_Implementation.md
│   │   ├── Backend_Master_Plan.md
│   │   └── BACKEND_DEVELOPMENT_PHASES.md
│   ├── planning/                     # Roadmaps, questions, analysis
│   │   ├── 26_Open_Questions.md
│   │   ├── 27_Data_Model_Reference.md
│   │   ├── 28_Development_Roadmap.md
│   │   ├── Repository_Analysis.md
│   │   └── Repository_Improvement_Plan.md
│   ├── guides/                       # Operational guides
│   │   ├── RUNNING_THE_PROJECT.md
│   │   ├── PROJECT_RECOVERY_GUIDE.md
│   │   ├── AI_DEVELOPMENT_WORKFLOW.md
│   │   ├── AI_HANDOVER_TEMPLATE.md
│   │   ├── KNOWLEDGE_SYNC_RULES.md
│   │   └── RESTRUCTURING_PLAN.md
│   ├── handovers/                    # Session handovers
│   │   └── AI_HANDOVER.md
│   └── development/                  # Dev tracking (unchanged)
│       ├── decisions/
│       ├── daily-notes/
│       ├── frontend-progress/
│       └── backend-progress/
│
├── scripts/                          # Automation scripts
│   └── seed-database.py              # Future: seed from mock-data
│
├── tools/                            # Developer tooling
│   └── .keep                         # Placeholder
│
├── docker-compose.yml                # Future: orchestrate frontend + backend + db
├── .gitignore                        # Updated for monorepo
├── .prettierrc                       # Shared formatter config
├── .prettierignore                   # Shared formatter ignore
├── .lovable/                         # Platform metadata
├── .obsidian/                        # Obsidian vault config
├── .vscode/                          # Editor workspace config
└── README.md                         # Proper project README
```

---

## Deliverable 3: Migration Plan

### Phase 1: Delete Dead Code (Zero Risk)

| Action | Target | Reason |
|--------|--------|--------|
| DELETE | `simple-server.cjs` | Diagnostic fallback, not used |
| DELETE | `simple-server.js` | ESM variant of same |
| DELETE | `wbstabhtml.txt` | Scratch HTML, no references |
| DELETE | `simplified-app/` (entire dir) | Abandoned mini app with own node_modules |
| DELETE | `bun.lock` | Duplicate lockfile; keep `package-lock.json` |
| DELETE | `src/routes/-projects..tsx` | Disabled route fragment (155B) |
| DELETE | `src/routes/-wbs-prerequisite-new.tsx` | Disabled duplicate (25KB) |
| RESOLVE | `src/routes/customer-detail.$clientId.tsx` | Duplicate of `customers.$clientId.tsx` — delete after verifying |

### Phase 2: Create Monorepo Skeleton

```powershell
# Create top-level directories
mkdir frontend
mkdir backend
mkdir scripts
mkdir tools
```

### Phase 3: Move Frontend Files

Move all frontend-specific files into `frontend/`:

```powershell
# Move source
Move-Item src frontend/src

# Move config files
Move-Item package.json frontend/
Move-Item package-lock.json frontend/
Move-Item tsconfig.json frontend/
Move-Item vite.config.ts frontend/
Move-Item eslint.config.js frontend/
Move-Item components.json frontend/
Move-Item wrangler.jsonc frontend/
```

After move, from `frontend/` directory run:
```powershell
cd frontend
npm install   # Regenerates node_modules in correct location
npm run dev   # Verify it works
```

### Phase 4: Update Paths & Configuration

**`frontend/vite.config.ts`** — No changes needed (paths are relative to `src/`)

**`frontend/tsconfig.json`** — No changes needed (`@/*` maps to `./src/*`)

**`frontend/components.json`** — No changes needed (uses `@/` aliases)

**`.vscode/tasks.json`** — Update commands:
```json
{
  "command": "cd frontend && npm install && npm run dev"
}
```

### Phase 5: Reorganize Wiki Internally

Move wiki files into subdirectories. See Deliverable 5 below.

### Phase 6: Scaffold Backend

Create empty backend structure. See Deliverable 6 below.

### Phase 7: Update Root Files

- Rewrite `README.md` with proper project description
- Update `.gitignore` for monorepo structure
- Create `docker-compose.yml` placeholder

---

## Deliverable 4: File Movement Table

### Files to DELETE (7 files + 1 directory)

| Current Path | Size | Reason |
|-------------|------|--------|
| `simple-server.cjs` | 1.3KB | Unused fallback server |
| `simple-server.js` | 906B | Unused fallback server |
| `wbstabhtml.txt` | 14KB | Scratch/prototype HTML |
| `bun.lock` | 184KB | Duplicate lockfile (keep npm) |
| `simplified-app/` | ~60KB | Abandoned prototype with own deps |
| `src/routes/-projects..tsx` | 155B | Disabled route fragment |
| `src/routes/-wbs-prerequisite-new.tsx` | 25KB | Disabled route duplicate |
| `src/routes/customer-detail.$clientId.tsx` | 22.6KB | Duplicate of `customers.$clientId.tsx` |

### Files to MOVE (Root → `frontend/`)

| Current Path | New Path |
|-------------|----------|
| `package.json` | `frontend/package.json` |
| `package-lock.json` | `frontend/package-lock.json` |
| `tsconfig.json` | `frontend/tsconfig.json` |
| `vite.config.ts` | `frontend/vite.config.ts` |
| `eslint.config.js` | `frontend/eslint.config.js` |
| `components.json` | `frontend/components.json` |
| `wrangler.jsonc` | `frontend/wrangler.jsonc` |
| `src/` (entire directory) | `frontend/src/` |

### Files that STAY at Root

| File | Reason |
|------|--------|
| `.gitignore` | Repository-wide (will be updated) |
| `.prettierrc` | Shared across frontend + backend |
| `.prettierignore` | Shared across frontend + backend |
| `README.md` | Repository-level documentation |
| `.git/` | Version control |
| `.lovable/` | Platform metadata |
| `.obsidian/` | Obsidian vault config for wiki |
| `.vscode/` | Editor workspace (will be updated) |

### Generated Directories (Not Moved — Regenerated)

| Directory | Action |
|-----------|--------|
| `node_modules/` | DELETE from root; `npm install` inside `frontend/` |
| `dist/` | DELETE from root; `npm run build` inside `frontend/` |
| `.tanstack/` | DELETE from root; regenerated by dev server inside `frontend/` |
| `.wrangler/` | DELETE from root; regenerated by Wrangler inside `frontend/` |

---

## Deliverable 5: Wiki Reorganization Plan

### Current State: 42 flat files + 1 subdirectory

All wiki docs currently sit flat in `wiki/` root. This becomes hard to navigate as docs grow.

### Proposed: 7 subdirectories by concern

| New Path | Files Moving In | Count |
|----------|----------------|-------|
| `wiki/project/` | 00, 01, 02, 03, 04, 05, 25 | 7 |
| `wiki/frontend/` | 06, 07, 08, 29, Frontend_Architecture | 5 |
| `wiki/modules/` | 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 | 11 |
| `wiki/backend/` | 20, 21, 22, 23, 24, 30, Backend_Master_Plan, BACKEND_DEVELOPMENT_PHASES | 8 |
| `wiki/planning/` | 26, 27, 28, Repository_Analysis, Repository_Improvement_Plan | 5 |
| `wiki/guides/` | RUNNING_THE_PROJECT, PROJECT_RECOVERY_GUIDE, AI_DEVELOPMENT_WORKFLOW, AI_HANDOVER_TEMPLATE, KNOWLEDGE_SYNC_RULES, RESTRUCTURING_PLAN | 6 |
| `wiki/handovers/` | AI_HANDOVER | 1 |
| `wiki/development/` | (unchanged — already organized) | 4 subdirs |

### Wiki Link Impact

> [!WARNING]
> Obsidian `[[wiki links]]` use **file names only**, not paths. Moving files into subdirectories **will NOT break** any `[[links]]` as long as file names stay the same. Obsidian resolves links by filename regardless of folder depth.

This means the wiki reorganization is **safe** — no link updates needed.

---

## Deliverable 6: Backend Folder Blueprint

```
backend/
├── app/
│   ├── __init__.py                   # Package init
│   ├── main.py                       # FastAPI app, CORS, middleware mount
│   ├── config.py                     # Pydantic BaseSettings (from env vars)
│   ├── database.py                   # AsyncEngine, AsyncSessionLocal
│   ├── dependencies.py               # get_db(), get_current_user()
│   │
│   ├── middleware/
│   │   ├── __init__.py
│   │   ├── auth.py                   # JWT verification
│   │   └── rbac.py                   # Permission guard decorator
│   │
│   ├── models/                       # SQLAlchemy ORM models
│   │   ├── __init__.py               # Base, import all models
│   │   ├── base.py                   # BaseModel with id, created_at, updated_at
│   │   ├── user.py
│   │   ├── client.py
│   │   ├── project.py
│   │   ├── task.py
│   │   ├── wbs.py
│   │   ├── timesheet.py
│   │   ├── issue.py
│   │   ├── invoice.py
│   │   ├── approval.py
│   │   ├── notification.py
│   │   └── audit.py
│   │
│   ├── schemas/                      # Pydantic request/response schemas
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── user.py
│   │   ├── client.py
│   │   ├── project.py
│   │   └── common.py                 # Pagination, errors
│   │
│   ├── routers/                      # API route handlers
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── users.py
│   │   ├── clients.py
│   │   ├── projects.py
│   │   ├── tasks.py
│   │   ├── wbs.py
│   │   ├── timesheets.py
│   │   ├── issues.py
│   │   ├── invoices.py
│   │   ├── approvals.py
│   │   ├── resources.py
│   │   └── notifications.py
│   │
│   ├── services/                     # Business logic layer
│   │   ├── __init__.py
│   │   ├── auth_service.py
│   │   ├── approval_engine.py
│   │   ├── notification_service.py
│   │   ├── allocation_engine.py
│   │   └── audit_service.py
│   │
│   └── utils/
│       ├── __init__.py
│       ├── security.py               # Password hashing, JWT helpers
│       └── pagination.py
│
├── alembic/
│   ├── env.py
│   ├── script.py.mako
│   └── versions/                     # Migration files (auto-generated)
│
├── seeds/
│   ├── __init__.py
│   └── seed_all.py                   # Seed from mock-data equivalents
│
├── tests/
│   ├── __init__.py
│   ├── conftest.py                   # Fixtures, test database
│   ├── test_auth.py
│   └── test_clients.py
│
├── alembic.ini                       # Alembic config
├── requirements.txt                  # Production dependencies
├── requirements-dev.txt              # Dev/test dependencies
├── Dockerfile                        # Container build
└── .env.example                      # Environment template
```

### Initial `requirements.txt`
```
fastapi>=0.115.0
uvicorn[standard]>=0.30.0
sqlalchemy[asyncio]>=2.0.0
asyncpg>=0.30.0
alembic>=1.13.0
python-jose[cryptography]>=3.3.0
passlib[bcrypt]>=1.7.4
pydantic-settings>=2.0.0
python-multipart>=0.0.9
```

### Initial `.env.example`
```env
DATABASE_URL=postgresql+asyncpg://compass:compass_dev@localhost:5432/compass
SECRET_KEY=your-secret-key-change-in-production
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7
CORS_ORIGINS=http://localhost:6002
```

---

## Deliverable 7: REPOSITORY_SETUP.md

See separate file: [[REPOSITORY_SETUP]]

---

## Deliverable 8: Documentation Maintenance Rules

### Rule Matrix (Post-Restructuring)

| Change Type | Wiki Path to Update |
|------------|-------------------|
| Frontend route added/modified | `wiki/frontend/` + relevant `wiki/modules/` |
| Frontend component added | `wiki/frontend/06_UI_Architecture.md` |
| Frontend state change | `wiki/frontend/07_Frontend_Architecture.md` |
| Backend endpoint added | `wiki/backend/21_API_Design_Draft.md` |
| Backend model change | `wiki/backend/20_Database_Design_Draft.md` |
| Database migration | `wiki/backend/20_Database_Design_Draft.md` |
| API auth/RBAC change | `wiki/backend/23_Security_and_RBAC.md` |
| Business workflow change | `wiki/project/05_Business_Workflows.md` + `wiki/modules/` |
| Role permission change | `wiki/project/04_Roles_and_Permissions.md` |
| Architecture decision | `wiki/development/decisions/ADR-NNN.md` |
| Configuration change | `wiki/guides/RUNNING_THE_PROJECT.md` |
| Session end | `wiki/handovers/AI_HANDOVER.md` |
| Any session | `wiki/development/daily-notes/YYYY-MM-DD.md` |

### Enforcement Rules

1. **No PR/commit is complete** without corresponding wiki updates
2. **Frontend changes** → update `wiki/frontend/` AND relevant `wiki/modules/`
3. **Backend changes** → update `wiki/backend/` AND relevant `wiki/modules/`
4. **Database changes** → update `wiki/backend/20_Database_Design_Draft.md`
5. **API changes** → update `wiki/backend/21_API_Design_Draft.md`
6. **Workflow changes** → update `wiki/project/05_Business_Workflows.md`
7. **Architecture decisions** → create ADR in `wiki/development/decisions/`
8. **Every AI session** → create daily note AND update handover

---

## Execution Checklist

> [!IMPORTANT]
> Do NOT execute any steps until you explicitly approve this plan.

- [ ] **Phase 1:** Delete dead code (7 files + 1 directory)
- [ ] **Phase 2:** Create monorepo skeleton (`frontend/`, `backend/`, `scripts/`, `tools/`)
- [ ] **Phase 3:** Move frontend files into `frontend/`
- [ ] **Phase 4:** Delete generated dirs from root (`node_modules/`, `dist/`, `.tanstack/`, `.wrangler/`)
- [ ] **Phase 5:** Run `npm install` inside `frontend/`, verify `npm run dev` works
- [ ] **Phase 6:** Reorganize wiki into subdirectories
- [ ] **Phase 7:** Scaffold empty backend structure
- [ ] **Phase 8:** Update `.gitignore`, `.vscode/tasks.json`, `README.md`
- [ ] **Phase 9:** Create `REPOSITORY_SETUP.md`
- [ ] **Phase 10:** Update all wiki internal cross-references

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| `routeTree.gen.ts` breaks after move | Medium | Low | Regenerates automatically on `npm run dev` |
| `@/*` import paths break | Low | High | `tsconfig.json` moves WITH `src/`, paths stay relative |
| Obsidian links break | Very Low | Low | Obsidian resolves by filename, not path |
| Git history lost on files | Low | Medium | Use `git mv` for proper tracking |
| Build breaks | Medium | Medium | Test after each phase before proceeding |
| `.lovable` integration breaks | Low | Low | `project.json` references template, not paths |

---

## Related Documents
- [[Repository_Analysis]]
- [[Repository_Improvement_Plan]]
- [[Backend_Master_Plan]]
- [[BACKEND_DEVELOPMENT_PHASES]]
