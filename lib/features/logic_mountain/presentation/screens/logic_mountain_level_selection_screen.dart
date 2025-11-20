import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../progress/providers/progress_provider.dart';
import '../../providers/logic_game_provider.dart';
import '../widgets/winding_logic_path.dart';

/// Logic Mountain Level Selection Screen
/// Shows 20 levels with purple gradient theme
class LogicMountainLevelSelectionScreen extends ConsumerWidget {
  const LogicMountainLevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoneProgressAsync = ref.watch(zoneProgressProvider('logic_mountain'));
    final levelsAsync = ref.watch(logicLevelsProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.indigo.shade900, Colors.purple.shade900],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () => context.pop(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Logic Mountain',
                              style: Theme.of(context).textTheme.headlineMedium!
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            zoneProgressAsync.when(
                              data: (progress) => Text(
                                '${progress?.levelsCompleted ?? 0}/1000 Levels Completed',
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(color: Colors.white70),
                              ),
                              loading: () => const SizedBox(
                                height: 20,
                                width: 100,
                                child: LinearProgressIndicator(),
                              ),
                              error: (_, __) => const SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Level Grid
                Expanded(
                  child: levelsAsync.when(
                    data: (levels) {
                      final levelsCompleted =
                          zoneProgressAsync.value?.levelsCompleted ?? 0;

                      return WindingLogicPath(
                        levels: levels,
                        levelsCompleted: levelsCompleted,
                        onLevelTap: (levelId) {
                          context.pushNamed(
                            'logicGame',
                            pathParameters: {'levelId': levelId},
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    error: (error, stack) => Center(
                      child: Text(
                        'Error loading levels',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
