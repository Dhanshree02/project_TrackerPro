@echo off
echo ========================================================
echo   Starting BOTH Development AND UAT Simultaneously
echo ========================================================
echo.
echo Starting Shared Database & UAT Stack (Ports 3001, 5195, 5432, 5050)...
docker compose -f docker-compose.uat.yml -p pms_uat up -d
echo.
echo Starting Development Stack (Ports 3000, 5194)...
docker compose -f docker-compose.development.yml -p pms_development up -d
echo.
echo ========================================================
echo  BOTH STACKS ARE RUNNING ON SINGLE DATABASE SERVER!
echo ========================================================
echo  Database:        Port 5432 (pms_development, pms_uat, pms_deployment)
echo  pgAdmin:         http://localhost:5050 (admin@admin.com / clockit)
echo.
echo  Development UI:  http://localhost:3000
echo  Development API: http://localhost:5194/swagger
echo.
echo  UAT UI:          http://localhost:3001
echo  UAT API:         http://localhost:5195/swagger
echo ========================================================
pause
