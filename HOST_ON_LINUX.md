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

Production HTTPS is handled by the host nginx + Let's Encrypt (managed by IT). The app container listens on port `39127` and nginx reverse-proxies `https://pms-uat.talakunchi.com` to it.

## Part A. IT does this once

Send this list to the IT person. You cannot do these without an administrator.

1. Install Docker and Docker Compose on the PMS instance.
2. Add your user to the `docker` group, so `docker ps` works with no `sudo`.
3. Install nginx and certbot (Let's Encrypt). Add a server block that reverse-proxies `https://pms-uat.talakunchi.com` to `http://127.0.0.1:39127` with `X-Forwarded-Proto https`. See the example config in Part G below.
4. Open these ports to the office / public network:
   - `80` and `443` for production HTTPS (nginx + Let's Encrypt)
   - `39117` UAT app for testers
   - `52819` UAT API
   - `39127` / `52827` optional direct debug access (only if needed)
5. Confirm DNS: `pms-uat.talakunchi.com` → `169.58.144.168` (already done).

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

Start the app:

```bash
bash scripts/update-production.sh
```

The first build can take several minutes. When it ends, open:

`https://pms-uat.talakunchi.com`

Sign in with Microsoft.

If the schema step says a table does not exist, the production database on this server is empty. Stop and load the real production database dump into `pms_production`, then run `bash scripts/update-production.sh` again. Do not copy `pms_development.sql` or `pms_uat.sql` into production.

### If production is already running — switch to HTTPS

Ask IT to add the nginx reverse-proxy config (see Part G). Then:

```bash
cd ~/pms-production
# or: cd ~/app
nano apps/backend/.env
```

Set this line (keep the three Tenant/Client lines and `Jwt__SigningKey` as they are):

```bash
AzureAd__RedirectUri=https://pms-uat.talakunchi.com/api/v1/auth/microsoft/callback
```

Then recreate the backend:

```bash
docker compose -f compose/production.yml -p pms-production up -d --force-recreate backend
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

Today production is `https://pms-uat.talakunchi.com` via the host nginx reverse proxy. Once you have a dedicated DNS name (e.g. `pms.talakunchi.com`), ask IT to update the nginx `server_name`, run `certbot` for the new domain, then update `apps/backend/.env` and the Entra redirect URI to that hostname.

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

## Part G. Nginx reverse-proxy config (IT reference)

IT adds this config to the host nginx. The cert paths assume certbot with Let's Encrypt:

```bash
sudo nano /etc/nginx/sites-available/pms-production
```

```nginx
server {
    listen 443 ssl;
    server_name pms-uat.talakunchi.com;

    ssl_certificate     /etc/letsencrypt/live/pms-uat.talakunchi.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/pms-uat.talakunchi.com/privkey.pem;
    include             /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam         /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass         http://127.0.0.1:39127;
        proxy_set_header   Host              $host;
        proxy_set_header   X-Forwarded-Proto https;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_read_timeout 120s;
    }
}

server {
    listen 80;
    server_name pms-uat.talakunchi.com;
    return 301 https://$host$request_uri;
}
```

Enable and reload:

```bash
sudo ln -s /etc/nginx/sites-available/pms-production /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```
