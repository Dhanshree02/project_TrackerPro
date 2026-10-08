#!/bin/sh
# Fresh Postgres volume only. Loads one SQL file into each database.
set -eu

load_db() {
  db="$1"
  exists="$(psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '${db}'")"
  if [ "$exists" != "1" ]; then
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres -c "CREATE DATABASE ${db} OWNER ${POSTGRES_USER}"
  fi
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$db" -f "/sql/${db}.sql"
}

load_db pms_development
load_db pms_uat
load_db pms_deployment
