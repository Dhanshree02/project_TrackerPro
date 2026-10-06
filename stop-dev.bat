@echo off
echo Stopping Development Stack...
docker compose stop backend_dev frontend_dev
echo Development stack stopped (PostgreSQL remains running).
