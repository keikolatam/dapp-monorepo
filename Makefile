# =============================================================================
# Makefile para Keiko Latam - Plataforma de Colaboración Educativa Descentralizada
# Automatización de tareas de desarrollo, configuración y despliegue
# =============================================================================

# Variables de configuración
PROJECT_NAME := keiko-latam
VERSION := $(shell git describe --tags --always --dirty)
BUILD_TIME := $(shell date -u +%Y-%m-%dT%H:%M:%SZ)
GIT_COMMIT := $(shell git rev-parse --short HEAD)

# Colores para output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
NC := \033[0m # No Color

# Configuración de Docker
DOCKER_REGISTRY := registry.gra.cloud.ovh.net/keikolatam
DOCKER_TAG := $(VERSION)

# Configuración de desarrollo
DEV_ENV := development
STAGING_ENV := staging
PROD_ENV := production

# Flutter local: si existe la instalación en $HOME/flutter, anteponerla al PATH
ifneq (,$(wildcard $(HOME)/flutter/bin/flutter))
export PATH := $(HOME)/flutter/bin:$(PATH)
endif

# =============================================================================
# Targets principales
# =============================================================================

.PHONY: help
help: ## Mostrar ayuda
	@echo "$(CYAN)🎓 Keiko Latam - Comandos disponibles$(NC)"
	@echo "=================================="
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "$(GREEN)%-28s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(YELLOW)🖥️ Desarrollo local (Linux desktop):$(NC)"
	@echo "  make dev-bootstrap               # Toolchain + deps + backend (si compila) + UI"
	@echo "  make dev-mobile-launch-desktop   # Solo la app Flutter en Linux desktop"
	@echo "  make dev-backend-start           # Solo el backend Rust (hoy falla: deuda PR #8)"
	@echo ""
	@echo "$(YELLOW)📱 Device Android físico:$(NC)"
	@echo "  make dev-mobile-launch-device    # Lanzar app en el device conectado (USB o WiFi)"
	@echo "  make dev-mobile-connect-wifi     # Pasar el device a ADB por WiFi (USB la 1ra vez)"

.PHONY: status
status: ## Mostrar estado de todos los componentes
	@echo "$(BLUE)🎓 Estado de Keiko Latam$(NC)"
	@echo "=========================="
	@echo ""
	@echo "$(YELLOW)📊 Componentes del sistema:$(NC)"
	@echo "  • Keikochain: $$(docker ps --filter 'name=keikochain' --format '{{.Status}}' 2>/dev/null || echo 'No disponible')"
	@echo "  • gRPC Gateway: $$(pgrep -f 'grpc-gateway' >/dev/null && echo 'Activo' || echo 'Inactivo')"
	@echo "  • Backend: $$(pgrep -f 'backend' >/dev/null && echo 'Activo' || echo 'Inactivo')"
	@echo "  • PostgreSQL: $$(pg_isready -h localhost -p 5432 >/dev/null 2>&1 && echo 'Activo' || echo 'Inactivo')"
	@echo "  • Redis: $$(redis-cli ping 2>/dev/null || echo 'Inactivo')"
	@echo "  • Python PoH: $$([ -d .venv ] && echo 'Activo (.venv)' || echo 'No configurado')"
	@echo ""
	@echo "$(YELLOW)🔧 Herramientas:$(NC)"
	@echo "  • Podman: $$(podman --version 2>/dev/null | cut -d' ' -f3 | cut -d',' -f1 || echo 'No disponible')"
	@echo "  • Docker: $$(docker --version 2>/dev/null | cut -d' ' -f3 | cut -d',' -f1 || echo 'No disponible')"
	@echo "  • Rust: $$(rustc --version 2>/dev/null | cut -d' ' -f2 || echo 'No disponible')"
	@echo "  • Flutter: $$(flutter --version 2>/dev/null | head -1 | cut -d' ' -f2 || echo 'No disponible')"
	@echo "  • GitFlow: $$(git flow version 2>/dev/null | cut -d' ' -f3 || echo 'No disponible')"
	@echo ""

# =============================================================================
# Configuración inicial y desarrollo
# =============================================================================

.PHONY: dev-setup
dev-setup: install-deps infra-setup db-setup poh-setup gitflow-setup ## Configuración completa de desarrollo
	@echo "$(GREEN)✅ Configuración de desarrollo completada$(NC)"
	@echo "$(CYAN)🎉 ¡Keiko Latam está listo para desarrollar!$(NC)"
	@echo ""
	@echo "$(YELLOW)Próximos pasos:$(NC)"
	@echo "  • make appchain-start    # Iniciar Keikochain"
	@echo "  • make backend-start     # Iniciar Backend"
	@echo "  • make frontend-start    # Iniciar Frontend"
	@echo "  • make status            # Ver estado"

.PHONY: install-deps
install-deps: ## Instalar dependencias del sistema
	@echo "$(BLUE)📦 Instalando dependencias del sistema...$(NC)"
	@./scripts/install-deps.sh

.PHONY: infra-setup
infra-setup: ## Configurar infraestructura (Docker, redes)
	@echo "$(BLUE)🐳 Configurando infraestructura...$(NC)"
	@docker network create keiko-network 2>/dev/null || true
	@echo "$(GREEN)✅ Infraestructura configurada$(NC)"

.PHONY: db-setup
db-setup: ## Configurar bases de datos (PostgreSQL, Redis)
	@echo "$(BLUE)🗄️ Configurando bases de datos...$(NC)"
	@./scripts/db-setup.sh

.PHONY: poh-setup
poh-setup: ## Configurar entorno Python para Proof-of-Humanity
	@echo "$(BLUE)🐍 Configurando entorno Python...$(NC)"
	@python3 -m venv .venv
	@source .venv/bin/activate && pip install --upgrade pip
	@source .venv/bin/activate && pip install -r requirements.txt
	@echo "$(GREEN)✅ Entorno Python configurado$(NC)"

# =============================================================================
# Desarrollo local (Linux desktop) — convención env-recurso-verbo
# =============================================================================

.PHONY: dev-toolchain-check
dev-toolchain-check: ## Verificar toolchain local (Flutter + Linux desktop)
	@echo "$(BLUE)🔧 Verificando toolchain de desarrollo...$(NC)"
	@command -v flutter >/dev/null 2>&1 || { \
		echo "$(RED)❌ Flutter no encontrado en el PATH ni en $$HOME/flutter/bin$(NC)"; \
		echo "$(YELLOW)   Instalalo con:$(NC)"; \
		echo "$(YELLOW)   git clone https://github.com/flutter/flutter.git -b stable $$HOME/flutter$(NC)"; \
		exit 1; }
	@echo "$(GREEN)✅ Flutter: $$(flutter --version 2>/dev/null | head -1)$(NC)"
	@command -v ninja >/dev/null 2>&1 || { \
		echo "$(RED)❌ ninja no encontrado (requerido para Linux desktop)$(NC)"; \
		echo "$(YELLOW)   sudo apt install ninja-build clang cmake pkg-config$(NC)"; \
		exit 1; }
	@pkg-config --exists gtk+-3.0 2>/dev/null || { \
		echo "$(RED)❌ GTK3 (dev) no encontrado (requerido para Linux desktop)$(NC)"; \
		echo "$(YELLOW)   sudo apt install libgtk-3-dev$(NC)"; \
		exit 1; }
	@flutter devices 2>/dev/null | grep -q "linux" || { \
		echo "$(RED)❌ Linux desktop no aparece como dispositivo Flutter$(NC)"; \
		echo "$(YELLOW)   Ejecutá: flutter config --enable-linux-desktop$(NC)"; \
		echo "$(YELLOW)   Y revisá deps de sistema: sudo apt install ninja-build libgtk-3-dev clang cmake pkg-config$(NC)"; \
		exit 1; }
	@echo "$(GREEN)✅ Toolchain Linux desktop OK$(NC)"

.PHONY: dev-mobile-deps-get
dev-mobile-deps-get: ## Instalar dependencias Flutter (apps/mobile)
	@echo "$(BLUE)📦 Instalando dependencias Flutter (apps/mobile)...$(NC)"
	@cd apps/mobile && flutter pub get

.PHONY: dev-mobile-launch-desktop
dev-mobile-launch-desktop: ## Lanzar app Coach en Linux desktop
	@echo "$(BLUE)🖥️ Lanzando app Flutter en Linux desktop...$(NC)"
	@cd apps/mobile && flutter run -d linux

.PHONY: dev-mobile-launch-device
dev-mobile-launch-device: ## Lanzar app en device Android físico (USB o WiFi)
	@command -v adb >/dev/null 2>&1 || { \
		echo "$(RED)❌ adb no encontrado$(NC)"; \
		echo "$(YELLOW)   sudo apt install adb (o Android SDK platform-tools)$(NC)"; \
		exit 1; }
	@SERIAL=$$(adb devices | awk 'NR>1 && $$2=="device" {print $$1; exit}'); \
	if [ -z "$$SERIAL" ]; then \
		echo "$(RED)❌ Ningún device Android autorizado (revisá: adb devices)$(NC)"; \
		echo "$(YELLOW)   Conectá el teléfono por USB, habilitá Depuración USB y aceptá el prompt en pantalla$(NC)"; \
		echo "$(YELLOW)   O conectalo por WiFi primero: make dev-mobile-connect-wifi$(NC)"; \
		exit 1; \
	fi; \
	echo "$(GREEN)✅ Device detectado: $$SERIAL$(NC)"; \
	echo "$(BLUE)📱 Lanzando app Flutter en el device...$(NC)"; \
	cd apps/mobile && flutter run -d "$$SERIAL"

.PHONY: dev-mobile-connect-wifi
dev-mobile-connect-wifi: ## Conectar device Android vía WiFi ADB (requiere USB la primera vez)
	@command -v adb >/dev/null 2>&1 || { \
		echo "$(RED)❌ adb no encontrado$(NC)"; \
		echo "$(YELLOW)   sudo apt install adb (o Android SDK platform-tools)$(NC)"; \
		exit 1; }
	@SERIAL=$$(adb devices | awk 'NR>1 && $$2=="device" && $$1 !~ /:/ {print $$1; exit}'); \
	if [ -z "$$SERIAL" ]; then \
		echo "$(RED)❌ Ningún device Android por USB (necesario para habilitar el modo TCP/IP)$(NC)"; \
		echo "$(YELLOW)   Conectá el teléfono por USB con Depuración USB activada y reintentá$(NC)"; \
		exit 1; \
	fi; \
	IP=$$(adb -s "$$SERIAL" shell ip route 2>/dev/null | awk '/wlan/ {print $$9; exit}'); \
	if [ -z "$$IP" ]; then \
		echo "$(RED)❌ No pude obtener la IP WiFi del device (¿WiFi activado y en la misma red?)$(NC)"; \
		exit 1; \
	fi; \
	echo "$(BLUE)📡 Habilitando ADB por TCP/IP (puerto 5555) en $$SERIAL...$(NC)"; \
	adb -s "$$SERIAL" tcpip 5555; \
	sleep 2; \
	adb connect "$$IP:5555"; \
	echo "$(GREEN)✅ Device conectado por WiFi ($$IP:5555). Ya podés desenchufar el USB.$(NC)"; \
	echo "$(YELLOW)   Lanzá la app con: make dev-mobile-launch-device$(NC)"

.PHONY: dev-backend-build
dev-backend-build: ## Compilar backend Rust (keiko-backend)
	@echo "$(BLUE)⚙️ Compilando backend (cargo build -p keiko-backend)...$(NC)"
	@cargo build -p keiko-backend || { \
		echo ""; \
		echo "$(RED)❌ El backend NO compila hoy: deuda preexistente del workspace Rust$(NC)"; \
		echo "$(YELLOW)   Falta el crate 'shared' y hay workspace.dependencies sin declarar.$(NC)"; \
		echo "$(YELLOW)   Deuda documentada en el PR #8 (Fase 0) e issue #2.$(NC)"; \
		echo "$(YELLOW)   La UI local funciona igual: make dev-mobile-launch-desktop$(NC)"; \
		exit 1; }

.PHONY: dev-backend-start
dev-backend-start: dev-backend-build ## Iniciar backend local (falla honesto si no compila)
	@echo "$(GREEN)✅ Backend compilado, iniciando...$(NC)"
	@cargo run -p keiko-backend

.PHONY: dev-bootstrap
dev-bootstrap: dev-toolchain-check dev-mobile-deps-get ## Levantar entorno local: backend (si compila) + UI Linux desktop
	@echo "$(BLUE)🚀 Bootstrap de desarrollo local...$(NC)"
	@if $(MAKE) dev-backend-build; then \
		mkdir -p logs; \
		echo "$(GREEN)✅ Iniciando backend en segundo plano (logs/backend-dev.log)...$(NC)"; \
		( cargo run -p keiko-backend > logs/backend-dev.log 2>&1 & ); \
	else \
		echo "$(YELLOW)⚠️ Backend omitido (no compila — deuda PR #8 / issue #2). Continuando solo con la UI...$(NC)"; \
	fi
	@$(MAKE) dev-mobile-launch-desktop

# =============================================================================
# GitFlow
# =============================================================================

.PHONY: gitflow-setup
gitflow-setup: ## Configurar GitFlow
	@echo "$(BLUE)🔄 Configurando GitFlow...$(NC)"
	@./scripts/gitflow-setup.sh configure
	@echo "$(GREEN)✅ GitFlow configurado$(NC)"

.PHONY: gitflow-status
gitflow-status: ## Ver estado de GitFlow
	@echo "$(BLUE)🔄 Estado de GitFlow$(NC)"
	@./scripts/gitflow-setup.sh status

.PHONY: create-release
create-release: ## Crear release (uso: make create-release VERSION=1.0.0)
	@if [ -z "$(VERSION)" ]; then \
		echo "$(RED)❌ Error: Especifica VERSION. Ejemplo: make create-release VERSION=1.0.0$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)🚀 Creando release $(VERSION)...$(NC)"
	@git flow release start $(VERSION)
	@echo "$(GREEN)✅ Release $(VERSION) iniciada$(NC)"

.PHONY: create-hotfix
create-hotfix: ## Crear hotfix (uso: make create-hotfix NAME=critical)
	@if [ -z "$(NAME)" ]; then \
		echo "$(RED)❌ Error: Especifica NAME. Ejemplo: make create-hotfix NAME=critical$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)🚨 Creando hotfix $(NAME)...$(NC)"
	@git flow hotfix start $(NAME)
	@echo "$(GREEN)✅ Hotfix $(NAME) iniciada$(NC)"

# =============================================================================
# Componentes individuales
# =============================================================================

.PHONY: appchain-start
appchain-start: ## Iniciar Keikochain (Starknet Appchain)
	@echo "$(BLUE)⛓️ Iniciando Keikochain...$(NC)"
	@./scripts/appchain-quick-start.sh --non-interactive

.PHONY: appchain-stop
appchain-stop: ## Detener Keikochain
	@echo "$(BLUE)⛓️ Deteniendo Keikochain...$(NC)"
	@podman-compose -f apps/appchain/docker-compose.yml down || docker-compose -f apps/appchain/docker-compose.yml down

.PHONY: grpc-gateway-start
grpc-gateway-start: ## Iniciar gRPC Gateway
	@echo "$(BLUE)🌉 Iniciando gRPC Gateway...$(NC)"
	@./scripts/grpc-gateway-quick-start.sh

.PHONY: backend-start
backend-start: ## Iniciar Backend monolítico modular
	@echo "$(BLUE)⚙️ Iniciando Backend...$(NC)"
	@./scripts/backend-quick-start.sh

.PHONY: backend-stop
backend-stop: ## Detener Backend
	@echo "$(BLUE)⚙️ Deteniendo Backend...$(NC)"
	@pkill -f "backend" || true

.PHONY: frontend-start
frontend-start: ## Iniciar Frontend Flutter
	@echo "$(BLUE)🌐 Iniciando Frontend...$(NC)"
	@cd apps/mobile && flutter run -d web-server --web-port 3001

.PHONY: api-gateway-start
api-gateway-start: ## Iniciar API Gateway
	@echo "$(BLUE)🔌 Iniciando API Gateway...$(NC)"
	@./scripts/api-gateway-quick-start.sh

# =============================================================================
# Testing y calidad
# =============================================================================

.PHONY: test-all
test-all: test-rust test-python test-flutter ## Ejecutar todos los tests

.PHONY: test-rust
test-rust: ## Ejecutar tests de Rust
	@echo "$(BLUE)🧪 Ejecutando tests de Rust...$(NC)"
	@cargo test --workspace

.PHONY: test-python
test-python: ## Ejecutar tests de Python
	@echo "$(BLUE)🧪 Ejecutando tests de Python...$(NC)"
	@source .venv/bin/activate && python -m pytest tests/python/

.PHONY: test-flutter
test-flutter: ## Ejecutar tests de Flutter
	@echo "$(BLUE)🧪 Ejecutando tests de Flutter...$(NC)"
	@cd apps/mobile && flutter test

.PHONY: lint-all
lint-all: lint-rust lint-python lint-flutter ## Ejecutar linting completo

.PHONY: lint-rust
lint-rust: ## Ejecutar linting de Rust
	@echo "$(BLUE)🔍 Ejecutando linting de Rust...$(NC)"
	@cargo fmt -- --check
	@cargo clippy -- -D warnings

.PHONY: lint-python
lint-python: ## Ejecutar linting de Python
	@echo "$(BLUE)🔍 Ejecutando linting de Python...$(NC)"
	@source .venv/bin/activate && flake8 .
	@source .venv/bin/activate && black --check .

.PHONY: lint-flutter
lint-flutter: ## Ejecutar linting de Flutter
	@echo "$(BLUE)🔍 Ejecutando linting de Flutter...$(NC)"
	@cd apps/mobile && flutter analyze

# =============================================================================
# Build y deployment
# =============================================================================

.PHONY: build-all
build-all: build-rust build-flutter ## Construir todos los componentes

.PHONY: build-rust
build-rust: ## Construir componentes Rust
	@echo "$(BLUE)🏗️ Construyendo componentes Rust...$(NC)"
	@cargo build --release --workspace

.PHONY: build-flutter
build-flutter: ## Construir aplicación Flutter
	@echo "$(BLUE)🏗️ Construyendo aplicación Flutter...$(NC)"
	@cd apps/mobile && flutter build web

.PHONY: container-build
container-build: ## Construir imágenes de contenedor (Podman/Docker)
	@echo "$(BLUE)🐳 Construyendo imágenes de contenedor...$(NC)"
	@podman build -t $(DOCKER_REGISTRY)/keiko-backend:$(DOCKER_TAG) -f apps/backend/Dockerfile . || \
	 docker build -t $(DOCKER_REGISTRY)/keiko-backend:$(DOCKER_TAG) -f apps/backend/Dockerfile .
	@podman build -t $(DOCKER_REGISTRY)/keiko-frontend:$(DOCKER_TAG) -f apps/mobile/Dockerfile apps/mobile/ || \
	 docker build -t $(DOCKER_REGISTRY)/keiko-frontend:$(DOCKER_TAG) -f apps/mobile/Dockerfile apps/mobile/

.PHONY: container-push
container-push: container-build ## Push imágenes de contenedor al registry
	@echo "$(BLUE)🚀 Pusheando imágenes de contenedor...$(NC)"
	@podman push $(DOCKER_REGISTRY)/keiko-backend:$(DOCKER_TAG) || \
	 docker push $(DOCKER_REGISTRY)/keiko-backend:$(DOCKER_TAG)
	@podman push $(DOCKER_REGISTRY)/keiko-frontend:$(DOCKER_TAG) || \
	 docker push $(DOCKER_REGISTRY)/keiko-frontend:$(DOCKER_TAG)

# =============================================================================
# Utilidades
# =============================================================================

.PHONY: logs
logs: ## Ver logs de todos los servicios
	@echo "$(BLUE)📋 Logs del sistema$(NC)"
	@echo "=========================="
	@echo ""
	@echo "$(YELLOW)🐳 Contenedores:$(NC)"
	@podman-compose logs --tail=50 2>/dev/null || docker-compose logs --tail=50 2>/dev/null || echo "No hay contenedores ejecutándose"
	@echo ""
	@echo "$(YELLOW)⚙️ Backend logs:$(NC)"
	@tail -20 logs/backend.log 2>/dev/null || echo "No hay logs de backend"
	@echo ""
	@echo "$(YELLOW)🌉 gRPC Gateway logs:$(NC)"
	@tail -20 logs/gateway.log 2>/dev/null || echo "No hay logs de gateway"

.PHONY: clean
clean: ## Limpiar contenedores, volúmenes y archivos temporales
	@echo "$(BLUE)🧹 Limpiando sistema...$(NC)"
	@podman-compose down -v --remove-orphans 2>/dev/null || docker-compose down -v --remove-orphans 2>/dev/null || true
	@podman system prune -f 2>/dev/null || docker system prune -f 2>/dev/null || true
	@rm -rf logs/*.log
	@rm -rf target/debug target/release
	@rm -rf apps/mobile/build
	@echo "$(GREEN)✅ Sistema limpiado$(NC)"

.PHONY: verify-setup
verify-setup: ## Verificar configuración completa
	@echo "$(BLUE)🔍 Verificando configuración...$(NC)"
	@./scripts/verify-setup.sh

.PHONY: poh-examples
poh-examples: ## Ejecutar ejemplos de Proof-of-Humanity
	@echo "$(BLUE)🔐 Ejecutando ejemplos de Proof-of-Humanity...$(NC)"
	@source .venv/bin/activate && python scripts/poh-examples.py

.PHONY: poh-key-gen
poh-key-gen: ## Generar ejemplo de humanity_proof_key
	@echo "$(BLUE)🔑 Generando humanity_proof_key de ejemplo...$(NC)"
	@source .venv/bin/activate && python scripts/poh-key-gen.py

# =============================================================================
# Documentación
# =============================================================================

.PHONY: docs-serve
docs-serve: ## Servir documentación localmente
	@echo "$(BLUE)📚 Sirviendo documentación en http://localhost:8000$(NC)"
	@cd docs && mkdocs serve

.PHONY: docs-build
docs-build: ## Construir documentación
	@echo "$(BLUE)📚 Construyendo documentación...$(NC)"
	@cd docs && mkdocs build

.PHONY: docs-deploy
docs-deploy: ## Desplegar documentación a GitHub Pages
	@echo "$(BLUE)🚀 Desplegando documentación...$(NC)"
	@cd docs && mkdocs gh-deploy

# =============================================================================
# Información del proyecto
# =============================================================================

.PHONY: info
info: ## Mostrar información del proyecto
	@echo "$(CYAN)🎓 Keiko Latam - Información del Proyecto$(NC)"
	@echo "============================================="
	@echo ""
	@echo "$(YELLOW)📋 Detalles:$(NC)"
	@echo "  • Nombre: $(PROJECT_NAME)"
	@echo "  • Versión: $(VERSION)"
	@echo "  • Commit: $(GIT_COMMIT)"
	@echo "  • Build: $(BUILD_TIME)"
	@echo ""
	@echo "$(YELLOW)🏗️ Arquitectura:$(NC)"
	@echo "  • Frontend: Flutter (Web/Mobile)"
	@echo "  • API Gateway: GraphQL + REST (Rust)"
	@echo "  • Backend: Monolítico Modular (Rust)"
	@echo "  • gRPC Gateway: Rust ↔ Cairo (Rust)"
	@echo "  • Blockchain: Keikochain (Cairo + Starknet)"
	@echo ""
	@echo "$(YELLOW)🔗 Enlaces:$(NC)"
	@echo "  • GitHub: https://github.com/keikolatam/dapp-monorepo"
	@echo "  • Documentación: https://keikolatam.github.io/dapp-monorepo"
	@echo "  • Discord: https://discord.gg/keikolatam"
	@echo ""

.PHONY: version
version: ## Mostrar versión actual
	@echo "$(VERSION)"

# =============================================================================
# Configuración por defecto
# =============================================================================

.DEFAULT_GOAL := help

# Variables de entorno
export RUST_LOG := info
export RUST_BACKTRACE := 1
export FLUTTER_WEB_AUTO_DETECT := true
