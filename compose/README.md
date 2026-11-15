# Pulse PMO environments

One Git repository. Three branches, three folders, three databases. A change in one folder does not change the other two.

| Environment | Folder | Branch |
| --- | --- | --- |
| Development | `/Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/pms-development` | `development` |
| UAT | `/Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/pms-uat` | `uat` |
| Production | `/Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/pms-production` | `production` |

The folders share Git history. They do not share working files. Start each stack from its own folder, so Docker mounts that folder's frontend, backend files, and Documents.

## Names

| | Development | UAT | Production |
| --- | --- | --- | --- |
| Git branch | `development` | `uat` | `production` |
| Compose project | `pms-development` | `pms-uat` | `pms-production` |
| Backend container | `pms-development-backend` | `pms-uat-backend` | `pms-production-backend` |
| Frontend container | `pms-development-frontend` | `pms-uat-frontend` | `pms-production-frontend` |
| Database | `pms_development` | `pms_uat` | `pms_production` |
| App | http://localhost:39107 | http://localhost:39117 | http://localhost:39127 |
| API | http://localhost:52815 | http://localhost:52819 | http://localhost:52827 |

Postgres container: `pms_uat_db` (host port 41763). pgAdmin: http://localhost:46382, server name **Pulse PMO**. The container name stays `pms_uat_db` because the live data volume is already attached to it.

`pms_uat_clean` remains the snapshot these three databases were copied from. `pms_deployment` is the older extra database and is not one of the three stacks.

## What differs

Development and UAT keep the user switch. Production signs in with Microsoft 365. The production API image is `pms-backend:production`. `Auth__AllowHeaderBypass` is false on that stack, so `X-User-Id` is not a login. `ASPNETCORE_ENVIRONMENT` stays `Development` on every stack so Swagger still opens. `App__Stage` and `VITE_APP_ENV` say which stack a container belongs to. The header shows Development, UAT, or Production.

Each stack has its own file volume. Uploads under `Documents/` are still the shared checkout folder.

## Commands

Start the database first if it is not already running, from the development folder:

```
docker compose -f docker-compose.uat.yml -p pms_uat up -d db pgadmin
```

Then start each app from its own folder:

```
cd /Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/pms-development
docker compose -f compose/development.yml -p pms-development up -d

cd /Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/pms-uat
docker compose -f compose/uat.yml -p pms-uat up -d

cd /Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/pms-production
docker compose -f compose/production.yml -p pms-production up -d
```

`Database__AutoMigrate` and `Database__Seed` stay false.
