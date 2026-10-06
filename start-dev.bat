@echo off
echo ========================================================
echo        Starting PMS TrackerPro DEVELOPMENT Stack
echo ========================================================
echo.
echo Database: trackerpro_development (Port 5432)
echo API:      http://localhost:5194
echo Frontend: http://localhost:3000
echo pgAdmin:  http://localhost:5050
echo.
docker compose up -d postgres_db pgadmin backend_dev frontend_dev
echo.
echo Development stack is running!
pause
