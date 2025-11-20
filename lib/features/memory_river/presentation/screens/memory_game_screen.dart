import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../models/memory_game_state.dart';
import '../../providers/memory_game_provider.dart';
import '../widgets/memory_card_widget.dart';

/// Memory Game Screen where players match pairs of cards
/// Features:
/// - Grid of memory cards
/// - Card selection and flip logic
/// - Match/mismatch animations
/// - Moves counter
/// - Timer display (if time limit exists)
/// - Completion detection
class MemoryGameScreen extends ConsumerStatefulWidget {
  final String levelId;

  const MemoryGameScreen({super.key, required this.levelId});

  @override
  ConsumerState<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends ConsumerState<MemoryGameScreen> {
  @override
  void initState() {
    super.initState();
    // Start the level when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(memoryGameProvider(widget.levelId).notifier).startLevel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(memoryGameProvider(widget.levelId));

    // Listen for level completion and navigate
    ref.listen<MemoryGameState>(memoryGameProvider(widget.levelId), (
      previous,
      next,
    ) {
      if (next.status == MemoryGameStatus.completed &&
          previous?.status != MemoryGameStatus.completed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _navigateToLevelComplete();
          }
        });
      }
    });

    return Scaffold(
      body: GradientBackground(
        gradient: AppColors.memoryRiverGradient,
        child: SafeArea(
          child: gameState.status == MemoryGameStatus.loading
              ? _buildLoadingState()
              : gameState.status == MemoryGameStatus.error
              ? _buildErrorState(gameState.errorMessage ?? 'Unknown error')
              : gameState.status == MemoryGameStatus.playing ||
                    gameState.status == MemoryGameStatus.paused
              ? _buildGameState(gameState)
              : _buildInitialState(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: AppTextStyles.heading1.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildGameState(MemoryGameState gameState) {
    if (gameState.level == null) {
      return _buildErrorState('Level not found');
    }

    return Column(
      children: [
        // Header with stats and pause button
        _buildHeader(gameState),

        const SizedBox(height: 16),

        // Memory cards grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildCardsGrid(gameState),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHeader(MemoryGameState gameState) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => _showExitDialog(),
          ),

          // Stats
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Moves counter
                _buildStatCard(
                  icon: Icons.touch_app,
                  label: 'Moves',
                  value: '${gameState.moves}',
                ),
                const SizedBox(width: 16),

                // Matched pairs counter
                _buildStatCard(
                  icon: Icons.check_circle,
                  label: 'Pairs',
                  value:
                      '${gameState.matchedPairs}/${gameState.level!.totalPairs}',
                ),

                // Timer (if time limit exists)
                if (gameState.level!.timeLimit > 0) ...[
                  const SizedBox(width: 16),
                  _buildStatCard(
                    icon: Icons.timer,
                    label: 'Time',
                    value: _formatTime(gameState.timeRemaining),
                    isWarning: gameState.timeRemaining <= 10,
                  ),
                ],
              ],
            ),
          ),

          // Pause button
          IconButton(
            icon: Icon(
              gameState.status == MemoryGameStatus.paused
                  ? Icons.play_arrow
                  : Icons.pause,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => _togglePause(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isWarning ? AppColors.warningYellow : Colors.white,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: isWarning ? AppColors.warningYellow : Colors.white,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsGrid(MemoryGameState gameState) {
    final level = gameState.level!;
    final cards = gameState.cards;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: level.gridColumns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return MemoryCardWidget(
          card: card,
          onTap: () => _handleCardTap(card.id),
          isEnabled:
              gameState.status == MemoryGameStatus.playing &&
              !gameState.hasTwoCardsSelected,
        );
      },
    );
  }

  void _handleCardTap(String cardId) {
    ref.read(memoryGameProvider(widget.levelId).notifier).selectCard(cardId);
  }

  void _togglePause() {
    final notifier = ref.read(memoryGameProvider(widget.levelId).notifier);
    final state = ref.read(memoryGameProvider(widget.levelId));

    if (state.status == MemoryGameStatus.paused) {
      notifier.resumeGame();
    } else {
      notifier.pauseGame();
      _showPauseDialog();
    }
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Paused'),
        content: const Text('Take a break! Resume when you\'re ready.'),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              ref
                  .read(memoryGameProvider(widget.levelId).notifier)
                  .resumeGame();
            },
            child: const Text('Resume'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              context.pop(); // Exit game screen
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Game?'),
        content: const Text('Your progress will be lost if you exit now.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Exit game screen
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _navigateToLevelComplete() {
    // In a full implementation, this would navigate to a level complete screen
    // For now, just show a dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final gameState = ref.read(memoryGameProvider(widget.levelId));
        return AlertDialog(
          title: const Text('Level Complete!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.celebration,
                size: 64,
                color: AppColors.successGreen,
              ),
              const SizedBox(height: 16),
              Text('Moves: ${gameState.moves}'),
              Text('Time: ${_formatTime(gameState.timeSpent)}'),
              Text('Pairs: ${gameState.matchedPairs}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop(); // Close dialog
                context.pop(); // Exit game screen
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
