import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sub_in/router/app_router.dart';
import 'package:sub_in/config/app_theme.dart';
import 'package:sub_in/config/app_constants.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {

  // Sentry DSN via --dart-define (never hardcode secrets).
  // flutter run --dart-define=SENTRY_DSN=... --dart-define=ENVIRONMENT=development
  const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  if (sentryDsn.isNotEmpty) {
    // 👇 Initialize Sentry for production crash reporting
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;

      // Only send errors to Sentry in production
      options.environment = const String.fromEnvironment(
        'ENVIRONMENT',
        defaultValue: 'development',
      );
         options.debug = true; 


      // Don't send PII (Personally Identifiable Information)
      options.sendDefaultPii = false;
    },
    appRunner: () {
     WidgetsFlutterBinding.ensureInitialized();
      runApp(
      const ProviderScope(
        child: GameOnApp(),
      ),
    );
    },
  );
  } else {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(
      const ProviderScope(
        child: GameOnApp(),
      ),
    );
  }
}

class GameOnApp extends ConsumerWidget {
  const GameOnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the router provider. If auth state changes, the router
    // automatically re-evaluates the `redirect` logic.
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router, // <-- The magic happens here
    );
  }
}
