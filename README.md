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

## Propósito, Objetivo, Principios pedagógicos y políticos

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

## 🏗️ Arquitectura Híbrida

Keiko utiliza una arquitectura híbrida de 5 capas que combina las ventajas de blockchain con la simplicidad de una aplicación monolítica modular:

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
│                   Backend Layer                             │
│  Aplicación Monolítica Modular (Rust + PostgreSQL + Redis)  │
└─────────────────────┬───────────────────────────────────────┘
                      │ HTTP/REST (API Gateway ↔ Backend)
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

- **📝 Escritura**: Flutter → GraphQL → HTTP/REST → Backend → gRPC Gateway → Keikochain Contract → Evento Redis → GraphQL Subscription
- **📖 Lectura**: Flutter → GraphQL → HTTP/REST → Backend → Cache PostgreSQL → (fallback) gRPC Gateway → Keikochain Contract
- **⚡ Tiempo Real**: Keikochain Contract → gRPC Gateway → Backend → Redis Streams → API Gateway → GraphQL Subscription → Flutter
- **📥 Importación**: LRS Externos → REST Webhooks → API Gateway → HTTP/REST → Backend → gRPC Gateway → Keikochain Contract

## 📁 Estructura del Proyecto

```
keiko/
├── appchain/                         # Keikochain Layer (Starknet Appchain)
│   ├── contracts/                    # Contratos Cairo
│   │   ├── learning_interactions/    # xAPI statements
│   │   ├── life_learning_passport/   # Pasaportes de aprendizaje
│   │   ├── reputation_system/        # Sistema de reputación
│   │   ├── governance/               # Gobernanza comunitaria
│   │   └── marketplace/              # Espacios de aprendizaje
│   ├── tests/                        # Tests de contratos
│   └── config/                       # Configuración de Keikochain (Starknet Appchain)
├── grpc-gateway/                     # gRPC Gateway Layer
│   ├── client/                       # Cliente Starknet RPC
│   ├── proto/                        # Definiciones gRPC
│   ├── server/                       # Servidor gRPC Gateway
│   ├── translator/                   # Traductor Rust ↔ Cairo
│   └── config/                       # Configuración del gateway para Keikochain
├── backend/                          # Backend Layer (Monolítico Modular)
│   ├── modules/                      # Módulos organizados por dominio
│   │   ├── identity/                 # Autenticación y usuarios
│   │   ├── learning/                 # Procesamiento xAPI
│   │   ├── reputation/               # Cálculo de reputación
│   │   ├── passport/                 # Agregación de pasaportes
│   │   ├── governance/               # Herramientas de gobernanza
│   │   ├── marketplace/              # Gestión de espacios
│   │   └── selfstudy_guides/         # Guías de auto-estudio evaluadas por agente IA
│   ├── shared/                       # Componentes compartidos del backend
│   └── main.rs                       # Punto de entrada monolítico
├── api-gateway/                      # API Layer
│   ├── graphql_server/               # Servidor GraphQL principal
│   ├── rest_endpoints/               # Endpoints REST para LRS externos
│   └── admin_panel/                  # Panel admin Leptos
├── frontend/                         # Frontend Layer
│   └── lib/                          # Aplicación Flutter
├── shared/                           # Componentes compartidos
│   ├── types/                        # Tipos compartidos
│   ├── proto/                        # Definiciones gRPC
│   └── utils/                        # Utilidades comunes
└── docs/                             # Documentación
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
- **gRPC (tonic)** - Comunicación con backend monolítico
- **Starknet RPC** - Comunicación con Keikochain
- **Cairo Translator** - Traductor de tipos Rust ↔ Cairo

### Backend Layer (Monolítico Modular)

- **Rust** - Lenguaje principal para la aplicación monolítica
- **HTTP/REST** - Comunicación con API Gateway
- **PostgreSQL** - Base de datos única con schemas separados por módulo
- **Redis Streams** - Event-driven architecture entre módulos
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

## 🏛️ Arquitectura Modular del Backend

El backend de Keiko está diseñado como una **aplicación monolítica modular** que combina las ventajas de una arquitectura simple con la organización por dominios de negocio:

### **Ventajas de la Arquitectura Modular**

- **🚀 Desarrollo Rápido**: Una sola aplicación Rust es más fácil de desarrollar y debuggear que múltiples microservicios
- **🔧 Debugging Simplificado**: Stack traces completos y debugging local sin red
- **📦 Deployment Único**: Un solo binario para desplegar, sin coordinación entre servicios
- **💰 Recursos Limitados**: Una sola base de datos PostgreSQL con schemas separados por módulo
- **🔄 Comunicación Directa**: Llamadas de función directas entre módulos, sin latencia de red

### **Organización por Módulos**

Cada módulo representa un **bounded context** del dominio educativo:

```
backend/modules/
├── identity/           # Autenticación, usuarios, Proof-of-Humanity
├── learning/           # xAPI statements, interacciones atómicas
├── reputation/         # Sistema de calificaciones y reputación
├── passport/           # Agregación de pasaportes de aprendizaje
├── governance/         # Gobernanza comunitaria y estándares
├── marketplace/        # Tutores, espacios, transacciones
└── auto_study/        # Guías de auto-estudio adaptativas
```

### **Comunicación Entre Módulos**

- **Llamadas Directas**: Los módulos se comunican via llamadas de función directas
- **Eventos Redis**: Para desacoplamiento y notificaciones asíncronas
- **Base de Datos Compartida**: PostgreSQL con schemas separados por módulo
- **gRPC Gateway**: Solo para comunicación con Keikochain (no entre módulos)

### **Escalabilidad Futura**

La arquitectura está diseñada para permitir la **extracción gradual a microservicios** cuando sea necesario:
- Interfaces bien definidas entre módulos
- Separación clara de responsabilidades
- Event-driven architecture preparada
- Schemas de base de datos independientes

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

### 2. API Gateway ↔ Backend

```rust
// API Gateway traduce GraphQL → HTTP/REST
async fn get_user_passport(ctx: &Context, user_id: String) -> Result<Passport> {
    // Llamadas HTTP paralelas al backend monolítico
    let (passport_data, reputation_data) = tokio::join!(
        ctx.http_client.get(&format!("/api/passport/{}", user_id)),
        ctx.http_client.get(&format!("/api/reputation/{}", user_id))
    );

    // Orquestar respuesta
    Ok(Passport {
        data: passport_data?.json().await?,
        reputation: reputation_data?.json().await?,
    })
}
```

### 3. Backend ↔ gRPC Gateway

```rust
// Backend monolítico escribe via gRPC Gateway
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

    // 3. Enviar a Backend via HTTP/REST
    for interaction in interactions {
        http_client.post("/api/learning/interactions")
            .json(&interaction)
            .send()
            .await?;
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
bash scripts/appchain-quick-start.sh
```

- **gRPC Gateway Quick Start**: inicializa y levanta el gateway gRPC.

```bash
bash scripts/grpc-gateway-quick-start.sh
```

- **Backend Quick Start**: prepara dependencias (PostgreSQL, Redis) y levanta el backend monolítico modular.

```bash
bash scripts/backend-quick-start.sh
```

#### Parámetros y uso

- **Appchain (`scripts/appchain-quick-start.sh`)**
  - Uso básico:
    ```bash
    bash scripts/appchain-quick-start.sh --non-interactive
    ```
  - Flags disponibles:
    - `-f, --force-recreate`: Forzar recreación de la devnet existente
    - `-y, --yes, --non-interactive`: Ejecutar sin confirmaciones
    - `--use-existing`: Usar una devnet existente (falla si no hay)
    - `--provider <auto|podman|docker>`: Seleccionar proveedor (default: auto, preferido: podman)
    - `--wait-blocks <n>`: Esperar n bloques (default: 55)
    - `--wait-minutes <m>`: Espera aproximada en minutos (default: 10)
    - `--no-deps-check`: Omitir verificación de dependencias
    - `-h, --help`: Mostrar ayuda
  - Ejemplos:
    ```bash
    # Auto, sin prompts (usa Podman por defecto)
    bash scripts/appchain-quick-start.sh --non-interactive

    # Forzar Podman y recrear
    bash scripts/appchain-quick-start.sh --provider podman --force-recreate --non-interactive

    # Usar devnet existente
    bash scripts/appchain-quick-start.sh --use-existing
    ```

- **gRPC Gateway (`scripts/grpc-gateway-quick-start.sh`)**
  - Sin parámetros. Instala y configura asdf, Scarb y Starknet Foundry.

- **Backend (`scripts/backend-quick-start.sh`)**
  - Sin parámetros. Instala Rust, herramientas del backend monolítico modular y genera estructura base.

### Entorno PoH (ZK) - Python

Tras ejecutar `scripts/backend-quick-start.sh`, se crea `.venv` con dependencias para biometría y Cairo.

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

## 🚀 Estrategia de Despliegue en OVHCloud Kubernetes

Keiko implementa una estrategia de despliegue en 4 fases evolutivas diseñada para aprovechar al máximo las capacidades de OVHCloud Managed Kubernetes:

### **📋 Fase 1: Backend Monolítico con PostgreSQL Managed**
- **Infraestructura base** con PostgreSQL y Redis Managed de OVHCloud
- **Escalado manual** con replicas fijas (2 backend, 2 api-gateway, 1 grpc-gateway)
- **Monitoreo básico** con logs nativos de Kubernetes
- **CI/CD básico** con GitHub Actions

### **📊 Fase 2: Observabilidad Completa**
- **Prometheus** para métricas con almacenamiento persistente (50Gi)
- **Grafana** para dashboards y visualización (10Gi)
- **Jaeger** para distributed tracing (100Gi)
- **OpenTelemetry Collector** como DaemonSet
- **Métricas granulares** por cada módulo del backend

### **🔄 Fase 3: GitOps con ArgoCD**
- **ArgoCD** para GitOps automation con 2 replicas
- **Pipeline CI/CD completo** con múltiples stages
- **Multi-environment** (staging/production)
- **Security scanning** y rollback automático

### **⚡ Fase 4: Autoscaling Avanzado**

#### **Horizontal Pod Autoscaler (HPA):**
- **Métricas múltiples**: CPU (70%), memoria (80%), y métricas custom de negocio
- **Escalado inteligente**: Backend (2-20 pods), API Gateway (2-15 pods)
- **Métricas específicas**: 
  - `learning_interactions_per_second` (target: 100)
  - `graphql_requests_per_second` (target: 200)
  - `websocket_connections` (target: 1000)
  - `redis_stream_queue_length` (target: 50)

#### **Vertical Pod Autoscaler (VPA):**
- **Optimización automática** de requests y limits
- **Rangos definidos**: Backend (200m-2000m CPU, 512Mi-4Gi RAM)
- **Update mode "Auto"** para optimización continua

#### **Cluster Autoscaler:**
- **Escalado de nodos** automático en OVHCloud (3-20 nodos)
- **Machine types variados**: b2-15, b2-30, c2-30
- **Node groups prioritarios**: applications (priority 10), system (priority 5)

### **📈 Métricas de Éxito:**
- **Disponibilidad**: 99.9% SLA compliance
- **Escalado**: <2 minutos response time de scaling
- **Eficiencia**: >70% resource utilization promedio
- **Costos**: 20% reducción vs configuración manual

### **🔧 Configuraciones Avanzadas:**
- **Pod Affinity**: Distribución inteligente de pods para alta disponibilidad
- **Multi-environment**: DEV, QA, STAGE, PROD con promotion automática
- **Gestión de Secretos**: OVHCloud Secret Manager + External Secrets Operator
- **Alertas inteligentes**: Sistema completo de alertas para problemas de autoscaling
- **Scripts automatizados**: Implementación por fases con scripts bash

### **🔐 Gestión de Secretos con OVHCloud Secret Manager**

Keiko implementa una estrategia híbrida de gestión de secretos que combina OVHCloud Secret Manager con External Secrets Operator:

#### **🎯 Estrategia Recomendada: OVHCloud Secret Manager**
- **Integración Nativa**: Perfecta integración con el ecosistema OVHCloud
- **Costo-Efectivo**: Actualmente en fase Alpha (gratuito) y será más económico que Vault
- **Servicio Gestionado**: Sin overhead operacional de mantener Vault
- **Compliance**: Integrado con IAM de OVHCloud y auditoría completa
- **Región**: Disponible en `eu-west-par` (perfecto para GDPR)

#### **🔧 Implementación Técnica**
- **External Secrets Operator**: Sincronización automática con Kubernetes Secrets
- **Rotación transparente**: Sin downtime durante la rotación de credenciales
- **Fallback automático**: En caso de fallos del Secret Manager
- **Monitoring integrado**: Con Prometheus para observabilidad completa

#### **📊 Secretos Específicos para Keiko**
- **Base de datos**: Credenciales PostgreSQL por entorno
- **JWT Secrets**: Claves para autenticación y autorización
- **Redis**: Credenciales para Redis Streams
- **gRPC Gateway**: Certificados TLS para comunicación segura
- **Proof-of-Humanity**: Salt y claves para verificación biométrica

Ver detalles completos en [design.md](.kiro/specs/01-keiko-dapp/design.md#estrategia-de-despliegue-en-ovhcloud-kubernetes)

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

### 🚧 En Desarrollo (Backend Layer)

- [ ] Módulo de Identidad (con FIDO2)
- [ ] Módulo Proof-of-Humanity (procesamiento biométrico + STARKs)
- [ ] Módulo de Aprendizaje (híbrido con firma Ed25519)
- [ ] Módulo de Reputación (híbrido)
- [ ] Módulo de Pasaporte (híbrido)
- [ ] Módulo de Gobernanza
- [ ] Módulo de Marketplace
- [ ] Módulo de Guías de Autoestudio

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