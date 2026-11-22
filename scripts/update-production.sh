#!/bin/sh
set -e
cd "$(dirname "$0")/.."

echo "Pulling origin/production"
git pull origin production

echo "Starting the production database without removing its volume"
docker network inspect pms_shared >/dev/null 2>&1 || docker network create pms_shared
docker volume inspect pms-production-storage >/dev/null 2>&1 || docker volume create pms-production-storage
docker compose -f compose/production.yml -p pms-production up -d db

echo "Applying schema update"
docker cp database/schema-update.sql pms_production_db:/tmp/schema-update.sql
docker exec pms_production_db psql -U postgres -d pms_production -v ON_ERROR_STOP=1 -f /tmp/schema-update.sql

echo "Rebuilding the production app"
docker compose -f compose/production.yml -p pms-production up -d --build

echo "Production update finished. Database volume was left in place."
echo "App: http://THIS-SERVER:39127"
