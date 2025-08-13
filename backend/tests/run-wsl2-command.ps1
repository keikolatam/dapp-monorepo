# Direct WSL2 Command Execution Script for Substrate Development
# This script provides a reliable way to execute commands in WSL2 Ubuntu
# Usage: .\run-wsl2-command.ps1 "cargo test -p pallet-reputation-system --lib"

param(
    [Parameter(Mandatory=$true)]
    [string]$Command,
    [string]$WorkingDirectory = "",
    [switch]$ShowDetails = $false
)

# Color scheme
$colors = @{
    Header = "Cyan"
    Success = "Green"
    Error = "Red"
    Warning = "Yellow"
    Info = "White"
    Separator = "DarkGray"
}

# Function to check if a WSL distribution is available
function Test-WSLDistribution {
    param([string]$DistroName)
    
    $installedDistros = wsl --list --quiet 2>$null
    if ($LASTEXITCODE -eq 0) {
        return $installedDistros -contains $DistroName
    }
    return $false
}

# Function to get the best available Ubuntu distribution
function Get-BestUbuntuDistro {
    $preferredDistros = @(
        "Ubuntu-24.04",
        "Ubuntu-22.04", 
        "Ubuntu-20.04",
        "Ubuntu-18.04",
        "Ubuntu"
    )
    
    foreach ($distro in $preferredDistros) {
        if (Test-WSLDistribution $distro) {
            return $distro
        }
    }
    
    return $null
}

# Main execution
if ($ShowDetails) {
    Write-Host "🐧 WSL2 Command Executor" -ForegroundColor $colors.Header
    Write-Host "Command: $Command" -ForegroundColor $colors.Info
}

# Check WSL2 availability
$wslCheck = wsl --status 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ WSL2 is not available. Please install WSL2 first:" -ForegroundColor $colors.Error
    Write-Host "  Run: .\setup-wsl2-substrate.ps1 -Install" -ForegroundColor $colors.Warning
    exit 1
}

# Find Ubuntu distribution
$ubuntuDistro = Get-BestUbuntuDistro
if ($null -eq $ubuntuDistro) {
    Write-Host "❌ No Ubuntu distribution found. Available distributions:" -ForegroundColor $colors.Error
    wsl --list --verbose
    Write-Host "Install Ubuntu with: wsl --install -d Ubuntu-24.04" -ForegroundColor $colors.Warning
    exit 1
}

if ($ShowDetails) {
    Write-Host "🐧 Using WSL2 distribution: $ubuntuDistro" -ForegroundColor $colors.Success
}

# Determine working directory
if ($WorkingDirectory -eq "") {
    # Default to backend directory
    $backendPath = Split-Path -Parent $PSScriptRoot
    $wslPath = $backendPath -replace '^([A-Z]):', '/mnt/$1' -replace '\\', '/' | ForEach-Object { $_.ToLower() }
} else {
    # Convert provided Windows path to WSL path
    $wslPath = $WorkingDirectory -replace '^([A-Z]):', '/mnt/$1' -replace '\\', '/' | ForEach-Object { $_.ToLower() }
}

if ($ShowDetails) {
    Write-Host "📁 Working directory: $wslPath" -ForegroundColor $colors.Info
}

# Check if Rust is available
if ($ShowDetails) {
    Write-Host "🔍 Checking Rust installation..." -ForegroundColor $colors.Info
}

$rustCheck = wsl -d $ubuntuDistro bash -c "source ~/.cargo/env 2>/dev/null; command -v cargo" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Rust/Cargo not found in $ubuntuDistro" -ForegroundColor $colors.Error
    Write-Host "Please install Rust first:" -ForegroundColor $colors.Warning
    Write-Host "  Run: .\setup-wsl2-substrate.ps1 -SetupRust" -ForegroundColor $colors.Warning
    exit 1
}

if ($ShowDetails) {
    Write-Host "✅ Rust is available" -ForegroundColor $colors.Success
    Write-Host "🚀 Executing command..." -ForegroundColor $colors.Info
}

# Execute the command in WSL2
$fullCommand = "cd '$wslPath' && source ~/.cargo/env && $Command"
wsl -d $ubuntuDistro bash -c $fullCommand

$exitCode = $LASTEXITCODE
if ($ShowDetails) {
    if ($exitCode -eq 0) {
        Write-Host "✅ Command completed successfully" -ForegroundColor $colors.Success
    } else {
        Write-Host "❌ Command failed with exit code: $exitCode" -ForegroundColor $colors.Error
    }
}

exit $exitCode