# Install analysis tools for code review (Windows PowerShell)
# Usage: .\scripts\install-tools.ps1

$ErrorActionPreference = "Stop"

$TOOLS_DIR = ".\tools"
$REPORTS_DIR = "$TOOLS_DIR\reports"

Write-Host "=== Installing Code Analysis Tools ===" -ForegroundColor Cyan

# Create directories
New-Item -ItemType Directory -Force -Path $TOOLS_DIR | Out-Null
New-Item -ItemType Directory -Force -Path $REPORTS_DIR | Out-Null

# 1. Install Semgrep via pip
Write-Host ""
Write-Host "[1/2] Installing Semgrep..." -ForegroundColor Yellow

$semgrepInstalled = $false
try {
    $version = & semgrep --version 2>$null
    if ($version) {
        Write-Host "  Semgrep already installed: $version" -ForegroundColor Green
        $semgrepInstalled = $true
    }
} catch {}

if (-not $semgrepInstalled) {
    try {
        & pip install semgrep
        Write-Host "  Semgrep installed successfully" -ForegroundColor Green
    } catch {
        try {
            & python -m pip install semgrep
            Write-Host "  Semgrep installed successfully" -ForegroundColor Green
        } catch {
            Write-Host "  ERROR: pip not found. Install Python first." -ForegroundColor Red
            exit 1
        }
    }
}

# 2. Install PMD standalone
Write-Host ""
Write-Host "[2/2] Installing PMD..." -ForegroundColor Yellow

$PMD_VERSION = "7.0.0"
$PMD_DIR = "$TOOLS_DIR\pmd-bin-$PMD_VERSION"

if (Test-Path $PMD_DIR) {
    Write-Host "  PMD already installed at $PMD_DIR" -ForegroundColor Green
} else {
    $PMD_URL = "https://github.com/pmd/pmd/releases/download/pmd_releases%2F$PMD_VERSION/pmd-dist-$PMD_VERSION-bin.zip"
    $PMD_ZIP = "$TOOLS_DIR\pmd.zip"

    Write-Host "  Downloading PMD $PMD_VERSION..."
    Invoke-WebRequest -Uri $PMD_URL -OutFile $PMD_ZIP

    Write-Host "  Extracting..."
    Expand-Archive -Path $PMD_ZIP -DestinationPath $TOOLS_DIR -Force
    Remove-Item $PMD_ZIP

    Write-Host "  PMD installed at $PMD_DIR" -ForegroundColor Green
}

# Verify
Write-Host ""
Write-Host "=== Installation Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Tools Status:" -ForegroundColor White
Write-Host "  Semgrep: Run 'semgrep --version' to verify"
Write-Host "  PMD: $PMD_DIR\bin\pmd.bat --version"
Write-Host ""
Write-Host "Usage:" -ForegroundColor White
Write-Host "  # Semgrep"
Write-Host "  semgrep --config 'p/java' .\src"
Write-Host ""
Write-Host "  # PMD"
Write-Host "  $PMD_DIR\bin\pmd.bat check -d .\src -R rulesets/java/quickstart.xml -f json"
