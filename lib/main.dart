import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/conference_members/presentation/bloc/conference_members_bloc.dart';
import 'features/payment/presentation/bloc/payment_bloc.dart';
import 'features/task_board/presentation/bloc/task_board_bloc.dart';
import 'startup/startup_config.dart';
import 'startup/startup_runner.dart';

void main() {
  // Wrap the entire app in a zone for error handling
  runZonedGuarded(
    () {
      // Configure Flutter error handling
      FlutterError.onError = _handleFlutterError;

      // Run the startup pipeline
      _runApp();
    },
    _handleZoneError,
  );
}

/// Runs the startup pipeline and launches the app.
///
/// This method orchestrates the complete startup sequence including:
/// - Flutter bindings initialization
/// - Dependency injection configuration
/// - Session restoration
/// - Database initialization
/// - Error reporting setup
/// - App launch
Future<void> _runApp() async {
  final startupRunner = StartupRunner(
    config: StartupConfig.load(),
    appBuilder: (getIt) => _buildApp(getIt),
  );

  final appWidget = await startupRunner.run();

  runApp(appWidget);
}

/// Builds the application widget with BlocObserver.
///
/// This method creates the MaterialApp with all necessary providers
/// and observers for state management and error tracking.
Widget _buildApp(GetIt getIt) {
  return MaterialApp(
    title: 'Error Handler Project',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    ),
    // TODO: Add proper routing with go_router
    // For now, showing a placeholder home screen
    home: const _HomeScreen(),
  );
}

/// Handles Flutter framework errors.
///
/// This callback is called when a Flutter framework error occurs.
/// In production, this would log the error to a crash reporting service.
void _handleFlutterError(FlutterErrorDetails details) {
  // In development, print to console
  debugPrint('Flutter Error: ${details.exception}');
  debugPrint('Stack trace: ${details.stack}');

  // In production, send to crash reporting service
  // Example: FirebaseCrashlytics.instance.recordError(...)
}

/// Handles zone errors that escape Flutter's error handling.
///
/// This callback is called when an error occurs in the zone that
/// wasn't caught by Flutter's error handling.
void _handleZoneError(Object error, StackTrace stackTrace) {
  // In development, print to console
  debugPrint('Zone Error: $error');
  debugPrint('Stack trace: $stackTrace');

  // In production, send to crash reporting service
  // Example: FirebaseCrashlytics.instance.recordError(...)
}

/// Placeholder home screen.
///
/// This is a temporary screen until proper routing is implemented.
/// In production, this would be replaced with the actual app navigation.
class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Handler Project'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _FeatureCard(
            title: 'Chat',
            description: 'Offline-first chat with WebSocket and REST fallback',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => getIt<ChatBloc>(),
                    child: const _PlaceholderScreen(title: 'Chat'),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _FeatureCard(
            title: 'Payment',
            description: 'Payment processing with user context',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => getIt<PaymentBloc>(),
                    child: const _PlaceholderScreen(title: 'Payment'),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _FeatureCard(
            title: 'Task Board',
            description: 'Kanban board with optimistic updates and rollback',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => getIt<TaskBoardBloc>(),
                    child: const _PlaceholderScreen(title: 'Task Board'),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _FeatureCard(
            title: 'Conference Members',
            description: 'Participant management with search and mute',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => getIt<ConferenceMembersBloc>(),
                    child: const _PlaceholderScreen(title: 'Conference Members'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Feature card for the home screen.
class _FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

/// Placeholder screen for features.
///
/// This is a temporary screen until proper feature screens are implemented.
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Text(
          '$title feature coming soon',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
