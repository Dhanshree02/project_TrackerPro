@echo off
echo ========================================================
echo           Starting PMS TrackerPro UAT Stack
echo ========================================================
echo.
echo Database: trackerpro_uat (Port 5432)
echo API:      http://localhost:5195
echo Frontend: http://localhost:3001
echo pgAdmin:  http://localhost:5050
echo.
docker compose up -d postgres_db pgadmin backend_uat frontend_uat
echo.
echo UAT stack is running!
pause
