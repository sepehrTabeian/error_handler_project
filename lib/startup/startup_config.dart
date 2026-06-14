/// Application configuration loaded at startup.
///
/// This class holds environment-specific configuration values that are
/// loaded before the app starts. Configuration should be loaded from
/// environment variables, config files, or remote config services.
///
/// Why separate config from constants:
/// - Allows different configurations per environment (dev, staging, prod)
/// - Enables feature flags and A/B testing
/// - Keeps sensitive values out of source code
/// - Allows runtime configuration changes without app updates
class StartupConfig {
  /// API base URL for REST endpoints.
  final String apiBaseUrl;

  /// WebSocket URL for real-time connections.
  final String webSocketUrl;

  /// Environment name (dev, staging, prod).
  final String environment;

  /// Whether debug logging is enabled.
  final bool enableDebugLogging;

  /// Whether crash reporting is enabled.
  final bool enableCrashReporting;

  /// Whether analytics is enabled.
  final bool enableAnalytics;

  const StartupConfig({
    required this.apiBaseUrl,
    required this.webSocketUrl,
    required this.environment,
    required this.enableDebugLogging,
    required this.enableCrashReporting,
    required this.enableAnalytics,
  });

  /// Creates a development configuration.
  factory StartupConfig.dev() {
    return const StartupConfig(
      apiBaseUrl: 'https://api-dev.example.com',
      webSocketUrl: 'wss://api-dev.example.com/chat',
      environment: 'dev',
      enableDebugLogging: true,
      enableCrashReporting: false,
      enableAnalytics: false,
    );
  }

  /// Creates a production configuration.
  factory StartupConfig.prod() {
    return const StartupConfig(
      apiBaseUrl: 'https://api.example.com',
      webSocketUrl: 'wss://api.example.com/chat',
      environment: 'prod',
      enableDebugLogging: false,
      enableCrashReporting: true,
      enableAnalytics: true,
    );
  }

  /// Loads configuration from environment or defaults.
  ///
  /// In a real implementation, this would read from:
  /// - Environment variables
  /// - .env files
  /// - Remote config services (Firebase Remote Config)
  /// - Platform-specific config (iOS Info.plist, Android manifest)
  factory StartupConfig.load() {
    // For now, return dev config as default
    // In production, this would check environment variables
    const env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');

    switch (env) {
      case 'prod':
        return StartupConfig.prod();
      default:
        return StartupConfig.dev();
    }
  }
}
