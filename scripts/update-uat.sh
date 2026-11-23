#!/bin/sh
set -e
cd "$(dirname "$0")/.."

echo "Pulling origin/uat"
git pull origin uat

echo "Starting the UAT database without removing its volume"
docker network inspect pms_shared >/dev/null 2>&1 || docker network create pms_shared
docker volume inspect pms-uat-storage >/dev/null 2>&1 || docker volume create pms-uat-storage
docker compose -f compose/uat.yml -p pms-uat up -d db

echo "Waiting for the UAT database to accept connections"
i=0
until docker exec pms_uat_db pg_isready -U postgres -d pms_uat >/dev/null 2>&1; do
  i=$((i + 1))
  if [ "$i" -gt 60 ]; then
    echo "Database did not become ready in time."
    exit 1
  fi
  sleep 2
done

table_count=$(docker exec pms_uat_db psql -U postgres -d pms_uat -tAc \
  "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog','information_schema')")
if [ "${table_count:-0}" -eq 0 ]; then
  dump=""
  if [ -f database/pms_uat.sql ]; then
    dump=database/pms_uat.sql
  elif [ -f database/trackerpro-uat.sql ]; then
    dump=database/trackerpro-uat.sql
  else
    echo "UAT database is empty and no dump file was found."
    echo "Place database/pms_uat.sql in the repo, then run this script again."
    exit 1
  fi
  echo "UAT database is empty. Loading $dump (first time only)"
  # Postgres 16 rejects SET transaction_timeout from a Postgres 18 dump.
  grep -v 'transaction_timeout' "$dump" \
    | docker exec -i pms_uat_db psql -U postgres -d pms_uat -v ON_ERROR_STOP=1
fi

echo "Applying schema update"
docker cp database/schema-update.sql pms_uat_db:/tmp/schema-update.sql
docker exec pms_uat_db psql -U postgres -d pms_uat -v ON_ERROR_STOP=1 -f /tmp/schema-update.sql

echo "Rebuilding the UAT app"
docker compose -f compose/uat.yml -p pms-uat up -d --build

echo "UAT update finished. Database volume was left in place."
echo "App: http://THIS-SERVER:39117"
