#!/bin/bash

# =============================================================================
# GitFlow Setup Script para Keiko Latam
# Configura GitFlow para el flujo de trabajo de desarrollo
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

# Función para verificar si git-flow está instalado
check_git_flow() {
    if command -v git-flow >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Función para instalar git-flow
install_git_flow() {
    log_info "Instalando git-flow..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Detectar distribución
        if command -v apt-get >/dev/null 2>&1; then
            log_info "Detectado Ubuntu/Debian, instalando con apt..."
            echo "Por favor ejecuta: sudo apt update && sudo apt install -y git-flow"
            echo "Luego vuelve a ejecutar este script."
            return 1
        elif command -v yum >/dev/null 2>&1; then
            log_info "Detectado RHEL/CentOS, instalando con yum..."
            echo "Por favor ejecuta: sudo yum install -y gitflow"
            echo "Luego vuelve a ejecutar este script."
            return 1
        elif command -v dnf >/dev/null 2>&1; then
            log_info "Detectado Fedora, instalando con dnf..."
            echo "Por favor ejecuta: sudo dnf install -y gitflow"
            echo "Luego vuelve a ejecutar este script."
            return 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "Detectado macOS, instalando con Homebrew..."
        if command -v brew >/dev/null 2>&1; then
            brew install git-flow
            return 0
        else
            echo "Por favor instala Homebrew primero: https://brew.sh/"
            return 1
        fi
    else
        log_error "Sistema operativo no soportado: $OSTYPE"
        return 1
    fi
}

# Función para configurar GitFlow
configure_git_flow() {
    log_info "Configurando GitFlow para Keiko Latam..."
    
    # Verificar que estamos en un repositorio git
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "No estás en un repositorio Git. Ejecuta este script desde la raíz del proyecto."
        exit 1
    fi
    
    # Verificar que existe la rama main
    if ! git show-ref --verify --quiet refs/heads/main; then
        log_warning "La rama 'main' no existe. Creándola..."
        git checkout -b main
    fi
    
    # Inicializar GitFlow con configuración por defecto
    log_info "Inicializando GitFlow..."
    git flow init -d
    
    # Configurar nombres personalizados para Keiko Latam
    log_info "Configurando nombres de ramas personalizados..."
    git flow config set master main
    git flow config set develop develop
    git flow config set feature feature/
    git flow config set release release/
    git flow config set hotfix hotfix/
    git flow config set support support/
    git flow config set versiontag v
    
    # Crear rama develop si no existe
    if ! git show-ref --verify --quiet refs/heads/develop; then
        log_info "Creando rama develop..."
        git checkout -b develop
        git push -u origin develop
    fi
    
    log_success "GitFlow configurado correctamente!"
}

# Función para mostrar el estado actual
show_status() {
    log_info "Estado actual del repositorio:"
    echo ""
    echo "📋 Ramas disponibles:"
    git branch -a
    echo ""
    echo "📊 Configuración GitFlow:"
    git flow config
    echo ""
    echo "🔄 Estado actual:"
    git status --short
}

# Función para mostrar ayuda
show_help() {
    echo "GitFlow Setup para Keiko Latam"
    echo ""
    echo "Uso: $0 [OPCIÓN]"
    echo ""
    echo "Opciones:"
    echo "  install     Instalar git-flow"
    echo "  configure   Configurar GitFlow en el repositorio"
    echo "  status      Mostrar estado actual"
    echo "  help        Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 install     # Instalar git-flow"
    echo "  $0 configure   # Configurar GitFlow"
    echo "  $0 status      # Ver estado"
    echo ""
    echo "Flujo de trabajo GitFlow para Keiko:"
    echo "  develop    → entorno dev"
    echo "  qa         → entorno qa"
    echo "  staging    → entorno stage"
    echo "  main       → entorno production"
    echo "  release/*  → preparación de releases"
    echo "  hotfix/*   → correcciones urgentes"
}

# Función principal
main() {
    echo "🚀 GitFlow Setup para Keiko Latam"
    echo "=================================="
    echo ""
    
    case "${1:-configure}" in
        "install")
            if check_git_flow; then
                log_success "git-flow ya está instalado!"
            else
                install_git_flow
            fi
            ;;
        "configure")
            if ! check_git_flow; then
                log_error "git-flow no está instalado. Ejecuta primero: $0 install"
                exit 1
            fi
            configure_git_flow
            show_status
            ;;
        "status")
            show_status
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            log_error "Opción desconocida: $1"
            show_help
            exit 1
            ;;
    esac
}

# Ejecutar función principal
main "$@"
