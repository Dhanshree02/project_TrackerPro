# Host UAT and production on the Linux server

You do not need to learn Linux. Copy each block into the server window and press Enter.
Do not type `sudo` unless IT told you that you must. Do not type `git push` on the server.

Public DNS name (already points at this host):

| Name | IP |
| --- | --- |
| `pms-uat.talakunchi.com` | `169.58.144.168` |

| Who | Open this |
| --- | --- |
| Testers (UAT) | `http://pms-uat.talakunchi.com:39117` |
| Production users | `https://pms-uat.talakunchi.com` |

Production uses a Caddy container (`compose/caddy.yml`) for automatic Let's Encrypt HTTPS on ports `80`/`443`—no `sudo` or host Nginx required.

## Part A. IT does this once

Send this list to the IT person. You cannot do these without an administrator.

1. Install Docker and Docker Compose on the PMS instance.
2. Add your user to the `docker` group, so `docker ps` works with no `sudo`.
3. Open these ports to the office / public network:
   - `80` and `443` for production HTTPS (Let's Encrypt + Caddy)
   - `39117` UAT app for testers
   - `52819` UAT API
   - `39127` / `52827` optional direct debug access (only if needed)
4. Confirm DNS: `pms-uat.talakunchi.com` → `169.58.144.168` (already done).

## Part B. Check that you can work

Log in to the server. Type:

```bash
docker ps
```

A table means you can continue. The table can be empty.
If you see `permission denied`, stop and tell IT. Your user cannot use Docker yet.

## Part C. Production, first time

Production uses Microsoft sign-in. The user switch stays off.

```bash
cd ~
git clone https://github.com/Dhanshree02/project_TrackerPro pms-production
cd pms-production
git checkout production
nano apps/backend/.env
```

`nano` is a text screen. Type these lines. Paste the real Microsoft values and a random 64+ character `Jwt__SigningKey`.

```bash
AzureAd__TenantId=paste-tenant-id
AzureAd__ClientId=paste-client-id
AzureAd__ClientSecret=paste-client-secret
AzureAd__RedirectUri=https://pms-uat.talakunchi.com/api/v1/auth/microsoft/callback
Jwt__SigningKey=paste-a-random-64-plus-character-secret-here
```

In the Microsoft Entra app registration, add **exactly** this redirect URI:

`https://pms-uat.talakunchi.com/api/v1/auth/microsoft/callback`

Save with Ctrl+O, press Enter, then leave with Ctrl+X.

Start the app and Caddy HTTPS proxy:

```bash
bash scripts/update-production.sh
```

The first build can take several minutes. When it ends, check Caddy obtained the TLS certificate (`docker logs pms-caddy`), then open:

`https://pms-uat.talakunchi.com`

Sign in with Microsoft.

If the schema step says a table does not exist, the production database on this server is empty. Stop and load the real production database dump into `pms_production`, then run `bash scripts/update-production.sh` again. Do not copy `pms_development.sql` or `pms_uat.sql` into production.

### If production is already running — switch to HTTPS

```bash
cd ~/pms-production
# or: cd ~/app
nano apps/backend/.env
```

Set this line (keep the three Tenant/Client lines and `Jwt__SigningKey` as they are):

```bash
AzureAd__RedirectUri=https://pms-uat.talakunchi.com/api/v1/auth/microsoft/callback
```

Then recreate the backend and start Caddy:

```bash
docker compose -f compose/production.yml -p pms-production up -d --force-recreate backend
docker compose -f compose/caddy.yml -p pms-proxy up -d
```

Add `https://pms-uat.talakunchi.com/api/v1/auth/microsoft/callback` in Entra. Then open `https://pms-uat.talakunchi.com`.

## Part D. UAT, first time

UAT is for functional testers. It has its own database. The user switch stays on. It does not use the production `.env`.

```bash
cd ~
git clone https://github.com/Dhanshree02/project_TrackerPro pms-uat
cd pms-uat
git checkout uat
bash scripts/update-uat.sh
```

When it ends, open:

`http://pms-uat.talakunchi.com:39117`

The UAT app is a **built** frontend. The container runs the Node render server and serves the hashed files. A “Welcome to nginx” page means an older image is still running. Rebuild:

```bash
cd ~/pms-uat
git pull origin uat
docker compose -f compose/uat.yml -p pms-uat up -d --build --force-recreate frontend
```

The first rebuild can take several minutes. Then hard-refresh the browser (Ctrl+Shift+R). Testers pick a user from the switch in the top bar.

On a new empty UAT volume the script waits for Postgres, then loads `database/pms_uat.sql` once, then applies `schema-update.sql`. Do not load the production database into UAT.

## Part E. Later: dedicated production domain (optional)

Today production is `https://pms-uat.talakunchi.com` via `compose/caddy.yml` (`pms-caddy` on ports 80/443). Once you have a dedicated DNS name (e.g. `pms.talakunchi.com`), update `compose/Caddyfile`, `apps/backend/.env`, and the Entra redirect URI to that hostname—no host Nginx install needed.

## Part F. Later updates

On your PC, push the change to `origin/uat` for testers, or `origin/production` for users.

On the server, testers first:

```bash
cd ~/pms-uat
bash scripts/update-uat.sh
```

After UAT is accepted:

```bash
cd ~/pms-production
bash scripts/update-production.sh
```

The `.env` file stays where it is. Do not run `git push` on the server. Do not run `docker compose down -v`. That command deletes the database.
