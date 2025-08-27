# Requirements Document

## Introduction

Este documento define los requerimientos para la migración del backend monolítico de Keiko (Substrate parachain) hacia una arquitectura de microservicios cloud-native desplegada en OVHCloud Managed Kubernetes. La migración incluye la implementación de CI/CD automatizado usando GitOps con Terraform para infraestructura y ArgoCD para aplicaciones.

El objetivo es transformar el monolito actual de Substrate que contiene todos los pallets en un solo runtime, hacia servicios independientes que mantengan las ventajas de blockchain mientras ganan flexibilidad, escalabilidad y capacidad de desarrollo paralelo por equipos.

## Requirements

### Requirement 1: Arquitectura de Microservicios

**User Story:** Como arquitecto de software, quiero descomponer el monolito de Substrate en microservicios independientes, para que cada dominio de negocio pueda desarrollarse, desplegarse y escalarse de forma autónoma.

#### Acceptance Criteria

1. CUANDO se identifiquen los bounded contexts ENTONCES el sistema DEBERÁ separar cada pallet actual en un servicio independiente
2. CUANDO se implemente la separación ENTONCES cada servicio DEBERÁ tener su propia base de datos siguiendo el patrón Database per Service
3. CUANDO se comuniquen los servicios ENTONCES DEBERÁ usar APIs REST/GraphQL bien definidas y event-driven architecture
4. CUANDO se desplieguen los servicios ENTONCES cada uno DEBERÁ ser containerizado y desplegable independientemente
5. SI un servicio falla ENTONCES los otros servicios DEBERÁ continuar funcionando (fault isolation)

### Requirement 2: Patrones de Migración Gradual

**User Story:** Como DevOps engineer, quiero implementar una migración gradual del monolito usando patrones probados, para que la transición sea controlada y sin interrupciones de servicio.

#### Acceptance Criteria

1. CUANDO se inicie la migración ENTONCES DEBERÁ implementarse el Strangler Fig Pattern para dirigir tráfico gradualmente
2. CUANDO se creen abstracciones ENTONCES DEBERÁ usarse Branch by Abstraction Pattern para permitir implementaciones duales
3. CUANDO se organicen los equipos ENTONCES DEBERÁ aplicarse Service per Team Pattern con repositorios independientes
4. CUANDO se migre un servicio ENTONCES DEBERÁ mantener sincronización de datos durante la transición
5. CUANDO se complete la migración de un servicio ENTONCES DEBERÁ eliminarse el código legacy correspondiente

### Requirement 3: Infraestructura como Código con Terraform

**User Story:** Como DevOps engineer, quiero gestionar toda la infraestructura de OVHCloud usando Terraform, para que el aprovisionamiento sea reproducible, versionado y automatizado.

#### Acceptance Criteria

1. CUANDO se provisione infraestructura ENTONCES Terraform DEBERÁ crear tres clusters de Kubernetes en OVHCloud: "keikolatam-dev", "keikolatam-staging", "keikolatam-production"
2. CUANDO se configuren recursos ENTONCES DEBERÁ incluir bases de datos PostgreSQL independientes por servicio en cada entorno
3. CUANDO se desplieguen los clusters ENTONCES DEBERÁ configurar node pools diferenciados (system y applications) con sizing apropiado por entorno
4. CUANDO se gestione el estado ENTONCES Terraform DEBERÁ usar remote state backend separado por entorno en OVH Object Storage (buckets: keikolatam-terraform-state-dev/staging/prod)
5. CUANDO se actualice infraestructura ENTONCES DEBERÁ seguir el principio de immutable infrastructure y promote changes dev → staging → production

### Requirement 4: GitOps con ArgoCD

**User Story:** Como desarrollador, quiero que los deployments de aplicaciones sean automáticos y declarativos usando GitOps, para que cualquier cambio en Git se refleje automáticamente en el cluster.

#### Acceptance Criteria

1. CUANDO se instale ArgoCD ENTONCES DEBERÁ configurarse automáticamente via Terraform en cada cluster (dev, staging, production)
2. CUANDO se implemente App of Apps ENTONCES ArgoCD DEBERÁ gestionar todas las aplicaciones desde repositorios centrales con overlays por entorno
3. CUANDO se actualice código ENTONCES DEBERÁ triggear automáticamente el rebuild y redeploy siguiendo el flujo dev → staging → production
4. CUANDO se detecten cambios en Git ENTONCES ArgoCD DEBERÁ sincronizar automáticamente el estado del cluster correspondiente
5. CUANDO ocurra drift configuration ENTONCES ArgoCD DEBERÁ auto-heal y restaurar el estado deseado en cada entorno

### Requirement 5: Servicios Independientes por Dominio

**User Story:** Como desarrollador de backend, quiero que cada dominio de negocio tenga su propio servicio independiente, para que pueda desarrollar y desplegar sin afectar otros dominios.

#### Acceptance Criteria

1. CUANDO se extraiga Identity Service ENTONCES DEBERÁ gestionar autenticación, autorización y perfiles de usuario
2. CUANDO se extraiga Learning Service ENTONCES DEBERÁ procesar xAPI statements y interacciones de aprendizaje
3. CUANDO se extraiga Reputation Service ENTONCES DEBERÁ calcular y gestionar reputación de tutores y estudiantes
4. CUANDO se extraiga Passport Service ENTONCES DEBERÁ agregar competencias y gestionar pasaportes de aprendizaje
5. CUANDO se creen nuevos servicios ENTONCES DEBERÁ incluir Governance Service y Marketplace Service

### Requirement 6: Observabilidad y Monitoreo

**User Story:** Como SRE, quiero tener visibilidad completa del sistema distribuido, para que pueda monitorear, debuggear y optimizar el rendimiento de todos los servicios.

#### Acceptance Criteria

1. CUANDO se desplieguen servicios ENTONCES DEBERÁ implementar distributed tracing con Jaeger
2. CUANDO se generen logs ENTONCES DEBERÁ agregarse centralizadamente usando ELK Stack
3. CUANDO se recolecten métricas ENTONCES DEBERÁ usar Prometheus y visualizarse en Grafana
4. CUANDO se expongan health checks ENTONCES cada servicio DEBERÁ tener endpoints /health y /ready
5. CUANDO ocurran errores ENTONCES DEBERÁ implementar alerting automático via Prometheus AlertManager

### Requirement 7: Seguridad y Configuración

**User Story:** Como security engineer, quiero que la configuración sensible esté externalizada y segura, para que no haya credenciales hardcodeadas y se sigan las mejores prácticas de seguridad.

#### Acceptance Criteria

1. CUANDO se configure servicios ENTONCES DEBERÁ usar ConfigMaps de Kubernetes para configuración no sensible
2. CUANDO se gestionen credenciales ENTONCES DEBERÁ usar Secrets de Kubernetes para datos sensibles
3. CUANDO se autentiquen servicios ENTONCES DEBERÁ implementar service-to-service authentication con JWT
4. CUANDO se expongan APIs ENTONCES DEBERÁ implementar rate limiting y API authentication
5. CUANDO se acceda a bases de datos ENTONCES DEBERÁ usar connection pooling y encrypted connections

### Requirement 8: CI/CD Pipeline Automatizado

**User Story:** Como desarrollador, quiero que cada servicio tenga su propio pipeline de CI/CD, para que pueda desplegar cambios de forma rápida y segura sin afectar otros servicios.

#### Acceptance Criteria

1. CUANDO se haga commit a develop ENTONCES DEBERÁ triggear automáticamente deploy a dev, commit a staging DEBERÁ deploy a staging, commit a main DEBERÁ deploy a production
2. CUANDO se construya imagen ENTONCES DEBERÁ taggearse con commit SHA y pushearse al registry de OVH (registry.gra.cloud.ovh.net/keikolatam/)
3. CUANDO se actualice imagen ENTONCES DEBERÁ modificar automáticamente los manifiestos de Kubernetes del entorno correspondiente
4. CUANDO se ejecuten tests ENTONCES DEBERÁ incluir unit tests en dev, integration tests en staging, y smoke tests en production
5. CUANDO falle el pipeline ENTONCES DEBERÁ notificar automáticamente, bloquear promoción a siguiente entorno y permitir rollback

### Requirement 9: Resiliencia y Tolerancia a Fallos

**User Story:** Como arquitecto de software, quiero que el sistema sea resiliente a fallos, para que la indisponibilidad de un servicio no afecte la funcionalidad completa del sistema.

#### Acceptance Criteria

1. CUANDO un servicio no responda ENTONCES DEBERÁ implementar Circuit Breaker Pattern para evitar cascading failures
2. CUANDO ocurran errores transitorios ENTONCES DEBERÁ implementar retry policies con exponential backoff
3. CUANDO se pierda conectividad ENTONCES DEBERÁ implementar graceful degradation de funcionalidades
4. CUANDO se sobrecargue un servicio ENTONCES DEBERÁ implementar rate limiting y load shedding
5. CUANDO se reinicie un servicio ENTONCES DEBERÁ implementar graceful shutdown y startup

### Requirement 10: Event-Driven Communication

**User Story:** Como desarrollador de backend, quiero que los servicios se comuniquen de forma asíncrona usando eventos, para que el sistema sea más resiliente y desacoplado.

#### Acceptance Criteria

1. CUANDO ocurra un evento de dominio ENTONCES DEBERÁ publicarse en el event bus para notificar servicios interesados
2. CUANDO se procesen eventos ENTONCES DEBERÁ garantizar at-least-once delivery y idempotencia
3. CUANDO se definan eventos ENTONCES DEBERÁ seguir un schema versionado y backward compatible
4. CUANDO se suscriban servicios ENTONCES DEBERÁ implementar dead letter queues para eventos fallidos
5. CUANDO se implemente event sourcing ENTONCES DEBERÁ mantener audit trail completo de cambios de estado