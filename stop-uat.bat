@echo off
echo Stopping UAT Stack...
docker compose -f docker-compose.uat.yml -p pms_uat down
echo UAT stack stopped.
