# Stop PostgreSQL Server
$ErrorActionPreference = "Stop"
$pgDir = "$env:LOCALAPPDATA\Programs\PostgreSQL"
$binDir = "$pgDir\pgsql\bin"
$dataDir = "$pgDir\data"

if (-not (Test-Path "$binDir\pg_ctl.exe")) {
    Write-Error "PostgreSQL not found at $binDir"
    exit 1
}

Write-Host "Stopping PostgreSQL server..."
& "$binDir\pg_ctl.exe" -D "$dataDir" stop
Write-Host "PostgreSQL server stopped."
