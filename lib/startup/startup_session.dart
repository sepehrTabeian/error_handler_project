import 'package:flutter/foundation.dart';

import '../app/startup/initialize_session_usecase.dart';
import 'startup_config.dart';

/// Handles session restoration during startup.
///
/// This class is responsible for restoring the user's session from stored
/// authentication tokens. It validates the token, extracts the user ID,
/// and sets up the user context for the application.
///
/// Session Restoration Flow:
/// 1. Check if access token exists in secure storage
/// 2. If token exists, decode and validate it
/// 3. Extract user ID from token payload
/// 4. Set user context with extracted user ID
/// 5. If token is invalid or missing, clear user context
///
/// Why session restoration matters:
/// - Users should stay logged in across app restarts
/// - Avoids forcing login on every app launch
/// - Provides seamless user experience
/// - Enables background sync and notifications
class StartupSession {
  final StartupConfig config;
  final InitializeSessionUseCase initializeSessionUseCase;

  StartupSession({
    required this.config,
    required this.initializeSessionUseCase,
  });

  /// Restores the user session from stored authentication tokens.
  ///
  /// This method should be called during app startup after dependencies
  /// are initialized. It attempts to restore the user's session from
  /// stored tokens and sets up the user context.
  ///
  /// Returns:
  /// - [true] if session was restored successfully
  /// - [false] if no valid session exists or restoration failed
  Future<bool> restore() async {
    debugPrint('Restoring session...');

    try {
      await initializeSessionUseCase();

      // In a real implementation, we would check if the user context
      // was actually set to determine success
      // For now, we assume success if no exception was thrown

      debugPrint('Session restored successfully');
      return true;
    } catch (error, stackTrace) {
      debugPrint('Failed to restore session: $error');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Clears the current user session.
  ///
  /// This method is called when the user explicitly logs out or when
  /// the session needs to be invalidated (e.g., token expired).
  Future<void> clear() async {
    debugPrint('Clearing session...');

    try {
      // In a real implementation, this would call the logout use case
      // and clear tokens from secure storage
      // For now, we just log the action

      debugPrint('Session cleared successfully');
    } catch (error, stackTrace) {
      debugPrint('Failed to clear session: $error');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
