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

Development keeps the user switch. UAT and production will get login later and should stay the same as each other. All three still run the current application, including the user switch, because the login screen is not in the product yet. `ASPNETCORE_ENVIRONMENT` stays `Development` on every stack until that login is ready. `App__Stage` and `VITE_APP_ENV` already say which stack a container belongs to. The header shows Development, UAT, or Production.

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
