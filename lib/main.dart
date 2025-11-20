import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/colors.dart';
import 'firebase_options.dart';
import 'shared/services/storage_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive storage
  await StorageService.instance.initialize();

  // Run the app with Riverpod
  runApp(const ProviderScope(child: BrainLandApp()));
}

class BrainLandApp extends ConsumerWidget {
  const BrainLandApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
        ),
      ),
      home: const PlaceholderHomeScreen(),
    );
  }
}

/// Placeholder home screen until world map is implemented
class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.1),
              AppColors.secondary.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji-based zone preview
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🌳', style: TextStyle(fontSize: 48)),
                  SizedBox(width: 16),
                  Text('⛰️', style: TextStyle(fontSize: 48)),
                  SizedBox(width: 16),
                  Text('🌊', style: TextStyle(fontSize: 48)),
                  SizedBox(width: 16),
                  Text('🔷', style: TextStyle(fontSize: 48)),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to ${AppConstants.appName}!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '✅ Project setup complete',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '🎨 Emoji-based design ready',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              const Text(
                '🚀 Ready for feature implementation',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              // Avatar preview
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🐼', style: TextStyle(fontSize: 40)),
                  SizedBox(width: 16),
                  Text('🤖', style: TextStyle(fontSize: 40)),
                  SizedBox(width: 16),
                  Text('🐱', style: TextStyle(fontSize: 40)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
