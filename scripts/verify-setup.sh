#!/bin/bash

# =============================================================================
# Script de Verificación de Configuración para Keiko Latam
# Verifica que todos los componentes estén correctamente configurados
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

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Función para verificar conectividad de red
check_network() {
    log_info "Verificando conectividad de red..."
    
    if ping -c 1 github.com >/dev/null 2>&1; then
        log_success "GitHub: Conectado"
    else
        log_error "GitHub: Sin conexión"
        return 1
    fi
    
    if ping -c 1 starknet.io >/dev/null 2>&1; then
        log_success "Starknet: Conectado"
    else
        log_warning "Starknet: Sin conexión (puede afectar Cairo)"
    fi
}

# Función para verificar herramientas principales
check_tools() {
    log_info "Verificando herramientas principales..."
    
    local errors=0
    
    # Rust
    if command_exists rustc; then
        log_success "Rust: $(rustc --version | cut -d' ' -f2)"
    else
        log_error "Rust: No instalado"
        ((errors++))
    fi
    
    # Cairo
    if command_exists scarb; then
        log_success "Scarb: $(scarb --version | cut -d' ' -f2)"
    else
        log_error "Scarb: No instalado"
        ((errors++))
    fi
    
    # Starknet Foundry
    if command_exists snforge; then
        log_success "Starknet Foundry: $(snforge --version | cut -d' ' -f2)"
    else
        log_error "Starknet Foundry: No instalado"
        ((errors++))
    fi
    
    # Flutter
    if command_exists flutter; then
        log_success "Flutter: $(flutter --version | head -1 | cut -d' ' -f2)"
    else
        log_error "Flutter: No instalado"
        ((errors++))
    fi
    
    # Podman
    if command_exists podman; then
        log_success "Podman: $(podman --version | cut -d' ' -f3 | cut -d',' -f1)"
    else
        log_error "Podman: No instalado"
        ((errors++))
    fi
    
    # Docker (alternativa)
    if command_exists docker; then
        log_success "Docker: $(docker --version | cut -d' ' -f3 | cut -d',' -f1) (alternativa)"
    else
        log_warning "Docker: No instalado (opcional)"
    fi
    
    # GitFlow
    if command_exists git-flow; then
        log_success "GitFlow: $(git flow version | cut -d' ' -f3)"
    else
        log_error "GitFlow: No instalado"
        ((errors++))
    fi
    
    # Python
    if command_exists python3; then
        log_success "Python: $(python3 --version | cut -d' ' -f2)"
    else
        log_error "Python3: No instalado"
        ((errors++))
    fi
    
    return $errors
}

# Función para verificar servicios locales
check_services() {
    log_info "Verificando servicios locales..."
    
    local errors=0
    
    # PostgreSQL
    if pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
        log_success "PostgreSQL: Activo en puerto 5432"
    else
        log_warning "PostgreSQL: Inactivo (puerto 5432)"
        ((errors++))
    fi
    
    # Redis
    if redis-cli ping >/dev/null 2>&1; then
        log_success "Redis: Activo"
    else
        log_warning "Redis: Inactivo"
        ((errors++))
    fi
    
    return $errors
}

# Función para verificar contenedores
check_containers() {
    log_info "Verificando contenedores..."
    
    # Verificar si hay contenedores ejecutándose
    if command_exists podman; then
        local podman_containers=$(podman ps --format "{{.Names}}" 2>/dev/null | wc -l)
        if [ "$podman_containers" -gt 0 ]; then
            log_success "Podman: $podman_containers contenedor(es) ejecutándose"
        else
            log_info "Podman: No hay contenedores ejecutándose"
        fi
    fi
    
    if command_exists docker; then
        local docker_containers=$(docker ps --format "{{.Names}}" 2>/dev/null | wc -l)
        if [ "$docker_containers" -gt 0 ]; then
            log_success "Docker: $docker_containers contenedor(es) ejecutándose"
        else
            log_info "Docker: No hay contenedores ejecutándose"
        fi
    fi
}

# Función para verificar entorno Python
check_python_env() {
    log_info "Verificando entorno Python..."
    
    if [ -d ".venv" ]; then
        log_success "Entorno virtual: .venv existe"
        
        # Activar entorno y verificar dependencias
        source .venv/bin/activate 2>/dev/null || {
            log_error "No se pudo activar el entorno virtual"
            return 1
        }
        
        # Verificar dependencias críticas
        if python -c "import cv2" >/dev/null 2>&1; then
            log_success "OpenCV: Disponible"
        else
            log_error "OpenCV: No disponible"
        fi
        
        if python -c "import Bio" >/dev/null 2>&1; then
            log_success "BioPython: Disponible"
        else
            log_error "BioPython: No disponible"
        fi
        
        if python -c "import cairo_lang" >/dev/null 2>&1; then
            log_success "cairo-lang: Disponible"
        else
            log_error "cairo-lang: No disponible"
        fi
        
        deactivate 2>/dev/null || true
    else
        log_warning "Entorno virtual: .venv no existe"
        return 1
    fi
}

# Función para verificar archivos de configuración
check_config_files() {
    log_info "Verificando archivos de configuración..."
    
    local errors=0
    
    # Verificar archivos importantes
    local config_files=(
        "Makefile"
        "scripts/gitflow-setup.sh"
        "scripts/install-deps.sh"
        "scripts/appchain-quick-start.sh"
        "scripts/grpc-gateway-quick-start.sh"
        "scripts/services-quick-start.sh"
        "scripts/api-gateway-quick-start.sh"
        "scripts/frontend-quick-start.sh"
        "docs/mkdocs.yml"
        "docs/requirements.txt"
    )
    
    for file in "${config_files[@]}"; do
        if [ -f "$file" ]; then
            log_success "Archivo: $file"
        else
            log_error "Archivo faltante: $file"
            ((errors++))
        fi
    done
    
    return $errors
}

# Función para verificar permisos de scripts
check_script_permissions() {
    log_info "Verificando permisos de scripts..."
    
    local errors=0
    
    # Verificar que los scripts sean ejecutables
    local scripts=(
        "scripts/gitflow-setup.sh"
        "scripts/install-deps.sh"
        "scripts/appchain-quick-start.sh"
        "scripts/grpc-gateway-quick-start.sh"
        "scripts/services-quick-start.sh"
        "scripts/api-gateway-quick-start.sh"
        "scripts/frontend-quick-start.sh"
        "scripts/verify-setup.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            if [ -x "$script" ]; then
                log_success "Ejecutable: $script"
            else
                log_error "No ejecutable: $script"
                ((errors++))
            fi
        fi
    done
    
    return $errors
}

# Función para mostrar resumen
show_summary() {
    echo ""
    echo "📊 Resumen de Verificación"
    echo "=========================="
    echo ""
    
    if [ $1 -eq 0 ]; then
        log_success "¡Configuración completa y correcta!"
        echo ""
        echo "🎉 Keiko Latam está listo para desarrollar"
        echo ""
        echo "Próximos pasos:"
        echo "  • make appchain-start    # Iniciar Keikochain"
        echo "  • make backend-start     # Iniciar Backend"
        echo "  • make frontend-start    # Iniciar Frontend"
        echo "  • make status            # Ver estado"
    else
        log_error "Se encontraron $1 problemas en la configuración"
        echo ""
        echo "🔧 Acciones recomendadas:"
        echo "  • make install-deps      # Instalar dependencias faltantes"
        echo "  • make dev-setup         # Configuración completa"
        echo "  • Revisar logs de errores anteriores"
    fi
}

# Función principal
main() {
    echo "🔍 Verificación de Configuración de Keiko Latam"
    echo "================================================"
    echo ""
    
    local total_errors=0
    local errors=0
    
    # Verificaciones
    check_network || ((total_errors++))
    echo ""
    
    check_tools || ((total_errors++))
    echo ""
    
    check_services || ((total_errors++))
    echo ""
    
    check_containers
    echo ""
    
    check_python_env || ((total_errors++))
    echo ""
    
    check_config_files || ((total_errors++))
    echo ""
    
    check_script_permissions || ((total_errors++))
    echo ""
    
    # Mostrar resumen
    show_summary $total_errors
    
    exit $total_errors
}

# Ejecutar función principal
main "$@"
