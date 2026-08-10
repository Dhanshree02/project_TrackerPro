# Setup Script for Project Compass ASP.NET Core PostgreSQL Database
# Usage: .\scripts\setup-db.ps1

Write-Host "🚀 Initializing Project Compass ASP.NET Core & PostgreSQL Environment..." -ForegroundColor Cyan

Set-Location "$PSScriptRoot\..\apps\backend"

Write-Host "📦 Restoring .NET NuGet packages..." -ForegroundColor Cyan
dotnet restore

Write-Host "⚡ Running Entity Framework Core Migrations on PostgreSQL database..." -ForegroundColor Cyan
dotnet ef database update

Write-Host "✨ Setup complete! You can start the ASP.NET Core Web API with:" -ForegroundColor Green
Write-Host "   cd apps/backend" -ForegroundColor White
Write-Host "   dotnet run" -ForegroundColor White
