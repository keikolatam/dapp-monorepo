# WSL2 Substrate Development Setup and Management Script
# This script helps set up and manage WSL2 for Substrate development
# Usage: .\setup-wsl2-substrate.ps1 [--install] [--setup-rust] [--test] [--status] [--help]

param(
    [switch]$Install = $false,
    [switch]$SetupRust = $false,
    [switch]$Test = $false,
    [switch]$Status = $false,
    [switch]$Help = $false
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
        "Ubuntu-24.04",  # Ubuntu 24.04 LTS (Noble Numbat)
        "Ubuntu-22.04",  # Ubuntu 22.04 LTS (Jammy Jellyfish)
        "Ubuntu-20.04",  # Ubuntu 20.04 LTS (Focal Fossa)
        "Ubuntu-18.04",  # Ubuntu 18.04 LTS (Bionic Beaver)
        "Ubuntu"         # Generic Ubuntu (latest)
    )
    
    foreach ($distro in $preferredDistros) {
        if (Test-WSLDistribution $distro) {
            return $distro
        }
    }
    
    return $null
}

# Function to check WSL2 status
function Get-WSL2Status {
    Write-Host "🔍 Checking WSL2 Status..." -ForegroundColor $colors.Header
    
    # Check if WSL is available
    $wslCheck = wsl --status 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ WSL2 is not available or not installed" -ForegroundColor $colors.Error
        return $false
    }
    
    Write-Host "✅ WSL2 is available" -ForegroundColor $colors.Success
    
    # List available distributions
    Write-Host "📋 Available WSL distributions:" -ForegroundColor $colors.Info
    wsl --list --verbose
    
    # Check for Ubuntu
    $ubuntuDistro = Get-BestUbuntuDistro
    if ($null -eq $ubuntuDistro) {
        Write-Host "❌ No Ubuntu distribution found" -ForegroundColor $colors.Error
        return $false
    }
    
    Write-Host "✅ Found Ubuntu distribution: $ubuntuDistro" -ForegroundColor $colors.Success
    
    # Check if Rust is installed
    Write-Host "🦀 Checking Rust installation in $ubuntuDistro..." -ForegroundColor $colors.Info
    $rustCheck = wsl -d $ubuntuDistro bash -c "command -v cargo" 2>$null
    if ($LASTEXITCODE -eq 0) {
        $rustVersion = wsl -d $ubuntuDistro bash -c "rustc --version" 2>$null
        Write-Host "✅ Rust is installed: $rustVersion" -ForegroundColor $colors.Success
        
        # Check for wasm32 target
        $wasmTarget = wsl -d $ubuntuDistro bash -c "rustup target list --installed | grep wasm32-unknown-unknown" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ wasm32-unknown-unknown target is installed" -ForegroundColor $colors.Success
        } else {
            Write-Host "⚠️  wasm32-unknown-unknown target is missing" -ForegroundColor $colors.Warning
        }
    } else {
        Write-Host "❌ Rust is not installed in $ubuntuDistro" -ForegroundColor $colors.Error
        return $false
    }
    
    return $true
}

# Function to install WSL2 and Ubuntu
function Install-WSL2Ubuntu {
    Write-Host "🚀 Installing WSL2 with Ubuntu..." -ForegroundColor $colors.Header
    
    # Check if running as administrator
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "❌ This operation requires administrator privileges" -ForegroundColor $colors.Error
        Write-Host "Please run PowerShell as Administrator and try again" -ForegroundColor $colors.Warning
        return $false
    }
    
    try {
        Write-Host "📦 Installing WSL2 with Ubuntu 24.04 LTS..." -ForegroundColor $colors.Info
        wsl --install -d Ubuntu-24.04
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ WSL2 and Ubuntu 24.04 installation initiated" -ForegroundColor $colors.Success
            Write-Host "⚠️  You may need to restart your computer to complete the installation" -ForegroundColor $colors.Warning
            Write-Host "After restart, run: .\setup-wsl2-substrate.ps1 -SetupRust" -ForegroundColor $colors.Info
            return $true
        } else {
            Write-Host "❌ Failed to install WSL2/Ubuntu" -ForegroundColor $colors.Error
            return $false
        }
    }
    catch {
        Write-Host "❌ Error during installation: $($_.Exception.Message)" -ForegroundColor $colors.Error
        return $false
    }
}

# Function to setup Rust in WSL2
function Setup-RustInWSL2 {
    Write-Host "🦀 Setting up Rust in WSL2..." -ForegroundColor $colors.Header
    
    $ubuntuDistro = Get-BestUbuntuDistro
    if ($null -eq $ubuntuDistro) {
        Write-Host "❌ No Ubuntu distribution found. Please install WSL2 first." -ForegroundColor $colors.Error
        return $false
    }
    
    Write-Host "📦 Installing system dependencies in $ubuntuDistro..." -ForegroundColor $colors.Info
    
    # Install system dependencies first
    $systemDepsCommand = @"
sudo apt update && 
sudo apt install -y build-essential pkg-config libssl-dev git curl && 
echo "System dependencies installed successfully"
"@
    
    wsl -d $ubuntuDistro bash -c $systemDepsCommand
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️  System dependencies installation had issues, but continuing..." -ForegroundColor $colors.Warning
    }
    
    Write-Host "🦀 Installing Rust in $ubuntuDistro..." -ForegroundColor $colors.Info
    
    # Install Rust with all necessary components for Substrate development
    $rustInstallCommand = @"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && 
source ~/.cargo/env && 
rustup default stable && 
rustup update && 
rustup component add rust-src && 
rustup component add rustfmt && 
rustup component add clippy && 
rustup target add wasm32-unknown-unknown && 
rustup target add x86_64-unknown-linux-gnu && 
rustup toolchain install nightly && 
rustup component add rust-src --toolchain nightly && 
echo "Rust installation with all components completed successfully"
"@
    
    wsl -d $ubuntuDistro bash -c $rustInstallCommand
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Rust setup completed successfully" -ForegroundColor $colors.Success
        
        # Verify installation
        Write-Host "🔍 Verifying Rust installation..." -ForegroundColor $colors.Info
        $rustVersion = wsl -d $ubuntuDistro bash -c "source ~/.cargo/env && rustc --version" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Rust verification successful: $rustVersion" -ForegroundColor $colors.Success
            return $true
        } else {
            Write-Host "⚠️  Rust installed but verification failed. You may need to restart your terminal." -ForegroundColor $colors.Warning
            return $true
        }
    } else {
        Write-Host "❌ Failed to setup Rust" -ForegroundColor $colors.Error
        return $false
    }
}

# Function to test Substrate build
function Test-SubstrateBuild {
    Write-Host "🧪 Testing Substrate build in WSL2..." -ForegroundColor $colors.Header
    
    $ubuntuDistro = Get-BestUbuntuDistro
    if ($null -eq $ubuntuDistro) {
        Write-Host "❌ No Ubuntu distribution found" -ForegroundColor $colors.Error
        return $false
    }
    
    # Get the backend path in WSL2 format
    $backendPath = Split-Path -Parent $PSScriptRoot
    $wslBackendPath = $backendPath -replace '^([A-Z]):', '/mnt/$1' -replace '\\', '/' | ForEach-Object { $_.ToLower() }
    
    Write-Host "📁 Testing in directory: $wslBackendPath" -ForegroundColor $colors.Info
    
    # Set up environment for proc-macro compilation
    Write-Host "🔧 Configuring Rust environment for Substrate..." -ForegroundColor $colors.Info
    $envSetupCommand = @"
cd '$wslBackendPath' && 
source ~/.cargo/env && 
export RUSTFLAGS='-C target-cpu=native' && 
export CARGO_TARGET_DIR='target' && 
rustup show
"@
    wsl -d $ubuntuDistro bash -c $envSetupCommand
    
    # Test cargo check
    Write-Host "🔍 Running cargo check..." -ForegroundColor $colors.Info
    wsl -d $ubuntuDistro bash -c "cd '$wslBackendPath' && source ~/.cargo/env && cargo check"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Cargo check passed" -ForegroundColor $colors.Success
        
        # Test a simple pallet
        Write-Host "🧪 Testing reputation system pallet..." -ForegroundColor $colors.Info
        wsl -d $ubuntuDistro bash -c "cd '$wslBackendPath' && source ~/.cargo/env && cargo test -p pallet-reputation-system --lib create_rating_works"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Pallet test passed! Substrate development environment is ready." -ForegroundColor $colors.Success
            return $true
        } else {
            Write-Host "⚠️  Cargo check passed but pallet test failed. This may be due to proc-macro compilation issues." -ForegroundColor $colors.Warning
            Write-Host "💡 Try running: cargo clean && cargo build --release" -ForegroundColor $colors.Info
            return $false
        }
    } else {
        Write-Host "❌ Cargo check failed. Check Rust installation and dependencies." -ForegroundColor $colors.Error
        Write-Host "💡 Common fixes:" -ForegroundColor $colors.Warning
        Write-Host "  - Install build essentials: sudo apt update && sudo apt install build-essential" -ForegroundColor $colors.Info
        Write-Host "  - Install additional dependencies: sudo apt install pkg-config libssl-dev" -ForegroundColor $colors.Info
        return $false
    }
}

# Function to show help
function Show-Help {
    Write-Host "🛠️  WSL2 Substrate Development Setup Script" -ForegroundColor $colors.Header
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor $colors.Info
    Write-Host "  .\setup-wsl2-substrate.ps1 -Status      # Check current WSL2/Rust status"
    Write-Host "  .\setup-wsl2-substrate.ps1 -Install     # Install WSL2 with Ubuntu (requires admin)"
    Write-Host "  .\setup-wsl2-substrate.ps1 -SetupRust   # Install Rust in existing WSL2"
    Write-Host "  .\setup-wsl2-substrate.ps1 -Test        # Test Substrate build environment"
    Write-Host "  .\setup-wsl2-substrate.ps1 -Help        # Show this help"
    Write-Host ""
    Write-Host "Typical Setup Process:" -ForegroundColor $colors.Warning
    Write-Host "  1. Run as Administrator: .\setup-wsl2-substrate.ps1 -Install"
    Write-Host "  2. Restart computer if prompted"
    Write-Host "  3. Run: .\setup-wsl2-substrate.ps1 -SetupRust"
    Write-Host "  4. Run: .\setup-wsl2-substrate.ps1 -Test"
    Write-Host ""
    Write-Host "After setup, use the test scripts:" -ForegroundColor $colors.Info
    Write-Host "  .\test-pallet-using-wsl2.ps1 `"-p pallet-reputation-system --lib`""
    Write-Host "  .\tests-building-on-windows.ps1"
    Write-Host ""
}

# Main execution
Write-Host "🚀 WSL2 Substrate Development Manager" -ForegroundColor $colors.Header
Write-Host "=" * 50 -ForegroundColor $colors.Separator

if ($Help) {
    Show-Help
    exit 0
}

if ($Status) {
    $statusOk = Get-WSL2Status
    exit $(if ($statusOk) { 0 } else { 1 })
}

if ($Install) {
    $installOk = Install-WSL2Ubuntu
    exit $(if ($installOk) { 0 } else { 1 })
}

if ($SetupRust) {
    $setupOk = Setup-RustInWSL2
    exit $(if ($setupOk) { 0 } else { 1 })
}

if ($Test) {
    $testOk = Test-SubstrateBuild
    exit $(if ($testOk) { 0 } else { 1 })
}

# If no specific action, show status and help
Write-Host "No specific action requested. Showing current status:" -ForegroundColor $colors.Info
Write-Host ""
Get-WSL2Status
Write-Host ""
Write-Host "For more options, run: .\setup-wsl2-substrate.ps1 -Help" -ForegroundColor $colors.Info