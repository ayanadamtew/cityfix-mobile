// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'core/constants.dart';
import 'services/offline_sync_service.dart';

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

  // 3. Run App
  runApp(
    const ProviderScope(
      child: CityFixApp(),
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
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'CityFix Jimma',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
