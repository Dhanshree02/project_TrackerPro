#!/bin/sh
set -e
cd "$(dirname "$0")/.."

echo "Pulling origin/production"
git pull origin production

echo "Starting the production database without removing its volume"
docker network inspect pms_shared >/dev/null 2>&1 || docker network create pms_shared
docker volume inspect pms-production-storage >/dev/null 2>&1 || docker volume create pms-production-storage
docker compose -f compose/production.yml -p pms-production up -d db

echo "Waiting for the production database to accept connections"
i=0
until docker exec pms_production_db pg_isready -U postgres -d pms_production >/dev/null 2>&1; do
  i=$((i + 1))
  if [ "$i" -gt 60 ]; then
    echo "Database did not become ready in time."
    exit 1
  fi
  sleep 2
done

table_count=$(docker exec pms_production_db psql -U postgres -d pms_production -tAc \
  "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog','information_schema')")
if [ "${table_count:-0}" -eq 0 ]; then
  echo "Production database is empty. Stop here and load the real production dump into pms_production."
  echo "Do not load pms_development.sql or pms_uat.sql into production."
  exit 1
fi

echo "Applying schema update"
docker cp database/schema-update.sql pms_production_db:/tmp/schema-update.sql
docker exec pms_production_db psql -U postgres -d pms_production -v ON_ERROR_STOP=1 -f /tmp/schema-update.sql

echo "Rebuilding the production app"
docker compose -f compose/production.yml -p pms-production up -d --build

echo "Production update finished. The database was not deleted."
echo "App: http://THIS-SERVER:39127"
