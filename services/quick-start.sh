#!/bin/bash

# Script de configuración rápida para el Services Layer - Keiko DApp
# Instala Rust, herramientas de desarrollo y dependencias para microservicios
# Basado en la documentación oficial de Rust y mejores prácticas para microservicios

set -e  # Salir si cualquier comando falla

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones de logging
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Función para detectar sistema operativo
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case "$ID" in
                ubuntu|debian)
                    OS="ubuntu"
                    ;;
                centos|rhel|fedora)
                    OS="centos"
                    ;;
                arch)
                    OS="arch"
                    ;;
                *)
                    OS="linux"
                    ;;
            esac
        else
            OS="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        OS="unknown"
    fi
}

# Función para verificar dependencias del sistema
check_system_dependencies() {
    print_status "Verificando dependencias del sistema..."
    
    local missing_deps=()
    
    # Verificar dependencias básicas
    for dep in curl git gcc make pkg-config libssl-dev; do
        if ! command -v $dep &> /dev/null; then
            missing_deps+=($dep)
        fi
    done
    
    # Verificar dependencias específicas según el OS
    case $OS in
        "ubuntu")
            # Paquetes necesarios para OpenCV y compilación
            UBUNTU_PKGS=(build-essential cmake clang libopencv-dev python3 python3-venv python3-pip)
            for dep in "${UBUNTU_PKGS[@]}"; do
                if ! dpkg -l | grep -q "^ii.*$dep"; then
                    missing_deps+=($dep)
                fi
            done
            ;;
        "centos")
            for dep in gcc-c++ openssl-devel cmake clang opencv-devel python3 python3-venv python3-pip; do
                if ! rpm -q $dep &> /dev/null; then
                    missing_deps+=($dep)
                fi
            done
            ;;
        "arch")
            for dep in base-devel openssl cmake clang opencv python python-virtualenv python-pip; do
                if ! pacman -Q $dep &> /dev/null; then
                    missing_deps+=($dep)
                fi
            done
            ;;
        "macos")
            if ! command -v xcode-select &> /dev/null; then
                missing_deps+=("xcode-select")
            fi
            ;;
    esac
    
    if [ ${#missing_deps[@]} -eq 0 ]; then
        print_success "Todas las dependencias del sistema están instaladas"
        return 0
    else
        print_warning "Faltan las siguientes dependencias: ${missing_deps[*]}"
        print_status "Por favor instala las dependencias faltantes manualmente:"
        
        case $OS in
            "ubuntu")
                echo "  sudo apt-get update && sudo apt-get install -y ${missing_deps[*]}"
                ;;
            "centos")
                echo "  sudo yum install -y ${missing_deps[*]}"
                ;;
            "arch")
                echo "  sudo pacman -S --noconfirm ${missing_deps[*]}"
                ;;
            "macos")
                echo "  xcode-select --install"
                echo "  brew install cmake clang opencv python"
                ;;
            *)
                echo "  Instala manualmente: ${missing_deps[*]}"
                ;;
        esac
        
        print_warning "Continuando con la instalación de Rust..."
        return 1
    fi
}

# Función para instalar Rust
install_rust() {
    print_status "Instalando Rust..."
    
    # Verificar si Rust ya está instalado
    if command -v rustc &> /dev/null; then
        print_warning "Rust ya está instalado: $(rustc --version)"
        print_status "Actualizando Rust..."
        rustup update
    else
        print_status "Instalando Rust desde rustup.rs..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        
        # Cargar Rust en la sesión actual
        source ~/.cargo/env
    fi
    
    # Configurar componentes y herramientas
    print_status "Configurando componentes de Rust..."
    rustup component add rustfmt clippy rust-src
    
    # Instalar herramientas adicionales
    print_status "Instalando herramientas de desarrollo..."
    cargo install cargo-watch      # Para desarrollo con hot-reload
    cargo install cargo-expand     # Para expandir macros
    cargo install cargo-audit      # Para auditoría de seguridad
    cargo install cargo-outdated   # Para verificar dependencias desactualizadas
    cargo install cargo-tree       # Para visualizar dependencias
    cargo install cargo-udeps      # Para detectar dependencias no utilizadas
    cargo install cargo-tarpaulin  # Para cobertura de código
    cargo install cargo-nextest    # Para testing avanzado
    cargo install cargo-profdata   # Para profiling
    
    print_success "Rust instalado correctamente"
}

# Función para instalar herramientas específicas para microservicios
install_microservices_tools() {
    print_status "Instalando herramientas específicas para microservicios..."
    
    # Herramientas para gRPC
    print_status "Instalando herramientas para gRPC..."
    if ! command -v protoc &> /dev/null; then
        case $OS in
            "ubuntu")
                sudo apt-get update && sudo apt-get install -y protobuf-compiler
                ;;
            "centos")
                sudo yum install -y protobuf-compiler
                ;;
            "arch")
                sudo pacman -S --noconfirm protobuf
                ;;
            "macos")
                brew install protobuf
                ;;
            *)
                print_warning "Instala protobuf-compiler manualmente para tu sistema"
                ;;
        esac
    fi
    
    # Herramientas para PostgreSQL
    print_status "Verificando herramientas para PostgreSQL..."
    if ! command -v psql &> /dev/null; then
        case $OS in
            "ubuntu")
                sudo apt-get install -y postgresql-client libpq-dev
                ;;
            "centos")
                sudo yum install -y postgresql postgresql-devel
                ;;
            "arch")
                sudo pacman -S --noconfirm postgresql-libs
                ;;
            "macos")
                brew install postgresql
                ;;
        esac
    fi
    
    # Herramientas para Redis
    print_status "Verificando herramientas para Redis..."
    if ! command -v redis-cli &> /dev/null; then
        case $OS in
            "ubuntu")
                sudo apt-get install -y redis-tools
                ;;
            "centos")
                sudo yum install -y redis
                ;;
            "arch")
                sudo pacman -S --noconfirm redis
                ;;
            "macos")
                brew install redis
                ;;
        esac
    fi
    
    print_success "Herramientas para microservicios instaladas"
}

# Función para configurar Python + entorno ZK (biometría + Cairo)
setup_python_and_zk_stack() {
    print_status "Configurando Python y entorno para pruebas ZK..."
    
    # Asegurar python3 y pip
    if ! command -v python3 &> /dev/null; then
        print_error "python3 no está instalado. Instálalo e inténtalo de nuevo."
        return 1
    fi
    if ! command -v pip3 &> /dev/null; then
        print_error "pip3 no está instalado. Instálalo e inténtalo de nuevo."
        return 1
    fi
    
    # Crear y activar entorno virtual local
    if [ ! -d ".venv" ]; then
        python3 -m venv .venv
    fi
    # shellcheck disable=SC1091
    source .venv/bin/activate
    
    # Actualizar pip y wheel
    pip install --upgrade pip wheel
    
    # Instalar BioPython (análisis genómico), OpenCV (Python) y cairo-lang (toolchain Cairo Python)
    pip install biopython opencv-python-headless cairo-lang
    
    # Verificaciones rápidas
    python - << 'EOF'
import sys
ok = True
try:
    import Bio  # noqa: F401
except Exception as e:
    ok = False
    print(f"[PY-EVAL] Error importando BioPython: {e}", file=sys.stderr)
    try:
        import cairo_lang  # noqa: F401
except Exception as e:
    ok = False
    print(f"[PY-EVAL] Error importando cairo-lang: {e}", file=sys.stderr)
    try:
        import cv2  # noqa: F401
    except Exception as e:
        ok = False
        print(f"[PY-EVAL] Error importando OpenCV (cv2): {e}", file=sys.stderr)
sys.exit(0 if ok else 1)
EOF
    if [ $? -eq 0 ]; then
        print_success "Entorno Python listo: biopython y cairo-lang disponibles"
    else
        print_warning "Entorno Python configurado con advertencias. Revisa los mensajes anteriores."
    fi
}

# Función para configurar el entorno de desarrollo
setup_development_environment() {
    print_status "Configurando entorno de desarrollo..."
    
    # Crear archivo .cargo/config.toml para configuración del proyecto
    mkdir -p .cargo
    cat > .cargo/config.toml << EOF
[build]
# Configuración para builds más rápidos
rustc-wrapper = "sccache"

[target.x86_64-unknown-linux-gnu]
# Configuración específica para Linux
linker = "clang"

[env]
# Variables de entorno para desarrollo
RUST_LOG = "debug"
RUST_BACKTRACE = "1"
EOF

    # Crear archivo rust-toolchain.toml
    cat > rust-toolchain.toml << EOF
[toolchain]
channel = "stable"
components = ["rustfmt", "clippy", "rust-src"]
targets = ["x86_64-unknown-linux-gnu"]
EOF

    # Crear archivo .rustfmt.toml
    cat > .rustfmt.toml << EOF
# Configuración de rustfmt para el proyecto
edition = "2021"
max_width = 100
tab_spaces = 4
newline_style = "Unix"
use_small_heuristics = "Default"
EOF

    # Crear archivo clippy.toml
    cat > clippy.toml << EOF
# Configuración de clippy para el proyecto
avoid-breaking-exported-api = false
single-char-lifetime-names = false
EOF

    print_success "Entorno de desarrollo configurado"
}

# Función para crear estructura básica del proyecto
create_project_structure() {
    print_status "Creando estructura básica del proyecto..."
    
    # Crear directorios para microservicios
    mkdir -p {identity-service,learning-service,reputation-service,passport-service,governance-service,marketplace-service,ai-tutor-service}
    
    # Crear directorio para componentes compartidos
    mkdir -p shared/{auth,config,database,grpc,logging,metrics,utils}
    
    # Crear archivo Cargo.toml principal para workspace
    cat > Cargo.toml << EOF
[workspace]
members = [
    "identity-service",
    "learning-service", 
    "reputation-service",
    "passport-service",
    "governance-service",
    "marketplace-service",
    "ai-tutor-service",
    "shared/auth",
    "shared/config",
    "shared/database",
    "shared/grpc",
    "shared/logging",
    "shared/metrics",
    "shared/utils",
]

resolver = "2"

[workspace.dependencies]
# Dependencias comunes para todos los microservicios
tokio = { version = "1.0", features = ["full"] }
tonic = "0.12"
prost = "0.13"
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
anyhow = "1.0"
thiserror = "1.0"
tracing = "0.1"
tracing-subscriber = "0.3"
sqlx = { version = "0.8", features = ["runtime-tokio-rustls", "postgres", "chrono", "uuid"] }
redis = { version = "0.25", features = ["tokio-comp"] }
uuid = { version = "1.0", features = ["v4", "serde"] }
chrono = { version = "0.4", features = ["serde"] }
base64 = "0.22"
sha2 = "0.10"
ed25519-dalek = "2.0"
jsonwebtoken = "9.0"
argon2 = "0.5"
fido2 = "0.1"
opencv = "0.88"
bio = "1.5"
cairo-lang = "0.1"
starknet-rs = "0.1"
circuit-breaker = "0.1"
tokio-retry = "0.3"
prometheus = "0.13"
opentelemetry = "0.21"
opentelemetry-jaeger = "0.20"
opentelemetry-prometheus = "0.12"
tower = "0.4"
tower-http = { version = "0.5", features = ["cors", "trace"] }
axum = "0.7"
tungstenite = "0.21"
futures-util = "0.3"
async-trait = "0.1"
dashmap = "5.5"
parking_lot = "0.12"
crossbeam = "0.8"
rayon = "1.8"
regex = "1.10"
url = "2.5"
reqwest = { version = "0.12", features = ["json"] }
clap = { version = "4.0", features = ["derive"] }
config = "0.14"
dotenvy = "0.15"
env_logger = "0.10"
log = "0.4"
EOF

    print_success "Estructura del proyecto creada"
}

# Función para verificar instalaciones
verify_installations() {
    print_status "Verificando instalaciones..."
    
    # Verificar Rust
    if command -v rustc &> /dev/null; then
        print_success "Rust: $(rustc --version)"
    else
        print_error "Rust no está disponible"
    fi
    
    # Verificar Cargo
    if command -v cargo &> /dev/null; then
        print_success "Cargo: $(cargo --version)"
    else
        print_error "Cargo no está disponible"
    fi
    
    # Verificar herramientas instaladas
    local tools=("cargo-watch" "cargo-expand" "cargo-audit" "cargo-outdated" "cargo-tree" "cargo-udeps" "cargo-tarpaulin" "cargo-nextest")
    for tool in "${tools[@]}"; do
        if command -v $tool &> /dev/null; then
            print_success "$tool: instalado"
        else
            print_warning "$tool: no disponible"
        fi
    done
    
    # Verificar protoc
    if command -v protoc &> /dev/null; then
        print_success "protoc: $(protoc --version)"
    else
        print_warning "protoc: no disponible"
    fi

    # Verificar OpenCV (sistema) para el crate de Rust
    if pkg-config --modversion opencv4 &> /dev/null; then
        print_success "OpenCV (sistema): $(pkg-config --modversion opencv4)"
    elif pkg-config --modversion opencv &> /dev/null; then
        print_success "OpenCV (sistema): $(pkg-config --modversion opencv)"
    else
        print_warning "OpenCV (sistema) no detectado via pkg-config. Requiere libopencv-dev/opencv-devel instalado."
    fi

    # Verificar Python env
    if [ -d ".venv" ]; then
        # shellcheck disable=SC1091
        source .venv/bin/activate
        PY_OK=0
        python - << 'EOF'
import sys
try:
    import Bio, cairo_lang, cv2  # noqa: F401
    sys.exit(0)
except Exception:
    sys.exit(1)
EOF
        PY_OK=$?
        if [ $PY_OK -eq 0 ]; then
            print_success "Python (.venv) listo con biopython, cairo-lang y opencv-python"
        else
            print_warning "Python (.venv) presente pero faltan paquetes (biopython/cairo-lang/opencv)"
        fi
    else
        print_warning ".venv no encontrado. Ejecuta setup_python_and_zk_stack para configurarlo"
    fi
}

# Función para mostrar información post-instalación
show_post_installation_info() {
    echo
    print_success "¡Instalación completada exitosamente!"
    echo
    print_status "Próximos pasos:"
    echo "  1. Reinicia tu terminal o ejecuta: source ~/.cargo/env"
    echo "  2. Navega al directorio de un microservicio específico"
    echo "  3. Ejecuta 'cargo new . --name <nombre-del-servicio>' para inicializar"
    echo "  4. Ejecuta 'cargo build' para compilar"
    echo "  5. Ejecuta 'cargo test' para ejecutar tests"
    echo "  6. Ejecuta 'cargo watch -x run' para desarrollo con hot-reload"
    echo
    print_status "Comandos útiles:"
    echo "  • cargo clippy          - Análisis de código"
    echo "  • cargo fmt             - Formatear código"
    echo "  • cargo audit           - Auditoría de seguridad"
    echo "  • cargo outdated        - Verificar dependencias desactualizadas"
    echo "  • cargo tree            - Visualizar dependencias"
    echo "  • cargo tarpaulin       - Cobertura de código"
    echo "  • cargo nextest run     - Testing avanzado"
    echo
    print_status "Recursos útiles:"
    echo "  • Documentación Rust: https://doc.rust-lang.org/"
    echo "  • Cargo Book: https://doc.rust-lang.org/cargo/"
    echo "  • Tokio: https://tokio.rs/"
    echo "  • Tonic (gRPC): https://github.com/hyperium/tonic"
    echo "  • SQLx: https://github.com/launchbadge/sqlx"
    echo
    print_warning "Nota: Si tienes problemas, verifica que Rust esté en tu PATH"
}

# Función principal
main() {
    echo "=========================================="
    echo "  Keiko DApp - Services Layer Setup"
    echo "=========================================="
    echo
    
    # Detectar sistema operativo
    detect_os
    print_status "Sistema operativo detectado: $OS"
    
    # Verificar dependencias del sistema
    check_system_dependencies
    
    # Instalar Rust
    install_rust
    
    # Instalar herramientas para microservicios
    install_microservices_tools
    
    # Configurar Python + stack para pruebas ZK (biometría + Cairo)
    setup_python_and_zk_stack
    
    # Configurar entorno de desarrollo
    setup_development_environment
    
    # Crear estructura del proyecto
    create_project_structure
    
    # Verificar instalaciones
    verify_installations
    
    # Mostrar información post-instalación
    show_post_installation_info
}

# Ejecutar función principal
main "$@"
