@echo off
setlocal
cd /d "%~dp0\.."

echo ==============================================================================
echo   PMS TrackerPro - Tester Environment (Port 3001)
echo ==============================================================================
echo.

:: Check Docker
docker info >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker is not running!
    echo Please start Docker Desktop and run this script again.
    echo.
    pause
    exit /b 1
)

echo [1/3] Checking for latest stable updates from deployment-phase1...
git fetch origin deployment-phase1 >nul 2>&1
if %ERRORLEVEL% equ 0 (
    git checkout deployment-phase1 >nul 2>&1
    git pull origin deployment-phase1
    echo [OK] Branch deployment-phase1 is up to date.
) else (
    echo [INFO] Running in offline / standalone mode (Git remote not reachable).
)

echo.
echo [2/3] Building and starting Docker containers (Frontend on Port 3001)...
docker compose -f docker-compose.tester-port3001.yml up -d --build

echo.
echo [3/3] Checking running services...
docker compose -f docker-compose.tester-port3001.yml ps

echo.
echo ==============================================================================
echo   Application Ready for Testing on Port 3001!
echo ==============================================================================
echo   * Frontend Web App:     http://localhost:3001
echo   * Backend Swagger API:  http://localhost:5194/swagger
echo   * Database Manager:     http://localhost:5050  (admin@admin.com / clockit)
echo.
echo   To stop testing:        docker compose -f docker-compose.tester-port3001.yml down
echo   To reset fresh DB:      scripts\tester-reset-db.bat
echo ==============================================================================
echo.

start http://localhost:3001

pause
