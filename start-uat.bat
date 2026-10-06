@echo off
echo ========================================================
echo           Starting PMS TrackerPro UAT Stack
echo ========================================================
echo.
docker compose -f docker-compose.uat.yml -p pms_uat up -d
echo.
echo ========================================================
echo Database: pms_uat (Port 5432)
echo API:      http://localhost:5195/swagger
echo Frontend: http://localhost:3001
echo pgAdmin:  http://localhost:5050 (admin@admin.com / clockit)
echo ========================================================
pause
