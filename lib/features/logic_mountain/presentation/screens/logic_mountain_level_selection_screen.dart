import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../progress/providers/progress_provider.dart';
import '../../models/logic_level.dart';
import '../../providers/logic_game_provider.dart';

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
                          color: Colors.white.withOpacity(0.2),
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

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 1,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: levels.length,
                        itemBuilder: (context, index) {
                          final level = levels[index];
                          // Lock if level number is greater than completed + 1
                          // e.g. if 0 completed, level 1 is unlocked, level 2 is locked.
                          final isLocked =
                              level.levelNumber > levelsCompleted + 1;
                          return _buildLevelCard(context, level, isLocked);
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

  Widget _buildLevelCard(
    BuildContext context,
    LogicLevel level,
    bool isLocked,
  ) {
    return GestureDetector(
      onTap: () {
        if (!isLocked) {
          context.pushNamed('logicGame', pathParameters: {'levelId': level.id});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Complete Level ${level.levelNumber - 1} to unlock!',
              ),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: isLocked
                  ? LinearGradient(
                      colors: [Colors.grey.shade400, Colors.grey.shade600],
                    )
                  : LinearGradient(
                      colors: [
                        Colors.purple.shade400,
                        Colors.deepPurple.shade600,
                      ],
                    ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLocked)
                    const Icon(Icons.lock, color: Colors.white54, size: 24)
                  else
                    Text(
                      level.levelNumber.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Star overlay for completed levels
          if (!isLocked && level.starsEarned > 0)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    index < level.starsEarned
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 12,
                    color: index < level.starsEarned
                        ? Colors.amber
                        : Colors.white30,
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
