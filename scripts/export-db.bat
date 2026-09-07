@echo off
setlocal
cd /d "%~dp0\.."

echo ==============================================================================
echo   PMS TrackerPro - Export Database Dump for Team / Tester
echo ==============================================================================
echo.

:: Check which postgres container is running
set PG_CONTAINER=pms_postgres
docker ps --format "{{.Names}}" | findstr /i "pms_postgres" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker container '%PG_CONTAINER%' is not running!
    echo Please make sure your database container is running before exporting.
    pause
    exit /b 1
)

echo Exporting PostgreSQL database 'trackerpro' to database\trackerpro-final.sql...
docker exec -t %PG_CONTAINER% pg_dump -U postgres -d trackerpro --clean --if-exists > database\trackerpro-final.sql

if %ERRORLEVEL% equ 0 (
    echo [OK] Successfully exported database to database\trackerpro-final.sql!
    echo.
    echo Next steps:
    echo 1. git add database/trackerpro-final.sql
    echo 2. git commit -m "chore: update database dump"
    echo 3. git push origin deployment-phase1
    echo.
    echo The tester will receive this fresh dataset on their next reset.
) else (
    echo [ERROR] Failed to export database dump.
)

echo ==============================================================================
pause
