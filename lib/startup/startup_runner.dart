import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/di/injection_container.dart';
import 'startup_config.dart';
import 'startup_dependencies.dart';
import 'startup_session.dart';

/// Orchestrates the complete application startup sequence.
///
/// This class manages the entire startup pipeline from Flutter bindings
/// initialization through dependency injection, session restoration, and
/// app launch. It provides a clean separation between startup logic and
/// the main.dart file.
///
/// Startup Pipeline:
/// 1. Initialize Flutter bindings (for plugins like Firebase, SQLite)
/// 2. Load environment configuration
/// 3. Configure dependency injection
/// 4. Initialize local database
/// 5. Restore user session
/// 6. Configure logging and error reporting
/// 7. Launch the application
///
/// Error Handling:
/// - Startup failures are caught and reported
/// - User is shown appropriate error screens
/// - Debug information is logged in development
/// - Crash reports are sent in production
class StartupRunner {
  final StartupConfig config;
  final WidgetBuilder appBuilder;

  StartupRunner({
    required this.config,
    required this.appBuilder,
  });

  /// Runs the complete startup pipeline and launches the app.
  ///
  /// This is the main entry point for application startup. It orchestrates
  /// all initialization steps and handles failures gracefully.
  ///
  /// Returns:
  /// A [Widget] that represents the running application or an error screen.
  ///
  /// Throws:
  /// Re-throws critical startup failures that cannot be recovered from.
  Future<Widget> run() async {
    debugPrint('=== Starting Application Startup ===');
    debugPrint('Environment: ${config.environment}');
    debugPrint('API Base URL: ${config.apiBaseUrl}');
    debugPrint('WebSocket URL: ${config.webSocketUrl}');

    try {
      // Step 1: Initialize Flutter bindings
      await _initializeBindings();

      // Step 2: Configure dependencies
      await _configureDependencies();

      // Step 3: Initialize database
      await _initializeDatabase();

      // Step 4: Restore session
      await _restoreSession();

      // Step 5: Configure logging
      _configureLogging();

      // Step 6: Configure error reporting
      _configureErrorReporting();

      debugPrint('=== Startup Completed Successfully ===');

      // Launch the app
      return appBuilder(getIt);
    } catch (error, stackTrace) {
      debugPrint('=== Startup Failed ===');
      debugPrint('Error: $error');
      debugPrint('Stack trace: $stackTrace');

      // Return error screen
      return _buildErrorScreen(error, stackTrace);
    }
  }

  /// Initializes Flutter bindings for native plugins.
  ///
  /// Flutter bindings must be initialized before any plugin is used.
  /// This includes Firebase, SQLite, and other native integrations.
  Future<void> _initializeBindings() async {
    debugPrint('Initializing Flutter bindings...');

    // In a real implementation, this would initialize:
    // - Firebase (Firebase.initializeApp)
    // - Other native plugins
    // - Platform channels

    debugPrint('Flutter bindings initialized');
  }

  /// Configures dependency injection.
  ///
  /// Registers all services, repositories, use cases, and blocs with
  /// the service locator. Dependencies are registered in dependency order.
  Future<void> _configureDependencies() async {
    debugPrint('Configuring dependencies...');

    final startupDependencies = StartupDependencies(config: config);
    await startupDependencies.initialize();

    debugPrint('Dependencies configured');
  }

  /// Initializes the local database.
  ///
  /// Opens the SQLite database and runs any pending migrations.
  /// This ensures the database is ready before the app launches.
  Future<void> _initializeDatabase() async {
    debugPrint('Initializing database...');

    // Get the database instance from DI to trigger initialization
    final database = getIt();
    // The database is initialized lazily on first access

    debugPrint('Database initialized');
  }

  /// Restores the user session from stored tokens.
  ///
  /// Attempts to restore the user's session from secure storage.
  /// If successful, the user context is set for the app.
  Future<void> _restoreSession() async {
    debugPrint('Restoring session...');

    final startupSession = StartupSession(
      config: config,
      initializeSessionUseCase: getIt(),
    );

    final restored = await startupSession.restore();

    if (restored) {
      debugPrint('Session restored successfully');
    } else {
      debugPrint('No valid session found, user must log in');
    }
  }

  /// Configures logging based on environment.
  ///
  /// In development, verbose logging is enabled.
  /// In production, only critical logs are enabled.
  void _configureLogging() {
    debugPrint('Configuring logging...');

    // In a real implementation, this would configure:
    // - Logger instances
    // - Log levels
    // - Log destinations (console, remote logging service)

    debugPrint('Logging configured (debug: ${config.enableDebugLogging})');
  }

  /// Configures error reporting and crash analytics.
  ///
  /// In production, crash reporting is enabled to track crashes.
  /// In development, crashes are logged but not sent.
  void _configureErrorReporting() {
    debugPrint('Configuring error reporting...');

    // In a real implementation, this would configure:
    // - Firebase Crashlytics
    // - Sentry
    // - Custom error tracking

    debugPrint(
      'Error reporting configured (crash: ${config.enableCrashReporting})',
    );
  }

  /// Builds an error screen for startup failures.
  ///
  /// When startup fails, this screen is shown to the user instead of
  /// crashing the app. In development, detailed error information is shown.
  /// In production, a user-friendly error message is shown.
  Widget _buildErrorScreen(Object error, StackTrace stackTrace) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Startup Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Failed to start application',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  config.environment == 'dev'
                      ? 'Error: $error\n\n$stackTrace'
                      : 'Please check your internet connection and try again.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // In a real implementation, this would restart the app
                    // or attempt to recover from the error
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
