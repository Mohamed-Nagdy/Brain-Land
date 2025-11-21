import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/audio_manager.dart';
import 'features/ads/services/ad_manager.dart';
import 'features/ads/services/app_open_ad_service.dart';
import 'firebase_options.dart';
import 'shared/services/storage_service.dart';

// Global app open ad service
final appOpenAdService = AppOpenAdService();

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive storage
  await StorageService.instance.initialize();

  // Initialize Audio Manager
  await AudioManager.instance.initialize();

  // Initialize AdManager (handles AdMob initialization internally)
  await AdManager.instance.initialize();

  // Preload app open ad
  await appOpenAdService.loadAd();

  // Run the app with Riverpod
  runApp(const ProviderScope(child: BrainLandApp()));
}

class BrainLandApp extends ConsumerStatefulWidget {
  const BrainLandApp({super.key});

  @override
  ConsumerState<BrainLandApp> createState() => _BrainLandAppState();
}

class _BrainLandAppState extends ConsumerState<BrainLandApp>
    with WidgetsBindingObserver {
  final router = AppRouter.createRouter();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Show app open ad when app resumes
    if (state == AppLifecycleState.resumed) {
      appOpenAdService.showIfAvailable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.buildTheme(),
    );
  }
}
