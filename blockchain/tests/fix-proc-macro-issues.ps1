# Script to fix proc-macro compilation issues in WSL2
# This addresses the "cannot produce proc-macro" error for aquamarine and other crates

param(
    [switch]$Help = $false
)

if ($Help) {
    Write-Host "🔧 Proc-macro Fix Script for WSL2 Substrate Development" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "This script fixes common proc-macro compilation issues in WSL2:" -ForegroundColor Yellow
    Write-Host "  - Installs native Linux toolchain components" -ForegroundColor White
    Write-Host "  - Configures proper target settings" -ForegroundColor White
    Write-Host "  - Sets up environment variables for cross-compilation" -ForegroundColor White
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\fix-proc-macro-issues.ps1" -ForegroundColor White
    Write-Host ""
    exit 0
}

# Color scheme
$colors = @{
    Header = "Cyan"
    Success = "Green"
    Error = "Red"
    Warning = "Yellow"
    Info = "White"
}

Write-Host "🔧 Fixing proc-macro compilation issues..." -ForegroundColor $colors.Header

# Get WSL2 command runner
$wslRunnerPath = Join-Path $PSScriptRoot "run-wsl2-command.ps1"

if (-not (Test-Path $wslRunnerPath)) {
    Write-Host "❌ WSL2 command runner not found: $wslRunnerPath" -ForegroundColor $colors.Error
    exit 1
}

Write-Host "📦 Installing additional system dependencies..." -ForegroundColor $colors.Info
& $wslRunnerPath "sudo apt update && sudo apt install -y gcc-multilib libc6-dev" -ShowDetails

Write-Host "🦀 Installing additional Rust components..." -ForegroundColor $colors.Info
$rustFixCommand = @"
source ~/.cargo/env && 
rustup toolchain install stable-x86_64-unknown-linux-gnu && 
rustup component add proc-macro --toolchain stable-x86_64-unknown-linux-gnu && 
rustup default stable-x86_64-unknown-linux-gnu && 
echo "Rust proc-macro components installed successfully"
"@

& $wslRunnerPath $rustFixCommand -ShowDetails

Write-Host "⚙️  Configuring Cargo for proper proc-macro compilation..." -ForegroundColor $colors.Info
$cargoConfigCommand = @"
mkdir -p ~/.cargo && 
cat > ~/.cargo/config.toml << 'EOF'
[build]
target = "x86_64-unknown-linux-gnu"

[target.x86_64-unknown-linux-gnu]
linker = "gcc"

[env]
CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER = "gcc"
EOF
echo "Cargo configuration updated"
"@

& $wslRunnerPath $cargoConfigCommand -ShowDetails

Write-Host "🧹 Cleaning previous build artifacts..." -ForegroundColor $colors.Info
& $wslRunnerPath "cargo clean" -ShowDetails

Write-Host "🧪 Testing proc-macro compilation..." -ForegroundColor $colors.Info
$testResult = & $wslRunnerPath "cargo check -p pallet-reputation-system" -ShowDetails

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Proc-macro compilation fix successful!" -ForegroundColor $colors.Success
    Write-Host "💡 You can now run tests normally with the WSL2 scripts." -ForegroundColor $colors.Info
} else {
    Write-Host "⚠️  Proc-macro fix may need additional steps." -ForegroundColor $colors.Warning
    Write-Host "💡 Try running: cargo update && cargo clean && cargo check" -ForegroundColor $colors.Info
    Write-Host "💡 If issues persist, consider using: cargo +nightly check" -ForegroundColor $colors.Info
}

Write-Host "🏁 Proc-macro fix script completed." -ForegroundColor $colors.Header