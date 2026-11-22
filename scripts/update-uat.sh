#!/bin/sh
set -e
cd "$(dirname "$0")/.."

echo "Pulling origin/uat"
git pull origin uat

echo "Starting the UAT database without removing its volume"
docker network inspect pms_shared >/dev/null 2>&1 || docker network create pms_shared
docker volume inspect pms-uat-storage >/dev/null 2>&1 || docker volume create pms-uat-storage
docker compose -f compose/uat.yml -p pms-uat up -d db

echo "Applying schema update"
docker cp database/schema-update.sql pms_uat_db:/tmp/schema-update.sql
docker exec pms_uat_db psql -U postgres -d pms_uat -v ON_ERROR_STOP=1 -f /tmp/schema-update.sql

echo "Rebuilding the UAT app"
docker compose -f compose/uat.yml -p pms-uat up -d --build

echo "UAT update finished. The database was not deleted."
echo "App: http://THIS-SERVER:39117"
