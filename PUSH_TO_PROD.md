# Push development changes to production

Use this when app or database-schema work on `development` is ready for production.
The production server only pulls and runs one script. Do not commit or push from that machine.

Repo: `https://github.com/Dhanshree02/project_TrackerPro`

| Place | Branch | Folder |
| --- | --- | --- |
| Development machine | `development` | `PMS-dev` |
| Production server | `production` | `PMS-prod` |

App: https://pms-uat.talakunchi.com  
API: http://pms-uat.talakunchi.com:52827/swagger  
Database container: `pms_production_db`  
Database name: `pms_production`  

Microsoft redirect in `apps/backend/.env` on the server:

`AzureAd__RedirectUri=https://pms-uat.talakunchi.com/api/v1/auth/microsoft/callback`

Add that same URI in the Entra app registration.

## What production keeps

- Microsoft sign-in stays on. `compose/production.yml` sets `Auth__AllowHeaderBypass` to `false` and `VITE_APP_ENV` to `production`.
- The user switch stays off. Development and UAT keep it.
- Existing production rows stay in the Docker volume `pms_production_postgres_data`.
- Schema changes are `CREATE` and `ALTER` statements in `database/schema-update.sql`. The script is safe to run again.
- Images are built on the server: `pms-backend:production` and `pms-frontend:production`. Docker must not download `pms-frontend:uat-clean`.

## On the development machine

Work in `PMS-dev` on branch `development`.

1. Make the app change and test it on the development stack.
2. When the database shape changes, add an Entity Framework migration:

```powershell
dotnet tool restore
dotnet ef migrations add YourChangeName --project "apps/backend/PMS.API.csproj" --startup-project "apps/backend/PMS.API.csproj" --output-dir Migrations
```

Run that from `apps/backend` after `dotnet tool restore` if `dotnet ef` is not on the path.

3. Keep the migration idempotent. Add columns with `ADD COLUMN IF NOT EXISTS`. Widen columns with `ALTER COLUMN ... TYPE`. Number only rows that are still empty. Do not delete or replace production rows.
4. Put the same SQL in `database/schema-update.sql`, inside a transaction, and record the migration id:

```sql
INSERT INTO public."__EFMigrationsHistory" ("MigrationId", "ProductVersion")
SELECT 'YYYYMMDDHHMMSS_YourChangeName', '10.0.4'
WHERE NOT EXISTS (
    SELECT 1 FROM public."__EFMigrationsHistory"
    WHERE "MigrationId" = 'YYYYMMDDHHMMSS_YourChangeName'
);
```

5. Commit on `development` and push:

```powershell
git push origin development
```

6. Bring that commit onto `production` without replacing production-only files:

```powershell
git checkout production
git pull origin production
git cherry-pick <development-commit>
git push origin production
git checkout development
```

Keep these production files as they are on `origin/production`:

- `compose/production.yml`
- `scripts/update-production.bat`
- the production database dumps
- `Documents/` already stored for production

Leave out development database dumps, local uploads, and `apps/backend/.env`.

## On the production server

Open `~/pms-production` and run:

```bash
bash scripts/update-production.sh
```

The script pulls `origin/production`, creates the `pms_shared` network and `pms-production-storage` volume when they are missing, applies `database/schema-update.sql`, rebuilds the app, and starts/reloads Caddy (`compose/caddy.yml`) for HTTPS. The database volume stays in place.

Then sign in at https://pms-uat.talakunchi.com with Microsoft and check the screen you changed.

Do not commit, push, or edit files on the production server after the script. The next change starts again on `development`.

## On the server

Run only the update script. It pulls code, adds any missing columns, and starts the app again. It does not stop Docker and it does not delete the database. The rows stay in the Docker volume. Do not type a Docker stop command, and do not run `git push` on the server.
