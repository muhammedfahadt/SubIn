import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subIn/router/app_router.dart';
import 'package:subIn/config/app_theme.dart';
import 'package:subIn/config/app_constants.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {

  // 👇 Initialize Sentry for production crash reporting
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://03bd81240306a9eff839e21b88e77640@o4512020928921600.ingest.de.sentry.io/4512021032927312';

      // Only send errors to Sentry in production
      options.environment = const String.fromEnvironment(
        'ENVIRONMENT',
        defaultValue: 'development',
      );
         options.debug = true; // 👈 CRITICAL: Prints to console to prove it's trying to send


      // Don't send PII (Personally Identifiable Information)
      options.sendDefaultPii = false;
    },
    appRunner: () {
     WidgetsFlutterBinding.ensureInitialized();
      runApp(
      const ProviderScope(
        child: GameOnApp(),
      ),
    ); Sentry.captureMessage("✅ Sentry is successfully connected to Flutter!");
    }
  );
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
