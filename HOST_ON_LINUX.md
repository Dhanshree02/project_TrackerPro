# Host UAT and production on the Linux server

You do not need to learn Linux. Copy each block into the server window and press Enter.
Do not type `sudo` unless IT told you that you must. Do not type `git push` on the server.

Ask IT for the server address before you start. This guide calls it `SERVER-ADDRESS`.
Example: `10.50.30.50` or `pms-server`.

## Part A. IT does this once

Send this list to the IT person. You cannot do these without an administrator.

1. Install Docker and Docker Compose on the PMS instance.
2. Add your user to the `docker` group, so `docker ps` works with no `sudo`.
3. Open these ports to the office network:
   - `39117` UAT app for testers
   - `52819` UAT API
   - `39127` production app
   - `52827` production API
4. Optional short links, after the apps are running. See Part E. That part needs them because a name on port 80 needs an administrator.

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

`nano` is a text screen. Type these four lines. Paste the real Microsoft values.

```bash
AzureAd__TenantId=paste-tenant-id
AzureAd__ClientId=paste-client-id
AzureAd__ClientSecret=paste-client-secret
AzureAd__RedirectUri=http://SERVER-ADDRESS:39127/api/v1/auth/microsoft/callback
```

Use the same address in the Microsoft app registration, under redirect URIs.
Save with Ctrl+O, press Enter, then leave with Ctrl+X.

Start the app:

```bash
bash scripts/update-production.sh
```

The first build can take several minutes. When it ends, open:

`http://SERVER-ADDRESS:39127`

Sign in with Microsoft.

If the schema step says a table does not exist, the production database on this server is empty. Stop and ask for the existing production database to be placed in the `pms_production` volume. Do not copy `pms_development.sql` into production. That file is development data.

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

`http://SERVER-ADDRESS:39117`

The UAT app is a **built** frontend. The container runs the Node render server and serves the hashed files. A “Welcome to nginx” page means an older image is still running. Rebuild:

```bash
cd ~/pms-uat
git pull origin uat
docker compose -f compose/uat.yml -p pms-uat up -d --build --force-recreate frontend
```

The first rebuild can take several minutes. Then hard-refresh the browser (Ctrl+Shift+R). Testers pick a user from the switch in the top bar.

On a new empty UAT volume the script waits for Postgres, then loads `database/pms_uat.sql` once, then applies `schema-update.sql`. Do not load the production database into UAT.

## Part E. Turn a port into a link

Until IT adds names, the links are:

| Who | Type this in the browser |
| --- | --- |
| Testers | `http://SERVER-ADDRESS:39117` |
| Production users | `http://SERVER-ADDRESS:39127` |

To hide the port, send IT this request:

"Please add two DNS names that point at this server, and a reverse proxy. `pms-uat.OFFICE` should forward to `127.0.0.1:39117`. `pms.OFFICE` should forward to `127.0.0.1:39127`. I cannot bind port 80 without administrator rights."

After they do that, the links are:

| Who | Link |
| --- | --- |
| Testers | `http://pms-uat.OFFICE` |
| Production users | `http://pms.OFFICE` |

Change the production redirect line in `apps/backend/.env` to the new production link, then run the production script again:

```bash
AzureAd__RedirectUri=http://pms.OFFICE/api/v1/auth/microsoft/callback
```

Put that same address in the Microsoft app registration. UAT does not need this, because testers use the user switch.

A Caddy file IT can use, if they ask what to install:

```text
pms.OFFICE {
    reverse_proxy 127.0.0.1:39127
}

pms-uat.OFFICE {
    reverse_proxy 127.0.0.1:39117
}
```

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
