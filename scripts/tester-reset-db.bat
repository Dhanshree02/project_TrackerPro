@echo off
setlocal
cd /d "%~dp0\.."

echo ==============================================================================
echo   PMS TrackerPro - Database Reset (Tester)
echo ==============================================================================
echo.
echo WARNING: This will delete the tester database container volume and
echo re-seed a completely fresh database from trackerpro-final.sql.
echo.
set /p CONFIRM="Are you sure you want to reset the database? (Y/N): "
if /i "%CONFIRM%" neq "Y" (
    echo Reset cancelled.
    pause
    exit /b 0
)

echo.
echo Stopping and removing tester containers and database volume...
docker compose -f docker-compose.tester-port3001.yml down -v >nul 2>&1
docker compose -f docker-compose.tester.yml down -v >nul 2>&1

echo.
echo Database has been reset! Run your start script (tester-start.bat or tester-start-port3001.bat) to launch fresh.
echo.
pause
