@echo off
echo ========================================================
echo   Starting BOTH Development AND UAT Simultaneously
echo ========================================================
echo.
echo Starting Shared Database & pgAdmin...
echo Starting Development Stack (Ports 3000, 5194)...
echo Starting UAT Stack (Ports 3001, 5195)...
echo.
docker compose up -d
echo.
echo ========================================================
echo  BOTH STACKS ARE RUNNING ON SINGLE DATABASE SERVER!
echo ========================================================
echo  Database:        Port 5432 (trackerpro_development, trackerpro_uat, trackerpro_deployment)
echo  pgAdmin:         http://localhost:5050
echo.
echo  Development UI:  http://localhost:3000
echo  Development API: http://localhost:5194/swagger
echo.
echo  UAT UI:          http://localhost:3001
echo  UAT API:          http://localhost:5195/swagger
echo ========================================================
pause
