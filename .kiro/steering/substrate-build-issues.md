# Substrate Build Issues

## Overview

Substrate development is optimized for Linux environments. Windows development often encounters platform-specific compilation issues, dependency conflicts, and missing system calls. **The recommended approach is to use WSL2 for all Substrate development.**

## Known Windows Issues

### Platform-Specific Compilation Errors

**Common Issues**:
- `TcpListener` not found in `tokio::net`
- Unix-specific system calls (`pipe2`, `getppid`, `kill`) not available on Windows
- Missing `std::os::unix` and `std::os::fd` modules
- `nix` crate errors for Unix-only functionality
- `mio` crate method resolution failures

**Root Cause**: Substrate and Polkadot SDK dependencies are designed primarily for Unix-like systems and contain platform-specific code that doesn't compile on Windows.

### Dependency Configuration Issues

**Issue**: Missing feature flags in dependencies like:
```
error[E0433]: failed to resolve: could not find `TcpListener` in `net`
  --> substrate/utils/prometheus/src/lib.rs:89:29
```

**Root Cause**: Substrate dependencies may have incomplete Windows support or missing feature flags for Windows builds.

## Recommended Solution: WSL2

### Why WSL2?

1. **Native Linux Environment**: Substrate is designed for Linux
2. **Full Warning Visibility**: See all warnings and errors without suppression
3. **Better Performance**: Native Unix system calls and file I/O
4. **Consistent CI/CD**: Matches production deployment environment
5. **Complete Toolchain Support**: All Substrate tools work properly
6. **Proper Error Reporting**: See actual build issues instead of platform conflicts

### WSL2 Setup

#### Automated Setup (Recommended)
Use the provided setup script for easy installation:

```powershell
cd backend/tests
# Run as Administrator for WSL2 installation
.\setup-wsl2-substrate.ps1 -Install
# Restart computer if prompted
.\setup-wsl2-substrate.ps1 -SetupRust
.\setup-wsl2-substrate.ps1 -Test
```

#### Manual Setup (Alternative)
If you prefer manual setup:

1. **Install WSL2 with Ubuntu LTS**:
   ```powershell
   # Install Ubuntu 24.04 LTS (recommended)
   wsl --install -d Ubuntu-24.04
   
   # Or check available distributions
   wsl --list --online
   ```

2. **Set up Rust in WSL2**:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   source ~/.cargo/env
   rustup default stable
   rustup update
   rustup target add wasm32-unknown-unknown
   ```

3. **Clone and build**:
   ```bash
   git clone <repository>
   cd keiko/backend
   cargo build --release
   cargo test -p pallet-reputation-system
   ```

### WSL2 Setup and Management

#### Automated Setup Script
Use the `setup-wsl2-substrate.ps1` script for easy WSL2 configuration:

```powershell
cd backend/tests

# Check current WSL2/Rust status
.\setup-wsl2-substrate.ps1 -Status

# Install WSL2 with Ubuntu (requires Administrator)
.\setup-wsl2-substrate.ps1 -Install

# Install Rust in existing WSL2
.\setup-wsl2-substrate.ps1 -SetupRust

# Test Substrate build environment
.\setup-wsl2-substrate.ps1 -Test

# Show help and setup instructions
.\setup-wsl2-substrate.ps1 -Help
```

**Typical Setup Process**:
1. Run as Administrator: `.\setup-wsl2-substrate.ps1 -Install`
2. Restart computer if prompted
3. Run: `.\setup-wsl2-substrate.ps1 -SetupRust`
4. Run: `.\setup-wsl2-substrate.ps1 -Test`

#### Individual Pallet Testing
The `test-pallet-using-wsl2.ps1` script runs individual pallet tests:

```powershell
cd backend/tests
.\test-pallet-using-wsl2.ps1 "-p pallet-reputation-system --lib"
.\test-pallet-using-wsl2.ps1 "-p pallet-learning-interactions --lib"
.\test-pallet-using-wsl2.ps1 "-p pallet-life-learning-passport --lib"
.\test-pallet-using-wsl2.ps1 "-p pallet-reputation-system --lib create_rating_works"
```

#### Comprehensive Test Suite
The `tests-building-on-windows.ps1` script runs ALL project tests:

```powershell
cd backend/tests
# Run all tests (comprehensive)
.\tests-building-on-windows.ps1

# Run all tests with detailed output
.\tests-building-on-windows.ps1 -Verbose

# Skip slower integration tests
.\tests-building-on-windows.ps1 -Fast

# Show help
.\tests-building-on-windows.ps1 -Help
```

#### Direct WSL2 Command Execution
For advanced users, the `run-wsl2-command.ps1` script provides direct command execution:

```powershell
cd backend/tests
# Run any cargo command with detailed output
.\run-wsl2-command.ps1 "cargo test -p pallet-reputation-system --lib" -ShowDetails

# Run build commands
.\run-wsl2-command.ps1 "cargo build --release"

# Run clippy linting
.\run-wsl2-command.ps1 "cargo clippy --all-targets --all-features"
```

**Test Categories Covered**:
1. **Pallet Unit Tests**: All custom pallets (learning_interactions, life_learning_passport, reputation_system)
2. **Runtime Integration Tests**: Runtime compilation and build verification
3. **Node Build Tests**: Node compilation checks
4. **Workspace Quality Tests**: Code formatting and linting (clippy)

**Script Features**:
- 🔍 **Auto-Detection**: Finds the best Ubuntu LTS distribution (24.04 → 22.04 → 20.04 → 18.04 → Ubuntu)
- 🦀 **Rust Verification**: Checks if Rust/Cargo is installed in the selected distribution
- 📊 **Comprehensive Reporting**: Detailed test results with timing and status
- ⚡ **Fast Mode**: Skip slower tests for quick validation
- 🔍 **Verbose Mode**: Show detailed output for debugging
- 🛠️ **Automated Setup**: One-command WSL2 and Rust installation
- 🚀 **Reliable Execution**: Dedicated WSL2 command runner for consistent results
- ✅ **WSL2 Available**: Runs tests in WSL2 with full output and proper error reporting
- ❌ **WSL2 Not Available**: Clear error messages with automated setup options

## Fallback Strategies (Not Recommended)

If WSL2 is not available, these workarounds may help but are not recommended for production development:

1. **Workspace-Level Testing**:
   ```bash
   cargo test -p pallet-name
   ```

2. **Runtime Integration Testing**:
   ```bash
   cargo build --release
   ```

3. **Mock Dependencies**: Create minimal test environments that avoid problematic dependencies

## Implementation Guidelines

When implementing pallets:

- **Develop in WSL2** for the best experience
- Focus on core pallet logic and data structures
- Use trait abstractions for external dependencies
- Implement comprehensive unit tests using mock environments
- Verify integration through runtime compilation
- **Never suppress warnings** - they indicate real issues

## Testing Strategy

1. **Unit Tests**: Run in WSL2 with `cargo test -p pallet-name --lib`
2. **Integration Tests**: Test through runtime compilation in WSL2
3. **Functional Tests**: Use full node testing environment in WSL2

## Migration from Windows to WSL2

If you've been developing on Windows:

1. **Backup your work**: Commit all changes to git
2. **Set up WSL2**: Use `.\setup-wsl2-substrate.ps1 -Install` (requires Administrator)
3. **Install Rust**: Use `.\setup-wsl2-substrate.ps1 -SetupRust`
4. **Test setup**: Use `.\setup-wsl2-substrate.ps1 -Test`
5. **Run clean builds**: Use `.\run-wsl2-command.ps1 "cargo clean && cargo build --release"`
6. **Verify tests**: Use `.\tests-building-on-windows.ps1` to run all tests

## Available Scripts Summary

| Script | Purpose | Usage |
|--------|---------|-------|
| `setup-wsl2-substrate.ps1` | WSL2 setup and management | `.\setup-wsl2-substrate.ps1 -Install\|-SetupRust\|-Test\|-Status` |
| `test-pallet-using-wsl2.ps1` | Individual pallet testing | `.\test-pallet-using-wsl2.ps1 "-p pallet-name --lib"` |
| `tests-building-on-windows.ps1` | Comprehensive test suite | `.\tests-building-on-windows.ps1 [-Verbose\|-Fast\|-Help]` |
| `run-wsl2-command.ps1` | Direct WSL2 command execution | `.\run-wsl2-command.ps1 "cargo command" [-ShowDetails]` |

## Benefits of WSL2 Development

- 🚀 **Faster builds**: Native Linux file I/O
- 🔍 **Better debugging**: Full error visibility
- 🛡️ **Fewer issues**: Platform compatibility guaranteed
- 🔄 **CI/CD consistency**: Matches deployment environment
- 📊 **Proper monitoring**: See real warnings and errors
- 🧪 **Complete testing**: All Substrate features work

**Bottom Line**: Use WSL2 for Substrate development. It eliminates platform-specific issues and provides the proper development environment for blockchain development.
