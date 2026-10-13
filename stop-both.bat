@echo off
echo Stopping all TrackerPro services...
docker compose -f docker-compose.development.yml -p pms_development down
docker compose -f docker-compose.uat.yml -p pms_uat down
echo All services stopped.
