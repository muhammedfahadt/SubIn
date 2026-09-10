import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

class AppLogger {
  // Singleton pattern: One logger instance for the entire app
  static final Talker _talker = TalkerFlutter.init(
    settings: TalkerSettings(
      // In production, disable console logs to save performance
      enabled: const bool.fromEnvironment('ENABLE_LOGS', defaultValue: true),

      // Define what severity levels to log
      useConsoleLogs: true,

      // History: Keep last 1000 logs in memory for debugging
      maxHistoryItems: 1000,
    ),
  );

  // Expose the talker instance for advanced integrations (like Dio)
  static Talker get instance => _talker;

  // --- SEVERITY LEVELS ---

  /// Use for: Variable values, API responses, navigation events
  static void debug(String message, [Object? data]) {
    _talker.debug(message, data);
  }

  /// Use for: Successful logins, completed API calls, state changes
  static void info(String message, [Object? data]) {
    _talker.info(message, data);
  }

  /// Use for: Deprecated API usage, retry attempts, slow responses
  static void warning(String message, [Object? data]) {
    _talker.warning(message, data);
  }

  /// Use for: API failures, caught exceptions, invalid user input
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _talker.error(message, error, stackTrace);
  }

  /// Use for: App crashes, database corruption, security breaches
  static void critical(String message, [Object? error, StackTrace? stackTrace]) {
    _talker.critical(message, error, stackTrace);

     // 👇 Automatically send critical errors to Sentry dashboard
  Sentry.captureException(
    error,
    stackTrace: stackTrace,
    hint: Hint.withMap({'message': message}),
  );
  }
}
