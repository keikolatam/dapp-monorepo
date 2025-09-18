# Documento de Requerimientos - Frontend Flutter con Clean Architecture

## Introducción

Este spec define la arquitectura del frontend Flutter para Keiko DApp, implementando Clean Architecture con Riverpod para gestión de estado. La aplicación Flutter será multiplataforma (web y móvil) y se comunicará exclusivamente con el API Gateway GraphQL del backend.

La arquitectura seguirá los principios de Clean Architecture con separación clara de responsabilidades en capas, usando Riverpod como solución de gestión de estado y inyección de dependencias.

## Requerimientos

### Requerimiento 1: Arquitectura por Capas con Riverpod

**Historia de Usuario:** Como desarrollador Flutter, quiero una arquitectura limpia y escalable con Riverpod, para mantener el código organizado y testeable a medida que la aplicación crece.

#### Criterios de Aceptación

1. CUANDO se estructura la aplicación ENTONCES el sistema DEBERÁ implementar Clean Architecture con 4 capas claramente definidas
2. CUANDO se gestione el estado ENTONCES el sistema DEBERÁ usar Riverpod como única solución de gestión de estado
3. CUANDO se inyecten dependencias ENTONCES el sistema DEBERÁ usar Riverpod providers para inyección de dependencias
4. CUANDO se organice el código ENTONCES el sistema DEBERÁ seguir feature-first organization con módulos independientes
5. CUANDO se implementen providers ENTONCES el sistema DEBERÁ usar StateNotifier y AsyncNotifier para lógica de negocio compleja

### Requerimiento 2: Capa de Presentación (UI Layer)

**Historia de Usuario:** Como usuario, quiero una interfaz intuitiva y responsiva, para interactuar fácilmente con mi pasaporte de aprendizaje desde cualquier dispositivo.

#### Criterios de Aceptación

1. CUANDO se rendericen widgets ENTONCES el sistema DEBERÁ usar ConsumerWidget y Consumer para consumir Riverpod providers
2. CUANDO se muestren estados de carga ENTONCES el sistema DEBERÁ usar AsyncValue para manejar estados asíncronos
3. CUANDO se navegue entre pantallas ENTONCES el sistema DEBERÁ usar go_router con navegación declarativa
4. CUANDO se muestren errores ENTONCES el sistema DEBERÁ tener manejo consistente de errores en toda la UI
5. CUANDO se adapte a diferentes pantallas ENTONCES el sistema DEBERÁ ser completamente responsivo (móvil, tablet, web)

### Requerimiento 3: Capa de Lógica de Negocio (Business Logic Layer)

**Historia de Usuario:** Como desarrollador, quiero lógica de negocio centralizada y testeable, para mantener la consistencia de reglas de negocio en toda la aplicación.

#### Criterios de Aceptación

1. CUANDO se implemente lógica de negocio ENTONCES el sistema DEBERÁ usar StateNotifier para estados complejos
2. CUANDO se manejen operaciones asíncronas ENTONCES el sistema DEBERÁ usar AsyncNotifier para operaciones async
3. CUANDO se validen datos ENTONCES el sistema DEBERÁ implementar validación en la capa de lógica de negocio
4. CUANDO se transformen datos ENTONCES el sistema DEBERÁ mapear entre DTOs y entidades de dominio
5. CUANDO se manejen casos de uso ENTONCES el sistema DEBERÁ implementar casos de uso como providers independientes

### Requerimiento 4: Capa de Repositorio (Repository Layer)

**Historia de Usuario:** Como desarrollador, quiero abstracción de fuentes de datos, para poder cambiar implementaciones sin afectar la lógica de negocio.

#### Criterios de Aceptación

1. CUANDO se acceda a datos remotos ENTONCES el sistema DEBERÁ usar repositorios como Riverpod providers
2. CUANDO se comunique con el backend ENTONCES el sistema DEBERÁ usar exclusivamente GraphQL client con autenticación JWT
3. CUANDO se cacheen datos ENTONCES el sistema DEBERÁ implementar caché local con Hive
4. CUANDO se manejen errores de red ENTONCES el sistema DEBERÁ implementar retry logic y manejo de errores
5. CUANDO se sincronicen datos ENTONCES el sistema DEBERÁ usar GraphQL subscriptions sobre WSS para tiempo real
6. CUANDO se autentique ENTONCES el sistema DEBERÁ integrar JWT tokens en todas las operaciones de repositorio
7. CUANDO se maneje Proof-of-Humanity ENTONCES el sistema DEBERÁ usar repositorios especializados con validación de identidad

### Requerimiento 5: Capa de Fuentes de Datos (Data Sources Layer)

**Historia de Usuario:** Como desarrollador, quiero fuentes de datos bien definidas, para separar la lógica de acceso a datos de la lógica de negocio.

#### Criterios de Aceptación

1. CUANDO se implemente GraphQL client ENTONCES el sistema DEBERÁ usar graphql_flutter como provider con autenticación JWT
2. CUANDO se almacenen datos localmente ENTONCES el sistema DEBERÁ usar Hive como provider para caché
3. CUANDO se manejen tokens de autenticación ENTONCES el sistema DEBERÁ usar flutter_secure_storage como provider para JWT
4. CUANDO se configuren interceptors ENTONCES el sistema DEBERÁ implementar interceptors para autenticación JWT y logging
5. CUANDO se manejen subscriptions ENTONCES el sistema DEBERÁ mantener conexiones WSS para tiempo real
6. CUANDO se implemente WebSocket ENTONCES el sistema DEBERÁ usar web_socket_channel con WSS y autenticación JWT
7. CUANDO se maneje Proof-of-Humanity ENTONCES el sistema DEBERÁ usar fuentes de datos especializadas con validación de identidad
8. CUANDO se implemente JWT ENTONCES el sistema DEBERÁ usar jwt_decoder para validación y decodificación de tokens

### Requerimiento 6: Gestión de Estado Global

**Historia de Usuario:** Como usuario, quiero que la aplicación mantenga mi estado de sesión y datos, para una experiencia fluida sin pérdida de información.

#### Criterios de Aceptación

1. CUANDO se autentique el usuario ENTONCES el sistema DEBERÁ mantener estado de autenticación global
2. CUANDO se navegue entre pantallas ENTONCES el sistema DEBERÁ preservar estado relevante
3. CUANDO se actualicen datos ENTONCES el sistema DEBERÁ sincronizar estado en toda la aplicación
4. CUANDO se cierre la aplicación ENTONCES el sistema DEBERÁ persistir estado crítico localmente
5. CUANDO se detecten cambios remotos ENTONCES el sistema DEBERÁ actualizar estado local automáticamente

### Requerimiento 7: Visualización Cronológica del Pasaporte de Aprendizaje

**Historia de Usuario:** Como usuario, quiero una aplicación Flutter que funcione tanto en web como en dispositivos móviles para visualizar mi pasaporte de aprendizaje como una línea de tiempo vertical, para poder acceder y comprender fácilmente mi progreso educativo desde cualquier dispositivo.

#### Criterios de Aceptación

1. CUANDO un usuario accede a la aplicación desde web o móvil ENTONCES el sistema DEBERÁ mostrar una visualización cronológica vertical (línea de tiempo) de su pasaporte de aprendizaje, optimizada para scroll vertical en dispositivos móviles
2. CUANDO se visualiza el pasaporte ENTONCES el sistema DEBERÁ agrupar visualmente las interacciones de aprendizaje que pertenecen a una misma sesión tutorial
3. CUANDO existen diferentes tipos de interacciones ENTONCES el sistema DEBERÁ diferenciar visualmente entre:
   - Sesiones tutoriales con educadores humanos
   - Sesiones con tutores IA
   - Interacciones de aprendizaje individuales (preguntas puntuales a IA)
   - Sesiones de estudio personal
4. CUANDO se selecciona una sesión tutorial en la línea de tiempo ENTONCES el sistema DEBERÁ expandir la vista para mostrar todas las interacciones de aprendizaje contenidas en ella
5. CUANDO se selecciona una interacción específica ENTONCES el sistema DEBERÁ mostrar todos los detalles y evidencias asociadas
6. CUANDO un usuario quiere compartir logros específicos ENTONCES el sistema DEBERÁ generar certificados visuales verificables
7. CUANDO se accede desde diferentes dispositivos ENTONCES el sistema DEBERÁ mantener sincronización de datos y experiencia consistente, adaptando la visualización al tamaño de pantalla
8. CUANDO la aplicación se ejecuta en móvil ENTONCES el sistema DEBERÁ aprovechar las capacidades nativas del dispositivo como notificaciones push
9. CUANDO la aplicación se ejecuta en web ENTONCES el sistema DEBERÁ ser completamente funcional sin necesidad de instalación adicional

### Requerimiento 8: Comunicación Exclusiva con API Gateway GraphQL

**Historia de Usuario:** Como desarrollador de frontend, quiero que la aplicación Flutter se comunique exclusivamente con el API Gateway GraphQL, para tener una interfaz unificada y type-safe sin conocer la arquitectura interna de microservicios.

#### Criterios de Aceptación

1. CUANDO la aplicación Flutter se comunica con el backend ENTONCES el sistema DEBERÁ usar EXCLUSIVAMENTE GraphQL queries, mutations y subscriptions a través del API Gateway middleware
2. CUANDO se requieran datos en tiempo real ENTONCES el sistema DEBERÁ usar GraphQL subscriptions que se alimentan de eventos Redis Streams
3. CUANDO el frontend necesite datos de múltiples microservicios ENTONCES el API Gateway DEBERÁ orquestar las llamadas gRPC y devolver una respuesta GraphQL unificada
4. CUANDO se ejecuten mutations GraphQL ENTONCES el sistema DEBERÁ manejar transacciones distribuidas a través del API Gateway
5. CUANDO se manejen errores de red ENTONCES el sistema DEBERÁ implementar retry automático y fallbacks con manejo de errores GraphQL
6. CUANDO se optimice rendimiento ENTONCES el sistema DEBERÁ implementar caché de queries GraphQL y paginación

### Requerimiento 9: Testing y Calidad

**Historia de Usuario:** Como desarrollador, quiero código bien testeado y mantenible, para garantizar la calidad y facilitar el mantenimiento.

#### Criterios de Aceptación

1. CUANDO se testeen providers ENTONCES el sistema DEBERÁ permitir override de providers para testing
2. CUANDO se testeen widgets ENTONCES el sistema DEBERÁ usar ProviderScope para tests de widgets
3. CUANDO se testeen casos de uso ENTONCES el sistema DEBERÁ mockear repositorios usando Riverpod
4. CUANDO se ejecuten tests ENTONCES el sistema DEBERÁ tener cobertura mínima del 80%
5. CUANDO se integre CI/CD ENTONCES el sistema DEBERÁ ejecutar tests automáticamente

### Requerimiento 10: Rendimiento y Escalabilidad

**Historia de Usuario:** Como usuario, quiero una aplicación rápida y fluida, para una experiencia de usuario óptima en cualquier dispositivo.

#### Criterios de Aceptación

1. CUANDO se rendericen listas grandes ENTONCES el sistema DEBERÁ usar lazy loading y virtualización
2. CUANDO se cacheen datos ENTONCES el sistema DEBERÁ implementar caché inteligente con invalidación
3. CUANDO se optimicen rebuilds ENTONCES el sistema DEBERÁ usar Riverpod select para optimizar renders
4. CUANDO se manejen imágenes ENTONCES el sistema DEBERÁ implementar caché de imágenes y lazy loading
5. CUANDO se monitoree rendimiento ENTONCES el sistema DEBERÁ implementar métricas de rendimiento

### Requerimiento 11: Sistema de Calificación y Reputación en Frontend

**Historia de Usuario:** Como estudiante o tutor, quiero una interfaz intuitiva para calificar experiencias educativas y visualizar reputación, para mantener un sistema de feedback constante y transparente.

#### Criterios de Aceptación

1. CUANDO un estudiante completa una interacción de aprendizaje ENTONCES el sistema DEBERÁ mostrar una interfaz para calificar la experiencia con puntuaciones y comentarios detallados
2. CUANDO un tutor completa una sesión educativa ENTONCES el sistema DEBERÁ permitirle también calificar al estudiante a través de la interfaz Flutter
3. CUANDO se visualiza un perfil ENTONCES el sistema DEBERÁ mostrar tanto la reputación histórica como la reputación reciente (últimos 30 días) con indicadores visuales claros
4. CUANDO un usuario recibe un comentario ENTONCES el sistema DEBERÁ mostrar notificaciones y permitir responder a ese comentario
5. CUANDO estudiantes participan en actividades grupales ENTONCES el sistema DEBERÁ proporcionar interfaces para calificaciones entre pares
6. CUANDO se consulta reputación ENTONCES el sistema DEBERÁ mostrar métricas visuales que prioricen calificaciones más recientes

### Requerimiento 12: Evaluación Pedagógica Inicial

**Historia de Usuario:** Como estudiante nuevo en la plataforma, quiero realizar una evaluación pedagógica inicial opcional a través de la aplicación Flutter, para recibir contenido y metodologías personalizadas desde el primer momento.

#### Criterios de Aceptación

1. CUANDO un usuario se registra en la plataforma ENTONCES la aplicación Flutter DEBERÁ ofrecer la opción de realizar una evaluación pedagógica inicial con interfaz intuitiva
2. CUANDO un usuario completa la evaluación pedagógica ENTONCES la aplicación DEBERÁ mostrar el perfil de aprendizaje generado de manera visual y comprensible
3. CUANDO se genera un perfil de aprendizaje ENTONCES la aplicación DEBERÁ permitir visualizar y editar las preferencias de aprendizaje
4. CUANDO un usuario desea actualizar su perfil ENTONCES la aplicación DEBERÁ permitir realizar nuevas evaluaciones periódicas con progreso guardado
5. CUANDO se detectan cambios en el comportamiento de aprendizaje ENTONCES la aplicación DEBERÁ mostrar sugerencias para reevaluación del perfil
6. SI un usuario decide no realizar la evaluación inicial ENTONCES la aplicación DEBERÁ mostrar cómo se construye gradualmente el perfil basado en interacciones

### Requerimiento 13: Planes de Acción Tutorial Adaptativos

**Historia de Usuario:** Como estudiante con un ritmo de aprendizaje variable, quiero que la aplicación Flutter me muestre planes de acción tutorial adaptativos sin necesidad de un plan de estudios predefinido, para poder aprender de manera asíncrona según mis intereses y disponibilidad.

#### Criterios de Aceptación

1. CUANDO un usuario interactúa con contenido educativo ENTONCES la aplicación DEBERÁ mostrar patrones de interés y compromiso de manera visual
2. CUANDO se acumulan suficientes datos de interacción ENTONCES la aplicación DEBERÁ mostrar recomendaciones de aprendizaje personalizadas en tiempo real
3. CUANDO un usuario completa una actividad ENTONCES la aplicación DEBERÁ sugerir el siguiente paso lógico con explicación del por qué
4. CUANDO un usuario retoma su aprendizaje ENTONCES la aplicación DEBERÁ proporcionar un resumen contextual visual y recomendaciones actualizadas
5. CUANDO un usuario muestra interés en un nuevo tema ENTONCES la aplicación DEBERÁ mostrar cómo se integra en su plan adaptativo actual
6. CUANDO se detectan brechas de conocimiento ENTONCES la aplicación DEBERÁ sugerir recursos complementarios con visualización clara de la brecha
7. CUANDO un usuario aprende de manera asíncrona ENTONCES la aplicación DEBERÁ mantener coherencia visual y progresión lógica entre sesiones discontinuas

### Requerimiento 14: Marketplace de Espacios de Aprendizaje

**Historia de Usuario:** Como estudiante o padre de familia, quiero acceder desde la aplicación Flutter a espacios físicos seguros y autorizados para recibir tutorías presenciales, para garantizar un ambiente de aprendizaje protegido.

#### Criterios de Aceptación

1. CUANDO un estudiante necesita tutorías presenciales ENTONCES la aplicación DEBERÁ mostrar opciones de espacios de coworking y centros de estudio autorizados cercanos con mapa interactivo
2. CUANDO se buscan espacios ENTONCES la aplicación DEBERÁ mostrar información de credenciales, seguridad y condiciones de cada espacio
3. CUANDO un tutor nuevo ofrece servicios presenciales ENTONCES la aplicación DEBERÁ recomendar prioritariamente espacios seguros con indicadores visuales claros
4. CUANDO se reserva un espacio ENTONCES la aplicación DEBERÁ gestionar la disponibilidad, costos y confirmación con interfaz intuitiva
5. CUANDO un estudiante tiene necesidades especiales ENTONCES la aplicación DEBERÁ filtrar espacios con requisitos de accesibilidad usando filtros visuales
6. CUANDO se completa una sesión ENTONCES la aplicación DEBERÁ permitir calificar tanto al tutor como al espacio con formularios separados
7. CUANDO padres buscan opciones para menores ENTONCES la aplicación DEBERÁ mostrar espacios con certificaciones de seguridad infantil con badges visuales

### Requerimiento 15: Jerarquía de Experiencias de Aprendizaje

**Historia de Usuario:** Como estudiante, quiero que la aplicación Flutter visualice una jerarquía completa de experiencias educativas (cursos, clases, tutorías e interacciones), para poder navegar y organizar mi aprendizaje en diferentes niveles de granularidad.

#### Criterios de Aceptación

1. CUANDO se visualiza un curso completo ENTONCES la aplicación DEBERÁ mostrar una estructura expandible que contenga múltiples clases relacionadas
2. CUANDO se navega una clase ENTONCES la aplicación DEBERÁ mostrar las interacciones de aprendizaje contenidas manteniendo referencia visual al curso
3. CUANDO se realiza un examen ENTONCES la aplicación DEBERÁ mostrar cada pregunta como una interacción individual pero agrupada visualmente
4. CUANDO se visualiza el historial ENTONCES la aplicación DEBERÁ permitir navegar entre diferentes niveles de granularidad con breadcrumbs claros
5. CUANDO se analiza progreso ENTONCES la aplicación DEBERÁ mostrar métricas tanto a nivel de cursos completos como de interacciones individuales
6. CUANDO se exportan datos ENTONCES la aplicación DEBERÁ mantener la jerarquía visual entre cursos, clases, tutorías e interacciones

### Requerimiento 16: Autenticación Segura con JWT y WebSocket Secure (WSS)

**Historia de Usuario:** Como usuario de Keiko, quiero que mi autenticación y comunicación sean completamente seguras, para proteger mis datos de Proof-of-Humanity y LearningInteractions de accesos no autorizados.

#### Criterios de Aceptación

1. CUANDO un usuario se autentica ENTONCES el sistema DEBERÁ usar JWT tokens con refresh token automático para mantener sesiones seguras
2. CUANDO se comunica con el backend ENTONCES el sistema DEBERÁ usar WebSocket Secure (WSS) para todas las comunicaciones en tiempo real
3. CUANDO se almacenan tokens ENTONCES el sistema DEBERÁ usar secure storage para proteger tokens de autenticación localmente
4. CUANDO se valida Proof-of-Humanity ENTONCES el sistema DEBERÁ incluir claims específicos en JWT para verificación de identidad
5. CUANDO se pierde la conexión WSS ENTONCES el sistema DEBERÁ implementar reconexión automática con reautenticación
6. CUANDO se detecta token expirado ENTONCES el sistema DEBERÁ refrescar automáticamente el token sin interrumpir la experiencia del usuario
7. CUANDO se manejan LearningInteractions ENTONCES el sistema DEBERÁ incluir claims de permisos específicos en JWT
8. CUANDO se implementa interceptor HTTP ENTONCES el sistema DEBERÁ agregar automáticamente JWT en headers de todas las requests
9. CUANDO se establece conexión WSS ENTONCES el sistema DEBERÁ incluir JWT en headers de WebSocket para autenticación
10. CUANDO se detectan errores de autenticación ENTONCES el sistema DEBERÁ manejar logout automático y redirección a login

### Requerimiento 17: Gestión de Estado de Autenticación con Riverpod

**Historia de Usuario:** Como desarrollador Flutter, quiero una gestión de estado de autenticación centralizada y reactiva, para mantener consistencia en toda la aplicación y facilitar el testing.

#### Criterios de Aceptación

1. CUANDO se implementa autenticación ENTONCES el sistema DEBERÁ usar StateNotifier para manejar estado de autenticación global
2. CUANDO se valida JWT ENTONCES el sistema DEBERÁ usar AsyncNotifier para operaciones asíncronas de validación
3. CUANDO se refresca token ENTONCES el sistema DEBERÁ implementar retry logic con exponential backoff
4. CUANDO se maneja logout ENTONCES el sistema DEBERÁ limpiar todos los estados relacionados con autenticación
5. CUANDO se testea autenticación ENTONCES el sistema DEBERÁ permitir override de providers para mocking
6. CUANDO se persiste sesión ENTONCES el sistema DEBERÁ usar SharedPreferences con encriptación para datos sensibles
7. CUANDO se detecta cambio de estado ENTONCES el sistema DEBERÁ notificar a todos los widgets suscritos automáticamente
8. CUANDO se maneja Proof-of-Humanity ENTONCES el sistema DEBERÁ incluir validación específica en el estado de autenticación

### Requerimiento 18: Comunicación Segura en Tiempo Real

**Historia de Usuario:** Como usuario de Keiko, quiero recibir actualizaciones en tiempo real de mis LearningInteractions de forma segura, para mantenerme sincronizado con mi progreso educativo sin comprometer la seguridad.

#### Criterios de Aceptación

1. CUANDO se establece conexión WSS ENTONCES el sistema DEBERÁ verificar certificados SSL y validar identidad del servidor
2. CUANDO se envían mensajes ENTONCES el sistema DEBERÁ encriptar datos sensibles antes de transmisión
3. CUANDO se reciben LearningInteractions ENTONCES el sistema DEBERÁ validar integridad y autenticidad de los datos
4. CUANDO se pierde conexión ENTONCES el sistema DEBERÁ implementar queue de mensajes para no perder datos
5. CUANDO se reconecta ENTONCES el sistema DEBERÁ sincronizar estado perdido durante desconexión
6. CUANDO se detectan errores de red ENTONCES el sistema DEBERÁ mostrar indicadores visuales de estado de conexión
7. CUANDO se manejan subscriptions GraphQL ENTONCES el sistema DEBERÁ usar WSS como transporte seguro
8. CUANDO se implementa heartbeat ENTONCES el sistema DEBERÁ mantener conexión viva con ping/pong seguro
9. CUANDO se optimiza rendimiento ENTONCES el sistema DEBERÁ implementar compresión de mensajes para WSS
10. CUANDO se maneja Proof-of-Humanity ENTONCES el sistema DEBERÁ usar canales WSS separados para datos críticos

## Dependencias Requeridas

### Dependencias Core
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Gestión de Estado
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # Navegación
  go_router: ^12.1.3
  
  # HTTP y GraphQL
  graphql_flutter: ^5.1.2
  http: ^1.1.0
  
  # WebSocket
  web_socket_channel: ^2.4.0
  
  # Autenticación y Seguridad
  jwt_decoder: ^2.0.1
  flutter_secure_storage: ^9.0.0
  crypto: ^3.0.3
  
  # Almacenamiento Local
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # UI y Utilidades
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  intl: ^0.19.0
  
  # Testing
  mockito: ^5.4.4
  build_runner: ^2.4.7
```

### Dependencias de Desarrollo
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code Generation
  riverpod_generator: ^2.3.9
  hive_generator: ^2.0.1
  json_annotation: ^4.8.1
  json_serializable: ^6.7.1
  
  # Testing
  mockito: ^5.4.4
  build_runner: ^2.4.7
  
  # Linting
  flutter_lints: ^3.0.1
  very_good_analysis: ^5.1.0
```

## Arquitectura de Seguridad

### Flujo de Autenticación
1. **Login con Proof-of-Humanity** → Validación de identidad
2. **Emisión de JWT** → Token con claims específicos de Keiko
3. **Almacenamiento Seguro** → flutter_secure_storage
4. **Interceptor HTTP** → Agregar JWT automáticamente
5. **WebSocket WSS** → Conexión segura con autenticación
6. **Refresh Automático** → Mantener sesión activa
7. **Logout Seguro** → Limpiar todos los datos sensibles

### Claims JWT Específicos para Keiko
```json
{
  "sub": "user_id",
  "proof_of_humanity": {
    "verified": true,
    "method": "biometric",
    "timestamp": "2024-01-01T00:00:00Z"
  },
  "learning_permissions": {
    "can_create_interactions": true,
    "can_rate_tutors": true,
    "can_access_marketplace": true
  },
  "life_learning_passport": {
    "level": "intermediate",
    "verified_skills": ["programming", "mathematics"]
  }
}
```

### Configuración WSS
- **Certificados SSL** → Validación de identidad del servidor
- **Headers de Autenticación** → JWT en cada conexión
- **Reconexión Automática** → Con reautenticación
- **Queue de Mensajes** → Para no perder datos durante desconexiones
- **Heartbeat** → Mantener conexión viva
- **Compresión** → Optimizar rendimiento