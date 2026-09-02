# PMS TrackerPro — WFH Tester Setup Guide

This guide enables QA / Testers to run and test the full **PMS TrackerPro** application stack (React Frontend + .NET Core Backend + PostgreSQL Database + pgAdmin) locally using Docker while working from home.

---

## 1. Prerequisites (Tester Laptop)

1. **Docker Desktop**: Download and install [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows or Mac).
   - Ensure Docker Desktop is running before starting the app.
2. **Git**: Installed on your laptop.

---

## 2. One-Time Setup

1. Open your terminal / command prompt and clone the repository:
   ```bash
   git clone https://github.com/Dhanshree02/project_TrackerPro.git
   cd project_TrackerPro
   git checkout deployment-phase1
   ```

2. Run the start script:
   - **On Windows**: Double-click `scripts\tester-start.bat` (or run it in Command Prompt).
   - **On Mac/Linux**:
     ```bash
     docker compose -f docker-compose.tester.yml up -d --build
     ```

Docker will download the images, compile the code, automatically seed the PostgreSQL database from `trackerpro-final.sql`, and start all services.

---

## 3. Accessing the Services

| Service | URL | Credentials / Notes |
| :--- | :--- | :--- |
| **Frontend Web App** | [http://localhost:3000](http://localhost:3000) | Main application UI |
| **Backend Swagger API** | [http://localhost:5194/swagger](http://localhost:5194/swagger) | Interactive API documentation |
| **pgAdmin (DB Viewer)** | [http://localhost:5050](http://localhost:5050) | Email: `admin@admin.com`<br>Password: `clockit` |
| **PostgreSQL Database** | `localhost:5432` | DB: `trackerpro`<br>User: `postgres`<br>Password: `clockit` |

---

## 4. Daily Testing & Updates

Whenever the development team informs you that a new build is ready:
1. Double-click `scripts\tester-start.bat`.
2. The script automatically:
   - Pulls the latest stable changes from `deployment-phase1`.
   - Rebuilds and restarts the updated containers.
   - Preserves all test data you previously created.

---

## 5. Common Tasks

### How to Stop Testing
When done for the day, run:
```bash
docker compose -f docker-compose.tester.yml stop
```
*(To start again, run `docker compose -f docker-compose.tester.yml start`)*

### How to Reset to a Clean Database
If you modified data, deleted records, or want a clean slate:
- Double-click `scripts\tester-reset-db.bat`.
- Or run:
  ```bash
  docker compose -f docker-compose.tester.yml down -v
  docker compose -f docker-compose.tester.yml up -d
  ```
This wipes test data and automatically re-seeds the fresh initial database.
