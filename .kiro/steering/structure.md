# Estructura del Proyecto

## Organización del Monorepo

Keiko utiliza una estructura de monorepo con clara separación de responsabilidades a través de tres dominios principales:

```
keiko/
├── backend/           # Parachain de Substrate (Rust)
├── frontend/          # Aplicación Flutter (Dart)
├── middleware/        # Servicios Node.js (TypeScript)
├── shared/            # Utilidades y tipos compartidos
├── .specs/            # Especificaciones y requerimientos del proyecto
└── .kiro/             # Configuración y steering de Kiro IDE
```

## Estructura del Backend (Substrate)

**Ubicación**: `backend/`
**Lenguaje**: Rust
**Build**: Cargo workspace

```
backend/
├── Cargo.toml         # Configuración del workspace
├── node/              # Implementación del nodo blockchain
├── runtime/           # Lógica del runtime de la parachain
├── pallets/           # Pallets FRAME personalizados
│   ├── learning_interactions/    # Datos centrales de aprendizaje
│   ├── life_learning_passport/   # Perfiles de aprendizaje de usuarios
│   ├── reputation_system/        # Reputación de tutores/estudiantes
│   ├── governance/               # Gobernanza educativa comunitaria
│   └── marketplace/              # Marketplace de espacios seguros
└── scripts/           # Scripts de despliegue y utilidades
```

**Convenciones Clave**:

- Cada pallet sigue los estándares FRAME
- Usar macros `#[pallet::*]` para la estructura del pallet
- Implementar pesos apropiados para extrinsics
- Seguir convenciones de nomenclatura de Substrate (snake_case)

## Estructura del Frontend (Flutter)

**Ubicación**: `frontend/`
**Lenguaje**: Dart
**Arquitectura**: Clean Architecture + BLoC

```
frontend/lib/
├── main.dart          # Punto de entrada de la aplicación
├── core/              # Núcleo compartido de la aplicación
│   ├── constants/     # Constantes de toda la app
│   ├── errors/        # Manejo de errores
│   ├── network/       # Clientes HTTP y blockchain
│   ├── usecases/      # Clases base de casos de uso
│   └── utils/         # Funciones de utilidad
└── features/          # Organización basada en características
    ├── passport/      # Pasaporte de Aprendizaje de Vida
    ├── tutoring/      # Sistema de tutorías
    ├── reputation/    # Gestión de reputación
    ├── governance/    # Gobernanza educativa
    ├── marketplace/   # Marketplace de espacios seguros
    ├── assessment/    # Evaluación pedagógica inicial
    ├── adaptive_plans/ # Planes adaptativos de aprendizaje
    └── wallet/        # Billetera Keikoin
```

**Estructura de Características** (cada característica sigue este patrón):

```
feature/
├── domain/            # Capa de lógica de negocio
│   ├── entities/      # Objetos centrales de negocio
│   ├── repositories/  # Contratos abstractos de datos
│   └── usecases/      # Casos de uso de negocio
├── data/              # Capa de acceso a datos
│   ├── models/        # Objetos de transferencia de datos
│   ├── datasources/   # Fuentes de datos remotas/locales
│   └── repositories/  # Implementaciones de repositorios
└── presentation/      # Capa de UI
    ├── bloc/          # Gestión de estado
    ├── pages/         # Widgets de pantalla
    └── widgets/       # Componentes UI reutilizables
```

**Convenciones Clave**:

- Usar patrón BLoC para gestión de estado
- Seguir principios de Clean Architecture
- Implementar manejo apropiado de errores con `Either<Failure, Success>`
- Usar inyección de dependencias con `get_it`

## Estructura del Middleware (Node.js)

**Ubicación**: `middleware/`
**Lenguaje**: TypeScript
**Framework**: NestJS

```
middleware/
├── api_gateway/       # Servicio principal de API gateway
├── ai_tutor_service/  # Integración de tutorías con IA
├── lrs_connector/     # Conector de sistemas LRS legacy
└── parachain_bridge/  # Puente con la parachain
```

**Estructura de Servicios** (cada servicio sigue convenciones NestJS):

```
service/
├── src/
│   ├── modules/       # Módulos de características
│   ├── controllers/   # Controladores HTTP
│   ├── services/      # Lógica de negocio
│   ├── dto/           # Objetos de transferencia de datos
│   ├── guards/        # Autenticación/autorización
│   └── validators/    # Validación de datos
├── test/              # Tests de integración
└── package.json       # Dependencias y scripts
```

## Recursos Compartidos

**Ubicación**: `shared/`
**Propósito**: Utilidades comunes, tipos y configuraciones usadas entre servicios

```
shared/
├── types/             # Definiciones de tipos compartidos
│   ├── learning/      # Tipos relacionados con aprendizaje
│   ├── blockchain/    # Tipos de blockchain
│   └── api/           # Tipos de API
└── utils/             # Utilidades compartidas
    ├── crypto/        # Utilidades criptográficas
    ├── validation/    # Validación de datos
    └── testing/       # Utilidades de testing
```

## Especificaciones

**Ubicación**: `.specs/`
**Propósito**: Requerimientos del proyecto, documentos de diseño y tareas de implementación

- Usar para planificación de características complejas
- Referenciar en comentarios de código al implementar specs

## Guías de Desarrollo

1. **Diseño Dirigido por Dominio**: Organizar código por dominios de negocio, no por capas técnicas
2. **Clean Architecture**: Mantener separación clara entre lógica de negocio e infraestructura
3. **Nomenclatura Consistente**: Usar convenciones apropiadas por lenguaje (snake_case para Rust, camelCase para TypeScript/Dart)
4. **Manejo de Errores**: Implementar manejo comprehensivo de errores en todas las capas
5. **Testing**: Escribir tests para lógica de negocio, especialmente casos de uso y pallets
6. **Documentación**: Documentar APIs públicas y lógica de negocio compleja

## Convenciones de Nomenclatura de Archivos

- **Rust**: `snake_case.rs`
- **Dart**: `snake_case.dart`
- **TypeScript**: `kebab-case.ts` para archivos, `PascalCase` para clases
- **Tests**: `*.test.ts`, `*_test.dart`, `tests.rs`

## Estructura Detallada por Componente

### API Gateway (middleware/api_gateway/)

```
api_gateway/src/
├── controllers/       # Controladores REST/GraphQL
│   ├── passport/      # Endpoints del pasaporte de aprendizaje
│   ├── interactions/  # Endpoints de interacciones
│   ├── tutoring/      # Endpoints de tutorías
│   ├── reputation/    # Endpoints de reputación
│   └── marketplace/   # Endpoints del marketplace
├── services/          # Lógica de negocio
│   ├── blockchain/    # Comunicación con Substrate
│   ├── queue/         # Cola de procesamiento
│   ├── cache/         # Caché Redis
│   └── auth/          # Servicios de autenticación
└── validators/        # Validación de datos xAPI
```

### LRS Connector (middleware/lrs_connector/)

```
lrs_connector/src/
├── adapters/          # Adaptadores específicos por LRS
│   ├── learning_locker/ # Integración con Learning Locker
│   ├── scorm_cloud/   # Integración con SCORM Cloud
│   └── moodle/        # Integración con Moodle
├── transformers/      # Transformación de datos
│   ├── xapi/          # Procesamiento xAPI
│   └── blockchain/    # Mapeo a formatos blockchain
└── queue/             # Cola de reintentos
```

### AI Tutor Service (middleware/ai_tutor_service/)

```
ai_tutor_service/src/
├── models/            # Modelos de IA
├── adapters/          # Adaptadores de LLM
│   ├── openai/        # Integración OpenAI
│   ├── anthropic/     # Integración Anthropic
│   └── local/         # Modelos locales
├── validators/        # Validación de respuestas
└── personalization/   # Personalización de contenido
```
