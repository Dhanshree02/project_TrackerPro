@echo off
echo ========================================================
echo           Starting PMS TrackerPro UAT Stack
echo ========================================================
echo.
docker compose -f docker-compose.uat.yml -p pms_uat up -d
echo.
echo ========================================================
echo Database: pms_uat (Port 41763)
echo API:      http://localhost:52814/swagger
echo Frontend: http://localhost:39106
echo pgAdmin:  http://localhost:46382 (osdpkvam@osdpkvam.com / Osdpkvam)
echo ========================================================
pause
