#!/bin/bash

# =============================================================================
# Script de Instalación de Dependencias para Keiko Latam
# Instala todas las dependencias necesarias para el desarrollo
# =============================================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Función para detectar sistema operativo
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get >/dev/null 2>&1; then
            echo "ubuntu"
        elif command -v yum >/dev/null 2>&1; then
            echo "rhel"
        elif command -v dnf >/dev/null 2>&1; then
            echo "fedora"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Función para instalar Rust
install_rust() {
    if command_exists rustc; then
        log_success "Rust ya está instalado: $(rustc --version)"
        return 0
    fi
    
    log_info "Instalando Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
    
    # Instalar toolchain nightly para Cairo
    rustup toolchain install nightly
    rustup default stable
    rustup target add wasm32-unknown-unknown --toolchain nightly
    
    log_success "Rust instalado correctamente"
}

# Función para instalar Cairo y Starknet
install_cairo() {
    if command_exists scarb && command_exists snforge; then
        log_success "Cairo ya está instalado"
        return 0
    fi
    
    log_info "Instalando Cairo y Starknet..."
    
    # Instalar asdf si no existe
    if ! command_exists asdf; then
        log_info "Instalando asdf..."
        git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1
        echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
        echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc
        source ~/.bashrc
    fi
    
    # Instalar Scarb
    curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh
    
    # Instalar Starknet Foundry
    curl -L https://raw.githubusercontent.com/foundry-rs/starknet-foundry/master/scripts/install.sh | sh
    
    log_success "Cairo y Starknet instalados correctamente"
}

# Función para instalar Flutter
install_flutter() {
    if command_exists flutter; then
        log_success "Flutter ya está instalado: $(flutter --version | head -1)"
        return 0
    fi
    
    log_info "Instalando Flutter..."
    
    # Clonar Flutter
    git clone https://github.com/flutter/flutter.git -b stable ~/flutter
    
    # Agregar al PATH
    echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
    export PATH="$PATH:$HOME/flutter/bin"
    
    # Ejecutar doctor para configurar
    flutter doctor --android-licenses || true
    
    log_success "Flutter instalado correctamente"
}

# Función para instalar dependencias del sistema (Ubuntu/Debian)
install_ubuntu_deps() {
    log_info "Instalando dependencias para Ubuntu/Debian..."
    
    sudo apt update && sudo apt upgrade -y
    
    sudo apt install -y \
        build-essential \
        pkg-config \
        libssl-dev \
        libudev-dev \
        libclang-dev \
        cmake \
        git \
        curl \
        wget \
        unzip \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        podman \
        podman-compose \
        docker.io \
        docker-compose \
        postgresql-client \
        redis-tools \
        jq \
        make \
        libopencv-dev \
        libgstreamer1.0-dev \
        libgstreamer-plugins-base1.0-dev
    
    # Iniciar Podman (y Docker como alternativa)
    sudo systemctl enable podman
    sudo systemctl start podman
    sudo systemctl enable docker
    sudo systemctl start docker
    
    # Agregar usuario al grupo podman
    sudo usermod -aG podman $USER
    sudo usermod -aG docker $USER
    
    log_success "Dependencias de Ubuntu instaladas"
}

# Función para instalar dependencias del sistema (macOS)
install_macos_deps() {
    log_info "Instalando dependencias para macOS..."
    
    # Instalar Homebrew si no existe
    if ! command_exists brew; then
        log_info "Instalando Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Instalar dependencias
    brew install \
        pkg-config \
        openssl \
        cmake \
        git \
        curl \
        wget \
        python3 \
        podman \
        podman-compose \
        docker \
        docker-compose \
        postgresql \
        redis \
        jq \
        make \
        opencv
    
    log_success "Dependencias de macOS instaladas"
}

# Función para instalar dependencias del sistema (RHEL/CentOS)
install_rhel_deps() {
    log_info "Instalando dependencias para RHEL/CentOS..."
    
    sudo yum update -y
    
    sudo yum groupinstall -y "Development Tools"
    sudo yum install -y \
        pkgconfig \
        openssl-devel \
        libudev-devel \
        clang \
        cmake \
        git \
        curl \
        wget \
        unzip \
        python3 \
        python3-pip \
        python3-devel \
        docker \
        docker-compose \
        postgresql \
        redis \
        jq \
        make \
        opencv-devel
    
    # Iniciar Docker
    sudo systemctl enable docker
    sudo systemctl start docker
    
    log_success "Dependencias de RHEL instaladas"
}

# Función para instalar dependencias del sistema (Fedora)
install_fedora_deps() {
    log_info "Instalando dependencias para Fedora..."
    
    sudo dnf update -y
    
    sudo dnf groupinstall -y "Development Tools"
    sudo dnf install -y \
        pkgconfig \
        openssl-devel \
        libudev-devel \
        clang \
        cmake \
        git \
        curl \
        wget \
        unzip \
        python3 \
        python3-pip \
        python3-devel \
        docker \
        docker-compose \
        postgresql \
        redis \
        jq \
        make \
        opencv-devel
    
    # Iniciar Docker
    sudo systemctl enable docker
    sudo systemctl start docker
    
    log_success "Dependencias de Fedora instaladas"
}

# Función para instalar GitFlow
install_gitflow() {
    if command_exists git-flow; then
        log_success "GitFlow ya está instalado"
        return 0
    fi
    
    log_info "Instalando GitFlow..."
    
    OS=$(detect_os)
    case $OS in
        "ubuntu")
            sudo apt install -y git-flow
            ;;
        "rhel"|"fedora")
            sudo yum install -y gitflow || sudo dnf install -y gitflow
            ;;
        "macos")
            brew install git-flow
            ;;
        *)
            # Instalación manual
            wget --no-check-certificate -q https://raw.github.com/nvie/gitflow/develop/contrib/gitflow-installer.sh
            chmod +x gitflow-installer.sh
            sudo ./gitflow-installer.sh
            rm gitflow-installer.sh
            ;;
    esac
    
    log_success "GitFlow instalado correctamente"
}

# Función para verificar instalación
verify_installation() {
    log_info "Verificando instalación..."
    
    local errors=0
    
    # Verificar Rust
    if command_exists rustc; then
        log_success "Rust: $(rustc --version)"
    else
        log_error "Rust no está instalado"
        ((errors++))
    fi
    
    # Verificar Cairo
    if command_exists scarb; then
        log_success "Scarb: $(scarb --version)"
    else
        log_error "Scarb no está instalado"
        ((errors++))
    fi
    
    # Verificar Starknet Foundry
    if command_exists snforge; then
        log_success "Starknet Foundry: $(snforge --version)"
    else
        log_error "Starknet Foundry no está instalado"
        ((errors++))
    fi
    
    # Verificar Flutter
    if command_exists flutter; then
        log_success "Flutter: $(flutter --version | head -1)"
    else
        log_error "Flutter no está instalado"
        ((errors++))
    fi
    
    # Verificar Podman
    if command_exists podman; then
        log_success "Podman: $(podman --version)"
    else
        log_error "Podman no está instalado"
        ((errors++))
    fi
    
    # Verificar Docker (alternativa)
    if command_exists docker; then
        log_success "Docker: $(docker --version)"
    else
        log_warning "Docker no está instalado (opcional, Podman es preferido)"
    fi
    
    # Verificar GitFlow
    if command_exists git-flow; then
        log_success "GitFlow: $(git flow version)"
    else
        log_error "GitFlow no está instalado"
        ((errors++))
    fi
    
    # Verificar Python
    if command_exists python3; then
        log_success "Python: $(python3 --version)"
    else
        log_error "Python3 no está instalado"
        ((errors++))
    fi
    
    if [ $errors -eq 0 ]; then
        log_success "Todas las dependencias están instaladas correctamente"
        return 0
    else
        log_error "Se encontraron $errors errores en la instalación"
        return 1
    fi
}

# Función principal
main() {
    echo "🚀 Instalación de Dependencias para Keiko Latam"
    echo "==============================================="
    echo ""
    
    # Detectar sistema operativo
    OS=$(detect_os)
    log_info "Sistema detectado: $OS"
    
    # Instalar dependencias del sistema
    case $OS in
        "ubuntu")
            install_ubuntu_deps
            ;;
        "rhel")
            install_rhel_deps
            ;;
        "fedora")
            install_fedora_deps
            ;;
        "macos")
            install_macos_deps
            ;;
        *)
            log_warning "Sistema operativo no soportado: $OS"
            log_info "Intentando instalación manual..."
            ;;
    esac
    
    # Instalar herramientas principales
    install_rust
    install_cairo
    install_flutter
    install_gitflow
    
    # Verificar instalación
    echo ""
    verify_installation
    
    echo ""
    log_success "Instalación completada!"
    echo ""
    echo "🎉 ¡Keiko Latam está listo para desarrollar!"
    echo ""
    echo "Próximos pasos:"
    echo "  • make dev-setup     # Configuración completa"
    echo "  • make status        # Ver estado"
    echo "  • make verify-setup  # Verificar configuración"
    echo ""
    echo "💡 Nota: Es posible que necesites reiniciar tu terminal"
    echo "   para que los cambios en PATH tomen efecto."
}

# Ejecutar función principal
main "$@"
