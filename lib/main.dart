// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cityfix_mobile/l10n/app_localizations.dart';

import 'firebase_options.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'core/constants.dart';
import 'core/push_notification_service.dart';
import 'core/localization_fallback.dart';
import 'services/offline_sync_service.dart';
import 'features/profile/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase (guard against duplicate-app on hot restart)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Firebase is already initialized (happens on hot restart) — safe to ignore
  }

  // 2. Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.offlineDraftsBox);
  await Hive.openBox(AppConstants.userBox);
  await Hive.openBox(AppConstants.notificationsBox);
  await Hive.openBox(AppConstants.feedBox);

  // 3. Run App
  final container = ProviderContainer();
  
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const CityFixApp(),
    ),
  );
}

class CityFixApp extends ConsumerStatefulWidget {
  const CityFixApp({super.key});

  @override
  ConsumerState<CityFixApp> createState() => _CityFixAppState();
}

class _CityFixAppState extends ConsumerState<CityFixApp> {
  @override
  void initState() {
    super.initState();
    // Start background sync listener
    ref.read(offlineSyncServiceProvider);
    
    // Initialize push notifications (requests permissions & syncs token)
    // We pass the global ProviderContainer to let the service write to our Notifier.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final container = ProviderScope.containerOf(context);
      PushNotificationService.init(container);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);
    
    ThemeMode themeMode;
    switch (settings['themeMode']) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    final localeCode = settings['locale'] as String? ?? 'en';
    final locale = Locale(localeCode);

    return MaterialApp.router(
      title: 'CityFix Jimma',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
        FallbackWidgetsLocalizationDelegate(),
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('am'),
        Locale('om'),
      ],
    );
  }
}
