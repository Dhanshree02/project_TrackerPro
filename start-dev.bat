@echo off
echo ========================================================
echo        Starting PMS TrackerPro DEVELOPMENT Stack
echo ========================================================
echo.
echo Starting Shared Database & pgAdmin...
docker compose -f docker-compose.uat.yml -p pms_uat up -d db pgadmin
echo.
echo Starting Development App...
docker compose -f docker-compose.development.yml -p pms_development up -d
echo.
echo ========================================================
echo Database: pms_development (Port 5432)
echo API:      http://localhost:5194/swagger
echo Frontend: http://localhost:3000
echo pgAdmin:  http://localhost:5050 (admin@admin.com / clockit)
echo ========================================================
pause
