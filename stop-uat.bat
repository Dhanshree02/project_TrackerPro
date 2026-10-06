@echo off
echo Stopping UAT Stack...
docker compose stop backend_uat frontend_uat
echo UAT stack stopped (PostgreSQL remains running).
