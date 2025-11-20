import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/audio_manager.dart';
import 'firebase_options.dart';
import 'shared/services/storage_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Google Mobile Ads (must be done before app starts)
  await MobileAds.instance.initialize();

  // Configure for child-directed treatment (COPPA compliance)
  await MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
      maxAdContentRating: MaxAdContentRating.g,
    ),
  );

  // Initialize Hive storage
  await StorageService.instance.initialize();

  // Initialize Audio Manager
  await AudioManager.instance.initialize();

  // Run the app with Riverpod
  runApp(const ProviderScope(child: BrainLandApp()));
}

class BrainLandApp extends ConsumerWidget {
  const BrainLandApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = AppRouter.createRouter();

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.buildTheme(),
    );
  }
}
