# Start PostgreSQL Server
$ErrorActionPreference = "Stop"
$pgDir = "$env:LOCALAPPDATA\Programs\PostgreSQL"
$binDir = "$pgDir\pgsql\bin"
$dataDir = "$pgDir\data"

if (-not (Test-Path "$binDir\pg_ctl.exe")) {
    Write-Error "PostgreSQL not found at $binDir"
    exit 1
}

Write-Host "Starting PostgreSQL server..."
& "$binDir\pg_ctl.exe" -D "$dataDir" -l "$dataDir\server.log" start
Write-Host "PostgreSQL server started. Host: localhost:5432, User: postgres"
