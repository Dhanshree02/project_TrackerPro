# Project Compass (Pulse PMO)

Enterprise-grade **Project Management, Resource Allocation, Finance, Governance, and Approval Workflow** platform for IT service companies and professional services organizations.

## Repository Structure

```
project-compass/
├── apps/
│   ├── frontend/    → React 19 + TanStack Start application
│   └── backend/     → FastAPI + PostgreSQL (coming soon)
├── wiki/            → Obsidian knowledge base (source of truth, flat vault)
├── scripts/         → Automation & migration scripts
└── tools/           → Developer tooling
```

## Quick Start

### Frontend
```powershell
cd apps/frontend
npm install
npm run dev
# Opens at http://localhost:6002
```

### Backend (Future)
```powershell
cd apps/backend
# Not yet implemented — see Backend_Master_Plan.md in wiki for plans
```

## Documentation

The `wiki/` directory is a flat Obsidian vault. Start with:
- `wiki/PROJECT_RECOVERY_GUIDE.md` — Full onboarding guide
- `wiki/REPOSITORY_SETUP.md` — Detailed setup instructions
- `wiki/00_Project_Overview.md` — Business context

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React 19, TypeScript, TanStack Start/Router, Tailwind CSS, shadcn/ui |
| Backend (planned) | FastAPI, PostgreSQL, SQLAlchemy, Alembic |
| Documentation | Obsidian Markdown Wiki |

## Status

- **Frontend:** ~80% complete (all UI screens, mock data)
- **Backend:** Not yet started (architecture designed, empty folder created)
- **Wiki:** 44+ documents, fully synchronized with monorepo paths
