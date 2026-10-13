@echo off
echo Stopping Development App...
docker compose -f docker-compose.development.yml -p pms_development down
echo Development app stopped.
