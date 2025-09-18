# Documento de Requerimientos

## Introducción

Keiko es una red social educativa descentralizada (DApp) construida como un monorepo que integra un backend desarrollado en Rust con contratos inteligentes en Cairo sobre Starknet y un frontend multiplataforma desarrollado en Flutter. Su propósito es convertir el aprendizaje en capital humano verificable e interoperable en tiempo real. La plataforma permite a cualquier individuo construir y demostrar su Pasaporte de Aprendizaje de Vida (LifeLearningPassport) en blockchain, mediante interacciones de aprendizaje atómicas (LearningInteractions) compatibles con el estándar xAPI (Tin Can). El objetivo principal es reemplazar las certificaciones tradicionales con evidencia infalsificable de aprendizaje, evaluada por múltiples actores y almacenada de forma descentralizada.

La arquitectura del proyecto se organiza en cinco capas principales con estructura de carpetas correspondiente:

- **Keikochain Layer** (`appchain/`): Contratos Cairo en Keikochain (Starknet Appchain) para almacenamiento inmutable y consenso
- **gRPC Gateway Layer** (`grpc-gateway/`): Traductor Rust ↔ Cairo que comunica microservicios con Keikochain (Starknet Appchain)
- **Service Layer** (`services/`): Microservicios Rust con comunicación gRPC, cache PostgreSQL local, y eventos Redis Streams
- **API Layer** (`api-gateway/`): API Gateway GraphQL que traduce queries del frontend a llamadas gRPC y orquesta respuestas
- **Frontend Layer** (`frontend/`): Aplicación Flutter multiplataforma que se comunica exclusivamente via GraphQL

**Flujo de Datos Híbrido:**

- **Escritura**: Flutter → GraphQL → Microservicio → gRPC Gateway → Keikochain Contract → Evento Redis → GraphQL Subscription
- **Lectura**: Flutter → GraphQL → Microservicio → Cache/DB local → (fallback) gRPC Gateway → Keikochain Contract
- **Tiempo Real**: Keikochain Contract → gRPC Gateway → Microservicio → Redis Streams → API Gateway → GraphQL Subscription → Flutter

## Requerimientos

### Requerimiento 1: Pasaporte de Aprendizaje de Vida

**Componente:** Backend + Frontend Móvil

**Historia de Usuario:** Como usuario, quiero tener un Pasaporte de Aprendizaje de Vida en blockchain, para poder demostrar mi conocimiento y habilidades de manera verificable e infalsificable desde mi dispositivo móvil.

#### Criterios de Aceptación

1. CUANDO un usuario se registra en la plataforma ENTONCES el sistema DEBERÁ crear un nuevo LifeLearningPassport asociado a su identidad blockchain y humanity_proof_key biométrica
2. CUANDO se registra una nueva interacción de aprendizaje ENTONCES el sistema DEBERÁ actualizar el LifeLearningPassport del usuario correspondiente en Keikochain usando firma Ed25519 derivada de la humanity_proof_key
3. CUANDO un usuario solicita ver su pasaporte desde la aplicación móvil ENTONCES el sistema DEBERÁ mostrar todas sus interacciones de aprendizaje registradas en orden cronológico
4. CUANDO un tercero solicita verificar el pasaporte de un usuario ENTONCES el sistema DEBERÁ permitir la verificación criptográfica de la autenticidad de los datos almacenados en blockchain y la humanidad del usuario
5. CUANDO un usuario quiere compartir su pasaporte desde la aplicación móvil ENTONCES el sistema DEBERÁ generar un enlace verificable que incluya verificación de humanidad y pueda ser compartido con terceros

**Nota:** Para detalles de implementación de visualización móvil del pasaporte, ver Spec 02-flutter-frontend-architecture

### Requerimiento 2: Interacciones de Aprendizaje Atómicas

**Componente:** Backend

**Historia de Usuario:** Como educador o plataforma de aprendizaje, quiero registrar interacciones de aprendizaje atómicas compatibles con xAPI en la blockchain, para crear un registro inmutable y granular de cada actividad educativa individual.

#### Criterios de Aceptación

1. CUANDO se envía una interacción de aprendizaje en formato xAPI ENTONCES el sistema DEBERÁ validar su estructura y contenido.
2. CUANDO una interacción de aprendizaje es válida ENTONCES el sistema DEBERÁ almacenarla en la blockchain mediante el contrato Cairo learning_interactions usando firma Ed25519 del usuario.
3. CUANDO una interacción contiene archivos adjuntos o evidencias ENTONCES el sistema DEBERÁ almacenar referencias a estos archivos de manera segura.
4. CUANDO se registra una interacción ENTONCES el sistema DEBERÁ emitir un evento que pueda ser capturado por sistemas externos.
5. SI una interacción no cumple con el estándar xAPI ENTONCES el sistema DEBERÁ rechazar la transacción y notificar el error.
6. CUANDO se registra una pregunta en un examen o quiz ENTONCES el sistema DEBERÁ tratarla como una interacción atómica individual firmada con la humanity_proof_key del usuario.
7. CUANDO se registra una respuesta a una pregunta ENTONCES el sistema DEBERÁ tratarla como una interacción atómica individual firmada con la humanity_proof_key del usuario.
8. CUANDO se registra un ejercicio práctico ENTONCES el sistema DEBERÁ tratarlo como una interacción atómica individual firmada con la humanity_proof_key del usuario.
9. CUANDO se registra una discusión o participación en clase ENTONCES el sistema DEBERÁ tratarla como una interacción atómica individual firmada con la humanity_proof_key del usuario.
10. CUANDO se registra una evaluación o calificación ENTONCES el sistema DEBERÁ tratarla como una interacción atómica individual firmada con la humanity_proof_key del usuario.

### Requerimiento 3: Integración con Learning Record Stores (LRS) y SCORM

**Componente:** API Gateway + Microservicios

**Historia de Usuario:** Como institución educativa, quiero integrar mi Learning Record Store existente y contenido SCORM con Keiko, para transferir automáticamente los registros de aprendizaje a los microservicios y a Keikochain.

#### Criterios de Aceptación

1. CUANDO un LRS compatible envía datos via REST webhook ENTONCES el API Gateway DEBERÁ procesar y validar estos datos xAPI
2. CUANDO se configura la integración con un LRS ENTONCES el sistema DEBERÁ proporcionar endpoints REST y credenciales de webhook
3. CUANDO se reciben datos de Learning Locker ENTONCES el API Gateway DEBERÁ transformarlos y enviarlos via gRPC al Learning Service
4. CUANDO se importa contenido SCORM desde Moodle ENTONCES el API Gateway DEBERÁ procesar paquetes SCORM y convertirlos automáticamente a statements xAPI estándar
5. CUANDO se procesa un paquete SCORM ENTONCES el sistema DEBERÁ extraer metadatos, actividades y progreso para convertirlos a statements xAPI y almacenarlos en Keikochain
6. SI la conexión con microservicios falla ENTONCES el API Gateway DEBERÁ almacenar los datos en Redis Streams para reintento
7. CUANDO se actualiza el LRS ENTONCES el sistema DEBERÁ sincronizar los nuevos registros via eventos de dominio en Redis Streams
8. CUANDO se importa contenido desde LRS basados en SCORM ENTONCES el sistema DEBERÁ transformar automáticamente los datos a formato xAPI antes de almacenarlos en Keikochain, priorizando la compatibilidad con xAPI sobre SCORM

### Requerimiento 4: Ecosistema de Aprendizaje Híbrido (Humano-IA)

**Componente:** Microservicios + Frontend

**Historia de Usuario:** Como usuario, quiero acceder tanto a educadores humanos como a tutores basados en IA, para obtener la mejor experiencia de aprendizaje según mis necesidades y preferencias.

#### Criterios de Aceptación

1. CUANDO un usuario busca recursos educativos ENTONCES el Marketplace Service DEBERÁ ofrecer opciones tanto de tutores humanos como de agentes IA via gRPC
2. CUANDO un educador humano crea una oferta educativa ENTONCES el Marketplace Service DEBERÁ permitir establecer precios y publicar evento de dominio
3. CUANDO un usuario interactúa con un tutor IA ENTONCES el Learning Service DEBERÁ registrar estas interacciones via gRPC y emitir eventos
4. CUANDO se completa una sesión educativa ENTONCES el sistema DEBERÁ coordinar pago via eventos entre Marketplace y Identity Services
5. CUANDO un tutor IA proporciona contenido ENTONCES el AI Tutor Service DEBERÁ verificar calidad antes de enviar via gRPC
6. SI una sesión es disputada ENTONCES el Governance Service DEBERÁ iniciar proceso de resolución via eventos de dominio
7. CUANDO se utilizan tutores IA ENTONCES el sistema DEBERÁ personalizar experiencia basándose en datos del Passport Service via gRPC

### Requerimiento 5: Sistema de Calificación, Comentarios y Reputación Dinámica

**Componente:** Backend + Frontend Móvil

**Historia de Usuario:** Como estudiante o tutor, quiero un sistema de calificaciones que expire cada 30 días y permita dejar comentarios detallados, para mantener una reputación actualizada y recibir feedback constante sobre mi desempeño.

#### Criterios de Aceptación

1. CUANDO un estudiante completa una interacción de aprendizaje ENTONCES el sistema DEBERÁ permitir calificar la experiencia con puntuaciones y comentarios detallados
2. CUANDO un estudiante califica a un educador ENTONCES el sistema DEBERÁ actualizar la reputación del educador en Keikochain y mostrar el comentario en su perfil
3. CUANDO un tutor completa una sesión educativa ENTONCES el sistema DEBERÁ permitirle también calificar al estudiante para crear un sistema de reputación bidireccional
4. CUANDO pasan 30 días desde una calificación ENTONCES el sistema DEBERÁ reducir gradualmente su peso en la reputación general hasta expirar completamente (lógica de backend)
5. CUANDO se acumulan calificaciones ENTONCES el sistema DEBERÁ calcular métricas de reputación visibles públicamente, priorizando las más recientes
6. CUANDO un usuario recibe un comentario ENTONCES el sistema DEBERÁ permitir responder a ese comentario para mantener un diálogo constructivo
7. CUANDO estudiantes participan en actividades grupales ENTONCES el sistema DEBERÁ permitir calificaciones entre pares
8. SI se detectan patrones de calificación maliciosos ENTONCES el sistema DEBERÁ aplicar mecanismos anti-fraude (lógica de backend)
9. CUANDO un usuario consulta un perfil desde la aplicación móvil ENTONCES el sistema DEBERÁ mostrar tanto la reputación histórica como la reputación reciente (últimos 30 días) para comparación

**Nota:** Para detalles de implementación de interfaces móviles de calificación, ver Spec 02-flutter-frontend-architecture

### Requerimiento 6: Gobernanza Educativa Comunitaria

**Componente:** Backend + Frontend

**Historia de Usuario:** Como miembro de una comunidad educativa, quiero participar en la definición de estándares y métodos de validación, para asegurar que el sistema refleje nuestros valores y necesidades.

#### Criterios de Aceptación

1. CUANDO una comunidad se forma ENTONCES el sistema DEBERÁ proporcionar herramientas de gobernanza personalizables.
2. CUANDO se propone un cambio en los estándares ENTONCES el sistema DEBERÁ permitir votaciones democráticas.
3. CUANDO una comunidad establece reglas de validación ENTONCES el sistema DEBERÁ aplicar estas reglas a las interacciones de esa comunidad.
4. CUANDO diferentes comunidades interactúan ENTONCES el sistema DEBERÁ facilitar la interoperabilidad respetando las reglas de cada una.
5. CUANDO se toman decisiones de gobernanza ENTONCES el sistema DEBERÁ registrar estas decisiones en Keikochain para transparencia.

### Requerimiento 7: Aplicación Móvil Flutter con Visualización Cronológica

**Componente:** Frontend (Flutter) + API Gateway

**Historia de Usuario:** Como usuario, quiero una aplicación móvil Flutter para visualizar mi pasaporte de aprendizaje como una línea de tiempo cronológica, para poder acceder y comprender fácilmente mi progreso educativo desde mi dispositivo móvil.

#### Criterios de Aceptación

1. CUANDO un usuario accede a la aplicación móvil ENTONCES el sistema DEBERÁ mostrar su pasaporte de aprendizaje como una visualización cronológica vertical
2. CUANDO se visualiza el pasaporte ENTONCES el sistema DEBERÁ agrupar las interacciones de aprendizaje que pertenecen a una misma sesión tutorial
3. CUANDO existen diferentes tipos de interacciones ENTONCES el sistema DEBERÁ diferenciar visualmente entre sesiones con educadores humanos, tutores IA, e interacciones individuales
4. CUANDO se selecciona una sesión tutorial ENTONCES el sistema DEBERÁ mostrar todas las interacciones de aprendizaje contenidas en ella
5. CUANDO un usuario quiere compartir logros ENTONCES el sistema DEBERÁ generar certificados visuales verificables
6. CUANDO la aplicación móvil se comunica con el backend ENTONCES el sistema DEBERÁ usar EXCLUSIVAMENTE GraphQL a través del API Gateway
7. CUANDO se requieran actualizaciones en tiempo real ENTONCES el sistema DEBERÁ usar GraphQL subscriptions alimentadas por eventos Redis Streams
8. CUANDO se aprovechen capacidades móviles ENTONCES el sistema DEBERÁ implementar notificaciones push y funcionalidades nativas

**Nota:** Para detalles técnicos de implementación con Clean Architecture y Riverpod, ver Spec 02-flutter-frontend-architecture

### Requerimiento 8: Panel Administrativo Web con Leptos

**Componente:** API Gateway (Panel Admin Leptos)

**Historia de Usuario:** Como administrador del sistema, quiero un panel web construido con Leptos para gestionar usuarios, validar interacciones y monitorear el sistema, para tener control administrativo completo con una interfaz web moderna y eficiente.

#### Criterios de Aceptación

1. CUANDO un administrador accede al panel ENTONCES el sistema DEBERÁ mostrar un dashboard con métricas del sistema usando Server-Side Rendering.
2. CUANDO se requiere gestionar usuarios ENTONCES el sistema DEBERÁ proporcionar CRUD completo para usuarios, tutores y estudiantes.
3. CUANDO se necesita validar interacciones ENTONCES el sistema DEBERÁ mostrar interacciones pendientes de validación con herramientas de aprobación/rechazo.
4. CUANDO se requiere monitoreo ENTONCES el sistema DEBERÁ mostrar estadísticas en tiempo real del uso de la plataforma.
5. CUANDO se necesita moderar contenido ENTONCES el sistema DEBERÁ proporcionar herramientas para revisar y moderar tutorías y comentarios.
6. CUANDO se requiere configuración ENTONCES el sistema DEBERÁ permitir configurar parámetros del sistema y políticas de la plataforma.
7. CUANDO se accede al panel ENTONCES el sistema DEBERÁ requerir autenticación administrativa y permisos apropiados.
8. CUANDO se realizan cambios administrativos ENTONCES el sistema DEBERÁ registrar todas las acciones en un log de auditoría.

### Requerimiento 9: API Gateway GraphQL

**Componente:** API Gateway (Rust)

**Historia de Usuario:** Como desarrollador de frontend, quiero un API Gateway GraphQL que traduzca mis queries a llamadas gRPC a microservicios, para tener una interfaz unificada y type-safe desde el frontend Flutter sin conocer la arquitectura interna de microservicios.

#### Criterios de Aceptación

1. CUANDO el frontend Flutter envía queries GraphQL ENTONCES el API Gateway DEBERÁ traducir automáticamente a llamadas gRPC a los microservicios correspondientes
2. CUANDO se requieran datos de múltiples microservicios ENTONCES el API Gateway DEBERÁ orquestar llamadas gRPC paralelas y agregar resultados
3. CUANDO se ejecuten mutations GraphQL ENTONCES el API Gateway DEBERÁ traducir a llamadas gRPC y manejar transacciones distribuidas
4. CUANDO ocurran errores en microservicios ENTONCES el API Gateway DEBERÁ mapear errores gRPC a errores GraphQL comprensibles
5. CUANDO se requiera autenticación ENTONCES el API Gateway DEBERÁ validar tokens JWT y propagar contexto de usuario via gRPC metadata
6. CUANDO se necesite cache ENTONCES el API Gateway DEBERÁ implementar cache de queries GraphQL con invalidación basada en eventos Redis
7. CUANDO se reciban eventos de dominio ENTONCES el API Gateway DEBERÁ actualizar subscriptions GraphQL en tiempo real
8. CUANDO sistemas externos requieran integración ENTONCES el API Gateway DEBERÁ exponer endpoints REST para webhooks y APIs de terceros
9. CUANDO se requiera observabilidad ENTONCES el API Gateway DEBERÁ instrumentar todas las llamadas GraphQL → gRPC con OpenTelemetry

### Requerimiento 10: Interoperabilidad y Estándares Abiertos

**Componente:** Blockchain + API Gateway

**Historia de Usuario:** Como institución educativa, quiero que Keiko utilice estándares abiertos e interoperables, para integrarme fácilmente con el ecosistema educativo existente.

#### Criterios de Aceptación

1. CUANDO se implementan nuevas funcionalidades ENTONCES el sistema DEBERÁ adherirse a estándares abiertos como xAPI.
2. CUANDO se intercambian datos con sistemas externos ENTONCES el sistema DEBERÁ utilizar formatos estándar como JSON.
3. CUANDO se desarrollan nuevas APIs ENTONCES el sistema DEBERÁ documentarlas siguiendo especificaciones OpenAPI.
4. CUANDO se requiere interoperabilidad con otras blockchains ENTONCES el sistema DEBERÁ implementar puentes compatibles.
5. CUANDO cambian los estándares de la industria ENTONCES el sistema DEBERÁ adaptarse manteniendo compatibilidad hacia atrás.

### Requerimiento 11: Seguridad y Privacidad de Datos

**Componente:** Blockchain + Frontend + API Gateway

**Historia de Usuario:** Como usuario, quiero tener control sobre mis datos educativos y su privacidad, para proteger mi información personal mientras demuestro mis habilidades.

#### Criterios de Aceptación

1. CUANDO un usuario registra datos personales ENTONCES el sistema DEBERÁ cumplir con regulaciones de privacidad como GDPR.
2. CUANDO se almacenan datos sensibles ENTONCES el sistema DEBERÁ implementar cifrado y técnicas de minimización de datos.
3. CUANDO un usuario quiere controlar la visibilidad de su información ENTONCES el sistema DEBERÁ ofrecer configuraciones granulares de privacidad.
4. CUANDO se comparten datos con terceros ENTONCES el sistema DEBERÁ requerir consentimiento explícito del usuario.
5. SI se detecta una brecha de seguridad ENTONCES el sistema DEBERÁ notificar a los usuarios afectados y tomar medidas correctivas inmediatas.
6. CUANDO se procesan datos biométricos ENTONCES el sistema DEBERÁ garantizar que nunca se almacenen en blockchain, solo hashes y pruebas STARK.
7. CUANDO se genera la humanity_proof_key ENTONCES el sistema DEBERÁ usar salt único por usuario y eliminar datos biométricos originales después del procesamiento.
8. CUANDO se implementa autenticación biométrica ENTONCES el sistema DEBERÁ usar pruebas de conocimiento cero para verificar humanidad sin exponer datos sensibles.

### Requerimiento 12: Tutores IA Avanzados

**Componente:** Services + Frontend + API Gateway

**Historia de Usuario:** Como estudiante, quiero acceder a tutores IA especializados que puedan adaptarse a mi estilo de aprendizaje y necesidades específicas, para maximizar mi progreso educativo sin depender exclusivamente de educadores humanos.

#### Criterios de Aceptación

1. CUANDO un usuario solicita asistencia educativa ENTONCES el sistema DEBERÁ proporcionar tutores IA con conocimientos especializados en el tema requerido.
2. CUANDO un tutor IA interactúa con un estudiante ENTONCES el sistema DEBERÁ adaptar el contenido y metodología según el perfil de aprendizaje del estudiante.
3. CUANDO un tutor IA proporciona información ENTONCES el sistema DEBERÁ verificar su precisión y actualidad antes de presentarla al estudiante.
4. CUANDO un estudiante interactúa repetidamente con tutores IA ENTONCES el sistema DEBERÁ mejorar progresivamente la personalización basándose en el historial de interacciones.
5. CUANDO un tutor IA identifica dificultades de aprendizaje ENTONCES el sistema DEBERÁ sugerir recursos adicionales o metodologías alternativas.
6. SI un tutor IA no puede resolver una consulta compleja ENTONCES el sistema DEBERÁ ofrecer la opción de conectar con un educador humano especializado.
7. CUANDO se utilizan tutores IA ENTONCES el sistema DEBERÁ garantizar transparencia sobre la naturaleza artificial del tutor.

### Requerimiento 13: Evaluación Pedagógica Inicial

**Componente:** Backend + Frontend Móvil

**Historia de Usuario:** Como estudiante nuevo en la plataforma, quiero realizar una evaluación pedagógica inicial opcional desde mi dispositivo móvil que identifique mi estilo de aprendizaje, para recibir contenido y metodologías personalizadas desde el primer momento.

#### Criterios de Aceptación

1. CUANDO un usuario se registra en la aplicación móvil ENTONCES el sistema DEBERÁ ofrecer la opción de realizar una evaluación pedagógica inicial
2. CUANDO un usuario completa la evaluación pedagógica ENTONCES el sistema DEBERÁ generar un perfil de aprendizaje personalizado y almacenarlo en blockchain
3. CUANDO se genera un perfil de aprendizaje ENTONCES el sistema DEBERÁ almacenarlo en el LifeLearningPassport del usuario en Keikochain
4. CUANDO un tutor (humano o IA) interactúa con un estudiante ENTONCES el sistema DEBERÁ proporcionar acceso al perfil de aprendizaje para personalizar la experiencia
5. CUANDO un usuario desea actualizar su perfil ENTONCES el sistema DEBERÁ permitir realizar nuevas evaluaciones periódicas desde la aplicación móvil
6. CUANDO se detectan cambios significativos en el comportamiento de aprendizaje ENTONCES el sistema DEBERÁ sugerir una reevaluación del perfil
7. SI un usuario decide no realizar la evaluación inicial ENTONCES el sistema DEBERÁ construir gradualmente un perfil basado en sus interacciones posteriores

**Nota:** Para detalles de implementación de interfaces móviles de evaluación, ver Spec 02-flutter-frontend-architecture

### Requerimiento 14: Planes de Acción Tutorial Adaptativos para Aprendizaje Asíncrono

**Componente:** Backend + Frontend Móvil

**Historia de Usuario:** Como estudiante con un ritmo de aprendizaje variable, quiero que el sistema genere y adapte planes de acción tutorial de forma dinámica sin necesidad de un plan de estudios predefinido, para poder aprender de manera asíncrona según mis intereses y disponibilidad desde mi dispositivo móvil.

#### Criterios de Aceptación

1. CUANDO un usuario interactúa con contenido educativo ENTONCES el sistema DEBERÁ registrar patrones de interés y compromiso en Keikochain
2. CUANDO se acumulan suficientes datos de interacción ENTONCES el sistema DEBERÁ generar automáticamente recomendaciones de aprendizaje personalizadas (algoritmos de backend)
3. CUANDO un usuario completa una actividad de aprendizaje ENTONCES el sistema DEBERÁ sugerir el siguiente paso lógico basado en su progreso y objetivos
4. CUANDO un usuario retoma su aprendizaje después de un período de inactividad ENTONCES la aplicación móvil DEBERÁ proporcionar un resumen contextual y recomendaciones actualizadas
5. CUANDO un usuario muestra interés en un nuevo tema ENTONCES el sistema DEBERÁ integrar este tema en su plan adaptativo sin interrumpir su progreso actual
6. CUANDO se detectan brechas de conocimiento ENTONCES el sistema DEBERÁ sugerir recursos complementarios para abordarlas (lógica de IA en backend)
7. SI un usuario desea más estructura ENTONCES la aplicación móvil DEBERÁ permitir la creación de planes de aprendizaje más formales a partir de sus interacciones asíncronas previas
8. CUANDO un usuario aprende de manera asíncrona ENTONCES el sistema DEBERÁ mantener la coherencia y progresión lógica entre sesiones discontinuas

**Nota:** Para detalles de implementación de interfaces móviles de planes adaptativos, ver Spec 02-flutter-frontend-architecture

### Requerimiento 15: Integración con Starknet - Keikochain como Appchain

**Componente:** Backend + gRPC Gateway

**Historia de Usuario:** Como usuario de la plataforma, quiero que Keikochain funcione como una appchain en el ecosistema Starknet, para beneficiarme de la escalabilidad de L2, la interoperabilidad con Ethereum y la eficiencia de CairoVM.

#### Criterios de Aceptación

1. CUANDO se despliega la blockchain de Keiko ENTONCES el sistema DEBERÁ implementar contratos Cairo en Keikochain (appchain personalizada de Starknet).
2. CUANDO se requiere comunicación con Keikochain ENTONCES el sistema DEBERÁ utilizar el gRPC Gateway para traducir llamadas Rust a transacciones Cairo.
3. CUANDO se necesita transferir activos entre Keiko y otras cadenas ENTONCES el sistema DEBERÁ implementar puentes compatibles con el ecosistema Starknet.
4. CUANDO se actualiza un contrato Cairo ENTONCES el sistema DEBERÁ mantener la compatibilidad con CairoVM y Starknet.
5. CUANDO se requiere validación de transacciones ENTONCES el sistema DEBERÁ adherirse al protocolo de consenso de Starknet.
6. CUANDO un usuario necesita interactuar con Keikochain ENTONCES el sistema DEBERÁ proporcionar una interfaz unificada a través del gRPC Gateway.
7. CUANDO se implementan nuevas funcionalidades ENTONCES el sistema DEBERÁ seguir las mejores prácticas y estándares del ecosistema Starknet.

### Requerimiento 16: Marketplace de Espacios de Aprendizaje Seguros

**Componente:** Backend + Frontend Móvil

**Historia de Usuario:** Como estudiante o padre de familia, quiero acceder desde mi dispositivo móvil a espacios físicos seguros y autorizados para recibir tutorías presenciales, para garantizar un ambiente de aprendizaje protegido especialmente cuando trabajo con tutores nuevos o cuando requiero atención presencial por mis necesidades educativas especiales.

#### Criterios de Aceptación

1. CUANDO un estudiante necesita tutorías presenciales ENTONCES la aplicación móvil DEBERÁ mostrar opciones de espacios de coworking y centros de estudio autorizados cercanos
2. CUANDO un espacio de aprendizaje se registra ENTONCES el sistema DEBERÁ verificar sus credenciales, seguridad y condiciones apropiadas para la enseñanza (proceso de backend)
3. CUANDO un tutor nuevo (con baja reputación) ofrece servicios presenciales ENTONCES el sistema DEBERÁ recomendar prioritariamente espacios seguros en lugar de domicilios
4. CUANDO se reserva un espacio desde la aplicación móvil ENTONCES el sistema DEBERÁ gestionar la disponibilidad, costos y confirmación de la reserva
5. CUANDO un estudiante tiene necesidades educativas especiales ENTONCES la aplicación móvil DEBERÁ filtrar espacios que cumplan con requisitos de accesibilidad y condiciones específicas
6. CUANDO se completa una sesión en un espacio autorizado ENTONCES la aplicación móvil DEBERÁ permitir calificar tanto al tutor como al espacio utilizado
7. CUANDO padres de familia buscan opciones para menores ENTONCES la aplicación móvil DEBERÁ priorizar espacios con certificaciones de seguridad infantil
8. CUANDO un espacio acumula calificaciones negativas ENTONCES el sistema DEBERÁ revisar su autorización y tomar medidas correctivas (proceso de backend)

**Nota:** Para detalles de implementación de interfaces móviles de marketplace, ver Spec 02-flutter-frontend-architecture

### Requerimiento 17: Modelado de Sesiones Tutoriales y sus Interacciones de Aprendizaje

**Componente:** Backend + Frontend Móvil

**Historia de Usuario:** Como tutor o estudiante, quiero que el sistema distinga claramente entre una sesión tutorial completa y las múltiples interacciones de aprendizaje atómicas que ocurren durante ella, para tener un registro estructurado y detallado de cada proceso educativo visualizable desde mi dispositivo móvil.

#### Criterios de Aceptación

1. CUANDO se inicia una sesión tutorial ENTONCES el sistema DEBERÁ crear un contenedor lógico en Keikochain que agrupe todas las interacciones de aprendizaje relacionadas
2. CUANDO ocurre una interacción de aprendizaje durante una tutoría ENTONCES el sistema DEBERÁ registrarla como una entidad atómica independiente pero vinculada a la sesión tutorial correspondiente
3. CUANDO un estudiante hace una pregunta durante una tutoría ENTONCES el sistema DEBERÁ registrarla como una interacción atómica individual en Keikochain
4. CUANDO un tutor proporciona una explicación ENTONCES el sistema DEBERÁ registrarla como una interacción atómica individual en Keikochain
5. CUANDO se realiza un quiz de verificación durante una tutoría ENTONCES el sistema DEBERÁ registrar cada pregunta del quiz como una interacción atómica individual
6. CUANDO finaliza una sesión tutorial ENTONCES la aplicación móvil DEBERÁ permitir una evaluación general de la sesión completa, además de las evaluaciones de interacciones individuales
7. CUANDO se visualiza el historial de aprendizaje desde la aplicación móvil ENTONCES el sistema DEBERÁ permitir navegar tanto por sesiones tutoriales completas como por interacciones individuales
8. CUANDO se califica una sesión tutorial ENTONCES la aplicación móvil DEBERÁ distinguir entre la calificación de la sesión completa y las calificaciones de interacciones específicas
9. CUANDO un tutor registra una interacción de aprendizaje ENTONCES la aplicación móvil DEBERÁ ofrecer opciones para categorizarla dentro del contexto de la sesión tutorial
10. CUANDO se analiza el progreso de aprendizaje ENTONCES la aplicación móvil DEBERÁ proporcionar métricas tanto a nivel de sesiones tutoriales como de interacciones individuales
11. CUANDO se exportan datos de aprendizaje ENTONCES el sistema DEBERÁ mantener la jerarquía entre sesiones tutoriales e interacciones atómicas

**Nota:** Para detalles de implementación de navegación jerárquica móvil, ver Spec 02-flutter-frontend-architecture

### Requerimiento 18: Arquitectura Híbrida Appchain-gRPC Gateway-Microservicios

**Componente:** Appchain + gRPC Gateway + Services + API Gateway

**Historia de Usuario:** Como arquitecto de software, quiero una arquitectura híbrida donde Keikochain sea la fuente de verdad, el gRPC Gateway traduzca entre Rust y Cairo, y los microservicios actúen como capa de servicio, para combinar las ventajas de blockchain (inmutabilidad, consenso) con la flexibilidad de microservicios (escalabilidad, cache, APIs modernas).

#### Criterios de Aceptación

1. CUANDO se escriban datos críticos ENTONCES los microservicios DEBERÁ enviar transacciones via gRPC Gateway a Keikochain como fuente de verdad inmutable
2. CUANDO se lean datos frecuentemente ENTONCES los microservicios DEBERÁ servir desde cache local con fallback a gRPC Gateway → Keikochain
3. CUANDO ocurran cambios en Keikochain ENTONCES el gRPC Gateway DEBERÁ detectar eventos y notificar a microservicios para actualizar cache local
4. CUANDO se requiera comunicación entre microservicios ENTONCES DEBERÁ usar exclusivamente gRPC con service discovery
5. CUANDO se publiquen eventos de dominio ENTONCES los microservicios DEBERÁ usar Redis Streams (NUNCA Keikochain)
6. CUANDO el API Gateway reciba queries GraphQL ENTONCES DEBERÁ traducir a llamadas gRPC y orquestar respuestas de múltiples microservicios
7. CUANDO se requieran subscriptions en tiempo real ENTONCES el API Gateway DEBERÁ usar Redis Streams para alimentar GraphQL subscriptions
8. CUANDO sistemas externos requieran integración ENTONCES DEBERÁ usar endpoints REST solo en el API Gateway (no en microservicios)
9. CUANDO se desplieguen microservicios ENTONCES cada uno DEBERÁ tener su propia base de datos PostgreSQL independiente
10. CUANDO se requiera observabilidad ENTONCES DEBERÁ instrumentar toda la cadena: GraphQL → gRPC → gRPC Gateway → Keikochain Contract

### Requerimiento 19: Jerarquía Completa de Experiencias de Aprendizaje

**Componente:** Backend + Frontend

**Historia de Usuario:** Como estudiante, quiero que el sistema modele una jerarquía completa de experiencias educativas (cursos, clases, tutorías e interacciones), para poder visualizar y organizar mi aprendizaje en diferentes niveles de granularidad.

#### Criterios de Aceptación

1. CUANDO se registra un curso completo ENTONCES el sistema DEBERÁ crear una estructura que pueda contener múltiples clases relacionadas bajo un mismo plan de estudios.
2. CUANDO se imparte una clase dentro de un curso ENTONCES el sistema DEBERÁ registrarla como una entidad que puede contener múltiples interacciones de aprendizaje, manteniendo la referencia al curso al que pertenece.
3. CUANDO se realiza un examen final ENTONCES el sistema DEBERÁ registrar cada pregunta del examen como una interacción atómica individual.
4. CUANDO ocurre una discusión grupal en clase ENTONCES el sistema DEBERÁ registrarla como una interacción atómica individual.
5. CUANDO un profesor proporciona feedback ENTONCES el sistema DEBERÁ registrarlo como una interacción atómica individual.
6. CUANDO un estudiante realiza una autoevaluación ENTONCES el sistema DEBERÁ registrarla como una interacción atómica individual.
7. CUANDO ocurren interacciones de aprendizaje durante una clase (preguntas, respuestas, ejercicios) ENTONCES el sistema DEBERÁ registrarlas individualmente pero vinculadas a la clase correspondiente.
8. CUANDO se visualiza la línea de tiempo ENTONCES el sistema DEBERÁ permitir filtrar y agrupar por diferentes niveles jerárquicos:
   - Cursos completos (ej: "Matemáticas" con 20 clases y 45 interacciones)
   - Clases individuales (ej: "Clase 1: Álgebra Básica" con 3 interacciones)
   - Tutorías específicas (ej: "Tutoría Individual" con 3 interacciones)
   - Sesiones de estudio personal (ej: "Interacción con IA" con 2 interacciones)
   - Interacciones de aprendizaje atómicas (ej: "Pregunta sobre derivadas")
9. CUANDO se muestra una clase en la línea de tiempo ENTONCES el sistema DEBERÁ incluir una etiqueta visible que indique a qué curso pertenece.
10. CUANDO un usuario busca en su historial de aprendizaje ENTONCES el sistema DEBERÁ permitir navegar por esta jerarquía en ambas direcciones (de lo general a lo específico y viceversa).
11. CUANDO se generan certificaciones o credenciales ENTONCES el sistema DEBERÁ poder emitirlas a cualquier nivel de la jerarquía (curso completo, clase específica, o logro particular).
12. CUANDO se exportan datos de aprendizaje ENTONCES el sistema DEBERÁ preservar esta estructura jerárquica completa.

## Requerimientos de Microservicios

### Requerimiento 20: Arquitectura de Microservicios con Keikochain

**Componente:** Service Layer + gRPC Gateway + Keikochain

**Historia de Usuario:** Como arquitecto de software, quiero descomponer la lógica de negocio en microservicios independientes que se comuniquen con Keikochain via gRPC Gateway, para que cada dominio de negocio pueda desarrollarse, desplegarse y escalarse de forma autónoma.

#### Criterios de Aceptación

1. CUANDO se identifiquen los bounded contexts ENTONCES el sistema DEBERÁ separar cada dominio de negocio en un servicio independiente
2. CUANDO se implemente la separación ENTONCES cada servicio DEBERÁ tener su propio schema PostgreSQL separado (Database per Service o Schema per Service según recursos disponibles)
3. CUANDO se comuniquen los servicios ENTONCES DEBERÁ usar gRPC bien definidas y event-driven architecture con Redis Streams
4. CUANDO se desplieguen los servicios ENTONCES cada uno DEBERÁ ser containerizado y desplegable independientemente
5. SI un servicio falla ENTONCES los otros servicios DEBERÁ continuar funcionando (fault isolation)
6. CUANDO se requiera comunicación con Keikochain ENTONCES DEBERÁ usar el gRPC Gateway como intermediario

### Requerimiento 21: Patrones de Migración Gradual

**Componente:** Service Layer + gRPC Gateway

**Historia de Usuario:** Como DevOps engineer, quiero implementar una migración gradual hacia microservicios usando patrones probados, para que la transición sea controlada y sin interrupciones de servicio.

#### Criterios de Aceptación

1. CUANDO se inicie la migración ENTONCES DEBERÁ implementarse el Strangler Fig Pattern para dirigir tráfico gradualmente
2. CUANDO se creen abstracciones ENTONCES DEBERÁ usarse Branch by Abstraction Pattern para permitir implementaciones duales
3. CUANDO se organicen los equipos ENTONCES DEBERÁ aplicarse Service per Team Pattern con repositorios independientes
4. CUANDO se migre un servicio ENTONCES DEBERÁ mantener sincronización de datos durante la transición
5. CUANDO se complete la migración de un servicio ENTONCES DEBERÁ eliminarse el código legacy correspondiente

### Requerimiento 22: Servicios Independientes por Dominio

**Componente:** Service Layer

**Historia de Usuario:** Como desarrollador de backend, quiero que cada dominio de negocio tenga su propio servicio independiente, para que pueda desarrollar y desplegar sin afectar otros dominios.

#### Criterios de Aceptación

1. CUANDO se extraiga Identity Service ENTONCES DEBERÁ gestionar autenticación, autorización y perfiles de usuario
2. CUANDO se extraiga Learning Service ENTONCES DEBERÁ procesar xAPI statements y interacciones de aprendizaje
3. CUANDO se extraiga Reputation Service ENTONCES DEBERÁ calcular y gestionar reputación de tutores y estudiantes
4. CUANDO se extraiga Passport Service ENTONCES DEBERÁ agregar competencias y gestionar pasaportes de aprendizaje
5. CUANDO se creen nuevos servicios ENTONCES DEBERÁ incluir Governance Service, Marketplace Service y AI Tutor Service

### Requerimiento 23: Resiliencia y Tolerancia a Fallos

**Componente:** Service Layer + gRPC Gateway

**Historia de Usuario:** Como arquitecto de software, quiero que el sistema sea resiliente a fallos, para que la indisponibilidad de un servicio no afecte la funcionalidad completa del sistema.

#### Criterios de Aceptación

1. CUANDO un servicio no responda ENTONCES DEBERÁ implementar Circuit Breaker Pattern para evitar cascading failures
2. CUANDO ocurran errores transitorios ENTONCES DEBERÁ implementar retry policies con exponential backoff
3. CUANDO se pierda conectividad ENTONCES DEBERÁ implementar graceful degradation de funcionalidades
4. CUANDO se sobrecargue un servicio ENTONCES DEBERÁ implementar rate limiting y load shedding
5. CUANDO se reinicie un servicio ENTONCES DEBERÁ implementar graceful shutdown y startup
6. CUANDO falle la comunicación con Keikochain ENTONCES DEBERÁ usar cache local como fallback

### Requerimiento 24: Event-Driven Communication

**Componente:** Service Layer + Redis Streams

**Historia de Usuario:** Como desarrollador de backend, quiero que los servicios se comuniquen de forma asíncrona usando eventos, para que el sistema sea más resiliente y desacoplado.

#### Criterios de Aceptación

1. CUANDO ocurra un evento de dominio ENTONCES DEBERÁ publicarse en Redis Streams para notificar servicios interesados
2. CUANDO se procesen eventos ENTONCES DEBERÁ garantizar at-least-once delivery y idempotencia
3. CUANDO se definan eventos ENTONCES DEBERÁ seguir un schema versionado y backward compatible
4. CUANDO se suscriban servicios ENTONCES DEBERÁ implementar dead letter queues para eventos fallidos
5. CUANDO se implemente event sourcing ENTONCES DEBERÁ mantener audit trail completo de cambios de estado
6. CUANDO se publiquen eventos ENTONCES DEBERÁ usar Redis Streams (NUNCA Keikochain para eventos)

### Requerimiento 25: API Design y Contratos de Servicio

**Componente:** Service Layer + API Gateway

**Historia de Usuario:** Como desarrollador de frontend, quiero que los microservicios expongan APIs bien definidas y documentadas, para que pueda integrarme fácilmente sin conocer la implementación interna.

#### Criterios de Aceptación

1. CUANDO se diseñen APIs ENTONCES DEBERÁ seguir principios gRPC y usar Protocol Buffers specification
2. CUANDO se versionen APIs ENTONCES DEBERÁ mantener backward compatibility y deprecation policies
3. CUANDO se documenten APIs ENTONCES DEBERÁ incluir ejemplos, códigos de error y rate limits
4. CUANDO se cambien contratos ENTONCES DEBERÁ usar consumer-driven contract testing
5. CUANDO se expongan GraphQL APIs ENTONCES DEBERÁ implementar schema federation para queries distribuidas
6. CUANDO el API Gateway reciba queries ENTONCES DEBERÁ traducir a llamadas gRPC a microservicios

### Requerimiento 26: Data Consistency y Transacciones Distribuidas

**Componente:** Service Layer + Keikochain

**Historia de Usuario:** Como desarrollador de backend, quiero manejar la consistencia de datos entre microservicios y Keikochain, para que las operaciones complejas mantengan integridad.

#### Criterios de Aceptación

1. CUANDO se requieran transacciones distribuidas ENTONCES DEBERÁ implementar Saga Pattern para coordinación
2. CUANDO se sincronicen datos ENTONCES DEBERÁ usar eventual consistency con compensating actions
3. CUANDO se detecten inconsistencias ENTONCES DEBERÁ implementar reconciliation processes automáticos
4. CUANDO se repliquen datos ENTONCES DEBERÁ usar event sourcing para mantener audit trail
5. CUANDO se requiera consistencia fuerte ENTONCES DEBERÁ identificar bounded contexts que requieren transacciones locales
6. CUANDO se escriban datos críticos ENTONCES DEBERÁ enviar transacciones via gRPC Gateway a Keikochain como fuente de verdad

### Requerimiento 27: Service Discovery y Load Balancing

**Componente:** Service Layer + gRPC Gateway

**Historia de Usuario:** Como desarrollador de microservicios, quiero que los servicios se descubran automáticamente, para que no tenga que hardcodear direcciones IP y pueda escalar dinámicamente.

#### Criterios de Aceptación

1. CUANDO se desplieguen servicios ENTONCES DEBERÁ usar service discovery automático de Kubernetes
2. CUANDO se balancee carga ENTONCES DEBERÁ implementar client-side load balancing con circuit breakers
3. CUANDO se enruten requests ENTONCES DEBERÁ usar service mesh para traffic management
4. CUANDO se requiera failover ENTONCES DEBERÁ implementar health checks y automatic failover
5. CUANDO se escalen servicios ENTONCES DEBERÁ distribuir tráfico automáticamente a nuevas instancias
6. CUANDO se comuniquen con Keikochain ENTONCES DEBERÁ usar el gRPC Gateway como punto de entrada único

### Requerimiento 28: Testing de Microservicios

**Componente:** Service Layer + gRPC Gateway + Keikochain

**Historia de Usuario:** Como desarrollador, quiero estrategias de testing específicas para microservicios, para que pueda validar tanto servicios individuales como el sistema completo.

#### Criterios de Aceptación

1. CUANDO se prueben servicios individuales ENTONCES DEBERÁ implementar unit tests con mocks para dependencias
2. CUANDO se prueben integraciones ENTONCES DEBERÁ usar contract testing entre servicios
3. CUANDO se pruebe el sistema completo ENTONCES DEBERÁ implementar end-to-end tests en entorno de staging
4. CUANDO se pruebe performance ENTONCES DEBERÁ implementar load testing por servicio y sistema completo
5. CUANDO se pruebe resiliencia ENTONCES DEBERÁ implementar chaos engineering para validar fault tolerance
6. CUANDO se pruebe comunicación con Keikochain ENTONCES DEBERÁ usar mocks del gRPC Gateway

### Requerimiento 29: Migración de Datos y Estado

**Componente:** Service Layer + Keikochain

**Historia de Usuario:** Como DBA, quiero migrar datos hacia microservicios de forma segura, para que no se pierda información y se mantenga la integridad durante la transición.

#### Criterios de Aceptación

1. CUANDO se migren datos ENTONCES DEBERÁ crear estrategia de migración por fases con rollback capability
2. CUANDO se sincronicen datos ENTONCES DEBERÁ mantener dual-write durante período de transición
3. CUANDO se validen migraciones ENTONCES DEBERÁ implementar data validation y reconciliation
4. CUANDO se complete migración ENTONCES DEBERÁ eliminar dual-write y limpiar datos legacy
5. CUANDO se requiera rollback ENTONCES DEBERÁ poder revertir migración sin pérdida de datos
6. CUANDO se migren datos críticos ENTONCES DEBERÁ mantener Keikochain como fuente de verdad inmutable

### Requerimiento 30: Estrategia de Base de Datos para Recursos Limitados

**Componente:** Service Layer + PostgreSQL

**Historia de Usuario:** Como desarrollador con recursos limitados, quiero usar una estrategia pragmática de base de datos que mantenga la separación de dominios pero sea económicamente viable, para poder desarrollar microservicios sin la complejidad de múltiples instancias de base de datos.

#### Criterios de Aceptación

1. CUANDO se configure la base de datos ENTONCES DEBERÁ usar una única instancia PostgreSQL con schemas separados por servicio
2. CUANDO se definan schemas ENTONCES DEBERÁ crear un schema por microservicio (identity_schema, learning_schema, reputation_schema, etc.)
3. CUANDO se configuren conexiones ENTONCES cada microservicio DEBERÁ conectarse solo a su schema específico
4. CUANDO se requiera escalabilidad ENTONCES DEBERÁ poder migrar fácilmente de schemas a bases de datos separadas
5. CUANDO se implemente esta estrategia ENTONCES DEBERÁ documentar claramente la migración futura a Database per Service
6. CUANDO se despliegue en producción ENTONCES DEBERÁ evaluar la migración a bases de datos separadas según el crecimiento

### Requerimiento 31: Proof-of-Humanity con zkProofs para Firmar Interacciones de Aprendizaje

**Componente:** Service Layer + gRPC Gateway + Keikochain + Frontend

**Historia de Usuario:** Como usuario de la plataforma, quiero demostrar mi humanidad única usando datos biométricos (iris y genoma) con pruebas de conocimiento cero, para poder firmar mis interacciones de aprendizaje de forma única y verificable, garantizando que cada interacción proviene de una persona humana real.

#### Criterios de Aceptación

1. CUANDO un usuario se registra ENTONCES el sistema DEBERÁ generar una `humanity_proof_key = sha256(iris_hash || genoma_hash || salt)` usando datos biométricos procesados off-chain
2. CUANDO se procesan datos biométricos ENTONCES el sistema DEBERÁ usar Gabor filters para iris_hash y análisis de SNPs en VCF/FASTA para genoma_hash
3. CUANDO se genera la humanity_proof_key ENTONCES el sistema DEBERÁ crear una prueba STARK (no zk-SNARK) que verifique la validez sin exponer los inputs biométricos
4. CUANDO se verifica la humanidad ENTONCES el contrato Cairo en Keikochain DEBERÁ validar la prueba STARK, verificar que la humanity_proof_key corresponde a una persona humana única, y permitir la recuperación de identidad si el usuario demuestra conocimiento de la misma humanity_proof_key desde una cuenta diferente
5. CUANDO se firman interacciones de aprendizaje ENTONCES el sistema DEBERÁ usar una clave Ed25519 derivada de la humanity_proof_key para firmar cada interacción, garantizando que proviene de una persona humana específica
6. CUANDO se verifica una firma de interacción ENTONCES el contrato Cairo DEBERÁ validar la firma Ed25519 contra la humanity_proof_key almacenada para confirmar la humanidad del firmante
7. CUANDO se detecta una humanity_proof_key duplicada ENTONCES el sistema DEBERÁ permitir la recuperación de identidad transfiriendo el historial de aprendizaje a la nueva cuenta, manteniendo la unicidad de la persona humana
8. CUANDO se procesan datos biométricos ENTONCES DEBERÁ hacerse completamente off-chain en microservicios Rust, nunca en Keikochain

### Requerimiento 32: Integración FIDO2 con zkProofs para Autenticación Híbrida

**Componente:** Frontend + API Gateway + Service Layer + Keikochain

**Historia de Usuario:** Como usuario, quiero usar FIDO2 para login inicial y zkProofs para operaciones críticas, para tener una experiencia de autenticación fluida que combine la conveniencia de WebAuthn con la seguridad de pruebas de humanidad.

#### Criterios de Aceptación

1. CUANDO un usuario inicia sesión ENTONCES la aplicación Flutter DEBERÁ usar FIDO2 (WebAuthn) para autenticación inicial
2. CUANDO FIDO2 es exitoso ENTONCES el API Gateway DEBERÁ generar un JWT para la sesión del usuario
3. CUANDO se requiere verificación de humanidad ENTONCES el sistema DEBERÁ solicitar la prueba STARK de la humanity_proof_key
4. CUANDO se envían interacciones críticas ENTONCES el sistema DEBERÁ verificar tanto el JWT como la prueba STARK
5. CUANDO se usa FIDO2 ENTONCES DEBERÁ configurarse con `userVerification: 'required'` y `rpId: 'keiko.com'`
6. CUANDO se genera el JWT ENTONCES DEBERÁ incluir información de la sesión FIDO2 y referencia a la humanity_proof_key
7. CUANDO se requiere re-autenticación ENTONCES el sistema DEBERÁ permitir usar FIDO2 sin repetir el proceso biométrico completo
8. CUANDO se detecta actividad sospechosa ENTONCES el sistema DEBERÁ requerir verificación adicional con zkProofs

### Requerimiento 33: Contrato Cairo para Verificación de Pruebas STARK y Proof-of-Humanity en Keikochain

**Componente:** Keikochain (Cairo Smart Contracts)

**Historia de Usuario:** Como desarrollador de contratos inteligentes, quiero un contrato Cairo en Keikochain que verifique pruebas STARK y gestione el proof-of-humanity, para proporcionar verificación criptográfica descentralizada de que las interacciones de aprendizaje provienen de personas humanas reales.

#### Criterios de Aceptación

1. CUANDO se despliega el contrato ENTONCES DEBERÁ implementar verificación de pruebas STARK usando `starknet-crypto` para SHA-256
2. CUANDO se registra una humanity_proof_key ENTONCES el contrato DEBERÁ almacenarla asociada a la dirección de la cuenta en Keikochain, permitiendo recuperación de identidad
3. CUANDO se verifica una prueba STARK ENTONCES el contrato DEBERÁ validar que la prueba demuestra conocimiento de iris_hash, genoma_hash y salt sin exponerlos
4. CUANDO se firma una interacción de aprendizaje ENTONCES el contrato DEBERÁ verificar la firma Ed25519 contra la humanity_proof_key almacenada para confirmar proof-of-humanity
5. CUANDO se almacenan interacciones ENTONCES DEBERÁ guardarlas en un storage tipo `LearningPassport: AccountId -> Vec<(Data, Timestamp, HumanSignature)>` incluyendo la firma de humanidad
6. CUANDO se detecta una humanity_proof_key duplicada ENTONCES el contrato DEBERÁ permitir recuperación de identidad transfiriendo el historial de aprendizaje a la nueva cuenta
7. CUANDO se optimiza para gas ENTONCES DEBERÁ usar operaciones eficientes de Cairo y minimizar storage writes
8. CUANDO se implementa el contrato ENTONCES DEBERÁ seguir las mejores prácticas de Cairo y ser compatible con CairoVM

### Requerimiento 34: Procesamiento Off-Chain de Datos Biométricos

**Componente:** Service Layer (Rust Microservices)

**Historia de Usuario:** Como desarrollador de backend, quiero procesar datos biométricos de forma segura off-chain, para generar la humanity_proof_key y pruebas STARK sin exponer datos sensibles en blockchain.

#### Criterios de Aceptación

1. CUANDO se procesan datos de iris ENTONCES el microservicio DEBERÁ usar OpenCV con Gabor filters para generar iris_hash
2. CUANDO se procesan datos genómicos ENTONCES el microservicio DEBERÁ usar BioPython para analizar SNPs en archivos VCF/FASTA y generar genoma_hash
3. CUANDO se genera la humanity_proof_key ENTONCES DEBERÁ usar SHA-256 con concatenación segura de iris_hash || genoma_hash || salt
4. CUANDO se crean pruebas STARK ENTONCES DEBERÁ usar `cairo-lang` para generar pruebas que verifiquen la validez sin exponer inputs
5. CUANDO se procesan datos biométricos ENTONCES DEBERÁ hacerse en un entorno seguro con cifrado en reposo y en tránsito
6. CUANDO se completa el procesamiento ENTONCES DEBERÁ eliminar los datos biométricos originales, manteniendo solo hashes
7. CUANDO se genera la clave Ed25519 ENTONCES DEBERÁ derivarla de la humanity_proof_key usando funciones criptográficas seguras
8. CUANDO se envían datos a Keikochain ENTONCES DEBERÁ usar el gRPC Gateway para traducir tipos Rust a Cairo

### Requerimiento 35: Integración gRPC Gateway para Comunicación Rust ↔ Cairo

**Componente:** gRPC Gateway Layer

**Historia de Usuario:** Como desarrollador de microservicios, quiero un gateway que traduzca llamadas Rust a transacciones Cairo, para comunicarme con Keikochain sin conocer los detalles de implementación de Starknet.

#### Criterios de Aceptación

1. CUANDO se envían datos desde microservicios ENTONCES el gRPC Gateway DEBERÁ traducir tipos Rust a tipos Cairo compatibles
2. CUANDO se invocan contratos ENTONCES DEBERÁ usar `starknet-rs` para comunicarse con el RPC de Keikochain
3. CUANDO se procesan transacciones ENTONCES DEBERÁ manejar confirmaciones y estados de transacciones Starknet
4. CUANDO ocurren errores ENTONCES DEBERÁ mapear errores de Starknet a errores gRPC comprensibles
5. CUANDO se requiere optimización ENTONCES DEBERÁ implementar batching de transacciones cuando sea posible
6. CUANDO se configura la conexión ENTONCES DEBERÁ usar el RPC endpoint de Keikochain (`wss://keikochain.karnot.xyz`)
7. CUANDO se implementa el gateway ENTONCES DEBERÁ seguir patrones de resiliencia con circuit breakers y retry policies
8. CUANDO se despliega ENTONCES DEBERÁ exponer un servidor gRPC en `localhost:50051` para comunicación con microservicios
