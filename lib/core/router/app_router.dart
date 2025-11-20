import 'package:brain_land/features/logic_mountain/presentation/screens/logic_game_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Avatar screens
import '../../features/avatar/presentation/screens/avatar_customization_screen.dart';
// Math Forest screens
import '../../features/math_forest/presentation/screens/level_complete_screen.dart';
import '../../features/math_forest/presentation/screens/level_selection_screen.dart';
import '../../features/math_forest/presentation/screens/math_game_screen.dart';
// Memory River screens
import '../../features/memory_river/presentation/screens/memory_game_screen.dart';
// Progress screens
import '../../features/progress/presentation/screens/daily_reward_screen.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';
// Reward screens
import '../../features/rewards/presentation/screens/pet_collection_screen.dart';
import '../../features/rewards/presentation/screens/reward_chest_screen.dart';
// Settings screens
import '../../features/settings/presentation/screens/settings_screen.dart';
// Shape Valley screens
import '../../features/shape_valley/presentation/screens/shape_game_screen.dart';
// World Map screens
import '../../features/world_map/presentation/screens/world_map_screen.dart';

/// Route names for type-safe navigation
class AppRoutes {
  AppRoutes._();

  // Main routes
  static const String worldMap = '/';
  static const String settings = '/settings';
  static const String progress = '/progress';
  static const String dailyReward = '/daily-reward';

  // Math Forest routes
  static const String mathForestLevels = '/math-forest';
  static const String mathGame = '/math-forest/game/:levelId';
  static const String mathLevelComplete = '/math-forest/complete/:levelId';

  // Logic Mountain routes
  static const String logicMountainLevels = '/logic-mountain';
  static const String logicGame = '/logic-mountain/game/:levelId';
  static const String logicLevelComplete = '/logic-mountain/complete';

  // Memory River routes
  static const String memoryRiverLevels = '/memory-river';
  static const String memoryGame = '/memory-river/game/:levelId';
  static const String memoryLevelComplete = '/memory-river/complete';

  // Shape Valley routes
  static const String shapeValleyLevels = '/shape-valley';
  static const String shapeGame = '/shape-valley/game/:levelId';
  static const String shapeLevelComplete = '/shape-valley/complete';

  // Avatar routes
  static const String avatarCustomization = '/avatar';

  // Reward routes
  static const String rewardChest = '/reward-chest';

  // Pet routes
  static const String petCollection = '/pets';
}

/// Router configuration for BrainLand app
class AppRouter {
  AppRouter._();

  /// Creates and configures the GoRouter instance
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: AppRoutes.worldMap,
      debugLogDiagnostics: true,
      routes: [
        // World Map (Home)
        GoRoute(
          path: AppRoutes.worldMap,
          name: 'worldMap',
          pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const WorldMapScreen(),
          ),
        ),

        // Settings
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const SettingsScreen(),
          ),
        ),

        // Progress Screen
        GoRoute(
          path: AppRoutes.progress,
          name: 'progress',
          pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const ProgressScreen(),
          ),
        ),

        // Daily Reward
        GoRoute(
          path: AppRoutes.dailyReward,
          name: 'dailyReward',
          pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const DailyRewardScreen(),
          ),
        ),

        // Math Forest Zone
        GoRoute(
          path: AppRoutes.mathForestLevels,
          name: 'mathForestLevels',
          pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const LevelSelectionScreen(),
          ),
          redirect: (context, state) =>
              _checkZoneUnlock(context, 'math_forest'),
        ),
        GoRoute(
          path: AppRoutes.mathGame,
          name: 'mathGame',
          pageBuilder: (context, state) {
            final levelId = state.pathParameters['levelId'] ?? '';
            return _buildPageWithTransition(
              context: context,
              state: state,
              child: MathGameScreen(levelId: levelId),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.mathLevelComplete,
          name: 'mathLevelComplete',
          pageBuilder: (context, state) {
            final levelId = state.pathParameters['levelId'] ?? '';
            return _buildPageWithTransition(
              context: context,
              state: state,
              child: LevelCompleteScreen(levelId: levelId),
            );
          },
        ),

        // Logic Mountain Zone
        GoRoute(
          path: AppRoutes.logicMountainLevels,
          name: 'logicMountainLevels',
          pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const PlaceholderScreen(title: 'Logic Mountain Levels'),
          ),
          redirect: (context, state) =>
              _checkZoneUnlock(context, 'logic_mountain'),
        ),
        GoRoute(
          path: AppRoutes.logicGame,
          name: 'logicGame',
          pageBuilder: (context, state) {
            final levelId = state.pathParameters['levelId'] ?? '';
            return _buildPageWithTransition(
              context: context,
              state: state,
              child: LogicGameScreen(levelId: levelId),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.logicLevelComplete,
          name: 'logicLevelComplete',
          pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const PlaceholderScreen(title: 'Level Complete'),
          ),
        ),

        // Memory River Zone
        GoRoute(
          path: AppRoutes.memoryRiverLevels,
          name: 'memoryRiverLevels',
          pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const PlaceholderScreen(title: 'Memory River Levels'),
          ),
          redirect: (context, state) =>
              _checkZoneUnlock(context, 'memory_river'),
        ),
        GoRoute(
          path: AppRoutes.memoryGame,
          name: 'memoryGame',
          pageBuilder: (context, state) {
            final levelId = state.pathParameters['levelId'] ?? '';
            return _buildPageWithTransition(
              context: context,
              state: state,
              child: MemoryGameScreen(levelId: levelId),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.memoryLevelComplete,
          name: 'memoryLevelComplete',
          pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const PlaceholderScreen(title: 'Level Complete'),
          ),
        ),

        // Shape Valley Zone
        GoRoute(
          path: AppRoutes.shapeValleyLevels,
          name: 'shapeValleyLevels',
          pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const PlaceholderScreen(title: 'Shape Valley Levels'),
          ),
          redirect: (context, state) =>
              _checkZoneUnlock(context, 'shape_valley'),
        ),
        GoRoute(
          path: AppRoutes.shapeGame,
          name: 'shapeGame',
          pageBuilder: (context, state) {
            final levelId = state.pathParameters['levelId'] ?? '';
            return _buildPageWithTransition(
              context: context,
              state: state,
              child: ShapeGameScreen(levelId: levelId),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.shapeLevelComplete,
          name: 'shapeLevelComplete',
          pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const PlaceholderScreen(title: 'Level Complete'),
          ),
        ),

        // Avatar Customization
        GoRoute(
          path: AppRoutes.avatarCustomization,
          name: 'avatarCustomization',
          pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const AvatarCustomizationScreen(),
          ),
        ),

        // Reward Chest
        GoRoute(
          path: AppRoutes.rewardChest,
          name: 'rewardChest',
          pageBuilder: (context, state) {
            final chestId =
                state.uri.queryParameters['chestId'] ?? 'default_chest';
            return _buildPageWithTransition(
              context: context,
              state: state,
              child: RewardChestScreen(chestId: chestId),
            );
          },
        ),

        // Pet Collection
        GoRoute(
          path: AppRoutes.petCollection,
          name: 'petCollection',
          pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const PetCollectionScreen(),
          ),
        ),
      ],
      errorPageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: ErrorScreen(error: state.error.toString()),
      ),
    );
  }

  /// Builds a page with custom transition animation
  static Page<dynamic> _buildPageWithTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide + Fade transition
        const begin = Offset(0.0, 0.1);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final slideTween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        final fadeTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// Navigation guard to check if a zone is unlocked
  /// Returns null if zone is unlocked, otherwise redirects to world map
  static String? _checkZoneUnlock(BuildContext context, String zoneId) {
    // TODO: Implement actual zone unlock check with provider
    // For now, allow access to all zones during development
    // In production, this will check the player's progress:
    //
    // final isUnlocked = ref.read(worldMapProvider).isZoneUnlocked(zoneId);
    // if (!isUnlocked) {
    //   // Show a dialog or snackbar indicating the zone is locked
    //   return AppRoutes.worldMap;
    // }
    return null;
  }
}

/// Placeholder screen for routes not yet implemented
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coming soon!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.worldMap);
                }
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error screen for navigation errors
class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oops!'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.worldMap),
                icon: const Icon(Icons.home),
                label: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
