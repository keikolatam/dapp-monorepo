# Keiko - Red Social Educativa Descentralizada

Keiko es una red social educativa descentralizada (DApp) que transforma el aprendizaje en capital humano verificable mediante blockchain. La plataforma permite crear un **Pasaporte de Aprendizaje de Vida** inmutable que registra todas las interacciones educativas usando el estándar xAPI.

## 🔐 Proof-of-Humanity con zkProofs

Keiko implementa un sistema único de **Proof-of-Humanity** que garantiza que cada interacción de aprendizaje proviene de una persona humana real, sin comprometer la privacidad de los datos biométricos:

### **Autenticación Biométrica Off-Chain**
- **Datos Biométricos**: Procesamiento de iris (Gabor filters) y genoma (SNPs en VCF/FASTA)
- **Composite Key**: `sha256(iris_hash || genoma_hash || salt)` generada off-chain
- **Privacidad**: Los datos biométricos originales nunca se almacenan en blockchain

### **Verificación con Pruebas STARK**
- **Pruebas de Conocimiento Cero**: STARKs para verificar humanidad sin exponer datos
- **Firma Única**: Cada interacción se firma con Ed25519 derivada de la humanity_proof_key
- **Recuperación de Identidad**: Los usuarios pueden recuperar su identidad de aprendizaje con la misma humanity_proof_key

### **Flujo de Proof-of-Humanity**
```
1. Usuario registra datos biométricos → humanity_proof_key única
2. Sistema genera prueba STARK que verifica conocimiento sin exponer datos
3. Usuario firma interacciones con Ed25519 derivada de humanity_proof_key
4. Keikochain verifica que cada interacción proviene de una persona humana real
5. Si usuario pierde cuenta, puede recuperar identidad con misma humanity_proof_key
```

### **Beneficios**
- **🛡️ Anti-Sybil**: Previene múltiples identidades de la misma persona
- **🔒 Privacidad**: Datos biométricos nunca se exponen en blockchain
- **🔄 Recuperación**: Permite recuperar identidad de aprendizaje sin perder historial
- **✅ Verificabilidad**: Cualquier tercero puede verificar la humanidad de las interacciones

## 🏗️ Arquitectura Híbrida

Keiko utiliza una arquitectura híbrida de 5 capas que combina las ventajas de blockchain con la flexibilidad de microservicios:

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
                      │ gRPC (Rust ↔ Rust)
┌─────────────────────▼───────────────────────────────────────┐
│                  gRPC Gateway Layer                         │
│         Traductor Rust ↔ Cairo (Starknet Appchain)        │
└─────────────────────┬───────────────────────────────────────┘
                      │ Starknet RPC + Transacciones
┌─────────────────────▼───────────────────────────────────────┐
│                  Appchain Layer                             │
│         Cairo Smart Contracts (Keikochain - Starknet Appchain) │
└─────────────────────────────────────────────────────────────┘
```

### Flujos de Datos

- **📝 Escritura**: Flutter → GraphQL → gRPC → Microservicio → gRPC Gateway → Keikochain Contract → Evento Redis → GraphQL Subscription
- **📖 Lectura**: Flutter → GraphQL → gRPC → Cache PostgreSQL → (fallback) gRPC Gateway → Keikochain Contract
- **⚡ Tiempo Real**: Keikochain Contract → gRPC Gateway → Microservicio → Redis Streams → API Gateway → GraphQL Subscription → Flutter
- **📥 Importación**: LRS Externos → REST Webhooks → API Gateway → gRPC → Learning Service → gRPC Gateway → Keikochain Contract

## 📁 Estructura del Proyecto

```
keiko/
├── appchain/                         # 🔗 Keikochain Layer (Starknet Appchain)
│   ├── contracts/                    # Contratos Cairo
│   │   ├── learning_interactions/    # xAPI statements
│   │   ├── life_learning_passport/   # Pasaportes de aprendizaje
│   │   ├── reputation_system/        # Sistema de reputación
│   │   ├── governance/               # Gobernanza comunitaria
│   │   └── marketplace/              # Espacios de aprendizaje
│   ├── tests/                        # Tests de contratos
│   └── config/                       # Configuración de Keikochain (Starknet Appchain)
├── grpc-gateway/                     # 🌉 gRPC Gateway Layer
│   ├── client/                       # Cliente Starknet RPC
│   ├── proto/                        # Definiciones gRPC
│   ├── server/                       # Servidor gRPC Gateway
│   ├── translator/                   # Traductor Rust ↔ Cairo
│   └── config/                       # Configuración del gateway para Keikochain
├── services/                         # 🔧 Service Layer
│   ├── identity_service/             # Autenticación y usuarios
│   ├── learning_service/             # Procesamiento xAPI
│   ├── reputation_service/           # Cálculo de reputación
│   ├── passport_service/             # Agregación de pasaportes
│   ├── governance_service/           # Herramientas de gobernanza
│   ├── marketplace_service/          # Gestión de espacios
│   └── ai_tutor_service/             # Tutores IA especializados
├── api-gateway/                      # 🌐 API Layer
│   ├── graphql_server/               # Servidor GraphQL principal
│   ├── rest_endpoints/               # Endpoints REST para LRS externos
│   └── admin_panel/                  # Panel admin Leptos
├── frontend/                         # 📱 Frontend Layer
│   └── lib/                          # Aplicación Flutter
├── shared/                           # 🔄 Componentes compartidos
│   ├── types/                        # Tipos compartidos
│   ├── proto/                        # Definiciones gRPC
│   └── utils/                        # Utilidades comunes
└── docs/                             # 📚 Documentación
```

## 🚀 Tecnologías Clave

### Keikochain Layer

- **Cairo** - Lenguaje de contratos inteligentes
- **Starknet** - Red L2 de Ethereum con CairoVM
- **Keikochain** - Appchain personalizada de Starknet implementada en Cairo
- **STARKs** - Pruebas de conocimiento cero nativas en Cairo para verificación de humanidad
- **Ed25519** - Firma criptográfica para interacciones de aprendizaje

### gRPC Gateway Layer

- **Rust** - Lenguaje principal para el gateway
- **gRPC (tonic)** - Comunicación con microservicios
- **Starknet RPC** - Comunicación con Keikochain
- **Cairo Translator** - Traductor de tipos Rust ↔ Cairo

### Service Layer

- **Rust** - Lenguaje principal para microservicios
- **gRPC (tonic)** - Comunicación inter-servicios
- **PostgreSQL** - Base de datos por servicio (schemas separados para recursos limitados)
- **Redis Streams** - Event-driven architecture
- **OpenCV** - Procesamiento de datos biométricos (iris con Gabor filters)
- **BioPython** - Análisis de datos genómicos (SNPs en VCF/FASTA)
- **cairo-lang** - Generación de pruebas STARK para verificación de humanidad

### API Layer

- **GraphQL (async-graphql)** - API unificada para frontend
- **REST APIs** - Endpoints para integración con LRS externos
- **SCORM Compatibility** - Importación de datos de Moodle y otros LRS
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

### 3. Microservicios ↔ gRPC Gateway

```rust
// Microservicio escribe via gRPC Gateway
async fn create_interaction(&self, interaction: Interaction) -> Result<()> {
    // 1. Escribir via gRPC Gateway (fuente de verdad)
    let tx_hash = self.grpc_gateway_client
        .create_interaction(interaction.clone())
        .await?;

    // 2. Actualizar cache local
    self.db.save_interaction(&interaction).await?;

    // 3. Publicar evento Redis (NO blockchain)
    let event = DomainEvent::InteractionCreated { interaction };
    self.event_bus.publish(event).await?;

    Ok(())
}
```

### 4. gRPC Gateway ↔ Keikochain Contracts

```rust
// gRPC Gateway traduce gRPC calls a Starknet RPC
impl LearningService for GrpcGateway {
    async fn create_interaction(&self, interaction: Interaction) -> Result<String> {
        // 1. Traducir tipos Rust → Cairo
        let cairo_data = self.translator.rust_to_cairo(interaction)?;
        
        // 2. Preparar calldata para Cairo contract
        let calldata = self.prepare_calldata(cairo_data)?;
        
        // 3. Enviar transacción a Keikochain
        let tx_hash = self.starknet_client
            .invoke_contract(
                self.learning_contract_address,
                "create_interaction",
                calldata
            )
            .await?;
            
        Ok(tx_hash)
    }
}
```

### 5. Eventos en Tiempo Real

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

### 6. Integración LRS Externos (REST + SCORM)

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

// Endpoints para diferentes LRS y SCORM
// POST /api/v1/webhooks/moodle
// POST /api/v1/webhooks/canvas
// POST /api/v1/webhooks/learning-locker
// POST /api/v1/import/scorm          # Importación SCORM
// POST /api/v1/import/moodle-scorm   # Importación específica Moodle SCORM
// GET  /api/v1/export/xapi/{user_id}
```

## 🎯 Características Principales

- **🔐 Proof-of-Humanity**: Verificación criptográfica de que cada interacción proviene de una persona humana real usando zkProofs
- **🎓 Pasaporte de Aprendizaje de Vida**: Registro inmutable de todas las experiencias educativas firmadas con proof-of-humanity
- **🤖 Tutores IA Adaptativos**: Personalización basada en estilos de aprendizaje
- **👥 Tutorías Humanas**: Marketplace de educadores con sistema de reputación
- **🏢 Espacios Seguros**: Marketplace de espacios físicos para tutorías presenciales
- **🗳️ Gobernanza Comunitaria**: Estándares educativos definidos democráticamente
- **📊 Evaluación Pedagógica**: Perfiles de aprendizaje personalizados
- **🔗 Interoperabilidad**: Importación automática desde LRS existentes via webhooks REST
- **📥 Importación xAPI**: Endpoints REST para Moodle, Canvas, Learning Locker y otros LRS
- **📦 Compatibilidad SCORM**: Importación de datos de Moodle y otros LRS con soporte SCORM
- **🔄 Recuperación de Identidad**: Los usuarios pueden recuperar su identidad de aprendizaje sin perder historial

## 🛠️ Desarrollo Local

### Prerrequisitos

- **Rust** (stable + nightly)
- **Cairo** (1.0+)
- **Keikochain** (Starknet appchain local)
- **Flutter** (3.0+)
- **Docker** y **Docker Compose**
- **PostgreSQL** (14+)
- **Redis** (7+)
- **OpenCV** (4.0+) - Para procesamiento de datos biométricos
- **Python** (3.8+) con **BioPython** - Para análisis genómico
- **FIDO2/WebAuthn** - Para autenticación inicial

### Configuración Rápida

```bash
# 1. Clonar repositorio
git clone https://github.com/keikolatam/keiko-dapp
cd keiko-dapp

# 2. Configurar Keikochain (Starknet appchain) local
starknet-devnet --host 0.0.0.0 --port 5050

# 3. Compilar y desplegar contratos Cairo
cd appchain/contracts
scarb build
starknet declare --contract target/dev/learning_interactions.sierra.json
starknet deploy --class-hash <class_hash>

# 4. Configurar gRPC Gateway
cd ../../grpc-gateway
cargo run --bin grpc_gateway_server

# 5. Configurar services layer
cd ../services
docker-compose up -d postgres redis
cargo run --bin identity_service &
cargo run --bin learning_service &
cargo run --bin reputation_service &

# 6. Configurar API Gateway
cd ../api-gateway
cargo run --bin graphql_server

# 7. Configurar frontend
cd ../frontend
flutter pub get
flutter run -d web
```

## 📋 Estado del Desarrollo

### 🔄 Reiniciando (Keikochain Layer - Starknet Appchain)

- [ ] Configuración Cairo/Starknet base
- [ ] Contrato Proof-of-Humanity (STARK verification)
- [ ] Contrato Learning Interactions (con firma Ed25519)
- [ ] Contrato Life Learning Passport
- [ ] Contrato Reputation System
- [ ] Contrato Governance
- [ ] Contrato Marketplace

### 🚧 En Desarrollo (gRPC Gateway Layer)

- [ ] Cliente Starknet RPC
- [ ] Traductor Rust ↔ Cairo
- [ ] Servidor gRPC Gateway
- [ ] Configuración de Keikochain (Starknet Appchain)

### 🚧 En Desarrollo (Service Layer)

- [ ] Identity Service (con FIDO2)
- [ ] Proof-of-Humanity Service (procesamiento biométrico + STARKs)
- [ ] Learning Service (híbrido con firma Ed25519)
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
- **Starknet**: [starknet.io](https://starknet.io/)
- **Cairo**: [cairo-lang.org](https://cairo-lang.org/)
- **xAPI**: [xapi.com](https://xapi.com/)

---

**Keiko Team** - Transformando el aprendizaje en capital humano verificable 🎓✨
