# Plan de Implementación - Keiko DApp

## Estado Actual del Proyecto

**✅ COMPLETADO:**
- Migración de Polkadot parachain a Starknet appchain (Keikochain)
- Estructura del proyecto reorganizada según arquitectura de cinco capas
- Documentación actualizada con nueva arquitectura híbrida

**🔄 EN PROGRESO:**
- Implementación de arquitectura híbrida de cinco capas
- Migración de pallets Substrate a contratos Cairo en Keikochain
- Desarrollo de gRPC Gateway Layer

**⚠️ PENDIENTE:**
- Contratos Cairo en Keikochain (Starknet Appchain)
- gRPC Gateway Layer (Rust ↔ Cairo translator)
- Microservicios independientes (Service Layer)
- API Gateway con GraphQL + WSS (API Layer)
- Panel administrativo Leptos

**🎯 OBJETIVO:**
- Microservicios cloud-native completamente independientes
- Arquitectura híbrida con Keikochain como fuente de verdad
- Comunicación gRPC entre microservicios
- GraphQL API Gateway con WebSocket Secure (WSS)

## Tareas de Implementación

### Fase 0: Migración y Reestructuración del Proyecto

- [ ] 0.1 Reestructurar directorios según nueva arquitectura

  - Crear nueva estructura de directorios: appchain/, grpc-gateway/, services/, api-gateway/, frontend/, shared/, docs/
  - Migrar backend/ → appchain/ (conversión a contratos Cairo)
  - Migrar middleware/ → api-gateway/ (preparar para conversión a Rust)
  - Crear grpc-gateway/ para traductor Rust ↔ Cairo
  - Crear services/ para microservicios independientes
  - Crear shared/ para código compartido entre servicios
  - Actualizar todos los Cargo.toml y referencias de paths
  - _Requerimientos: Preparación para arquitectura de cinco capas_

- [ ] 0.2 Actualizar documentación y configuración

  - Actualizar README.md con nueva estructura de proyecto
  - Actualizar .gitignore para nueva estructura
  - Configurar workspace Cargo.toml para appchain/, grpc-gateway/, services/, api-gateway/
  - Actualizar scripts de build y desarrollo
  - Documentar proceso de migración a Keikochain
  - _Requerimientos: Documentación actualizada_

### Fase 1: Keikochain Layer (Starknet Appchain)

- [ ] 01. Configurar Keikochain (Starknet Appchain)

  - Configurar entorno de desarrollo con Starknet devnet
  - Configurar conexión a Keikochain (wss://keikochain.karnot.xyz)
  - Configurar herramientas de desarrollo Cairo (Scarb, starknet-devnet)
  - Configurar variables de entorno para diferentes entornos (dev, staging, production)
  - Crear scripts de despliegue y testing para contratos Cairo
  - _Requerimientos: Configuración base de Keikochain_

- [ ] 02. Implementar contrato Proof-of-Humanity

  - Crear contrato proof_of_humanity.cairo con verificación STARK
  - Implementar registro de humanity_proof_key con verificación de unicidad
  - Implementar verificación de firmas Ed25519 para interacciones de aprendizaje
  - Crear funciones para verificar humanidad y obtener learning passport
  - Implementar tests unitarios para verificación STARK y Ed25519
  - _Requerimientos: Proof-of-Humanity con zkProofs_

- [ ] 03. Implementar contrato Learning Interactions

  - Crear contrato learning_interactions.cairo con soporte xAPI completo
  - Implementar jerarquías educativas (Course, Class, TutorialSession)
  - Implementar registro de interacciones atómicas con firma Ed25519
  - Crear funciones para consultar interacciones por usuario y rango de tiempo
  - Implementar tests unitarios para validación xAPI y jerarquías
  - _Requerimientos: 2.1-2.10, jerarquías educativas_

- [ ] 04. Implementar contrato Life Learning Passport

  - Crear contrato life_learning_passport.cairo con gestión de pasaportes
  - Implementar configuraciones de privacidad granulares
  - Implementar sistema de compartir pasaportes con enlaces verificables
  - Crear funciones para generar y verificar enlaces de pasaportes
  - Implementar tests unitarios para gestión de pasaportes y privacidad
  - _Requerimientos: 1.1-1.5, perfiles de aprendizaje_

- [ ] 05. Implementar contrato Reputation System

  - Crear contrato reputation_system.cairo con sistema de calificaciones
  - Implementar calificaciones con expiración de 30 días
  - Implementar sistema bidireccional de calificaciones (estudiante-tutor)
  - Crear funciones para calcular reputación dinámica priorizando recientes
  - Implementar tests unitarios para expiración y cálculo de reputación
  - _Requerimientos: 5.1-5.9, sistema de reputación dinámica_

- [ ] 06. Implementar contrato Governance

  - Crear contrato governance.cairo con herramientas de gobernanza comunitaria
  - Implementar sistema de propuestas y votaciones democráticas
  - Implementar registro inmutable de decisiones de gobernanza
  - Crear funciones para establecer reglas de validación personalizadas
  - Implementar tests unitarios para sistema de gobernanza
  - _Requerimientos: 6.1-6.5, gobernanza comunitaria_

- [ ] 07. Implementar contrato Marketplace

  - Crear contrato learning_marketplace.cairo con gestión de espacios de aprendizaje
  - Implementar sistema de reservas y disponibilidad de espacios
  - Implementar calificaciones multidimensionales de espacios
  - Crear funciones para verificación de credenciales de espacios
  - Implementar tests unitarios para gestión de espacios y reservas
  - _Requerimientos: 15.1-15.8, marketplace de espacios seguros_

- [ ] 08. Desplegar y probar contratos en Keikochain

  - Desplegar todos los contratos Cairo en Keikochain (Starknet Appchain)
  - Configurar direcciones de contratos y actualizar configuración
  - Implementar tests de integración end-to-end con Keikochain
  - Configurar monitoreo y observabilidad de contratos
  - Documentar direcciones de contratos y ABI para integración
  - _Requerimientos: Despliegue completo de Keikochain_

### Fase 2: gRPC Gateway Layer

- [ ] 09. Configurar gRPC Gateway base

  - Crear estructura base del gRPC Gateway en grpc-gateway/
  - Configurar cliente Starknet RPC con WebSocketConnector
  - Implementar conexión a Keikochain (wss://keikochain.karnot.xyz)
  - Configurar circuit breaker y retry policies
  - Crear configuración para diferentes entornos (dev, staging, production)
  - _Requerimientos: Configuración base del gRPC Gateway_

- [ ] 10. Implementar traductor Rust ↔ Cairo

  - Crear módulo translator/ para conversión de tipos
  - Implementar conversión de tipos Rust a FieldElement (Cairo)
  - Implementar conversión de respuestas Cairo a tipos Rust
  - Crear mapeo de funciones gRPC a funciones de contratos Cairo
  - Implementar validación de tipos y manejo de errores
  - _Requerimientos: Traductor Rust ↔ Cairo_

- [ ] 11. Implementar servicios gRPC para contratos Cairo

  - Crear proto/learning.proto con servicios para Learning Interactions
  - Crear proto/passport.proto con servicios para Life Learning Passport
  - Crear proto/reputation.proto con servicios para Reputation System
  - Crear proto/governance.proto con servicios para Governance
  - Crear proto/marketplace.proto con servicios para Marketplace
  - Implementar servidor gRPC con tonic para todos los servicios
  - _Requerimientos: Servicios gRPC para contratos Cairo_

- [ ] 12. Implementar clientes gRPC para microservicios

  - Crear clientes gRPC para Identity, Learning, Reputation, Passport, Governance y Marketplace Services
  - Implementar pool de conexiones gRPC con load balancing y circuit breakers
  - Crear sistema de cache para respuestas gRPC con invalidación basada en eventos Redis
  - Implementar propagación de contexto de autenticación via gRPC metadata
  - Escribir tests para comunicación gRPC con mocks de microservicios
  - _Requerimientos: Comunicación gRPC con microservicios_

- [ ] 13. Implementar manejo de transacciones y eventos

  - Implementar invocación de contratos Cairo via Starknet RPC
  - Implementar consultas de contratos Cairo via Starknet RPC
  - Crear sistema de detección de eventos de Keikochain
  - Implementar propagación de eventos a microservicios via Redis Streams
  - Escribir tests para flujo completo de transacciones y eventos
  - _Requerimientos: Manejo de transacciones y eventos_

### Fase 4: Service Layer + API Gateway Layer

- [ ] 14. Crear Identity Service

  - Crear directorio services/identity-service/ con estructura Rust + tonic
  - Implementar proto/identity.proto con servicios gRPC para autenticación y usuarios
  - Implementar autenticación FIDO2/WebAuthn con webauthn-rs
  - Implementar procesamiento biométrico off-chain (iris + genoma)
  - Implementar generación de humanity_proof_key y STARK proofs
  - Implementar base de datos PostgreSQL con sqlx para gestión de usuarios
  - Configurar Docker y Kubernetes manifests para despliegue
  - Escribir tests unitarios e integración para Identity Service
  - _Requerimientos: Autenticación híbrida FIDO2 + zkProofs_

- [ ] 16. Crear Learning Service (Arquitectura Híbrida)

  - Crear directorio services/learning-service/ con estructura Rust + tonic
  - Implementar proto/learning.proto con servicios gRPC para interacciones xAPI
  - Implementar cliente gRPC para comunicación con gRPC Gateway
  - Implementar base de datos PostgreSQL local para cache y queries optimizadas
  - Configurar sincronización híbrida: escritura → Keikochain, lectura → cache local
  - Configurar publicación de eventos de dominio en Redis Streams
  - Implementar detección de eventos de Keikochain para actualizar cache local
  - Escribir tests unitarios e integración para Learning Service híbrido
  - _Requerimientos: Procesamiento xAPI con arquitectura híbrida_

- [ ] 17. Crear Reputation Service (Arquitectura Híbrida)

  - Crear directorio services/reputation-service/ con estructura Rust + tonic
  - Implementar proto/reputation.proto con servicios gRPC para calificaciones
  - Implementar cliente gRPC para comunicación con gRPC Gateway
  - Implementar base de datos PostgreSQL local para cache y cálculos de reputación
  - Configurar sincronización: escritura → Keikochain, lectura → cache con fallback
  - Configurar suscripción a eventos de Learning Service via Redis Streams
  - Implementar detección de eventos de Keikochain para actualizar reputación local
  - Escribir tests unitarios e integración para Reputation Service híbrido
  - _Requerimientos: Sistema de reputación dinámica con expiración_

- [ ] 18. Crear Passport Service (Arquitectura Híbrida)

  - Crear directorio services/passport-service/ con estructura Rust + tonic
  - Implementar proto/passport.proto con servicios gRPC para pasaportes de aprendizaje
  - Implementar cliente gRPC para comunicación con gRPC Gateway
  - Implementar agregación de datos de Learning y Reputation Services via gRPC
  - Configurar base de datos PostgreSQL local para vistas agregadas y cache
  - Configurar sincronización: escritura → Keikochain, lectura → cache agregado
  - Implementar detección de eventos de Keikochain para actualizar pasaportes
  - Escribir tests unitarios e integración para Passport Service híbrido
  - _Requerimientos: Agregación de pasaportes de aprendizaje_

- [ ] 19. Crear Governance Service (Arquitectura Híbrida)

  - Crear directorio services/governance-service/ con estructura Rust + tonic
  - Implementar proto/governance.proto con servicios gRPC para gobernanza comunitaria
  - Implementar cliente gRPC para comunicación con gRPC Gateway
  - Implementar sistema de propuestas y votaciones con base de datos PostgreSQL local
  - Configurar sincronización: decisiones críticas → Keikochain, cache → PostgreSQL
  - Configurar eventos de dominio para decisiones de gobernanza en Redis Streams
  - Implementar detección de eventos de Keikochain para actualizar estado local
  - Escribir tests unitarios e integración para Governance Service híbrido
  - _Requerimientos: Herramientas de gobernanza comunitaria_

- [ ] 20. Crear Marketplace Service (Arquitectura Híbrida)

  - Crear directorio services/marketplace-service/ con estructura Rust + tonic
  - Implementar proto/marketplace.proto con servicios gRPC para espacios de aprendizaje
  - Implementar cliente gRPC para comunicación con gRPC Gateway
  - Implementar gestión de espacios, reservas y calificaciones con PostgreSQL local
  - Configurar sincronización: reservas críticas → Keikochain, cache → PostgreSQL
  - Configurar integración con Reputation Service via gRPC para recomendaciones
  - Implementar eventos Redis Streams para notificaciones de reservas
  - Escribir tests unitarios e integración para Marketplace Service híbrido
  - _Requerimientos: Gestión de espacios de aprendizaje seguros_

- [ ] 21. Crear AI Tutor Service

  - Crear directorio services/ai-tutor-service/ con estructura Rust + tonic
  - Implementar proto/ai_tutor.proto con servicios gRPC para tutorías con IA
  - Implementar integración con modelos de IA (GPT, Claude, etc.) usando async HTTP clients
  - Implementar sistema de recomendaciones usando machine learning crates
  - Implementar evaluación pedagógica inicial y reevaluación automática
  - Configurar integración con Passport Service via gRPC para perfiles de aprendizaje
  - Escribir tests unitarios e integración para AI Tutor Service
  - _Requerimientos: Tutores IA especializados_

- [ ] 22. Crear API Gateway GraphQL

  - Crear directorio api-gateway/graphql-server/ con estructura Rust + async-graphql
  - Implementar esquema GraphQL unificado para todos los microservicios
  - Implementar Query root que orquesta llamadas gRPC a múltiples microservicios
  - Implementar Mutation root que traduce mutations GraphQL a llamadas gRPC
  - Implementar Subscription root conectado a Redis Streams para eventos en tiempo real
  - Configurar caché GraphQL optimizado para consultas frecuentes
  - Escribir tests de integración para esquema GraphQL completo
  - _Requerimientos: API Gateway GraphQL unificado_

- [ ] 23. Implementar WebSocket Secure (WSS) para GraphQL Subscriptions

  - Implementar servidor WSS con tokio-tungstenite
  - Implementar autenticación JWT para conexiones WSS
  - Implementar manejo de conexiones WebSocket con gestión de estado
  - Implementar propagación de eventos Redis Streams a GraphQL subscriptions
  - Implementar manejo de errores y reconexión automática
  - Escribir tests para flujo completo de eventos Redis → GraphQL subscriptions
  - _Requerimientos: GraphQL Subscriptions sobre WSS_

- [ ] 24. Implementar endpoints REST para integraciones externas

  - Crear endpoints REST para webhooks de LRS (Learning Locker, Moodle, Canvas)
  - Implementar validación de webhooks y transformación de datos xAPI
  - Crear endpoints REST para APIs de terceros que no soportan GraphQL
  - Implementar rate limiting y autenticación para endpoints REST
  - Escribir tests para endpoints REST e integración con sistemas externos
  - _Requerimientos: Integración con LRS externos_

- [ ] 25. Crear Panel Admin Leptos

  - Crear directorio api-gateway/admin-panel/ con estructura Leptos SSR/CSR
  - Implementar gestión de estado administrativo con Leptos Signals
  - Crear hooks personalizados para autenticación admin y navegación
  - Implementar servicios para abstracción de datos administrativos
  - Crear cliente GraphQL para comunicación con APIs usando reqwest
  - Escribir tests unitarios para hooks y servicios administrativos
  - _Requerimientos: Panel administrativo web_

- [ ] 26. Desarrollar componentes compartidos

  - Crear directorio shared/types/ con definiciones Rust compartidas
  - Implementar esquemas xAPI compartidos entre servicios
  - Crear tipos de Keikochain compartidos
  - Implementar validadores de datos compartidos
  - Crear utilidades criptográficas en shared/utils/crypto/
  - Crear utilidades de validación de datos
  - Implementar utilidades de testing compartidas
  - Crear helpers para manejo de errores
  - Escribir tests para tipos, validadores y utilidades compartidas
  - _Requerimientos: Componentes compartidos entre servicios_

- [ ] 27. Implementar observabilidad y monitoreo

  - Implementar OpenTelemetry para tracing distribuido
  - Configurar Prometheus para métricas de servicios
  - Implementar logging estructurado con correlación de trazas
  - Configurar ELK Stack para logging centralizado
  - Implementar health checks para todos los servicios
  - Crear dashboards Grafana para monitoreo
  - Escribir tests para observabilidad y monitoreo
  - _Requerimientos: Observabilidad completa del sistema_

- [ ] 28. Implementar testing integral

  - Implementar tests de flujos completos de usuario
  - Crear tests de integración entre todos los componentes
  - Implementar tests de rendimiento y carga
  - Crear tests de compatibilidad entre plataformas
  - Escribir tests para flujos híbridos (Keikochain + microservicios)
  - _Requerimientos: Validación completa mediante tests_

- [ ] 29. Crear documentación completa

  - Crear directorio docs/ con documentación de arquitectura
  - Escribir documentación de APIs con especificaciones OpenAPI
  - Crear guías de despliegue para diferentes entornos
  - Escribir documentación de arquitectura y diagramas técnicos
  - Crear guías de usuario para todas las funcionalidades
  - Implementar documentación interactiva y ejemplos de código
  - _Requerimientos: Documentación completa del sistema_


