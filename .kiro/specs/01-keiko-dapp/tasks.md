# Plan de Implementación - Keiko DApp

## Tareas de Implementación

- [x] 1. Configurar estructura del monorepo y herramientas de desarrollo


  - Crear estructura de directorios del monorepo con backend/, frontend/, middleware/, shared/ y docs/
  - Configurar Cargo workspace para el backend Rust
  - Configurar Flutter workspace para el frontend multiplataforma
  - Configurar herramientas de CI/CD y linting para todos los componentes
  - _Requerimientos: Todos los requerimientos dependen de esta estructura base_

- [x] 2. Implementar configuración base del nodo Substrate




  - Crear configuración inicial del nodo Substrate en backend/node/ con main.rs y service.rs
  - Implementar configuración de red y consenso para desarrollo local
  - Configurar CLI básico para el nodo con parámetros de desarrollo
  - Escribir tests básicos de funcionamiento del nodo
  - _Requerimientos: 14.1, 14.2_

- [x] 3. Implementar runtime base de la parachain











  - Crear runtime básico de parachain en backend/runtime/ con lib.rs
  - Configurar pallets básicos de Substrate (System, Timestamp, Balances, etc.)
  - Implementar configuración inicial para parachain (cumulus)
  - Configurar tipos y constantes del runtime
  - Escribir tests básicos del runtime
  - _Requerimientos: 14.3, 14.4, 14.5, 14.6, 14.7_

- [x] 4. **Desarrollar** pallet Learning Interactions




- [x] 4.1 Crear estructura base del pallet




  - Crear archivo lib.rs en backend/pallets/learning_interactions/
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

- [ ] 5. Desarrollar pallet Life Learning Passport
- [ ] 5.1 Crear estructura base del pallet

  - Crear archivo lib.rs en backend/pallets/life_learning_passport/
  - Implementar estructura básica del pallet con Config trait
  - Crear Cargo.toml con dependencias necesarias
  - Configurar macros básicos del pallet
  - Escribir tests básicos de compilación
  - _Requerimientos: 1.1, 1.2_

- [ ] 5.2 Implementar estructura del pasaporte

  - Crear estructura LifeLearningPassport con referencias a interacciones
  - Implementar configuraciones de privacidad granulares
  - Crear extrinsic para inicializar pasaporte al registrar usuario
  - Implementar queries para recuperar datos del pasaporte
  - Escribir tests para creación y gestión de pasaportes
  - _Requerimientos: 1.1, 1.2, 10.3_

- [ ] 5.3 Implementar sistema de compartir pasaportes

  - Crear funcionalidad para generar enlaces verificables de pasaportes
  - Implementar verificación criptográfica de autenticidad de datos
  - Crear sistema de permisos para compartir datos específicos
  - Implementar expiración de enlaces compartidos
  - Escribir tests para verificación y compartir de pasaportes
  - _Requerimientos: 1.4, 1.5, 10.4_

- [ ] 5.4 Implementar perfiles de aprendizaje

  - Crear estructura LearningProfile con estilos y preferencias de aprendizaje
  - Implementar almacenamiento de resultados de evaluaciones pedagógicas
  - Crear sistema de actualización automática de perfiles basado en interacciones
  - Implementar queries para acceder a perfiles de aprendizaje
  - Escribir tests para gestión de perfiles de aprendizaje
  - _Requerimientos: 12.3, 12.4, 12.6_

- [ ] 6. Desarrollar pallet Reputation System
- [x] 6.1 Crear estructura base del pallet




  - Crear archivo lib.rs en backend/pallets/reputation_system/
  - Implementar estructura básica del pallet con Config trait
  - Crear Cargo.toml con dependencias necesarias
  - Configurar macros básicos del pallet
  - Escribir tests básicos de compilación
  - _Requerimientos: 5.1, 5.2_

- [ ] 6.2 Implementar sistema de calificaciones con expiración

  - Crear estructura Rating con timestamp de expiración (30 días)
  - Implementar extrinsic create_rating para calificar usuarios
  - Crear sistema automático de expiración de calificaciones
  - Implementar cálculo de reputación dinámica priorizando calificaciones recientes
  - Escribir tests para expiración y cálculo de reputación
  - _Requerimientos: 5.1, 5.2, 5.4, 5.5, 5.9_

- [ ] 6.3 Implementar sistema bidireccional de calificaciones

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

  - Crear directorio backend/pallets/marketplace/
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

  - Crear directorio backend/pallets/governance/
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

  - Actualizar backend/runtime/lib.rs para incluir todos los pallets personalizados
  - Configurar parámetros y constantes para cada pallet en el runtime
  - Implementar configuración de pesos para extrinsics
  - Configurar genesis config para inicialización de pallets
  - Escribir tests de integración del runtime completo
  - _Requerimientos: Todos los requerimientos de backend dependen de esta integración_

- [ ] 10. Desarrollar middleware - API Gateway
- [ ] 10.1 Crear estructura base del servicio

  - Crear directorio src/ en middleware/api_gateway/
  - Implementar main.ts con configuración básica de NestJS
  - Crear módulos base (app.module.ts, controllers, services)
  - Configurar TypeScript y dependencias en package.json
  - Escribir tests básicos de compilación y arranque
  - _Requerimientos: 8.1, 8.2_

- [ ] 10.2 Implementar APIs REST/GraphQL básicas

  - Crear servidor NestJS con endpoints REST para usuarios e interacciones
  - Implementar esquema GraphQL para consultas complejas de datos
  - Crear middleware de autenticación y autorización
  - Implementar validación de datos de entrada
  - Escribir tests de integración para APIs
  - _Requerimientos: 8.4, 9.3_

- [ ] 10.3 Implementar puente con parachain

  - Crear servicio ParachainBridge para comunicación con Substrate
  - Implementar pool de conexiones y manejo de transacciones
  - Crear sistema de cola para transacciones fallidas con reintentos
  - Implementar cache de datos frecuentemente consultados
  - Escribir tests para comunicación con parachain
  - _Requerimientos: 8.1, 8.2, 8.6, 8.7_

- [ ] 10.4 Implementar procesamiento en lotes y optimizaciones

  - Crear sistema de batching para múltiples transacciones
  - Implementar paralelización de operaciones independientes
  - Crear sistema de métricas y monitoreo de rendimiento
  - Implementar cache distribuido para escalabilidad
  - Escribir tests de rendimiento y carga
  - _Requerimientos: 8.8_

- [ ] 11. Desarrollar middleware - Servicio de Integración LRS
- [ ] 11.1 Crear estructura base del servicio

  - Crear directorio src/ en middleware/lrs_connector/
  - Crear package.json con dependencias necesarias
  - Implementar main.ts con configuración básica de NestJS
  - Crear módulos base para diferentes adaptadores LRS
  - Escribir tests básicos de compilación
  - _Requerimientos: 3.1, 3.2_

- [ ] 11.2 Implementar transformación de datos LRS

  - Crear transformadores para Learning Locker, SCORM Cloud, Moodle y Canvas
  - Implementar validación de datos xAPI entrantes
  - Crear sistema de mapeo de usuarios entre sistemas
  - Implementar normalización de datos de diferentes fuentes
  - Escribir tests para transformación de datos
  - _Requerimientos: 3.1, 3.2, 8.9_

- [ ] 11.3 Implementar sincronización automática

  - Crear sistema de webhooks para recibir datos en tiempo real
  - Implementar polling para sistemas que no soportan webhooks
  - Crear sistema de detección de cambios y sincronización incremental
  - Implementar manejo de errores y reintentos con backoff exponencial
  - Escribir tests para sincronización automática
  - _Requerimientos: 3.3, 3.4, 3.5_

- [ ] 12. Desarrollar middleware - Servicio de Tutores IA
- [ ] 12.1 Crear estructura base del servicio

  - Crear directorio src/ en middleware/ai_tutor_service/
  - Crear package.json con dependencias para integración de LLMs
  - Implementar main.ts con configuración básica de NestJS
  - Crear módulos base para diferentes proveedores de IA
  - Escribir tests básicos de compilación
  - _Requerimientos: 4.1, 4.2_

- [ ] 12.2 Implementar motor de IA personalizable

  - Integrar modelos de IA (GPT, Claude, etc.) para tutoría personalizada
  - Crear sistema de adaptación de contenido basado en perfiles de aprendizaje
  - Implementar generación de contenido educativo especializado por dominio
  - Crear sistema de verificación de precisión de información
  - Escribir tests para generación de contenido IA
  - _Requerimientos: 4.2, 11.1, 11.2, 11.3, 11.7_

- [ ] 12.3 Implementar sistema de recomendaciones adaptativas

  - Crear algoritmos de recomendación basados en historial de aprendizaje
  - Implementar detección de dificultades y sugerencias de recursos adicionales
  - Crear sistema de escalación a tutores humanos cuando sea necesario
  - Implementar mejora continua basada en feedback de usuarios
  - Escribir tests para sistema de recomendaciones
  - _Requerimientos: 11.4, 11.5, 11.6, 13.1, 13.2, 13.3, 13.4, 13.5, 13.6, 13.7, 13.8_

- [ ] 12.4 Implementar evaluación pedagógica inicial

  - Crear cuestionarios adaptativos para identificar estilos de aprendizaje
  - Implementar análisis de respuestas y generación de perfiles personalizados
  - Crear sistema de reevaluación periódica y actualización de perfiles
  - Implementar construcción gradual de perfiles basada en interacciones
  - Escribir tests para evaluación pedagógica
  - _Requerimientos: 12.1, 12.2, 12.5, 12.7_

- [ ] 13. Desarrollar frontend Flutter - Configuración base
- [ ] 13.1 Implementar estructura base de la aplicación

  - Crear main.dart con configuración básica de la aplicación
  - Implementar estructura de carpetas core/ con constants, errors, network, utils
  - Configurar inyección de dependencias con get_it e injectable
  - Crear configuración base para diferentes entornos (dev, staging, prod)
  - Escribir tests básicos de configuración
  - _Requerimientos: 7.7, 7.8, 7.9_

- [ ] 13.2 Implementar gestión de estado con Bloc

  - Configurar flutter_bloc para gestión de estado reactivo
  - Crear blocs base para autenticación, navegación y datos globales
  - Implementar patrón repository para abstracción de datos
  - Crear servicios de red para comunicación con APIs
  - Escribir tests unitarios para blocs y repositorios
  - _Requerimientos: Todos los requerimientos de frontend dependen de esta base_

- [ ] 14. Desarrollar frontend Flutter - Visualización de pasaporte
- [ ] 14.1 Crear estructura del módulo passport

  - Crear directorio features/passport/ con estructura Clean Architecture
  - Implementar domain/entities/ con modelos de pasaporte e interacciones
  - Crear domain/repositories/ con contratos abstractos
  - Implementar domain/usecases/ para casos de uso del pasaporte
  - Escribir tests unitarios para entidades y casos de uso
  - _Requerimientos: 1.1, 1.2, 1.3_

- [ ] 14.2 Implementar línea de tiempo vertical

  - Crear widget TimelineView con scroll vertical optimizado para móvil
  - Implementar visualización cronológica de interacciones de aprendizaje
  - Crear diferentes tipos de items para cursos, clases, tutorías e interacciones
  - Implementar sistema de expansión/colapso para sesiones tutoriales
  - Escribir tests de widgets para línea de tiempo
  - _Requerimientos: 7.1, 7.2, 7.5_

- [ ] 14.3 Implementar navegación jerárquica

  - Crear sistema de navegación entre niveles de jerarquía educativa
  - Implementar badges y etiquetas para mostrar relaciones jerárquicas
  - Crear filtros para diferentes tipos de experiencias de aprendizaje
  - Implementar búsqueda dentro del historial de aprendizaje
  - Escribir tests para navegación jerárquica
  - _Requerimientos: 7.3, 7.4, 17.9, 17.10_

- [ ] 14.4 Implementar funcionalidades de compartir

  - Crear generador de certificados visuales verificables
  - Implementar sistema de compartir logros específicos en redes sociales
  - Crear enlaces verificables para compartir pasaportes completos
  - Implementar configuraciones de privacidad granulares
  - Escribir tests para funcionalidades de compartir
  - _Requerimientos: 7.6, 1.5, 10.3_

- [ ] 15. Desarrollar frontend Flutter - Interacción con tutores IA
- [ ] 15.1 Crear estructura del módulo tutoring

  - Crear directorio features/tutoring/ con estructura Clean Architecture
  - Implementar domain/entities/ con modelos de sesiones y tutores
  - Crear domain/repositories/ con contratos para servicios de tutoría
  - Implementar domain/usecases/ para casos de uso de tutoría
  - Escribir tests unitarios para entidades y casos de uso
  - _Requerimientos: 4.1, 4.2_

- [ ] 15.2 Implementar interfaz de chat con IA

  - Crear widget de chat conversacional para interacción con tutores IA
  - Implementar diferentes tipos de mensajes (texto, imágenes, diagramas)
  - Crear sistema de sugerencias y respuestas rápidas
  - Implementar indicadores de typing y estado de conexión
  - Escribir tests para interfaz de chat
  - _Requerimientos: 4.1, 11.1_

- [ ] 15.3 Implementar personalización basada en perfil

  - Crear sistema de adaptación de UI basado en estilo de aprendizaje
  - Implementar contenido visual para aprendices visuales
  - Crear elementos interactivos para aprendices kinestésicos
  - Implementar opciones de audio para aprendices auditivos
  - Escribir tests para personalización de UI
  - _Requerimientos: 4.2, 11.2, 12.4_

- [ ] 15.4 Implementar evaluación pedagógica inicial

  - Crear wizard de evaluación inicial para nuevos usuarios
  - Implementar diferentes tipos de preguntas (opción múltiple, escenarios, escalas)
  - Crear visualización de resultados de evaluación
  - Implementar sistema de reevaluación periódica opcional
  - Escribir tests para evaluación pedagógica
  - _Requerimientos: 12.1, 12.2, 12.5, 12.7_

- [ ] 16. Desarrollar frontend Flutter - Marketplace de espacios
- [ ] 16.1 Crear estructura del módulo marketplace

  - Crear directorio features/marketplace/ con estructura Clean Architecture
  - Implementar domain/entities/ con modelos de espacios y reservas
  - Crear domain/repositories/ con contratos para servicios de marketplace
  - Implementar domain/usecases/ para casos de uso de marketplace
  - Escribir tests unitarios para entidades y casos de uso
  - _Requerimientos: 15.1, 15.2_

- [ ] 16.2 Implementar búsqueda y filtrado de espacios

  - Crear interfaz de búsqueda de espacios de aprendizaje por ubicación
  - Implementar filtros por capacidad, amenidades y certificaciones
  - Crear filtros especiales para seguridad infantil y accesibilidad
  - Implementar mapa interactivo para visualizar espacios cercanos
  - Escribir tests para búsqueda y filtrado
  - _Requerimientos: 15.1, 15.5, 15.7_

- [ ] 16.3 Implementar sistema de reservas

  - Crear interfaz para seleccionar fechas y horarios disponibles
  - Implementar calendario de disponibilidad de espacios
  - Crear sistema de confirmación y pago de reservas
  - Implementar notificaciones de recordatorio de reservas
  - Escribir tests para sistema de reservas
  - _Requerimientos: 15.4_

- [ ] 16.4 Implementar calificaciones y reseñas de espacios

  - Crear interfaz para calificar espacios en múltiples dimensiones
  - Implementar sistema de reseñas con comentarios detallados
  - Crear visualización de calificaciones promedio y distribución
  - Implementar sistema de reportes para espacios problemáticos
  - Escribir tests para calificaciones de espacios
  - _Requerimientos: 15.6, 15.8_

- [ ] 17. Desarrollar frontend Flutter - Sistema de reputación
- [ ] 17.1 Crear estructura del módulo reputation

  - Crear directorio features/reputation/ con estructura Clean Architecture
  - Implementar domain/entities/ con modelos de calificaciones y reputación
  - Crear domain/repositories/ con contratos para servicios de reputación
  - Implementar domain/usecases/ para casos de uso de reputación
  - Escribir tests unitarios para entidades y casos de uso
  - _Requerimientos: 5.1, 5.2_

- [ ] 17.2 Implementar visualización de reputación

  - Crear widgets para mostrar puntuaciones de reputación actuales e históricas
  - Implementar gráficos de evolución de reputación en el tiempo
  - Crear badges y logros basados en reputación
  - Implementar comparación de reputación reciente vs histórica
  - Escribir tests para visualización de reputación
  - _Requerimientos: 5.5, 5.9_

- [ ] 17.3 Implementar sistema de calificaciones

  - Crear interfaz para calificar tutores y estudiantes después de sesiones
  - Implementar sistema de comentarios con respuestas
  - Crear formularios de calificación multidimensional
  - Implementar sistema de calificaciones entre pares para grupos
  - Escribir tests para sistema de calificaciones
  - _Requerimientos: 5.1, 5.3, 5.6, 5.7_

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

  - Crear Dockerfiles para cada servicio de middleware
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
