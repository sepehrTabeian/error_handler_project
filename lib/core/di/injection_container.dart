import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/domain/repositories/repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/chat/data/datasources/chat_local_datasource.dart';
import '../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../features/chat/data/datasources/chat_socket_datasource.dart';
import '../../features/chat/data/datasources/drift_chat_local_datasource.dart';
import '../../features/chat/data/datasources/web_socket_chat_datasource.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/send_message_usecase.dart';
import '../../features/chat/domain/usecases/sync_pending_messages_usecase.dart';
import '../../features/chat/domain/usecases/watch_messages_usecase.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../features/conference_members/data/repositories/conference_members_repository_impl.dart';
import '../../features/conference_members/domain/repositories/conference_members_repository.dart';
import '../../features/conference_members/domain/usecases/get_conference_participants_usecase.dart';
import '../../features/conference_members/domain/usecases/update_participant_mute_status_usecase.dart';
import '../../features/conference_members/presentation/bloc/conference_members_bloc.dart';
import '../../features/payment/data/datasource/payment_remote_datasource.dart';
import '../../features/payment/data/repositories/payment_repository_impl.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';
import '../../features/payment/domain/pay_usecase.dart';
import '../../features/payment/presentation/bloc/payment_bloc.dart';
import '../../features/task_board/data/repositories/task_board_repository_impl.dart';
import '../../features/task_board/domain/repositories/task_board_repository.dart';
import '../../features/task_board/domain/usecases/move_task_usecase.dart';
import '../../features/task_board/presentation/bloc/task_board_bloc.dart';
import '../../app/startup/initialize_session_usecase.dart';
import '../../infrastructure/auth/jwt_token_payload_reader.dart';
import '../../infrastructure/auth/secure_token_storage.dart';
import '../../infrastructure/auth/token_payload_reader.dart';
import '../../infrastructure/auth/token_provider.dart';
import '../../infrastructure/auth/token_storage.dart';
import '../../infrastructure/auth/token_user_id_resolver.dart';
import '../../infrastructure/auth/user_id_resolver.dart';
import '../../infrastructure/database/app_database.dart';
import '../../infrastructure/errors/app_failure_mapper.dart';
import '../../infrastructure/errors/dio_error_mapper.dart';
import '../../infrastructure/network/auth_interseptor.dart';
import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/session/user_context_service.dart';

/// Global service locator for dependency injection.
///
/// This container manages all application dependencies following Clean Architecture principles.
/// Only abstractions are registered as dependencies; concrete implementations are resolved
/// through the container.
///
/// Registration Strategy:
/// - [registerLazySingleton]: For repositories, services, data sources, and singletons
/// - [registerFactory]: For use cases and blocs (new instance per request)
///
/// Why LazySingleton vs Factory:
/// - Repositories and data sources are stateful or expensive to create → LazySingleton
/// - Use cases are stateless and should be recreated per call → Factory
/// - Blocs hold state and should be recreated per widget lifecycle → Factory
final getIt = GetIt.instance;

/// Configures all application dependencies.
///
/// This method should be called once during app startup, typically in main.dart
/// before runApp(). The order of registration matters for dependencies that
/// depend on other registered services.
///
/// Registration Order:
/// 1. Infrastructure (lowest level, no dependencies on app code)
/// 2. Data sources (depend on infrastructure)
/// 3. Repositories (depend on data sources and infrastructure)
/// 4. Use cases (depend on repositories)
/// 5. Blocs (depend on use cases)
Future<void> configureDependencies() async {
  await _registerInfrastructure();
  await _registerDataSources();
  await _registerRepositories();
  await _registerUseCases();
  await _registerBlocs();
}

/// Registers infrastructure-level dependencies.
///
/// These are the lowest-level services that external systems depend on:
/// - Storage (token storage)
/// - Networking (Dio client, interceptors, error mappers)
/// - Database (local SQLite database)
/// - Session management (user context)
///
/// Infrastructure services are registered as lazy singletons because:
/// - They are expensive to create (database connections, HTTP clients)
/// - They maintain state (cached tokens, active connections)
/// - They should be shared across the application
Future<void> _registerInfrastructure() async {
  // =======================
  // Storage
  // =======================

  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  getIt.registerLazySingleton<TokenStorage>(
    () => SecureTokenStorage(getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<TokenProvider>(
    () => TokenProviderImpl(getIt<TokenStorage>()),
  );

  getIt.registerLazySingleton<TokenPayloadReader>(
    () => JwtTokenPayloadReader(),
  );

  getIt.registerLazySingleton<UserIdResolver>(
    () => TokenUserIdResolver(
      tokenProvider: getIt<TokenProvider>(),
      tokenPayloadReader: getIt<TokenPayloadReader>(),
    ),
  );

  // =======================
  // Session
  // =======================

  getIt.registerLazySingleton<UserContextService>(
    () => InMemoryUserContextService(),
  );

  // =======================
  // Networking
  // =======================

  getIt.registerLazySingleton<DioErrorMapper>(
    () => DioErrorMapper(),
  );

  getIt.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(getIt<TokenProvider>()),
  );

  getIt.registerLazySingleton<DioClient>(
    () => DioClient(getIt<TokenProvider>()),
  );

  getIt.registerLazySingleton<Dio>(
    () => getIt<DioClient>().create(),
  );

  getIt.registerLazySingleton<FailureMapper>(
    () => FailureMapper(),
  );

  // =======================
  // Database
  // =======================

  getIt.registerLazySingleton<AppDatabase>(
    () => AppDatabase(),
  );
}

/// Registers data source dependencies.
///
/// Data sources are the bridge between the app and external systems:
/// - Remote data sources (REST APIs)
/// - Socket data sources (WebSocket connections)
/// - Local data sources (SQLite database)
///
/// Data sources are registered as lazy singletons because:
/// - They maintain connections (WebSocket, database)
/// - They are expensive to create (connection setup)
/// - They should be shared across repositories
Future<void> _registerDataSources() async {
  // =======================
  // Auth Data Sources
  // =======================

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dio: getIt<Dio>(),
      errorMapper: getIt<DioErrorMapper>(),
    ),
  );

  // =======================
  // Chat Data Sources
  // =======================

  getIt.registerLazySingleton<ChatLocalDataSource>(
    () => DriftChatLocalDataSource(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(
      dio: getIt<Dio>(),
      errorMapper: getIt<DioErrorMapper>(),
    ),
  );

  getIt.registerLazySingleton<ChatSocketDataSource>(
    () => WebSocketChatDataSource(
      tokenProvider: getIt<TokenProvider>(),
      socketUrl: 'wss://api.example.com/chat',
    ),
  );

  // =======================
  // Payment Data Sources
  // =======================

  getIt.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(
      dio: getIt<Dio>(),
      errorMapper: getIt<DioErrorMapper>(),
    ),
  );
}

/// Registers repository dependencies.
///
/// Repositories orchestrate data flow between data sources and use cases.
/// They implement the repository abstractions defined in the domain layer.
///
/// Repositories are registered as lazy singletons because:
/// - They hold references to data sources (which are singletons)
/// - They may cache data locally
/// - They should be shared across use cases
Future<void> _registerRepositories() async {
  // =======================
  // Auth Repository
  // =======================

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      tokenStorage: getIt<TokenStorage>(),
      failureMapper: getIt<FailureMapper>(),
    ),
  );

  // =======================
  // Chat Repository
  // =======================

  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      localDataSource: getIt<ChatLocalDataSource>(),
      remoteDataSource: getIt<ChatRemoteDataSource>(),
      socketDataSource: getIt<ChatSocketDataSource>(),
      userContextService: getIt<UserContextService>(),
      failureMapper: getIt<FailureMapper>(),
    ),
  );

  // =======================
  // Payment Repository
  // =======================

  getIt.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(
      remoteDataSource: getIt<PaymentRemoteDataSource>(),
      failureMapper: getIt<FailureMapper>(),
    ),
  );

  // =======================
  // Task Board Repository
  // =======================

  getIt.registerLazySingleton<TaskBoardRepository>(
    () => TaskBoardRepositoryImpl(),
  );

  // =======================
  // Conference Members Repository
  // =======================

  getIt.registerLazySingleton<ConferenceMembersRepository>(
    () => ConferenceMembersRepositoryImpl(),
  );
}

/// Registers use case dependencies.
///
/// Use cases encapsulate single business rules and are the entry point
/// for business logic from the presentation layer.
///
/// Use cases are registered as factories because:
/// - They are stateless (no mutable state)
/// - They should be recreated per call (no shared state between calls)
/// - They depend on repositories (which are singletons)
Future<void> _registerUseCases() async {
  // =======================
  // Auth Use Cases
  // =======================

  getIt.registerFactory<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );

  // =======================
  // Chat Use Cases
  // =======================

  getIt.registerFactory<SendMessageUseCase>(
    () => SendMessageUseCase(getIt<ChatRepository>()),
  );

  getIt.registerFactory<SyncPendingMessagesUseCase>(
    () => SyncPendingMessagesUseCase(getIt<ChatRepository>()),
  );

  getIt.registerFactory<WatchMessagesUseCase>(
    () => WatchMessagesUseCase(getIt<ChatRepository>()),
  );

  // =======================
  // Payment Use Cases
  // =======================

  getIt.registerFactory<PayUseCase>(
    () => PayUseCase(
      repository: getIt<PaymentRepository>(),
      userContextService: getIt<UserContextService>(),
    ),
  );

  // =======================
  // Task Board Use Cases
  // =======================

  getIt.registerFactory<MoveTaskUseCase>(
    () => MoveTaskUseCase(getIt<TaskBoardRepository>()),
  );

  // =======================
  // Conference Members Use Cases
  // =======================

  getIt.registerFactory<GetConferenceParticipantsUseCase>(
    () => GetConferenceParticipantsUseCase(getIt<ConferenceMembersRepository>()),
  );

  getIt.registerFactory<UpdateParticipantMuteStatusUseCase>(
    () => UpdateParticipantMuteStatusUseCase(
      getIt<ConferenceMembersRepository>(),
    ),
  );

  // =======================
  // Startup Use Cases
  // =======================

  getIt.registerFactory<InitializeSessionUseCase>(
    () => InitializeSessionUseCase(
      userIdResolver: getIt<UserIdResolver>(),
      userContextService: getIt<UserContextService>(),
    ),
  );
}

/// Registers Bloc dependencies.
///
/// Blocs manage state for specific features and are consumed by the UI.
/// They depend on use cases to execute business logic.
///
/// Blocs are registered as factories because:
/// - They hold state (should be recreated per widget lifecycle)
/// - They have subscriptions (must be properly disposed)
/// - Multiple instances may exist (e.g., same bloc in different screens)
Future<void> _registerBlocs() async {
  // =======================
  // Chat Bloc
  // =======================

  getIt.registerFactory<ChatBloc>(
    () => ChatBloc(
      watchMessagesUseCase: getIt<WatchMessagesUseCase>(),
      sendMessageUseCase: getIt<SendMessageUseCase>(),
      syncPendingMessagesUseCase: getIt<SyncPendingMessagesUseCase>(),
    ),
  );

  // =======================
  // Payment Bloc
  // =======================

  getIt.registerFactory<PaymentBloc>(
    () => PaymentBloc(payUseCase: getIt<PayUseCase>()),
  );

  // =======================
  // Task Board Bloc
  // =======================

  getIt.registerFactory<TaskBoardBloc>(
    () => TaskBoardBloc(moveTaskUseCase: getIt<MoveTaskUseCase>()),
  );

  // =======================
  // Conference Members Bloc
  // =======================

  getIt.registerFactory<ConferenceMembersBloc>(
    () => ConferenceMembersBloc(
      getParticipantsUseCase: getIt<GetConferenceParticipantsUseCase>(),
      updateMuteStatusUseCase: getIt<UpdateParticipantMuteStatusUseCase>(),
    ),
  );
}
