@echo off
setlocal
cd /d "%~dp0\.."

echo Pulling origin/production
git pull origin production
if errorlevel 1 exit /b 1

echo Starting the production database without removing its volume
docker network inspect pms_shared >nul 2>&1
if errorlevel 1 docker network create pms_shared
docker volume inspect pms-production-storage >nul 2>&1
if errorlevel 1 docker volume create pms-production-storage
docker compose -f compose/production.yml -p pms-production up -d db
if errorlevel 1 exit /b 1

echo Applying schema update
docker cp database\schema-update.sql pms_production_db:/tmp/schema-update.sql
if errorlevel 1 exit /b 1
docker exec pms_production_db psql -U postgres -d pms_production -v ON_ERROR_STOP=1 -f /tmp/schema-update.sql
if errorlevel 1 exit /b 1

echo Rebuilding the production app
docker compose -f compose/production.yml -p pms-production up -d --build
if errorlevel 1 exit /b 1

echo Production update finished. Database volume was left in place.
exit /b 0
