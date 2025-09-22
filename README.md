# Keiko Latam - Plataforma de Colaboración Educativa Descentralizada

Keiko es una plataforma de colaboración educativa descentralizada (DApp) que transforma el aprendizaje en capital humano verificable mediante blockchain.

Keiko permite a cualquier individuo construir y demostrar su **Pasaporte de Aprendizaje de Vida (LifeLearningPassport)** en blockchain,
mediante una sucesión de **interacciones de aprendizaje atómicas (LearningInteractions)** compatibles con el estándar [xAPI (Tin Can)](https://xapi.com/).

Estos datos pueden ser:
- generados en formato xAPI desde el propio **LRS** (Learning Record Store) de Keiko (una aplicación móvil desarrollada en Flutter/Dart)
- importados en formato SCORM al back-end desde otros LRS tales como Moodle, a través de su API gateway, y eventualmente convertidos a formato xAPI

Las interacciones de aprendizaje atómicas estarán diseñadas para ser registrados en la "Keikochain" (una appchain L3 basada en Starknet).
  
**Keiko Latam** - Transformando el aprendizaje en capital humano verificable e infalsificable 🎓✨

---

## Proósito, Objetivo, Principios pedagógicos y políticos

**El propósito de Keiko** es estandarizar el mecanismo de verificación de adquisición de los conocimientos a escala Latinoamérica,
sin importar el país de origen ni la condición socioeconómica de cada estudiante,
para poder dejar obsoletas las certificaciones tradicionales, y **priorizar el encadenamiento de las evidencias de aprenzidaje,**
_sobre la ***confianza ciega*** en actores educativos que emitan títulos o certificaciones físicas o digitales_,

**El objetivo principal de Keiko** es logar que sea imposible adulterar cualquier evidencia de los estudios de cualquier ser humano a través de su vida,
para ésto se requiere que las interacciones de aprendizaje sean
- almacenadas de forma descentralizada,
- públicamente verificables por múltiples actores (no solamente educativos sino de cualquier industria),
- inmutables e infalsificables.

Keiko se basa en cuatro pilares:

1. **Libertad económica de tutores y mentores**: Los educadores pueden escoger monetizar sesiones individuales o grupales sin intermediarios.
2. **Democracia participativa de los educandos**: Los aprendices califican la calidad del conocimiento adquirido y de sus pares.
3. **Descentralización de la gestión de calidad**: Las comunidades regulan sus propios estándares y métodos de validación.
4. **Auto-determinación de las comunidades**: Cada red o nodo puede establecer su propia gobernanza educativa.

## ¿Por qué "Keiko" (稽古)?

El nombre **Keiko** significa "practicar para adquirir conocimiento" y también "pensar y estudiar el pasado", un concepto que refleja la idea de digitalizar y conservar la historia del aprendizaje de cada persona en una cadena de bloques, garantizando la validez y trazabilidad de ese conocimiento. Más sobre este concepto en [Lexicon Keiko – Renshinjuku](http://www.renshinjuku.nl/2012/10/lexicon-keiko/).

Además, la organización que aloja este repositorio en GitHub se llama **Keiko (稽古)**, inspirada en la filosofía del [**Aikido**](https://aikido-argentina.com.ar/tag/keiko/), donde *Keiko* es la práctica disciplinada y consciente, que busca no solo la perfección técnica, sino el crecimiento personal y la armonía entre mente y cuerpo. Esta visión del aprendizaje constante y reflexivo es fundamental para el proyecto.

En suma, el nombre Keiko simboliza la importancia de practicar y reflexionar sobre el aprendizaje a lo largo del tiempo, lo cual se materializa en la plataforma como un pasaporte digital de vida y aprendizaje, descentralizado e infalsificable.

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
│                   Flutter App (Web/Mobile)                  │
└─────────────────────┬───────────────────────────────────────┘
                      │ GraphQL (Queries/Mutations/Subscriptions)
┌─────────────────────▼───────────────────────────────────────┐
│                     API Layer                               │
│           API Gateway (GraphQL + Redis Streams)             │
└─────────────────────┬───────────────────────────────────────┘
                      │ gRPC + Event-driven (Redis Streams)
┌─────────────────────▼───────────────────────────────────────┐
│                   Service Layer                             │
│    Microservicios (gRPC + PostgreSQL Cache + Events)        │
└─────────────────────┬───────────────────────────────────────┘
                      │ gRPC (Rust ↔ Rust)
┌─────────────────────▼───────────────────────────────────────┐
│                  gRPC Gateway Layer                         │
│         Traductor Rust ↔ Cairo (Starknet Appchain)          │
└─────────────────────┬───────────────────────────────────────┘
                      │ Starknet RPC + Transacciones
┌─────────────────────▼───────────────────────────────────────┐
│                  Appchain Layer                             │
│      Cairo Smart Contracts (Keikochain - Starknet Appchain) │
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

Para acelerar el desarrollo en local, puedes usar los siguientes scripts automatizados:

- **Appchain Quick Start (Starknet/Cairo)**: configura Keikochain local, compila y despliega contratos Cairo.

```bash
bash appchain/quick-start.sh
```

- **gRPC Gateway Quick Start**: inicializa y levanta el gateway gRPC.

```bash
bash grpc-gateway/quick-start.sh
```

- **Services Quick Start**: prepara dependencias (PostgreSQL, Redis) y levanta los microservicios base.

```bash
bash services/quick-start.sh
```

#### Parámetros y uso

- **Appchain (`appchain/quick-start.sh`)**
  - Uso básico:
    ```bash
    bash appchain/quick-start.sh --non-interactive
    ```
  - Flags disponibles:
    - `-f, --force-recreate`: Forzar recreación de la devnet existente
    - `-y, --yes, --non-interactive`: Ejecutar sin confirmaciones
    - `--use-existing`: Usar una devnet existente (falla si no hay)
    - `--provider <auto|podman|docker>`: Seleccionar proveedor (default: auto)
    - `--wait-blocks <n>`: Esperar n bloques (default: 55)
    - `--wait-minutes <m>`: Espera aproximada en minutos (default: 10)
    - `--no-deps-check`: Omitir verificación de dependencias
    - `-h, --help`: Mostrar ayuda
  - Ejemplos:
    ```bash
    # Auto, sin prompts
    bash appchain/quick-start.sh --non-interactive

    # Forzar Podman y recrear
    bash appchain/quick-start.sh --provider podman --force-recreate --non-interactive

    # Usar devnet existente
    bash appchain/quick-start.sh --use-existing
    ```

- **gRPC Gateway (`grpc-gateway/quick-start.sh`)**
  - Sin parámetros. Instala y configura asdf, Scarb y Starknet Foundry.

- **Services (`services/quick-start.sh`)**
  - Sin parámetros. Instala Rust, herramientas de microservicios y genera estructura base.

### Entorno PoH (ZK) - Python

Tras ejecutar `services/quick-start.sh`, se crea `.venv` con dependencias para biometría y Cairo.

```bash
# Activar el entorno virtual
source .venv/bin/activate

# Verificar dependencias clave
python - << 'EOF'
import Bio, cairo_lang
print('OK: BioPython y cairo-lang disponibles')
EOF

# Salir del entorno cuando termines
deactivate
```

### Ejemplos mínimos PoH (biometría + ZK)

```bash
# 1) Procesamiento simple de iris (OpenCV) y FASTA (BioPython)
source .venv/bin/activate
python - << 'EOF'
import cv2, numpy as np
from Bio import SeqIO

# Simular un iris como imagen en memoria y aplicar un filtro Gabor básico
img = np.random.randint(0, 255, (128,128), dtype=np.uint8)
ksize = 21
sigma = 5
theta = 0
lam = 10
gamma = 0.5
psi = 0
kernel = cv2.getGaborKernel((ksize, ksize), sigma, theta, lam, gamma, psi, ktype=cv2.CV_32F)
feat = cv2.filter2D(img, cv2.CV_32F, kernel)
print('Iris feature mean/std:', float(feat.mean()), float(feat.std()))

# Leer una secuencia FASTA simple desde string
from io import StringIO
fasta_data = ">seq\nACGTACGTACGT\n"
handle = StringIO(fasta_data)
records = list(SeqIO.parse(handle, 'fasta'))
print('FASTA length:', len(records[0].seq))
EOF

# 2) Comando Cairo (tooling) de validación rápida
python - << 'EOF'
import cairo_lang
print('Cairo tooling OK:', cairo_lang.__version__ if hasattr(cairo_lang, '__version__') else 'present')
EOF
deactivate
```

```bash
# 3) Cálculo de humanity_proof_key = sha256(iris_hash || genome_hash || salt)
source .venv/bin/activate
python - << 'EOF'
import hashlib, os, numpy as np

# Supongamos que ya tienes vectores/características extraídas del iris y del genoma.
# Aquí simulamos bytes de hash previos (p.ej., hash de features Gabor y hash de SNPs).
iris_hash = hashlib.sha256(os.urandom(32)).digest()
genome_hash = hashlib.sha256(os.urandom(32)).digest()

# Salt seguro aleatorio (almacénalo de forma segura, por usuario)
salt = os.urandom(16)

# Concatenación: iris_hash || genome_hash || salt
composite = iris_hash + genome_hash + salt

# humanity_proof_key
humanity_proof_key = hashlib.sha256(composite).hexdigest()
print('humanity_proof_key:', humanity_proof_key)
EOF
deactivate
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