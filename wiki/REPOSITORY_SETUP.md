# Repository Setup Guide

> **Last Updated:** 2026-06-16  
> **Structure:** Monorepo (`apps/frontend/` + `apps/backend/` + `wiki/`)

---

## Prerequisites

| Tool | Version | Required For | Install |
|------|---------|-------------|---------|
| Node.js | 18+ (20+ recommended) | Frontend | [nodejs.org](https://nodejs.org) |
| npm | 10+ | Frontend packages | Included with Node |
| Python | 3.11+ | Backend | [python.org](https://python.org) |
| PostgreSQL | 16+ | Database | [postgresql.org](https://postgresql.org) or Docker |
| Docker | Latest | DB + Backend containers | [docker.com](https://docker.com) |
| Git | 2+ | Version control | [git-scm.com](https://git-scm.com) |

---

## Repository Structure

```
project-compass/
├── apps/
│   ├── frontend/    ← React 19 + TanStack Start application
│   └── backend/     ← FastAPI + PostgreSQL application (future)
├── wiki/            ← Obsidian knowledge base
├── scripts/         ← Automation scripts
└── tools/           ← Developer tooling
```

---

## Running the Frontend

### First Time Setup
```powershell
cd apps/frontend
npm install
```

### Start Development Server
```powershell
cd apps/frontend
npm run dev
```
Opens at: **http://localhost:6002**

### All Frontend Commands
| Command | Purpose |
|---------|---------|
| `npm run dev` | Start dev server with HMR (port 6002) |
| `npm run build` | Production build → `apps/frontend/dist/` |
| `npm run build:dev` | Dev build (unminified) |
| `npm run preview` | Preview production build |
| `npm run lint` | Run ESLint |
| `npm run format` | Format with Prettier |

### Expected Behavior
- Dashboard loads with role switcher in top bar
- Default role: **Senior PM**
- 6 roles available for testing
- All data is mock — resets on refresh

---

## Running the Backend (Future)

### Option A: Docker (Recommended)
```powershell
# From repository root
docker-compose up -d
```
This starts:
- PostgreSQL on port **5432**
- FastAPI on port **8000**

### Option B: Local Python
```powershell
cd apps/backend

# Create virtual environment
python -m venv venv
venv\Scripts\activate          # Windows

# Install dependencies
pip install -r requirements.txt

# Set up database
alembic upgrade head

# Seed data
python -m seeds.seed_all

# Start server
uvicorn app.main:app --reload --port 8000
```

API available at: **http://localhost:8000**  
API docs at: **http://localhost:8000/docs**

---

## Running Both Services Together (Future)

### Option A: Two Terminals
```powershell
# Terminal 1 — Frontend
cd apps/frontend && npm run dev

# Terminal 2 — Backend
cd apps/backend && uvicorn app.main:app --reload --port 8000
```

### Option B: Docker Compose (Full Stack)
```yaml
# docker-compose.yml (at repo root)
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_DB: compass
      POSTGRES_USER: compass
      POSTGRES_PASSWORD: compass_dev
    ports: ["5432:5432"]
    volumes: ["pgdata:/var/lib/postgresql/data"]

  api:
    build: ./apps/backend
    command: uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
    ports: ["8000:8000"]
    depends_on: [db]
    env_file: ./apps/backend/.env

  web:
    build: ./apps/frontend
    ports: ["6002:6002"]
    depends_on: [api]

volumes:
  pgdata:
```

### Frontend → Backend Connection
When the backend exists, add to `apps/frontend/.env`:
```env
VITE_API_BASE_URL=http://localhost:8000/api/v1
```

---

## Environment Variables

### Frontend (None Required Currently)
When backend integration starts:
```env
VITE_API_BASE_URL=http://localhost:8000/api/v1
VITE_AUTH_ENABLED=true
```

### Backend
Copy `apps/backend/.env.example` to `apps/backend/.env`:
```env
DATABASE_URL=postgresql+asyncpg://compass:compass_dev@localhost:5432/compass
SECRET_KEY=change-this-in-production
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7
CORS_ORIGINS=http://localhost:6002
```

---

## Wiki / Documentation

The `wiki/` directory is an Obsidian vault. To use:
1. Open Obsidian
2. "Open folder as vault" → select `wiki/`
3. Navigate from `00_Project_Overview.md`

Or read the markdown files directly in any editor.

Start with: `PROJECT_RECOVERY_GUIDE.md`

---

## Troubleshooting

### Frontend won't start
```powershell
cd apps/frontend
Remove-Item -Recurse node_modules
npm install
npm run dev
```

### Port 6002 in use
Vite will auto-try the next port. Check terminal output.

### Route generation errors
```powershell
cd apps/frontend
Remove-Item src\routeTree.gen.ts -Force
npm run dev
```

### Python virtual environment issues (Windows)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
cd apps/backend
python -m venv venv
venv\Scripts\activate
```
