# Comprehensive Substrate Testing Script for Windows using WSL2
# This script tests all pallets, runtime, and node components in the Keiko project
# Usage: .\tests-building-on-windows.ps1 [--verbose] [--fast] [--help]

param(
    [switch]$Verbose = $false,
    [switch]$Fast = $false,
    [switch]$Help = $false
)

# Show help information
if ($Help) {
    Write-Host "🧪 Keiko Substrate Comprehensive Test Suite" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\tests-building-on-windows.ps1                # Run all tests"
    Write-Host "  .\tests-building-on-windows.ps1 -Verbose       # Run with detailed output"
    Write-Host "  .\tests-building-on-windows.ps1 -Fast          # Skip slower integration tests"
    Write-Host "  .\tests-building-on-windows.ps1 -Help          # Show this help"
    Write-Host ""
    Write-Host "Test Categories:" -ForegroundColor Yellow
    Write-Host "  1. Pallet Unit Tests        - All custom pallets"
    Write-Host "  2. Runtime Integration Tests - Runtime compilation"
    Write-Host "  3. Node Build Tests         - Node compilation"
    Write-Host "  4. Workspace Tests          - Formatting and linting"
    Write-Host ""
    Write-Host "Requirements:" -ForegroundColor Yellow
    Write-Host "  - WSL2 with Ubuntu LTS installed"
    Write-Host "  - Rust toolchain in WSL2"
    Write-Host "  - wasm32-unknown-unknown target"
    Write-Host ""
    Write-Host "Available Pallets:" -ForegroundColor Yellow
    Write-Host "  - pallet-learning-interactions"
    Write-Host "  - pallet-life-learning-passport"
    Write-Host "  - pallet-reputation-system"
    Write-Host ""
    exit 0
}

# Test configuration
$testScriptPath = Join-Path $PSScriptRoot "test-pallet-using-wsl2.ps1"
$startTime = Get-Date
$totalTests = 0
$passedTests = 0
$failedTests = 0
$testResults = @()

# Color scheme
$colors = @{
    Header = "Cyan"
    Success = "Green"
    Error = "Red"
    Warning = "Yellow"
    Info = "White"
    Separator = "DarkGray"
}

# Function to log test results
function Log-TestResult {
    param(
        [string]$TestName,
        [string]$Category,
        [bool]$Success,
        [string]$Duration,
        [string]$Details = ""
    )
    
    $script:totalTests++
    if ($Success) {
        $script:passedTests++
        $status = "✅ PASS"
        $color = $colors.Success
    } else {
        $script:failedTests++
        $status = "❌ FAIL"
        $color = $colors.Error
    }
    
    $result = [PSCustomObject]@{
        Category = $Category
        TestName = $TestName
        Status = $status
        Duration = $Duration
        Details = $Details
        Success = $Success
    }
    
    $script:testResults += $result
    
    if ($Verbose -or -not $Success) {
        Write-Host "  $status $TestName ($Duration)" -ForegroundColor $color
        if ($Details -and ($Verbose -or -not $Success)) {
            Write-Host "    $Details" -ForegroundColor $colors.Info
        }
    }
}

# Function to run a test with timing
function Invoke-TimedTest {
    param(
        [string]$TestName,
        [string]$Category,
        [string]$Command,
        [string]$WorkingDirectory = (Get-Location)
    )
    
    $testStart = Get-Date
    
    if ($Verbose) {
        Write-Host "🔄 Running: $TestName" -ForegroundColor $colors.Info
        Write-Host "   Command: $Command" -ForegroundColor $colors.Separator
    }
    
    try {
        Push-Location $WorkingDirectory
        $result = Invoke-Expression $Command
        $success = $LASTEXITCODE -eq 0
        $details = if ($success) { "Completed successfully" } else { "Exit code: $LASTEXITCODE" }
    }
    catch {
        $success = $false
        $details = "Exception: $($_.Exception.Message)"
    }
    finally {
        Pop-Location
    }
    
    $testEnd = Get-Date
    $duration = "{0:F2}s" -f ($testEnd - $testStart).TotalSeconds
    
    Log-TestResult -TestName $TestName -Category $Category -Success $success -Duration $duration -Details $details
    
    return $success
}

# Function to print section header
function Write-SectionHeader {
    param([string]$Title)
    
    Write-Host ""
    Write-Host "=" * 80 -ForegroundColor $colors.Separator
    Write-Host "🧪 $Title" -ForegroundColor $colors.Header
    Write-Host "=" * 80 -ForegroundColor $colors.Separator
}

# Function to check if test script exists
function Test-ScriptExists {
    if (-not (Test-Path $testScriptPath)) {
        Write-Host "❌ Test script not found: $testScriptPath" -ForegroundColor $colors.Error
        Write-Host "Please ensure the test-pallet-using-wsl2.ps1 script exists in the tests directory." -ForegroundColor $colors.Warning
        exit 1
    }
}

# Main execution starts here
Write-Host "🚀 Starting Keiko Substrate Comprehensive Test Suite" -ForegroundColor $colors.Header
Write-Host "⏰ Started at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor $colors.Info
Write-Host "🔧 Mode: $(if ($Fast) { 'Fast' } else { 'Complete' }) | Verbose: $Verbose" -ForegroundColor $colors.Info

# Verify test script exists
Test-ScriptExists

# Change to backend directory
$backendPath = Split-Path -Parent $PSScriptRoot
Push-Location $backendPath

try {
    # 1. PALLET UNIT TESTS
    Write-SectionHeader "Pallet Unit Tests"
    
    $pallets = @(
        @{ Name = "learning-interactions"; Description = "Learning Interactions Pallet" },
        @{ Name = "life-learning-passport"; Description = "Life Learning Passport Pallet" },
        @{ Name = "reputation-system"; Description = "Reputation System Pallet" }
    )
    
    foreach ($pallet in $pallets) {
        $testName = "$($pallet.Description) - Unit Tests"
        $wslRunnerPath = Join-Path $PSScriptRoot "run-wsl2-command.ps1"
        $showDetailsFlag = if ($Verbose) { "-ShowDetails" } else { "" }
        $command = "& `"$wslRunnerPath`" `"cargo test -p pallet-$($pallet.Name) --lib`" $showDetailsFlag"
        Invoke-TimedTest -TestName $testName -Category "Pallet Tests" -Command $command
        
        if (-not $Fast) {
            # Run integration tests for each pallet
            $integrationTestName = "$($pallet.Description) - Integration Tests"
            $wslRunnerPath = Join-Path $PSScriptRoot "run-wsl2-command.ps1"
            $integrationCommand = "& `"$wslRunnerPath`" `"cargo test -p pallet-$($pallet.Name)`""
            Invoke-TimedTest -TestName $integrationTestName -Category "Pallet Tests" -Command $integrationCommand
        }
    }
    
    # 2. RUNTIME TESTS
    if (-not $Fast) {
        Write-SectionHeader "Runtime Integration Tests"
        
        # Runtime compilation test
        $wslRunnerPath = Join-Path $PSScriptRoot "run-wsl2-command.ps1"
        Invoke-TimedTest -TestName "Runtime Compilation" -Category "Runtime Tests" -Command "& `"$wslRunnerPath`" `"cargo test --manifest-path runtime/Cargo.toml --lib`""
        
        # Runtime build test
        $wslRunnerPath = Join-Path $PSScriptRoot "run-wsl2-command.ps1"
        Invoke-TimedTest -TestName "Runtime Build" -Category "Runtime Tests" -Command "& `"$wslRunnerPath`" `"cargo build --release --manifest-path runtime/Cargo.toml`""
    }
    
    # 3. NODE TESTS
    if (-not $Fast) {
        Write-SectionHeader "Node Build Tests"
        
        # Node compilation test
        $wslRunnerPath = Join-Path $PSScriptRoot "run-wsl2-command.ps1"
        Invoke-TimedTest -TestName "Node Compilation" -Category "Node Tests" -Command "& `"$wslRunnerPath`" `"cargo test --manifest-path node/Cargo.toml --lib`""
        
        # Node build test (this can be slow)
        Write-Host "⚠️  Node build test may take several minutes..." -ForegroundColor $colors.Warning
        $wslRunnerPath = Join-Path $PSScriptRoot "run-wsl2-command.ps1"
        Invoke-TimedTest -TestName "Node Build" -Category "Node Tests" -Command "& `"$wslRunnerPath`" `"cargo build --release --manifest-path node/Cargo.toml`""
    }
    
    # 4. WORKSPACE TESTS
    Write-SectionHeader "Workspace Quality Tests"
    
    # Clippy linting
    $wslRunnerPath = Join-Path $PSScriptRoot "run-wsl2-command.ps1"
    
    Invoke-TimedTest -TestName "Clippy Linting" -Category "Quality Tests" -Command "& `"$wslRunnerPath`" `"cargo clippy --all-targets --all-features -- -D warnings`""
    
    # Format checking
    Invoke-TimedTest -TestName "Format Check" -Category "Quality Tests" -Command "& `"$wslRunnerPath`" `"cargo fmt --all -- --check`""
    
    # Workspace-wide test
    if (-not $Fast) {
        $wslRunnerPath = Join-Path $PSScriptRoot "run-wsl2-command.ps1"
        Invoke-TimedTest -TestName "Workspace Tests" -Category "Workspace Tests" -Command "& `"$wslRunnerPath`" `"cargo test --workspace`""
    }
    
} finally {
    Pop-Location
}

# RESULTS SUMMARY
$endTime = Get-Date
$totalDuration = $endTime - $startTime

Write-Host ""
Write-Host "=" * 80 -ForegroundColor $colors.Separator
Write-Host "📊 TEST RESULTS SUMMARY" -ForegroundColor $colors.Header
Write-Host "=" * 80 -ForegroundColor $colors.Separator

Write-Host "⏱️  Total Duration: $($totalDuration.ToString('hh\:mm\:ss'))" -ForegroundColor $colors.Info
Write-Host "📈 Total Tests: $totalTests" -ForegroundColor $colors.Info
Write-Host "✅ Passed: $passedTests" -ForegroundColor $colors.Success
Write-Host "❌ Failed: $failedTests" -ForegroundColor $colors.Error
Write-Host "📊 Success Rate: $(if ($totalTests -gt 0) { [math]::Round(($passedTests / $totalTests) * 100, 1) } else { 0 })%" -ForegroundColor $(if ($failedTests -eq 0) { $colors.Success } else { $colors.Warning })

# Detailed results by category
Write-Host ""
Write-Host "📋 Results by Category:" -ForegroundColor $colors.Header

$categories = $testResults | Group-Object Category
foreach ($category in $categories) {
    $categoryPassed = ($category.Group | Where-Object { $_.Success }).Count
    $categoryTotal = $category.Group.Count
    $categoryRate = if ($categoryTotal -gt 0) { [math]::Round(($categoryPassed / $categoryTotal) * 100, 1) } else { 0 }
    
    Write-Host "  $($category.Name): $categoryPassed/$categoryTotal ($categoryRate%)" -ForegroundColor $(if ($categoryPassed -eq $categoryTotal) { $colors.Success } else { $colors.Warning })
}

# Show failed tests if any
if ($failedTests -gt 0) {
    Write-Host ""
    Write-Host "❌ Failed Tests:" -ForegroundColor $colors.Error
    $failedResults = $testResults | Where-Object { -not $_.Success }
    foreach ($failed in $failedResults) {
        Write-Host "  • $($failed.Category): $($failed.TestName)" -ForegroundColor $colors.Error
        if ($failed.Details) {
            Write-Host "    $($failed.Details)" -ForegroundColor $colors.Info
        }
    }
    
    Write-Host ""
    Write-Host "💡 Recommendations:" -ForegroundColor $colors.Warning
    Write-Host "  1. Check WSL2 setup and Rust installation" -ForegroundColor $colors.Info
    Write-Host "  2. Run individual tests with --verbose for detailed output" -ForegroundColor $colors.Info
    Write-Host "  3. Ensure all dependencies are properly configured" -ForegroundColor $colors.Info
}

Write-Host ""
Write-Host "🏁 Test suite completed at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor $colors.Info

# Exit with appropriate code
exit $(if ($failedTests -eq 0) { 0 } else { 1 })