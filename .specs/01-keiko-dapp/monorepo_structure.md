# Keiko Monorepo Structure

## Directory Structure

```
keiko/
├── .specs/                      # Requirements and design docs
│   └── 01-keiko-dapp/
│       ├── design.md
│       ├── requirements.md
│       └── tasks.md
│
├── backend/                     # Substrate blockchain
│   ├── node/                   
│   ├── runtime/                
│   └── pallets/               
│       ├── learning_interactions/
│       ├── reputation/
│       └── governance/
│
├── frontend/                    # Flutter app with Clean Architecture
│   ├── lib/
│   │   ├── core/
│   │   │   ├── constants/
│   │   │   ├── errors/
│   │   │   └── utils/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── learning_passport/
│   │   │   │   ├── learning_interactions/
│   │   │   │   ├── reputation/
│   │   │   │   └── governance/
│   │   │   ├── models/
│   │   │   │   ├── learning_passport.dart
│   │   │   │   ├── learning_interaction.dart
│   │   │   │   ├── reputation.dart
│   │   │   │   └── governance.dart
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── learning_passport/
│   │   │   │   ├── learning_interaction/
│   │   │   │   ├── reputation/
│   │   │   │   └── governance/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   │       ├── passport/
│   │   │       ├── learning/
│   │   │       ├── reputation/
│   │   │       └── governance/
│   │   ├── presentation/
│   │   │   ├── blocs/
│   │   │   ├── pages/
│   │   │   │   ├── passport/
│   │   │   │   ├── learning/
│   │   │   │   ├── reputation/
│   │   │   │   └── governance/
│   │   │   └── widgets/
│   │   └── di/
│   ├── test/
│   ├── pubspec.yaml
│   └── analysis_options.yaml
│
├── middleware/
│   ├── api_gateway/                 # API principal (Express/NestJS)
│   │   ├── src/
│   │   │   ├── controllers/        # Controladores REST/GraphQL
│   │   │   │   ├── passport/
│   │   │   │   ├── interactions/
│   │   │   │   └── tutoring/
│   │   │   ├── services/          # Lógica de negocio
│   │   │   │   ├── blockchain/    # Comunicación con Substrate
│   │   │   │   ├── queue/         # Cola de procesamiento
│   │   │   │   └── cache/         # Caché Redis
│   │   │   └── validators/        # Validación de datos
│   │   └── tests/
│   │
│   ├── lrs_connector/              # Integración con LRS (Learning Record Stores)
│   │   ├── src/
│   │   │   ├── adapters/          # Adaptadores específicos por LRS
│   │   │   │   ├── learning_locker/
│   │   │   │   ├── scorm_cloud/
│   │   │   │   └── moodle/
│   │   │   ├── transformers/      # Transformación de datos
│   │   │   │   ├── xapi/         # Procesamiento xAPI
│   │   │   │   └── blockchain/   # Mapeo a formatos blockchain
│   │   │   └── queue/            # Cola de reintentos
│   │   └── tests/
│   │
│   └── ai_tutor_service/          # Servicio de tutores IA
│       ├── src/
│       │   ├── models/           # Modelos de IA
│       │   ├── adapters/         # Adaptadores de LLM
│       │   └── validators/       # Validación de respuestas
│       └── tests/
│
├── shared/                     # Shared code and utilities
│   ├── types/
│   │   ├── learning/
│   │   ├── blockchain/
│   │   └── api/
│   └── utils/
│       ├── crypto/
│       ├── validation/
│       └── testing/
│
├── docs/                       # Documentation
│   ├── architecture/
│   ├── api/
│   └── deployment/
│
└── README.md
```

## Implementación del Middleware

El middleware está diseñado como un conjunto de microservicios en Node.js/TypeScript que actúan como puente entre sistemas externos y la blockchain. La arquitectura se divide en tres servicios principales:

### 1. API Gateway (NestJS)

Proporciona una API REST/GraphQL para el frontend y sistemas externos. Características clave:

- **Controllers**: Manejan requests HTTP y GraphQL
- **Services**: Implementan lógica de negocio
- **Validators**: Validan datos entrantes
- **Queue**: Procesamiento asíncrono con Bull + Redis
- **Cache**: Optimización con Redis

Ejemplo de implementación de interacciones:

```typescript
@Controller('interactions')
export class InteractionsController {
  @Post()
  async createInteraction(@Body() interaction: XAPIStatement) {
    // Validar estructura xAPI
    await this.xapiValidator.validate(interaction);
    
    // Transformar a formato blockchain
    const blockchainData = this.transformer.toBlockchain(interaction);
    
    // Enviar a cola de procesamiento
    await this.queue.add('interaction', blockchainData);
    
    // Emitir evento
    this.eventEmitter.emit('interaction.created', interaction);
  }
}
```

### 2. LRS Connector

Gestiona la integración con Learning Record Stores existentes:

- **Adapters**: Integración con diferentes LRS
- **Transformers**: Mapeo de datos
- **Queue**: Reintentos y procesamiento asíncrono

Ejemplo de sincronización:

```typescript
export class LearningLockerAdapter implements LRSAdapter {
  async sync(since: Date): Promise<void> {
    const statements = await this.fetchNewStatements(since);
    
    for (const statement of statements) {
      // Transformar a formato xAPI estándar
      const xapiStatement = this.transformer.toXAPI(statement);
      
      // Validar y enviar a blockchain
      await this.processingQueue.add('statement', xapiStatement);
    }
  }
}
```

### 3. AI Tutor Service

Gestiona tutores basados en IA:

- **Models**: Lógica de tutores IA
- **Adapters**: Integración con LLMs
- **Validators**: Control de calidad

Ejemplo de generación de respuestas:

```typescript
export class AITutorService {
  async generateResponse(
    query: string,
    learningProfile: LearningProfile
  ): Promise<TutorResponse> {
    // Adaptar al estilo de aprendizaje
    const adaptedPrompt = this.adaptToLearningStyle(
      query,
      learningProfile
    );
    
    // Generar respuesta con LLM
    const response = await this.llmService.generate(adaptedPrompt);
    
    // Validar precisión
    await this.validator.validateResponse(response);
    
    // Registrar en blockchain
    await this.blockchainService.recordInteraction({
      type: 'ai_tutoring',
      content: response,
      metadata: { 
        adaptations: learningProfile.preferences 
      }
    });
    
    return response;
  }
}
```

### Características Clave del Middleware

1. **Escalabilidad**:
   - Procesamiento asíncrono con colas
   - Caché distribuida
   - Microservicios independientes

2. **Robustez**:
   - Manejo de errores con reintentos
   - Validación en múltiples capas
   - Monitoreo y logging

3. **Extensibilidad**:
   - Arquitectura modular
   - Interfaces bien definidas
   - Fácil adición de nuevos adaptadores

4. **Rendimiento**:
   - Caché optimizada
   - Procesamiento en lotes
   - Conexiones persistentes
```