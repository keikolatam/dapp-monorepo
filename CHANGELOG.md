# 📋 Changelog - Keiko Latam

Todos los cambios notables de este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

## [Unreleased]

### ✨ Added
- **GitFlow Workflow**: Configuración completa de GitFlow para desarrollo organizado
- **Material for MkDocs**: Documentación moderna e interactiva con tema personalizado
- **Scripts Centralizados**: Todos los scripts quick-start.sh movidos a `./scripts/`
- **Backend Modular**: Refactorización de `./services` a `./backend` según design.md
- **Podman Support**: Soporte preferencial para Podman sobre Docker
- **Makefile Completo**: Comandos make para automatización de tareas
- **GitHub Actions**: Pipelines de CI/CD para GitFlow y documentación
- **Scripts de Verificación**: Verificación automática de configuración

### 🔄 Changed
- **Documentación**: Actualizada para usar Podman como preferencia sobre Docker
- **Scripts**: Reorganizados y centralizados en `./scripts/` con nombres descriptivos
- **Makefile**: Actualizado para usar nuevas ubicaciones de scripts
- **Instalación**: Scripts de instalación actualizados para incluir Podman
- **Backend**: Arquitectura migrada de microservicios a aplicación monolítica modular

### 🗑️ Removed
- Scripts duplicados en directorios individuales (movidos a `./scripts/`)
- Estructura de microservicios (migrada a módulos monolíticos)

## [0.1.0] - 2024-09-22

### ✨ Added
- Estructura inicial del proyecto Keiko Latam
- Arquitectura híbrida de 5 capas
- Especificaciones técnicas detalladas
- Configuración base de desarrollo

---

## 📝 Detalles de Cambios

### 🔄 GitFlow Implementation

**Archivos agregados:**
- `scripts/gitflow-setup.sh` - Configuración automática de GitFlow
- `.github/workflows/gitflow.yml` - Pipeline CI/CD para GitFlow
- `docs/development/gitflow.md` - Documentación completa de GitFlow

**Características:**
- Configuración automática para WSL2 Ubuntu 24.04 LTS
- Mapeo de branches a entornos (develop → dev, main → production)
- Automatización de releases y hotfixes
- Integración con GitHub Actions

### 📚 Material for MkDocs

**Archivos agregados:**
- `docs/mkdocs.yml` - Configuración completa de Material for MkDocs
- `docs/index.md` - Página principal con diseño moderno
- `docs/getting-started/` - Guías de instalación y configuración
- `docs/architecture/overview.md` - Documentación de arquitectura
- `docs/development/gitflow.md` - Guía de GitFlow
- `docs/stylesheets/keiko-custom.css` - Estilos personalizados
- `docs/javascripts/keiko-custom.js` - Funcionalidades interactivas
- `docs/requirements.txt` - Dependencias de documentación
- `.github/workflows/docs-deploy.yml` - Despliegue automático

**Características:**
- Tema dinámico (claro/oscuro)
- Elementos interactivos con JavaScript
- Diagramas Mermaid integrados
- Despliegue automático en GitHub Pages
- Responsive design para móviles
- Búsqueda avanzada en tiempo real

### 📁 Scripts Reorganizados

**Scripts movidos:**
- `appchain/quick-start.sh` → `scripts/appchain-quick-start.sh`
- `grpc-gateway/quick-start.sh` → `scripts/grpc-gateway-quick-start.sh`
- `services/quick-start.sh` → `scripts/backend-quick-start.sh`
- `api-gateway/quick-start.sh` → `scripts/api-gateway-quick-start.sh`
- `frontend/quick-start.sh` → `scripts/frontend-quick-start.sh`

**Archivos actualizados:**
- `Makefile` - Referencias actualizadas a nuevos scripts
- `docs/getting-started/quick-setup.md` - Referencias actualizadas
- `README.md` - Referencias actualizadas

### 🏗️ Backend Modular Refactoring

**Estructura anterior (Microservicios):**
```
services/
├── identity-service/
├── learning-service/
├── reputation-service/
├── passport-service/
├── governance-service/
├── marketplace-service/
└── quick-start.sh
```

**Nueva estructura (Monolítico Modular):**
```
backend/
├── modules/
│   ├── identity/          # Autenticación y usuarios
│   ├── learning_passport/ # Interacciones xAPI y pasaportes
│   ├── reputation/        # Sistema de reputación
│   ├── governance/        # Herramientas de gobernanza
│   ├── marketplace/       # Gestión de espacios
│   └── selfstudy_guides/  # Guías de auto-estudio
├── shared/                # Componentes compartidos
├── src/main.rs            # Punto de entrada monolítico
└── Cargo.toml             # Configuración principal
```

**Beneficios de la migración:**
- **Simplicidad operacional**: Un solo proceso vs múltiples microservicios
- **Comunicación eficiente**: In-memory vs gRPC entre servicios
- **Desarrollo más rápido**: Menos overhead de infraestructura
- **Debugging simplificado**: Stack traces unificados
- **Deployment simplificado**: Un solo binario
- **Preparado para el futuro**: Fácil extracción a microservicios cuando sea necesario

**Fusión de módulos:**
- **Learning + Passport**: Los módulos `learning` y `passport` se fusionaron en `learning_passport` ya que las interacciones de aprendizaje se almacenan directamente en el pasaporte del usuario según los requirements
- **Cohesión funcional**: El nuevo módulo maneja tanto las interacciones xAPI como la agregación en pasaportes de aprendizaje

### 🐳 Podman Support

**Cambios realizados:**
- Documentación actualizada para preferir Podman sobre Docker
- Scripts de instalación incluyen Podman
- Makefile actualizado para usar Podman con fallback a Docker
- Scripts de verificación incluyen Podman

**Archivos modificados:**
- `docs/getting-started/installation.md`
- `docs/getting-started/quick-setup.md`
- `docs/architecture/overview.md`
- `scripts/install-deps.sh`
- `Makefile`

### 🛠️ Makefile Completo

**Comandos agregados:**
- `make dev-setup` - Configuración completa de desarrollo
- `make gitflow-setup` - Configuración de GitFlow
- `make status` - Estado de todos los componentes
- `make clean` - Limpieza del sistema
- `make verify-setup` - Verificación de configuración
- `make container-build` - Construcción de imágenes (Podman/Docker)
- `make docs-serve` - Servir documentación localmente

### 🔍 Scripts de Verificación

**Archivo agregado:**
- `scripts/verify-setup.sh` - Verificación completa de configuración

**Verificaciones incluidas:**
- Conectividad de red
- Herramientas principales (Rust, Cairo, Flutter, Podman)
- Servicios locales (PostgreSQL, Redis)
- Contenedores ejecutándose
- Entorno Python (Proof-of-Humanity)
- Archivos de configuración
- Permisos de scripts

---

## 🚀 Próximos Pasos

### Inmediatos
1. **Configurar GitFlow**: `make gitflow-setup`
2. **Verificar configuración**: `make verify-setup`
3. **Servir documentación**: `make docs-serve`

### Desarrollo
1. **Configurar entorno**: `make dev-setup`
2. **Iniciar componentes**: `make appchain-start`, `make backend-start`
3. **Ver estado**: `make status`

### Contribución
1. **Leer documentación**: https://keikolatam.github.io/dapp-monorepo
2. **Seguir GitFlow**: `docs/development/gitflow.md`
3. **Reportar issues**: GitHub Issues

---

## 📞 Soporte

- **📖 Documentación**: [docs/](docs/)
- **🐛 Issues**: [GitHub Issues](https://github.com/keikolatam/dapp-monorepo/issues)
- **💬 Discord**: [Discord](https://discord.gg/keikolatam)
- **📧 Email**: [dev@keikolatam.app](mailto:dev@keikolatam.app)

---

*Última actualización: 2024-09-22*
