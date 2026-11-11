# Docker & Runtime Environment Context

## 1. Running Containers

| Container Name | Base Image / Service | External Port | Internal Port | Health / Status |
|---|---|---|---|---|
| `pms_uat_clean_backend` | .NET 10 API (`PMS.API.dll`) | `52815` | `8080` | Healthy / Running |
| `pms_uat_clean_frontend` | Vite / TanStack React 19 / Nginx | `39107` | `3000` | Healthy / Running |
| `pms_uat_db` | PostgreSQL 16 Alpine | `41763` | `5432` | Healthy (db: `pms_uat_clean`) |
| `pms_pgadmin` | dpage/pgadmin4 | `46382` | `80` | Healthy / Running |

---

## 2. PostgreSQL Connection Details
- **Host:** `localhost`
- **Port:** `41763`
- **Database:** `pms_uat_clean`
- **Username:** `postgres`
- **Password:** `postgres`
- **CLI Connection:** `docker exec -it pms_uat_db psql -U postgres -d pms_uat_clean`

---

## 3. Rebuild & Recreate Commands

When backend C# files or frontend TypeScript files are modified:

```bash
# Rebuild containers without cache issues
docker compose -f docker-compose.uat-clean.yml build backend frontend

# Restart services
docker compose -f docker-compose.uat-clean.yml up -d backend frontend
```

---

## 4. SQL Backup & Dumps
Always keep the SQL dumps in sync when making catalog schema changes:
- `database/pms_uat.sql`
- `database/trackerpro-uat.sql`

