# Documento de Requerimientos

## Introducción

Keiko es una red social educativa descentralizada (DApp) construida como un monorepo que integra un backend desarrollado en Rust sobre Substrate y un frontend multiplataforma desarrollado en Flutter. Su propósito es convertir el aprendizaje en capital humano verificable e interoperable en tiempo real. La plataforma permite a cualquier individuo construir y demostrar su Pasaporte de Aprendizaje de Vida (LifeLearningPassport) en blockchain, mediante interacciones de aprendizaje atómicas (LearningInteractions) compatibles con el estándar xAPI (Tin Can). El objetivo principal es reemplazar las certificaciones tradicionales con evidencia infalsificable de aprendizaje, evaluada por múltiples actores y almacenada de forma descentralizada.

La arquitectura del proyecto se organiza en:

- **Backend**: Blockchain personalizada en Rust usando Substrate con pallets especializados
- **Frontend**: Aplicación Flutter que funciona tanto en web como en dispositivos móviles
- **Middleware**: Servicios de integración para migración de datos históricos desde LRS existentes ([Learning Locker](https://learninglocker.net/), SCORM Cloud, etc.), registro de nuevas interacciones de aprendizaje desde tutores y estudiantes, e integración con sistemas educativos externos

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

**Componente:** Middleware + Backend

**Historia de Usuario:** Como institución educativa, quiero integrar mi Learning Record Store existente con Keiko, para transferir automáticamente los registros de aprendizaje a la blockchain.

#### Criterios de Aceptación

1. CUANDO un LRS compatible envía datos a Keiko ENTONCES el sistema DEBERÁ procesar y validar estos datos.
2. CUANDO se configura la integración con un LRS ENTONCES el sistema DEBERÁ proporcionar las credenciales y endpoints necesarios.
3. CUANDO se reciben datos de Learning Locker ENTONCES el sistema DEBERÁ transformarlos al formato requerido por el pallet learning_interactions.
4. SI la conexión con el LRS falla ENTONCES el sistema DEBERÁ almacenar los datos en una cola para reintento.
5. CUANDO se actualiza el LRS ENTONCES el sistema DEBERÁ sincronizar los nuevos registros con la blockchain.

### Requerimiento 4: Ecosistema de Aprendizaje Híbrido (Humano-IA)

**Componente:** Backend + Frontend

**Historia de Usuario:** Como usuario, quiero acceder tanto a educadores humanos como a tutores basados en IA, para obtener la mejor experiencia de aprendizaje según mis necesidades y preferencias.

#### Criterios de Aceptación

1. CUANDO un usuario busca recursos educativos ENTONCES el sistema DEBERÁ ofrecer opciones tanto de tutores humanos como de agentes IA.
2. CUANDO un educador humano crea una oferta educativa ENTONCES el sistema DEBERÁ permitir establecer un precio en tokens nativos o personalizados.
3. CUANDO un usuario interactúa con un tutor IA ENTONCES el sistema DEBERÁ registrar estas interacciones en su pasaporte de aprendizaje.
4. CUANDO se completa una sesión educativa con un humano ENTONCES el sistema DEBERÁ liberar los fondos al educador automáticamente.
5. CUANDO un tutor IA proporciona contenido educativo ENTONCES el sistema DEBERÁ verificar la calidad y precisión de la información.
6. SI una sesión con educador humano es disputada ENTONCES el sistema DEBERÁ iniciar un proceso de resolución basado en la gobernanza de la comunidad.
7. CUANDO se utilizan tutores IA ENTONCES el sistema DEBERÁ permitir personalizar la experiencia según el estilo de aprendizaje del usuario.

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

**Componente:** Frontend

**Historia de Usuario:** Como usuario, quiero una aplicación Flutter que funcione tanto en web como en dispositivos móviles para visualizar mi pasaporte de aprendizaje como una línea de tiempo vertical, para poder acceder y comprender fácilmente mi progreso educativo desde cualquier dispositivo.

#### Criterios de Aceptación

1. CUANDO un usuario accede a la aplicación desde web o móvil ENTONCES el sistema DEBERÁ mostrar una visualización cronológica vertical (línea de tiempo) de su pasaporte de aprendizaje, optimizada para scroll vertical en dispositivos móviles.
2. CUANDO se visualiza el pasaporte ENTONCES el sistema DEBERÁ agrupar visualmente las interacciones de aprendizaje que pertenecen a una misma sesión tutorial.
3. CUANDO existen diferentes tipos de interacciones ENTONCES el sistema DEBERÁ diferenciar visualmente entre:
   - Sesiones tutoriales con educadores humanos
   - Sesiones con tutores IA
   - Interacciones de aprendizaje individuales (preguntas puntuales a IA)
   - Sesiones de estudio personal
4. CUANDO se selecciona una sesión tutorial en la línea de tiempo ENTONCES el sistema DEBERÁ expandir la vista para mostrar todas las interacciones de aprendizaje contenidas en ella.
5. CUANDO se selecciona una interacción específica ENTONCES el sistema DEBERÁ mostrar todos los detalles y evidencias asociadas.
6. CUANDO un usuario quiere compartir logros específicos ENTONCES el sistema DEBERÁ generar certificados visuales verificables.
7. CUANDO se accede desde diferentes dispositivos ENTONCES el sistema DEBERÁ mantener sincronización de datos y experiencia consistente, adaptando la visualización al tamaño de pantalla.
8. CUANDO la aplicación se ejecuta en móvil ENTONCES el sistema DEBERÁ aprovechar las capacidades nativas del dispositivo como notificaciones push.
9. CUANDO la aplicación se ejecuta en web ENTONCES el sistema DEBERÁ ser completamente funcional sin necesidad de instalación adicional.

### Requerimiento 8: Middleware para Integración con Sistemas Externos

**Componente:** Middleware

**Historia de Usuario:** Como desarrollador, quiero un middleware que facilite la comunicación entre sistemas externos y la blockchain de Keiko, para integrar fácilmente otras plataformas educativas y registrar nuevas interacciones de aprendizaje.

#### Criterios de Aceptación

1. CUANDO un sistema externo envía datos ENTONCES el middleware DEBERÁ validar y transformar estos datos xAPI al formato de la parachain.
2. CUANDO se procesan datos válidos ENTONCES el middleware DEBERÁ enviar extrinsics a la blockchain de Keiko.
3. CUANDO tutores o estudiantes registran nuevas interacciones ENTONCES el middleware DEBERÁ procesar y almacenar estas interacciones en la blockchain.
4. CUANDO el frontend Flutter solicita datos ENTONCES el middleware DEBERÁ proporcionar APIs REST/GraphQL para la comunicación.
5. CUANDO tutores IA generan interacciones ENTONCES el middleware DEBERÁ procesar y validar estas interacciones antes del registro.
6. CUANDO la blockchain confirma una transacción ENTONCES el middleware DEBERÁ notificar al sistema de origen.
7. SI ocurre un error en la comunicación ENTONCES el middleware DEBERÁ implementar mecanismos de reintento y notificación.
8. CUANDO se requiere escalabilidad ENTONCES el middleware DEBERÁ soportar procesamiento en lotes y paralelización.
9. CUANDO se integra con LMS existentes ENTONCES el middleware DEBERÁ ser compatible con APIs de Moodle, Canvas, Blackboard y otras plataformas educativas.

### Requerimiento 9: Interoperabilidad y Estándares Abiertos

**Componente:** Backend + Middleware

**Historia de Usuario:** Como institución educativa, quiero que Keiko utilice estándares abiertos e interoperables, para integrarme fácilmente con el ecosistema educativo existente.

#### Criterios de Aceptación

1. CUANDO se implementan nuevas funcionalidades ENTONCES el sistema DEBERÁ adherirse a estándares abiertos como xAPI.
2. CUANDO se intercambian datos con sistemas externos ENTONCES el sistema DEBERÁ utilizar formatos estándar como JSON.
3. CUANDO se desarrollan nuevas APIs ENTONCES el sistema DEBERÁ documentarlas siguiendo especificaciones OpenAPI.
4. CUANDO se requiere interoperabilidad con otras blockchains ENTONCES el sistema DEBERÁ implementar puentes compatibles.
5. CUANDO cambian los estándares de la industria ENTONCES el sistema DEBERÁ adaptarse manteniendo compatibilidad hacia atrás.

### Requerimiento 10: Seguridad y Privacidad de Datos

**Componente:** Backend + Frontend + Middleware

**Historia de Usuario:** Como usuario, quiero tener control sobre mis datos educativos y su privacidad, para proteger mi información personal mientras demuestro mis habilidades.

#### Criterios de Aceptación

1. CUANDO un usuario registra datos personales ENTONCES el sistema DEBERÁ cumplir con regulaciones de privacidad como GDPR.
2. CUANDO se almacenan datos sensibles ENTONCES el sistema DEBERÁ implementar cifrado y técnicas de minimización de datos.
3. CUANDO un usuario quiere controlar la visibilidad de su información ENTONCES el sistema DEBERÁ ofrecer configuraciones granulares de privacidad.
4. CUANDO se comparten datos con terceros ENTONCES el sistema DEBERÁ requerir consentimiento explícito del usuario.
5. SI se detecta una brecha de seguridad ENTONCES el sistema DEBERÁ notificar a los usuarios afectados y tomar medidas correctivas inmediatas.

### Requerimiento 11: Tutores IA Avanzados

**Componente:** Backend + Frontend + Middleware

**Historia de Usuario:** Como estudiante, quiero acceder a tutores IA especializados que puedan adaptarse a mi estilo de aprendizaje y necesidades específicas, para maximizar mi progreso educativo sin depender exclusivamente de educadores humanos.

#### Criterios de Aceptación

1. CUANDO un usuario solicita asistencia educativa ENTONCES el sistema DEBERÁ proporcionar tutores IA con conocimientos especializados en el tema requerido.
2. CUANDO un tutor IA interactúa con un estudiante ENTONCES el sistema DEBERÁ adaptar el contenido y metodología según el perfil de aprendizaje del estudiante.
3. CUANDO un tutor IA proporciona información ENTONCES el sistema DEBERÁ verificar su precisión y actualidad antes de presentarla al estudiante.
4. CUANDO un estudiante interactúa repetidamente con tutores IA ENTONCES el sistema DEBERÁ mejorar progresivamente la personalización basándose en el historial de interacciones.
5. CUANDO un tutor IA identifica dificultades de aprendizaje ENTONCES el sistema DEBERÁ sugerir recursos adicionales o metodologías alternativas.
6. SI un tutor IA no puede resolver una consulta compleja ENTONCES el sistema DEBERÁ ofrecer la opción de conectar con un educador humano especializado.
7. CUANDO se utilizan tutores IA ENTONCES el sistema DEBERÁ garantizar transparencia sobre la naturaleza artificial del tutor.

### Requerimiento 12: Evaluación Pedagógica Inicial

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

### Requerimiento 13: Planes de Acción Tutorial Adaptativos para Aprendizaje Asíncrono

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

### Requerimiento 14: Integración con Polkadot como Parachain

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

### Requerimiento 15: Marketplace de Espacios de Aprendizaje Seguros

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

### Requerimiento 16: Modelado de Sesiones Tutoriales y sus Interacciones de Aprendizaje

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

### Requerimiento 17: Jerarquía Completa de Experiencias de Aprendizaje

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
