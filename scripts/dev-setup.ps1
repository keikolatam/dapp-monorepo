# Business Source License 1.1
# 
# Licensed Work: keiko-dapp Version 0.0.1 or later.
# The Licensed Work is (c) 2025 Luis Andrés Peña Castillo
# 
# For full license terms, see LICENSE file in the repository root.

# Keiko Development Setup Script para Windows
# Este script ayuda a configurar el entorno de desarrollo para la nueva arquitectura

param(
    [switch]$Help,
    [switch]$CheckOnly,
    [switch]$BuildAll
)

# Colores para output
$Green = "Green"
$Yellow = "Yellow" 
$Red = "Red"
$White = "White"

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

function Show-Help {
    Write-Host "Keiko Development Setup Script" -ForegroundColor $White
    Write-Host ""
    Write-Host "Uso:" -ForegroundColor $White
    Write-Host "  .\dev-setup.ps1                 # Setup completo"
    Write-Host "  .\dev-setup.ps1 -CheckOnly      # Solo verificar prerequisitos"
    Write-Host "  .\dev-setup.ps1 -BuildAll       # Build completo de todos los componentes"
    Write-Host "  .\dev-setup.ps1 -Help           # Mostrar esta ayuda"
    Write-Host ""
}

if ($Help) {
    Show-Help
    exit 0
}

Write-Status "🚀 Configurando entorno de desarrollo Keiko..."

# Verificar prerequisitos
Write-Status "Verificando prerequisitos..."

# Verificar WSL2 (recomendado para desarrollo Substrate)
try {
    $wslVersion = wsl --version 2>$null
    if ($wslVersion) {
        Write-Status "✅ WSL2 encontrado"
        $hasWSL2 = $true
        
        # Verificar si hay distribuciones instaladas
        $wslDistros = wsl --list --quiet 2>$null
        if ($wslDistros) {
            Write-Status "✅ Distribuciones WSL2 disponibles"
        } else {
            Write-Warning "⚠️  No hay distribuciones WSL2 instaladas"
            Write-Status "💡 Recomendación: Instalar Ubuntu LTS para desarrollo Substrate"
            Write-Status "   Ejecutar: wsl --install -d Ubuntu-24.04"
        }
    }
} catch {
    Write-Warning "⚠️  WSL2 no encontrado"
    Write-Status "💡 Recomendación: WSL2 es altamente recomendado para desarrollo Substrate"
    Write-Status "   Substrate está optimizado para entornos Linux"
    Write-Status "   Ejecutar como Administrador: wsl --install"
    $hasWSL2 = $false
}

# Verificar Rust
try {
    $rustVersion = cargo --version
    Write-Status "✅ Rust encontrado: $rustVersion"
    
    # Verificar target wasm32-unknown-unknown
    $wasmTarget = rustup target list --installed | Select-String "wasm32-unknown-unknown"
    if ($wasmTarget) {
        Write-Status "✅ Target wasm32-unknown-unknown instalado"
    } else {
        Write-Warning "⚠️  Target wasm32-unknown-unknown no encontrado"
        Write-Status "💡 Instalando target wasm32-unknown-unknown..."
        rustup target add wasm32-unknown-unknown
    }
} catch {
    Write-Error "❌ Rust/Cargo no encontrado. Instalar desde: https://rustup.rs/"
    if ($hasWSL2) {
        Write-Status "💡 Alternativamente, instalar Rust en WSL2 para mejor compatibilidad con Substrate"
        Write-Status "   Usar: blockchain\tests\setup-wsl2-substrate.ps1 -SetupRust"
    }
    exit 1
}

# Verificar Flutter
try {
    $flutterVersion = flutter --version 2>$null | Select-Object -First 1
    Write-Status "✅ Flutter encontrado: $flutterVersion"
    $hasFlutter = $true
} catch {
    Write-Warning "⚠️  Flutter no encontrado. Instalar para desarrollo frontend: https://flutter.dev/"
    $hasFlutter = $false
}

# Verificar Podman (preferido sobre Docker)
try {
    $podmanVersion = podman --version
    Write-Status "✅ Podman encontrado: $podmanVersion"
    $hasPodman = $true
} catch {
    # Fallback a Docker si Podman no está disponible
    try {
        $dockerVersion = docker --version
        Write-Status "✅ Docker encontrado: $dockerVersion (recomendamos migrar a Podman)"
        $hasPodman = $false
        $hasDocker = $true
    } catch {
        Write-Warning "⚠️  Ni Podman ni Docker encontrados. Instalar Podman: https://podman.io/"
        $hasPodman = $false
        $hasDocker = $false
    }
}

# Verificar Git
try {
    $gitVersion = git --version
    Write-Status "✅ Git encontrado: $gitVersion"
} catch {
    Write-Warning "⚠️  Git no encontrado. Instalar desde: https://git-scm.com/"
}

Write-Status "✅ Verificación de prerequisitos completada!"

if ($CheckOnly) {
    Write-Status "Modo CheckOnly - finalizando."
    exit 0
}

# Build blockchain layer
Write-Status "Construyendo blockchain layer..."

# Verificar si WSL2 está disponible para desarrollo Substrate
if ($hasWSL2) {
    Write-Status "💡 WSL2 detectado - recomendado para desarrollo Substrate"
    Write-Status "   Para usar WSL2: blockchain\tests\setup-wsl2-substrate.ps1 -Test"
    Write-Status "   Para tests completos: blockchain\tests\tests-building-on-windows.ps1"
}

Push-Location blockchain
try {
    if ($BuildAll) {
        Write-Status "⚠️  Construyendo en Windows - pueden ocurrir errores de compatibilidad"
        Write-Status "   Si hay errores, usar WSL2: blockchain\tests\setup-wsl2-substrate.ps1"
        cargo build --release
        Write-Status "✅ Blockchain layer construido exitosamente"
    } else {
        cargo check
        Write-Status "✅ Blockchain layer verificado exitosamente"
    }
} catch {
    Write-Error "❌ Falló la construcción del blockchain layer"
    Write-Status ""
    Write-Status "🔧 Soluciones recomendadas:"
    Write-Status "1. Usar WSL2 para desarrollo Substrate (recomendado):"
    Write-Status "   blockchain\tests\setup-wsl2-substrate.ps1 -Install"
    Write-Status "2. Ejecutar tests en WSL2:"
    Write-Status "   blockchain\tests\tests-building-on-windows.ps1"
    Write-Status "3. Verificar dependencias específicas de Windows"
    Pop-Location
    exit 1
}
Pop-Location

# Verificar estructura de servicios
Write-Status "Verificando estructura de servicios..."
$services = @(
    "identity-service",
    "learning-service", 
    "reputation-service",
    "passport-service",
    "governance-service",
    "marketplace-service"
)

foreach ($service in $services) {
    $cargoPath = "services\$service\Cargo.toml"
    if (Test-Path $cargoPath) {
        Write-Status "✅ $service estructura lista"
        if ($BuildAll) {
            Push-Location "services\$service"
            try {
                cargo check
                Write-Status "✅ $service verificado"
            } catch {
                Write-Warning "⚠️  $service necesita implementación"
            }
            Pop-Location
        }
    } else {
        Write-Warning "⚠️  $service necesita implementación"
    }
}

# Verificar API Gateway
Write-Status "Verificando API Gateway..."
Push-Location api-gateway
try {
    cargo check
    Write-Status "✅ API Gateway estructura lista"
} catch {
    Write-Warning "⚠️  API Gateway necesita actualizaciones para nueva arquitectura"
}
Pop-Location

# Verificar componentes compartidos
Write-Status "Verificando componentes compartidos..."
if ((Test-Path "shared\types\Cargo.toml") -and (Test-Path "shared\utils\Cargo.toml")) {
    Write-Status "✅ Componentes compartidos estructura lista"
    if ($BuildAll) {
        Push-Location "shared\types"
        cargo check
        Pop-Location
        Push-Location "shared\utils"  
        cargo check
        Pop-Location
        Write-Status "✅ Componentes compartidos verificados"
    }
} else {
    Write-Warning "⚠️  Componentes compartidos necesitan implementación"
}

# Verificar frontend
Write-Status "Verificando frontend..."
if (Test-Path "frontend\pubspec.yaml") {
    Write-Status "✅ Frontend estructura lista"
    if ($hasFlutter) {
        Push-Location frontend
        try {
            flutter pub get
            Write-Status "✅ Dependencias Flutter instaladas"
        } catch {
            Write-Warning "⚠️  Error instalando dependencias Flutter"
        }
        Pop-Location
    }
} else {
    Write-Warning "⚠️  Frontend necesita implementación"
}

# Verificar infraestructura
Write-Status "Verificando infraestructura..."
if (Test-Path "infrastructure") {
    Write-Status "✅ Directorio infrastructure creado"
    if (Test-Path "infrastructure\docker") {
        Write-Status "✅ Directorio Docker listo"
    }
    if (Test-Path "infrastructure\kubernetes") {
        Write-Status "✅ Directorio Kubernetes listo"  
    }
    if (Test-Path "infrastructure\terraform") {
        Write-Status "✅ Directorio Terraform listo"
    }
} else {
    Write-Warning "⚠️  Infraestructura necesita configuración"
}

Write-Status ""
Write-Status "🎉 Configuración del entorno de desarrollo completada!"
Write-Status ""
Write-Status "📋 Arquitectura Híbrida - PostgreSQL por Microservicio:"
Write-Status "  • identity-service    → PostgreSQL (usuarios, sesiones, cache identidades)"
Write-Status "  • learning-service    → PostgreSQL (cache interacciones xAPI, queries rápidas)"
Write-Status "  • reputation-service  → PostgreSQL (cálculos agregados de reputación)"
Write-Status "  • passport-service    → PostgreSQL (vistas agregadas de pasaportes)"
Write-Status "  • governance-service  → PostgreSQL (propuestas, votaciones temporales)"
Write-Status "  • marketplace-service → PostgreSQL (espacios, reservas, disponibilidad)"
Write-Status ""
Write-Status "💡 Flujo de Datos Híbrido:"
Write-Status "  📝 Escritura: Microservicio → Parachain (fuente verdad) → PostgreSQL (cache)"
Write-Status "  📖 Lectura:   PostgreSQL (cache) → fallback Parachain RPC si no existe"
Write-Status "  ⚡ Eventos:   Parachain → Microservicio → Redis Streams → GraphQL Subscriptions"
Write-Status ""
Write-Status "Próximos pasos:"
Write-Status "1. Implementar microservicios en directorio services/"
Write-Status "2. Actualizar API Gateway para arquitectura GraphQL + gRPC"
Write-Status "3. Implementar frontend Flutter con cliente GraphQL"
Write-Status "4. Configurar infraestructura con Podman Compose"
Write-Status ""
Write-Status "Para implementación detallada, revisar .kiro\specs\01-keiko-dapp\tasks.md"

# Mostrar comandos útiles
Write-Status ""
Write-Status "Comandos útiles para Windows:"
if ($hasWSL2) {
    Write-Status ""
    Write-Status "🐧 Comandos WSL2 (recomendado para Substrate):"
    Write-Status "  # Setup WSL2 para Substrate:"
    Write-Status "  blockchain\tests\setup-wsl2-substrate.ps1 -Install"
    Write-Status "  blockchain\tests\setup-wsl2-substrate.ps1 -SetupRust"
    Write-Status ""
    Write-Status "  # Tests completos en WSL2:"
    Write-Status "  blockchain\tests\tests-building-on-windows.ps1"
    Write-Status "  blockchain\tests\tests-building-on-windows.ps1 -Verbose"
    Write-Status ""
    Write-Status "  # Tests individuales:"
    Write-Status "  blockchain\tests\test-pallet-using-wsl2.ps1 `"-p pallet-reputation-system --lib`""
    Write-Status ""
    Write-Status "  # Comandos directos en WSL2:"
    Write-Status "  blockchain\tests\run-wsl2-command.ps1 `"cargo build --release`""
    Write-Status "  blockchain\tests\run-wsl2-command.ps1 `"cargo test --workspace`""
    Write-Status ""
}
Write-Status "🪟 Comandos Windows (pueden tener problemas de compatibilidad):"
Write-Status "  # Build blockchain:"
Write-Status "  cd blockchain && cargo build --release"
Write-Status ""
Write-Status "  # Verificar workspace completo:"
Write-Status "  cargo check --workspace"
Write-Status ""
Write-Status "  # Ejecutar tests blockchain:"
Write-Status "  cd blockchain && cargo test"
Write-Status ""
if ($hasFlutter) {
    Write-Status "  # Ejecutar frontend:"
    Write-Status "  cd frontend && flutter run -d web"
    Write-Status ""
}
if ($hasPodman) {
    Write-Status "  # Iniciar servicios locales con Podman:"
    Write-Status "  podman-compose up -d"
    Write-Status "  # O usar pods nativos de Podman:"
    Write-Status "  podman play kube infrastructure/kubernetes/dev-services.yaml"
    Write-Status ""
} elseif ($hasDocker) {
    Write-Status "  # Iniciar servicios locales con Docker:"
    Write-Status "  docker-compose up -d"
    Write-Status "  # Recomendamos migrar a Podman para mejor seguridad"
    Write-Status ""
}