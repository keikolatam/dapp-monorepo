# Keiko - Red Social Educativa Descentralizada

Keiko es una red social educativa descentralizada (DApp) que transforma el aprendizaje en capital humano verificable mediante blockchain. La plataforma permite crear un **Pasaporte de Aprendizaje de Vida** inmutable que registra todas las interacciones educativas usando el estándar xAPI.

## 🏗️ Arquitectura Híbrida

Keiko utiliza una arquitectura híbrida de 4 capas que combina las ventajas de blockchain con la flexibilidad de microservicios:

```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend Layer                           │
│                   Flutter App (Web/Mobile)                 │
└─────────────────────┬───────────────────────────────────────┘
                      │ GraphQL (Queries/Mutations/Subscriptions)
┌─────────────────────▼───────────────────────────────────────┐
│                     API Layer                               │
│           API Gateway (GraphQL + Redis Streams)            │
└─────────────────────┬───────────────────────────────────────┘
                      │ gRPC + Event-driven (Redis Streams)
┌─────────────────────▼───────────────────────────────────────┐
│                   Service Layer                             │
│    Microservicios (gRPC + PostgreSQL Cache + Events)       │
└─────────────────────┬───────────────────────────────────────┘
                      │ Substrate RPC + Transacciones
┌─────────────────────▼───────────────────────────────────────┐
│                  Blockchain Layer                           │
│         Parachain Substrate (Fuente de Verdad)             │
└─────────────────────────────────────────────────────────────┘
```

### Flujos de Datos

- **📝 Escritura**: Flutter → GraphQL → gRPC → Microservicio → Parachain → Evento Redis → GraphQL Subscription
- **📖 Lectura**: Flutter → GraphQL → gRPC → Cache PostgreSQL → (fallback) Parachain RPC
- **⚡ Tiempo Real**: Parachain → Microservicio → Redis Streams → API Gateway → GraphQL Subscription → Flutter
- **📥 Importación**: LRS Externos → REST Webhooks → API Gateway → gRPC → Learning Service → Parachain

## 📁 Estructura del Proyecto

```
keiko/
├── blockchain/              # 🔗 Blockchain Layer
│   ├── node/               # Nodo Substrate
│   ├── runtime/            # Runtime de la parachain
│   └── pallets/            # Pallets personalizados
│       ├── learning_interactions/    # xAPI statements
│       ├── life_learning_passport/   # Pasaportes de aprendizaje
│       ├── reputation_system/        # Sistema de reputación
│       ├── governance/               # Gobernanza comunitaria
│       └── marketplace/              # Espacios de aprendizaje
├── services/               # 🔧 Service Layer
│   ├── identity_service/   # Autenticación y usuarios
│   ├── learning_service/   # Procesamiento xAPI
│   ├── reputation_service/ # Cálculo de reputación
│   ├── passport_service/   # Agregación de pasaportes
│   ├── governance_service/ # Herramientas de gobernanza
│   ├── marketplace_service/# Gestión de espacios
│   └── ai_tutor_service/   # Tutores IA especializados
├── api-gateway/            # 🌐 API Layer
│   ├── graphql_server/     # Servidor GraphQL principal
│   ├── rest_endpoints/     # Endpoints REST para LRS externos
│   └── admin_panel/        # Panel admin Leptos
├── frontend/               # 📱 Frontend Layer
│   └── lib/                # Aplicación Flutter
├── shared/                 # 🔄 Componentes compartidos
│   ├── types/              # Tipos compartidos
│   ├── proto/              # Definiciones gRPC
│   └── utils/              # Utilidades comunes
└── docs/                   # 📚 Documentación
```

## 🚀 Tecnologías Clave

### Blockchain Layer

- **Substrate** - Framework de blockchain
- **Polkadot** - Parachain en ecosistema Polkadot
- **FRAME** - Pallets personalizados

### Service Layer

- **Rust** - Lenguaje principal para microservicios
- **gRPC (tonic)** - Comunicación inter-servicios
- **PostgreSQL** - Base de datos por servicio
- **Redis Streams** - Event-driven architecture

### API Layer

- **GraphQL (async-graphql)** - API unificada para frontend
- **REST APIs** - Endpoints para integración con LRS externos
- **Axum** - Framework web para API Gateway
- **Leptos** - Panel administrativo SSR/CSR

### Frontend Layer

- **Flutter** - Aplicación multiplataforma
- **BLoC** - Gestión de estado reactivo
- **GraphQL (graphql_flutter)** - Cliente GraphQL

## � ─Patrones de Comunicación

### 1. Frontend ↔ API Gateway (GraphQL)

```dart
// Flutter usa SOLO GraphQL
final result = await client.query(
  QueryOptions(document: gql('''
    query GetUserPassport($userId: ID!) {
      user(id: $userId) {
        passport {
          interactions { id, timestamp, content }
          reputation { current, historical }
        }
      }
    }
  '''))
);
```

### 2. API Gateway ↔ Microservicios

```rust
// API Gateway traduce GraphQL → gRPC
async fn get_user_passport(ctx: &Context, user_id: String) -> Result<Passport> {
    // Llamadas gRPC paralelas
    let (passport_data, reputation_data) = tokio::join!(
        ctx.passport_client.get_passport(user_id.clone()),
        ctx.reputation_client.get_reputation(user_id)
    );

    // Orquestar respuesta
    Ok(Passport {
        data: passport_data?,
        reputation: reputation_data?,
    })
}
```

### 3. Microservicios ↔ Parachain

```rust
// Microservicio escribe a parachain y publica evento
async fn create_interaction(&self, interaction: Interaction) -> Result<()> {
    // 1. Escribir a parachain (fuente de verdad)
    let tx_hash = self.substrate_client
        .create_interaction(interaction.clone())
        .await?;

    // 2. Actualizar cache local
    self.db.save_interaction(&interaction).await?;

    // 3. Publicar evento Redis (NO parachain)
    let event = DomainEvent::InteractionCreated { interaction };
    self.event_bus.publish(event).await?;

    Ok(())
}
```

### 4. Eventos en Tiempo Real

```rust
// Redis Streams → GraphQL Subscriptions
impl Subscription {
    async fn interaction_updates(&self, user_id: String) -> impl Stream<Item = Interaction> {
        self.redis_client
            .subscribe("learning.interactions")
            .filter(move |event| event.user_id == user_id)
            .map(|event| event.interaction)
    }
}
```

### 5. Integración LRS Externos (REST)

```rust
// API Gateway expone endpoints REST para webhooks e importación
#[post("/api/v1/xapi/statements")]
async fn import_xapi_statements(
    Json(statements): Json<Vec<XAPIStatement>>,
    headers: HeaderMap,
) -> Result<Json<ImportResponse>> {
    // 1. Validar webhook signature
    validate_webhook_signature(&headers)?;

    // 2. Transformar xAPI → formato interno
    let interactions: Vec<Interaction> = statements
        .into_iter()
        .map(|stmt| transform_xapi_to_interaction(stmt))
        .collect::<Result<Vec<_>>>()?;

    // 3. Enviar a Learning Service via gRPC
    for interaction in interactions {
        learning_client.create_interaction(interaction).await?;
    }

    Ok(Json(ImportResponse { imported: interactions.len() }))
}

// Endpoints para diferentes LRS
// POST /api/v1/webhooks/moodle
// POST /api/v1/webhooks/canvas
// POST /api/v1/webhooks/learning-locker
// GET  /api/v1/export/xapi/{user_id}
```

## 🎯 Características Principales

- **🎓 Pasaporte de Aprendizaje de Vida**: Registro inmutable de todas las experiencias educativas
- **🤖 Tutores IA Adaptativos**: Personalización basada en estilos de aprendizaje
- **👥 Tutorías Humanas**: Marketplace de educadores con sistema de reputación
- **🏢 Espacios Seguros**: Marketplace de espacios físicos para tutorías presenciales
- **🗳️ Gobernanza Comunitaria**: Estándares educativos definidos democráticamente
- **📊 Evaluación Pedagógica**: Perfiles de aprendizaje personalizados
- **🔗 Interoperabilidad**: Importación automática desde LRS existentes via webhooks REST
- **📥 Importación xAPI**: Endpoints REST para Moodle, Canvas, Learning Locker y otros LRS

## 🛠️ Desarrollo Local

### Prerrequisitos

- **Rust** (stable + nightly)
- **Flutter** (3.0+)
- **Docker** y **Docker Compose**
- **PostgreSQL** (14+)
- **Redis** (7+)

### Configuración Rápida

```bash
# 1. Clonar repositorio
git clone https://github.com/keikolatam/keiko-dapp
cd keiko-dapp

# 2. Configurar blockchain layer
cd blockchain
cargo build --release
cargo test

# 3. Configurar services layer
cd ../services
docker-compose up -d postgres redis
cargo run --bin identity_service &
cargo run --bin learning_service &
cargo run --bin reputation_service &

# 4. Configurar API Gateway
cd ../api-gateway
cargo run --bin graphql_server

# 5. Configurar frontend
cd ../frontend
flutter pub get
flutter run -d web
```

## 📋 Estado del Desarrollo

### ✅ Completado (Blockchain Layer)

- [x] Parachain Substrate base
- [x] Pallet Learning Interactions
- [x] Pallet Life Learning Passport
- [x] Pallet Reputation System

### 🚧 En Desarrollo (Service Layer)

- [ ] Identity Service
- [ ] Learning Service (híbrido)
- [ ] Reputation Service (híbrido)
- [ ] Passport Service (híbrido)

### 📋 Pendiente (API + Frontend)

- [ ] API Gateway GraphQL
- [ ] Panel Admin Leptos
- [ ] Aplicación Flutter
- [ ] Integración LRS

## 🤝 Contribuir

1. **Fork** el repositorio
2. **Crear** branch para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. **Commit** tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. **Push** al branch (`git push origin feature/nueva-funcionalidad`)
5. **Crear** Pull Request

## 📄 Licencia

Este proyecto está licenciado bajo Business Source License 1.1. Ver [LICENSE](LICENSE) para más detalles.

## 🔗 Enlaces

- **Homepage**: [http://keiko-dapp.xyz/](http://keiko-dapp.xyz/)
- **Documentación**: [docs/](docs/)
- **Especificaciones**: [.kiro/specs/](.kiro/specs/)
- **Polkadot**: [polkadot.network](https://polkadot.network/)
- **xAPI**: [xapi.com](https://xapi.com/)

---

**Keiko Team** - Transformando el aprendizaje en capital humano verificable 🎓✨
