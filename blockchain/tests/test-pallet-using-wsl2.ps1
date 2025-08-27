# PowerShell script to run individual Cargo tests using WSL2 for proper Substrate development
# This script uses the run-wsl2-command.ps1 runner for reliable WSL2 execution
# Usage: .\test-pallet-using-wsl2.ps1 "-p pallet-reputation-system --lib"
# Usage: .\test-pallet-using-wsl2.ps1 "-p pallet-reputation-system --lib create_rating_works"

param(
    [string]$TestArgs = "",
    [switch]$ShowDetails = $false
)

if ($TestArgs -eq "") {
    Write-Host "🧪 Individual Pallet Test Script for WSL2" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\test-pallet-using-wsl2.ps1 `"-p pallet-name --lib`""
    Write-Host "  .\test-pallet-using-wsl2.ps1 `"-p pallet-name --lib test_name`""
    Write-Host "  .\test-pallet-using-wsl2.ps1 `"--workspace`""
    Write-Host "  .\test-pallet-using-wsl2.ps1 `"-p pallet-name --lib`" -ShowDetails"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\test-pallet-using-wsl2.ps1 `"-p pallet-reputation-system --lib`""
    Write-Host "  .\test-pallet-using-wsl2.ps1 `"-p pallet-reputation-system --lib create_rating_works`""
    Write-Host "  .\test-pallet-using-wsl2.ps1 `"-p pallet-learning-interactions`""
    Write-Host "  .\test-pallet-using-wsl2.ps1 `"--manifest-path runtime/Cargo.toml --lib`""
    Write-Host ""
    Write-Host "Available Pallets:" -ForegroundColor Yellow
    Write-Host "  - pallet-learning-interactions"
    Write-Host "  - pallet-life-learning-passport"
    Write-Host "  - pallet-reputation-system"
    Write-Host ""
    Write-Host "Setup Help:" -ForegroundColor Yellow
    Write-Host "  If WSL2/Rust is not set up, run: .\setup-wsl2-substrate.ps1 -Help"
    Write-Host ""
    exit 1
}

Write-Host "🧪 Running Substrate Test via WSL2" -ForegroundColor Cyan
Write-Host "Command: cargo test $TestArgs" -ForegroundColor White

# Execute the test command using the reliable WSL2 runner
$wslRunnerPath = Join-Path $PSScriptRoot "run-wsl2-command.ps1"
$exitCode = 0

try {
    if ($ShowDetails) {
        & $wslRunnerPath "cargo test $TestArgs" -ShowDetails
    } else {
        & $wslRunnerPath "cargo test $TestArgs"
    }
    $exitCode = $LASTEXITCODE
} catch {
    Write-Host "❌ Failed to execute WSL2 command: $($_.Exception.Message)" -ForegroundColor Red
    $exitCode = 1
}

if ($exitCode -eq 0) {
    Write-Host "✅ Tests completed successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Tests failed with exit code: $exitCode" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  1. Check if WSL2 is installed: .\setup-wsl2-substrate.ps1 -Status" -ForegroundColor White
    Write-Host "  2. Install WSL2 if needed: .\setup-wsl2-substrate.ps1 -Install" -ForegroundColor White
    Write-Host "  3. Setup Rust in WSL2: .\setup-wsl2-substrate.ps1 -SetupRust" -ForegroundColor White
    Write-Host "  4. Test the environment: .\setup-wsl2-substrate.ps1 -Test" -ForegroundColor White
}

exit $exitCode