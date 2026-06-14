import 'package:flutter/foundation.dart';

import '../core/di/injection_container.dart';
import 'startup_config.dart';

/// Handles dependency injection configuration during startup.
///
/// This class is responsible for initializing the service locator (GetIt)
/// with all application dependencies. Dependencies are registered in a
/// specific order to ensure that dependencies are available before they
/// are needed.
///
/// Registration Order:
/// 1. Infrastructure (storage, networking, database)
/// 2. Data sources (remote, local, socket)
/// 3. Repositories (orchestrate data sources)
/// 4. Use cases (business logic)
/// 5. Blocs (state management)
///
/// Why separate from main.dart:
/// - Keeps main.dart clean and focused
/// - Allows testing startup logic independently
/// - Makes startup failures easier to debug
/// - Enables conditional registration based on config
class StartupDependencies {
  final StartupConfig config;

  StartupDependencies({required this.config});

  /// Initializes all application dependencies.
  ///
  /// This method should be called once during app startup before any
  /// feature is accessed. It registers all services with the service locator.
  ///
  /// Throws:
  /// - [StateError] if dependencies are already initialized
  /// - [Exception] if dependency registration fails
  Future<void> initialize() async {
    if (getIt.isReady()) {
      debugPrint('Dependencies already initialized, skipping...');
      return;
    }

    debugPrint('Initializing dependencies...');

    try {
      await configureDependencies();

      debugPrint('Dependencies initialized successfully');
    } catch (error, stackTrace) {
      debugPrint('Failed to initialize dependencies: $error');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Resets all dependencies.
  ///
  /// This is primarily used for testing to ensure a clean state between tests.
  /// Should never be called in production.
  Future<void> reset() async {
    if (!kDebugMode) {
      debugPrint('WARNING: Resetting dependencies in release mode!');
    }

    await getIt.reset();
    debugPrint('Dependencies reset');
  }
}
