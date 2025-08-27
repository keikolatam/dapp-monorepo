# Documento de Requerimientos

## Introducción

Keiko es una red social educativa descentralizada (DApp) construida como un monorepo que integra un backend desarrollado en Rust sobre Substrate y un frontend multiplataforma desarrollado en Flutter. Su propósito es convertir el aprendizaje en capital humano verificable e interoperable en tiempo real. La plataforma permite a cualquier individuo construir y demostrar su Pasaporte de Aprendizaje de Vida (LifeLearningPassport) en blockchain, mediante interacciones de aprendizaje atómicas (LearningInteractions) compatibles con el estándar xAPI (Tin Can). El objetivo principal es reemplazar las certificaciones tradicionales con evidencia infalsificable de aprendizaje, evaluada por múltiples actores y almacenada de forma descentralizada.

La arquitectura del proyecto se organiza en cuatro capas principales con estructura de carpetas correspondiente:

- **Blockchain Layer** (`blockchain/`): Parachain Substrate con pallets especializados para almacenamiento inmutable y consenso
- **Service Layer** (`services/`): Microservicios Rust con comunicación gRPC, cache PostgreSQL local, y eventos Redis Streams
- **API Layer** (`api-gateway/`): API Gateway GraphQL que traduce queries del frontend a llamadas gRPC y orquesta respuestas
- **Frontend Layer** (`frontend/`): Aplicación Flutter multiplataforma que se comunica exclusivamente via GraphQL

**Flujo de Datos Híbrido:**

- **Escritura**: Flutter → GraphQL → Microservicio → Parachain → Evento Redis → GraphQL Subscription
- **Lectura**: Flutter → GraphQL → Microservicio → Cache/DB local → (fallback) Parachain RPC
- **Tiempo Real**: Parachain → Microservicio → Redis Streams → API Gateway → GraphQL Subscription → Flutter

## Requerimientos

### Requerimiento 1: Pasaporte de Aprendizaje de Vida

**Componente:** Backend + Frontend

**Historia de Usuario:** Como usuario, quiero tener un Pasaporte de Aprendizaje de Vida en blockchain, para poder demostrar mi conocimiento y habilidades de manera verificable e infalsificable.

#### Criterios de Aceptación

1. CUANDO un usuario se registra en la plataforma ENTONCES el sistema DEBERÁ crear un nuevo LifeLearningPassport asociado a su identidad blockchain.
2. CUANDO se registra una nueva interacción de aprendizaje ENTONCES el sistema DEBERÁ actualizar el LifeLearningPassport del usuario correspondiente.
3. CUANDO un usuario solicita ver su pasaporte ENTONCES el sistema DEBERÁ mostrar todas sus interacciones de aprendizaje registradas en orden cronológico.
4. CUANDO un tercero solicita verificar el pasaporte de un usuario ENTONCES el sistema DEBERÁ permitir la verificación criptográfica de la autenticidad de los datos.
5. CUANDO un usuario quiere compartir su pasaporte ENTONCES el sistema DEBERÁ generar un enlace verificable que pueda ser compartido con terceros.

### Requerimiento 2: Interacciones de Aprendizaje Atómicas

**Componente:** Backend

**Historia de Usuario:** Como educador o plataforma de aprendizaje, quiero registrar interacciones de aprendizaje atómicas compatibles con xAPI en la blockchain, para crear un registro inmutable y granular de cada actividad educativa individual.

#### Criterios de Aceptación

1. CUANDO se envía una interacción de aprendizaje en formato xAPI ENTONCES el sistema DEBERÁ validar su estructura y contenido.
2. CUANDO una interacción de aprendizaje es válida ENTONCES el sistema DEBERÁ almacenarla en la blockchain mediante el pallet learning_interactions.
3. CUANDO una interacción contiene archivos adjuntos o evidencias ENTONCES el sistema DEBERÁ almacenar referencias a estos archivos de manera segura.
4. CUANDO se registra una interacción ENTONCES el sistema DEBERÁ emitir un evento que pueda ser capturado por sistemas externos.
5. SI una interacción no cumple con el estándar xAPI ENTONCES el sistema DEBERÁ rechazar la transacción y notificar el error.
6. CUANDO se registra una pregunta en un examen o quiz ENTONCES el sistema DEBERÁ tratarla como una interacción atómica individual.
7. CUANDO se registra una respuesta a una pregunta ENTONCES el sistema DEBERÁ tratarla como una interacción atómica individual.
8. CUANDO se registra un ejercicio práctico ENTONCES el sistema DEBERÁ tratarlo como una interacción atómica individual.
9. CUANDO se registra una discusión o participación en clase ENTONCES el sistema DEBERÁ tratarla como una interacción atómica individual.
10. CUANDO se registra una evaluación o calificación ENTONCES el sistema DEBERÁ tratarla como una interacción atómica individual.

### Requerimiento 3: Integración con Learning Record Stores (LRS)

**Componente:** API Gateway + Microservicios

**Historia de Usuario:** Como institución educativa, quiero integrar mi Learning Record Store existente con Keiko, para transferir automáticamente los registros de aprendizaje a los microservicios.

#### Criterios de Aceptación

1. CUANDO un LRS compatible envía datos via REST webhook ENTONCES el API Gateway DEBERÁ procesar y validar estos datos xAPI
2. CUANDO se configura la integración con un LRS ENTONCES el sistema DEBERÁ proporcionar endpoints REST y credenciales de webhook
3. CUANDO se reciben datos de Learning Locker ENTONCES el API Gateway DEBERÁ transformarlos y enviarlos via gRPC al Learning Service
4. SI la conexión con microservicios falla ENTONCES el API Gateway DEBERÁ almacenar los datos en Redis Streams para reintento
5. CUANDO se actualiza el LRS ENTONCES el sistema DEBERÁ sincronizar los nuevos registros via eventos de dominio en Redis Streams

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

**Componente:** Backend + Frontend

**Historia de Usuario:** Como estudiante o tutor, quiero un sistema de calificaciones que expire cada 30 días y permita dejar comentarios detallados, para mantener una reputación actualizada y recibir feedback constante sobre mi desempeño.

#### Criterios de Aceptación

1. CUANDO un estudiante completa una interacción de aprendizaje ENTONCES el sistema DEBERÁ permitir calificar la experiencia con puntuaciones y comentarios detallados.
2. CUANDO un estudiante califica a un educador ENTONCES el sistema DEBERÁ actualizar la reputación del educador y mostrar el comentario en su perfil.
3. CUANDO un tutor completa una sesión educativa ENTONCES el sistema DEBERÁ permitirle también calificar al estudiante para crear un sistema de reputación bidireccional.
4. CUANDO pasan 30 días desde una calificación ENTONCES el sistema DEBERÁ reducir gradualmente su peso en la reputación general hasta expirar completamente.
5. CUANDO se acumulan calificaciones ENTONCES el sistema DEBERÁ calcular métricas de reputación visibles públicamente, priorizando las más recientes.
6. CUANDO un usuario recibe un comentario ENTONCES el sistema DEBERÁ permitir responder a ese comentario para mantener un diálogo constructivo.
7. CUANDO estudiantes participan en actividades grupales ENTONCES el sistema DEBERÁ permitir calificaciones entre pares.
8. SI se detectan patrones de calificación maliciosos ENTONCES el sistema DEBERÁ aplicar mecanismos anti-fraude.
9. CUANDO un usuario consulta un perfil ENTONCES el sistema DEBERÁ mostrar tanto la reputación histórica como la reputación reciente (últimos 30 días) para comparación.

### Requerimiento 6: Gobernanza Educativa Comunitaria

**Componente:** Backend + Frontend

**Historia de Usuario:** Como miembro de una comunidad educativa, quiero participar en la definición de estándares y métodos de validación, para asegurar que el sistema refleje nuestros valores y necesidades.

#### Criterios de Aceptación

1. CUANDO una comunidad se forma ENTONCES el sistema DEBERÁ proporcionar herramientas de gobernanza personalizables.
2. CUANDO se propone un cambio en los estándares ENTONCES el sistema DEBERÁ permitir votaciones democráticas.
3. CUANDO una comunidad establece reglas de validación ENTONCES el sistema DEBERÁ aplicar estas reglas a las interacciones de esa comunidad.
4. CUANDO diferentes comunidades interactúan ENTONCES el sistema DEBERÁ facilitar la interoperabilidad respetando las reglas de cada una.
5. CUANDO se toman decisiones de gobernanza ENTONCES el sistema DEBERÁ registrar estas decisiones en la blockchain para transparencia.

### Requerimiento 7: Aplicación Frontend Multiplataforma con Visualización Cronológica

**Componente:** Frontend (Flutter)

**Historia de Usuario:** Como usuario, quiero una aplicación Flutter que funcione tanto en web como en dispositivos móviles para visualizar mi pasaporte de aprendizaje como una línea de tiempo vertical, conectándose exclusivamente a la API GraphQL del middleware, para poder acceder y comprender fácilmente mi progreso educativo desde cualquier dispositivo.

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
10. CUANDO la aplicación Flutter se comunica con el backend ENTONCES el sistema DEBERÁ usar EXCLUSIVAMENTE GraphQL queries, mutations y subscriptions a través del API Gateway middleware
11. CUANDO se requieran datos en tiempo real ENTONCES el sistema DEBERÁ usar GraphQL subscriptions que se alimentan de eventos Redis Streams
12. CUANDO el frontend necesite datos de múltiples microservicios ENTONCES el API Gateway DEBERÁ orquestar las llamadas gRPC y devolver una respuesta GraphQL unificada

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

**Componente:** Backend + Frontend

**Historia de Usuario:** Como estudiante nuevo en la plataforma, quiero realizar una evaluación pedagógica inicial opcional que identifique mi estilo de aprendizaje, para recibir contenido y metodologías personalizadas desde el primer momento.

#### Criterios de Aceptación

1. CUANDO un usuario se registra en la plataforma ENTONCES el sistema DEBERÁ ofrecer la opción de realizar una evaluación pedagógica inicial.
2. CUANDO un usuario completa la evaluación pedagógica ENTONCES el sistema DEBERÁ generar un perfil de aprendizaje personalizado.
3. CUANDO se genera un perfil de aprendizaje ENTONCES el sistema DEBERÁ almacenarlo en el LifeLearningPassport del usuario.
4. CUANDO un tutor (humano o IA) interactúa con un estudiante ENTONCES el sistema DEBERÁ proporcionar acceso al perfil de aprendizaje para personalizar la experiencia.
5. CUANDO un usuario desea actualizar su perfil de aprendizaje ENTONCES el sistema DEBERÁ permitir realizar nuevas evaluaciones periódicas.
6. CUANDO se detectan cambios significativos en el comportamiento de aprendizaje ENTONCES el sistema DEBERÁ sugerir una reevaluación del perfil.
7. SI un usuario decide no realizar la evaluación inicial ENTONCES el sistema DEBERÁ construir gradualmente un perfil basado en sus interacciones posteriores.

### Requerimiento 14: Planes de Acción Tutorial Adaptativos para Aprendizaje Asíncrono

**Componente:** Backend + Frontend

**Historia de Usuario:** Como estudiante con un ritmo de aprendizaje variable, quiero que el sistema genere y adapte planes de acción tutorial de forma dinámica sin necesidad de un plan de estudios predefinido, para poder aprender de manera asíncrona según mis intereses y disponibilidad.

#### Criterios de Aceptación

1. CUANDO un usuario interactúa con contenido educativo ENTONCES el sistema DEBERÁ registrar patrones de interés y compromiso.
2. CUANDO se acumulan suficientes datos de interacción ENTONCES el sistema DEBERÁ generar automáticamente recomendaciones de aprendizaje personalizadas.
3. CUANDO un usuario completa una actividad de aprendizaje ENTONCES el sistema DEBERÁ sugerir el siguiente paso lógico basado en su progreso y objetivos.
4. CUANDO un usuario retoma su aprendizaje después de un período de inactividad ENTONCES el sistema DEBERÁ proporcionar un resumen contextual y recomendaciones actualizadas.
5. CUANDO un usuario muestra interés en un nuevo tema ENTONCES el sistema DEBERÁ integrar este tema en su plan adaptativo sin interrumpir su progreso actual.
6. CUANDO se detectan brechas de conocimiento ENTONCES el sistema DEBERÁ sugerir recursos complementarios para abordarlas.
7. SI un usuario desea más estructura ENTONCES el sistema DEBERÁ permitir la creación de planes de aprendizaje más formales a partir de sus interacciones asíncronas previas.
8. CUANDO un usuario aprende de manera asíncrona ENTONCES el sistema DEBERÁ mantener la coherencia y progresión lógica entre sesiones discontinuas.

### Requerimiento 15: Integración con Polkadot como Parachain

**Componente:** Backend

**Historia de Usuario:** Como usuario de la plataforma, quiero que Keiko funcione como una parachain en el ecosistema Polkadot, para beneficiarme de la seguridad compartida, la interoperabilidad con otras cadenas y la escalabilidad del ecosistema.

#### Criterios de Aceptación

1. CUANDO se despliega la blockchain de Keiko ENTONCES el sistema DEBERÁ implementar las interfaces necesarias para funcionar como una parachain de Polkadot.
2. CUANDO se requiere comunicación con otras parachains ENTONCES el sistema DEBERÁ utilizar XCMP (Cross-Chain Message Passing) para el intercambio de mensajes.
3. CUANDO se necesita transferir activos entre Keiko y otras parachains ENTONCES el sistema DEBERÁ implementar los estándares de Polkadot para transferencias de activos entre cadenas.
4. CUANDO se actualiza el runtime de la parachain ENTONCES el sistema DEBERÁ mantener la compatibilidad con la relay chain de Polkadot.
5. CUANDO se requiere validación de bloques ENTONCES el sistema DEBERÁ adherirse al protocolo de consenso de Polkadot.
6. CUANDO un usuario necesita interactuar con otras parachains ENTONCES el sistema DEBERÁ proporcionar una interfaz unificada para estas interacciones.
7. CUANDO se implementan nuevas funcionalidades ENTONCES el sistema DEBERÁ seguir las mejores prácticas y estándares del ecosistema Polkadot.

### Requerimiento 16: Marketplace de Espacios de Aprendizaje Seguros

**Componente:** Backend + Frontend

**Historia de Usuario:** Como estudiante o padre de familia, quiero acceder a espacios físicos seguros y autorizados para recibir tutorías presenciales, para garantizar un ambiente de aprendizaje protegido especialmente cuando trabajo con tutores nuevos o cuando requiero atención presencial por mis necesidades educativas especiales.

#### Criterios de Aceptación

1. CUANDO un estudiante necesita tutorías presenciales ENTONCES el sistema DEBERÁ ofrecer opciones de espacios de coworking y centros de estudio autorizados cercanos.
2. CUANDO un espacio de aprendizaje se registra ENTONCES el sistema DEBERÁ verificar sus credenciales, seguridad y condiciones apropiadas para la enseñanza.
3. CUANDO un tutor nuevo (con baja reputación) ofrece servicios presenciales ENTONCES el sistema DEBERÁ recomendar prioritariamente espacios seguros en lugar de domicilios.
4. CUANDO se reserva un espacio ENTONCES el sistema DEBERÁ gestionar la disponibilidad, costos y confirmación de la reserva.
5. CUANDO un estudiante tiene necesidades educativas especiales ENTONCES el sistema DEBERÁ filtrar espacios que cumplan con requisitos de accesibilidad y condiciones específicas.
6. CUANDO se completa una sesión en un espacio autorizado ENTONCES el sistema DEBERÁ permitir calificar tanto al tutor como al espacio utilizado.
7. CUANDO padres de familia buscan opciones para menores ENTONCES el sistema DEBERÁ priorizar espacios con certificaciones de seguridad infantil.
8. CUANDO un espacio acumula calificaciones negativas ENTONCES el sistema DEBERÁ revisar su autorización y tomar medidas correctivas.

### Requerimiento 17: Modelado de Sesiones Tutoriales y sus Interacciones de Aprendizaje

**Componente:** Backend + Frontend

**Historia de Usuario:** Como tutor o estudiante, quiero que el sistema distinga claramente entre una sesión tutorial completa y las múltiples interacciones de aprendizaje atómicas que ocurren durante ella, para tener un registro estructurado y detallado de cada proceso educativo.

#### Criterios de Aceptación

1. CUANDO se inicia una sesión tutorial ENTONCES el sistema DEBERÁ crear un contenedor lógico que agrupe todas las interacciones de aprendizaje relacionadas.
2. CUANDO ocurre una interacción de aprendizaje durante una tutoría ENTONCES el sistema DEBERÁ registrarla como una entidad atómica independiente pero vinculada a la sesión tutorial correspondiente.
3. CUANDO un estudiante hace una pregunta durante una tutoría ENTONCES el sistema DEBERÁ registrarla como una interacción atómica individual.
4. CUANDO un tutor proporciona una explicación ENTONCES el sistema DEBERÁ registrarla como una interacción atómica individual.
5. CUANDO se realiza un quiz de verificación durante una tutoría ENTONCES el sistema DEBERÁ registrar cada pregunta del quiz como una interacción atómica individual.
6. CUANDO finaliza una sesión tutorial ENTONCES el sistema DEBERÁ permitir una evaluación general de la sesión completa, además de las evaluaciones de interacciones individuales.
7. CUANDO se visualiza el historial de aprendizaje ENTONCES el sistema DEBERÁ permitir navegar tanto por sesiones tutoriales completas como por interacciones individuales.
8. CUANDO se califica una sesión tutorial ENTONCES el sistema DEBERÁ distinguir entre la calificación de la sesión completa y las calificaciones de interacciones específicas.
9. CUANDO un tutor registra una interacción de aprendizaje ENTONCES el sistema DEBERÁ ofrecer opciones para categorizarla dentro del contexto de la sesión tutorial.
10. CUANDO se analiza el progreso de aprendizaje ENTONCES el sistema DEBERÁ proporcionar métricas tanto a nivel de sesiones tutoriales como de interacciones individuales.
11. CUANDO se exportan datos de aprendizaje ENTONCES el sistema DEBERÁ mantener la jerarquía entre sesiones tutoriales e interacciones atómicas.

### Requerimiento 18: Arquitectura Híbrida Parachain-Microservicios

**Componente:** Blockchain + Services + API Gateway

**Historia de Usuario:** Como arquitecto de software, quiero una arquitectura híbrida donde la parachain Substrate sea la fuente de verdad y los microservicios actúen como capa de servicio, para combinar las ventajas de blockchain (inmutabilidad, consenso) con la flexibilidad de microservicios (escalabilidad, cache, APIs modernas).

#### Criterios de Aceptación

1. CUANDO se escriban datos críticos ENTONCES los microservicios DEBERÁ enviar transacciones a la parachain Substrate como fuente de verdad inmutable
2. CUANDO se lean datos frecuentemente ENTONCES los microservicios DEBERÁ servir desde cache local con fallback a RPC de parachain
3. CUANDO ocurran cambios en la parachain ENTONCES los microservicios DEBERÁ detectar eventos y actualizar cache local automáticamente
4. CUANDO se requiera comunicación entre microservicios ENTONCES DEBERÁ usar exclusivamente gRPC con service discovery
5. CUANDO se publiquen eventos de dominio ENTONCES los microservicios DEBERÁ usar Redis Streams (NUNCA la parachain)
6. CUANDO el API Gateway reciba queries GraphQL ENTONCES DEBERÁ traducir a llamadas gRPC y orquestar respuestas de múltiples microservicios
7. CUANDO se requieran subscriptions en tiempo real ENTONCES el API Gateway DEBERÁ usar Redis Streams para alimentar GraphQL subscriptions
8. CUANDO sistemas externos requieran integración ENTONCES DEBERÁ usar endpoints REST solo en el API Gateway (no en microservicios)
9. CUANDO se desplieguen microservicios ENTONCES cada uno DEBERÁ tener su propia base de datos PostgreSQL independiente
10. CUANDO se requiera observabilidad ENTONCES DEBERÁ instrumentar toda la cadena: GraphQL → gRPC → Parachain RPC

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
