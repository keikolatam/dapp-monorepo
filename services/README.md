# 🦀 Services Layer - Keiko DApp

El Services Layer contiene todos los microservicios Rust que implementan la lógica de negocio de la Keiko DApp. Cada microservicio es independiente, auto-contenido y se comunica con otros servicios a través de gRPC y Redis Streams.

## 🎯 Arquitectura de Microservicios

La arquitectura sigue los principios de **Twelve-Factor App** y **Microservices Design Patterns**:

- **Self-Contained**: Cada servicio tiene su propia base de datos y dependencias
- **Database per Service**: Cada microservicio gestiona su propio estado
- **Event-Driven**: Comunicación asíncrona a través de Redis Streams
- **Circuit Breaker**: Patrones de resiliencia para comunicación entre servicios
- **CQRS**: Separación de comandos y consultas
- **Saga**: Transacciones distribuidas para operaciones complejas

## 🏗️ Microservicios

### 1. **Identity Service** (`identity-service/`)
- **Responsabilidad**: Gestión de identidad y autenticación
- **Tecnologías**: FIDO2, JWT, Proof-of-Humanity con zkProofs
- **Base de Datos**: PostgreSQL para cache local
- **Funcionalidades**:
  - Registro con Proof-of-Humanity (iris, genome)
  - Autenticación FIDO2/WebAuthn
  - Generación de `humanity_proof_key`
  - Verificación de Ed25519 signatures
  - Gestión de sesiones JWT

### 2. **Learning Service** (`learning-service/`)
- **Responsabilidad**: Gestión del aprendizaje y interacciones educativas
- **Tecnologías**: xAPI (Tin Can), SCORM, Cairo smart contracts
- **Base de Datos**: PostgreSQL para cache local
- **Funcionalidades**:
  - Procesamiento de interacciones de aprendizaje
  - Integración con SCORM
  - Generación de xAPI statements
  - Firma de interacciones con Ed25519
  - Sincronización con Keikochain

### 3. **Reputation Service** (`reputation-service/`)
- **Responsabilidad**: Sistema de reputación y gamificación
- **Tecnologías**: Algoritmos de reputación, Cairo smart contracts
- **Base de Datos**: PostgreSQL para cache local
- **Funcionalidades**:
  - Cálculo de reputación basado en aprendizaje
  - Sistema de badges y achievements
  - Gamificación y leaderboards
  - Verificación de reputación en Keikochain

### 4. **Passport Service** (`passport-service/`)
- **Responsabilidad**: Life Learning Passport (LLP)
- **Tecnologías**: Cairo smart contracts, IPFS
- **Base de Datos**: PostgreSQL para cache local
- **Funcionalidades**:
  - Generación y gestión de LLP
  - Almacenamiento de credenciales en IPFS
  - Verificación de credenciales
  - Exportación de LLP

### 5. **Governance Service** (`governance-service/`)
- **Responsabilidad**: Gobernanza descentralizada
- **Tecnologías**: Cairo smart contracts, voting mechanisms
- **Base de Datos**: PostgreSQL para cache local
- **Funcionalidades**:
  - Procesos de votación
  - Gestión de propuestas
  - Delegación de votos
  - Resultados de gobernanza

### 6. **Marketplace Service** (`marketplace-service/`)
- **Responsabilidad**: Mercado de credenciales y servicios
- **Tecnologías**: Cairo smart contracts, payment systems
- **Base de Datos**: PostgreSQL para cache local
- **Funcionalidades**:
  - Marketplace de credenciales
  - Sistema de pagos
  - Gestión de transacciones
  - Verificación de credenciales

### 7. **AI Tutor Service** (`ai-tutor-service/`)
- **Responsabilidad**: Tutoría inteligente y recomendaciones
- **Tecnologías**: Machine Learning, AI models
- **Base de Datos**: PostgreSQL para cache local
- **Funcionalidades**:
  - Recomendaciones personalizadas
  - Tutoría adaptativa
  - Análisis de progreso
  - Generación de contenido

## 📁 Estructura del Proyecto

```
services/
├── identity-service/           # Microservicio de identidad
│   ├── src/
│   │   ├── main.rs
│   │   ├── lib.rs
│   │   ├── auth/               # Módulo de autenticación
│   │   ├── biometric/          # Procesamiento biométrico
│   │   ├── grpc/               # Servicios gRPC
│   │   └── database/           # Acceso a base de datos
│   ├── proto/                  # Definiciones Protocol Buffers
│   ├── migrations/             # Migraciones de base de datos
│   ├── tests/                  # Tests del servicio
│   └── Cargo.toml
├── learning-service/           # Microservicio de aprendizaje
├── reputation-service/         # Microservicio de reputación
├── passport-service/           # Microservicio de LLP
├── governance-service/         # Microservicio de gobernanza
├── marketplace-service/        # Microservicio de marketplace
├── ai-tutor-service/           # Microservicio de AI tutor
├── shared/                     # Componentes compartidos
│   ├── auth/                   # Autenticación compartida
│   ├── config/                 # Configuración compartida
│   ├── database/               # Acceso a base de datos
│   ├── grpc/                   # Clientes gRPC
│   ├── logging/                # Logging centralizado
│   ├── metrics/                # Métricas y observabilidad
│   └── utils/                  # Utilidades comunes
├── Cargo.toml                  # Workspace principal
├── quick-start.sh              # Script de configuración
└── README.md                   # Este archivo
```

## 🚀 Configuración Rápida

### Prerrequisitos

Asegúrate de tener instalados:
- **Git** para control de versiones
- **Docker** (opcional, para bases de datos locales)
- **PostgreSQL** (para desarrollo local)
- **Redis** (para Redis Streams)

### Instalación Automática

Para configurar todo el entorno de desarrollo automáticamente:

```bash
cd services
./quick-start.sh
```

Este script instalará:
- ✅ **Rust** (última versión estable)
- ✅ **Cargo** y herramientas de desarrollo
- ✅ **Herramientas adicionales** (clippy, rustfmt, etc.)
- ✅ **Dependencias del sistema** (protoc, PostgreSQL, Redis)
- ✅ **Estructura del proyecto** completa
- ✅ **Configuración de desarrollo** optimizada

### Instalación Manual

Si prefieres instalar manualmente:

1. **Instalar Rust**:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   source ~/.cargo/env
   ```

2. **Instalar herramientas de desarrollo**:
   ```bash
   rustup component add rustfmt clippy rust-src
   cargo install cargo-watch cargo-expand cargo-audit
   ```

3. **Instalar dependencias del sistema**:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install protobuf-compiler postgresql-client libpq-dev redis-tools
   
   # macOS
   brew install protobuf postgresql redis
   ```

## 🛠️ Desarrollo

### Estructura de un Microservicio

Cada microservicio sigue esta estructura:

```rust
// src/main.rs
use tonic::transport::Server;
use identity_service::IdentityService;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Configurar logging
    tracing_subscriber::fmt::init();
    
    // Inicializar servicio
    let identity_service = IdentityService::new().await?;
    
    // Configurar servidor gRPC
    let addr = "[::1]:50051".parse()?;
    Server::builder()
        .add_service(identity_service.into_service())
        .serve(addr)
        .await?;
    
    Ok(())
}
```

### Comandos Útiles

```bash
# Compilar todos los servicios
cargo build

# Ejecutar tests
cargo test

# Desarrollo con hot-reload
cargo watch -x run

# Análisis de código
cargo clippy

# Formatear código
cargo fmt

# Auditoría de seguridad
cargo audit

# Cobertura de código
cargo tarpaulin

# Testing avanzado
cargo nextest run
```

### Configuración de Base de Datos

Cada microservicio tiene su propia base de datos PostgreSQL:

```bash
# Crear base de datos para un servicio
createdb identity_service_db

# Ejecutar migraciones
cd identity-service
sqlx migrate run
```

### Configuración de Redis

Para Redis Streams (comunicación entre servicios):

```bash
# Iniciar Redis
redis-server

# Verificar conexión
redis-cli ping
```

## 🔧 Tecnologías Clave

### **Rust Ecosystem**
- **Tokio**: Runtime asíncrono
- **Tonic**: Framework gRPC
- **SQLx**: ORM para PostgreSQL
- **Redis**: Cliente Redis para Streams
- **Serde**: Serialización/deserialización

### **Autenticación y Seguridad**
- **FIDO2/WebAuthn**: Autenticación biométrica
- **JWT**: Tokens de sesión
- **Ed25519**: Firmas criptográficas
- **Argon2**: Hashing de contraseñas
- **Proof-of-Humanity**: Verificación con zkProofs

### **Observabilidad**
- **Tracing**: Logging estructurado
- **Prometheus**: Métricas
- **OpenTelemetry**: Trazabilidad distribuida
- **Jaeger**: Visualización de traces

### **Resiliencia**
- **Circuit Breaker**: Patrón de resiliencia
- **Retry Policies**: Reintentos con backoff
- **Health Checks**: Monitoreo de salud
- **Graceful Shutdown**: Cierre ordenado

## 📊 Monitoreo y Observabilidad

### Métricas
- **Prometheus**: Métricas de aplicación
- **Grafana**: Dashboards de monitoreo
- **AlertManager**: Alertas automáticas

### Logging
- **Structured Logging**: Logs en formato JSON
- **ELK Stack**: Elasticsearch, Logstash, Kibana
- **Correlation IDs**: Trazabilidad de requests

### Tracing
- **OpenTelemetry**: Instrumentación automática
- **Jaeger**: Visualización de traces distribuidos
- **Span Context**: Propagación de contexto

## 🧪 Testing

### Estrategia de Testing
- **Unit Tests**: Tests unitarios para cada módulo
- **Integration Tests**: Tests de integración con bases de datos
- **Contract Tests**: Tests de contratos gRPC
- **End-to-End Tests**: Tests de flujos completos

### Herramientas de Testing
- **cargo test**: Testing básico
- **cargo nextest**: Testing avanzado y paralelo
- **cargo tarpaulin**: Cobertura de código
- **mockall**: Mocking para tests

## 🚀 Despliegue

### Contenedores
- **Docker**: Contenedores para cada microservicio
- **Docker Compose**: Orquestación local
- **Kubernetes**: Orquestación en producción

### CI/CD
- **GitHub Actions**: Pipeline de CI/CD
- **Automated Testing**: Tests automáticos en PRs
- **Security Scanning**: Escaneo de vulnerabilidades
- **Performance Testing**: Tests de rendimiento

## 📚 Documentación Adicional

- [Documento de Diseño de Keiko DApp](../../.kiro/specs/01-keiko-dapp/design.md)
- [Principios de Arquitectura de Microservicios](../../.kiro/steering/microservices-arquitecture-principles.md)
- [Documentación de Rust](https://doc.rust-lang.org/)
- [Documentación de Tokio](https://tokio.rs/)
- [Documentación de Tonic](https://github.com/hyperium/tonic)
- [Documentación de SQLx](https://github.com/launchbadge/sqlx)

## 🤝 Contribución

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo [LICENSE](../../LICENSE) para más detalles.
