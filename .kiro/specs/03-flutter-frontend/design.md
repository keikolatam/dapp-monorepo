# Documento de Diseño - Frontend Flutter con Clean Architecture y Riverpod

## Visión General

Este documento define la arquitectura del frontend Flutter para Keiko DApp, implementando Clean Architecture con Riverpod como solución de gestión de estado y inyección de dependencias. La aplicación será multiplataforma (web, Android, iOS) y se comunicará exclusivamente con el API Gateway GraphQL.

## Arquitectura por Capas

### Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    CAPA DE PRESENTACIÓN                     │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐│
│  │   Pages/Screens │ │     Widgets     │ │   Controllers   ││
│  │                 │ │                 │ │                 ││
│  │ ConsumerWidget  │ │ Consumer        │ │ StateNotifier   ││
│  │ AsyncValue      │ │ AsyncValue      │ │ AsyncNotifier   ││
│  └─────────────────┘ └─────────────────┘ └─────────────────┘│
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                CAPA DE LÓGICA DE NEGOCIO                    │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐│
│  │   Use Cases     │ │   Validators    │ │   Mappers       ││
│  │                 │ │                 │ │                 ││
│  │ Provider        │ │ Provider        │ │ Provider        ││
│  │ StateNotifier   │ │ Pure Functions  │ │ Pure Functions  ││
│  └─────────────────┘ └─────────────────┘ └─────────────────┘│
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   CAPA DE REPOSITORIO                       │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐│
│  │  Repositories   │ │   Interfaces    │ │   Cache Logic   ││
│  │                 │ │                 │ │                 ││
│  │ Provider        │ │ Abstract Class  │ │ Provider        ││
│  │ Implementation  │ │ Contracts       │ │ Hive/Memory     ││
│  └─────────────────┘ └─────────────────┘ └─────────────────┘│
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                CAPA DE FUENTES DE DATOS                     │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐│
│  │ GraphQL Client  │ │  Local Storage  │ │ Secure Storage  ││
│  │                 │ │                 │ │                 ││
│  │ Provider        │ │ Hive Provider   │ │ Provider        ││
│  │ graphql_flutter │ │ Cache           │ │ Tokens/Keys     ││
│  └─────────────────┘ └─────────────────┘ └─────────────────┘│
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      API GATEWAY                            │
│                    (GraphQL Endpoint)                       │
└─────────────────────────────────────────────────────────────┘
```

### Flujo de Datos con Riverpod

```
UI Widget (ConsumerWidget)
    │
    │ watch(provider)
    ▼
StateNotifier/AsyncNotifier (Business Logic)
    │
    │ read(repositoryProvider)
    ▼
Repository (Provider)
    │
    │ read(dataSourceProvider)
    ▼
GraphQL Client (Provider)
    │
    │ HTTP/WebSocket
    ▼
API Gateway (Backend)
```

## Estructura de Proyecto

```
frontend/lib/
├── main.dart                          # Entry point con ProviderScope
├── app/                               # Configuración global de la app
│   ├── app.dart                       # Widget principal de la app
│   ├── router/                        # Configuración de navegación
│   │   ├── app_router.dart           # go_router configuration
│   │   └── route_names.dart          # Constantes de rutas
│   └── theme/                         # Tema y estilos
│       ├── app_theme.dart
│       └── theme_constants.dart
├── core/                              # Núcleo compartido
│   ├── constants/                     # Constantes globales
│   ├── errors/                        # Manejo de errores
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── network/                       # Configuración de red
│   │   ├── graphql_client.dart
│   │   └── network_info.dart
│   ├── storage/                       # Almacenamiento local
│   │   ├── hive_storage.dart
│   │   └── secure_storage.dart
│   └── utils/                         # Utilidades
│       ├── validators.dart
│       └── formatters.dart
├── shared/                            # Componentes compartidos
│   ├── providers/                     # Providers globales
│   │   ├── auth_provider.dart
│   │   └── connectivity_provider.dart
│   ├── widgets/                       # Widgets reutilizables
│   │   ├── loading_widget.dart
│   │   ├── error_widget.dart
│   │   └── timeline_widget.dart
│   └── models/                        # Modelos compartidos
│       └── base_model.dart
└── features/                          # Características por dominio
    ├── auth/                          # Autenticación
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── auth_remote_datasource.dart
    │   │   ├── models/
    │   │   │   └── user_model.dart
    │   │   └── repositories/
    │   │       └── auth_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── user.dart
    │   │   ├── repositories/
    │   │   │   └── auth_repository.dart
    │   │   └── usecases/
    │   │       ├── login_usecase.dart
    │   │       └── logout_usecase.dart
    │   └── presentation/
    │       ├── providers/
    │       │   └── auth_provider.dart
    │       ├── pages/
    │       │   ├── login_page.dart
    │       │   └── register_page.dart
    │       └── widgets/
    │           └── login_form.dart
    ├── passport/                      # Pasaporte de aprendizaje
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── passport_remote_datasource.dart
    │   │   ├── models/
    │   │   │   ├── learning_interaction_model.dart
    │   │   │   ├── passport_model.dart
    │   │   │   ├── course_model.dart
    │   │   │   └── tutorial_session_model.dart
    │   │   └── repositories/
    │   │       └── passport_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── learning_interaction.dart
    │   │   │   ├── passport.dart
    │   │   │   ├── course.dart
    │   │   │   └── tutorial_session.dart
    │   │   ├── repositories/
    │   │   │   └── passport_repository.dart
    │   │   └── usecases/
    │   │       ├── get_passport_timeline.dart
    │   │       ├── share_achievement.dart
    │   │       ├── get_course_hierarchy.dart
    │   │       └── filter_interactions.dart
    │   └── presentation/
    │       ├── providers/
    │       │   ├── passport_provider.dart
    │       │   ├── timeline_provider.dart
    │       │   └── hierarchy_provider.dart
    │       ├── pages/
    │       │   ├── passport_page.dart
    │       │   ├── timeline_page.dart
    │       │   └── course_detail_page.dart
    │       └── widgets/
    │           ├── timeline_item.dart
    │           ├── interaction_card.dart
    │           ├── course_card.dart
    │           └── hierarchy_navigator.dart
    ├── tutoring/                      # Sistema de tutorías
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── tutoring_remote_datasource.dart
    │   │   ├── models/
    │   │   │   ├── tutorial_session_model.dart
    │   │   │   └── tutor_model.dart
    │   │   └── repositories/
    │   │       └── tutoring_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── tutorial_session.dart
    │   │   │   ├── tutor.dart
    │   │   │   └── ai_tutor.dart
    │   │   ├── repositories/
    │   │   │   └── tutoring_repository.dart
    │   │   └── usecases/
    │   │       ├── book_session.dart
    │   │       ├── start_session.dart
    │   │       ├── end_session.dart
    │   │       └── chat_with_ai.dart
    │   └── presentation/
    │       ├── providers/
    │       │   ├── tutoring_provider.dart
    │       │   └── chat_provider.dart
    │       ├── pages/
    │       │   ├── tutoring_page.dart
    │       │   └── chat_page.dart
    │       └── widgets/
    │           ├── chat_bubble.dart
    │           └── tutor_card.dart
    ├── reputation/                    # Sistema de reputación
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── reputation_remote_datasource.dart
    │   │   ├── models/
    │   │   │   ├── rating_model.dart
    │   │   │   └── reputation_score_model.dart
    │   │   └── repositories/
    │   │       └── reputation_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── rating.dart
    │   │   │   └── reputation_score.dart
    │   │   ├── repositories/
    │   │   │   └── reputation_repository.dart
    │   │   └── usecases/
    │   │       ├── rate_user.dart
    │   │       ├── get_reputation.dart
    │   │       └── get_rating_history.dart
    │   └── presentation/
    │       ├── providers/
    │       │   └── reputation_provider.dart
    │       ├── pages/
    │       │   ├── reputation_page.dart
    │       │   └── rating_page.dart
    │       └── widgets/
    │           ├── reputation_badge.dart
    │           └── rating_form.dart
    ├── assessment/                    # Evaluación pedagógica inicial
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── assessment_remote_datasource.dart
    │   │   ├── models/
    │   │   │   ├── learning_profile_model.dart
    │   │   │   └── assessment_model.dart
    │   │   └── repositories/
    │   │       └── assessment_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── learning_profile.dart
    │   │   │   └── assessment.dart
    │   │   ├── repositories/
    │   │   │   └── assessment_repository.dart
    │   │   └── usecases/
    │   │       ├── take_assessment.dart
    │   │       ├── generate_profile.dart
    │   │       └── update_profile.dart
    │   └── presentation/
    │       ├── providers/
    │       │   └── assessment_provider.dart
    │       ├── pages/
    │       │   ├── assessment_page.dart
    │       │   └── profile_page.dart
    │       └── widgets/
    │           ├── assessment_question.dart
    │           └── profile_visualization.dart
    ├── adaptive_plans/                # Planes adaptativos de aprendizaje
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── adaptive_plans_remote_datasource.dart
    │   │   ├── models/
    │   │   │   ├── learning_plan_model.dart
    │   │   │   └── recommendation_model.dart
    │   │   └── repositories/
    │   │       └── adaptive_plans_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── learning_plan.dart
    │   │   │   └── recommendation.dart
    │   │   ├── repositories/
    │   │   │   └── adaptive_plans_repository.dart
    │   │   └── usecases/
    │   │       ├── generate_recommendations.dart
    │   │       ├── update_plan.dart
    │   │       └── track_progress.dart
    │   └── presentation/
    │       ├── providers/
    │       │   └── adaptive_plans_provider.dart
    │       ├── pages/
    │       │   ├── learning_plan_page.dart
    │       │   └── recommendations_page.dart
    │       └── widgets/
    │           ├── recommendation_card.dart
    │           └── progress_visualization.dart
    └── marketplace/                   # Marketplace de espacios seguros
        ├── data/
        │   ├── datasources/
        │   │   └── marketplace_remote_datasource.dart
        │   ├── models/
        │   │   ├── learning_space_model.dart
        │   │   └── reservation_model.dart
        │   └── repositories/
        │       └── marketplace_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   ├── learning_space.dart
        │   │   └── reservation.dart
        │   ├── repositories/
        │   │   └── marketplace_repository.dart
        │   └── usecases/
        │       ├── search_spaces.dart
        │       ├── book_space.dart
        │       └── rate_space.dart
        └── presentation/
            ├── providers/
            │   └── marketplace_provider.dart
            ├── pages/
            │   ├── marketplace_page.dart
            │   ├── space_detail_page.dart
            │   └── booking_page.dart
            └── widgets/
                ├── space_card.dart
                ├── map_view.dart
                └── booking_form.dart
```

## Implementación de Riverpod por Capas

### 1. Capa de Fuentes de Datos (Data Sources)

```dart
// GraphQL Client Provider
final graphqlClientProvider = Provider<GraphQLClient>((ref) {
  final httpLink = HttpLink('https://api.keiko.com/graphql');
  final authLink = AuthLink(getToken: () async {
    final authState = ref.read(authProvider);
    return authState.token;
  });
  
  final link = authLink.concat(httpLink);
  
  return GraphQLClient(
    cache: GraphQLCache(store: HiveStore()),
    link: link,
  );
});

// Local Storage Provider
final hiveStorageProvider = Provider<HiveStorage>((ref) {
  return HiveStorage();
});

// Secure Storage Provider
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});
```

### 2. Capa de Repositorio

```dart
// Abstract Repository
abstract class PassportRepository {
  Future<Either<Failure, Passport>> getPassport(String userId);
  Future<Either<Failure, List<LearningInteraction>>> getTimeline(String userId);
  Stream<List<LearningInteraction>> watchTimeline(String userId);
}

// Repository Implementation Provider
final passportRepositoryProvider = Provider<PassportRepository>((ref) {
  final remoteDataSource = ref.read(passportRemoteDataSourceProvider);
  final localDataSource = ref.read(passportLocalDataSourceProvider);
  
  return PassportRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

// Repository Implementation
class PassportRepositoryImpl implements PassportRepository {
  final PassportRemoteDataSource remoteDataSource;
  final PassportLocalDataSource localDataSource;
  
  PassportRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  
  @override
  Future<Either<Failure, Passport>> getPassport(String userId) async {
    try {
      // Try cache first
      final cachedPassport = await localDataSource.getCachedPassport(userId);
      if (cachedPassport != null) {
        return Right(cachedPassport.toEntity());
      }
      
      // Fetch from remote
      final remotePassport = await remoteDataSource.getPassport(userId);
      
      // Cache the result
      await localDataSource.cachePassport(remotePassport);
      
      return Right(remotePassport.toEntity());
    } on ServerException {
      return Left(ServerFailure());
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
```

### 3. Capa de Lógica de Negocio (Use Cases)

```dart
// Use Case Provider
final getPassportTimelineProvider = Provider<GetPassportTimeline>((ref) {
  final repository = ref.read(passportRepositoryProvider);
  return GetPassportTimeline(repository);
});

// Use Case Implementation
class GetPassportTimeline {
  final PassportRepository repository;
  
  GetPassportTimeline(this.repository);
  
  Future<Either<Failure, List<LearningInteraction>>> call(
    GetPassportTimelineParams params,
  ) async {
    return await repository.getTimeline(params.userId);
  }
}

// Business Logic Provider (StateNotifier)
final passportNotifierProvider = 
    StateNotifierProvider<PassportNotifier, PassportState>((ref) {
  final getPassportTimeline = ref.read(getPassportTimelineProvider);
  final shareAchievement = ref.read(shareAchievementProvider);
  
  return PassportNotifier(
    getPassportTimeline: getPassportTimeline,
    shareAchievement: shareAchievement,
  );
});

class PassportNotifier extends StateNotifier<PassportState> {
  final GetPassportTimeline getPassportTimeline;
  final ShareAchievement shareAchievement;
  
  PassportNotifier({
    required this.getPassportTimeline,
    required this.shareAchievement,
  }) : super(const PassportState.initial());
  
  Future<void> loadTimeline(String userId) async {
    state = const PassportState.loading();
    
    final result = await getPassportTimeline(
      GetPassportTimelineParams(userId: userId),
    );
    
    result.fold(
      (failure) => state = PassportState.error(failure.message),
      (timeline) => state = PassportState.loaded(timeline),
    );
  }
}
```

### 4. Capa de Presentación

```dart
// UI Widget consuming state
class PassportPage extends ConsumerWidget {
  const PassportPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passportState = ref.watch(passportNotifierProvider);
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Pasaporte de Aprendizaje')),
      body: passportState.when(
        initial: () => const Center(child: Text('Carga tu pasaporte')),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (timeline) => TimelineView(interactions: timeline),
        error: (message) => ErrorWidget(message: message),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(passportNotifierProvider.notifier)
              .loadTimeline(authState.user!.id);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// Optimized widget with select
class TimelineView extends ConsumerWidget {
  final List<LearningInteraction> interactions;
  
  const TimelineView({Key? key, required this.interactions}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuild when filter changes, not entire passport state
    final filter = ref.watch(
      passportNotifierProvider.select((state) => state.filter),
    );
    
    final filteredInteractions = interactions
        .where((interaction) => filter.matches(interaction))
        .toList();
    
    return ListView.builder(
      itemCount: filteredInteractions.length,
      itemBuilder: (context, index) {
        return InteractionCard(
          interaction: filteredInteractions[index],
        );
      },
    );
  }
}
```

## Gestión de Estado Avanzada

### AsyncNotifier para Operaciones Asíncronas

```dart
// AsyncNotifier for complex async operations
final passportAsyncProvider = 
    AsyncNotifierProvider<PassportAsyncNotifier, List<LearningInteraction>>(() {
  return PassportAsyncNotifier();
});

class PassportAsyncNotifier extends AsyncNotifier<List<LearningInteraction>> {
  @override
  Future<List<LearningInteraction>> build() async {
    // Initial load
    final authState = ref.read(authProvider);
    if (authState.user == null) return [];
    
    return _loadTimeline(authState.user!.id);
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    
    try {
      final authState = ref.read(authProvider);
      final timeline = await _loadTimeline(authState.user!.id);
      state = AsyncValue.data(timeline);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<List<LearningInteraction>> _loadTimeline(String userId) async {
    final repository = ref.read(passportRepositoryProvider);
    final result = await repository.getTimeline(userId);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (timeline) => timeline,
    );
  }
}
```

### Providers Familiares para Datos Relacionados

```dart
// Family provider for user-specific data
final userPassportProvider = FutureProvider.family<Passport, String>((ref, userId) async {
  final repository = ref.read(passportRepositoryProvider);
  final result = await repository.getPassport(userId);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (passport) => passport,
  );
});

// Usage in UI
class UserPassportWidget extends ConsumerWidget {
  final String userId;
  
  const UserPassportWidget({Key? key, required this.userId}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passportAsync = ref.watch(userPassportProvider(userId));
    
    return passportAsync.when(
      data: (passport) => PassportView(passport: passport),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => ErrorView(error: error),
    );
  }
}
```

## Comunicación con Backend GraphQL

### GraphQL Operations

```dart
// GraphQL Queries
const String GET_PASSPORT_TIMELINE = '''
  query GetPassportTimeline(\$userId: ID!, \$limit: Int, \$offset: Int) {
    user(id: \$userId) {
      passport {
        interactions(limit: \$limit, offset: \$offset) {
          id
          timestamp
          category
          verb {
            id
            display
          }
          object {
            id
            definition {
              name
              description
            }
          }
          result {
            score {
              scaled
              raw
            }
            success
            completion
          }
        }
      }
    }
  }
''';

// GraphQL Mutations
const String CREATE_INTERACTION = '''
  mutation CreateInteraction(\$input: CreateInteractionInput!) {
    createInteraction(input: \$input) {
      id
      timestamp
      category
    }
  }
''';

// GraphQL Subscriptions
const String PASSPORT_UPDATES = '''
  subscription PassportUpdates(\$userId: ID!) {
    passportUpdated(userId: \$userId) {
      interaction {
        id
        timestamp
        category
      }
    }
  }
''';
```

### Repository con GraphQL

```dart
class PassportRemoteDataSource {
  final GraphQLClient client;
  
  PassportRemoteDataSource({required this.client});
  
  Future<PassportModel> getPassport(String userId) async {
    final result = await client.query(QueryOptions(
      document: gql(GET_PASSPORT_TIMELINE),
      variables: {'userId': userId},
    ));
    
    if (result.hasException) {
      throw ServerException(result.exception.toString());
    }
    
    return PassportModel.fromJson(result.data!['user']['passport']);
  }
  
  Stream<LearningInteractionModel> watchPassportUpdates(String userId) {
    return client.subscribe(SubscriptionOptions(
      document: gql(PASSPORT_UPDATES),
      variables: {'userId': userId},
    )).map((result) {
      if (result.hasException) {
        throw ServerException(result.exception.toString());
      }
      
      return LearningInteractionModel.fromJson(
        result.data!['passportUpdated']['interaction'],
      );
    });
  }
}
```

## Testing con Riverpod

### Override de Providers para Testing

```dart
void main() {
  group('PassportNotifier Tests', () {
    late ProviderContainer container;
    late MockPassportRepository mockRepository;
    
    setUp(() {
      mockRepository = MockPassportRepository();
      container = ProviderContainer(
        overrides: [
          passportRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });
    
    tearDown(() {
      container.dispose();
    });
    
    test('should load timeline successfully', () async {
      // Arrange
      const userId = 'user123';
      final expectedTimeline = [
        LearningInteraction(id: '1', timestamp: DateTime.now()),
      ];
      
      when(() => mockRepository.getTimeline(userId))
          .thenAnswer((_) async => Right(expectedTimeline));
      
      // Act
      final notifier = container.read(passportNotifierProvider.notifier);
      await notifier.loadTimeline(userId);
      
      // Assert
      final state = container.read(passportNotifierProvider);
      expect(state, isA<PassportStateLoaded>());
      expect((state as PassportStateLoaded).timeline, expectedTimeline);
    });
  });
}
```

### Widget Testing con Providers

```dart
void main() {
  group('PassportPage Widget Tests', () {
    testWidgets('should show loading indicator when loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            passportNotifierProvider.overrideWith(() => PassportNotifier(
              getPassportTimeline: MockGetPassportTimeline(),
              shareAchievement: MockShareAchievement(),
            )),
          ],
          child: MaterialApp(home: PassportPage()),
        ),
      );
      
      // Trigger loading
      final notifier = tester.binding.defaultBinaryMessenger;
      // ... trigger loading state
      
      await tester.pump();
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

## Consideraciones de Rendimiento y Escalabilidad

### ¿Por qué Riverpod para Proyectos a Gran Escala?

1. **Sistema de Caché Inteligente**
   - Riverpod cachea automáticamente los resultados de providers
   - Invalidación selectiva de caché cuando cambian dependencias
   - Garbage collection automático de providers no utilizados

2. **Optimización de Rebuilds**
   - `select()` permite escuchar solo partes específicas del estado
   - Providers granulares evitan rebuilds innecesarios
   - Lazy loading de providers hasta que se necesiten

3. **Testing y Mantenibilidad**
   - Override de providers para testing sin modificar código de producción
   - Inyección de dependencias nativa sin configuración adicional
   - Detección de errores en tiempo de compilación

4. **Escalabilidad**
   - Providers pueden ser combinados y compuestos fácilmente
   - Separación clara de responsabilidades por capas
   - Fácil refactoring y modularización

### Optimizaciones Específicas

```dart
// Optimización con select para evitar rebuilds innecesarios
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(passportNotifierProvider.select((state) => state.isLoading));
});

// Provider con autoDispose para liberar memoria
final temporaryDataProvider = Provider.autoDispose<String>((ref) {
  // Se libera automáticamente cuando no se usa
  return 'temporary data';
});

// Family provider con caché limitado
final userDataProvider = Provider.family<UserData, String>((ref, userId) {
  ref.cacheFor(const Duration(minutes: 5)); // Caché por 5 minutos
  return fetchUserData(userId);
});
```

## Conclusión

Esta arquitectura con Clean Architecture y Riverpod proporciona:

- **Separación clara de responsabilidades** por capas
- **Gestión de estado escalable** con Riverpod
- **Testing fácil** con override de providers
- **Rendimiento optimizado** con caché inteligente y rebuilds selectivos
- **Mantenibilidad** a largo plazo con código modular y testeable
- **Comunicación eficiente** con backend GraphQL
- **Experiencia de usuario fluida** en múltiples plataformas