# Docker Setup & Team Deployment Guide

This document provides complete instructions for running the **PMS (TrackerPro)** application stack using Docker.

---

## Architecture Overview

```
                      ┌────────────────────────────────────────┐
                      │          HOST MACHINE / SERVER         │
                      │         (IP: 10.50.30.189)             │
                      │                                        │
                      │  ┌──────────────┐    ┌──────────────┐  │
                      │  │  PostgreSQL  │    │ PostgreSQL   │  │
                      │  │  Container   │◄───┤ Persistent   │  │
                      │  │ (Port: 5432) │    │ Docker Volume│  │
                      │  └───────▲──────┘    └──────────────┘  │
                      │          │                             │
                      │  ┌───────┴──────┐    ┌──────────────┐  │
                      │  │ .NET Backend │    │ React/Vite   │  │
                      │  │  Container   │◄───┤  Container   │  │
                      │  │ (Port: 5194) │    │ (Port: 3000) │  │
                      │  └──────────────┘    └──────▲───────┘  │
                      │  ┌──────────────┐           │          │
                      │  │ pgAdmin Web  │           │          │
                      │  │ (Port: 5050) │           │          │
                      │  └──────────────┘           │          │
                      └─────────────────────────────┼──────────┘
                                                    │
        ┌────────────────────────┐                  │
        │      DEVELOPERS        │                  │
        │ (Head Dev + 2 Devs)    │                  │
        │ Connect to Port: 5432  │                  │
        └───────────┬────────────┘                  │
                    │                               │
                    ▼                               ▼
       Direct DB access from code         Testing Team accesses 
       (Live synchronization)           http://10.50.30.189:3000
                                        (Source code is hidden)
```

---

## 1. Prerequisites (Host Machine)

Enable Hardware Virtualization and WSL/Virtual Machine Platform in Windows (PowerShell as Administrator):

```powershell
# Enable Virtual Machine Platform & WSL
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
bcdedit /set hypervisorlaunchtype auto

# Reboot to apply
Restart-Computer
```

---

## 2. Docker Files Configuration

### Root `docker-compose.yml`

```yaml
services:
  # 1. PostgreSQL Database
  postgres_db:
    image: postgres:16-alpine
    container_name: pms_postgres
    restart: always
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: clockit
      POSTGRES_DB: trackerpro
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/trackerpro-final.sql:/docker-entrypoint-initdb.d/01_init.sql:ro
    networks:
      - pms_network

  # 2. pgAdmin 4 (Web Database Manager)
  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: pms_pgadmin
    restart: always
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@admin.com
      PGADMIN_DEFAULT_PASSWORD: clockit
    ports:
      - "5050:80"
    networks:
      - pms_network
    depends_on:
      - postgres_db

  # 3. .NET Web API Backend
  backend:
    build:
      context: ./apps/backend
      dockerfile: Dockerfile
    container_name: pms_backend
    restart: always
    depends_on:
      - postgres_db
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:8080
      - ConnectionStrings__DefaultConnection=Host=postgres_db;Port=5432;Database=trackerpro;Username=postgres;Password=clockit
    ports:
      - "5194:8080"
    networks:
      - pms_network

  # 4. React Frontend App
  frontend:
    build:
      context: ./apps/frontend
      dockerfile: Dockerfile
    container_name: pms_frontend
    restart: always
    depends_on:
      - backend
    environment:
      - VITE_BACKEND_URL=http://backend:8080
    ports:
      - "3000:3000"
      - "80:3000"
    networks:
      - pms_network

networks:
  pms_network:
    driver: bridge

volumes:
  postgres_data:
    driver: local
```

---

### Backend Dockerfile (`apps/backend/Dockerfile`)

```dockerfile
# Stage 1: Build & Publish .NET API
FROM mcr.microsoft.com/dotnet/sdk:10.0-preview AS build
WORKDIR /src

COPY ["PMS.API.csproj", "./"]
RUN dotnet restore "PMS.API.csproj"

COPY . .
RUN dotnet publish "PMS.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:10.0-preview AS runtime
WORKDIR /app
COPY --from=build /app/publish .

EXPOSE 8080
ENTRYPOINT ["dotnet", "PMS.API.dll"]
```

---

### Frontend Dockerfile (`apps/frontend/Dockerfile`)

```dockerfile
FROM node:20-alpine
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

ENV NODE_ENV=development
ENV VITE_BACKEND_URL=http://backend:8080

EXPOSE 3000
CMD ["npx", "vite", "--host", "0.0.0.0", "--port", "3000"]
```

---

## 3. Command Reference

### Starting Containers

```powershell
# Start all containers (builds if changed)
docker compose up -d --build

# Start only the database (for developers working locally)
docker compose up -d postgres_db

# Start database + pgAdmin Web
docker compose up -d postgres_db pgadmin
```

### Checking Status & Logs

```powershell
# View running containers
docker ps

# View real-time logs of all containers
docker compose logs -f

# View logs for a specific service
docker compose logs -f backend
docker compose logs -f frontend
docker compose logs -f postgres_db
docker compose logs -f pgadmin
```

### Stopping & Resetting Containers

```powershell
# Stop all containers (preserves database data)
docker compose down

# Stop containers and delete database volume (fresh start)
docker compose down -v
```

### Database Backup & Restore

```powershell
# Backup database to a file
docker exec -t pms_postgres pg_dump -U postgres -d trackerpro > backup.sql

# Restore / Re-import SQL dump into database
Get-Content ./database/trackerpro-final.sql | docker exec -i pms_postgres psql -U postgres -d trackerpro
```

---

## 4. Team Access & Credentials

### A. For Developers (Syncing Code to Shared Database)
- **Host IP:** `10.50.30.189`
- **Port:** `5432`
- **Database:** `trackerpro`
- **Username:** `postgres`
- **Password:** `clockit`

**Connection String for `appsettings.Development.json`:**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=10.50.30.189;Port=5432;Database=trackerpro;Username=postgres;Password=clockit"
  }
}
```

---

### B. For QA / Testing Team (Code Completely Hidden)
Testers simply open their browser to:
- **Application URL:** `http://10.50.30.189:3000` *(or `http://10.50.30.189`)*
- **Demo Login:** `dhanshree@acme.co` / `Password@123`

---

### C. pgAdmin Web Database Management
- **URL:** `http://localhost:5050` *(or `http://10.50.30.189:5050`)*
- **Login Email:** `admin@admin.com`
- **Login Password:** `clockit`
- **Server Registration Inside pgAdmin:**
  - Host: `postgres_db` *(or `10.50.30.189`)*
  - Port: `5432`
  - Maintenance DB: `trackerpro`
  - Username: `postgres`
  - Password: `clockit`
