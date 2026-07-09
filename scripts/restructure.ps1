# =============================================================================
# Project Compass — Repository Restructuring Script
# =============================================================================
# Run from project root: d:\TalaKunchi\Project Compass 12
# Usage: powershell -ExecutionPolicy Bypass -File scripts\restructure.ps1
# =============================================================================

$ErrorActionPreference = "Stop"
$root = "d:\TalaKunchi\Project Compass 12"
Set-Location $root

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Phase 1: Delete Dead Code" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$deleteFiles = @(
    "simple-server.cjs",
    "simple-server.js",
    "wbstabhtml.txt",
    "bun.lock",
    "src\routes\-projects..tsx",
    "src\routes\-wbs-prerequisite-new.tsx",
    "src\routes\customer-detail.`$clientId.tsx"
)

foreach ($f in $deleteFiles) {
    $path = Join-Path $root $f
    if (Test-Path $path) {
        Remove-Item $path -Force
        Write-Host "  DELETED: $f" -ForegroundColor Red
    } else {
        Write-Host "  SKIPPED (not found): $f" -ForegroundColor Yellow
    }
}

# Delete simplified-app directory
$simplifiedApp = Join-Path $root "simplified-app"
if (Test-Path $simplifiedApp) {
    Remove-Item $simplifiedApp -Recurse -Force
    Write-Host "  DELETED: simplified-app/ (entire directory)" -ForegroundColor Red
}

# Clean up pre-created backend files (keep only empty backend/ folder)
$backendApp = Join-Path $root "backend\app"
if (Test-Path $backendApp) {
    Remove-Item $backendApp -Recurse -Force
    Write-Host "  CLEANED: backend/app/ (will be created later)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Phase 2: Create Monorepo Skeleton" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$dirs = @("frontend", "backend", "scripts", "tools")
foreach ($d in $dirs) {
    $path = Join-Path $root $d
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host "  CREATED: $d/" -ForegroundColor Green
    } else {
        Write-Host "  EXISTS: $d/" -ForegroundColor Yellow
    }
}

# Add .keep files so empty dirs are tracked by git
foreach ($d in @("backend", "tools")) {
    $keep = Join-Path $root "$d\.keep"
    if (-not (Test-Path $keep)) {
        New-Item -ItemType File -Path $keep -Force | Out-Null
        Write-Host "  CREATED: $d/.keep" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Phase 3: Move Frontend Files" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$frontendDir = Join-Path $root "frontend"

# Move src/ directory
$srcDir = Join-Path $root "src"
$dstSrc = Join-Path $frontendDir "src"
if ((Test-Path $srcDir) -and -not (Test-Path $dstSrc)) {
    Move-Item $srcDir $dstSrc
    Write-Host "  MOVED: src/ -> frontend/src/" -ForegroundColor Green
} else {
    Write-Host "  SKIPPED: src/ (already moved or not found)" -ForegroundColor Yellow
}

# Move config files
$configFiles = @(
    "package.json",
    "package-lock.json",
    "tsconfig.json",
    "vite.config.ts",
    "eslint.config.js",
    "components.json",
    "wrangler.jsonc"
)

foreach ($f in $configFiles) {
    $srcPath = Join-Path $root $f
    $dstPath = Join-Path $frontendDir $f
    if ((Test-Path $srcPath) -and -not (Test-Path $dstPath)) {
        Move-Item $srcPath $dstPath
        Write-Host "  MOVED: $f -> frontend/$f" -ForegroundColor Green
    } elseif (-not (Test-Path $srcPath)) {
        Write-Host "  SKIPPED (not found): $f" -ForegroundColor Yellow
    } else {
        Write-Host "  SKIPPED (already exists): frontend/$f" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Phase 4: Clean Generated Directories" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$generatedDirs = @("node_modules", "dist", ".tanstack", ".wrangler")
foreach ($d in $generatedDirs) {
    $path = Join-Path $root $d
    if (Test-Path $path) {
        Remove-Item $path -Recurse -Force
        Write-Host "  DELETED: $d/ (will be regenerated in frontend/)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Phase 5: Install & Verify Frontend" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Set-Location $frontendDir
Write-Host "  Running npm install in frontend/..." -ForegroundColor Cyan
npm install
if ($LASTEXITCODE -eq 0) {
    Write-Host "  npm install SUCCESS" -ForegroundColor Green
} else {
    Write-Host "  npm install FAILED — run manually: cd frontend && npm install" -ForegroundColor Red
}

Set-Location $root

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Phase 6: Reorganize Wiki" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$wikiRoot = Join-Path $root "wiki"

# Create wiki subdirectories
$wikiDirs = @("project", "frontend", "modules", "backend", "planning", "guides", "handovers")
foreach ($d in $wikiDirs) {
    $path = Join-Path $wikiRoot $d
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host "  CREATED: wiki/$d/" -ForegroundColor Green
    }
}

# Move wiki files to subdirectories
$wikiMoves = @{
    # project/
    "00_Project_Overview.md" = "project"
    "01_System_Architecture.md" = "project"
    "02_Business_Domain.md" = "project"
    "03_Organization_Hierarchy.md" = "project"
    "04_Roles_and_Permissions.md" = "project"
    "05_Business_Workflows.md" = "project"
    "25_Project_Glossary.md" = "project"
    # frontend/
    "06_UI_Architecture.md" = "frontend"
    "07_Frontend_Architecture.md" = "frontend"
    "08_Module_Analysis.md" = "frontend"
    "29_Known_Frontend_Behavior.md" = "frontend"
    "Frontend_Architecture.md" = "frontend"
    # modules/
    "09_Client_Management.md" = "modules"
    "10_Project_Management.md" = "modules"
    "11_WBS_Management.md" = "modules"
    "12_Resource_Management.md" = "modules"
    "13_Task_Management.md" = "modules"
    "14_Timesheet_Management.md" = "modules"
    "15_Approval_Engine.md" = "modules"
    "16_Notification_System.md" = "modules"
    "17_Health_and_Governance.md" = "modules"
    "18_Finance_Module.md" = "modules"
    "19_Reports_and_Analytics.md" = "modules"
    # backend/
    "20_Database_Design_Draft.md" = "backend"
    "21_API_Design_Draft.md" = "backend"
    "22_Backend_Architecture_Draft.md" = "backend"
    "23_Security_and_RBAC.md" = "backend"
    "24_Audit_Logging.md" = "backend"
    "30_Future_Backend_Implementation.md" = "backend"
    "Backend_Master_Plan.md" = "backend"
    "BACKEND_DEVELOPMENT_PHASES.md" = "backend"
    # planning/
    "26_Open_Questions.md" = "planning"
    "27_Data_Model_Reference.md" = "planning"
    "28_Development_Roadmap.md" = "planning"
    "Repository_Analysis.md" = "planning"
    "Repository_Improvement_Plan.md" = "planning"
    # guides/
    "RUNNING_THE_PROJECT.md" = "guides"
    "REPOSITORY_SETUP.md" = "guides"
    "PROJECT_RECOVERY_GUIDE.md" = "guides"
    "AI_DEVELOPMENT_WORKFLOW.md" = "guides"
    "AI_HANDOVER_TEMPLATE.md" = "guides"
    "KNOWLEDGE_SYNC_RULES.md" = "guides"
    "RESTRUCTURING_PLAN.md" = "guides"
    # handovers/
    "AI_HANDOVER.md" = "handovers"
}

foreach ($file in $wikiMoves.Keys) {
    $srcPath = Join-Path $wikiRoot $file
    $dstDir = Join-Path $wikiRoot $wikiMoves[$file]
    $dstPath = Join-Path $dstDir $file
    if ((Test-Path $srcPath) -and -not (Test-Path $dstPath)) {
        Move-Item $srcPath $dstPath
        Write-Host "  MOVED: wiki/$file -> wiki/$($wikiMoves[$file])/$file" -ForegroundColor Green
    } elseif (-not (Test-Path $srcPath)) {
        Write-Host "  SKIPPED (not found): wiki/$file" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " RESTRUCTURING COMPLETE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. cd frontend && npm run dev   (verify frontend works)" -ForegroundColor White
Write-Host "  2. Open wiki/ in Obsidian       (verify links work)" -ForegroundColor White
Write-Host "  3. git add -A && git commit -m 'chore: restructure to monorepo'" -ForegroundColor White
Write-Host ""
