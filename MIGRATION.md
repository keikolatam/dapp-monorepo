<!--
Business Source License 1.1

Licensed Work: keiko-dapp Version 0.0.1 or later.
The Licensed Work is (c) 2025 Luis Andrés Peña Castillo

For full license terms, see LICENSE file in the repository root.
-->

# Migración a Arquitectura Híbrida Keiko

## 📋 Resumen de Cambios

Keiko ha migrado de una arquitectura monolítica a una **arquitectura híbrida de 4 capas** que combina las ventajas de blockchain con la flexibilidad de microservicios.

### Estructura Anterior vs Nueva

```
ANTES (Monolítica):                    DESPUÉS (Híbrida):
backend/                               blockchain/          # Parachain Substrate
├── node/                              ├── node/
├── runtime/                           ├── runtime/
└── pallets/                           └── pallets/

middleware/                            services/            # Microservicios Rust + gRPC
├── api_gateway/                       ├── identity-service/
├── ai_tutor_service/                  ├── learning-service/
└── lrs_connector/                     ├── reputation-service/
                                       ├── passport-service/
                                       ├── governance-service/
                                       └── marketplace-service/

                                       api-gateway/         # GraphQL + REST
                                       ├── graphql_server/
                                       ├── rest_endpoints/
                                       └── admin_panel/

frontend/                              frontend/            # Flutter (sin cambios)
└── lib/                               └── lib/
```

## 🏗️ Arquitectura Híbrida Explicada

### 1. Blockchain Layer (Fuente de Verdad)

- **Propósito**: Inmutabilidad, consenso, verificabilidad
- **Tecnología**: Substrate Parachain + Polkadot
- **Datos**: Interacciones críticas, pasaportes, reputación, gobernanza

### 2. Service Layer (Cache + Lógica de Negocio)

- **Propósito**: Performance, queries complejas, agregaciones
- **Tecnología**: Rust + gRPC + PostgreSQL por servicio
- **Datos**: Cache local, vistas agregadas, datos temporales

### 3. API Layer (Orquestación)

- **Propósito**: API unificada, traducción GraphQL ↔ gRPC
- **Tecnología**: Axum + async-graphql + Redis Streams
- **Funciones**: Orquestación, cache, eventos tiempo real

### 4. Frontend Layer (Interfaz Usuario)

- **Propósito**: UI/UX multiplataforma
- **Tecnología**: Flutter + GraphQL client
- **Comunicación**: Solo GraphQL (queries, mutations, subscriptions)

## 🔄 Flujos de Datos Híbridos

### Escritura (Write Path)

```
Flutter → GraphQL Mutation → API Gateway → gRPC → Microservicio → Parachain → PostgreSQL Cache → Redis Event → GraphQL Subscription → Flutter
```

### Lectura (Read Path)

```
Flutter → GraphQL Query → API Gateway → gRPC → PostgreSQL Cache → (fallback) Parachain RPC → Flutter
```

### Eventos Tiempo Real

```
Parachain Event → Microservicio → Redis Streams → API Gateway → GraphQL Subscription → Flutter
```

## 🗄️ PostgreSQL por Microservicio - Propósito Específico

### ¿Por qué PostgreSQL en cada microservicio?

1. **Performance**: Queries rápidas sin consultar blockchain constantemente
2. **Agregaciones**: Cálculos complejos (reputación, estadísticas)
3. **Cache Inteligente**: Datos frecuentemente accedidos
4. **Vistas Optimizadas**: Joins y filtros imposibles en blockchain
5. **Datos Temporales**: Sesiones, propuestas en progreso

### Distribución por Servicio:

| Servicio                | PostgreSQL Contiene                | Puerto | Propósito                                |
| ----------------------- | ---------------------------------- | ------ | ---------------------------------------- |
| **identity-service**    | Usuarios, sesiones, perfiles       | 5432   | Cache de identidades, autenticación      |
| **learning-service**    | Interacciones xAPI, jerarquías     | 5433   | Cache optimizado para queries educativas |
| **reputation-service**  | Cálculos agregados, métricas       | 5434   | Reputación en tiempo real, tendencias    |
| **passport-service**    | Vistas agregadas de pasaportes     | 5435   | Dashboards, reportes, visualizaciones    |
| **governance-service**  | Propuestas, votaciones activas     | 5436   | Procesos democráticos en curso           |
| **marketplace-service** | Espacios, reservas, disponibilidad | 5437   | Calendario, búsquedas, recomendaciones   |

### Sincronización Blockchain ↔ PostgreSQL

```rust
// Ejemplo: Learning Service
async fn create_interaction(&self, interaction: Interaction) -> Result<()> {
    // 1. Escribir a parachain (fuente de verdad)
    let tx_hash = self.substrate_client
        .create_interaction(interaction.clone())
        .await?;

    // 2. Actualizar cache PostgreSQL local
    self.db.save_interaction(&interaction).await?;

    // 3. Publicar evento Redis (NO parachain)
    let event = DomainEvent::InteractionCreated {
        interaction,
        tx_hash
    };
    self.event_bus.publish(event).await?;

    Ok(())
}
```

## 🐳 Migración de Docker a Podman

### ¿Por qué Podman?

1. **Seguridad**: Rootless por defecto
2. **Compatibilidad**: Drop-in replacement para Docker
3. **Pods Nativos**: Mejor para microservicios
4. **Sin Daemon**: Menos overhead

### Comandos Equivalentes:

| Docker              | Podman              |
| ------------------- | ------------------- |
| `docker run`        | `podman run`        |
| `docker-compose up` | `podman-compose up` |
| `docker build`      | `podman build`      |
| `docker ps`         | `podman ps`         |

### Configuración de Desarrollo:

```bash
# Iniciar todos los servicios PostgreSQL + Redis
podman-compose -f infrastructure/podman-compose.yml up -d

# O usar pods nativos de Podman
podman play kube infrastructure/kubernetes/dev-services.yaml

# Verificar servicios
podman ps
```

## 🚀 Guía de Migración Paso a Paso

### 1. Preparar Entorno

```powershell
# Instalar Podman (Windows)
winget install RedHat.Podman

# Verificar instalación
podman --version
podman-compose --version

# Clonar y configurar
git clone https://github.com/keikolatam/keiko-dapp
cd keiko-dapp
Copy-Item .env.example .env
```

### 2. Iniciar Servicios de Desarrollo

```powershell
# Iniciar bases de datos y Redis
podman-compose -f infrastructure/podman-compose.yml up -d

# Verificar que todos los servicios estén healthy
podman-compose -f infrastructure/podman-compose.yml ps
```

### 3. Build y Test Blockchain Layer

```powershell
cd blockchain
cargo build --release
cargo test
```

### 4. Implementar Microservicios (Próximos Pasos)

```powershell
# Cada servicio tendrá su propia implementación
cd services/identity-service
cargo run  # Cuando esté implementado

cd ../learning-service
cargo run  # Cuando esté implementado
```

### 5. Configurar API Gateway

```powershell
cd api-gateway
cargo run --bin graphql_server  # Cuando esté actualizado
```

### 6. Ejecutar Frontend

```powershell
cd frontend
flutter pub get
flutter run -d web
```

## 🔧 Herramientas de Desarrollo

### Scripts Útiles:

```powershell
# Setup completo
.\scripts\dev-setup.ps1

# Solo verificar prerequisitos
.\scripts\dev-setup.ps1 -CheckOnly

# Build completo
.\scripts\dev-setup.ps1 -BuildAll
```

### Administración de Bases de Datos:

- **Adminer**: http://localhost:8080 (interfaz web)
- **psql directo**: `podman exec -it keiko-postgres-identity psql -U keiko_identity -d identity_service`

### Monitoreo:

- **Redis CLI**: `podman exec -it keiko-redis redis-cli`
- **Logs**: `podman-compose -f infrastructure/podman-compose.yml logs -f`

## 📊 Beneficios de la Nueva Arquitectura

### Performance

- ✅ Queries rápidas desde PostgreSQL cache
- ✅ Agregaciones complejas sin impacto en blockchain
- ✅ Eventos en tiempo real via Redis Streams

### Escalabilidad

- ✅ Microservicios independientes
- ✅ Scaling horizontal por servicio
- ✅ Base de datos dedicada por dominio

### Mantenibilidad

- ✅ Separación clara de responsabilidades
- ✅ Tecnología homogénea (Rust)
- ✅ APIs bien definidas (gRPC + GraphQL)

### Seguridad

- ✅ Blockchain como fuente de verdad inmutable
- ✅ Podman rootless
- ✅ Aislamiento por microservicio

## 🎯 Próximos Pasos

1. **Implementar microservicios** según tasks.md
2. **Actualizar API Gateway** para GraphQL + gRPC
3. **Migrar frontend** a cliente GraphQL puro
4. **Configurar CI/CD** con Podman
5. **Documentar APIs** con OpenAPI/GraphQL schema

---

Para más detalles técnicos, consultar:

- `.kiro/specs/01-keiko-dapp/tasks.md` - Plan de implementación
- `infrastructure/podman-compose.yml` - Configuración de servicios
- `.env.example` - Variables de entorno
