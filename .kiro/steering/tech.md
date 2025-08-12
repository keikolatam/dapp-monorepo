# Technology Stack

## Architecture Overview

Keiko follows a monorepo structure with three main layers:

- **Backend**: Substrate-based parachain (Rust)
- **Frontend**: Flutter mobile/web app (Dart)
- **Middleware**: Node.js services for integration

## Backend (Substrate Parachain)

**Framework**: Substrate (Rust)
**Build System**: Cargo workspace
**Key Components**:

- Custom pallets for learning interactions, reputation, and governance
- Polkadot parachain integration
- xAPI-compatible data structures

### Common Commands

```bash
# Build the parachain
cargo build --release

# Run development node
cargo run --release -- --dev

# Run tests
cargo test

# Check code
cargo clippy
```

## Frontend (Flutter)

**Framework**: Flutter (Dart)
**Architecture**: Clean Architecture with BLoC pattern
**Key Dependencies**:

- `flutter_bloc` - State management
- `polkadot_dart` - Blockchain connectivity
- `jitsi_meet_flutter_sdk` - Video calling for tutoring
- `web3dart` - Web3 integration

### Common Commands

```bash
# Install dependencies
flutter pub get

# Run development
flutter run

# Build for production
flutter build apk
flutter build web

# Run tests
flutter test

# Generate code
flutter packages pub run build_runner build
```

## Middleware (Node.js)

**Framework**: NestJS (TypeScript)
**Key Services**:

- API Gateway - Request routing and authentication
- AI Tutor Service - LLM integration
- LRS Connector - Legacy system integration
- Parachain Bridge - Direct blockchain communication

**Dependencies**:

- `@polkadot/api` - Substrate connectivity
- `bull` + `redis` - Job queues
- `class-validator` - Input validation
- `@nestjs/graphql` - GraphQL API
- `axios` - HTTP client for external APIs

### Common Commands

```bash
# Install dependencies
yarn install

# Development mode
yarn dev

# Build all services
yarn build

# Run tests
yarn test

# Lint code
yarn lint
```

### Implementation Examples

#### API Gateway Controller

```typescript
@Controller("interactions")
export class InteractionsController {
  @Post()
  async createInteraction(@Body() interaction: XAPIStatement) {
    // Validar estructura xAPI
    await this.xapiValidator.validate(interaction);

    // Transformar a formato blockchain
    const blockchainData = this.transformer.toBlockchain(interaction);

    // Enviar a cola de procesamiento
    await this.queue.add("interaction", blockchainData);

    // Emitir evento
    this.eventEmitter.emit("interaction.created", interaction);
  }
}
```

#### LRS Connector Service

```typescript
export class LearningLockerAdapter implements LRSAdapter {
  async sync(since: Date): Promise<void> {
    const statements = await this.fetchNewStatements(since);

    for (const statement of statements) {
      // Transformar a formato xAPI estándar
      const xapiStatement = this.transformer.toXAPI(statement);

      // Validar y enviar a blockchain
      await this.processingQueue.add("statement", xapiStatement);
    }
  }
}
```

#### AI Tutor Service

```typescript
export class AITutorService {
  async generateResponse(
    query: string,
    learningProfile: LearningProfile
  ): Promise<TutorResponse> {
    // Adaptar al estilo de aprendizaje
    const adaptedPrompt = this.adaptToLearningStyle(query, learningProfile);

    // Generar respuesta con LLM
    const response = await this.llmService.generate(adaptedPrompt);

    // Validar precisión
    await this.validator.validateResponse(response);

    // Registrar en blockchain
    await this.blockchainService.recordInteraction({
      type: "ai_tutoring",
      content: response,
      metadata: {
        adaptations: learningProfile.preferences,
      },
    });

    return response;
  }
}
```

### Middleware Architecture Principles

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

## Development Workflow

1. **Blockchain First**: Start with pallet development and testing
2. **API Integration**: Build middleware services for blockchain interaction
3. **Frontend Last**: Implement UI with proper state management
4. **Testing**: Unit tests for pallets, integration tests for services

## Key Technologies

- **Blockchain**: Substrate, Polkadot, FRAME pallets
- **Mobile**: Flutter, Dart, BLoC pattern
- **Backend Services**: NestJS, TypeScript, Redis
- **Video Calling**: Jitsi Meet, Agora.io
- **Standards**: xAPI (Tin Can API) for learning records
