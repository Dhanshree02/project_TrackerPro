@echo off
setlocal
cd /d "%~dp0"

echo [1/3] Pulling latest code from origin production...
git pull origin production
if errorlevel 1 (
    echo ERROR: git pull origin production failed.
    pause
    exit /b 1
)

echo [2/3] Ensuring required Docker network and volume exist...
docker network inspect pms_shared >nul 2>&1
if errorlevel 1 (
    docker network create pms_shared
    if errorlevel 1 (
        echo ERROR: Failed to create network pms_shared.
        pause
        exit /b 1
    )
)

docker volume inspect pms-production-storage >nul 2>&1
if errorlevel 1 (
    docker volume create pms-production-storage
    if errorlevel 1 (
        echo ERROR: Failed to create volume pms-production-storage.
        pause
        exit /b 1
    )
)

echo [3/3] Rebuilding and starting production Docker containers...
docker compose -f compose/production.yml -p pms-production up -d --build
if errorlevel 1 (
    echo ERROR: Docker Compose build/up failed.
    pause
    exit /b 1
)

echo.
echo Production rebuild complete.
echo App: http://localhost:39127
echo API: http://localhost:52827/swagger
pause
exit /b 0
