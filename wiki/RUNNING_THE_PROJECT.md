# Running the Project

> **OS:** Windows  
> **Last Verified:** 2026-06-16

---

## Prerequisites

### Required Tools

| Tool | Minimum Version | Purpose | Install |
|------|----------------|---------|---------|
| **Node.js** | 18.x (20.x+ recommended) | JavaScript runtime | [nodejs.org](https://nodejs.org) |
| **Bun** | 1.x (optional) | Package manager (project has `bun.lock`) | `npm install -g bun` |
| **npm** | 10.x | Package manager (fallback) | Included with Node.js |
| **Git** | 2.x | Version control | [git-scm.com](https://git-scm.com) |

### Verify Installation

```powershell
node --version   # Should show v18.x or higher
npm --version    # Should show 10.x or higher
bun --version    # Optional: Should show 1.x
git --version    # Should show 2.x
```

---

## Quick Start (5 Minutes)

### Step 1: Navigate to Frontend Directory

```powershell
cd "d:\TalaKunchi\Project Compass 12\apps\frontend"
```

### Step 2: Install Dependencies

**Using npm (recommended — lockfile present):**
```powershell
npm install
```

**Using Bun (faster, lockfile present):**
```powershell
bun install
```

> **Note:** Both `bun.lock` and `package-lock.json` exist inside `apps/frontend/`. Use whichever package manager you prefer. npm is safer if you encounter issues.

### Step 3: Start Development Server

```powershell
npm run dev
```

### Step 4: Open in Browser

Navigate to:
```
http://localhost:6002
```

> The port is configured in `vite.config.ts` as `6002`. If that port is busy, Vite will try the next available port (strictPort is `false`).

---

## All Available Commands

Runs from `apps/frontend/`:

| Command | What It Does |
|---------|-------------|
| `npm run dev` | Start Vite development server with HMR on port 6002 |
| `npm run build` | Production build (outputs to `dist/` inside `apps/frontend/`) |
| `npm run build:dev` | Development build (unminified, with sourcemaps) |
| `npm run preview` | Preview production build locally |
| `npm run lint` | Run ESLint on all TypeScript files |
| `npm run format` | Format all files with Prettier |

---

## Expected Startup Behavior

When you run `npm run dev` from `apps/frontend/`, you should see output similar to:

```
  VITE v7.3.1  ready in 2500ms

  ➜  Local:   http://localhost:6002/
  ➜  Network: http://192.168.x.x:6002/
  ➜  press h + enter to show help
```

The application will:
1. Compile TypeScript and JSX
2. Process Tailwind CSS
3. Generate the route tree (`routeTree.gen.ts`)
4. Start the SSR-capable development server
5. Open to the **Dashboard** page with the default role (**Senior PM**)

### First Load Experience
- You'll see a **sidebar** on the left with navigation items
- A **role switcher** in the top bar lets you switch between 6 roles
- The **Dashboard** shows KPIs, project lists, and issue summaries
- All data is **mock data** — changes reset on page refresh

---

## Environment Variables

**Currently: NONE required.**

The project has no `.env` file and no environment variable dependencies. All data is embedded in the source code.

When the backend is implemented, you'll need:
```env
# Future .env file inside apps/frontend/
VITE_API_BASE_URL=http://localhost:8000/api/v1
VITE_AUTH_ENABLED=true
```

---

## Fallback Server

If the Vite dev server fails to start, a simple HTTP fallback exists:

```powershell
node simple-server.cjs
```

This starts a minimal HTTP server on port 6000+ that confirms Node.js is working. It does NOT serve the application — it's a diagnostic tool only.

---

## Common Issues & Troubleshooting

Run these commands from `apps/frontend/`:

### Issue: `npm install` fails with dependency conflicts
**Solution:** Try with `--legacy-peer-deps`:
```powershell
npm install --legacy-peer-deps
```

### Issue: Port 6002 is already in use
**Solution:** Vite will automatically try the next port. Check terminal output for the actual URL.

### Issue: TanStack route generation errors
**Solution:** Delete the generated route tree and restart:
```powershell
Remove-Item src\routeTree.gen.ts -Force
npm run dev
```

### Issue: `@lovable.dev/vite-tanstack-config` not found
**Solution:** This package is in the devDependencies. Run `npm install` to ensure it's installed.

### Issue: TypeScript errors in IDE but app runs fine
**Solution:** The project uses `skipLibCheck: true`. Some type errors are suppressed. Restart your IDE's TypeScript server:
- VS Code: `Ctrl+Shift+P` → "TypeScript: Restart TS Server"

### Issue: Styles not loading (unstyled page)
**Solution:** Ensure Tailwind CSS v4 is properly installed:
```powershell
npm install tailwindcss@^4.2.1 @tailwindcss/vite@^4.2.1
```

### Issue: Blank page or SSR errors
**Solution:** The SSR handler in `server.ts` catches catastrophic errors. Check the terminal for error messages. If SSR is problematic:
1. Check `apps/frontend/src/server.ts` for error logs
2. Look for `[dev] SSR handler error:` messages in terminal

---

## Project Structure Quick Reference

Rooted at `apps/frontend/`:

```
src/
├── routes/     ← Pages (26 files)
├── components/ ← UI components (6 custom + 46 shadcn/ui)
├── lib/        ← Data, state, utilities (7 files)
├── hooks/      ← Custom hooks (1 file)
└── styles.css  ← Design tokens + Tailwind config
```

---

## Related Documents

- [[Repository_Analysis]] — Complete codebase analysis
- [[Frontend_Architecture]] — How the app works
