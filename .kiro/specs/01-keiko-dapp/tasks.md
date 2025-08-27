# Plan de Implementación - Keiko DApp

## Estado Actual del Proyecto

**✅ COMPLETADO:**
- Backend Substrate: 3 pallets personalizados completamente implementados y funcionales
  - `pallet_learning_interactions`: xAPI completo con jerarquías educativas
  - `pallet_life_learning_passport`: Perfiles de usuario y privacidad
  - `pallet_reputation_system`: Reputación dinámica con expiración
- Runtime: Pallets integrados correctamente en parachain Substrate
- Tests: Tests unitarios para todos los pallets

**⚠️ PENDIENTE (Solo archivos de configuración):**
- Middleware: Solo package.json, sin implementación real
- Frontend: Solo archivos de tema, sin main.dart ni aplicación Flutter
- API Gateway: Requiere migración completa a Rust
- Microservicios: No implementados

**🔄 MIGRACIÓN REQUERIDA:**
- Reestructurar proyecto: backend/ → blockchain/, middleware/ → api-gateway/
- Migrar de NestJS/TypeScript a Rust para servicios
- Implementar arquitectura de microservicios cloud-native

## Tareas de Implementación

### Fase 0: Migración y Reestructuración del Proyecto

- [x] 0.1 Reestructurar directorios según nueva arquitectura

  - Crear nueva estructura de directorios: blockchain/, services/, api-gateway/, frontend/, shared/, infrastructure/
  - Migrar backend/ → blockchain/ (mantener parachain Substrate existente)
  - Migrar middleware/ → api-gateway/ (preparar para conversión a Rust)
  - Crear services/ para microservicios independientes
  - Crear shared/ para código compartido entre servicios
  - Crear infrastructure/ para IaC (Terraform, Kubernetes manifests)
  - Actualizar todos los Cargo.toml y referencias de paths
  - _Requerimientos: Preparación para arquitectura de microservicios_

- [x] 0.2 Actualizar documentación y configuración

  - Actualizar README.md con nueva estructura de proyecto
  - Actualizar .gitignore para nueva estructura
  - Configurar workspace Cargo.toml para blockchain/ y services/
  - Actualizar scripts de build y desarrollo
  - Documentar proceso de migración
  - _Requerimientos: Documentación actualizada_

### Fase 1: Backend Blockchain

- [x] 1. Pallets Substrate implementados y funcionales

  - ✅ Pallet Learning Interactions: Implementación completa con xAPI, jerarquías educativas
  - ✅ Pallet Life Learning Passport: Perfiles de usuario y configuraciones de privacidad  
  - ✅ Pallet Reputation System: Sistema de reputación dinámica con expiración
  - ✅ Integración en runtime: Todos los pallets integrados correctamente
  - ✅ Tests: Tests unitarios implementados para todos los pallets
  - _Requerimientos: 2.1-2.10, 1.1-1.5, 5.1-5.9_

- [x] 2. Implementar configuración base del nodo Substrate

  - ✅ Configuración inicial del nodo Substrate en backend/node/ (completado)
  - ✅ Configuración de red y consenso para desarrollo local (completado)
  - ✅ CLI básico para el nodo con parámetros de desarrollo (completado)
  - ✅ Tests básicos de funcionamiento del nodo (completado)
  - _Requerimientos: 15.1, 15.2_

- [x] 3. Implementar runtime base de la parachain

  - ✅ Runtime básico de parachain en backend/runtime/ con lib.rs (completado)
  - ✅ Pallets básicos de Substrate configurados (System, Timestamp, Balances, etc.) (completado)
  - ✅ Configuración inicial para parachain (cumulus) (completado)
  - ✅ Tipos y constantes del runtime configurados (completado)
  - ✅ Tests básicos del runtime (completado)
  - _Requerimientos: 15.3, 15.4, 15.5, 15.6, 15.7_

- [x] 4. **Desarrollar** pallet Learning Interactions

- [x] 4.1 Crear estructura base del pallet

  - Crear archivo lib.rs en blockchain/pallets/learning_interactions/
  - Implementar estructura básica del pallet con Config trait
  - Crear Cargo.toml con dependencias necesarias
  - Configurar macros básicos del pallet (#[pallet::pallet], #[pallet::config])
  - Escribir tests básicos de compilación
  - _Requerimientos: 2.1, 2.2_

- [x] 4.2 Implementar estructuras de datos xAPI

  - Crear tipos Rust para LearningInteraction, Actor, Verb, Object según estándar xAPI
  - Implementar validación de estructura xAPI en el pallet
  - Crear funciones de serialización/deserialización para compatibilidad JSON

  - Escribir tests unitarios para validación de datos xAPI
  - _Requerimientos: 2.1, 2.2, 9.1, 9.2_

- [x] 4.3 Implementar jerarquía de experiencias de aprendizaje

  - Crear estructuras Course, Class, TutorialSession en el pallet
  - Implementar relaciones jerárquicas entre contenedores educativos

  - Crear extrinsics para crear y gestionar cursos, clases y sesiones
  - Implementar queries para recuperar jerarquías completas
  - Escribir tests de integración para jerarquías de datos
  - _Requerimientos: 16.1, 16.2, 16.3, 16.4, 16.5, 16.6, 16.7, 16.8, 16.9, 16.10, 16.11, 17.1, 17.2, 17.3, 17.4, 17.5, 17.6, 17.7, 17.8, 17.9, 17.10, 17.11, 17.12_

- [x] 4.4 Implementar registro de interacciones atómicas

  - Crear extrinsic create_interaction para registrar interacciones individuales
  - Implementar validación de contenido y estructura de interacciones
  - Crear sistema de eventos para notificar interacciones registradas
  - Implementar manejo de archivos adjuntos y evidencias
  - Escribir tests para diferentes tipos de interacciones (pregunta, respuesta, ejercicio, etc.)
  - _Requerimientos: 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 2.10_

- [x] 5. Desarrollar pallet Life Learning Passport

- [x] 5.1 Crear estructura base del pallet

  - Crear archivo lib.rs en blockchain/pallets/life_learning_passport/
  - Implementar estructura básica del pallet con Config trait
  - Crear Cargo.toml con dependencias necesarias
  - Configurar macros básicos del pallet
  - Escribir tests básicos de compilación
  - _Requerimientos: 1.1, 1.2_

- [x] 5.2 Implementar estructura del pasaporte

  - Crear estructura LifeLearningPassport con referencias a interacciones
  - Implementar configuraciones de privacidad granulares
  - Crear extrinsic para inicializar pasaporte al registrar usuario
  - Implementar queries para recuperar datos del pasaporte
  - Escribir tests para creación y gestión de pasaportes

  - _Requerimientos: 1.1, 1.2, 10.3_

- [x] 5.3 Implementar sistema de compartir pasaportes

  - Crear funcionalidad para generar enlaces verificables de pasaportes
  - Implementar verificación criptográfica de autenticidad de datos
  - Crear sistema de permisos para compartir datos específicos
  - Implementar expiración de enlaces compartidos

  - Escribir tests para verificación y compartir de pasaportes
  - _Requerimientos: 1.4, 1.5, 10.4_

- [x] 5.4 Implementar perfiles de aprendizaje

  - Crear estructura LearningProfile con estilos y preferencias de aprendizaje
  - Implementar almacenamiento de resultados de evaluaciones pedagógicas
  - Crear sistema de actualización automática de perfiles basado en interacciones
  - Implementar queries para acceder a perfiles de aprendizaje
  - Escribir tests para gestión de perfiles de aprendizaje
  - _Requerimientos: 12.3, 12.4, 12.6_

- [-] 6. Desarrollar pallet Reputation System

- [x] 6.1 Crear estructura base del pallet

  - Crear archivo lib.rs en blockchain/pallets/reputation_system/
  - Implementar estructura básica del pallet con Config trait
  - Crear Cargo.toml con dependencias necesarias
  - Configurar macros básicos del pallet
  - Escribir tests básicos de compilación
  - _Requerimientos: 5.1, 5.2_

- [x] 6.2 Implementar sistema de calificaciones con expiración

  - Crear estructura Rating con timestamp de expiración (30 días)
  - Implementar extrinsic create_rating para calificar usuarios
  - Crear sistema automático de expiración de calificaciones
  - Implementar cálculo de reputación dinámica priorizando calificaciones recientes
  - Escribir tests para expiración y cálculo de reputación
  - _Requerimientos: 5.1, 5.2, 5.4, 5.5, 5.9_

- [x] 6.3 Implementar sistema bidireccional de calificaciones

  - Crear funcionalidad para que tutores califiquen estudiantes
  - Implementar sistema de comentarios detallados en calificaciones
  - Crear funcionalidad de respuesta a comentarios
  - Implementar calificaciones entre pares para actividades grupales
  - Escribir tests para sistema bidireccional de calificaciones
  - _Requerimientos: 5.3, 5.6, 5.7_

- [ ] 6.4 Implementar detección anti-fraude



  - Crear algoritmos para detectar patrones de calificación maliciosos
  - Implementar sistema de alertas para comportamientos sospechosos
  - Crear mecanismos de penalización para usuarios fraudulentos
  - Implementar sistema de apelaciones para calificaciones disputadas
  - Escribir tests para detección de fraude
  - _Requerimientos: 5.8_

- [ ] 7. Desarrollar pallet Marketplace
- [ ] 7.1 Crear estructura base del pallet

  - Crear directorio blockchain/pallets/marketplace/
  - Crear archivo lib.rs con estructura básica del pallet
  - Implementar Config trait y macros básicos
  - Crear Cargo.toml con dependencias necesarias
  - Escribir tests básicos de compilación
  - _Requerimientos: 15.1, 15.2_

- [ ] 7.2 Implementar gestión de espacios de aprendizaje

  - Crear estructura LearningSpace con información de espacios físicos
  - Implementar sistema de verificación de credenciales de espacios
  - Crear extrinsics para registrar y gestionar espacios
  - Implementar certificaciones de seguridad y accesibilidad
  - Escribir tests para gestión de espacios
  - _Requerimientos: 15.2, 15.7_

- [ ] 7.3 Implementar sistema de reservas

  - Crear estructura SpaceReservation para gestionar reservas
  - Implementar sistema de disponibilidad y calendario de espacios
  - Crear extrinsics para crear, modificar y cancelar reservas
  - Implementar cálculo automático de costos de reserva
  - Escribir tests para sistema de reservas
  - _Requerimientos: 15.4_

- [ ] 7.4 Implementar calificaciones de espacios

  - Crear estructura SpaceRating para calificar espacios
  - Implementar calificaciones multidimensionales (seguridad, limpieza, accesibilidad)
  - Crear sistema de recomendación de espacios basado en calificaciones
  - Implementar filtros especiales para menores y necesidades especiales
  - Escribir tests para calificaciones de espacios
  - _Requerimientos: 15.1, 15.3, 15.5, 15.6, 15.8_

- [ ] 8. Desarrollar pallet Governance
- [ ] 8.1 Crear estructura base del pallet

  - Crear directorio blockchain/pallets/governance/
  - Crear archivo lib.rs con estructura básica del pallet
  - Implementar Config trait y macros básicos
  - Crear Cargo.toml con dependencias necesarias
  - Escribir tests básicos de compilación
  - _Requerimientos: 6.1, 6.2_

- [ ] 8.2 Implementar herramientas de gobernanza comunitaria

  - Crear estructuras para propuestas y votaciones comunitarias
  - Implementar sistema de votación democrática con diferentes mecanismos
  - Crear funcionalidad para establecer reglas de validación personalizadas
  - Implementar registro inmutable de decisiones de gobernanza
  - Escribir tests para sistema de gobernanza
  - _Requerimientos: 6.1, 6.2, 6.3, 6.5_

- [ ] 8.3 Implementar interoperabilidad entre comunidades

  - Crear sistema de reconocimiento mutuo entre comunidades
  - Implementar mecanismos de resolución de conflictos entre reglas
  - Crear funcionalidad para transferencia de credenciales entre comunidades
  - Implementar sistema de federación de comunidades educativas
  - Escribir tests para interoperabilidad
  - _Requerimientos: 6.4_

- [ ] 9. Integrar pallets en el runtime

  - Actualizar blockchain/runtime/lib.rs para incluir todos los pallets personalizados
  - Configurar parámetros y constantes para cada pallet en el runtime
  - Implementar configuración de pesos para extrinsics
  - Configurar genesis config para inicialización de pallets
  - Escribir tests de integración del runtime completo
  - _Requerimientos: Todos los requerimientos de backend dependen de esta integración_

- [ ] 10. Desarrollar API Gateway GraphQL (Rust)
- [ ] 10.1 Migrar y reestructurar middleware como API Gateway

  - Migrar middleware/ → api-gateway/ según nueva estructura
  - Cambiar de NestJS/TypeScript a Rust con Axum + async-graphql
  - Crear directorio src/ con estructura Rust en api-gateway/
  - Implementar main.rs con configuración básica de Axum + async-graphql
  - Crear módulos base (schema.rs, resolvers.rs, grpc_clients.rs)
  - Configurar Cargo.toml con dependencias para gRPC (tonic) y GraphQL (async-graphql)
  - Escribir tests básicos de compilación y arranque
  - _Requerimientos: 9.1, 9.2_

- [ ] 10.2 Implementar esquema GraphQL unificado

  - Crear tipos GraphQL para usuarios, interacciones, pasaportes y reputación
  - Implementar Query root que orquesta llamadas gRPC a múltiples microservicios
  - Implementar Mutation root que traduce mutations GraphQL a llamadas gRPC
  - Implementar Subscription root conectado a Redis Streams para eventos en tiempo real
  - Escribir tests de integración para esquema GraphQL completo
  - _Requerimientos: 9.3, 9.7, 7.11, 7.12_

- [ ] 10.3 Implementar clientes gRPC para microservicios

  - Crear clientes gRPC para Identity, Learning, Reputation, Passport, Governance y Marketplace Services
  - Implementar pool de conexiones gRPC con load balancing y circuit breakers
  - Crear sistema de cache para respuestas gRPC con invalidación basada en eventos Redis
  - Implementar propagación de contexto de autenticación via gRPC metadata
  - Escribir tests para comunicación gRPC con mocks de microservicios
  - _Requerimientos: 9.1, 9.2, 9.4, 9.5_

- [ ] 10.4 Implementar integración con Redis Streams para eventos

  - Configurar cliente Redis para suscribirse a eventos de dominio de microservicios
  - Implementar sistema de invalidación de cache basado en eventos
  - Crear sistema de notificaciones en tiempo real via GraphQL subscriptions
  - Implementar manejo de eventos para actualizar estado de frontend automáticamente
  - Escribir tests para flujo completo de eventos Redis → GraphQL subscriptions
  - _Requerimientos: 9.6, 9.7_

- [ ] 10.5 Implementar endpoints REST para integraciones externas

  - Crear endpoints REST para webhooks de LRS (Learning Locker, Moodle, Canvas)
  - Implementar validación de webhooks y transformación de datos xAPI
  - Crear endpoints REST para APIs de terceros que no soportan GraphQL
  - Implementar rate limiting y autenticación para endpoints REST
  - Escribir tests para endpoints REST e integración con sistemas externos
  - _Requerimientos: 9.8, 3.1, 3.2_

- [ ] 11. Desarrollar microservicios independientes con gRPC
- [ ] 11.1 Crear Identity Service

  - Crear directorio services/identity-service/ con estructura Rust + tonic
  - Implementar proto/identity.proto con servicios gRPC para autenticación y usuarios
  - Crear main.rs con servidor gRPC usando tonic y tokio
  - Implementar base de datos PostgreSQL con sqlx para gestión de usuarios
  - Configurar Docker y Kubernetes manifests para despliegue
  - Escribir tests unitarios e integración para Identity Service
  - _Requerimientos: 4.1, 9.5_

- [ ] 11.2 Crear Learning Service (Arquitectura Híbrida)

  - Crear directorio services/learning_service/ con estructura Rust + tonic
  - Implementar proto/learning.proto con servicios gRPC para interacciones xAPI
  - Crear cliente Substrate para enviar transacciones a pallet_learning_interactions
  - Implementar base de datos PostgreSQL local para cache y queries optimizadas
  - Configurar sincronización bidireccional: escritura → parachain, lectura → cache local
  - Configurar publicación de eventos de dominio en Redis Streams (NO en parachain)
  - Implementar detección de eventos de parachain para actualizar cache local
  - Escribir tests unitarios e integración para Learning Service híbrido
  - _Requerimientos: 2.1, 2.2, 2.3, 2.4, 18.1, 18.2_

- [ ] 11.3 Crear Reputation Service (Arquitectura Híbrida)

  - Crear directorio services/reputation_service/ con estructura Rust + tonic
  - Implementar proto/reputation.proto con servicios gRPC para calificaciones
  - Crear cliente Substrate para enviar transacciones a pallet_reputation_system
  - Implementar base de datos PostgreSQL local para cache y cálculos de reputación
  - Configurar sincronización: escritura → parachain, lectura → cache con fallback a RPC
  - Configurar suscripción a eventos de Learning Service via Redis Streams
  - Implementar detección de eventos de parachain para actualizar reputación local
  - Escribir tests unitarios e integración para Reputation Service híbrido
  - _Requerimientos: 5.1, 5.2, 5.3, 5.4, 18.1, 18.2_

- [ ] 11.4 Crear Passport Service (Arquitectura Híbrida)

  - Crear directorio services/passport_service/ con estructura Rust + tonic
  - Implementar proto/passport.proto con servicios gRPC para pasaportes de aprendizaje
  - Crear cliente Substrate para enviar transacciones a pallet_life_learning_passport
  - Implementar agregación de datos de Learning y Reputation Services via gRPC
  - Configurar base de datos PostgreSQL local para vistas agregadas y cache
  - Configurar sincronización: escritura → parachain, lectura → cache agregado
  - Implementar detección de eventos de parachain para actualizar pasaportes
  - Escribir tests unitarios e integración para Passport Service híbrido
  - _Requerimientos: 1.1, 1.2, 1.3, 1.4, 18.1, 18.2_

- [ ] 11.5 Crear Governance Service (Arquitectura Híbrida)

  - Crear directorio services/governance_service/ con estructura Rust + tonic
  - Implementar proto/governance.proto con servicios gRPC para gobernanza comunitaria
  - Crear cliente Substrate para enviar transacciones a pallet_governance (futuro)
  - Implementar sistema de propuestas y votaciones con base de datos PostgreSQL local
  - Configurar sincronización: decisiones críticas → parachain, cache → PostgreSQL
  - Configurar eventos de dominio para decisiones de gobernanza en Redis Streams
  - Implementar detección de eventos de parachain para actualizar estado local
  - Escribir tests unitarios e integración para Governance Service híbrido
  - _Requerimientos: 6.1, 6.2, 6.3, 18.1, 18.2_

- [ ] 11.6 Crear Marketplace Service (Arquitectura Híbrida)

  - Crear directorio services/marketplace_service/ con estructura Rust + tonic
  - Implementar proto/marketplace.proto con servicios gRPC para espacios de aprendizaje
  - Crear cliente Substrate para enviar transacciones a pallet_marketplace (futuro)
  - Implementar gestión de espacios, reservas y calificaciones con PostgreSQL local
  - Configurar sincronización: reservas críticas → parachain, cache → PostgreSQL
  - Configurar integración con Reputation Service via gRPC para recomendaciones
  - Implementar eventos Redis Streams para notificaciones de reservas
  - Escribir tests unitarios e integración para Marketplace Service híbrido
  - _Requerimientos: 15.1, 15.2, 15.4, 15.6, 18.1, 18.2_

- [ ] 11.7 Implementar sincronización Parachain-Microservicios

  - Crear shared/parachain_sync crate para sincronización común
  - Implementar cliente Substrate genérico con pool de conexiones RPC
  - Crear sistema de detección de eventos de parachain usando substrate-api-client
  - Implementar patrón Event Sourcing para sincronizar cambios parachain → cache local
  - Configurar sistema de fallback: cache local → RPC parachain si cache falla
  - Implementar métricas de sincronización y health checks para cada microservicio
  - Crear sistema de reconciliación para detectar y corregir inconsistencias
  - Escribir tests de integración para flujo completo de sincronización
  - _Requerimientos: 18.1, 18.2, 18.3, 18.4, 18.5, 18.6, 18.7, 18.8, 18.9, 18.10_

- [ ] 12. Desarrollar AI Tutor Service
- [ ] 12.1 Migrar y crear estructura base del AI Tutor Service

  - Migrar middleware/ai_tutor_service/ → services/ai-tutor-service/ 
  - Cambiar de NestJS/TypeScript a Rust + tonic según nueva arquitectura
  - Implementar proto/ai_tutor.proto con servicios gRPC para tutorías con IA
  - Crear Cargo.toml con dependencias para LLMs (async-openai, reqwest) y gRPC (tonic)
  - Implementar main.rs con servidor gRPC usando tokio runtime
  - Configurar Docker y Kubernetes manifests para despliegue
  - Escribir tests básicos de compilación y arranque del servicio
  - _Requerimientos: 4.1, 4.2_

- [ ] 12.2 Implementar motor de IA personalizable con gRPC

  - Integrar modelos de IA (GPT, Claude, etc.) usando async HTTP clients
  - Crear servicios gRPC para generación de contenido educativo personalizado
  - Implementar sistema de adaptación basado en datos del Passport Service via gRPC
  - Crear sistema de verificación de precisión antes de responder via gRPC
  - Escribir tests para generación de contenido IA con mock servers y gRPC
  - _Requerimientos: 4.2, 11.1, 11.2, 11.3, 11.7_

- [ ] 12.3 Implementar sistema de recomendaciones con eventos

  - Crear algoritmos de recomendación usando machine learning crates (candle, tch)
  - Implementar detección de dificultades y escalación via gRPC al Marketplace Service
  - Configurar suscripción a eventos de Learning Service para mejora continua
  - Implementar publicación de eventos de recomendaciones en Redis Streams
  - Escribir tests para sistema de recomendaciones con property-based testing
  - _Requerimientos: 11.4, 11.5, 11.6, 13.1, 13.2, 13.3, 13.4, 13.5, 13.6, 13.7, 13.8_

- [ ] 12.4 Implementar evaluación pedagógica inicial

  - Crear servicios gRPC para cuestionarios adaptativos y análisis de respuestas
  - Implementar integración con Passport Service via gRPC para actualizar perfiles
  - Crear sistema de reevaluación usando cron-like scheduling con tokio-cron-scheduler
  - Configurar eventos de dominio para cambios en perfiles de aprendizaje
  - Escribir tests para evaluación pedagógica con quickcheck y mocks gRPC
  - _Requerimientos: 12.1, 12.2, 12.5, 12.7_

- [ ] 13. Desarrollar panel admin Leptos - Configuración base
- [ ] 13.1 Crear estructura base del panel administrativo

  - Migrar middleware/web_frontend/ → api-gateway/admin-panel/ según nueva estructura
  - Crear main.rs con configuración básica de Leptos SSR/CSR
  - Implementar estructura de módulos src/ con app, components, pages, services
  - Configurar Leptos.toml para build configuration y features administrativas
  - Crear configuración base para autenticación administrativa
  - Integrar con API Gateway GraphQL para datos administrativos
  - Escribir tests básicos de configuración con wasm-bindgen-test
  - _Requerimientos: 8.1, 8.7_

- [ ] 13.2 Implementar gestión de estado administrativo con Leptos Signals

  - Configurar signals y resources para gestión de estado del panel admin
  - Crear hooks personalizados para autenticación admin y navegación
  - Implementar servicios para abstracción de datos administrativos
  - Crear cliente GraphQL para comunicación con APIs usando reqwest
  - Escribir tests unitarios para hooks y servicios administrativos
  - _Requerimientos: 8.2, 8.3, 8.4, 8.5, 8.6, 8.8_

- [ ] 14. Integración Frontend Móvil - Backend
- [ ] 14.1 Definir contratos GraphQL para aplicación móvil

  - Definir schemas GraphQL para pasaporte de aprendizaje y visualización cronológica
  - Crear mutations para calificaciones, comentarios y evaluaciones desde aplicación móvil
  - Definir subscriptions para actualizaciones en tiempo real de interacciones
  - Documentar APIs GraphQL para consumo desde Flutter con ejemplos móviles
  - Crear queries optimizadas para diferentes casos de uso móviles (timeline, jerarquías, marketplace)
  - _Requerimientos: 7.6, 7.7, 7.8_

- [ ] 14.2 Implementar orquestación GraphQL en API Gateway

  - Configurar resolvers GraphQL que orquesten llamadas gRPC a microservicios
  - Implementar agregación de datos de múltiples microservicios para vistas móviles
  - Configurar caché GraphQL optimizado para consultas móviles frecuentes
  - Implementar manejo de errores GraphQL comprensibles para aplicación móvil
  - Configurar subscriptions GraphQL alimentadas por eventos Redis Streams
  - Optimizar queries GraphQL para consumo de datos móvil (paginación, lazy loading)
  - _Requerimientos: 9.1, 9.2, 9.3, 9.4, 9.7_

**Nota:** Para implementación detallada de la aplicación móvil Flutter con Clean Architecture y Riverpod, ver Spec 02-flutter-frontend-architecture

**Nota:** Todas las tareas de implementación detallada de la aplicación móvil Flutter (incluyendo tutorías IA, marketplace de espacios, sistema de reputación, evaluación pedagógica, y planes adaptativos) se encuentran en el Spec 02-flutter-frontend-architecture

- [ ] 18. Desarrollar componentes compartidos
- [ ] 18.1 Crear tipos y esquemas compartidos

  - Crear directorio shared/types/ con definiciones TypeScript/Dart
  - Implementar esquemas xAPI compartidos entre servicios
  - Crear tipos de blockchain compartidos
  - Implementar validadores de datos compartidos
  - Escribir tests para tipos y validadores
  - _Requerimientos: 9.1, 9.2_

- [ ] 18.2 Crear utilidades compartidas

  - Implementar utilidades criptográficas en shared/utils/crypto/
  - Crear utilidades de validación de datos
  - Implementar utilidades de testing compartidas
  - Crear helpers para manejo de errores
  - Escribir tests para utilidades compartidas
  - _Requerimientos: 10.1, 10.2_

- [ ] 19. Implementar seguridad y privacidad
- [ ] 19.1 Implementar cifrado y protección de datos

  - Crear sistema de cifrado end-to-end para datos sensibles
  - Implementar técnicas de minimización de datos según GDPR
  - Crear sistema de anonimización para análisis de datos
  - Implementar auditoría de acceso a datos personales
  - Escribir tests de seguridad y penetración
  - _Requerimientos: 10.1, 10.2_

- [ ] 19.2 Implementar sistema de consentimiento

  - Crear interfaces para gestión granular de consentimientos
  - Implementar sistema de revocación de consentimientos
  - Crear notificaciones de cambios en políticas de privacidad
  - Implementar exportación de datos personales bajo demanda
  - Escribir tests para gestión de consentimientos
  - _Requerimientos: 10.4, 10.5_

- [ ] 20. Implementar testing integral y documentación
- [ ] 20.1 Crear suite de tests end-to-end

  - Implementar tests de flujos completos de usuario
  - Crear tests de integración entre todos los componentes
  - Implementar tests de rendimiento y carga
  - Crear tests de compatibilidad entre plataformas
  - Configurar CI/CD para ejecución automática de tests
  - _Requerimientos: Todos los requerimientos necesitan validación mediante tests_

- [ ] 20.2 Crear documentación completa

  - Crear directorio docs/ con documentación de arquitectura
  - Escribir documentación de APIs con especificaciones OpenAPI
  - Crear guías de despliegue para diferentes entornos
  - Escribir documentación de arquitectura y diagramas técnicos
  - Crear guías de usuario para todas las funcionalidades
  - Implementar documentación interactiva y ejemplos de código
  - _Requerimientos: 9.3_

- [ ] 21. Configurar despliegue básico
- [ ] 21.1 Configurar Docker y contenedores

  - Crear Dockerfiles para cada servicio y el API Gateway
  - Crear docker-compose.yml para desarrollo local
  - Configurar variables de entorno para diferentes entornos
  - Crear scripts de build y despliegue básicos
  - Escribir documentación de despliegue local
  - _Requerimientos: 14.4, 14.5_

- [ ] 21.2 Configurar CI/CD básico

  - Crear workflows de GitHub Actions para build y test automático
  - Configurar build automático de aplicación Flutter para web
  - Implementar tests automáticos en pipelines
  - Crear scripts de despliegue para entornos de desarrollo
  - Configurar notificaciones de estado de builds
  - _Requerimientos: Todos los requerimientos necesitan despliegue automatizado_


